function matrixForR_optim(csvFile, data, e, type, protocol, Type_Rejet_Artefact, Size_around_event, Acceptable_Artefacted_Sample_In_Window, todoParquet)

    global reject_table %#ok<GVMIS> 
    
    if strcmp(type,'TF') || strcmp(type,'meanTF')
        dat    = [data.extract('TF')];                       %#ok<NBRAK> 
        exType = 'TF';
        if strcmp(type,'TF')
            if size(dat) == [1,1]                            %#ok<BDSCA> 
                disp(['Un seul event dans condition : ' e{1} ' - ' cell2mat(unique(linq(data).select(@(x) x.info('trial').patient).toList)) ])
                TForR = dat.times{1}+(dat.tBlock/2);
            else
                TForR = dat{1}.times{1}+(dat{1}.tBlock/2);
            end
            switch e{1}
                case {'FIX'}
                    win_name = 'BSL_Fix';
                case {'CUE'}
                    win_name = 'CUE';
                case {'WrFIX'}
                    win_name = 'BSL_WrFix';
                case {'WrCUE'}
                    win_name = 'WrCUE';
                case {'T0', 'T0_EMG'}
                    win_name = 'APA';
                case {'FO1', 'FC1'}
                    win_name = 'initiation';
                case {'FO', 'FC'}
                    win_name = 'Marche_Lancee';
                case {'FOG_S','FOG_E'}
                    win_name = 'FOG';
                case {'TURN_S'}
                    win_name = 'Start_Turn';
                case {'TURN_E'}
                    win_name = 'Turn_EndTurn';
                case {'BSL'}
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
                    win_name = 'bsl';
            end
            idx_time = dat{1}.times{1}+(dat{1}.tBlock/2) >= win(1) & dat{1}.times{1}+(dat{1}.tBlock/2) <= win(2);
        end
    elseif strcmp(type,'PE')
        dat    = [data.extract('PE')];                     %#ok<NBRAK> 
        exType = 'PE';
        TForR  = dat{1}.times{1}; %+(dat{1}.tBlock/2);  
    elseif strcmp(type,'FqBdes')  
        dat    = [data.extract('TF')];                     %#ok<NBRAK> 
        exType = 'FqBdes';
        TForR  = dat{1}.times{1} + (dat{1}.tBlock/2);  
    end
    % extract artifacts annotation if any
    
    
    MForR{1,1}      = 'Protocol';
    MForR{1,2}      = 'Patient'; %'Subject'; 
    MForR{1,3}      = 'Medication'; %'MedCondition'; %
    MForR{1,4}      = 'Task'; %'Task'; %
    MForR{1,5}      = 'Condition'; %'Task'; %
    MForR{1,6}      = 'quality'; %'Instruction'; %
    MForR{1,7}      = 'isValid'; % distance to door
    MForR{1,8}      = 'isFOG'; % distance to door
    MForR{1,9}      = 'nTrial'; %nTrial ex 6
    MForR{1,10}     = 'Channel'; % ex 7
    MForR{1,11}     = 'Region'; %'descrition'; 
    MForR{1,12}     = 'grouping'; %'grouping'; %
    MForR{1,13}     = 'Freq'; % ex 8
    MForR{1,14}     = 'Run'; %run ex 9
    MForR{1,15}     = 'Event'; % ex10
    MForR{1,16}     = 'nStep'; %run ex 9
    MForR{1,17}     = 'side'; % ex10
    
    
    nbRows = size(MForR,2);
    % MForR(1,9+1:9+numel(TForR)) = cellfun(@num2str, num2cell(TForR), 'UniformOutput', false);
    MForR(1,nbRows+1:nbRows+numel(TForR)) = cellfun(@num2str, num2cell(TForR), 'UniformOutput', false);
    
    Patients= unique(linq(data).select(@(x) x.info('trial').patient).toList);
    
    index =1;
    
    for pat=1:length(Patients)
        
        ch_artefacte = 0 ;
        ev_artefacte = 0 ;
        ev_good      = 0 ;
    
        if ~isempty(reject_table)
            localrejecttabl = reject_table(strcmp(reject_table.patient, Patients{pat}), :);
            localrejecttabl = localrejecttabl(strcmp([localrejecttabl.Condition{:}], win_name), :);
        else
            localrejecttabl = [] ;
        end
    
        segments_linq = linq(data).where(@(x) strcmp(x.info('trial').patient,Patients(pat)));
        trials        = segments_linq.array;
        
        Ntrial        = length(trials);
        
        Nchannels     = linq(trials.extract(exType)).select(@(x) size(x.labels,2)).toList;
        Chan          = linq(trials.extract(exType)).select(@(x) {x.labels.name}).toList;
        ChRegion      = linq(trials.extract(exType)).select(@(x) {x.labels.description}).toList;
        ChGp          = linq(trials.extract(exType)).select(@(x) {x.labels.grouping}).toList;
        
        if strcmp(type,'TF') || strcmp(type,'meanTF')
            F = trials(1).extract('TF').f;
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
            if strcmp(type,'TF') || strcmp(type,'meanTF')
                NLine_trial = Nchannels{tr}*numel(F);
            else
                NLine_trial = Nchannels{tr};
            end
            
            if isempty(trials(tr).info('trial').isFOG)
                FoGValue = NaN;
            else
                FoGValue = trials(tr).info('trial').isFOG;
            end

            if isempty(trials(tr).info('trial').side)
                sideValue = NaN;
            else
                sideValue = trials(tr).info('trial').side;
            end

            MForR(index_tr+1:index_tr+NLine_trial,1)        = {protocol};
            MForR(index_tr+1:index_tr+NLine_trial,3)        = {trials(tr).info('trial').medication}; %medcondition};
            MForR(index_tr+1:index_tr+NLine_trial,4)        = {trials(tr).info('trial').task}; %task};
            MForR(index_tr+1:index_tr+NLine_trial,5)        = {trials(tr).info('trial').condition}; %task};
            MForR(index_tr+1:index_tr+NLine_trial,6)        = {trials(tr).info('trial').quality}; %instruction};
            MForR(index_tr+1:index_tr+NLine_trial,7)        = {trials(tr).info('trial').isValid}; 
            MForR(index_tr+1:index_tr+NLine_trial,8)        = {FoGValue}; 
            MForR(index_tr+1:index_tr+NLine_trial,9)        = {trials(tr).info('trial').nTrial};
            MForR(index_tr+1:index_tr+NLine_trial,14)       = {trials(tr).info('trial').run};
            MForR(index_tr+1:index_tr+NLine_trial,15)       = e ;%event 
            MForR(index_tr+1:index_tr+NLine_trial,16)       = {trials(tr).info('trial').nStep};
            MForR(index_tr+1:index_tr+NLine_trial,17)       = {sideValue};
            
            if strcmp(type,'TF') || strcmp(type,'meanTF')
                
                NLine_trial= Nchannels{tr}*numel(F);
                flag_event_for_artefact = false;
                
                if ~strcmp(win_name,'bsl')
                    for idx_search = 1:length(trials(1,tr).eventProcess.values{1,1})
                        if strcmp(trials(1,tr).eventProcess.values{1,1}(idx_search,1).name.name, e{1})
                            idx_eventprocess = idx_search ;
                        end
                    end
                end
                
                if strcmp(Type_Rejet_Artefact,'TraceBrut')
                    Encrypted_String = trials(1,tr).eventProcess.values{1,1}(idx_eventprocess,1).description ;
                    Artefact_Score_By_Channel_For_Event = MAGIC.batch.Artefact_in_this_event_per_channel(0, 0, 'decode', 0, Encrypted_String, Size_around_event, Acceptable_Artefacted_Sample_In_Window) ;
                end
                
                for ch=1:numel(Chan{1,tr})
                    idx_quality = {} ;
    
                    if ~isempty(localrejecttabl)
                    idx_quality = find(strcmp(localrejecttabl.patient, Patients{pat}) & ...
                            strcmp([localrejecttabl.Medication{:}]', trials(tr).info('trial').medication) & ...
                            strcmp([localrejecttabl.nTrial{:}]', num2str(trials(tr).info('trial').nTrial)) & (...
                            contains([localrejecttabl.Channel{:}]', Chan{1,tr}{ch}(1))  | ...
                            contains([localrejecttabl.Channel{:}]', Chan{1,tr}{ch}(2)))  & ...
                            contains([localrejecttabl.Channel{:}]', Chan{1,tr}{ch}(end))  & ...
                            strcmp([localrejecttabl.Condition{:}]', win_name) == 1, 1);                    
                    end
    
                    if strcmp(Type_Rejet_Artefact,'TraceBrut') && Artefact_Score_By_Channel_For_Event(ch) == 0
                        idx_quality = {0} ;
                    end
    
                    if strcmp(Type_Rejet_Artefact,'TF')
                         idx_start_art = -1 + find(-Size_around_event + 0 < TForR(:),1,"first") ; % 0 car centre sur event
                         idx_end_art   = +1 + find(+Size_around_event + 0 > TForR(:),1,"last") ; % trouve les 2 bornes temporelles
                         min_freq = 1  ;
                         max_freq = 36 ;
                         v             = trials(1,tr).spectralProcess.values{1, 1}  (idx_start_art:idx_end_art, min_freq:max_freq, ch) ;
                         output        = sum(sum( v )) ;
                         seuil         = Acceptable_Artefacted_Sample_In_Window * size(v,1) * size(v,2) ;
                         if output > seuil
                             idx_quality = {0} ;
                         end
                    end
    
                    if ~isempty(idx_quality)
                            %reject_table(idx_quality,:)
                            MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),6)    = {0};
                            ch_artefacte = ch_artefacte + 1 ;
                            flag_event_for_artefact = true;
                    end
                    
                    MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),10)    = {Chan{1,tr}(ch)};
                    MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),11)    = {ChRegion{1,tr}(ch)};
                    MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),12)    = {ChGp{1,tr}(ch)};
                    MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),13)    = num2cell(trials(tr).extract(exType).f);
                    if strcmp(type,'TF') || strcmp(type,'PE')
                        MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),nbRows+1:nbRows+numel(TForR)) = num2cell(squeeze(trials(tr).extract(exType).values{1}(:,:,ch)))';
                    elseif strcmp(type,'meanTF')
                        MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),nbRows+1:nbRows+numel(TForR)) = num2cell(squeeze(nanmean(trials(tr).extract(exType).values{1}(idx_time,:,ch))))'; %#ok<NANMEAN> 
                    end
                    % change quality to 0 if artifacts on channel
                    if strcmp(Type_Rejet_Artefact,'Old_with_Metadata') && strcmp(Art_events(tr).type, 'metadata.event.Artifact')
                        if contains(Chan{1,tr}(ch), {Art_events(tr).labels.name})
                            MForR(index_tr+1+(ch-1)*numel(F):index_tr+ch*numel(F),6) = {0};
                        end
                    end
    
                end
                if flag_event_for_artefact
                    ev_artefacte = ev_artefacte + 1 ;
                else
                    ev_good = ev_good + 1 ;
                end
            else
                
                MForR(index_tr+1:index_tr+NLine_trial,10)  = Chan{1,tr};
                MForR(index_tr+1:index_tr+NLine_trial,11)  = ChRegion{1,tr};
                MForR(index_tr+1:index_tr+NLine_trial,12) = ChGp{1,tr};
                MForR(index_tr+1:index_tr+NLine_trial,13) = {0};
                MForR(index_tr+1:index_tr+NLine_trial,nbRows+1:nbRows+numel(TForR))    = num2cell(trials(tr).extract(exType).values{1})';
                
            end
            
            index_tr= index_tr+NLine_trial;
            
        end
        
        index= index+NLine_patient;
        
        disp([Patients{pat} '-' e{1} '-' num2str(ev_artefacte+ev_good) 'event-' num2str(Nchannels{1}) 'channel-' num2str(ev_artefacte) 'eventArtefacte-' num2str(ch_artefacte) 'channel*eventArtefacte-' num2str(round(ch_artefacte/(ev_artefacte+ev_good)/Nchannels{1}*100)) '%'  ])
    
    end
    
   
 
    MForR = MForR(vertcat(true, cell2mat(MForR(2:end, 6)) == 1), :) ;

    clearvars -except MForR csvFile todoParquet
    
    if todoParquet ~= 1
        warning('off','stats:dataset:ModifiedVarnames')
        export(cell2dataset(MForR),'File',csvFile); %#ok<CELLDTSET> 
        warning('on','stats:dataset:ModifiedVarnames')
    else
        csvFile = strrep(csvFile, '.csv', '.parquet');
        parquetwrite(csvFile,  cell2table(MForR(2:end,:), 'VariableNames', MForR(1,:)));
    end

end
    
    