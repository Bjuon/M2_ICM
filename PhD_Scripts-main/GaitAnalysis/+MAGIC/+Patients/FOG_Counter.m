clear all; clc; close all;


filename_listOfFOG = {'ParkPitie_2020_09_17_GAl_MAGIC_POSTOP_OFF_GNG_GAIT_027.c3d','ParkPitie_2020_07_02_GIs_GBMOV_POSTOP_ON_GNG_GAIT_027.c3d','ParkPitie_2020_09_17_GAl_MAGIC_POSTOP_OFF_GNG_GAIT_031.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_01.c3d','ParkPitie_2020_10_21_SAs_MAGIC_POSTOP_OFF_GNG_GAIT_041.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_03.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_06.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_08.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_10.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_12.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_14.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_15.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_16.c3d',...
    'GOGAIT_POSTOP_DESJO20_OFF_GNG_18.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_22.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_24.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_28.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_32.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_38.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_46.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_50.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_51.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_52.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_54.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_55.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_57.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_OFF_GNG_GAIT_001.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_OFF_GNG_GAIT_002.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_OFF_GNG_GAIT_003.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_OFF_GNG_GAIT_004.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_OFF_GNG_GAIT_005.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_OFF_GNG_GAIT_006.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_OFF_GNG_GAIT_007.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_ON_GNG_GAIT_006.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_ON_GNG_GAIT_007.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_ON_GNG_GAIT_008.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_ON_GNG_GAIT_057.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_ON_GNG_GAIT_059.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_ON_GNG_GAIT_060.c3d','ParkPitie_2020_06_25_ALb_MAGIC_POSTOP_OFF_GNG_GAIT_053.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_001.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_002.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_003.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_004.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_005.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_006.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_007.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_008.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_009.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_010.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_012.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_014.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_015.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_016.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_018.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_022.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_023.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_024.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_026.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_027.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_028.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_031.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_032.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_034.c3d','ParkRouen_2020_11_30_GUG_MAGIC_POSTOP_OFF_GNG_GAIT_016.c3d','ParkRouen_2020_11_30_GUG_MAGIC_POSTOP_ON_GNG_GAIT_034.c3d'};
Folder             =  '\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MAGIC\04_Traitement\01_POSTOP_Gait_data_MAGIC-GOGAIT\DATA\' ;
ExitFolder         =  'C:\Users\mathieu.yeche\Desktop\Temporaire' ;

fprintf(2, "Verifier la liste des FOG en entrée \n")

listoftimepostAPA = [] ;
listoftimepostAPASTART = [] ;
StructNbrEph = struct() ;
StructNbrEphAllmed = struct() ;
for med = 1:2
    if med == 1
        disp("OFF")
    else
        disp("ON")
    end
    
    nbrepochs = 0 ;
    lengthFogList = [] ;
    
    for file_num = 1:length(filename_listOfFOG) % Boucle num_trial
        
      
        filename = filename_listOfFOG{file_num};
        
        if med == 1 && ~contains(filename,"OFF")
            continue
        end
        if med == 2 && ~contains(filename,"ON")
            continue
        end
    
    
        Split  = strsplit(filename, '_');   % recupere le nom du patient pour acceder au bon dossier
        if strcmp(Split{1},'GOGAIT') || strcmp(Split{1},'GAITPARK')
            Patient = Split{3} ;
        elseif strcmp(Split{1},'ParkPitie') || strcmp(Split{1},'ParkRouen')  || strcmp(Split{1},'Test') 
            Patient = Split{5} ;
        end
    
        h = btkReadAcquisition(fullfile(Folder, Patient, filename)); 
        Fa = btkGetAnalogFrequency(h); % fréquence d'acquisition des EMG
        Ev = btkGetEvents(h); % chargement des évènements temporels
        
        Times  = (0:btkGetLastFrame(h)-btkGetFirstFrame(h))/btkGetPointFrequency(h); % timeline de l'enregistrement
        n  = length(Times);
        
        nbrepochs = nbrepochs + length(Ev.General_Start_FOG) ;
        if isfield(StructNbrEph,[Patient num2str(med)])
            StructNbrEph.([Patient num2str(med)]) = StructNbrEph.([Patient num2str(med)]) + length(Ev.General_Start_FOG) ;
        else
            StructNbrEph = setfield(StructNbrEph,[Patient num2str(med)],length(Ev.General_Start_FOG));
        end

        if isfield(StructNbrEphAllmed,[Patient])
            StructNbrEphAllmed.([Patient ]) = StructNbrEphAllmed.([Patient ]) + length(Ev.General_Start_FOG) ;
        else
            StructNbrEphAllmed = setfield(StructNbrEphAllmed,[Patient ],length(Ev.General_Start_FOG));
        end

        if length(Ev.General_Start_FOG)  == 1 &&  ~strcmp(Patient, 'FRa')
            lengthFogList(end+1) = Ev.General_Start_FOG - Ev.General_End_FOG ;
            listoftimepostAPA(end+1) = Ev.General_Start_FOG + (-Ev.General_Start_FOG + Ev.General_End_FOG)/2 - Ev.General_Event(1);
            listoftimepostAPASTART(end+1) = Ev.General_Start_FOG - Ev.General_Event(1);
        elseif ~strcmp(Patient, 'FRa')
            lengthFogList((end+1):(end+length(Ev.General_Start_FOG))) = Ev.General_Start_FOG - Ev.General_End_FOG ;
            if isfield(Ev,"General_Event")
                listoftimepostAPA((end+1):(end+length(Ev.General_Start_FOG))) = Ev.General_Start_FOG + (-Ev.General_Start_FOG + Ev.General_End_FOG)/2 - Ev.General_Event(1);
                listoftimepostAPASTART((end+1):(end+length(Ev.General_Start_FOG))) = Ev.General_Start_FOG - Ev.General_Event(1);
            end
        end
        
        
        
    end

    disp(['Number of trials : '  num2str(length(filename_listOfFOG)) ])
    disp(['Number of episode : ' num2str(nbrepochs) ])
    disp(['Number of length : ' num2str(length(lengthFogList)) ])
    disp(['Mean duration : ' num2str(mean(lengthFogList)) ' +/- ' num2str(std(lengthFogList)) ])
    disp(['Median duration : ' num2str(median(lengthFogList))  ' interquartile ' num2str(iqr(lengthFogList))  ])
    disp(['Mean time since APA (on+off) : ' num2str(mean(listoftimepostAPA))  '  +/- ' num2str(std(listoftimepostAPA))  ])
    disp(['Median time since APA (on+off) : ' num2str(median(listoftimepostAPA))  ' interquartile ' num2str(iqr(listoftimepostAPA))  ])
    disp(['Mean time from APA to S_FOG (on+off) : ' num2str(mean(listoftimepostAPASTART))  '  +/- ' num2str(std(listoftimepostAPASTART))  ])
    disp(['Median time from APA to S_FOG (on+off) : ' num2str(median(listoftimepostAPASTART))  ' interquartile ' num2str(iqr(listoftimepostAPASTART))  ])
    

end
