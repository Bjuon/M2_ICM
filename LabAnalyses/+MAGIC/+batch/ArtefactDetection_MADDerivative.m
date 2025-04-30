function [seg_clean, stats] = ArtefactDetection_MADDerivative(seg_clean)
% ArtefactDetection_MADDerivative
% 2) Derivative MAD interpolation using *central differences* + residual
%    After cleaning, stores per‑segment flags and per‑event (FO/FC) flags.
% 3) Returns a stats struct summarising rejection at segment & event level.
% ----------------------------------------------------------------------
% OUTPUT
%   seg_clean – updated Segment array with cleaned data and info fields:
%                   ▸ .info('derivFlags')       – 1×nCh logical, whole segment
%                   ▸ .info('derivEventInfo')   – struct array per FO/FC event
%   stats         – struct with counts, percentages, usable events etc.


%% ===== USER‑TUNABLE CONSTANTS ==========================================
derivFactor    = 1.5;        % Derivative threshold = derivFactor × MAD
smoothWinFrac  = 0.05;        % Fraction of Fs for movmean (0.1 ⇒ 100 ms)
eventWindowSec = [-1 1];     % Window (s) around FO / FC for per‑event flags
stepEventNames = {'FO','FC'}; % Behavioural event names of interest
%% ======================================================================

% Optional diagnostic plotting controlled by global `todo.plot`
global Deriv_Dir; 
todo.plot =0;
todo.plot_surrogate = 1;
plotVisible = 'on';
if isempty(Deriv_Dir), Deriv_Dir = fullfile(pwd,'DerivPlots'); end

%% ---------- INITIALISATION --------------------------------------------
nSeg   = numel(seg_clean);
firstSp= seg_clean(1).sampledProcess;
[~, nCh] = size(firstSp.values{1});
segmentFlags  = false(nSeg, nCh);   % whole‑segment flags (any sample)
allEventFlags = [];                 % will accumulate [nEvents × nCh]
usableFO = 0; usableFC = 0; FOcounts = []; FCcounts = [];
numEventsChecked = 0;

%% ---------- MAIN LOOP over segments -----------------------------------
for iSeg = 1:nSeg
    sp      = seg_clean(iSeg).sampledProcess;
    raw     = sp.values{1};     % [samples × channels]
    Fs      = sp.Fs;
    timeVec = sp.times{1};
    nSamples= size(raw,1);

  %-------- Derivative‑based MAD interpolation -------------------

    % --- Method 1 : Simple Derivative‑Based Filtering ------------------
    % deriv = diff(raw);
    % deriv = [deriv(1,:); deriv];   % prepend to preserve size
    % ArtefactFlags = false(nSamples, nCh);
    % CleanedData   = raw;
    % for ch = 1:nCh
    %     d_med = median(deriv(:,ch));
    %     d_mad = mad(deriv(:,ch),1);
    %     derivOutliers = abs(deriv(:,ch) - d_med) > derivFactor * d_mad;
    %     ArtefactFlags(:,ch) = derivOutliers;
    %     goodIdx = ~derivOutliers;
    %     if nnz(goodIdx) >= 2
    %         CleanedData(:,ch) = interp1(timeVec(goodIdx), CleanedData(goodIdx,ch), timeVec, 'pchip', 'extrap');
    %     end
    % end
    % % it’s asymmetric and sensitive to noise—every little perturbation shows up.

    % --- Method 2 : Central differences + residual (ACTIVE) ------------
    deriv            = zeros(size(raw));
    deriv(1,:)       = raw(2,:) - raw(1,:);
    deriv(2:end-1,:) = (raw(3:end,:) - raw(1:end-2,:)) / 2;
    deriv(end,:)     = raw(end,:) - raw(end-1,:);

    window       = round(smoothWinFrac * Fs);   % e.g. 0.1 s window
    smooth_deriv = movmean(deriv, window);
    residual     = deriv - smooth_deriv;        % fast component

    CleanedData  = raw;                         % start from amp‑cleaned
    perChanMask  = false(nSamples, nCh);        % store masks for per‑event eval

    for ch = 1:nCh
        r_med = median(residual(:,ch));
        r_mad = mad(residual(:,ch),1);
        outDer= abs(residual(:,ch) - r_med) > derivFactor * r_mad;
        perChanMask(:,ch)   = outDer;
        segmentFlags(iSeg,ch)= any(outDer);
        goodIdx = ~outDer;
        if nnz(goodIdx) >= 2
            CleanedData(:,ch) = interp1(timeVec(goodIdx), CleanedData(goodIdx,ch), timeVec, 'pchip', 'extrap');
        end
    end

    % Save cleaned trace and segment‑level flags
    seg_clean(iSeg).sampledProcess.values{1} = CleanedData;
    seg_clean(iSeg).info('derivFlags')       = segmentFlags(iSeg,:);

    %% --- STEP 3: Event‑by‑event artefact flags (FO / FC) ---------------
    evs = seg_clean(iSeg).eventProcess.find('func', @(x) ismember(x.name.name, stepEventNames), 'policy','all');
    if iscell(evs), evs = [evs{:}]; end

        % Build once per segment
    trialInfo = seg_clean(iSeg).info('trial');
    keySuffix = sprintf('%s_%d_%s', trialInfo.patient(end-2:end), trialInfo.nTrial, trialInfo.medication);
    lblStruct = seg_clean(iSeg).sampledProcess.labels;
    chanNames = cellfun(@(L)L.name, num2cell(lblStruct),'UniformOutput',false);


    evInfoSeg = struct('eventTime', {}, 'eventName', {}, 'eventArtifactFlags', {});

    for ev = 1:numel(evs)
        numEventsChecked = numEventsChecked + 1;
        evT   = evs(ev).tStart;
        idxWin= timeVec >= evT + eventWindowSec(1) & timeVec <= evT + eventWindowSec(2);
        tSeg = timeVec(idxWin) - evT;

        if ~any(idxWin), continue; end
        evFlags = any(perChanMask(idxWin,:), 1);   % 1×nCh logical
        evName = evs(ev).name.name;                     
        evInfoSeg(ev).eventTime          = evT;
        evInfoSeg(ev).eventName          = evName;
        evInfoSeg(ev).eventArtifactFlags = evFlags;

        patientTag = trialInfo.patient(end-2:end);                   % e.g. 'ABC'
        patientDir = fullfile(Deriv_Dir, patientTag);                % DerivDir/ABC
        MAGIC.batch.EnsureDir(patientDir);                           

        % usable counts (≥1 clean channel)
        if ~all(evFlags)
            switch evs(ev).name.name
                case 'FO'
                    usableFO = usableFO + 1; FOcounts(end+1) = nnz(~evFlags);
                case 'FC'
                    usableFC = usableFC + 1; FCcounts(end+1) = nnz(~evFlags);
            end
        end

    % Plot (optional): loop over channels, unique figName
        if todo.plot
            for ch = 1:nCh
                % DEBUG PART: unique filename for each event & channel
                figName = sprintf('%s_%s_ch%d_trial%d', evName, patientTag, ch, trialInfo.nTrial);

                fig = figure('Visible', plotVisible, 'Color', 'w');
                tiledlayout(3,1,'TileSpacing','compact','Padding','compact');

                % ── 1st tile: raw data with artefact patches ───────────────
                nexttile;
                rawCh = raw(idxWin, ch);
                plot(tSeg, rawCh, 'LineWidth',1);
                hold on;
                    maskCh = perChanMask(idxWin, ch);
                    dMask  = diff([0; maskCh; 0]);
                    starts = find(dMask==1);
                    ends   = find(dMask==-1)-1;
                    yl     = ylim;
                    for iF = 1:numel(starts)
                        x1 = tSeg(starts(iF)); x2 = tSeg(ends(iF));
                        patch([x1 x2 x2 x1], [yl(1) yl(1) yl(2) yl(2)], 'r', 'FaceAlpha',.15, 'EdgeColor','none');
                    end
                hold off;
                xlabel('Time (s)'); ylabel('\muV');
                title([evName ' raw – ' chanNames{ch}]);

                % ── 2nd tile: instantaneous slope with ±MAD threshold ───────
                nexttile;
                centralDiff   = deriv(idxWin, ch);
                dMed          = median(centralDiff);
                dMad          = mad(centralDiff,1);
                thresholdHigh = dMed + derivFactor * dMad;
                thresholdLow  = dMed - derivFactor * dMad;
                plot(tSeg, centralDiff, 'LineWidth',1);
                hold on; yline(thresholdHigh,'--','LineWidth',.8); yline(thresholdLow,'--','LineWidth',.8);
                hold off;
                xlabel('Time (s)'); ylabel('\muV/s');
                title(sprintf('%s: slope ±%.1f×MAD – %s', evName, derivFactor, chanNames{ch}));

                % ── 3rd tile: cleaned signal after interpolation ────────────
                nexttile;
                cleanCh = CleanedData(idxWin, ch);
                plot(tSeg, cleanCh, 'LineWidth',1);
                xlabel('Time (s)'); ylabel('\muV');
                title(sprintf('%s: cleaned – %s', evName, chanNames{ch}));

                % save figure
                saveas(fig, fullfile(patientDir, [figName, '.png']));
                close(fig);
            end
        end
        if todo.plot_surrogate && strcmp(evName,'FO')
            % snippet for channel-1 FO
            s_real = raw(idxWin,1);          % real  µV snippet

             % generate a perfect-power surrogate *of that snippet itself*
             s_sur = FT_surrogate(s_real);    % now both share identical |FFT| bins
    
            % actual window length (number of samples in the FO window)
             winLen = numel(s_real);
        
%             % choose FFT length = next pow2 of snippet length, but no larger than snippet
%             nfft = 2^nextpow2(winLen);
%             if nfft > winLen
%                 nfft = winLen;
%             end
%         
%             % construct taper window of length nfft
%             win = hamming(nfft);

            
           
%             % compute PSDs (Welch) with default 50% overlap
%             [P_real, f] = pwelch( s_real, win, [], nfft, Fs );
%             [P_sur ,    ] = pwelch( s_sur , win, [], nfft, Fs );
%         
%             % convert to dB/Hz
%             P_real_dB = 10*log10(P_real);
%             P_sur_dB  = 10*log10(P_sur);

                % —– compute **exact** periodogram PSDs (no windowing/overlap):
            nfft = winLen;   % use full window length
            [P_real, f] = periodogram(s_real, [], nfft, Fs);
            [P_sur ,    ] = periodogram(s_sur , [], nfft, Fs);
        
            % convert to dB/Hz
            P_real_dB = 10*log10(P_real);
            P_sur_dB  = 10*log10(P_sur);
    
            % produce 2-row figure: waveform above, PSD below
        figure('Visible',plotVisible,'Color','w');
    
        % ── Time-domain plot ───────────────────────────────────────────────
        subplot(2,1,1);
        plot(tSeg, s_real, 'b','LineWidth',1.2); hold on;
        plot(tSeg, s_sur , 'g','LineWidth',1.2);
        xlabel('Time (s)');
        ylabel('Amplitude (\muV)');
        title('Raw LFP from Foot Contact Event vs Surrogate LFP (time domain)');
        legend('Raw LFP','Surrogate LFP');
        box off; hold off;
    
        % ── PSD plot (0–100 Hz, display 0–10 dB) ───────────────────────────
        subplot(2,1,2);
        plot(f, P_real_dB, 'b','LineWidth',1.2); hold on;
        plot(f, P_sur_dB , 'g','LineWidth',1.2);
        xlabel('Frequency (Hz)');
        ylabel('Power (dB)');       % display-only label
        title('Raw LFP from Foot Contact Event vs Surrogate LFP (PSD)');
        legend('Raw LFP','Surrogate LFP');
        box off;
        xlim([0 100]);                   % restrict to 0–100 Hz
        %ylim([0 10]);                    % display range 0–10 dB
        hold off;
    
        % save and close as before
        saveas(gcf, fullfile(Deriv_Dir, sprintf('Surrogate_FC_ev%02d.png',ev)));
        close(gcf);

        figure('Visible',plotVisible,'Color','w');
        scatter(P_real_dB, P_sur_dB, 12, 'filled'); hold on;
        % unity line
        mn = min([P_real_dB; P_sur_dB]);  
        mx = max([P_real_dB; P_sur_dB]);
        plot([mn mx],[mn mx],'k--','LineWidth',1);
        legend({'Surrogate vs. Raw PSD bins','Unity line (y = x)'}, ...
       'Location','best');
        xlabel('Real PSD (dB)'); ylabel('Surrogate PSD (dB)');
        title('PSD Overlap: Raw vs Surrogate');
        axis equal; box off; grid on;
        saveas(gcf, fullfile(Deriv_Dir, sprintf('Surrogate_FC_ev%02d_scatter.png',ev)));
        close(gcf);

        end

    end
    
    seg_clean(iSeg).info('derivEventInfo') = evInfoSeg;
    if ~isempty(evInfoSeg)
        allEventFlags = [allEventFlags; vertcat(evInfoSeg.eventArtifactFlags)]; %#ok<AGROW>
    end
end % segment loop

seg_clean = seg_clean;  % primary output

%% ---------- Compile statistics ----------------------------------------
stats                         = struct();
stats.totalSegments           = nSeg;
stats.rejectedSegmentsCountPerChannel  = sum(segmentFlags,1);
stats.percentageSegmentsRejectedPerChannel = stats.rejectedSegmentsCountPerChannel / nSeg * 100;

stats.numEventsChecked        = numEventsChecked;
if ~isempty(allEventFlags)
    stats.eventRejectedCountPerChannel   = sum(allEventFlags,1);
    stats.eventRejectedPercentPerChannel = stats.eventRejectedCountPerChannel / size(allEventFlags,1) * 100;
else
    stats.eventRejectedCountPerChannel   = zeros(1,nCh);
    stats.eventRejectedPercentPerChannel = zeros(1,nCh);
end

stats.usableEvents.FO = usableFO;
stats.usableEvents.FC = usableFC;
if ~isempty(FOcounts)
    stats.OKchannelsPerFO = struct('min', min(FOcounts), 'mean', mean(FOcounts), 'max', max(FOcounts));
else
    stats.OKchannelsPerFO = struct('min', NaN, 'mean', NaN, 'max', NaN);
end
if ~isempty(FCcounts)
    stats.OKchannelsPerFC = struct( ...
        'min',  min(FCcounts), ...
        'mean', mean(FCcounts), ...
        'max',  max(FCcounts)  ...
    );
else
    stats.OKchannelsPerFC = struct( ...
        'min',  NaN, ...
        'mean', NaN, ...
        'max',  NaN  ...
    );
end

%% Helper Function
   %% ─── Perfect‐power Fourier Surrogate ───────────────────────────────────
function s_sur = FT_surrogate(s)
    N = numel(s);
    S = fft(s);   % original complex spectrum

    % Identify positive‐frequency bins (excluding DC at 1 and Nyquist if even N)
    if mod(N,2)==0
        posBins = 2 : (N/2);        % for even N, bins 2…N/2 are positive
        nyqBin  = N/2 + 1;          % Nyquist
    else
        posBins = 2 : (N+1)/2;      % for odd N, bins 2…(N+1)/2 are positive
        nyqBin  = [];               % no single Nyquist bin
    end

    % corresponding negative‐frequency bins
    negBins = N - posBins + 2;

    % generate one random phase per positive bin
    phases = exp(1i * 2*pi * rand(numel(posBins),1));

    % apply phase shuffling **in place** (preserves |S|)
    S(posBins) = S(posBins) .* phases;
    S(negBins) = S(negBins) .* conj(phases);

    % leave S(1) (DC) and S(nyqBin) untouched

    % invert back to time domain (will be purely real)
    s_sur = real(ifft(S));
end

end