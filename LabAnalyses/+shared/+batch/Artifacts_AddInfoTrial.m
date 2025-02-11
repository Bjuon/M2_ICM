%TODO
% add column ChComment to csv for R

function Artifacts_AddInfoTrial(OutputFileName, TFcheck_suf)

load([OutputFileName '_TF_check' TFcheck_suf '.mat'])

if  exist('artifacts', 'var')  
    
    Art_events = artifacts.find('eventType', 'metadata.event.Artifact');    
    if numel(dataTF) ~= numel(Art_events)
        error('number of seg and artefacts differ')
    end

    % check artifact trial per trial
    for t = 1 : numel(dataTF) 
        artifacts(t).info('trial') = dataTF(t).info('trial');
    end

    save([OutputFileName '_artifacts.mat'], 'artifacts')
end

