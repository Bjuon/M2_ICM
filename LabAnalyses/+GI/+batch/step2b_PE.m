% function data_temp = step2_spectral(protocol, subject, data, e, norm)
function dataPE = step2b_PE(seg, e, norm)


%% select data
d    = linq(seg);

if ~isempty(e)
    temp    = d.where(@(x) x.info('trial').quality == 1);
    SyncWin = [-0.5 1];
else
    temp = d;
    winBsl  = [0.4  0.9];
end

if isempty(temp)
    display([e ' trigger is empty']);   
else
    %% sync data around event
    % temp.sync('eventType','metadata.event','eventVal',e,'window',[-2 2]);
    switch e
        case {'T0', 'FO1', 'FC1'}
            temp   = d.where(@(x) strcmp(x.info('trial').condition, 'APA'));
            winBsl = [0.4  0.9];
        case {'FO', 'FC'}
            temp   = d.where(@(x) strcmp(x.info('trial').condition, 'step'));
            winBsl = [0.4  0.9];
        case {'TURN_S', 'TURN_E'}
            temp   = d.where(@(x) strcmp(x.info('trial').condition, 'turn'));
            winBsl = [0.4  0.9];
        case {'FOG_S', 'FOG_E'}
            temp   = d.where(@(x) strcmp(x.info('trial').condition, 'FOG'));
            winBsl = [-09  -0.1];
    end
    
    temp = d.toArray();
    
    if ~isempty(e)
        idx_event = cell2mat(arrayfun(@(x) sum(arrayfun(@(y) strcmp(y.name.name  , e) , x.eventProcess.values{1}))>0, temp, 'uni', 0));
        temp = temp(idx_event);
        temp.sync('func',@(x) strcmp(x.name.name, e), 'window', SyncWin);
    end
    
    %% PE
    lfp      = [temp.sampledProcess];
    %lfp_mean = lfp.mean; 
   
    % Exctract Event Process
    EVTs = [temp.eventProcess];
    
    %% Recreate segment
    for trial = 1:numel(lfp)
        if ~exist('dataPE')
            dataPE(1) = Segment('process',{...
                lfp(trial),...
                EVTs(trial)},...
                'labels',{'PE' 'Evt'});
            dataPE(1).info('trial') = temp(trial).info('trial');
        else
            dataPE(end+1) = Segment('process',{...
                lfp(trial),...
                EVTs(trial)},...
                'labels',{'PE' 'Evt'});
            dataPE(end).info('trial') = temp(trial).info('trial');
        end
    end
end

