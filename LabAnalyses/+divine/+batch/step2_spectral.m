% function data_temp = step2_spectral(protocol, subject, data, e, norm)
function dataTF = step2_spectral(seg, e, norm, BslTFm)

%% select data
d    = linq(seg);
temp = d.where(@(x) x.info('trial').MovieQuality == 1);
temp = d.where(@(x) x.info('trial').isValid >= 1);


if isempty(temp)
    display([e ' condition is empty']);   
else
    temp = d.toArray();
    %% sync data around event
    % temp.sync('eventType','metadata.event','eventVal',e,'window',[-2 2]);
    % {'MOVIE_S', 'MVT_S', 'GRASP', 'MVT_END'};
    switch e
        case {'sMOVIE', 'sMVT', 'GRASP'}
            SyncWin = [-1 2];
        case 'eMVT'
            SyncWin = [-2 1];
    end
%     temp.sync('eventType', 'metadata.event.Stimulus', 'eventVal', e, 'window', SyncWin);
    temp.sync('func',@(x) strcmp(x.name.name, e), 'window', SyncWin);    
    
        %% Spectral transformation
    lfp  = [temp.sampledProcess];
    TF   = tfr(lfp,'method','chronux','tBlock',0.5,'tStep',0.03,'f',[1 100],'tapers',[3 5],'pad',1);
    
    %% Normalisation
    if norm > 0
        %     TF.normalize(2,'window',[-0.5 0.1],'method','divide');TF.fix();
        %     TF.normalize(0,'window',[-1 -0.1],'method','subtract');
%         TF.normalize(0,'window',[0.1 0.9],'method','subtract','process', BslTFm);

        % split VGRASP AND RGRAPS, and ON and OFF condition
        for tsk = fieldnames(BslTFm)'
            for med = fieldnames(BslTFm.(tsk{1}))'
                idx = cell2mat(arrayfun(@(x) strcmp(x.info('trial').medication, med{1}), temp, 'uni', 0)) & ...
                    cell2mat(arrayfun(@(x) strcmp(x.info('trial').task, tsk{1}), temp, 'uni', 0));
                if sum(idx) > 0
                    %% !!!! for window, add tblock value for tend because tblock is removed in  applywindow line 45
                    if norm == 1
                        TF(idx) = TF(idx).normalize(0,'method','z-score','Process', BslTFm.(tsk{1}).(med{1}),'window',[-0.4 0.4]);
                    elseif norm == 2
                        TF(idx) = TF(idx).normalize(0,'method','subtract','Process', BslTFm.(tsk{1}).(med{1}),'window',[-0.4 0.4]);
                    elseif norm == 3
                        TF(idx) = TF(idx).normalize(0,'method','divide','Process', BslTFm.(tsk{1}).(med{1}),'window',[-0.4 0.4]);
                    end
                end
            end
        end
        TF.fix();
    end
    
    % Exctract Event Process
    EVTs = [temp.eventProcess];
    
    %% Recreate segment
    for trial = 1:numel(TF)

        if ~exist('dataTF')
            dataTF(1) = Segment('process',{...
                TF(trial),...
                EVTs(trial)},...
                'labels',{'LFP' 'Gait'});
            dataTF(1).info('trial') = temp(trial).info('trial');
        else
            dataTF(end+1) = Segment('process',{...
                TF(trial),...
                EVTs(trial)},...
                'labels',{'LFP' 'Gait'});
            dataTF(end).info('trial') = temp(trial).info('trial');
        end
    end
    
    
    
    %TF.plot('log', false)
end




end