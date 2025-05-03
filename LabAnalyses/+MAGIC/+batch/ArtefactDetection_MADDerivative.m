function [seg_clean, stats] = ArtefactDetection_MADDerivative( ...
            seg_clean, method, doPlot, doSurrogate)
% ArtefactDetection_MADDerivative  – segment‑level artefact removal
% -------------------------------------------------------------------------
%   Cleans each LFP segment with one of three derivative‑based MAD rules
%   and (optionally) produces *independent* Fourier‑surrogate comparisons.
%
%   ── Derivative choices ────────────────────────────────────────────────
%       'simple'  : forward difference  (x[n+1]‑x[n])
%       'central' : 3‑point central difference, detrended
%       'ramp'    : forward difference but keeps only **runs** ≥ minDur ms
%                   where |deriv| > rampFactor × MAD  ➜ removes fast ramp‑ups
%
%   ── Usage ─────────────────────────────────────────────────────────────
%       [seg_clean,stats] = ArtefactDetection_MADDerivative(seg);
%       [seg_clean,stats] = ArtefactDetection_MADDerivative( ...
%                               seg,'ramp',true,true);
%
%   INPUTS
%       seg_clean   – struct array from previous pipeline step
%       method      – 'simple' | 'central' | 'ramp'  (default 'central')
%       doPlot      – produce diagnostic PNGs?        (default false)
%       doSurrogate – add surrogate comparison PNGs?  (default false)
%
%   OUTPUTS
%       seg_clean   – same struct, artefacts interpolated / zero‑filled
%       stats       – per‑channel rejection counts / percentages
% -------------------------------------------------------------------------

%% ===== USER‑TUNABLE CONSTANTS ==========================================
derivFactor   = 1.5;   % k × MAD for simple & central
rampFactor    = 2.5;   % k × MAD for ramp detection
minDurMs      = 15;    % minimum ramp length (ms)
growMs        = 10;    % dilate mask for simple & central (ms each side)
smoothWinFrac = 0.10;  % detrend window (× Fs) for central derivative
maxPsdHz      = 100;   % x‑axis limit on surrogate PSD plot

%% ===== ARGUMENT PARSING ===============================================
if nargin < 2 || isempty(method),      method      = 'central'; end
if nargin < 3 || isempty(doPlot),      doPlot      = false;    end
if nargin < 4 || isempty(doSurrogate), doSurrogate = false;    end
method = validatestring(lower(method), {'simple','central','ramp'});
plotVisible = 'off';          % figures drawn off‑screen

%% ===== OUTPUT ROOT FOLDERS ============================================
if doPlot || doSurrogate
    global Deriv_Dir
    if isempty(Deriv_Dir), Deriv_Dir = fullfile(pwd,'DerivPlots'); end
    if ~exist(Deriv_Dir,'dir'), mkdir(Deriv_Dir); end
end

%% ===== INITIALISE STATS ===============================================
nSeg     = numel(seg_clean);
[~, nCh] = size(seg_clean(1).sampledProcess.values{1});
segmentFlags = false(nSeg,nCh);

%% ===== MAIN LOOP =======================================================
for iSeg = 1:nSeg
    sp        = seg_clean(iSeg).sampledProcess;
    raw       = sp.values{1};            % [samples × channels]
    Fs        = sp.Fs;
    t         = sp.times{1};
    tRel      = t - t(1);
    info      = seg_clean(iSeg).info('trial');

    %% ---------- DERIVATIVES ------------------------------------------
    deriv_simple        = [diff(raw); NaN(1,nCh)];
    deriv_cent          = zeros(size(raw));
    deriv_cent(1,:)       = raw(2,:) - raw(1,:);
    deriv_cent(2:end-1,:) = (raw(3:end,:) - raw(1:end-2,:))/2;
    deriv_cent(end,:)     = raw(end,:) - raw(end-1,:);
    resid_cent          = deriv_cent - movmean(deriv_cent, ...
                                 round(smoothWinFrac*Fs));

    switch method
        case 'simple'
            compClean = deriv_simple;
            comp_seg  = deriv_simple;
            med_ch    = median(comp_seg,1,'omitnan');
            mad_ch    = median(abs(comp_seg-med_ch),1,'omitnan');

        case 'central'
            compClean = resid_cent;
            comp_seg  = resid_cent;
            med_ch    = median(comp_seg,1);
            mad_ch    = mad(comp_seg,1);

        case 'ramp'
            compClean = deriv_simple;    % fast enough, detrend not needed
            comp_seg  = deriv_simple;
            med_ch    = median(comp_seg,1,'omitnan');
            mad_ch    = median(abs(comp_seg-med_ch),1,'omitnan');
            rampMinSamp = round(minDurMs/1000*Fs);
    end

    %% ---------- ARTEFACT MASK & CLEANING -----------------------------
    mask    = false(size(raw));
    cleaned = raw;

    growN = round(growMs/1000*Fs);   % convert ms to samples

    for ch = 1:nCh
        switch method
            case {'simple','central'}
                bad = abs(compClean(:,ch)-med_ch(ch)) > derivFactor*mad_ch(ch);
                if growN>0
                    bad = conv(double(bad),ones(growN*2+1,1),'same')>0;
                end

            case 'ramp'
                thr   = rampFactor*mad_ch(ch);
                over  = abs(compClean(:,ch)-med_ch(ch)) > thr;
                d     = diff([0;over;0]);
                stRun = find(d==1);  enRun = find(d==-1)-1;
                keep  = false(size(over));
                for k = 1:numel(stRun)
                    if enRun(k)-stRun(k)+1 >= rampMinSamp
                        keep(stRun(k):enRun(k)) = true;
                    end
                end
                bad = keep;
        end

        mask(:,ch)            = bad;
        segmentFlags(iSeg,ch) = any(bad);

        if nnz(~bad) >= 2
            cleaned(:,ch) = interp1(t(~bad), raw(~bad,ch), ...
                                    t,'pchip','extrap');
        else
            cleaned(bad,ch) = 0;   % fallback if whole trace is artefact
        end
    end

    seg_clean(iSeg).sampledProcess.values{1} = cleaned;
    seg_clean(iSeg).info('derivFlags')       = any(mask,1);

    %% ---------- PLOTTING ---------------------------------------------
    if (doPlot || doSurrogate) && strcmpi(info.condition,'step')
        patientTag = info.patient(end-2:end);
        baseDir    = fullfile(Deriv_Dir,patientTag);
        diagDir    = fullfile(baseDir,'segment',  method);
        surDir     = fullfile(baseDir,'surrogate',method);
        if doPlot      && ~exist(diagDir,'dir'), mkdir(diagDir); end
        if doSurrogate && ~exist(surDir,'dir'), mkdir(surDir);  end

        chanNames = cellfun(@(l)l.name,num2cell(sp.labels),'uni',0);
        prefix = sprintf('%s_%s_%d_segment_%s', ...
                 patientTag,info.medication,info.nTrial,method);

        % surrogate derivative helper (only if needed)
        if doSurrogate
            if strcmp(method,'central')
                surrogateDeriv = @(x) ...
                    ([(x(2)-x(1));(x(3:end)-x(1:end-2))/2;(x(end)-x(end-1))]) - ...
                    movmean([(x(2)-x(1));(x(3:end)-x(1:end-2))/2;(x(end)-x(end-1))], ...
                             round(smoothWinFrac*Fs));
            else
                surrogateDeriv = @(x)[diff(x);NaN];
            end
        end

        for ch = 1:nCh
            chanSafe = regexprep(chanNames{ch},'[^\w]','_');
            figName  = sprintf('%s_%s',prefix,chanSafe);

            %% ---- diagnostic PNG (raw / deriv / cleaned) --------------
            if doPlot
                fig = figure('Visible',plotVisible,'Color','w');
                set(fig,'Units','normalized','OuterPosition',[0 0 1 1]);
                tiledlayout(3,1,'Padding','compact','TileSpacing','compact');

                % RAW
                nexttile;
                plot(tRel,raw(:,ch),'LineWidth',1); hold on
                dM = diff([0;mask(:,ch);0]);
                st = find(dM==1);  en = find(dM==-1)-1;
                yl = ylim;
                for k = 1:numel(st)
                    patch([tRel(st(k)) tRel(en(k)) tRel(en(k)) tRel(st(k))], ...
                          [yl(1) yl(1) yl(2) yl(2)], ...
                          'r','FaceAlpha',.30,'EdgeColor','none');
                end
                title(sprintf('%s – raw data',figName),'Interpreter','none');
                xlabel('Time (s)'); ylabel('\muV');

                % DERIVATIVE
                nexttile;
                hComp = plot(tRel,comp_seg(:,ch),'LineWidth',1); hold on
                switch method
                    case {'simple','central'}
                        thr = derivFactor*mad_ch(ch);
                        labelHi = sprintf('Upper +%.1f×MAD',derivFactor);
                        labelLo = sprintf('Lower –%.1f×MAD',derivFactor);
                    case 'ramp'
                        thr = rampFactor*mad_ch(ch);
                        labelHi = sprintf('Upper +%.1f×MAD (≥%d ms run)', ...
                                          rampFactor,minDurMs);
                        labelLo = sprintf('Lower –%.1f×MAD',rampFactor);
                end
                hHi = yline(med_ch(ch)+thr,'--r','LineWidth',1.2);
                hLo = yline(med_ch(ch)-thr,'--r','LineWidth',1.2);
                title(sprintf('%s – %s derivative',figName,method), ...
                      'Interpreter','none');
                xlabel('Time (s)'); ylabel('\muV/s');
                legend([hComp hHi hLo],{'Derivative',labelHi,labelLo}, ...
                       'Location','best');

                % CLEANED
                nexttile;
                plot(tRel,cleaned(:,ch),'LineWidth',1);
                title(sprintf('%s – cleaned',figName),'Interpreter','none');
                xlabel('Time (s)'); ylabel('\muV');

                exportgraphics(fig,fullfile(diagDir,[figName '.png']),'Resolution',150);
                close(fig);
            end

            %% ---- surrogate PNG (time & PSD) --------------------------
            if doSurrogate
                surRaw = FT_surrogate(raw(:,ch));
                surDer = surrogateDeriv(surRaw);
                [P_raw,f] = periodogram(raw(:,ch),[],numel(raw(:,ch)),Fs);
                [P_sur,~] = periodogram(surRaw   ,[],numel(surRaw)   ,Fs);

                figS = figure('Visible',plotVisible,'Color','w');
                set(figS,'Units','normalized','OuterPosition',[0 0 1 1]);
                tiledlayout(2,1,'Padding','compact','TileSpacing','compact');

                % time‑domain
                nexttile;
                plot(tRel,raw(:,ch),'b','LineWidth',1); hold on
                plot(tRel,surRaw   ,'g','LineWidth',1);
                xlabel('Time (s)'); ylabel('\muV');
                title(sprintf('%s – raw vs surrogate (time)',figName), ...
                      'Interpreter','none');
                legend({'Raw','Surrogate'}); box off

                % PSD
                nexttile;
                plot(f,10*log10(P_raw),'b','LineWidth',1); hold on
                plot(f,10*log10(P_sur),'g','LineWidth',1);
                xlabel('Frequency (Hz)'); ylabel('Power (dB)');
                title(sprintf('%s – PSD comparison',figName), ...
                      'Interpreter','none');
                xlim([0 maxPsdHz]); legend({'Raw','Surrogate'}); box off

                exportgraphics(figS,fullfile(surDir,[figName '_surrogate.png']), ...
                               'Resolution',150);
                close(figS);
            end
        end % channel loop
    end     % plotting branch
end         % segment loop

%% ===== SUMMARY STATS ===================================================
stats.totalSegments                       = nSeg;
stats.rejectedSegmentsCountPerChannel     = sum(segmentFlags,1);
stats.percentageSegmentsRejectedPerChannel= ...
    stats.rejectedSegmentsCountPerChannel / nSeg * 100;
end  % main function
% =======================================================================

function s_sur = FT_surrogate(s)
% Perfect‑power Fourier surrogate  (unchanged)
N = numel(s);  S = fft(s);
posBins = 2:floor(N/2);  negBins = N - posBins + 2;
phases  = exp(1i*2*pi*rand(numel(posBins),1));
S(posBins) = S(posBins) .* phases;
S(negBins) = S(negBins) .* conj(phases);
s_sur = real(ifft(S));
end
