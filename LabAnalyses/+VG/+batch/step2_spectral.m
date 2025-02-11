% function data_temp = step2_spectral(protocol, subject, data, e, norm)
function dataTF = step2_spectral(seg, e, norm, restTFm)

global tBlock

%% select data
d    = linq(seg);
temp = d.where(@(x) x.info('trial').GaitQuality == 1);
temp = d.where(@(x) x.info('trial').isGaitValid == 1);

% if strcmp(e, 'DOOR') || strcmp(e, 'END')
% %     temp = d.where(@(x) x.info('trial').isDoor == 1);
%     temp = d.where(@(x) strcmp(x.info('trial').DoorCond, 'P=5') == 0);
% end

if isempty(temp)
    display([e ' condition is empty']);   
else
    temp = d.toArray();
    %% sync data around event
    if ~isempty(e)
        switch e
            case {'GAIT', 'BUTTON'}
                SyncWin = [-1 2];
                temp.sync('func',@(x) strcmp(x.name.name, e), 'window', SyncWin);
            case {'DOOR'}
                SyncWin = [-2 2];
                temp.sync('func',@(x) strcmp(x.name.name, e), 'window', SyncWin);
            case 'END'
                SyncWin = [-2 1];
                temp.sync('func',@(x) strcmp(x.name.name, e), 'window', SyncWin);
%             case 'BUTTON'
%                 button_start = cell2mat(d.select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'BUTTON')).tStart).toList)';
%                 rest_start   = cell2mat(d.select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'REST')).tStart).toList)';
%                 gait_end     = cell2mat(d.select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'END')).tStart).toList)';
%                 SyncWin = [min([button_start,rest_start],[],2)-0.5 gait_end+1];
        end
        
    end
    
        %% Spectral transformation
    lfp  = [temp.sampledProcess];
%     TF   = tfr(lfp,'method','chronux','tBlock',0.5,'tStep',0.03,'f',[1 100],'tapers',[3 5],'pad',1);
    TF   = tfr(lfp,'method','chronux','tBlock',tBlock,'tStep',0.03,'f',[1 100],'tapers',[3 5],'pad',1);
    
    %% Normalisation
    if norm > 0
        %     TF.normalize(2,'window',[-0.5 0.1],'method','divide');TF.fix();
        %     TF.normalize(0,'window',[-1 -0.1],'method','subtract');
%         TF.normalize(0,'window',[0.1 0.9],'method','subtract','process', restTFm);

        % get tEnd from rest duration rest duration
        tEnd = restTFm.dur - 0.1;
        % split ON and OFF condition
        for med = fieldnames(restTFm)'
            idx = cell2mat(arrayfun(@(x) strcmp(x.info('trial').medication, med{1}), temp, 'uni', 0));
            if sum(idx) > 0
                %% !!!! for window, add tblock value for tend because tblock is removed in  applywindow line 45
                if norm == 1
%                     TF(idx) = TF(idx).normalize(0,'method','z-score','Process', restTFm.(med{1}),'window',[0.1 0.9]);
                    TF(idx) = TF(idx).normalize(0,'method','z-score','Process', restTFm.(med{1}),'window',[0.1 tEnd + tBlock]);
                elseif norm == 2
%                     TF(idx) = TF(idx).normalize(0,'method','subtract','Process', restTFm.(med{1}),'window',[0.1 0.9]);
                    TF(idx) = TF(idx).normalize(0,'method','subtract','Process', restTFm.(med{1}),'window',[0.1 tEnd + tBlock]);
                elseif norm == 3 || norm == 4
%                     TF(idx) = TF(idx).normalize(0,'method','divide','Process', restTFm.(med{1}),'window',[0.1 0.9]);
                    TF(idx) = TF(idx).normalize(0,'method','divide','Process', restTFm.(med{1}),'window',[0.1 tEnd + tBlock]);
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