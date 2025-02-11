%matfile = '281013_2_CLAIVEZ_OFF.mat';
function [data] = msupTrialInfo(matfile)

%% Load the topsData
log = topsDataLog.theDataLog;
log.flushAllData();
log.readDataFile(matfile);
if log.length == 0
   error('Trouble reading TOPS data log');
end
%cellfun(@(x) disp(x),log.groups)

trialInfo = log.getAllItemsFromGroupAsStruct('trialInfo');

% Trial start and finish
start = log.getAllItemsFromGroupAsStruct('traverse states:start');
ind = cellfun(@(x) isfield(x,'fevalName'),{start.item});
tStart = [start(ind).mnemonic];

finish = log.getAllItemsFromGroupAsStruct('traverse states:finish');
ind = cellfun(@(x) isfield(x,'fevalName'),{finish.item});
tFinish = [finish(ind).mnemonic];

% Fix on is the first state after start state, corresponds to the state
% just following the sync trigger
fix = log.getAllItemsFromGroupAsStruct('traverse states:enter:fix acquire');
tFixOn = [fix.mnemonic];
% fixAcquire corresponds to subject touch, which exits fix acquire
fix = log.getAllItemsFromGroupAsStruct('traverse states:exit:fix acquire');
tFixAcquire = [fix.mnemonic];
% targetOn
target = log.getAllItemsFromGroupAsStruct('traverse states:enter:overlap');
tTargetOn = [target.mnemonic];
% cueOn
cue = log.getAllItemsFromGroupAsStruct('traverse states:enter:cue2');
tCueOn = [cue.mnemonic];
% cueOff, subject leave fix window, this is also fixOff
cue = log.getAllItemsFromGroupAsStruct('traverse states:exit:cue2');
tCueOff = [cue.mnemonic];
% tarAcquireEnter, subject enters state checking target entry
tar = log.getAllItemsFromGroupAsStruct('traverse states:enter:tar acquire');
tTarAcquire1 = [tar.mnemonic];
% tarAcquireExit, subject hits target window
tar = log.getAllItemsFromGroupAsStruct('traverse states:exit:tar acquire');
tTarAcquire2 = [tar.mnemonic];
% tarHoldExit, subject  target window
tar = log.getAllItemsFromGroupAsStruct('traverse states:exit:target hold');
tTarHold = [tar.mnemonic];

% stopOff, subject leaves hold (stop) or hold (stop) finishes
stop = log.getAllItemsFromGroupAsStruct('traverse states:exit:stop hold');
tStopHoldOff = [stop.mnemonic];

success = log.getAllItemsFromGroupAsStruct('traverse states:enter:success');
tSuccessEnter = [success.mnemonic];
success = log.getAllItemsFromGroupAsStruct('traverse states:exit:success');
tSuccessExit = [success.mnemonic];
success2 = log.getAllItemsFromGroupAsStruct('traverse states:enter:success2');
tSuccess2Enter = [success2.mnemonic];
success2 = log.getAllItemsFromGroupAsStruct('traverse states:exit:success2');
tSuccess2Exit = [success2.mnemonic];
failure = log.getAllItemsFromGroupAsStruct('traverse states:enter:failure');
tFailure = [failure.mnemonic];
abort = log.getAllItemsFromGroupAsStruct('traverse states:enter:abort');
tAbort = [abort.mnemonic];

% parse timing into struct array with trial information
% Note that trialInfo gets logged after the tFinish because it occurs for
% the during the finish state.

% labels for events, which are handle compatible, so we create one instance
% for each kind of event
fixationLabel = metadata.Label('name','fixation');
targetLabel = metadata.Label('name','target');
feedbackLabel = metadata.Label('name','feedback');
cueLabel = metadata.Label('name','cue');
fixTouchLabel = metadata.Label('name','fixTouch');
tarTouchLabel = metadata.Label('name','tarTouch');


for i = 1:numel(trialInfo)
   meta_trial(i) = metadata.trial.Msup(trialInfo(i).item);
   if isempty(meta_trial(i).stopTrial)
      meta_trial(i).stopTrial = false;
   end
   % Recall that there can be multiple fixOnsets for a given 'trial' if the
   % subject leaves fix before cue.
   ind = (tFixOn > tStart(i)) & (tFixOn < tFinish(i));
   tOn = tFixOn(ind);
   
   shift = tOn(1); % Beginning of trial (start of Fix)
   meta_trial(i).start =  trialInfo(i).mnemonic - shift;
   meta_trial(i).startStateTime = tStart(i) - shift;
   meta_trial(i).finishStateTime = tFinish(i) - shift;
   meta_trial(i).triggerTime = shift;
   %% Fix point
   tOn = tOn - shift;   
   if meta_trial(i).stopTrial
      meta_trial(i).isSuccess = true;
      meta_trial(i).isFailure = false;
      meta_trial(i).isAbort = false;
      try
         if meta_trial(i).isCorrect
            ind = (tSuccess2Exit > tStart(i)) & (tSuccess2Exit < tFinish(i));
            tOff = tSuccess2Exit(ind) - shift;
         else
            ind = (tStopHoldOff > tStart(i)) & (tStopHoldOff < tFinish(i));
            tOff = tStopHoldOff(ind) - shift;
         end
      catch
         tOff = NaN;
      end
   else
      if numel(tOn) >= 1
         % if success
         ind = (tSuccessEnter > tStart(i)) & (tSuccessEnter < tFinish(i));
         if sum(ind) == 1
            tOff = tCueOff((tCueOff > tStart(i)) & (tCueOff < tFinish(i))) - shift;
            meta_trial(i).isSuccess = true;
            meta_trial(i).isFailure = false;
            meta_trial(i).isAbort = false;
         elseif sum(ind) > 1
            error('should not happen');
         else
            % else failure or abort, in which case all stim off here
            indF = (tFailure > tStart(i)) & (tFailure < tFinish(i));
            indA = (tAbort > tStart(i)) & (tAbort < tFinish(i));
            if sum(indF) == 1
               tOff = tFailure(indF) - shift;
               meta_trial(i).isSuccess = false;
               meta_trial(i).isFailure = true;
               meta_trial(i).isAbort = false;
            elseif sum(indA) == 1
               tOff = tAbort(indF) - shift;
               meta_trial(i).isSuccess = false;
               meta_trial(i).isFailure = false;
               meta_trial(i).isAbort = true;
            else
               meta_trial(i).isSuccess = false;
               meta_trial(i).isFailure = false;
               meta_trial(i).isAbort = false;
               warning('should be an error?');
            end
         end
      end
   end
   if numel(tOn) > 1
      meta_trial(i).isRepeat = numel(tOn);
      tOn = tOn(end);
      if exist('tOff','var') && ~isempty(tOff)
         tOff = tOff(end);
      end
   else
      meta_trial(i).isRepeat = 0;
   end
   if exist('tOff','var')
      meta_fixation(i) = metadata.event.Stimulus('name',fixationLabel,'tStart',tOn,...
         'tEnd',tOff);
   else
      meta_fixation(i) = metadata.event.Stimulus('name',fixationLabel,'tStart',tOn,...
         'tEnd',NaN);
   end

   clear tOn tOff;
   %% TARGET
   tOn = tTargetOn((tTargetOn > tStart(i)) & (tTargetOn < tFinish(i))) - shift;
   if numel(tOn) >= 1
      if meta_trial(i).stopTrial
         try
            if meta_trial(i).isCorrect
               ind = (tSuccess2Enter > tStart(i)) & (tSuccess2Enter < tFinish(i));
               tOff = tSuccess2Enter(ind) - shift;
            else
               ind = (tStopHoldOff > tStart(i)) & (tStopHoldOff < tFinish(i));
               tOff = tStopHoldOff(ind) - shift;
            end
         catch
            tOff = NaN;
         end
      else
         if meta_trial(i).isSuccess
            tOff = tTarHold((tTarHold > tStart(i)) & (tTarHold < tFinish(i))) - shift;
         elseif meta_trial(i).isFailure
            indF = (tFailure > tStart(i)) & (tFailure < tFinish(i));
            tOff = tFailure(indF) - shift;
         elseif meta_trial(i).isAbort
            indA = (tAbort > tStart(i)) & (tAbort < tFinish(i));
            tOff = tAbort(indF) - shift;
         end
      end
      if meta_trial(i).isRepeat
         tOn = tOn(end);
         if exist('tOff','var') && ~isempty(tOff)
            tOff = tOff(end);
         end
      end
      if exist('tOff','var')
         meta_target(i) = metadata.event.Stimulus('name',targetLabel,'tStart',tOn,...
            'tEnd',tOff);
      else
         meta_target(i) = metadata.event.Stimulus('name',targetLabel,'tStart',tOn,...
            'tEnd',NaN);
      end
   else % targets never displayed
      meta_target(i) = metadata.event.Stimulus('name',targetLabel);
   end
   
   clear tOn tOff;
   %% FEEDBACK?
   if meta_trial(i).stopTrial
      tOn = tSuccess2Enter((tSuccess2Enter > tStart(i)) & (tSuccess2Enter < tFinish(i))) - shift;
   else
      tOn = tSuccessEnter((tSuccessEnter > tStart(i)) & (tSuccessEnter < tFinish(i))) - shift;
   end
   if numel(tOn) >= 1
      if meta_trial(i).stopTrial
         try
            if meta_trial(i).isCorrect
               ind = (tSuccess2Exit > tStart(i)) & (tSuccess2Exit < tFinish(i));
               tOff = tSuccess2Exit(ind) - shift;
            else
               ind = (tStopHoldOff > tStart(i)) & (tStopHoldOff < tFinish(i));
               tOff = tStopHoldOff(ind) - shift;
            end
         catch
            tOff = NaN;
         end
      else
         if meta_trial(i).isSuccess
            tOff = tSuccessExit((tSuccessExit > tStart(i)) & (tSuccessExit < tFinish(i))) - shift;
         elseif meta_trial(i).isFailure
            indF = (tFailure > tStart(i)) & (tFailure < tFinish(i));
            tOff = tFailure(indF) - shift;
         elseif meta_trial(i).isAbort
            indA = (tAbort > tStart(i)) & (tAbort < tFinish(i));
            tOff = tAbort(indF) - shift;
         end
      end
      if meta_trial(i).isRepeat
         tOn = tOn(end);
         if exist('tOff','var') && ~isempty(tOff)
            tOff = tOff(end);
         end
      end
      if exist('tOff','var')
         meta_feedback(i) = metadata.event.Stimulus('name',feedbackLabel,'tStart',tOn,...
            'tEnd',tOff);
      else
         meta_feedback(i) = metadata.event.Stimulus('name',feedbackLabel,'tStart',tOn,...
            'tEnd',NaN);
      end
   else % targets never displayed
      meta_feedback(i) = metadata.event.Stimulus('name',feedbackLabel);
   end
   
   clear tOn tOff;
   %% CUE
   tOn = tCueOn((tCueOn > tStart(i)) & (tCueOn < tFinish(i))) - shift;
   if numel(tOn) >= 1
      tOff = tCueOff((tCueOff > tStart(i)) & (tCueOff < tFinish(i))) - shift;
      if meta_trial(i).isRepeat
         tOn = tOn(end);
         tOff = tOff(end);
      end
      meta_cue(i) = metadata.event.Stimulus('name',cueLabel,'tStart',tOn,...
         'tEnd',tOff);
   else
      meta_cue(i) = metadata.event.Stimulus('name',cueLabel);
   end
   
   clear tOn tOff;
   %% fix touch
   tOn = tFixAcquire((tFixAcquire > tStart(i)) & (tFixAcquire < tFinish(i))) - shift;
   if (numel(tOn) >= 1) && meta_trial(i).isSuccess
      tOff = tFixAcquire((tFixAcquire > tStart(i)) & (tFixAcquire < tFinish(i))) - shift;
      if meta_trial(i).isRepeat
         tOn = tOn(end);
         if exist('tOff','var') && ~isempty(tOff)
            tOff = tOff(end);
         end
      end
      if numel(tOff) > 1
         keyboard;
      end
      meta_fixTouch(i) = metadata.event.Response('name',fixTouchLabel,'modality','touch',...
         'tStart',tOn,'tEnd',tOff);
   else
      meta_fixTouch(i) = metadata.event.Response('name',fixTouchLabel,'modality','touch');
   end
    
   clear tOn tOff;
   %% target touch
   tOn = tTarAcquire2((tTarAcquire2 > tStart(i)) & (tTarAcquire2 < tFinish(i))) - shift;
   if numel(tOn) >= 1
      tOff = tTarHold((tTarHold > tStart(i)) & (tTarHold < tFinish(i))) - shift;
      if meta_trial(i).isRepeat
         tOn = tOn(end);
         if exist('tOff','var') && ~isempty(tOff)
            tOff = tOff(end);
         end
      end
      if numel(tOff) > 1
         keyboard;
      end
      meta_tarTouch(i) = metadata.event.Response('name',tarTouchLabel,'modality','touch',...
         'tStart',tOn,'tEnd',tOff);
   else
      meta_tarTouch(i) = metadata.event.Response('name',tarTouchLabel,'modality','touch');
   end
   
end

data.matfile = matfile;
data.trial = meta_trial;
data.fixation = meta_fixation;
data.target = meta_target;
data.cue = meta_cue;
data.feedback = meta_feedback;
data.fixTouch = meta_fixTouch;
data.tarTouch = meta_tarTouch;
   