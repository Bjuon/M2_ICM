function [cleanedSeg_flagged, stats, artifactFlags] = computePSDandArtifactRejection(cleanedSeg, baselineStruct)
% ────────────────────────────────────────────────────────────────────────────────
%  RMSE‑based 1/f validation (≥50 % increase in 10‑55 Hz band).
% ────────────────────────────────────────────────────────────────────────────────
global TrialRejectionDir
todo.plot = 0;
plotVisible = 'off'; % set off or on figure visibility 

%% ───── Parameters ─────────────────────────────────────────────────────────────
RMSEThreshold           = 0.5;              % >50 % increase
freqRMSERangeHz         = [10 55];           % band used for RMSE
fs            = cleanedSeg(1).sampledProcess.Fs;
eventWindowSec= [-1 1];
stepEventNames= {'FC','FO'};
freqRangeHz   = [10 55];
winLenSamples = round(fs*0.5);
overlapSamples= round(winLenSamples*0.5);
nfft          = 1024;

%% ───── FOOOF settings (unchanged) ─────────────────────────────────────────────
fooofSettings = struct();
fooofSettings.peak_width_limits = [1 12];
fooofSettings.max_n_peaks       = 5;
fooofSettings.min_peak_height   = 0;
fooofSettings.peak_threshold    = 2.0;
fooofSettings.aperiodic_mode    = 'fixed';
fooofSettings.verbose           = false;

%% ───── Initialisation ─────────────────────────────────────────────────────────
cleanedSeg_flagged = cleanedSeg;
nSegments          = numel(cleanedSeg);
if nSegments==0, error('cleanedSeg is empty.'); end
nChannels          = size(cleanedSeg(1).sampledProcess.values{1,1},2);
labels     = cleanedSeg(1).sampledProcess.labels;          % struct array
chanNames  = cellfun(@(L) L.name, num2cell(labels), ...
                     'UniformOutput', false);


sampleVals    = cleanedSeg(1).sampledProcess.values{1,1};  
emptyChannels = all(isnan(sampleVals) | sampleVals==0, 1); 
if any(emptyChannels)
    warning('computePSD:EmptyChannels', ...
            'Excluding empty channels: %s', ...
            strjoin(chanNames(emptyChannels), ', '));
end

% precompute list of “good” channels -->
goodChIdx      = find(~emptyChannels);  
nGoodChannels  = numel(goodChIdx);



artifactFlags      = false(nSegments,nChannels);
allBaselineAperiodicComponents = [];
allEventAperiodicComponents    = [];
allEventRmses                   = [];
numSegmentsChecked = 0; numEventsChecked = 0;

%% ───── PASS‑1  (baseline aperiodic fit)  
disp('Calculating baseline aperiodic component...');

for i = 1:nSegments
    trialInfo = cleanedSeg(i).info('trial');
    trialKey = sprintf('%s_%d_%s', trialInfo.patient, trialInfo.nTrial, trialInfo.medication);
    idxBaseline = find(arrayfun(@(x) strcmp(x.trialKey, trialKey), baselineStruct));
    
    if ~isempty(idxBaseline)
        bslSignal = baselineStruct(idxBaseline).signal;
        if size(bslSignal, 1) < winLenSamples
            warning('AR: Baseline window too short for spectrogram in trial %s. Assigning NaN baseline.', trialKey);
            baselineStruct(idxBaseline).aperiodic = nan(1, nChannels);
            continue;
        end
        
        trialBaselineAperiodic = nan(1, nChannels);
        % For each channel, we store frequency vector, averaged PSD, and FOOOF result.
        baselineFrequencies = cell(1, nChannels); 
        baselineAvgPSD = cell(1, nChannels);      
        baselineFooofRes = cell(1, nChannels);      
        
   
        for ch = 1:nChannels
          if emptyChannels(ch)                 % skip entirely empty channels
            trialBaselineAperiodic(ch) = NaN;
            baselineFrequencies{ch}       = [];
            baselineAvgPSD{ch}           = [];
            baselineFooofRes{ch}         = [];
            continue;
          end
            [s, f, ~] = spectrogram(bslSignal(:, ch), winLenSamples, overlapSamples, nfft, fs);
            freqIdx = (f >= freqRangeHz(1)) & (f <= freqRangeHz(2));
            if any(freqIdx)
                powerS = abs(s(freqIdx, :)).^2 + eps; % added espilon to avoid zero values
                avgPSD = mean(powerS, 2);  % avgPSD in linear power units
                if any(~isfinite(avgPSD))
                   warning('AR: canal %d du trial %s ignoré (PSD invalide).', ch, trialKey);
                   continue
                end
                fooofRes_bsl = MAGIC.batch.fooof(f(freqIdx), avgPSD, [freqRangeHz(1), freqRangeHz(2)], fooofSettings, false);
                trialBaselineAperiodic(ch) = fooofRes_bsl.aperiodic_params(1);
                
                % Save baseline metrics per channel for later plotting/comparison.
                baselineFrequencies{ch} = f(freqIdx);   
                baselineAvgPSD{ch}      = avgPSD;         
                baselineFooofRes{ch}    = fooofRes_bsl;
            else
                trialBaselineAperiodic(ch) = NaN;
                baselineFrequencies{ch} = [];
                baselineAvgPSD{ch}      = [];
                baselineFooofRes{ch}    = [];
            end
        end
        
        % Save the computed aperiodic vector and additional metrics into baselineStruct.
        baselineStruct(idxBaseline).aperiodic = trialBaselineAperiodic;
        baselineStruct(idxBaseline).f = baselineFrequencies;
        baselineStruct(idxBaseline).avgPSD = baselineAvgPSD;
        baselineStruct(idxBaseline).fooofResults = baselineFooofRes;
        
        % Accumulate for overall baseline statistics.
        allBaselineAperiodicComponents = [allBaselineAperiodicComponents; trialBaselineAperiodic];
    else
        warning('AR: No baseline found in baselineStruct for trial %s. Cannot store aperiodic component.', trialKey);
    end
end

disp('Baseline Computation Finished');

%% ───── PASS‑2  (event fit & RMSE flagging)  ───────────────────────────────────
disp('Computing event aperiodic fit for step events (FO/FC) and computing relative RMSE...');
relRmses = [];  % <<< NEW: collect all relative RMSE ratios

for i = 1:nSegments
    trialInfo = cleanedSeg(i).info('trial');
    if ~strcmp(trialInfo.condition,'step'), continue; end
    numSegmentsChecked = numSegmentsChecked + 1;

    trialKey   = sprintf('%s_%d_%s',trialInfo.patient,trialInfo.nTrial,trialInfo.medication);
    idxBaseline= find(arrayfun(@(x) strcmp(x.trialKey,trialKey),baselineStruct),1);
    if isempty(idxBaseline)
        currentTrialBaseline = nan(1,nChannels); baselineFooofAllCh = cell(1,nChannels);
    else
        currentTrialBaseline = baselineStruct(idxBaseline).aperiodic;
        baselineFooofAllCh   = baselineStruct(idxBaseline).fooofResults;
    end

    signalValues = cleanedSeg(i).sampledProcess.values{1,1};
    tVec         = cleanedSeg(i).sampledProcess.times{1,1};

    eventsFound  = cleanedSeg(i).eventProcess.find('func',...
                   @(x) ismember(x.name.name,stepEventNames),'policy','all');
    if iscell(eventsFound), eventsFound=[eventsFound{:}]; end
    if isempty(eventsFound), continue; end

    eventPSD = struct('eventTime',[],'eventAperiodic',[],'perChannelPSD',[],...
                      'eventArtifactFlags',[],'rmseValues',[]);

    for ev = 1:numel(eventsFound)
        numEventsChecked = numEventsChecked + 1;
        evTime = eventsFound(ev).tStart; % demander à mathieu si bon tstart
        idxWin = tVec>=max(tVec(1),evTime+eventWindowSec(1)) & ...
                 tVec<=min(tVec(end),evTime+eventWindowSec(2));
        if ~any(idxWin), continue; end
        evtSig = signalValues(idxWin,:);
        if size(evtSig,1)<winLenSamples, continue; end

        perChannelPSD        = cell(1,nChannels);
        eventAperiodic       = nan(1,nChannels);
        eventArtifactFlags   = false(1,nChannels);
        rmseValues           = nan(1,nChannels);

        for ch = 1:nChannels
            if emptyChannels(ch)           % also skip in event‐PSD
                continue;
            end
            sig = evtSig(:,ch);
            if any(isnan(sig)|isinf(sig)), continue; end

            [s,f,~] = spectrogram(sig,winLenSamples,overlapSamples,nfft,fs);
            fIdx  = f>=freqRangeHz(1)&f<=freqRangeHz(2);
            if ~any(fIdx), continue; end
              pwr   = abs(s(fIdx,:)).^2 + eps; avgPSD = mean(pwr,2); % added espilon to avoid zero values
            fooofEvt = MAGIC.batch.fooof(f(fIdx),avgPSD,[freqRangeHz(1),freqRangeHz(2)],fooofSettings,false);

            eventAperiodic(ch) = fooofEvt.aperiodic_params(1);
            perChannelPSD{ch}  = struct('f',f(fIdx),'avgPSD',avgPSD,'fooofResults',fooofEvt);

            % ----- RMSE comparison -----
            bf = baselineFooofAllCh{ch};
            if ~isempty(bf)
                fCommon = f(fIdx); fCommon = fCommon(fCommon>=freqRMSERangeHz(1)&fCommon<=freqRMSERangeHz(2));
                if numel(fCommon)>=5
                    % NEW  (correct 1/f model: offset  −  slope·log10(f))
                    fitEvt = 10.^(fooofEvt.aperiodic_params(1) - fooofEvt.aperiodic_params(2).*log10(fCommon));
                    fitBsl = 10.^(bf.aperiodic_params(1)       - bf.aperiodic_params(2)     .*log10(fCommon));
                    rmse   = sqrt(mean((fitEvt-fitBsl).^2));
                    rmseValues(ch) = rmse;
                         % <<< NEW: compute relative RMSE ratio
                    relRatio = rmse / mean(fitEvt);
                    relRmses(end+1) = relRatio;
                    eventPSD(ev).relativeRmse(ch) = relRatio;  % optional per-event storage

                    if relRatio > RMSEThreshold
                        eventArtifactFlags(ch)=true; artifactFlags(i,ch)=true;
                    end
                end
            end
        end

        eventPSD(ev).eventTime          = evTime;
        eventPSD(ev).eventAperiodic     = eventAperiodic;
        eventPSD(ev).perChannelPSD      = perChannelPSD;
        eventPSD(ev).eventArtifactFlags = eventArtifactFlags;
        validRmse = rmseValues(~isnan(rmseValues));
        allEventRmses = [allEventRmses, validRmse];
        eventPSD(ev).rmseValues         = rmseValues;

        valid = ~eventArtifactFlags & ~isnan(eventAperiodic);
        if any(valid)
            allEventAperiodicComponents = [allEventAperiodicComponents,eventAperiodic(valid)];
        end
    end
    cleanedSeg_flagged(i).info('psdInfo') = eventPSD;
end

%% Pass 3: Update Segment Metadata with Artifact Flags
disp('Adding artifact flags to segment metadata...');
for i = 1:nSegments
    flaggedChannels = find(artifactFlags(i, :));
    if ~isempty(flaggedChannels)
        % we store the flagged channel indices in the segment's info map with a new key.
        cleanedSeg_flagged(i).info('artifactChannels') = flaggedChannels;
        
        % Optionally, update the trial condition (in the trial info) to indicate artifact rejection.
        if isKey(cleanedSeg_flagged(i).info, 'trial')
            trialInfo = cleanedSeg_flagged(i).info('trial');
            if ~endsWith(trialInfo.condition, '_wrong')
                trialInfo.condition = [trialInfo.condition, '_wrong'];
            end
            cleanedSeg_flagged(i).info('trial') = trialInfo;
%             fprintf('AR: Added artifact flags (Channels: %s) to metadata for segment %d.\n', ...
%                     mat2str(flaggedChannels), i);
        else
            warning('AR: Cannot update trial metadata for segment %d - trial info missing.', i);
        end
    end
end
disp('Metadata flagging finished.');

%% Compile Statistics
stats = struct();
stats.totalSegments = nSegments;
stats.numSegmentsChecked = numSegmentsChecked;
stats.numEventsChecked = numEventsChecked;
stats.channelNames       = chanNames;
if ~isempty(allBaselineAperiodicComponents)
    stats.averageBaselineAperiodicComponents = mean(allBaselineAperiodicComponents, 1, 'omitnan');
    stats.overallAverageBaselineAperiodicComponents = mean(stats.averageBaselineAperiodicComponents, 'omitnan');
else
    stats.averageBaselineAperiodicComponents = nan(1, nChannels);
    stats.overallAverageBaselineAperiodicComponents = NaN;
end

if ~isempty(allEventAperiodicComponents)
    % All event offsets are numeric values collected from valid events.
    stats.overallAverageEventAperiodicComponents = mean(allEventAperiodicComponents, 'omitnan');
else
    stats.overallAverageEventAperiodicComponents = NaN;
end

stats.rejectedSegmentsCountPerChannel = sum(artifactFlags, 1);
stats.percentageSegmentsRejectedPerChannel = (stats.rejectedSegmentsCountPerChannel / numSegmentsChecked) * 100;
stats.totalFlaggedChannels = sum(artifactFlags(:));

% RMSE summary statistics
if ~isempty(allEventRmses)
    stats.meanEventRMSE   = mean(allEventRmses, 'omitnan');
    stats.medianEventRMSE = median(allEventRmses, 'omitnan');
    stats.maxEventRMSE    = max(allEventRmses, [], 'omitnan');
    stats.numEventRMSE    = numel(allEventRmses);
else
    stats.meanEventRMSE   = NaN;
    stats.medianEventRMSE = NaN;
    stats.maxEventRMSE    = NaN;
    stats.numEventRMSE    = 0;
end

if ~isempty(relRmses)
    stats.minRelativeRMSE    = min(relRmses,    [], 'omitnan');
    stats.meanRelativeRMSE   = mean(relRmses,   'omitnan');
    stats.maxRelativeRMSE    = max(relRmses,    [], 'omitnan');
else
    stats.minRelativeRMSE    = NaN;
    stats.meanRelativeRMSE   = NaN;
    stats.maxRelativeRMSE    = NaN;
end

stats.freqRangeHz        = freqRangeHz;
stats.freqRMSERangeHz    = freqRMSERangeHz;
stats.RMSEThreshold      = RMSEThreshold;
stats.fooofSettings      = fooofSettings;

% Initialize counters
usableFO = 0;     % number of FO events with ≥1 OK channel
usableFC = 0;     % number of FC events with ≥1 OK channel
FOcounts  = [];   % for each FO event, number of OK channels
FCcounts  = [];   % for each FC event, number of OK channels


for i = 1:nSegments
    % Only care about 'step' segments
    tinfo = cleanedSeg_flagged(i).info('trial');
    if ~startsWith(tinfo.condition,'step'), continue; end

    evs = cleanedSeg_flagged(i).eventProcess.values{1,1};
    psd = cleanedSeg_flagged(i).info('psdInfo');

    for e = 1:numel(psd)
        okCh = find(~psd(e).eventArtifactFlags & ~emptyChannels);
        if ~isempty(okCh)
            switch evs(e).name.name
                case 'FO'
                    usableFO = usableFO + 1;
                    FOcounts(end+1) = numel(okCh);

                    
                case 'FC'
                    usableFC = usableFC + 1;
                    FCcounts(end+1) = numel(okCh);
            end
        end
    end
end

% --- Print summary statistics to the command window ---
fprintf('\n=== Usable step events (≥1 OK channel) ===\n');
fprintf('FO events: %d\n', usableFO);
fprintf('FC events: %d\n', usableFC);

fprintf('\n=== OK-channel count distribution per event ===\n');
if ~isempty(FOcounts)
    fprintf('  FO – min: %d, mean: %.1f, max: %d OK channels\n', ...
        min(FOcounts), mean(FOcounts), max(FOcounts));
else
    fprintf('  FO – no usable events\n');
end
if ~isempty(FCcounts)
    fprintf('  FC – min: %d, mean: %.1f, max: %d OK channels\n', ...
        min(FCcounts), mean(FCcounts), max(FCcounts));
else
    fprintf('  FC – no usable events\n');
end


% Store into stats
stats.usableEvents.FO = usableFO;
stats.usableEvents.FC = usableFC;

for i = 1:nSegments
    tinfo = cleanedSeg_flagged(i).info('trial');
    if ~startsWith(tinfo.condition,'step'), continue; end

    keySuffix = sprintf('%s_%d_%s', tinfo.patient(end-2:end), tinfo.nTrial, tinfo.medication);
    eventPSD  = cleanedSeg_flagged(i).info('psdInfo');
    evs       = cleanedSeg_flagged(i).eventProcess.values{1,1};

    for e = 1:numel(eventPSD)
        % find OK‐channel **names**
        okIdx = find( ~eventPSD(e).eventArtifactFlags & ~emptyChannels );        
        if isempty(okIdx), continue; end
        okNames = chanNames(okIdx);

        figName = sprintf('%s_%s_step%02d', keySuffix, evs(e).name.name, tinfo.nStep);

        % join into comma‐separated list
        fprintf('Event %s: OK channels [%s]\n', ...
            figName, strjoin(okNames, ', '));
    end
end

%% ───── PASS‑4  (plotting)  ───────────────────────────────────────────────────
if todo.plot
    disp('Plotting Thenaisie start')

     patientTrig = cleanedSeg_flagged(i).info('trial').patient(end-2:end);
     patientDir  = fullfile(TrialRejectionDir, patientTrig);
    if ~exist(patientDir, 'dir')
        mkdir(patientDir);
    end
    for i = 1:nSegments
        trialInfo = cleanedSeg_flagged(i).info('trial');
        if ~startsWith(trialInfo.condition,'step'), continue; end

        keySuffix  = sprintf('%s_%d_%s',trialInfo.patient(end-2:end),...
                                          trialInfo.nTrial,trialInfo.medication);
        idxBaseline= find(endsWith({baselineStruct.trialKey},keySuffix),1);
        if isempty(idxBaseline), warning('Plot‑PSD: baseline “%s” not found',keySuffix); continue; end

        eventPSD = cleanedSeg_flagged(i).info('psdInfo');
        evs      = cleanedSeg_flagged(i).eventProcess.values{1,1};

        for e = 1:numel(eventPSD)
            evName  = evs(e).name.name;
            figName = sprintf('%s_%s_step%02d', keySuffix, evName, trialInfo.nStep);
            figure('Name',figName,'Color','w', 'Visible', plotVisible);
            numCols=4; numRows=ceil(nGoodChannels/numCols); % changed to good channels
            tl=tiledlayout(numRows,numCols,'TileSpacing','compact','Padding','compact');
            title(tl,strrep(figName,'_',' '),'Interpreter','none',...
                  'FontWeight','bold','FontSize',12);

            legendHandles = gobjects(1,4);

            for idx = 1:nGoodChannels
                ch = goodChIdx(idx);          % actual channel number

                ax = nexttile(tl,idx); hold(ax,'on');

                % --- baseline & event PSD
                fBsl = baselineStruct(idxBaseline).f{ch};
                pBsl = baselineStruct(idxBaseline).avgPSD{ch};
                evt  = eventPSD(e).perChannelPSD{ch};

                h1=plot(ax,fBsl,10*log10(pBsl),'k-','LineWidth',1.5);
                h2=plot(ax,evt.f,10*log10(evt.avgPSD),'b-','LineWidth',1.5);

                % --- aperiodic fits
                bf   = baselineStruct(idxBaseline).fooofResults{ch};
                ef   = evt.fooofResults;
                fitB = 10.^(bf.aperiodic_params(1) - bf.aperiodic_params(2).*log10(fBsl));
                fitE = 10.^(ef.aperiodic_params(1) - ef.aperiodic_params(2).*log10(evt.f));
                h3=plot(ax,fBsl,10*log10(fitB),'k--','LineWidth',1);
                h4=plot(ax,evt.f,10*log10(fitE),'b--','LineWidth',1);


                % --- annotate RMSE at fixed north‑centre
                rmseVal = eventPSD(e).rmseValues(ch);
                if ~isnan(rmseVal)
                    % reconstruct the event 1/f curve for this channel
                    freqs    = evt.f;                     % frequency vector used in the event PSD
                    fooofEvt = evt.fooofResults;          % saved FOOOF result
                    % 1/f model: power = 10^(offset − slope*log10(freq))
                    fitEvt   = 10.^( fooofEvt.aperiodic_params(1) ...
                                   - fooofEvt.aperiodic_params(2).*log10(freqs) );
                    % compute the normalized RMSE ratio: rmse / mean(event‑fit)
                    relRatio = rmseVal ./ mean(fitEvt);
                    % turn that into a text label (linear ratio and its dB equivalent)
                    txt = sprintf('RelRMSE=%.2f (%.1f dB)', relRatio, 10*log10(relRatio));
                    text(ax, 0.5, 1, txt, ...
                         'Units','normalized', ...
                         'FontSize',7, ...
                         'HorizontalAlignment','center', ...
                         'VerticalAlignment','top', ...
                         'Interpreter','none');
                 end

                % --- channel title if flagged
                isFlaggedNow = eventPSD(e).eventArtifactFlags(ch);   % <<—— per‑event flag
                if isFlaggedNow
                    title(ax, sprintf('%s: FLAGGED', chanNames{ch}), 'Color','k');
                else
                    title(ax, sprintf('%s: OK',      chanNames{ch}));
                end

                xlabel(ax,'Freq (Hz)'); ylabel(ax,'Power (dB)');
                xlim(ax,freqRangeHz);
                hold(ax,'off');

                if idx==1, legendHandles=[h1 h2 h3 h4]; end
            end

            lg=legend(legendHandles,{'Baseline PSD','Event PSD','Baseline 1/f','Event 1/f'},...
                      'Orientation','horizontal','Box','off','FontSize',14);
            lg.Layout.Tile='north';

            set(gcf,'Position',[100 100 1200 800]);
            saveas(gcf,fullfile(patientDir,[figName,'.png']));
          
            close(gcf);
        end
    end
end

end
