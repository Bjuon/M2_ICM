function [MForR] = matrixForR_optim_trial(data, e, protocol)

global norm
global reject_table
global tBlock

dat    = [data.extract('TF')];
exType = 'TF';
BSL_start  = cell2mat(linq(data).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'BSL')).tStart).toList)';
BSL_end    = cell2mat(linq(data).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'BSL')).tEnd).toList)';
APA_start  = cell2mat(linq(data).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'T0')).tStart).toList)';
APA_end    = cell2mat(linq(data).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'FO1')).tStart).toList)';
exec_start = cell2mat(linq(data).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'FO1')).tStart).toList)';
exec_end   = cell2mat(linq(data).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'FC1')).tStart).toList)';
step_start = cell2mat(linq(data).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'FO')).tStart).toList)';
step_end   = cell2mat(linq(data).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'TURN_S')).tStart).toList)';
turn_start = cell2mat(linq(data).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'TURN_S')).tStart).toList)';
turn_end   = cell2mat(linq(data).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'TURN_E')).tStart).toList)';
FOG_start  = cellfun(@(x) [x.tStart], (linq(data).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'FOG_S'),'policy','all')).toList)', 'uni', 0);
FOG_end    = cellfun(@(x) [x.tStart], (linq(data).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'FOG_E'),'policy','all')).toList)', 'uni', 0);

% FOG with no turn
FOGnoTurn_start = FOG_start; FOGturn_start = FOG_start;
FOGnoTurn_end   = FOG_end;   FOGturn_end   = FOG_end;
clear idx
for t = 1 : size(FOG_start,1)
    idx = FOG_start{t} >= turn_start(t) & FOG_start{t} < turn_end(t);
    FOGnoTurn_start{t}(idx) = NaN;
    FOGnoTurn_end{t}(idx)   = NaN;
    
    FOGturn_start{t}(idx==0) = NaN;
    FOGturn_end{t}(idx==0)   = NaN;
end

win.FOG  = [FOG_start FOG_end]; % FOG first to remove idx FOG from evts
win.BSL  = [BSL_start BSL_end];
win.APA  = [APA_start APA_end];
win.exec = [exec_start exec_end];
win.step = [step_start step_end];
win.turn = [turn_start turn_end];
win.FOGturn     = [FOGturn_start FOGturn_end];
win.FOGnoTurn   = [FOGnoTurn_start FOGnoTurn_end];

win_names = fieldnames(win);

MForR{1,1}      = 'Protocol';
MForR{1,2}      = 'Patient'; %'Subject'; 
MForR{1,3}      = 'Medication'; %'MedCondition'; %
MForR{1,4}      = 'Condition'; %'Task'; %
MForR{1,5}      = 'quality'; %'Instruction'; %
MForR{1,6}      = 'isValid'; % distance to door
MForR{1,7}      = 'nTrial'; %nTrial ex 6
MForR{1,8}      = 'Channel'; % ex 7
MForR{1,9}      = 'Region'; %'descrition'; 
MForR{1,10}     = 'grouping'; %'grouping'; %
MForR{1,11}     = 'Freq'; % ex 8
MForR{1,12}     = 'Run'; %run ex 9
MForR{1,13}     = 'Event'; % ex10
MForR{1,14}     = 'nStep'; %run ex 9
MForR{1,15}     = 'side'; % ex10

nbRows = size(MForR,2);

TForR = 0; % because mean over Time

% MForR(1,9+1:9+numel(TForR)) = cellfun(@num2str, num2cell(TForR), 'UniformOutput', false);
MForR(1,nbRows+1:nbRows+numel(TForR)) = cellfun(@num2str, num2cell(TForR), 'UniformOutput', false);

Patients= unique(linq(data).select(@(x) x.info('trial').patient).toList);

index =1;

for pat=1:length(Patients)
    
    segments_linq = linq(data).where(@(x) strcmp(x.info('trial').patient,Patients(pat)));
    trials        = segments_linq.array;
    
    Ntrial        = length(trials);
    
    Nchannels     = linq(trials.extract(exType)).select(@(x) size(x.labels,2)).toList;
    Chan          = linq(trials.extract(exType)).select(@(x) {x.labels.name}).toList;
    ChRegion      = linq(trials.extract(exType)).select(@(x) {x.labels.description}).toList;
    ChGp          = linq(trials.extract(exType)).select(@(x) {x.labels.grouping}).toList;
    
    F = trials(1).extract('TF').f;
    NLine_patient = sum(cell2mat(Nchannels))*numel(F) * numel(win_names);
    
    MForR(index+1:index+NLine_patient ,2)  = Patients(pat);
    index_tr = index;
    
    for tr = 1:Ntrial % win_count = 1 : numel(win_names)  
        NLine_trial = Nchannels{tr}*numel(F);      
        clear idx_FOG
        tr_time = dat{tr}.times{1} + dat{1}.tBlock/2;
        
        for  win_count = 1 : numel(win_names) %tr = 1:Ntrial
            if strcmp(win_names{win_count}, 'FOG') 
                tmp = num2cell(cell2mat(win.(win_names{win_count})(tr,:)')', 2);
                idx_time = cell2mat(cellfun(@(x) tr_time >= x(1) & tr_time <= x(2), tmp, 'uni', 0)');
                %idx_time = cell2mat(cellfun(@(x) dat{tr}.times{1}-(dat{1}.tBlock/2) >= x(1) & dat{tr}.times{1} <= x(2)-(dat{1}.tBlock/2), tmp, 'uni', 0)');
                idx_time = sum(idx_time, 2); % in case of several FOGS
                idx_time = idx_time > 0; %clear tmp
                idx_FOG  = cell2mat(cellfun(@(x) tr_time >= x(1) - tBlock/2 & tr_time <= x(2) + tBlock/2, tmp, 'uni', 0)'); % remove time before and after FOG
                idx_FOG  = sum(idx_FOG, 2); % in case of several FOGS
                idx_FOG  = idx_FOG > 0; clear tmp
            elseif strcmp(win_names{win_count}, 'FOGturn') || strcmp(win_names{win_count}, 'FOGnoTurn')
                tmp = num2cell(cell2mat(win.(win_names{win_count})(tr,:)')', 2);
                idx_time = cell2mat(cellfun(@(x) tr_time >= x(1) & tr_time <= x(2), tmp, 'uni', 0)');                
                idx_time = sum(idx_time, 2); % in case of several FOGS
                idx_time = idx_time > 0; %clear tmp
            else
                idx_time = tr_time >= win.(win_names{win_count})(tr,1) & tr_time <= win.(win_names{win_count})(tr,2);
%                idx_time = dat{tr}.times{1} >= win.(win_names{win_count})(tr,1)-(dat{1}.tBlock/2) & dat{tr}.times{1} <= win.(win_names{win_count})(tr,2)-(dat{1}.tBlock/2);
            end
            
            % if FOG during event, remove FOG from event
            switch win_names{win_count}
                case {'BSL', 'step'}
                    sum_time_VO = sum(idx_time);
                    idx_time(idx_FOG) = 0;
                    if sum(idx_time)/sum_time_VO > 0.5
                        isValid = 1; %
                    else
                        isValid = 0;
                    end
                case {'APA', 'exec', 'turn'}
                    idx_time_FOG = idx_time;
                    idx_time_FOG(idx_FOG) = 0;
                    if sum(idx_time_FOG) < sum(idx_time)
                        isValid = 0; %
                    else
                        isValid = 1;
                    end
                    
                case {'FOG' , 'FOGturn', 'FOGnoTurn'}
                    isValid = 1;
            end
            
            MForR(index_tr+1:index_tr+NLine_trial,1)        = {protocol};
            MForR(index_tr+1:index_tr+NLine_trial,3)        = {trials(tr).info('trial').medication}; %medcondition};
            MForR(index_tr+1:index_tr+NLine_trial,4)        = win_names(win_count); %{trials(tr).info('trial').condition}; %task};
            MForR(index_tr+1:index_tr+NLine_trial,5)        = {trials(tr).info('trial').quality}; %instruction};
            MForR(index_tr+1:index_tr+NLine_trial,6)        = {isValid}; %{trials(tr).info('trial').isValid};
            MForR(index_tr+1:index_tr+NLine_trial,7)        = {trials(tr).info('trial').nTrial};
            MForR(index_tr+1:index_tr+NLine_trial,12)       = {trials(tr).info('trial').run};
            MForR(index_tr+1:index_tr+NLine_trial,13)       = e ;%event
            MForR(index_tr+1:index_tr+NLine_trial,14)       = {trials(tr).info('trial').nStep};
            MForR(index_tr+1:index_tr+NLine_trial,15)       = {trials(tr).info('trial').side};
            
            %NLine_trial= Nchannels{tr}*numel(F);
            
            for ch=1:numel(Chan{1,tr})
                
                if ~isempty(reject_table)
                    idx_quality = find(strcmp(reject_table.patient, Patients{pat}) & ...
                        strcmp([reject_table.Medication{:}]', trials(tr).info('trial').medication) & ...
                        strcmp([reject_table.nTrial{:}]', num2str(trials(tr).info('trial').nTrial)) & ...
                        strcmp([reject_table.Channel{:}]', Chan{1,tr}{ch}) & ...
                        strcmp([reject_table.Condition{:}]', win_names{win_count}) == 1);
                    if ~isempty(idx_quality)
                        %reject_table(idx_quality,:)
                        MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),5)    = num2cell(0);
                    end
                end
                
                MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),8)    = {Chan{1,tr}(ch)};
                MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),9)    = {ChRegion{1,tr}(ch)};
                MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),10)   = {ChGp{1,tr}(ch)};
                MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),11)   = num2cell(trials(tr).extract(exType).f);
                if norm == 4
                    MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),nbRows+1:nbRows+numel(TForR)) = num2cell(squeeze(nanmedian(10*log10(trials(tr).extract(exType).values{1}(idx_time,:,ch)))))';
                else
                    MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),nbRows+1:nbRows+numel(TForR)) = num2cell(squeeze(nanmedian(trials(tr).extract(exType).values{1}(idx_time,:,ch))))';
                end
            end
            
            index_tr= index_tr+NLine_trial;
            
        end        
    end
    index= index+NLine_patient;
end

end

