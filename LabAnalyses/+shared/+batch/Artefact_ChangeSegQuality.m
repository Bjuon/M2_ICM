%TODO
% add column ChComment to csv for R

function seg = Artefact_ChangeSegQuality(OutputFileName, TFcheck_suf)

load([OutputFileName '_LFP.mat'])
load([OutputFileName '_TF_check' TFcheck_suf '.mat'])

if  exist('artifacts', 'var')  
    
    Art_events = artifacts.find('eventType', 'metadata.event.Artifact');    
    if numel(seg) ~= numel(Art_events)
        error('number of seg and artefacts differ')
    end

    % check artifact trial per trial
    for t = 1 : numel(seg)        
        if strcmp(Art_events(t).type, 'metadata.event.Artifact')
            clear trial BadCh ChNames idxBad
           
            % set bad channels 
            BadCh   = {Art_events(t).labels.name};
            ChNames = {seg(t).sampledProcess.labels.name};
            [~, idxBad] = intersect(ChNames, BadCh);
            if numel(BadCh) ~= numel(idxBad)
                error('number of idxBad and BadCh')
            end
            for i = 1:numel(idxBad)
                seg(t).sampledProcess.labels(idxBad(i)).comment = 'bad';
            end
            
            % set seg quality to 0 if all channels are tagged as bad
            if numel(idxBad) == numel(ChNames)
                trial = seg(t).info('trial');
                trial.quality = 0;
                seg(t).info('trial') = trial;
            end
        end
    end
end

