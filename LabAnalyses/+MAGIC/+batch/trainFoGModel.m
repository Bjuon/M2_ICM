function [net, YPred, scores] = trainFoGModel_eventAligned(kin, fs_kin, specLog, T, eventTimes, FoGvec, preSec, postSec)
% trainFoGModel_eventAligned  Train a fusion network on event-aligned kinematics + spectrogram
%    kin         – raw kinematics (nSamples×nChannels)
%    fs_kin      – kinematics sampling rate (Hz)
%    specLog     – log-power spectrogram (nFreq×nTime)
%    T           – spectrogram time-bin centers (1×nTime), in seconds
%    eventTimes  – vector of event times (in seconds) to align on
%    FoGvec      – binary FoG indicator (nSamples×1) at fs_kin resolution
%    preSec      – seconds before each event to include
%    postSec     – seconds after each event to include
%
%    [net, YPred, scores] = … returns the trained network, its predictions, and class scores

    % --- 1) KINEMATICS PREPROCESSING (UNCHANGED) ---
    % … (butterworth low-pass @10 Hz + filtfilt + z-score per channel)

    % --- 2) EVENT-ALIGNED WINDOWING & LABELING (NEW) ---
    Xkin  = {};
    Xspec = {};
    Y     = [];
    winSamples = round((preSec + postSec) * fs_kin);

    for i = 1:numel(eventTimes)
        tE = eventTimes(i);
        t0 = tE - preSec;
        t1 = tE + postSec;

        % convert to sample indices
        idxStart = max(1, floor(t0 * fs_kin) + 1);
        idxEnd   = min(size(kin_z,1), floor(t1 * fs_kin));
        if (idxEnd - idxStart + 1) ~= winSamples
            continue  % skip if window is incomplete at edges
        end

        % extract kinematic snippet
        Xkin{end+1,1} = kin_z(idxStart:idxEnd, :);

        % find corresponding spectrogram columns
        cols = find(T >= t0 & T < t1);
        expectedCols = round((preSec + postSec) / (T(2)-T(1)));
        if numel(cols) < expectedCols
            continue  % skip if spectrogram segment is too short
        end
        Xspec{end+1,1} = specLog(:, cols);

        % label if any FoG occurred in this window
        Y(end+1,1) = any(FoGvec(idxStart:idxEnd));
    end
    Y = categorical(Y);
    % --- 4) NETWORK DEFINITION & TRAINING (UNCHANGED) ---
    % define kinematics branch
    layersKin = [
        sequenceInputLayer(size(Xkin{1},2),"Name","kin_input")
        convolution1dLayer(5,32,"Padding","same","Name","kin_conv1")
        batchNormalizationLayer("Name","kin_bn1")
        reluLayer("Name","kin_relu1")
        lstmLayer(64,"OutputMode","last","Name","kin_lstm")
    ];

    % define spectrogram branch
    layersSpec = [
        imageInputLayer([size(Xspec{1},1) size(Xspec{1},2) 1],"Name","spec_input")
        convolution2dLayer(3,16,"Padding","same","Name","spec_conv1")
        batchNormalizationLayer("Name","spec_bn1")
        reluLayer("Name","spec_relu1")
        maxPooling2dLayer(2,"Stride",2,"Name","spec_pool1")
        convolution2dLayer(3,32,"Padding","same","Name","spec_conv2")
        batchNormalizationLayer("Name","spec_bn2")
        reluLayer("Name","spec_relu2")
        fullyConnectedLayer(64,"Name","spec_fc")
    ];

    % fusion & classification
    fusionLayers = [
        concatenationLayer(1,2,"Name","concat")
        fullyConnectedLayer(32,"Name","fc1")
        reluLayer("Name","relu_fuse")
        fullyConnectedLayer(2,"Name","fc_out")
        softmaxLayer("Name","softmax")
        classificationLayer("Name","classOutput")
    ];

    % assemble graph
    lgraph = layerGraph;
    lgraph = addLayers(lgraph, layersKin);
    lgraph = addLayers(lgraph, layersSpec);
    lgraph = addLayers(lgraph, fusionLayers);
    lgraph = connectLayers(lgraph, "kin_lstm",  "concat/in1");
    lgraph = connectLayers(lgraph, "spec_fc",   "concat/in2");

    % create combined datastore
    dsKin  = arrayDatastore(Xkin,  'IterationDimension',1);
    dsSpec = arrayDatastore(Xspec, 'IterationDimension',1);
    dsY    = arrayDatastore(Y,     'IterationDimension',1);
    dsAll  = combine(dsKin, dsSpec, dsY);

    % training options
    options = trainingOptions('adam', ...
        'MaxEpochs',10, ...
        'MiniBatchSize',16, ...
        'Shuffle','every-epoch', ...
        'Verbose',false);

    % train and predict
    net       = trainNetwork(dsAll, lgraph, options);
    [YPred, scores] = classify(net, dsAll);
end
