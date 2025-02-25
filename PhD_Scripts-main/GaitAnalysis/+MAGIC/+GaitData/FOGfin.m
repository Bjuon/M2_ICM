clear all; clc; close all;


filename_listOfFOG = {'ParkPitie_2020_09_17_GAl_MAGIC_POSTOP_OFF_GNG_GAIT_027.c3d','ParkPitie_2020_07_02_GIs_GBMOV_POSTOP_ON_GNG_GAIT_027.c3d','ParkPitie_2020_09_17_GAl_MAGIC_POSTOP_OFF_GNG_GAIT_031.c3d','ParkPitie_2020_09_17_GAl_MAGIC_POSTOP_ON_GNG_GAIT_043.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_01.c3d','ParkPitie_2020_10_21_SAs_MAGIC_POSTOP_OFF_GNG_GAIT_041.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_03.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_06.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_08.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_10.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_12.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_14.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_15.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_16.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_18.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_22.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_24.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_28.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_32.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_38.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_46.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_50.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_51.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_52.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_54.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_55.c3d','GOGAIT_POSTOP_DESJO20_OFF_GNG_57.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_OFF_GNG_GAIT_001.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_OFF_GNG_GAIT_002.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_OFF_GNG_GAIT_003.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_OFF_GNG_GAIT_004.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_OFF_GNG_GAIT_005.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_OFF_GNG_GAIT_006.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_OFF_GNG_GAIT_007.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_ON_GNG_GAIT_006.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_ON_GNG_GAIT_007.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_ON_GNG_GAIT_008.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_ON_GNG_GAIT_057.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_ON_GNG_GAIT_059.c3d','ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_ON_GNG_GAIT_060.c3d','ParkPitie_2020_06_25_ALb_MAGIC_POSTOP_OFF_GNG_GAIT_053.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_001.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_002.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_003.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_004.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_005.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_006.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_007.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_008.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_009.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_010.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_012.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_014.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_015.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_016.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_018.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_022.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_023.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_024.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_026.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_027.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_028.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_031.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_032.c3d','ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_034.c3d','ParkRouen_2020_11_30_GUG_MAGIC_POSTOP_OFF_GNG_GAIT_016.c3d','ParkRouen_2020_11_30_GUG_MAGIC_POSTOP_ON_GNG_GAIT_034.c3d'};
Folder             =  '\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MAGIC\04_Traitement\01_POSTOP_Gait_data_MAGIC-GOGAIT\DATA\' ;
ExitFolder         =  'C:\Users\mathieu.yeche\Desktop\Temporaire' ;


% filename_listOfFOG = {'Test_2020_09_17_GAl_MAGIC_POSTOP_OFF_GNG_GAIT_031.c3d',}
% Folder = 'C:\Users\mathieu.yeche\Desktop\Data VICON - Utiliser le lustre\TestScript\' 
% filename_listOfFOG = {'ParkPitie_2020_10_21_SAs_MAGIC_POSTOP_OFF_GNG_GAIT_041.c3d',}

arretLastSession = 18 ; % NORMALEMENT 0
todo_Reverifier_tous_les_essais = 0 ;
todo_Real_Change     = 1 ;
todo_Save_Plot       = 0 ; % to pdf and no change
todo_Prompt_Changes  = 1 ;
todo_Z_Heel_Position = 1 ; % And not do VASte

if todo_Reverifier_tous_les_essais              % Time consuming donc renvoi à un autre code
    [New_filename_listOfFOG, Folder] = MAGIC.Patients.FOG_List('MAGIC_LFP') ;
    disp(['Original trials, length : ' length(filename_listOfFOG) 'New files, length : ' length(New_filename_listOfFOG) ])
    filename_listOfFOG = New_filename_listOfFOG ;
end

PDF_Plot_Name = fullfile(ExitFolder, ['FOG_a_repreciser_-_' char(datetime('now'), 'dd-MM-uuuu_HH-mm-ss') '.pdf' ]) ;
arretLastSession = arretLastSession + 1 ; 
vicon_started = false ;
def_laf = javax.swing.UIManager.getSystemLookAndFeelClassName;
if ~strcmp(char(def_laf), 'com.sun.java.swing.plaf.windows.WindowsLookAndFeel')
    disp(['Le style par defaut (Windows L&F) n''est pas applique mais remplace par : ' char(def_laf)])
    def_laf = 'com.sun.java.swing.plaf.windows.WindowsLookAndFeel' ;
end
javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.nimbus.NimbusLookAndFeel');
for file_num = arretLastSession:length(filename_listOfFOG) 
        %% Chargement des données
    
    filename = filename_listOfFOG{file_num};
    
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
    Fs = btkGetPointFrequency(h);
    
    [analogs, ~] = btkGetAnalogs(h) ;
    if isfield(analogs,'Voltage_LVAS')
        LVAS = normalize(btkGetAnalog(h, 'Voltage.LVAS'),'range')     ;   % Recupération des EMG, normalisation entre 0 et 1 de chaque tracé et placés verticalment de maniere sequentielle
        RVAS = normalize(btkGetAnalog(h, 'Voltage.RVAS'),'range') + 3 ;
        LSOL = normalize(btkGetAnalog(h, 'Voltage.LSOL'),'range') + 1 ;
        RSOL = normalize(btkGetAnalog(h, 'Voltage.RSOL'),'range') + 4 ;
        RTA  = normalize(btkGetAnalog(h, 'Voltage.RTA' ),'range') + 5 ;
        LTA  = normalize(btkGetAnalog(h, 'Voltage.LTA' ),'range') + 2 ;
    elseif isfield(analogs,'Voltage_EMG_1') && strcmp(Patient, 'GUG')
        LVAS = normalize(btkGetAnalog(h, 'Voltage.EMG 6'),'range')     ;   % Recupération des EMG, normalisation entre 0 et 1 de chaque tracé et placés verticalment de maniere sequentielle
        RVAS = normalize(btkGetAnalog(h, 'Voltage.EMG 5'),'range') + 3 ;
        LSOL = normalize(btkGetAnalog(h, 'Voltage.EMG 4'),'range') + 1 ;
        RSOL = normalize(btkGetAnalog(h, 'Voltage.EMG 3'),'range') + 4 ;
        RTA  = normalize(btkGetAnalog(h, 'Voltage.EMG 1' ),'range') + 5 ;
        LTA  = normalize(btkGetAnalog(h, 'Voltage.EMG 2' ),'range') + 2 ;
    else
        disp(['pas d''EMG corectement nommé' filename])
        disp(analogs)
    end

    if todo_Z_Heel_Position
        All_mks = btkGetMarkers(h);
        All_mks.RHEE(All_mks.RHEE(:, 3) == 0, 3) = NaN ;
        All_mks.LHEE(All_mks.LHEE(:, 3) == 0, 3) = NaN ;
        RHEE = normalize(All_mks.RHEE(:, 3)) *2 + 3;
        LHEE = normalize(All_mks.LHEE(:, 3)) *2    ;
        RHEE(All_mks.RHEE(:, 3) == 0) = NaN ;
        LHEE(All_mks.LHEE(:, 3) == 0) = NaN ;
    end
    
    NbrFOGtotal = length(Ev.General_Start_FOG) ;
    modded = false ;
    Start_FOG_liste_read_only = Ev.General_Start_FOG ;
    End_FOG_liste_read_only = Ev.General_End_FOG ;


    for FogNumber = 1:NbrFOGtotal               % Un essai peut contenir plusieurs FOG

        
        for prompttime = 1 : 999                 % Permet d'ajouter plusieurs evenements de maniere sequentielle
            
            StartFOG = Start_FOG_liste_read_only(FogNumber) * Fa ;        % Ce bloc permet de calculer les limites du plot qui permettront de recaller toutes les valeurs
            End_FOG  = End_FOG_liste_read_only(FogNumber)  * Fa ;
            if End_FOG_liste_read_only(FogNumber) + 1/5 < Times(end) && Start_FOG_liste_read_only(FogNumber) - 1/5 > 0
                LimitST = round(StartFOG - Fa/5) ;                   % Fa/5 = 200ms dans 99% des cas
                LimitET = round(End_FOG  + Fa/5) ;
                EnlargedLimit = true ;
            else
                LimitST = StartFOG ;
                LimitET = End_FOG  ;
                EnlargedLimit = false ;
            end
            deplace_bouton = 0 ;
            size_bouton = 1 ;
%             duration = - Start_FOG_liste_read_only(FogNumber) + End_FOG_liste_read_only(FogNumber) ;
%             if duration > limit_for_redecoupage
%                 too_long = true ;
%                 cycles   = ceil(duration/10) ;
%             end

            %% Visualisation
            
            if todo_Prompt_Changes && size(get(groot,'MonitorPositions'),1) == 1     % Nombre d'écrans, le code est clairement mieux avec 2 ecrans
                 fig = figure('Name', ['Essai n°' num2str(file_num) '/' num2str(length(filename_listOfFOG))  ' - FOG n°' num2str(FogNumber) '/' num2str(NbrFOGtotal) ' : ' filename(1:end-4) ],'NumberTitle','off', 'units', 'centimeters', 'position', [-4 3 70 30]);
            elseif todo_Save_Plot
                 fig = figure('Name', ['Essai n°' num2str(file_num) '/' num2str(length(filename_listOfFOG))  ' - FOG n°' num2str(FogNumber) '/' num2str(NbrFOGtotal) ' : ' filename(1:end-4) ],'NumberTitle','off' , 'unit', 'centimeter', 'position', [24.00 15.60 29.7 21], 'PaperOrientation', 'landscape');
            elseif size(get(groot,'MonitorPositions'),1) == 4
                 fig = figure('Name', ['Essai n°' num2str(file_num) '/' num2str(length(filename_listOfFOG))  ' - FOG n°' num2str(FogNumber) '/' num2str(NbrFOGtotal) ' : ' filename(1:end-4) ],'NumberTitle','off', 'units', 'centimeters', 'position', [-15 34 195 28]);
                 deplace_bouton = 2520 ;
                 size_bouton = 2 ;
            else
                 fig = figure('Name', ['Essai n°' num2str(file_num) '/' num2str(length(filename_listOfFOG))  ' - FOG n°' num2str(FogNumber) '/' num2str(NbrFOGtotal) ' : ' filename(1:end-4) ],'NumberTitle','off', 'units', 'centimeters', 'position', [-5 3 59 24]);
            end
                     plot( LTA(LimitST:LimitET), 'color', '#F6D900' )    % Plotting et labelling des 6 EMG
            hold on, plot( RTA(LimitST:LimitET), 'color', '#18EBF0' )
            hold on, plot(RSOL(LimitST:LimitET), 'color', '#072EEF' )
            hold on, plot(LSOL(LimitST:LimitET), 'color', '#FF0D0D' )
        if todo_Z_Heel_Position
            hold on, plot(Times(round(LimitST/Fa*Fs):round(LimitET/Fa*Fs))*Fa-Times(round(LimitST/Fa*Fs))*Fa,RHEE(round(LimitST/Fa*Fs):round(LimitET/Fa*Fs))-mean(RHEE(round(LimitST/Fa*Fs):round(LimitET/Fa*Fs)))+3.4, 'color', '#00F640' )
            hold on, plot(Times(round(LimitST/Fa*Fs):round(LimitET/Fa*Fs))*Fa-Times(round(LimitST/Fa*Fs))*Fa,LHEE(round(LimitST/Fa*Fs):round(LimitET/Fa*Fs))-mean(LHEE(round(LimitST/Fa*Fs):round(LimitET/Fa*Fs)))+0.4  , 'color', '#F48102' )
            text(10, 0.75, 'LHEE'   ,'FontSize',14,'FontWeight','bold')
            text(10, 3.75, 'RHEE'   ,'FontSize',14,'FontWeight','bold')
        else
            hold on, plot(RVAS(LimitST:LimitET), 'color', '#00F640' )
            hold on, plot(LVAS(LimitST:LimitET), 'color', '#F48102' )
            text(10, 0.75, 'LVAS'   ,'FontSize',14,'FontWeight','bold')
            text(10, 3.75, 'RVAS'   ,'FontSize',14,'FontWeight','bold')
        end
            hold on, plot([StartFOG-LimitST  StartFOG-LimitST]', [zeros(1,1) ones(1,1)*6]'    , 'k', 'LineWidth',2)      % Plot start et End FOG
            hold on, plot([End_FOG-LimitST   End_FOG-LimitST ]', [zeros(1,1) ones(1,1)*6]'    , 'k', 'LineWidth',2)
            %hold on, plot([Detected(:)  Detected(:)]',   [zeros(length(Detected),1)     ones(length(Detected),1)*6]'    , 'm')
            text(10, 1.75, 'LSOL'   ,'FontSize',14,'FontWeight','bold')
            text(10, 2.75, 'LTA'    ,'FontSize',14,'FontWeight','bold')
            text(10, 4.75, 'RSOL'   ,'FontSize',14,'FontWeight','bold')
            text(10, 5.75, 'RTA'    ,'FontSize',14,'FontWeight','bold')
            title([strrep(['Essai n°' num2str(file_num) '/' num2str(length(filename_listOfFOG))  ' - FOG n°' num2str(FogNumber) '/' num2str(NbrFOGtotal) ' : ' filename(1:end-4) ], '_', '-') ])
            if Fa == 1000 
                xlabel('time (millisec)')
            else
                xlabel(['samples (' num2str(Fa) ' Hz)'])
            end
            
            if isfield(Ev,'Left_MidFOG_Start')                            % Ces 2 blocs plottent les "MidFOG"s preexistants 
                General_Mid_FOG_SL = Ev.Left_MidFOG_Start  ;
                General_Mid_FOG_EL = Ev.Left_MidFOG_End    ;
                General_Mid_FOG_SL = General_Mid_FOG_SL([General_Mid_FOG_SL*Fa<LimitET &  General_Mid_FOG_SL*Fa>LimitST])*Fa - LimitST ;
                General_Mid_FOG_EL = General_Mid_FOG_EL([General_Mid_FOG_EL*Fa<LimitET &  General_Mid_FOG_EL*Fa>LimitST])*Fa - LimitST ;
                hold on, plot([General_Mid_FOG_SL(:)  General_Mid_FOG_SL(:)]',   [ones(length(General_Mid_FOG_SL),1)*0     ones(length(General_Mid_FOG_SL),1)*3]' , 'color', '#FF00FF')
                hold on, plot([General_Mid_FOG_EL(:)  General_Mid_FOG_EL(:)]',   [ones(length(General_Mid_FOG_EL),1)*0     ones(length(General_Mid_FOG_EL),1)*3]' , 'color', '#9900CC')
            else
                General_Mid_FOG_SL = [] ;
                General_Mid_FOG_SR = [] ;
            end

            if isfield(Ev,'Right_MidFOG_Start')
                General_Mid_FOG_SR = Ev.Right_MidFOG_Start ;
                General_Mid_FOG_ER = Ev.Right_MidFOG_End   ;
                General_Mid_FOG_SR = General_Mid_FOG_SR([General_Mid_FOG_SR*Fa<LimitET &  General_Mid_FOG_SR*Fa>LimitST])*Fa - LimitST ;
                General_Mid_FOG_ER = General_Mid_FOG_ER([General_Mid_FOG_ER*Fa<LimitET &  General_Mid_FOG_ER*Fa>LimitST])*Fa - LimitST ;  
                hold on, plot([General_Mid_FOG_SR(:)  General_Mid_FOG_SR(:)]',   [ones(length(General_Mid_FOG_SR),1)*3     ones(length(General_Mid_FOG_SR),1)*6]' , 'color', '#FF00FF')
                hold on, plot([General_Mid_FOG_ER(:)  General_Mid_FOG_ER(:)]',   [ones(length(General_Mid_FOG_ER),1)*3     ones(length(General_Mid_FOG_ER),1)*6]' , 'color', '#9900CC')
            end
            
            
           
            if todo_Save_Plot
                exportgraphics(gca,PDF_Plot_Name,'Append',true)
%               saveas(fig, fullfile(ExitFolder, [filename(1:end-4) '_-_FOG_' num2str(FogNumber) '_de_' num2str(NbrFOGtotal) '.pdf' ]), 'pdf')
                close all
                break
            end

            if todo_Prompt_Changes
                breakcycle = false ;

                opts.WindowStyle = 'normal' ;
                opts.Interpreter = 'tex';
                opts.Resize = 'on';

                prompt = uibuttongroup('Visible','off','Position',[0 0 1 .03*mean([1 ,size_bouton])]);              
                % Create three radio buttons in the button group.
                r1 = uicontrol(prompt,'Style', 'pushbutton','String','ChangeStart', 'FontWeight','bold', 'FontSize',8*mean([1 sqrt(size_bouton)]) ,'Position', [200 + deplace_bouton 0 90 20*size_bouton] ,'HandleVisibility','off', 'Callback',{@ChangeStart, todo_Real_Change, h, Fa, LimitST, FogNumber, Start_FOG_liste_read_only});
                r2 = uicontrol(prompt,'Style', 'pushbutton','String','ChangeEnd',   'FontWeight','bold', 'FontSize',8*mean([1 sqrt(size_bouton)]) ,'Position', [300 + deplace_bouton 0 90 20*size_bouton] ,'HandleVisibility','off', 'Callback',{@ChangeEnd, todo_Real_Change, h, Fa, LimitST, FogNumber, End_FOG_liste_read_only});
                r3 = uicontrol(prompt,'Style', 'pushbutton','String','AddMid',      'FontWeight','bold', 'FontSize',8*mean([1 sqrt(size_bouton)]) ,'Position', [400 + deplace_bouton 0 90 20*size_bouton] ,'HandleVisibility','off', 'Callback',{@AddMid, todo_Real_Change, h, Fa, LimitST});
                r4 = uicontrol(prompt,'Style', 'pushbutton','String','DeleteMid',   'FontWeight','bold', 'FontSize',8*mean([1 sqrt(size_bouton)]) ,'Position', [500 + deplace_bouton 0 90 20*size_bouton] ,'HandleVisibility','off', 'Callback',{@DeleteMid, todo_Real_Change, h, Ev, General_Mid_FOG_SL, General_Mid_FOG_SR, StartFOG, opts});
                r5 = uicontrol(prompt,'Style', 'pushbutton','String','DELETE_FOG',  'FontWeight','bold', 'FontSize',8*mean([1 sqrt(size_bouton)]) ,'Position', [1000+ deplace_bouton 0 90 20*size_bouton] ,'HandleVisibility','off', 'Callback',{@DeleteFOG,todo_Real_Change, h, opts, FogNumber, Start_FOG_liste_read_only, End_FOG_liste_read_only},'BackgroundColor',[1 0.7 0.7]);
%                 r6 = uicontrol(prompt,'Style', 'pushbutton','String','Option',    'FontWeight','bold', 'FontSize',8*mean([1 sqrt(size_bouton)]) ,'Position', [600 + deplace_bouton 0 90 20*size_bouton] ,'HandleVisibility','off', 'Callback',@plotButtonPushed);
                r7 = uicontrol(prompt,'Style', 'pushbutton','String','Open_VICON',  'FontWeight','bold', 'FontSize',8*mean([1 sqrt(size_bouton)]) ,'Position', [900 + deplace_bouton 0 90 20*size_bouton] ,'HandleVisibility','off', 'Callback',{@OpenVicon, StartFOG , h, Patient, filename,vicon_started, opts},'BackgroundColor',[0.7 0.7 1]);
                r8 = uicontrol(prompt,'Style', 'pushbutton','String','End',         'FontWeight','bold', 'FontSize',8*mean([1 sqrt(size_bouton)]) ,'Position', [700 + deplace_bouton 0 90 20*size_bouton] ,'HandleVisibility','off', 'Callback',@endoffig,'BackgroundColor',[0.7 1 0.7]);
                % Make the uibuttongroup visible after creating child objects. 
                prompt.Visible = 'on';
                
                uiwait(fig)
                
                close all
                if breakcycle
                    break
                end

            end
        end    % End boucle multi prompt       
        
        if modded && todo_Real_Change      % Sauvegarde dans un dossier fait pour puis exporte les modifications
            copyfile (fullfile(Folder, Patient,filename), fullfile(Folder, 'Modifie_FOG_fin' ,[filename(1:end-4) '-Save-' char(datetime('now'), 'dd-MM-uuuu_HH-mm-ss') '.c3d']) )
            btkWriteAcquisition(h,fullfile(Folder, Patient,filename))
            disp(['Fichier modifié, FOG n°' num2str(FogNumber) '/' num2str(NbrFOGtotal) ' : ' filename(1:end-4)])
        end 
        
    end % end boucle FOG number 

end % end boucle essais

 
javax.swing.UIManager.setLookAndFeel(def_laf);
disp('END')



                function endoffig(src,event)
                    assignin('base','breakcycle',true)
                    close all
                end

                function ChangeStart(src,event, todo_Real_Change, h, Fa, LimitST, FogNumber, Start_FOG_liste_read_only)
                    disp('Cliquer sur le debut veritable')
                    [NewStartValue,~] = ginput(1) ;   %  l'utilisateur clique une fois au niveau qu'il estime etre celui du vrai debut du freezing
                    if todo_Real_Change
                        Ev = btkRemoveEvent(h, 'time', Start_FOG_liste_read_only(FogNumber)) ;                   % Le Start FOG initial est supprimé
                        Ev = btkAppendEvent(h, 'Start_FOG', NewStartValue/Fa + LimitST/Fa, 'General') ;     % Le nouveau Start FOG est crée
                        assignin('base','modded',true)                                                      % Le .c3d sera a exporter
                        Start_FOG_liste_read_only = Ev.General_Start_FOG ;
                        assignin('base','Start_FOG_liste_read_only',Start_FOG_liste_read_only)
                    else 
                        disp(['No real change, New Start : ' num2str(NewStartValue)])                       % Aucune action en mode 'test'
                    end
                    close all
                end

                function AddMid(src,event, todo_Real_Change, h, Fa, LimitST)
                    disp('Cliquer sur le début puis la fin du "MiddleFOG", 2 clics seulement, Bien indiquer le coté (gauche / droite)')
                    [NewMidValue,SideMid] = ginput(2) ;        %  Ici on recupere le niveau temporel de l'evenement mais aussi le coté de l'activité musculaire
                    if SideMid(1) < 3
                        SideMidV = 'Left' ;
                    elseif SideMid(1) > 3
                        SideMidV = 'Right' ;
                    else
                        error('not good side')
                    end
                    if todo_Real_Change
                        Ev = btkAppendEvent(h, 'MidFOG_Start', NewMidValue(1)/Fa + LimitST/Fa, SideMidV) ;   % Les 2 nouveaux evenements sont crées
                        Ev = btkAppendEvent(h, 'MidFOG_End'  , NewMidValue(2)/Fa + LimitST/Fa, SideMidV) ; 
                        assignin('base','modded',true)
                        assignin('base','Ev',Ev)
                    else 
                        disp(['No real change, side ' SideMidV ' start ' num2str(NewMidValue(1)) ' & end ' num2str(NewMidValue(2)) ])
                    end
                    close all
                end
                
                function ChangeEnd(src,event,todo_Real_Change, h, Fa, LimitST, FogNumber, End_FOG_liste_read_only)
                    disp('Cliquer sur la FIN veritable')
                    [NewEndValue,~] = ginput(1) ;
                    if todo_Real_Change
                        Ev = btkRemoveEvent(h, 'time', End_FOG_liste_read_only(FogNumber)) ;
                        Ev = btkAppendEvent(h, 'End_FOG', NewEndValue/Fa + LimitST/Fa, 'General') ;
                        assignin('base','modded',true)
                        End_FOG_liste_read_only = Ev.General_End_FOG ;
                        assignin('base','End_FOG_liste_read_only',End_FOG_liste_read_only)
                    else 
                        disp(['No real change, New End : ' num2str(NewEndValue)])
                    end
                    close all
                end

                function DeleteMid(src,event, todo_Real_Change, h, Ev, General_Mid_FOG_SL, General_Mid_FOG_SR,StartFOG, opts)
                    for i_text_mid = 1:length(General_Mid_FOG_SL) % plotte les numeros des marqueurs a gauche
                        text(General_Mid_FOG_SL(i_text_mid) , 0.15, num2str(i_text_mid) ,'FontSize',16,'FontWeight','bold', Color='b')
                    end
                    for i_text_mid = 1:length(General_Mid_FOG_SR) 
                        text(General_Mid_FOG_SR(i_text_mid) , 5.75, num2str(i_text_mid) ,'FontSize',16,'FontWeight','bold', Color='r')
                    end
                    answ5 = inputdlg({'Donner le numero du couple (start/stop) a supprimer, les details temporels seront donnes en sortie', 'Left OR Right '},'Deleting Middle FOG',[1 40],{'Numero a supprimer', 'Left Right'},opts) ;
                    if ~isempty(answ5)     % On choisi numéro et coté du marqueur a supprimer
                        if ~strcmp(answ5{2}, 'Left') && ~strcmp(answ5{2}, 'Right')
                            SideMidD = inputdlg({' Bien donner "Left" ou "Right" EXACTEMENT'},'Deleting Middle FOG',[1 40],{'Left Right'},opts) ;
                            SideMidD = SideMidD{1} ;
                        else
                            SideMidD = answ5{2} ;
                        end
                        First_num_Left = 1 ;
                        if isfield(Ev, 'Left_MidFOG_Start')
                            while Ev.Left_MidFOG_Start(First_num_Left) < StartFOG
                                First_num_Left = First_num_Left + 1 ;
                            end
                        end
                        First_num_Right = 1 ;
                        if isfield(Ev, 'Right_MidFOG_Start')
                            while Ev.Right_MidFOG_Start(First_num_Right) < StartFOG
                                First_num_Right = First_num_Right + 1 ;
                            end
                        end
                        NumMidDLeft  = str2num(answ5{1}) + First_num_Left  - 1 ;
                        NumMidDRight = str2num(answ5{1}) + First_num_Right - 1 ;
                        if todo_Real_Change
                            Ev = btkRemoveEvent (h, 'time', eval(['Ev.' SideMidD '_MidFOG_Start(NumMidD' SideMidD ')'])) ;   % Supprime les marqueurs
                            Ev = btkRemoveEvent (h, 'time', eval(['Ev.' SideMidD '_MidFOG_End(NumMidD'   SideMidD ')'])) ;   % ici essayer d'enlever les evals... 
                            assignin('base','modded',true)
                            assignin('base','Ev',Ev)
                        else 
                            disp(['No real change, ' SideMidD ' num ' answ5{1} ])
                        end
                    end 
                    close all
                end
                
                function DeleteFOG(src,event,todo_Real_Change, h, opts, FogNumber, Start_FOG_liste_read_only, End_FOG_liste_read_only)
                    
                    answ6 = inputdlg({'Valider la suppression COMPLETE du Freezing & l''abscence de MIDFOGS'},'Delete FOG',[1 10],{'OUI'},opts) ;
                    
                    if todo_Real_Change && ~isempty(answ6) 
                        Ev = btkRemoveEvent(h, 'time', End_FOG_liste_read_only(FogNumber)) ;
                        Ev = btkRemoveEvent(h, 'time', Start_FOG_liste_read_only(FogNumber)) ;
                        assignin('base','modded',true)
                        assignin('base','Ev',Ev)
                    else 
                        disp(['No real change, Fog not deleted : ' num2str(NewEndValue)])
                    end
                    close all
                end

                function OpenVicon(src,event, StartFOG , h, Patient, filename, vicon_started, opts)
                    DiskForVicon = 'Z:\' ;
                    if ~vicon_started
                        StartVicon(DiskForVicon, opts)
                    end
                    vicon = ViconNexus() ;
                    FrameStart = round(StartFOG/1000*btkGetPointFrequency(h)) ;
                    warning('off','MATLAB:msgbox:iconstring')
                    msgbox(['Frame: ' num2str(FrameStart) ],[num2str(FrameStart) ],WindowStyle = 'modal');
                    warning('on','MATLAB:msgbox:iconstring')
                    vicon.OpenTrial([DiskForVicon Patient filesep filename(1:end-4)], 45)
                    close all
                end

                function StartVicon(DiskForVicon, opts)
                    if ~exist([DiskForVicon Patient], 'dir')
                      answ6 = inputdlg({['Monter le disque réseau ' DiskForVicon(1:end-1) ' correspondant au Folder et redemarer vicon']},'Vicon Fermé',[1 40],{'Fait'},opts) ;
                    end
                    
                    % help ViconNexus/OpenTrial
                    try
                        vicon = ViconNexus() ;
                    catch
                        system('"C:\Program Files\Vicon\Nexus2.14\Nexus.exe" &') ;
                        msgbox(['Ouvrir VICON' ],['Ouvrir VICON'],WindowStyle = 'modal');
                        pause(10)
                        try
                            vicon = ViconNexus() ;
                        catch
                            answ6 = inputdlg({'Ouvrir VICON avant, ou se preparer au bug'},'Vicon Fermé',[1 40],{'Ouvert'},opts) ;
                        end
                    end
                    assignin("base","vicon_opened",true)
                end