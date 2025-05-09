function plotCombinedLFP_TFSegment(LFP_data, dataTF, outputDir, ...
                                   plotType, eventName)
% plotCombinedLFP_TFSegment – event‑centred QC panel
%
%   LFP_data   : raw Segment  (seg{1}(t))
%   dataTF     : matching TF  (dataTF(t))
%   outputDir  : root folder for PNG / FIG outputs
%   plotType   : 'Raw' | 'dNOR' | …
%   eventName  : 'FO' | 'FC' | …
%
%   For every ⟨event,channel⟩:
%      1⃣  raw LFP  (‑1..+1 s window)
%      2⃣  pre‑computed spectrogram slice  (+ event markers)
%      3⃣  central‑difference residual     (no MAD threshold)
%      4⃣  PSD + FOOOF 1/f fit (same params as artefact routine)

% ─── user‑tunable constants ────────────────────────────────────────────
winSec      = 0.5;          % ±1 s window
freqRangeHz = [10 55];    % PSD range sent to FOOOF
winLenFrac  = 0.5;        % 0.5 s spectrogram window
overlapFrac = 0.5;        % 50 % overlap
nfft        = 1024;
winsmooth = 0.1; % window for the movmean 
derivFactor = 1.5;     % NEW ▸ k × MAD lines drawn on residual plot
fooofSettings = struct('peak_width_limits',[1 12], ...
                       'max_n_peaks',5, ...
                       'min_peak_height',0, ...
                       'peak_threshold',2.0, ...
                       'aperiodic_mode','fixed', ...
                       'verbose',false);

% ─── find events of this type ──────────────────────────────────────────
eventsFound = LFP_data.eventProcess.find('func', ...
                 @(x) strcmp(x.name.name,eventName), 'policy','all');
if iscell(eventsFound), eventsFound = [eventsFound{:}]; end
if isempty(eventsFound)
    warning('No %s events in this segment – nothing plotted.',eventName);
    return
end

% ─── raw LFP & labels --------------------------------------------------
sp        = LFP_data.sampledProcess;
rawMatrix = sp.values{1};
tVec      = sp.times{1};
Fs        = sp.Fs;
nbCh      = size(rawMatrix,2);
chanLbl   = {sp.labels.name};
med       = LFP_data.info('trial').medication;
condTrial = LFP_data.info('trial').condition;        % NEW
if isempty(condTrial) || ~strcmpi(condTrial,'step')  % NEW
    return                                           % NEW
end                                                  % NEW

% ─── determine good channels up front ─────────────────────────────────
if isKey(LFP_data.info,'wrongChannels')
    wrongFlags = LFP_data.info('wrongChannels');   % 1×nCh logical
else
    wrongFlags = false(1,nbCh);
end
goodChIdx = find(~wrongFlags);                    % only these get plotted


% ─── TF cube -----------------------------------------------------------
t_TF   = dataTF.spectralProcess.times{1} + dataTF.spectralProcess.tBlock/2;
f_axis = dataTF.spectralProcess.f;

% ─── output path -------------------------------------------------------
segmentDir = fullfile(outputDir, 'Segments', upper(plotType), ...
                      upper(med));
if ~exist(segmentDir,'dir'), mkdir(segmentDir); end

% ─── loop : event → channel → figure ----------------------------------
for ev = 1:numel(eventsFound)

    evTime = eventsFound(ev).tStart;

    idxLFP = tVec >= evTime-winSec & tVec <= evTime+winSec;
    idxTF  = t_TF >= evTime-winSec & t_TF <= evTime+winSec;
    if ~any(idxLFP) || ~any(idxTF), continue; end

    tRelLFP = tVec(idxLFP) - evTime;
    tRelTF  = t_TF(idxTF)  - evTime;

     % if *no* good channels, skip this segment entirely
    if isempty(goodChIdx)
        warning('Segment has no good channels—skipping.');
        continue
    end

    for k = 1:numel(goodChIdx)
        ch = goodChIdx(k);
        % skip channels flagged as wrong
        wrongFlags = [];
        if isKey(LFP_data.info,'wrongChannels')
            wrongFlags = LFP_data.info('wrongChannels');   % ① map → variable
        end
        if ~isempty(wrongFlags) && wrongFlags(ch)          % ② index
            continue
        end
        signal = rawMatrix(idxLFP,ch);
        if all(isnan(signal) | signal==0), continue; end

        tf_vals = dataTF.spectralProcess.values{1}(idxTF,:,ch)';
        if contains(plotType,'Raw') || contains(plotType,'dNOR')
            tf_vals = 10*log10(tf_vals);
        end
        tf_vals = real(tf_vals);

        % central‑difference residual
        deriv          = nan(size(signal));
        deriv(1)       =  signal(2)-signal(1);
        deriv(2:end-1) = (signal(3:end)-signal(1:end-2))/2;
        deriv(end)     =  signal(end)-signal(end-1);
        resid_cent     = deriv - movmean(deriv,round(winsmooth*Fs));

        med_res = median(resid_cent,'omitnan');
        mad_res = mad(resid_cent,1);          % raw (un‑scaled) MAD
        thr_res = derivFactor * mad_res;

        % PSD + 1/f on the same window
        wLen   = round(winLenFrac*Fs);
        oLap   = round(overlapFrac*wLen);
        [S,F,~] = spectrogram(signal,wLen,oLap,nfft,Fs);
        P       = abs(S).^2 + eps;
        fIdx    = F>=freqRangeHz(1) & F<=freqRangeHz(2);
        avgPSD  = mean(P(fIdx,:),2);
        fooofRes= MAGIC.batch.fooof(F(fIdx),avgPSD,freqRangeHz, ...
                                    fooofSettings,false);
        fit1f   = 10.^(fooofRes.aperiodic_params(1) - ...
                       fooofRes.aperiodic_params(2).*log10(F(fIdx)));


        safeChan = regexprep(chanLbl{ch},'[^\w]','_');
        baseName = sprintf('%s_%s_%02d_%s_%02d_%s', ...
                   LFP_data.info('trial').patient(end-2:end), ... % PatientTag
                   med, ...                                      % medication
                   LFP_data.info('trial').nTrial, ...            % nRun
                   eventName, ...                                % evName
                   LFP_data.info('trial').nStep, ...             % nStep
                   safeChan);                                    % channel label

        % ── figure with 4 stacked tiles ────────────────────────────────
        fig = figure('Visible','off','Color','w', ...
                     'Units','normalized','OuterPosition',[0 0 1 1]);   % NEW ▸ full‑screen
        tl  = tiledlayout(fig,4,1,'TileSpacing','compact','Padding','compact');

        % ① raw LFP
        nexttile(tl);
        plot(tRelLFP, signal,'k','LineWidth',1);
        yline(0,':');
        xlabel('Time (s)'); ylabel('\muV');
        title(baseName, 'Interpreter','none');                           % NEW ▸ full filename
        % ── dynamic title with QC statistics ───────────────────────────
%         stats = [];
%         if isKey(LFP_data.info,'channelScoreStats')
%             stats = LFP_data.info('channelScoreStats');
%         end
%         if ~isempty(stats)
%             ttl = sprintf('%s | %s | μ=%.2f  min=%.2f  max=%.2f  bad=%.0f%%', ...
%                   baseName, eventName, stats.meanScore, stats.minScore, ...
%                   stats.maxScore, stats.pctFlagged);
%         else
%             ttl = sprintf('%s | %s', baseName, eventName);
%         end
%         title(ttl,'Interpreter','none');

        % ② spectrogram (pre‑computed) + event markers
        nexttile(tl);
        surf(tRelTF, f_axis, tf_vals, 'EdgeColor','none');
        view(0,90); axis tight
        MAGIC.batch.plot_for_MAGIC(dataTF.eventProcess, ...
                                   'handle', gca, 'all', 999);
        xlabel('Time (s)'); ylabel('Frequency (Hz)');
        title('Spectrogram (dB)');
        caxis([-10 10]); set(gca,'FontSize',12);
        cb = colorbar;                      % grab the colorbar handle
        cb.Label.String            = 'Power (dB)';    % specify the unit
        cb.Label.FontSize          = 12;              % match axis font size
        cb.Label.Rotation          = 270;             % rotate for vertical bar
        cb.Label.VerticalAlignment = 'bottom';        % position label nicely
        cb.Label.Interpreter       = 'none';          % literal text
        % ③ central residual
         nexttile(tl);
        plot(tRelLFP, resid_cent,'b'); hold on
        yline(med_res,'--k','Median','LineWidth',0.8);                 % NEW
        yline(med_res+thr_res,'--r',sprintf('+%.1f×MAD',derivFactor),... 
              'LineWidth',1.2);                                        % NEW
        yline(med_res-thr_res,'--r',sprintf('-%.1f×MAD',derivFactor),...
              'LineWidth',1.2);                                        % NEW
        xlabel('Time (s)'); ylabel('\Delta\muV');
        title('Central‑diff residual (+MAD thresholds)');
        legend({'Residual','Median','±k×MAD'},'Location','best');      % NEW

        % ④ PSD + 1/f
        nexttile(tl); hold on
        plot(F(fIdx),10*log10(avgPSD),'k','LineWidth',1.2);
        plot(F(fIdx),10*log10(fit1f),'--r','LineWidth',1);
        xlabel('Frequency (Hz)'); ylabel('Power (dB)'); box off
        title(sprintf('PSD & 1/f (offset %.2f)', ...
              fooofRes.aperiodic_params(1)));
% ── save figure ────────────────────────────────────────────────
        safeChan = regexprep(chanLbl{ch},'[^\w]','_');
        baseName = sprintf('%s_%s_%02d_%s_%02d_%s', ...
                   LFP_data.info('trial').patient(end-2:end), ... % PatientTag
                   med, ...                                      % medication
                   LFP_data.info('trial').nTrial, ...            % nRun
                   eventName, ...                                % evName
                   LFP_data.info('trial').nStep, ...             % nStep
                   safeChan);                                    % channel label
        pngFile  = fullfile(segmentDir,[baseName '.png']);
        exportgraphics(fig,pngFile,'Resolution',150);
        savefig(fig,strrep(pngFile,'.png','.fig'));
    end
end
end
