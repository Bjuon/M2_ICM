function [segments] = AddBehav(Resultats,stemp)
% Inputs:
%   - Resulats: comportemental data
%   - stemp: 1*N SampledProcess
% Output:
%   - evt_processes: 1*N EventProcess

% selection et ouverture du fichier
if ~isequal(size(Resultats.Data,1)-1,numel(stemp));
    error('ERROR Not the same number of trials in s and mat')
end

% ind old (header)
if strcmp(Resultats.Data{1}(1,1),'T');
    n = 2;
else n = 1;
end

for ind = n:size(Resultats.Data,1);
    
    % Time-sensitive events
    if(Resultats.Data{ind,3}.*10^(-3) >0)
        event(1) = metadata.event.Stimulus('tStart',Resultats.Data{ind,3}.*10^(-3),'tEnd',Resultats.Data{ind,3}.*10^(-3)+0.01,'name','PtFixOnSet');
    else
        event(1) = metadata.event.Stimulus('tStart',NaN,'tEnd',NaN,'name','PtFixOnSet');
    end
    
    if((Resultats.Data{ind,3}+ Resultats.Data{ind,5}).*10^(-3)>0)
        event(2) = metadata.event.Stimulus('tStart',(Resultats.Data{ind,3}+ Resultats.Data{ind,5}).*10^(-3),'tEnd',(Resultats.Data{ind,3}+ Resultats.Data{ind,5})*10^(-3) +0.01,'name','CueOnSet');
    else
        event(2) = metadata.event.Stimulus('tStart',NaN,'tEnd',NaN,'name','CueOnSet');
    end
    
        
    if((Resultats.Data{ind,3} + Resultats.Data{ind,5} + Resultats.Data{ind,7})*10^(-3)>0)
        event(3) = metadata.event.Response('tStart',(Resultats.Data{ind,3} + Resultats.Data{ind,5} + Resultats.Data{ind,7})*10^(-3),'tEnd',(Resultats.Data{ind,3} + Resultats.Data{ind,5} + Resultats.Data{ind,7})*10^(-3)+0.01,'name','Reaction');
    else
        event(3) = metadata.event.Response('tStart',NaN,'tEnd',NaN,'name','Reaction');
    end
    
    
    
    % Test Trial data
    gonogo = metadata.trial.GoNogo;
    
    % bloctype
    a = strfind(Resultats.Data{ind,1},'Control');
    if isempty(a);
        gonogo.isControl = false;
    else
        gonogo.isControl = true;
    end
    
    % trialtype
    if isempty(Resultats.Data{ind,9});
        gonogo.trial = 'Go';
    elseif ~isempty(Resultats.Data{ind,9});
        gonogo.trial = Resultats.Data{ind,9};
    end
    
    % resptype
    a = strfind(Resultats.Data{ind,10},'Correct');
    if ~isempty(a);
        gonogo.isCorrect = true;
    else
        a = strfind(Resultats.Data{ind,10},'Commission');
        if ~isempty(a);
            gonogo.isCommission = true;
        else
            a = strfind(Resultats.Data{ind,10},'Omission');
            if ~isempty(a);
                gonogo.isOmission = true;
            else
                a = strfind(Resultats.Data{ind,10},'Fausse');
                if ~isempty(a);
                    gonogo.isFA = true;
                else
                    error('ERROR No valid response tag')
                end
            end
        end
    end
    
    % Pack everything into Segment container
    if n==1
        i= ind;
        sampled_process = stemp(ind);
    else
        i=ind-1;
        sampled_process = stemp(ind-1);
    end
    
    sampled_process.fix();
    segments(i) = Segment('process',...
        {...
        sampled_process,...
        EventProcess('events',event,'tStart',sampled_process.tStart,'tEnd',sampled_process.tEnd) ...
        },...
        'labels',{'lfp' 'events'});
    
    segments(i).info('trial') = gonogo;
    
    
end