function plotCombinedLFP_TFSegment(LFP_data, dataTF, outputDir, ...
                                   plotType, trialName, eventName)
% plotCombinedLFP_TFSegment – event‑centred QC panel
%
%   LFP_data   : raw Segment  (seg{1}(t))
%   dataTF     : matching TF  (dataTF(t))
%   outputDir  : root folder for PNG / FIG outputs
%   plotType   : 'Raw' | 'dNOR' | …
%   trialName  : sub‑folder tag (e.g. 'Trial_07')
%   eventName  : 'FO' | 'FC' | …
%
%   For every ⟨event,channel⟩:
%      1⃣  raw LFP  (‑1..+1 s window)
%      2⃣  pre‑computed spectrogram slice  (+ event markers)
%      3⃣  central‑difference residual     (no MAD threshold)
%      4⃣  PSD + FOOOF 1/f fit (same params as artefact routine)

% ─── user‑tunable constants ────────────────────────────────────────────
winSec      = 1;          % ±1 s window
freqRangeHz = [10 55];    % PSD range sent to FOOOF
winLenFrac  = 0.5;        % 0.5 s spectrogram window
overlapFrac = 0.5;        % 50 % overlap
nfft        = 1024;
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

% ─── TF cube -----------------------------------------------------------
t_TF   = dataTF.spectralProcess.times{1} + dataTF.spectralProcess.tBlock/2;
f_axis = dataTF.spectralProcess.f;

% ─── output path -------------------------------------------------------
segmentDir = fullfile(outputDir, 'Segments', upper(plotType), ...
                      upper(med), trialName);
if ~exist(segmentDir,'dir'), mkdir(segmentDir); end

% ─── loop : event → channel → figure ----------------------------------
for ev = 1:numel(eventsFound)

    evTime = eventsFound(ev).tStart;

    idxLFP = tVec >= evTime-winSec & tVec <= evTime+winSec;
    idxTF  = t_TF >= evTime-winSec & t_TF <= evTime+winSec;
    if ~any(idxLFP) || ~any(idxTF), continue; end

    tRelLFP = tVec(idxLFP) - evTime;
    tRelTF  = t_TF(idxTF)  - evTime;

    for ch = 1:nbCh

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
        resid_cent     = deriv - movmean(deriv,round(0.10*Fs));

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

        % ── figure with 4 stacked tiles ────────────────────────────────
        fig = figure('Visible','off','Color','w', ...
                     'Units','centimeters','Position',[5 5 14 18]);
        tl  = tiledlayout(fig,4,1,'TileSpacing','compact','Padding','compact');

        % ① raw LFP
        nexttile(tl);
        plot(tRelLFP, signal,'k','LineWidth',1);
        yline(0,':');
        xlabel('Time (s)'); ylabel('\muV');
        title(sprintf('%s – raw LFP', chanLbl{ch}), 'Interpreter','none');

        % ② spectrogram (pre‑computed) + event markers
        nexttile(tl);
        surf(tRelTF, f_axis, tf_vals, 'EdgeColor','none');
        view(0,90); axis tight
        MAGIC.batch.plot_for_MAGIC(dataTF.eventProcess, ...
                                   'handle', gca, 'all', 999);
        xlabel('Time (s)'); ylabel('Frequency (Hz)');
        title('Spectrogram (dB)');
        caxis([-10 10]); set(gca,'FontSize',12);

        % ③ central residual
        nexttile(tl);
        plot(tRelLFP, resid_cent,'b');
        xlabel('Time (s)'); ylabel('\Delta\muV');
        title('Central‑diff residual');

        % ④ PSD + 1/f
        nexttile(tl); hold on
        plot(F(fIdx),10*log10(avgPSD),'k','LineWidth',1.2);
        plot(F(fIdx),10*log10(fit1f),'--r','LineWidth',1);
        xlabel('Frequency (Hz)'); ylabel('Power (dB)'); box off
        title(sprintf('PSD & 1/f (offset %.2f)', ...
              fooofRes.aperiodic_params(1)));

        % ── save figure ────────────────────────────────────────────────
        safeChan = regexprep(chanLbl{ch},'[^\w]','_');
        baseName = sprintf('%s_T%02d_S%02d_%s_ev%02d_%s', ...
                   LFP_data.info('trial').patient(end-2:end), ...
                   LFP_data.info('trial').nTrial, ...
                   LFP_data.info('trial').nStep, ...
                   eventName, ev, safeChan);
        pngFile = fullfile(segmentDir,[baseName '.png']);
        exportgraphics(fig,pngFile,'Resolution',150);
        savefig(fig,strrep(pngFile,'.png','.fig'));
        close(fig);
    end
end
end
