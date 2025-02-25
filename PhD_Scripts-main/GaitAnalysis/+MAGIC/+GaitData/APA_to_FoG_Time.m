clear all; clc; close all;

Project                          = 'PPN_spon';  % 'MAGIC_LFP'
time_or_space                    = 'space' ; % 'time' or 'space' 
todo_raster                      = true ; % 'global' or 'raster'
todo_Reverifier_tous_les_essais  = 0 ;
todo_Save_Plot                   = 0 ; 
ONdopa_only                      = 0;  
ExitFolder                       = 'C:\Users\mathieu.yeche\Desktop\Temporaire' ;  

disp(Project)
if strcmp(Project, 'MAGIC_LFP')
    %filename_listOfFOG = {'ParkPitie_2020_09_17_GAl_MAGIC_POSTOP_OFF_GNG_GAIT_027.c3d','ParkPitie_2020_07_02_GIs_GBMOV_POSTOP_OFF_GNG_GAIT_027.c3d','ParkPitie_2020_07_02_GIs_GBMOV_POSTOP_OFF_GNG_GAIT_039.c3d','ParkPitie_2020_07_02_GIs_GBMOV_POSTOP_OFF_GNG_GAIT_051.c3d','ParkPitie_2020_09_17_GAl_MAGIC_POSTOP_OFF_GNG_GAIT_031.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_01.c3d','ParkPitie_2020_10_21_SAs_MAGIC_POSTOP_OFF_GNG_GAIT_041.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_03.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_06.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_08.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_10.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_12.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_14.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_15.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_16.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_18.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_22.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_24.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_28.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_32.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_38.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_46.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_50.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_51.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_52.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_54.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_55.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_57.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_001.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_002.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_003.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_004.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_005.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_006.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_007.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_008.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_009.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_010.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_012.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_014.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_015.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_016.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_018.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_022.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_023.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_024.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_026.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_027.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_028.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_031.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_032.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_034.c3d','ParkRouen_2020_11_30_GUG_MAGIC_POSTOP_OFF_GNG_GAIT_016.c3d','ParkPitie_2020_06_25_ALb_MAGIC_POSTOP_OFF_GNG_GAIT_053.c3d','ParkRouen_2020_11_30_GUG_MAGIC_POSTOP_ON_GNG_GAIT_034.c3d'};
    Folder             =  '\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MAGIC\04_Traitement\01_POSTOP_Gait_data_MAGIC-GOGAIT\DATA\' ;
    FolderACC =   '\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MarcheReelle\01_kinematics\data\' ;
    Table = readtable("Z:\DATA\ResAPA_32Pat_forPCA.xlsx") ;
    Table = Table(Table.is_FOG==1,:) ;
    filename_listOfFOG = Table.TrialName' ;
elseif strcmp(Project, 'PPN_spon')
    [~, Folder] = MAGIC.Patients.FOG_List(Project) ;
    % filename_listOfFOG = {'GAITPARK_POSTOP_AVALA08_ON_S_17' ,	'GAITPARK_POSTOP_AVALA08_ON_S_18' ,	'GAITPARK_POSTOP_AVALA08_ON_S_19' ,	'GAITPARK_POSTOP_AVALA08_ON_S_21' ,	'GAITPARK_POSTOP_AVALA08_ON_S_26' ,	'GAITPARK_POSTOP_AVALA08_ON_S_35' ,	'GAITPARK_POSTOP_CHADO01_ON_S_02' ,	'GAITPARK_POSTOP_CHADO01_ON_S_15' ,	'GAITPARK_POSTOP_LESNE03_OFF_S_01' ,	'GAITPARK_POSTOP_LESNE03_OFF_S_02' ,	'GAITPARK_POSTOP_LESNE03_OFF_S_03' ,	'GAITPARK_POSTOP_LESNE03_ON_S_02' ,	'GAITPARK_POSTOP_LESNE03_ON_S_07' ,	'GAITPARK_POSTOP_LESNE03_ON_S_10' ,	'GAITPARK_POSTOP_SOUDA02_OFF_S_08' ,	'GAITPARK_POSTOP_SOUDA02_OFF_S_10' ,	'GAITPARK_POSTOP_SOUDA02_OFF_S_11' ,	'GAITPARK_POSTOP_SOUDA02_OFF_S_14' ,	'GAITPARK_POSTOP_SOUDA02_OFF_S_16' ,	'GAITPARK_POSTOP_SOUDA02_OFF_S_17' ,	'GAITPARK_POSTOP_SOUDA02_OFF_S_18' ,	'GAITPARK_POSTOP_SOUDA02_OFF_S_19' ,	'GAITPARK_POSTOP_SOUDA02_OFF_S_20' ,	'GAITPARK_POSTOP_SOUDA02_ON_S_03' ,	'GAITPARK_POSTOP_AVALA08_ON_S_23' } ;
    Table = readtable("U:\MarcheReelle\00_notes\ResAPA_PPN.xlsx") ;
    Table = Table(Table.is_FOG==1,:) ;
    filename_listOfFOG = Table.TrialName' ;
end

% if todo_Reverifier_tous_les_essais               % Time consuming donc renvoi à un autre code
%     [New_filename_listOfFOG, Folder] = MAGIC.Patients.FOG_List(Project) ;
%     disp(['Original trials, length : ' num2str(length(filename_listOfFOG)) 'New files, length : ' num2str(length(New_filename_listOfFOG)) ])
%     filename_listOfFOG = New_filename_listOfFOG ;
% end

list_FOG_Start = [];
list_FOG_End   = [];
list_FC2_End   = [];
list_FC1_End   = [];
list_nom_essai = {};
list_turn_Start = [];
list_turn_End   = [];
if todo_raster
    Raster = struct() ;
end

for file_num = 1:length(filename_listOfFOG) 
        %% Chargement des données
    
    filename = filename_listOfFOG{file_num};
    
    if ONdopa_only && contains(filename,'ON')
        fprintf(2, [filename ' : Essai ON non inclus \n'])
        continue
    end

    ACCpat = 0 ;
    Split  = strsplit(filename, '_');   % recupere le nom du patient pour acceder au bon dossier
    if strcmp(Split{1},'GOGAIT') || strcmp(Split{1},'GAITPARK')
        Patient = Split{3} ;
    elseif strcmp(Split{1},'ParkPitie') || strcmp(Split{1},'ParkRouen')  || strcmp(Split{1},'Test') 
        Patient = Split{5} ;
    elseif strcmp(Split{1},'GBMOV') 
        Patient = Split{3} ;
        Patient = [Patient(1:2) lower(Patient(4))] ;
        ACCpat = 1 ;
    end
    
    if ACCpat
        files = dir([FolderACC, '*', Patient, '\POSTOP\', '*.c3d']);
        for i = 1:length(files)
            if strcmpi(files(i).name, [filename '.c3d'] )
                filename = files(i).name ;
                fold = files(i).folder   ; 
                break;
            end
        end
        h = btkReadAcquisition(fullfile(fold, filename)); 
    else
        files = dir([Folder, Patient, '\*.c3d']);
        for i = 1:length(files)
            if strcmpi(files(i).name, [filename '.c3d'] )
                filename = files(i).name ;
                fold = files(i).folder   ; 
                break;
            end
        end
        if strcmp(Patient,'FRa')
            filename = [filename '_FStrikes.c3d' ] ;
            fold     = [Folder Patient] ;
        end   
        h = btkReadAcquisition(fullfile(fold, filename)); 
    end
    

    Ev = btkGetEvents(h); % chargement des évènements temporels
    Times  = (0:btkGetLastFrame(h)-btkGetFirstFrame(h))/btkGetPointFrequency(h); % timeline de l'enregistrement
    Fs = btkGetPointFrequency(h);
    AllMks = btkGetMarkers(h); % chargement des marqueurs
        
    

    if isfield(Ev,'General_Start_turn')
        if length(Ev.General_Start_turn) > 1
            fprintf(2, [ '2 start turn !! Erreur essai : ' filename ' \n'])
        end
        Ev.General_Start_Turn = Ev.General_Start_turn(1) ;
    end
    if isfield(Ev,'General_End_turn')
        Ev.General_End_Turn = Ev.General_End_turn(1) ;
    end

    if ~isfield(Ev,'General_Event')
        General_Event = Table.T0(file_num) ;
        if isstring(General_Event) || ischar(General_Event)
            General_Event = str2num(General_Event) ;                                           %#ok<ST2NM> 
        end
    else
        General_Event = Ev.General_Event(1);
    end

    if isfield(Ev,'General_FOG_start')
        Ev.General_Start_FOG = Ev.General_FOG_start ;
        Ev.General_End_FOG   = Ev.General_FOG_end   ;
    end
    if isfield(Ev,'General_Start_FES')
        Ev.General_Start_FOG = Ev.General_Start_FES ;
        Ev.General_End_FOG   = Ev.General_End_FES   ;
    end

    if ~isfield(Ev,'General_End_FOG')
        fprintf(2, [filename ' : pas de FOG marqué \n'])
        continue
    end

    if ~isfield(Ev,'Left_Foot_Strike')
        fprintf(2, [filename ' : passé \n'])
        continue
    end

    if isfield(Ev, 'General_Sart_FOG')
        Ev.General_Start_FOG = Ev.General_Sart_FOG ;
    end
        
    NbrFOGtotal = length(Ev.General_Start_FOG) ;
    
    filename = filename(1:end-4);

    FC1 = min(Ev.Left_Foot_Strike(1), Ev.Right_Foot_Strike(1)) - General_Event;
    FC2 = max(Ev.Left_Foot_Strike(1), Ev.Right_Foot_Strike(1)) - General_Event;
    
    if todo_raster
        loc_ini = func_space(AllMks,2,Fs,General_Event) ;
        Raster = setfield(Raster,filename,struct()) ;
        Raster.(filename).time.FC1 = FC1 ;  % ok General event
        Raster.(filename).time.FC2 = FC2 ;
        Raster.(filename).spac.FC1 = func_space(AllMks,2,Fs,FC1 + General_Event) ;
        Raster.(filename).spac.FC2 = func_space(AllMks,2,Fs,FC2 + General_Event) ;
        Raster.(filename).time.FCx = [] ;
        Raster.(filename).spac.FCx = [] ;
        Raster.(filename).time.FOG_Start = [] ;
        Raster.(filename).time.FOG_End = [] ;
        Raster.(filename).spac.FOG_Start = [] ;
        Raster.(filename).spac.FOG_End = [] ;
        for FCx = 2:length(Ev.Left_Foot_Strike)
            Raster.(filename).time.FCx(end+1) = Ev.Left_Foot_Strike(FCx) - General_Event ;
            Raster.(filename).spac.FCx(end+1) = func_space(AllMks,2,Fs,Ev.Left_Foot_Strike(FCx)) - loc_ini;
        end
        for FCx = 2:length(Ev.Right_Foot_Strike)
            Raster.(filename).time.FCx(end+1) = Ev.Right_Foot_Strike(FCx) - General_Event ;
            Raster.(filename).spac.FCx(end+1) = func_space(AllMks,2,Fs,Ev.Right_Foot_Strike(FCx)) - loc_ini;
        end
        
    end


    
    for FogNumber = 1:NbrFOGtotal               % Un essai peut contenir plusieurs FOG
            if strcmp(time_or_space, 'time')
                 list_FC1_End(end+1) = FC1 ;                                                         %#ok<*SAGROW> 
                list_FC2_End(end+1) = FC2 ;
                list_nom_essai{end+1} = filename ;

                list_FOG_Start(end+1) = Ev.General_Start_FOG(FogNumber) - General_Event ;
                list_FOG_End(end+1)   = Ev.General_End_FOG(FogNumber)   - General_Event ;
            
            
            elseif strcmp(time_or_space, 'space')
                loc_ini = func_space(AllMks,2,Fs,General_Event) ;
                list_FC1_End(end+1) = func_space(AllMks,2,Fs,FC1 + General_Event) - loc_ini  ;                                                         %#ok<*SAGROW> 
                list_FC2_End(end+1) = func_space(AllMks,2,Fs,FC2 + General_Event) - loc_ini  ;
                list_nom_essai{end+1} = filename ;

                list_FOG_Start(end+1) = func_space(AllMks,2,Fs,Ev.General_Start_FOG(FogNumber)) - loc_ini  ; 
                list_FOG_End(end+1)   = func_space(AllMks,2,Fs,Ev.General_End_FOG(FogNumber)  ) - loc_ini  ; 

               if isfield (Ev, 'General_Start_Turn')
                    list_turn_Start(end+1) = func_space(AllMks,2,Fs,Ev.General_Start_Turn)  ; 
                    lengthTurn = 0;
                    for i_time = (Ev.General_Start_Turn:0.02:Ev.General_End_Turn)
                        tmp = func_space(AllMks,2,Fs,i_time) ;
                        if (tmp > lengthTurn)
                            lengthTurn = tmp ;
                        end
                    end
                    MaxTurn    = lengthTurn ;
                    list_turn_End(end+1) = MaxTurn * 2 - func_space(AllMks,2,Fs,Ev.General_End_Turn) ;

                    list_turn_End(end) = list_turn_End(end)     - loc_ini ;
                    list_turn_Start(end) = list_turn_Start(end) - loc_ini ;

                    if (Ev.General_Start_FOG(FogNumber) > Ev.General_End_Turn)
                        list_FOG_Start(end) = MaxTurn * 2 - list_FOG_Start(end) ;
                        list_FOG_End(end)   = MaxTurn * 2 - list_FOG_End(  end) ;
                    end
               else
                     list_turn_Start(end+1) = NaN ;
                     list_turn_End(end+1)   = NaN ;
               end

            end

            if todo_raster
                Raster.(filename).time.FOG_Start(end+1) = Ev.General_Start_FOG(FogNumber) - General_Event ;
                Raster.(filename).time.FOG_End(end+1)   = Ev.General_End_FOG(FogNumber)   - General_Event ;
                Raster.(filename).spac.FOG_Start(end+1) = list_FOG_Start(end)  ;  % Ok  loc ini
                Raster.(filename).spac.FOG_End(end+1)   = list_FOG_End(end)  ; 
            end
    end % end boucle FOG number 

    if todo_raster
        if isnan(list_turn_Start(end))
            Raster.(filename).time.Turn_S = NaN ;
            Raster.(filename).time.Turn_E = NaN ;
            Raster.(filename).spac.Turn_S = NaN ;
            Raster.(filename).spac.Turn_E = NaN ;
        else
            Raster.(filename).spac.Turn_S = list_turn_Start(end) ; % Ok  loc ini
            Raster.(filename).spac.Turn_E = list_turn_End(end) ;
            Raster.(filename).time.Turn_S = Ev.General_Start_Turn - General_Event ;
            Raster.(filename).time.Turn_E = Ev.General_End_Turn   - General_Event ;
            for fcx = 1:length(Raster.(filename).time.FCx)
                if (Raster.(filename).time.FCx(fcx) > Raster.(filename).time.Turn_E)
                    Raster.(filename).spac.FCx(fcx) = 2*MaxTurn - Raster.(filename).spac.FCx(fcx) ;
                end
            end
        end
    end
       
end % end boucle essais

rose = [.7804 .3647 .6667 .05] ;
vert = [.0000 .6078 .6235 .01] ;
figure()
hold on
% Raster plot
for i = 1:length(list_FOG_Start)
    plot([list_FOG_Start(i) list_FOG_End(i)], [0 0], 'Color', rose ,'LineWidth', 8)
    plot([        0         list_FC2_End(i)], [0 0], 'Color', vert ,'LineWidth', 8)
end
ylim([-50 50])


ApaColor = [.0000 .6078 .6235] ;
WalkColor= [1.000 .6078 .6235] ;
TurnColor= [0.700 .7000 .7000] ;
FOGColor = [.7804 .3647 .6667] ;
PointCol = 'k' ;
centrage = 'start' ; % 'return' ou 'start' ou 'st_turn'
ordered  = true ;


if todo_raster
    fieldnam = fieldnames(Raster) ;
    for var = {'time','spac'}
        if ordered
            triallength = zeros(1,length(fieldnam)) ;
            for trial = 1:length(fieldnam)
                triallengthlocal = 0 ;
                triallengthlocal = max(Raster.(fieldnam{trial}).(var{1}).FOG_End) ;
                if (~isempty(Raster.(fieldnam{trial}).(var{1}).FCx))
                    triallengthlocal = max(max(triallengthlocal, Raster.(fieldnam{trial}).(var{1}).FCx)) ;
                end
                if ~isnan(Raster.(fieldnam{trial}).(var{1}).Turn_S)
                    triallengthlocal = max(triallengthlocal, Raster.(fieldnam{trial}).(var{1}).Turn_E) ;
                end
                triallength(trial) = max(triallengthlocal) ;
            end
            [~,order] = sort(triallength, "descend") ;
            fieldnam = fieldnam(order) ;
        end 
        figure()
        hold on
        for trial = 1:length(fieldnam)
            if ~strcmp(centrage,'start')
                if isnan(Raster.(fieldnam{trial}).(var{1}).Turn_S)
                    continue
                else
                    if strcmp(centrage,'st_turn')
                        offset = Raster.(fieldnam{trial}).(var{1}).Turn_S ;
                    elseif strcmp(centrage,'return')
                        offset = Raster.(fieldnam{trial}).(var{1}).Turn_E ;
                    end
                end 
            else
                offset = 0 ;
            end
            
            % APA
            rectangle("Position",[0 - offset, trial-1 ,      Raster.(fieldnam{trial}).(var{1}).FC2  ,    1 ], "FaceColor",ApaColor)
            % Turn 
            if ~isnan(Raster.(fieldnam{trial}).(var{1}).Turn_S)
                rectangle("Position",[Raster.(fieldnam{trial}).(var{1}).Turn_S - offset, trial-1 ,      Raster.(fieldnam{trial}).(var{1}).Turn_E - Raster.(fieldnam{trial}).(var{1}).Turn_S  ,    1 ], "FaceColor",TurnColor)
            end
            % Normal Gait

            % FOG
            for i = 1:length(Raster.(fieldnam{trial}).(var{1}).FOG_Start)
                rectangle("Position",[min(Raster.(fieldnam{trial}).(var{1}).FOG_Start(i),Raster.(fieldnam{trial}).(var{1}).FOG_End(i)) - offset, trial-1 ,      abs(Raster.(fieldnam{trial}).(var{1}).FOG_End(i) - Raster.(fieldnam{trial}).(var{1}).FOG_Start(i))  ,    1 ], "FaceColor",FOGColor)
            end

            % Point
            if (~isempty(Raster.(fieldnam{trial}).(var{1}).FCx))
                plot(Raster.(fieldnam{trial}).(var{1}).FCx - offset, trial-0.5, '.', 'Color', PointCol, 'MarkerSize', 10, 'LineWidth', 3)
            end
            plot(Raster.(fieldnam{trial}).(var{1}).FC1 - offset, trial-0.5, '.', 'Color', PointCol, 'MarkerSize', 10, 'LineWidth', 3)
            plot(Raster.(fieldnam{trial}).(var{1}).FC2 - offset, trial-0.5, '.', 'Color', PointCol, 'MarkerSize', 10, 'LineWidth', 3)
             
        end

    end
end


% Number of step before FOG
if todo_raster
    fieldnam = fieldnames(Raster) ;
        NumberOfStep = zeros(1,length(fieldnam)) ;
        TimingFog    = zeros(1,length(fieldnam)) ;
    for trial = 1:length(fieldnam)
        FogTime = min(Raster.(fieldnam{trial}).time.FOG_Start) ;
        NumStp  = length(Raster.(fieldnam{trial}).time.FCx(Raster.(fieldnam{trial}).time.FCx < FogTime)) ;
        if Raster.(fieldnam{trial}).time.FC1 < FogTime ;    NumStp = NumStp + 1 ;   end
        if Raster.(fieldnam{trial}).time.FC2 < FogTime ;    NumStp = NumStp + 1 ;   end
        NumberOfStep(trial) = NumStp ;
        TimingFog(trial) = FogTime   ;
    end
    disp(['Mean number of step between APA and first FOG : ' num2str(mean(NumberOfStep)) ' +/- ' num2str(std(NumberOfStep))])
    disp(['Mean time           between APA and first FOG : ' num2str(mean(TimingFog)) ' +/- ' num2str(std(TimingFog))])
    NumberOfStep = [] ;
    for trial = 1:length(fieldnam)
        for i = 1:length(Raster.(fieldnam{trial}).time.FOG_Start)
            FogTime = Raster.(fieldnam{trial}).time.FOG_Start(i) ;
            NumStp  = length(Raster.(fieldnam{trial}).time.FCx(Raster.(fieldnam{trial}).time.FCx < FogTime)) ;
            if Raster.(fieldnam{trial}).time.FC1 < FogTime ;    NumStp = NumStp + 1 ;   end
            if Raster.(fieldnam{trial}).time.FC2 < FogTime ;    NumStp = NumStp + 1 ;   end
            NumberOfStep(end+1) = NumStp ;
        end
    end
    disp(['Mean number of step between APA and all the FOG epoch : ' num2str(mean(NumberOfStep)) ' +/- ' num2str(std(NumberOfStep))])
    NumberOfStep = [] ;
    for trial = 1:length(fieldnam)
        FogTime = Raster.(fieldnam{trial}).time.FOG_Start(1) ;
        if isnan(Raster.(fieldnam{trial}).time.Turn_S) || Raster.(fieldnam{trial}).time.Turn_E < FogTime ; continue ; end
        NumStp  = length(Raster.(fieldnam{trial}).time.FCx(Raster.(fieldnam{trial}).time.FCx < FogTime)) ;
        if Raster.(fieldnam{trial}).time.FC1 < FogTime ;    NumStp = NumStp + 1 ;   end
        if Raster.(fieldnam{trial}).time.FC2 < FogTime ;    NumStp = NumStp + 1 ;   end
        NumberOfStep(end+1) = NumStp ;
    end
    disp(['Aller+turn Uniquement : Mean number of step between APA and first FOG : ' num2str(mean(NumberOfStep)) ' +/- ' num2str(std(NumberOfStep))])
    NumberOfStep = [] ;
    for trial = 1:length(fieldnam)
        for i = 1:length(Raster.(fieldnam{trial}).time.FOG_Start)
            FogTime = Raster.(fieldnam{trial}).time.FOG_Start(i) ;
            if isnan(Raster.(fieldnam{trial}).time.Turn_S) || Raster.(fieldnam{trial}).time.Turn_E < FogTime ; continue ; end
            NumStp  = length(Raster.(fieldnam{trial}).time.FCx(Raster.(fieldnam{trial}).time.FCx < FogTime)) ;
            if Raster.(fieldnam{trial}).time.FC1 < FogTime ;    NumStp = NumStp + 1 ;   end
            if Raster.(fieldnam{trial}).time.FC2 < FogTime ;    NumStp = NumStp + 1 ;   end
            NumberOfStep(end+1) = NumStp ;
        end
    end
    disp(['Aller+turn Uniquement : Mean number of step between APA and all the FOG epoch : ' num2str(mean(NumberOfStep)) ' +/- ' num2str(std(NumberOfStep))])
end





function location = func_space(AllMks,Axe,Fs,timepoint)
    fieldnam = fieldnames(AllMks) ;
    location_list = zeros(1,length(fieldnam)) ;
    for  marker = 1:length(fieldnam)
        traj = AllMks.(fieldnam{marker}) ;
        if timepoint*Fs+10 > length(traj)
            location_list(marker) = mean(traj(round(timepoint*Fs-10):length(traj),Axe))/1000 ;
        elseif timepoint*Fs-10 < 1
            location_list(marker) = mean(traj(1:round(timepoint*Fs+10),Axe))/1000 ;
        else
            location_list(marker) = mean(traj(round(timepoint*Fs-10):round(timepoint*Fs+10),Axe))/1000 ;
        end
    end
    location_list = location_list(location_list ~= 0) ;
    location = median(location_list) ;
end
    
 

