function [net, metrics] = trainFoG_CNN(inputData, labels, patientDir)
% trainFoG_CNN  Train and evaluate FoG detection CNN
%   [net, metrics] = trainFoG_CNN(inputData, labels, patientDir)
%   • inputData: Cell array of input data (from assembleFoGInput)
%   • labels: Cell array of FoG labels (0/1)
%   • patientDir: Directory to save model and results
%
%   Returns:
%   • net: Trained CNN network
%   • metrics: Structure with performance metrics

% Convert cell arrays to arrays
nSeg = length(inputData);
specSize = size(inputData{1}.spec);
kinSize = size(inputData{1}.kin);

% Initialize arrays
specs = zeros([specSize nSeg]);
kins = zeros([kinSize nSeg]);
allLabels = zeros(nSeg, 1);

for i = 1:nSeg
    specs(:,:,:,i) = inputData{i}.spec;
    kins(:,:,i) = inputData{i}.kin;
    allLabels(i) = labels{i};
end

% Split data (80% train, 20% test)
idx = randperm(nSeg);
trainIdx = idx(1:round(0.8*nSeg));
testIdx = idx(round(0.8*nSeg)+1:end);

% Create training and test sets
XTrain = struct('spec', specs(:,:,:,trainIdx), 'kin', kins(:,:,trainIdx));
YTrain = allLabels(trainIdx);
XTest = struct('spec', specs(:,:,:,testIdx), 'kin', kins(:,:,testIdx));
YTest = allLabels(testIdx);

% Define CNN architecture
layers = [
    % LFP spectrogram branch
    sequenceInputLayer([specSize(1) specSize(2) specSize(3)], 'Name', 'specInput')
    convolution2dLayer(3, 16, 'Padding', 'same', 'Name', 'conv1')
    batchNormalizationLayer('Name', 'bn1')
    reluLayer('Name', 'relu1')
    maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool1')
    
    convolution2dLayer(3, 32, 'Padding', 'same', 'Name', 'conv2')
    batchNormalizationLayer('Name', 'bn2')
    reluLayer('Name', 'relu2')
    maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool2')
    
    fullyConnectedLayer(64, 'Name', 'fcSpec')
    reluLayer('Name', 'reluSpec')
    
    % Kinematics branch
    sequenceInputLayer([kinSize(1) kinSize(2)], 'Name', 'kinInput')
    convolution2dLayer(3, 16, 'Padding', 'same', 'Name', 'convKin')
    batchNormalizationLayer('Name', 'bnKin')
    reluLayer('Name', 'reluKin')
    maxPooling2dLayer(2, 'Stride', 2, 'Name', 'poolKin')
    
    fullyConnectedLayer(64, 'Name', 'fcKin')
    reluLayer('Name', 'reluKin')
    
    % Merge branches
    additionLayer(2, 'Name', 'add')
    
    fullyConnectedLayer(1, 'Name', 'fcFinal')
    sigmoidLayer('Name', 'sigmoid')
    classificationLayer('Name', 'class')
];

% Define training options
options = trainingOptions('adam', ...
    'MaxEpochs', 50, ...
    'MiniBatchSize', 32, ...
    'InitialLearnRate', 0.001, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.1, ...
    'LearnRateDropPeriod', 20, ...
    'Shuffle', 'every-epoch', ...
    'Verbose', false, ...
    'Plots', 'training-progress');

% Train network
net = trainNetwork(XTrain, YTrain, layers, options);

% Evaluate on test set
YPred = predict(net, XTest);
YPred = YPred > 0.5; % Convert probabilities to binary predictions

% Calculate metrics
metrics = struct;
metrics.Accuracy = sum(YPred == YTest) / numel(YTest);
metrics.ConfusionMatrix = confusionmat(YTest, YPred);
metrics.Precision = metrics.ConfusionMatrix(2,2) / sum(metrics.ConfusionMatrix(:,2));
metrics.Recall = metrics.ConfusionMatrix(2,2) / sum(metrics.ConfusionMatrix(2,:));

% Save results
save(fullfile(patientDir, 'FoG_CNN_results.mat'), 'net', 'metrics');

% Plot confusion matrix
figure;
confusionchart(YTest, YPred);
title('FoG Detection Confusion Matrix');
saveas(gcf, fullfile(patientDir, 'FoG_CNN_confusion.png'));

end
