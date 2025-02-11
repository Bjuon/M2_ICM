function [MForR] = matrixForR_optim(data, e, type, protocol, art_temp)

global reject_table

if strcmp(type,'TF') || strcmp(type,'meanTF') || strcmp(type,'CO')
    if strcmp(type,'TF') || strcmp(type,'meanTF')
        dat    = [data.extract('TF')];
        exType = 'TF';
    elseif strcmp(type,'CO')
        dat    = [data.extract('CO')];
        exType = 'CO';
    end
    if strcmp(type,'TF') || strcmp(type,'CO')
        TForR = dat{1}.times{1}+(dat{1}.tBlock/2);
        switch e{1}
            case {'T0', 'T0_EMG'}
                win_name = 'APA';
            case {'FO1', 'FC1'}
                win_name = 'exec';
            case {'FO', 'FC'}
                win_name = 'step';
            case {'FOG_S','FOG_E'}
                win_name = 'FOG';
            case {'TURN_S', 'TURN_E'}
                win_name = 'turn';
            case 'BSL'
                win_name = 'bsl';
        end
    elseif strcmp(type,'meanTF')
        TForR = 0;
        switch e{1}
            case {'T0', 'T0_EMG', 'FO1', 'FC1', 'FO', 'FC'}
                win = [0  0.3];
            case {'FOG_S','TURN_S'}
                win = [0  0.5];
            case {'FOG_E', 'TURN_E'}
                win = [-0.3  0];
            case 'BSL'
                win = [0.4  0.9];
        end
        idx_time = dat{1}.times{1}+(dat{1}.tBlock/2) >= win(1) & dat{1}.times{1}+(dat{1}.tBlock/2) <= win(2);
    end
elseif strcmp(type,'PE')
    dat    = [data.extract('PE')];
    exType = 'PE';
    TForR  = dat{1}.times{1}; %+(dat{1}.tBlock/2);  
elseif strcmp(type,'FqBdes')  
    dat    = [data.extract('TF')];
    exType = 'FqBdes';
    TForR  = dat{1}.times{1} + (dat{1}.tBlock/2);  
end
% extract artifacts annotation if any
if ~isempty(art_temp)
    Art_events = art_temp.find('eventType', 'metadata.event.Artifact');
end

MForR{1,1}      = 'Protocol';
MForR{1,2}      = 'Patient'; %'Subject'; 
MForR{1,3}      = 'Medication'; %'MedCondition'; %
MForR{1,4}      = 'Segment'; %'Task'; %
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
MForR{1,16}     = 'Condition'; % ex10

nbRows = size(MForR,2);
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
    
    if strcmp(type,'TF') || strcmp(type,'meanTF') || strcmp(type,'CO')
        %F = trials(1).extract('TF').f;
        F = trials(1).extract(exType).f;
        NLine_patient = sum(cell2mat(Nchannels))*numel(F);
    else
        NLine_patient = sum(cell2mat(Nchannels));
    end
    MForR(index+1:index+NLine_patient ,2)  = Patients(pat);
%     if ~isempty(data(1).info('trial').trial)
%         MForR(index+1:index+NLine_patient ,1)  = {data(1).info('trial').trial(1:5)};
%     end
    
    index_tr = index;
    for tr = 1:Ntrial
        if strcmp(type,'TF') || strcmp(type,'meanTF') || strcmp(type,'CO')
            NLine_trial = Nchannels{tr}*numel(F);
        else
            NLine_trial = Nchannels{tr};
        end
        
        MForR(index_tr+1:index_tr+NLine_trial,1)        = {protocol};
        MForR(index_tr+1:index_tr+NLine_trial,3)        = {trials(tr).info('trial').medication}; %medcondition};
        MForR(index_tr+1:index_tr+NLine_trial,4)        = {trials(tr).info('trial').segment}; %task};
        MForR(index_tr+1:index_tr+NLine_trial,5)        = {trials(tr).info('trial').quality}; %instruction};
        MForR(index_tr+1:index_tr+NLine_trial,6)        = {trials(tr).info('trial').isValid}; 
        MForR(index_tr+1:index_tr+NLine_trial,7)        = {trials(tr).info('trial').nTrial};
        MForR(index_tr+1:index_tr+NLine_trial,12)       = {trials(tr).info('trial').run};
        MForR(index_tr+1:index_tr+NLine_trial,13)       = e; %event 
        MForR(index_tr+1:index_tr+NLine_trial,14)       = {trials(tr).info('trial').nStep};
        MForR(index_tr+1:index_tr+NLine_trial,15)       = {trials(tr).info('trial').side};
        MForR(index_tr+1:index_tr+NLine_trial,16)       = {trials(tr).info('trial').condition};
        
        if strcmp(type,'TF') || strcmp(type,'meanTF') || strcmp(type,'CO')
            
            NLine_trial= Nchannels{tr}*numel(F);
            
            for ch=1:numel(Chan{1,tr})
                
                if ~isempty(reject_table)
                    idx_quality = find(strcmp(reject_table.patient, Patients{pat}) & ...
                        strcmp([reject_table.Medication{:}]', trials(tr).info('trial').medication) & ...
                        strcmp([reject_table.nTrial(:)], num2str(trials(tr).info('trial').nTrial)) & ...
                        strcmp([reject_table.Channel{:}]', Chan{1,tr}{ch})  & ...
                        strcmp([reject_table.Segment{:}], win_name) & ...
                        strcmpi([reject_table.Condition(:)]', trials(tr).info('trial').condition(1)) == 1,1);
                    if ~isempty(idx_quality)
                        %reject_table(idx_quality,:)
                        MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),5)    = num2cell(0);
                    end
                end
                
                MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),8)    = {Chan{1,tr}(ch)};
                MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),9)    = {ChRegion{1,tr}(ch)};
                MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),10)   = {ChGp{1,tr}(ch)};
                MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),11)   = num2cell(trials(tr).extract(exType).f);
                if strcmp(type,'TF') || strcmp(type,'PE') || strcmp(type,'CO')
                    MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),nbRows+1:nbRows+numel(TForR)) = num2cell(squeeze(trials(tr).extract(exType).values{1}(:,:,ch)))';
                elseif strcmp(type,'meanTF')
                    MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),nbRows+1:nbRows+numel(TForR)) = num2cell(squeeze(nanmean(trials(tr).extract(exType).values{1}(idx_time,:,ch))))';
                end
                % change quality to 0 if artifacts on channel
                if ~isempty(art_temp) && strcmp(Art_events(tr).type, 'metadata.event.Artifact')
                    if contains(Chan{1,tr}(ch), {Art_events(tr).labels.name})
                        MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),5) = {0};
                    end
                end
            end
            
        else
            
            MForR(index_tr+1:index_tr+NLine_trial,8)  = Chan{1,tr};
            MForR(index_tr+1:index_tr+NLine_trial,9)  = ChRegion{1,tr};
            MForR(index_tr+1:index_tr+NLine_trial,10) = ChGp{1,tr};
            MForR(index_tr+1:index_tr+NLine_trial,11) = {0};
            MForR(index_tr+1:index_tr+NLine_trial,nbRows+1:nbRows+numel(TForR))    = num2cell(trials(tr).extract(exType).values{1})';
            
        end
        
        index_tr= index_tr+NLine_trial;
        
    end
    
    index= index+NLine_patient;
    
end

end

