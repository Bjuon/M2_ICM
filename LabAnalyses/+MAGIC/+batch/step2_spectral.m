function [dataTF, existTF] = step2_spectral(seg, e, norm, Bsl, version)
global tBlock
global fqStart
global segType
global rest_cond
global n_pad
global thenaisie
combinedplot =1;
% Set default version to 'cleaned' if not provided.
if nargin < 5
    version = 'clean';
end

seg_complete = seg;

if iscell(seg)
    if strcmpi(version, 'raw')
            seg = seg{1};
        elseif strcmpi(version, 'clean')
            seg = seg{2};
        else
            error('Invalid version specified. Use "raw" or "clean".');
    end
end

%% select data using segData
d = linq(seg);

if ~isempty(e)
    temp = d; 
%    temp = d.where(@(x) x.info('trial').quality == 1);
   if strcmp(segType, 'step')
        if strcmp(e, 'FOG_S') || strcmp(e, 'TURN_S')
            SyncWin = [-2.5 2];
        elseif combinedplot ==1;
            SyncWin = [-1 +1]; %
        else
            SyncWin = [-1.5 2]; %
        end
    elseif strcmp(segType, 'trial')
        bsl_start = cell2mat(d.select(@(x) x.eventProcess.find('func', @(x) strcmp(x.name.name, 'BSL')).tStart).toList)';
        turn_end  = cell2mat(d.select(@(x) x.eventProcess.find('func', @(x) strcmp(x.name.name, 'TURN_E')).tStart).toList)';
        % SyncWin = [bsl_start turn_end+1];
    end
else
    temp = d;
    winBsl = [0.4  0.9 + tBlock] - tBlock/2;
end

if isempty(temp)
    disp([e ' trigger is empty']);   
else
    %% sync data around event
    switch e
        case {'FIX', 'CUE', 'T0', 'T0_EMG', 'FO1', 'FC1','FO2','FC2', 'WrFIX', 'WrCUE'}
            temp = d.where(@(x) strcmp(x.info('trial').condition, 'APA'));
            winBsl = [0.4  0.9 + tBlock] - tBlock/2;
        case {'FO', 'FC'}
            temp = d.where(@(x) startsWith(x.info('trial').condition,'step'));
            winBsl = [0.4  0.9 + tBlock] - tBlock/2;
        case {'TURN_S', 'TURN_E'}
            temp = d.where(@(x) strcmp(x.info('trial').condition, 'turn'));
            winBsl = [0.4  0.9 + tBlock] - tBlock/2;
        case {'FOG_S', 'FOG_E'}
            temp = d.where(@(x) strcmp(x.info('trial').condition, 'FOG'));
            winBsl = [0.4  0.9 + tBlock] - tBlock/2;
        case {'BSL'}
            temp = d.where(@(x) strcmp(x.info('trial').condition, rest_cond));
            winBsl = [0.1  0.9 + tBlock] - tBlock/2;
    end
    
    temp = d.toArray();
    
    if ~isempty(e)
        idx_event = cell2mat(arrayfun(@(x) sum(arrayfun(@(y) strcmp(y.name.name, e), x.eventProcess.values{1})) > 0, temp, 'uni', 0));
        temp = temp(idx_event);
        if strcmp(segType, 'step')
            temp.sync('func', @(x) strcmp(x.name.name, e), 'window', SyncWin);
        end
    end
    
    %% Spectral transformation
    lfp = [temp.sampledProcess];
 
      % ---------------------------------------------------------------
    % ---  ZERO-out bad & empty channels *for the current event only* -     ---
    % ---------------------------------------------------------------
    if strcmpi(version,'clean') && thenaisie

        skipTrials          = false(1,numel(temp));
        keptCnt   = 0;   droppedCnt = 0;

        for tIdx = 1:numel(temp)

            % ---- 1. get the artefact flags for THIS event (e) ----
            evtNames = arrayfun(@(x) x.name.name, ...
                                temp(tIdx).eventProcess.values{1}, ...
                                'uni', 0);
            evtIdx   = find(strcmp(evtNames, e));       % FO = 1 , FC = 2
            if isempty(evtIdx)
                warning('step2_spectral: event ��%s�� missing in seg %d',e,tIdx);
                continue
            end

            % `psdInfo` was added by computePSDandArtifactRejection in step-1
            psdInf   = temp(tIdx).info('psdInfo');
            badFlags = logical(psdInf(evtIdx).eventArtifactFlags);   % 1 = flagged
            vals       = lfp(tIdx).values{1};                       % matrix: time � channels
            emptyMask  = all(isnan(vals) | vals==0, 1);            % 1 = empty channel
            badCombined = badFlags | emptyMask;            
            
            badCh = find(badCombined);
            nCh   = size(vals, 2);

            % ---- 2. decide keep / skip & possibly zero channels ----
            if isempty(badCh)                     % nothing flagged
                keptCnt = keptCnt + 1;
%                 fprintf('[step2] KEEP  seg %3d � all %d channels OK\n',tIdx,nCh);

            elseif numel(badCh) == nCh            % every channel bad
                skipTrials(tIdx) = true;
                droppedCnt       = droppedCnt + 1;
%                 fprintf('[step2] SKIP  seg %3d � %d/%d bad channels (all)\n',tIdx,nCh,nCh);

            else                                  % mixture of good & bad
                lfp(tIdx).values{1}(:,badCh) = 0; % hard-zero bad channels
                keptCnt = keptCnt + 1;
%                 fprintf('[step2] KEEP  seg %3d � zeroed %d/%d bad channels\n', ...
                 %       tIdx,numel(badCh),nCh);
            end
        end

        % ---- 3. physically drop the �all-bad� segments -------------
        if any(skipTrials)
            temp(skipTrials) = [];
            lfp(skipTrials)  = [];
        end
        fprintf('[step2] SUMMARY � %d segments kept | %d dropped\n\n', ...
                keptCnt, droppedCnt);

        if isempty(lfp)          % nothing left = abort
            dataTF  = [];
            existTF = false;
            fprintf('[step2] No usable segments remain � exiting.\n');
            return
        end
    end
    if ~isempty(lfp)
        TF = tfr(lfp, 'method', 'chronux', 'tBlock', tBlock, 'tStep', 0.03, ...
            'f', [fqStart 100], 'tapers', [3 5], 'pad', n_pad);

   
    %% Normalisation
    if norm > 0
        clear bslTFadd
        switch e
            case {'BSL', 'FIX', 'CUE', 'T0', 'T0_EMG', 'FO1', 'FC1', ...
                  'FO2', 'FC2', 'FO', 'FC', 'TURN_S', 'TURN_E', ...
                  'FOG_S', 'FOG_E', 'WrFIX', 'WrCUE'}
                trials = arrayfun(@(x) x.info('trial').nTrial, temp);
                for t = 1:numel(trials)
                    med    = temp(t).info('trial').medication;
                    nTrial = temp(t).info('trial').nTrial;
                    idx_t  = find((strcmp(Bsl.med, med) & [Bsl.ntrial{:}]' == nTrial) == 1);
                    if isempty(idx_t)
                        error('idx_t is empty');
                    end
                    bslTFadd(t) = Bsl.TF(idx_t);
                end
        end
        
        if numel(TF) ~= numel(bslTFadd)
            error('not the same number of trials')
        end
        
        if norm == 1
            TF.normalize(0, 'method', 'z-score', 'Process', bslTFadd, 'window', winBsl);
        elseif norm == 2
            TF.normalize(0, 'method', 'subtract', 'Process', bslTFadd, 'window', winBsl);
        elseif norm == 3 || norm == 4
            TF.normalize(0, 'method', 'divide', 'Process', bslTFadd, 'window', winBsl);
        end
       
        TF.fix();
    end
    
    % Extract Event Process
    EVTs = [temp.eventProcess];
    
    %% Recreate segment
    if isempty(e)
        for trial = 1:numel(TF)
            if ~exist('dataTF', 'var')
                dataTF(1) = Segment('process', {...
                    lfp(trial),...
                    TF(trial),...
                    EVTs(trial)},...
                    'labels', {'LFP', 'TF', 'Evt'});
                dataTF(1).info('trial') = temp(trial).info('trial');
            else
                dataTF(end+1) = Segment('process', {...
                    lfp(trial),...
                    TF(trial),...
                    EVTs(trial)},...
                    'labels', {'LFP', 'TF', 'Evt'});
                dataTF(end).info('trial') = temp(trial).info('trial');
            end
        end
    else
        for trial = 1:numel(TF)
            if ~exist('dataTF', 'var')
                dataTF(1) = Segment('process', {...
                    TF(trial),...
                    EVTs(trial)},...
                    'labels', {'TF', 'Evt'});
                dataTF(1).info('trial') = temp(trial).info('trial');
            else
                dataTF(end+1) = Segment('process', {...
                    TF(trial),...
                    EVTs(trial)},...
                    'labels', {'TF', 'Evt'});
                dataTF(end).info('trial') = temp(trial).info('trial');
            end
        end
        existTF = true;
    end
    %TF(1).plot('log', false)
    
else
    disp(['pas de ' e ' trouv�s'])
    dataTF = [];
    existTF = false;
    existTF_clean = false; 
    return;
    end

end
