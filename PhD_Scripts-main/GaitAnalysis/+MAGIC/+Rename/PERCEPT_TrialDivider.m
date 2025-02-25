
todo_LFP_artefacts = 1 ;
todo_Chop_and_copy = 1 ;  % Bien copier BLEO BLEC et VSK separement

% A importer d'une autre fonction a terme
Old_Vicon_Folder = 'C:\Users\mathieu.yeche\Desktop\Data VICON - Utiliser le lustre\SAi_000a\V1old' ;
Old_LFP_Folder   = '\\l2export\iss02.pf-marche\01_rawdata\01_RawData\02_Donnees_LFP_Brutes\PERCEPT\P04_Percept' ;
New_Vicon_Folder = 'C:\Users\mathieu.yeche\Desktop\Data VICON - Utiliser le lustre\SAi_000a\V1' ;
New_LFP_Folder   = 'C:\Users\mathieu.yeche\Desktop\Data VICON - Utiliser le lustre\SAi_000a\V1' ;
Table_name   = '\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\PERCEPT\PERCEPT_Correspondance.xlsx' ; 





Main_Table = readtable(Table_name) ;
Work_Table = Main_Table(strcmp(Main_Table.toDo,'here'),:) ;


for row = 1:length(Work_Table.toDo)
    if todo_LFP_artefacts || todo_Chop_and_copy
        json_name = fullfile(Old_LFP_Folder, char([ Work_Table.ORIGINALJSONNAME{row} '.json' ]) ) ;
        PERCEPT_data = jsondecode(fileread(json_name));
    end
        
    if todo_LFP_artefacts
        % Copie de json-read , voir toolbox lab analyses pour commentaire
        Fs = PERCEPT_data.BrainSenseTimeDomain(1).SampleRateInHz;
        ArtId = PERCEPT_data.BrainSenseTimeDomain(1).TimeDomainData ;
        Time_stamp = (1:length(PERCEPT_data.BrainSenseTimeDomain(1).TimeDomainData))/Fs ;
        Peaks = [] ;
        LocalMax = max(ArtId(1:length(ArtId)/2)) ; 
        Peaks(1) = Time_stamp(find(ArtId == LocalMax)) ;
        LocalMin = min(ArtId(1:length(ArtId)/2)) ; 
        Peaks(2) = Time_stamp(find(ArtId == LocalMin)) ;
        LocalMax = max(ArtId(length(ArtId)/2:end)) ; 
        Peaks(3) = Time_stamp(find(ArtId == LocalMax)) ;
        LocalMin = min(ArtId(length(ArtId)/2:end)) ; 
        Peaks(4) = Time_stamp(find(ArtId == LocalMin)) ;
        Peaks = sort(Peaks) ;
        %
        disp('A terme, ecrire dans table')
        disp(Peaks)
        clear Fs Peaks ArtId
    end

    if todo_Chop_and_copy
             
            if Work_Table.STARTWINDOW(row) < Work_Table.STARTWINDOW(row)
                error(['debut de l''essai vicon avant les lfp' ])
            end

            %% COPY 
            
            num = num2str(Work_Table.NEWNUM(row)) ;
            while length(num) < 3
                num = ['0' num] ;
            end

            % Vicon
            source      = char(fullfile(Old_Vicon_Folder,Work_Table.ORIGINALVICONNAME(row))) ;
            destination = [char(fullfile(New_Vicon_Folder,Work_Table.NEWVICONNAME(row))) num] ;

            if Work_Table.STARTWINDOW(row) < Work_Table.STARTWINDOW(row)
                error(['debut de l''essai vicon avant les trig lfp' destination])
            end

            copyfile([source '.Trial.enf'],[destination '.Trial.enf'])
            copyfile([source '.xcp']      ,[destination '.xcp'])
            copyfile([source '.x1d']      ,[destination '.x1d'])
            copyfile([source '.x2d']      ,[destination '.x2d'])
            copyfile([source '.c3d']      ,[destination '.c3d'])
            copyfile([source '.history']  ,[destination '.history'])
            copyfile([source '.system']   ,[destination '.system'])

            % LFP
            copyfile(char(fullfile(Old_LFP_Folder, char([ Work_Table.ORIGINALJSONNAME{row} '.json' ] )))  , ...
                     char(fullfile(New_LFP_Folder, char([ Work_Table.NEWLFPNAME{row}   num '.json' ] ))))

            %% CHOP LFP
            
            PERCEPT_data.Vicon_to_LFP_shift = Work_Table.VICONmoinsJSON(row) ;
            PERCEPT_data.filename           = char([ Work_Table.NEWLFPNAME{row} num '.json' ]) ;
            PERCEPT_data.Window_LFPtime = [Work_Table.STARTWINDOW(row)-Work_Table.VICONmoinsJSON(row) , Work_Table.ENDWINDOW(row)-Work_Table.VICONmoinsJSON(row)] ;
            PERCEPT_data.Window_VICONtime = [Work_Table.STARTWINDOW(row)                              , Work_Table.ENDWINDOW(row)                               ] ;
            
            
            jsonTextNew = jsonencode(PERCEPT_data,'PrettyPrint',true);
            file = fopen(fullfile(New_LFP_Folder, char([ Work_Table.NEWLFPNAME{row} num '.json' ])), 'w');
                fprintf(file, '%s', jsonTextNew);
            fclose(file);

            %% CHOP VICON

            h = btkReadAcquisition([destination '.c3d']) ;
            Fvicon = btkGetPointFrequency(h) ;
            btkCropAcquisition(h,Work_Table.STARTWINDOW(row)*Fvicon ,Work_Table.TrialDuration(row)*Fvicon +1)
            % disp([num2str(btkGetFirstFrame(h)) ' to ' num2str(btkGetLastFrame(h))])
            btkWriteAcquisition(h,[destination '.c3d'])
            btkCloseAcquisition(h)

           

    end
end













