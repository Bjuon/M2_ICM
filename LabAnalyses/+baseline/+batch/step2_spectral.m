% function data_temp = step2_spectral(protocol, subject, data, e, norm)
function dataTF = step2_spectral(seg, e)
global tBlock
global fqStart
global n_pad

%% select data
d    = linq(seg);
temp = d.toArray();

%% Spectral transformation
lfp  = [temp.sampledProcess];
TF   = tfr(lfp,'method','chronux','tBlock',tBlock,'tStep',0.03,'f',[fqStart 100],'tapers',[3 5],'pad',n_pad);
TF.fix();


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
end

%TF(1).plot('log', false)

end