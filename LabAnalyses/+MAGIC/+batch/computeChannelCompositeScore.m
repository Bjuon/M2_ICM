% NEW (overwrite)  ➜  +MAGIC/+batch/computeChannelCompositeScore.m
function [score, rejected, stats] = computeChannelCompositeScore(segEvt, tfEvt, evName)
% computeChannelCompositeScore  – channel‑wise QC flag (v3 + stats)
%
%   [score, rejected, stats] = …(segEvt, tfEvt, evName)
%
%   Only segments whose  trial.info.condition  equals  'step'  are evaluated.
%   All others return NaNs and are ignored by downstream code.
%
%   ---- composite score -----------------------------------------------
%      c1 = ( max|LFP| − 25 µV ) / 100
%      c2 = ( max|abs(resid − MAD)| − 2 µV ) / 4
%      c3 = ( β‑band⟨12–35 Hz⟩ power[dB] − 5 ) / 5
%   ---- reject when c1+c2+c3 > 1  --------------------------------------
%   stats struct  ▸  meanScore, minScore, maxScore, pctFlagged, …



%% ─── parameters ────────────────────────────────────────────────────────
winSec    = 0.5;            % window around event  (± 0.5 s)
winsmooth = 0.10;           % smoothing for baseline of residual (s)
betaBand  = [12 35];        % Hz

%% ─── locate event onset ────────────────────────────────────────────────
ev = segEvt.eventProcess.find('func', ...
       @(x) strcmp(x.name.name,evName),'policy','first');
if isempty(ev)
    error('Event "%s" not found in this Segment.', evName);
end
t0 = ev.tStart;

%% ─── grab LFP window ---------------------------------------------------
sp     = segEvt.sampledProcess;
Fs     = sp.Fs;
tVec   = sp.times{1};
idxWin = tVec >= t0-winSec & tVec <= t0+winSec;
xWin   = sp.values{1}(idxWin,:);                  % samples × nCh

%% ─── 1️⃣  peak amplitude (µV) -----------------------------------------
c1 = (max(abs(xWin),[],1) - 25) ./ 100;
c1(c1 < 0) = 0;

%% ─── 2️⃣  central‑diff residual vs MAD ---------------------------------
deriv       = diff([xWin(1,:); xWin; xWin(end,:)],2,1)/2;     % centred diff
deriv       = deriv(2:end-1,:);
kSmooth     = max(1,round(winsmooth*Fs));
baseline    = movmean(deriv,kSmooth,1,'omitnan');
resid       = deriv - baseline;
mad_res     = mad(resid,1,1);                                 % 1×nCh

diffFromMad = abs(resid - mad_res);                           % NEW rule
c2          = (max(diffFromMad,[],1) - 2) ./ 4;
c2(c2 < 0)  = 0;

%% ─── 3️⃣  β‑band power excess (dB) -------------------------------------
tfProc  = tfEvt.spectralProcess;
tTF     = tfProc.times{1} + tfProc.tBlock/2;
idxT    = tTF >= t0-winSec & tTF <= t0+winSec;
idxF    = tfProc.f >= betaBand(1) & tfProc.f <= betaBand(2);
powDB   = real(tfProc.values{1}(idxT,idxF,:));                % time×freq×ch
betaDB  = squeeze(mean(powDB,[1 2],'omitnan'))';
c3      = (betaDB - 5) ./ 5;
c3(c3 < 0) = 0;

%% ─── composite & flags --------------------------------------------------
score    = c1 + c2 + c3;
rejected = (score > 1) | isnan(score);
%% ─── stats struct -------------------------------------------------------
patientStr = string(segEvt.info('trial').patient);     % string scalar
eventStr   = string(evName);                           % string scalar

nTrialVal  = segEvt.info('trial').nTrial;
if isempty(nTrialVal), nTrialVal = NaN; end            % numeric scalar

nStepVal   = segEvt.info('trial').nStep;
if isempty(nStepVal),  nStepVal  = NaN; end            % numeric scalar

stats = struct( ...
    'patient',    patientStr, ...
    'event',      eventStr,   ...
    'nTrial',     nTrialVal, ...
    'nStep',      nStepVal,  ...
    'meanScore',  mean(score,'omitnan'), ...
    'minScore',   min(score,[],'omitnan'), ...
    'maxScore',   max(score,[],'omitnan'), ...
    'pctFlagged', 100*sum(rejected)/numel(rejected), ...
    'nbChannels', numel(rejected) );

%% ─── write back into Segment metadata (Map‑safe) ───────────────────────
segEvt.info('wrongChannels')     = rejected;   % new keys
segEvt.info('channelScoreStats') = stats;

tfEvt.info('wrongChannels')      = rejected;         
tfEvt.info('channelScoreStats')  = stats;
end