function Export_timecourses(seg, e, norm, Bsl)
   


global tBlock
global fqStart
global segType
global rest_cond
global n_pad

%% select data
d    = linq(seg);

if ~isempty(e)
    temp    = d.where(@(x) x.info('trial').quality == 1);
    if strcmp(segType, 'step')
        if strcmp(e, 'FOG_S') || strcmp(e, 'TURN_S')
            SyncWin = [-2.5 2];
        else
            SyncWin = [-1.5 2];
        end
    elseif strcmp(segType, 'trial')        
        bsl_start = cell2mat(linq(seg).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'BSL')).tStart).toList)';
        turn_end = cell2mat(linq(seg).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'TURN_E')).tStart).toList)';
%         SyncWin = [bsl_start turn_end+1];
    end
else
    temp = d;
    winBsl  = [0.4  0.9 + tBlock] -tBlock/2;
end

if isempty(temp)
    disp([e ' trigger is empty']);   
else
    %% sync data around event
    switch e
        case {'FIX', 'CUE', 'T0', 'T0_EMG', 'FO1', 'FC1','FO2','FC2', 'WrFIX', 'WrCUE'}
            temp   = d.where(@(x) strcmp(x.info('trial').condition, 'APA'));
            winBsl = [0.4  0.9 + tBlock] - tBlock/2;
        case {'FO', 'FC'}
            temp   = d.where(@(x) strcmp(x.info('trial').condition, 'step'));
            winBsl = [0.4  0.9 + tBlock] - tBlock/2;
        case {'TURN_S', 'TURN_E'}
            temp   = d.where(@(x) strcmp(x.info('trial').condition, 'turn'));
            winBsl = [0.4  0.9 + tBlock] - tBlock/2;
        case {'FOG_S', 'FOG_E'}
            temp   = d.where(@(x) strcmp(x.info('trial').condition, 'FOG'));
            %winBsl = [-09  -0.1 + tBlock];
            winBsl = [0.4  0.9 + tBlock] - tBlock/2;
        case {'BSL'}
            temp   = d.where(@(x) strcmp(x.info('trial').condition, rest_cond));
            winBsl = [0.1  0.9 + tBlock] - tBlock/2;
    end
    
    
    temp = d.toArray();
    
    if ~isempty(e)
        idx_event = cell2mat(arrayfun(@(x) sum(arrayfun(@(y) strcmp(y.name.name  , e) , x.eventProcess.values{1}))>0, temp, 'uni', 0));
        temp = temp(idx_event);
        if strcmp(segType, 'step')
            temp.sync('func',@(x) strcmp(x.name.name, e), 'window', SyncWin);
        end
    end
    
    %% Spectral transformation
    lfp  = [temp.sampledProcess];
    % TF   = tfr(lfp,'method','chronux','tBlock',0.5,'tStep',0.03,'f',[1 100],'tapers',[3 5],'pad',1);
    if ~isempty(lfp)
        TF   = tfr(lfp,'method','chronux','tBlock',tBlock,'tStep',0.03,'f',[fqStart 100],'tapers',[3 5],'pad',n_pad);
   
    %% Normalisation
    if norm > 0 %~isempty(e) && 
        clear bslTFadd
        %% for event other that APA, add trials to RestTF
        switch e
            case {'BSL', 'FIX', 'CUE', 'T0', 'T0_EMG', 'FO1', 'FC1', 'FO2', 'FC2', 'FO', 'FC', 'TURN_S', 'TURN_E', 'FOG_S', 'FOG_E', 'WrFIX', 'WrCUE'}
                trials    = arrayfun(@(x) x.info('trial').nTrial, temp);
                for t = 1:numel(trials)
                    med    = temp(t).info('trial').medication;
                    nTrial = temp(t).info('trial').nTrial;
                    idx_t  = find((strcmp(Bsl.med, med) & [Bsl.ntrial{:}]' == nTrial) == 1); 
                    if isempty(idx_t)
                        error ('idx_t is empty')
                    end
                    bslTFadd(t) = Bsl.TF(idx_t);
                end
%             case {'FOG_S', 'FOG_E'}
%                 if strcmp(e, 'FOG_E')
%                     temp.reset;
%                     temp.sync('func',@(x) strcmp(x.name.name, 'FOG_S'), 'window', SyncWin);
%                 end
%                 bslTFadd = tfr([temp.sampledProcess],'method','chronux','tBlock',tBlock,'tStep',0.03,'f',[fqStart 100],'tapers',[3 5],'pad',1);
%                 if strcmp(e, 'FOG_E')
%                     temp.reset;
%                     temp.sync('func',@(x) strcmp(x.name.name, e), 'window', SyncWin);
%                 end
%             case {'T0', 'FO1', 'FC1'}
%                 bslTFadd = Bsl.TF;
            case ''
                trials    = unique(arrayfun(@(x) [x.info('trial').medication '_' sprintf('%02i', x.info('trial').nTrial)], temp, 'UniformOutput', false));
                if numel(trials) ~= numel(Bsl.TF)
                    error('not same numbe of trials in Bsl and TF')
                end
                t_count   = 0;
                for t = 1:numel(Bsl.TF)
                    med         = Bsl.med{t};
                    nTrial      = Bsl.ntrial{t};
                    idx_t       = find((strcmp(Bsl.med, med) & [Bsl.ntrial{:}]' == nTrial) == 1);
                    idx_t_temp  = find(arrayfun(@(x) x.info('trial').nTrial == nTrial & strcmp(x.info('trial').medication, med), temp) == 1);
                    if isempty(idx_t)
                        error ('idx_t is empty')
                    end
                    bslTFadd(t_count+1:t_count+numel(idx_t_temp)) = Bsl.TF(idx_t);
                    t_count   = t_count + numel(idx_t_temp);
                end
        end
        
        if numel(TF) ~= numel(bslTFadd)
            error('not the same number of trials')
        end
        
        if norm == 1
            TF.normalize(0,'method','z-score','Process', bslTFadd,'window',winBsl); %,[-0.5 1.4]);
        elseif norm == 2
            TF.normalize(0,'method','subtract','Process', bslTFadd,'window',winBsl);
        elseif norm == 3 || norm == 4
            TF.normalize(0,'method','divide','Process', bslTFadd,'window',winBsl);
        end
       
        TF.fix();
    end
    
    % Exctract Event Process
    EVTs = [temp.eventProcess];
    
    %% Recreate segment
    if isempty(e)
        for trial = 1:numel(TF)
            if ~exist('dataTF')
                dataTF(1) = Segment('process',{...
                    lfp(trial),...
                    TF(trial),...
                    EVTs(trial)},...
                    'labels',{'LFP' 'TF' 'Evt'});
                dataTF(1).info('trial') = temp(trial).info('trial');
            else
                dataTF(end+1) = Segment('process',{...
                    lfp(trial),...
                    TF(trial),...
                    EVTs(trial)},...
                    'labels',{'LFP' 'TF' 'Evt'});
                dataTF(end).info('trial') = temp(trial).info('trial');
            end
        end
    elseif ~isempty(e)
        for trial = 1:numel(TF)
            if ~exist('dataTF')
                dataTF(1) = Segment('process',{...
                    TF(trial),...
                    EVTs(trial)},...
                    'labels',{'TF' 'Evt'});
                dataTF(1).info('trial') = temp(trial).info('trial');
            else
                dataTF(end+1) = Segment('process',{...
                    TF(trial),...
                    EVTs(trial)},...
                    'labels',{'TF' 'Evt'});
                dataTF(end).info('trial') = temp(trial).info('trial');
            end
        end
        existTF = true ;
    end
    else
        dataTF = NaN;
        disp(['Pas de LFP ou Pas d''event :' e])
        existTF = false ;
    end
    %TF(1).plot('log', false)
end




end

