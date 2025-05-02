function [seg_clean, stats] = ArtefactDetection_MADDerivative(seg_clean, method, doPlot, doSurrogate)
% ArtefactDetection_MADDerivative
% Performs derivative‐based artefact detection & interpolation using either
% simple forward differences or central differences + residual, with MAD
% thresholding. Optionally plots per‐event diagnostics and surrogate tests.
%
% USAGE
%   [seg_clean, stats] = ArtefactDetection_MADDerivative(seg_clean)
%   [seg_clean, stats] = ArtefactDetection_MADDerivative(seg_clean, method)
%   [seg_clean, stats] = ArtefactDetection_MADDerivative(seg_clean, method, doPlot)
%   [seg_clean, stats] = ArtefactDetection_MADDerivative(seg_clean, method, doPlot, doSurrogate)
%
% INPUTS
%   seg_clean  – array of Segment objects, each with:
%                  .sampledProcess.values{1} ([nSamples×nCh] raw data)
%                  .sampledProcess.times{1}  ([nSamples×1] time vector)
%                  .sampledProcess.Fs        (sampling rate)
%                  .eventProcess             (events array)
%                  .info('trial')            (trial info: patient, nTrial, medication)
%   method     – 'simple' or 'central' (default: 'central')
%   doPlot     – logical: plot per‐event diagnostics for chosen method (default: false)
%   doSurrogate– logical: perform surrogate‐based PSD plotting for FO events (default: false)
%
% OUTPUTS
%   seg_clean  – same array, but with:
%                   .sampledProcess.values{1} updated to cleaned data
%                   .info('derivFlags')       (1×nCh logical per segment)
%                   .info('derivEventInfo')   (struct array per FO/FC event)
%   stats      – struct summarising segment & event rejection counts

%% ===== USER-TUNABLE CONSTANTS ==========================================
derivFactor    = 3;          % threshold = derivFactor × MAD
smoothWinFrac  = 0.1;         % fraction of Fs for movmean window
eventWindowSec = [-1 1];       % window (s) around FO/FC for event flags
stepEventNames = {'FO','FC'};   % event names of interest

%% ===== DEFAULT ARGUMENTS ===============================================
if nargin < 2 || isempty(method),      method      = 'central'; end
if nargin < 3 || isempty(doPlot),      doPlot      = false;     end
if nargin < 4 || isempty(doSurrogate), doSurrogate = false;     end
method = validatestring(lower(method), {'simple','central'});

%% ===== INITIALISATION ==================================================
global Deriv_Dir;
if isempty(Deriv_Dir), Deriv_Dir = fullfile(pwd,'DerivPlots'); end
if ~exist(Deriv_Dir,'dir'), mkdir(Deriv_Dir); end
plotVisible = 'on';

nSeg   = numel(seg_clean);
firstSp= seg_clean(1).sampledProcess;
[~, nCh] = size(firstSp.values{1});

segmentFlags  = false(nSeg, nCh);   % whole-segment flags
allEventFlags = [];                 % accumulate across segments
usableFO = 0; usableFC = 0;
FOcounts = []; FCcounts = [];
numEventsChecked = 0;

%% ===== MAIN LOOP OVER SEGMENTS ========================================
for iSeg = 1:nSeg
    sp      = seg_clean(iSeg).sampledProcess;
    raw     = sp.values{1};        % [samples × channels]
    Fs      = sp.Fs;
    timeVec = sp.times{1};
    nSamples= size(raw,1);

    % Prepare cleaned data container
    CleanedData = raw;
    perChanMask = false(nSamples, nCh);

    %% --- CLEANING: choose derivative method --------------------------
    switch method
        case 'simple'
            % forward difference, pad with zeros at end
            deriv_s = [diff(raw); NaN(1,nCh)];
            for ch = 1:nCh
                d_all   = deriv_s(:,ch);
                m       = median(d_all,         'omitnan');      % robust location
                mad_val = median(abs(d_all - m),'omitnan');      % median absolute deviation
                bad = abs(deriv_s(:,ch) - m) > derivFactor * mad_val;
                perChanMask(:,ch) = bad;
                segmentFlags(iSeg,ch) = any(bad);
                good = ~bad;
                if nnz(good) >= 2 % number of non zero
                    CleanedData(:,ch) = interp1(...
                        timeVec(good), CleanedData(good,ch), timeVec,...
                        'pchip','extrap');
                end
            end

        case 'central'
            % 3-point central diff + residual
            deriv            = zeros(size(raw));
            deriv(1,:)       = raw(2,:) - raw(1,:);
            deriv(2:end-1,:) = (raw(3:end,:) - raw(1:end-2,:)) / 2;
            deriv(end,:)     = raw(end,:) - raw(end-1,:);
            window           = round(smoothWinFrac * Fs);
            smooth_deriv     = movmean(deriv, window);
            residual         = deriv - smooth_deriv;
            for ch = 1:nCh
                m   = median(residual(:,ch));
                mad_val  = mad(residual(:,ch),1);
                bad = abs(residual(:,ch) - m) > derivFactor * mad_val;
                perChanMask(:,ch)   = bad;
                segmentFlags(iSeg,ch)= any(bad);
                good = ~bad;
                if nnz(good) >= 2
                    CleanedData(:,ch) = interp1(...
                        timeVec(good), CleanedData(good,ch), timeVec,...
                        'pchip','extrap');
                end
            end
    end

    % Save cleaned data & segment‐level flags
    seg_clean(iSeg).sampledProcess.values{1} = CleanedData;
    seg_clean(iSeg).info('derivFlags')       = any(perChanMask,1);

    %% --- EVENT‐LEVEL ARTEFACT FLAGGING & PLOTTING --------------------
    evs = seg_clean(iSeg).eventProcess.find( ...
        'func', @(x) ismember(x.name.name, stepEventNames), ...
        'policy','all');
    if iscell(evs), evs = [evs{:}]; end

    trialInfo = seg_clean(iSeg).info('trial');
    patientTag = (trialInfo.patient(end-2:end));   % e.g. 'FRJ'

    patientDir = fullfile(Deriv_Dir, patientTag);
    if ~exist(patientDir,'dir'), mkdir(patientDir); end

    chanNames = cellfun(@(L)L.name, num2cell(seg_clean(iSeg).sampledProcess.labels), ...
                        'UniformOutput',false);

    evInfoSeg = struct('eventTime',{},'eventName',{},'eventArtifactFlags',{});
    % Only process segments where condition begins with 'step'
    if ~startsWith(trialInfo.condition, 'step') || ~strcmpi(trialInfo.medication, 'ON')
        continue;
    end
    for ev = 1:numel(evs)
        numEventsChecked = numEventsChecked + 1;
        evT   = evs(ev).tStart;
        idxWin= timeVec >= evT+eventWindowSec(1) & timeVec <= evT+eventWindowSec(2);
        if ~any(idxWin), continue; end
        tSeg    = timeVec(idxWin) - evT;
        evFlags = any(perChanMask(idxWin,:),1);
        evName  = evs(ev).name.name;

        % Store event info
        evInfoSeg(ev).eventTime          = evT;
        evInfoSeg(ev).eventName          = evName;
        evInfoSeg(ev).eventArtifactFlags = evFlags;

        % Count usable events
        if ~all(evFlags)
            switch evName
                case 'FO'
                    usableFO = usableFO + 1; FOcounts(end+1) = nnz(~evFlags);
                case 'FC'
                    usableFC = usableFC + 1; FCcounts(end+1) = nnz(~evFlags);
            end
        end

   %% --- EVENT‐LEVEL ARTEFACT FLAGGING & PLOTTING --------------------
    evs = seg_clean(iSeg).eventProcess.find( ...
        'func', @(x) ismember(x.name.name, stepEventNames), ...
        'policy','all');
    if iscell(evs), evs = [evs{:}]; end

    trialInfo = seg_clean(iSeg).info('trial');
    patientTag = trialInfo.patient(end-2:end);
    medication = trialInfo.medication;
    nTrial     = trialInfo.nTrial;
    prefix     = sprintf('%s_%s_%d', patientTag, medication, nTrial);
    patientDir = fullfile(Deriv_Dir, patientTag);
    if ~exist(patientDir,'dir'), mkdir(patientDir); end

    if doPlot && ~isempty(evs)
        % 1) Precompute channel stats once per segment
        switch method
          case 'simple'
            m_ch   = median(   deriv_s,        1, 'omitnan');
            mad_ch = median(abs(deriv_s - m_ch), 1, 'omitnan');
            comp   = deriv_s;
          case 'central'
            m_ch   = median(residual,    1);
            mad_ch = mad(     residual, 1);
            comp   = residual;
        end

        % 2) Loop over events
        for evIdx = 1:numel(evs)
            evT    = evs(evIdx).tStart;
            evName = evs(evIdx).name.name;
            idxWin = timeVec >= evT+eventWindowSec(1) & timeVec <= evT+eventWindowSec(2);
            if ~any(idxWin), continue; end
            tSeg   = timeVec(idxWin) - evT;
            
            % 3) Loop over channels
            for ch = 1:nCh
                % channel data
                rawCh   = raw(idxWin,   ch);
                cleanCh = CleanedData(idxWin,ch);
                maskCh  = perChanMask(idxWin,ch);
                compCh  = comp(idxWin,ch);
                hi      = m_ch(ch) + derivFactor * mad_ch(ch);
                lo      = m_ch(ch) - derivFactor * mad_ch(ch);

                % assemble figName
                chanSafe = regexprep(chanNames{ch}, '[^\w]', '_');
                figName  = sprintf('%s_%s_step%02d_%s_%s', ...
                             prefix, evName, trialInfo.nStep, method, chanSafe);

                % create fullscreen figure
                fig = figure('Visible',plotVisible,'Color','w');
                set(fig,'Units','normalized','OuterPosition',[0 0 1 1]);
                tiledlayout(3,1,'TileSpacing','compact','Padding','compact');

                % a) Raw + patches
                nexttile;
                plot(tSeg, rawCh, 'LineWidth',1); hold on;
                dMask  = diff([0; maskCh; 0]);
                starts = find(dMask==1); ends = find(dMask==-1)-1;
                yl     = ylim;
                for iF = 1:numel(starts)
                    patch([tSeg(starts(iF)) tSeg(ends(iF)) tSeg(ends(iF)) tSeg(starts(iF))], ...
                          [yl(1) yl(1) yl(2) yl(2)], 'r', 'FaceAlpha',.15, 'EdgeColor','none');
                end
                hold off;
                xlabel('Time (s)'); ylabel('\muV');
                title(sprintf('%s – raw data', figName), 'Interpreter','none');

                % b) Derivative/Residual + ±MAD lines
                nexttile;
                hComp = plot(tSeg, compCh, 'LineWidth',1.5); hold on;
                hHi   = yline(hi, '--','LineWidth',1.5,'Color','r');
                hLo   = yline(lo, '--','LineWidth',1.5,'Color','r');
                hold off;
                xlabel('Time (s)'); ylabel('\muV/s');
                title(sprintf('%s – %s (%+.2f×MAD)', figName, method, derivFactor), ...
                      'Interpreter','none');
                legend([hComp,hHi,hLo], {'Signal', ...
                       sprintf('Upper %.2f×MAD', derivFactor), ...
                       sprintf('Lower %.2f×MAD', derivFactor)}, ...
                       'Location','best');

                % c) Cleaned
                nexttile;
                plot(tSeg, cleanCh, 'LineWidth',1);
                xlabel('Time (s)'); ylabel('\muV');
                title(sprintf('%s – cleaned', figName), 'Interpreter','none');

                % save + close
                saveas(fig, fullfile(patientDir, [figName,'.png']));
                close(fig);
            end  % ch
        end      % evIdx
    end          % doPlot

        %% –– Surrogate analysis for FC events
        if doSurrogate && strcmp(evName,'FC')
            % real snippet
            s_real = raw(idxWin,1);
            s_sur  = FT_surrogate(s_real);
            winLen = numel(s_real);

            % periodograms
            nfft = winLen;
            [P_real, f] = periodogram(s_real, [], nfft, Fs);
            [P_sur ,    ] = periodogram(s_sur , [], nfft, Fs);
            P_real_dB = 10*log10(P_real);
            P_sur_dB  = 10*log10(P_sur);

            % time-domain & PSD figure
            fig = figure('Visible',plotVisible,'Color','w');
            subplot(2,1,1);
            plot(tSeg,s_real,'b','LineWidth',1.2); hold on;
            plot(tSeg,s_sur,'g','LineWidth',1.2);
            xlabel('Time (s)'); ylabel('\muV');
            title('Raw vs Surrogate LFP (time domain)');
            legend('Raw','Surrogate'); box off; hold off;

            subplot(2,1,2);
            plot(f,P_real_dB,'b','LineWidth',1.2); hold on;
            plot(f,P_sur_dB,'g','LineWidth',1.2);
            xlabel('Freq (Hz)'); ylabel('Power (dB)');
            title('Raw vs Surrogate PSD'); legend('Raw','Surrogate');
            xlim([0 100]); box off; hold off;

            saveas(fig, fullfile(Deriv_Dir, ...
                sprintf('Surrogate_%s_ev%02d.png', evName, ev)));
            close(fig);

            % scatter PSD bins
            fig = figure('Visible',plotVisible,'Color','w');
            scatter(P_real_dB, P_sur_dB, 12,'filled'); hold on;
            mn = min([P_real_dB; P_sur_dB]); mx = max([P_real_dB; P_sur_dB]);
            plot([mn mx],[mn mx],'k--','LineWidth',1);
            xlabel('Real PSD (dB)'); ylabel('Surrogate PSD (dB)');
            title('PSD Overlap: Raw vs Surrogate'); axis equal; box off; grid on;
            saveas(fig, fullfile(Deriv_Dir, ...
                sprintf('Surrogate_%s_scatter_ev%02d.png', evName, ev)));
            close(fig);
        end

    end  % for evs

    seg_clean(iSeg).info('derivEventInfo') = evInfoSeg;
    if ~isempty(evInfoSeg)
        allEventFlags = [allEventFlags; vertcat(evInfoSeg.eventArtifactFlags)]; %#ok<AGROW>
    end

end  % for segments

%% ===== COMPILE STATISTICS =============================================
stats = struct();
stats.totalSegments          = nSeg;
stats.rejectedSegmentsCountPerChannel   = sum(segmentFlags,1);
stats.percentageSegmentsRejectedPerChannel = stats.rejectedSegmentsCountPerChannel / nSeg * 100;
stats.numEventsChecked       = numEventsChecked;
if ~isempty(allEventFlags)
    stats.eventRejectedCountPerChannel   = sum(allEventFlags,1);
    stats.eventRejectedPercentPerChannel = stats.eventRejectedCountPerChannel / size(allEventFlags,1) * 100;
else
    stats.eventRejectedCountPerChannel   = zeros(1,nCh);
    stats.eventRejectedPercentPerChannel = zeros(1,nCh);
end
stats.usableEvents.FO        = usableFO;
stats.usableEvents.FC        = usableFC;
stats.OKchannelsPerFO = struct('min',min(FOcounts),'mean',mean(FOcounts),'max',max(FOcounts));
stats.OKchannelsPerFC = struct('min',min(FCcounts),'mean',mean(FCcounts),'max',max(FCcounts));

end  % function

%% ─── Helper: Perfect‐power Fourier Surrogate ───────────────────────────
function s_sur = FT_surrogate(s)
    N = numel(s);
    S = fft(s);
    if mod(N,2)==0
        posBins = 2:(N/2);
        nyqBin  = N/2+1;
    else
        posBins = 2:((N+1)/2);
        nyqBin  = [];
    end
    negBins = N - posBins + 2;
    phases = exp(1i*2*pi*rand(numel(posBins),1));
    S(posBins)   = S(posBins) .* phases;
    S(negBins)   = S(negBins) .* conj(phases);
    s_sur = real(ifft(S));
end
