function [MForR] = matrixForR_optim(data, e, type, protocol)

if strcmp(type,'LFP')
    dat = [data.extract('LFP')];
    TForR = dat{1}.times{1}+(dat{1}.tBlock/2);
end


MForR{1,1}      = 'Protocol';
MForR{1,2}      = 'Patient'; %'Subject'; 
MForR{1,3}      = 'Medication'; %'MedCondition'; %
MForR{1,4}      = 'Condition'; %'Task'; %
MForR{1,5}      = 'task'; %'VGRAPS ou RGRASP'; %
MForR{1,6}      = 'isValid'; % 1 to 4
MForR{1,7}      = 'nTrial'; %nTrial ex 6
MForR{1,8}      = 'Channel'; % ex 7
MForR{1,9}      = 'Region'; %'descrition'; 
MForR{1,10}     = 'grouping'; %'grouping'; %
MForR{1,11}     = 'Freq'; % ex 8
MForR{1,12}     = 'Run'; %run ex 9
MForR{1,13}     = 'Event'; % ex10

nbRows = size(MForR,2);
% MForR(1,9+1:9+numel(TForR)) = cellfun(@num2str, num2cell(TForR), 'UniformOutput', false);
MForR(1,nbRows+1:nbRows+numel(TForR)) = cellfun(@num2str, num2cell(TForR), 'UniformOutput', false);

Patients= unique(linq(data).select(@(x) x.info('trial').patient).toList);

index =1;

for pat=1:length(Patients)
    
    segments_linq = linq(data).where(@(x) strcmp(x.info('trial').patient,Patients(pat)));
    trials        = segments_linq.array;
    
    Ntrial        = length(trials);
    
    Nchannels     = linq(trials.extract(type)).select(@(x) size(x.labels,2)).toList;
    Chan          = linq(trials.extract(type)).select(@(x) {x.labels.name}).toList;
    ChRegion      = linq(trials.extract(type)).select(@(x) {x.labels.description}).toList;
    ChGp          = linq(trials.extract(type)).select(@(x) {x.labels.grouping}).toList;
    
    if strcmp(type,'LFP')
        F= trials(1).extract('LFP').f;
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
        if strcmp(type,'LFP')
            NLine_trial = Nchannels{tr}*numel(F);
        else
            NLine_trial = Nchannels{tr};
        end
        
        MForR(index_tr+1:index_tr+NLine_trial,1)        = {protocol};
        MForR(index_tr+1:index_tr+NLine_trial,3)        = {trials(tr).info('trial').medication}; %medcondition};
        MForR(index_tr+1:index_tr+NLine_trial,4)        = {trials(tr).info('trial').condition}; %task};
        MForR(index_tr+1:index_tr+NLine_trial,5)        = {trials(tr).info('trial').task}; %instruction};
        MForR(index_tr+1:index_tr+NLine_trial,6)        = {trials(tr).info('trial').isValid}; 
        MForR(index_tr+1:index_tr+NLine_trial,7)        = {trials(tr).info('trial').nTrial};
        MForR(index_tr+1:index_tr+NLine_trial,12)       = {trials(tr).info('trial').run};
        MForR(index_tr+1:index_tr+NLine_trial,nbRows)   = e ;
        
        if strcmp(type,'LFP')
            
            NLine_trial= Nchannels{tr}*numel(F);
            
            for ch=1:numel(Chan{1,tr})
                MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),8)    = {Chan{1,tr}(ch)};
                MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),9)    = {ChRegion{1,tr}(ch)};
                MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),10)   = {ChGp{1,tr}(ch)};
                MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),11)   = num2cell(trials(tr).extract(type).f);
                MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),nbRows+1:nbRows+numel(TForR)) = num2cell(squeeze(trials(tr).extract(type).values{1}(:,:,ch)))';
            end
            
        else
            
            MForR(index_tr+1:index_tr+NLine_trial,8)  = Chan{1,tr};
            MForR(index_tr+1:index_tr+NLine_trial,11) = {0};
            MForR(index_tr+1:index_tr+NLine_trial,nbRows+1:nbRows+numel(TForR))    = num2cell(trials(tr).extract(type).values{1})';
            
        end
        
        index_tr= index_tr+NLine_trial;
        
    end
    
    index= index+NLine_patient;
    
end

end

