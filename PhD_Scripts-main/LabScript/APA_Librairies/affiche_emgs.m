function f  = affiche_emgs(listes_acqs)
%% Fonction d'affichage des données EMG (EMG) dans une nouvelle interface f
global  h_RTA h_RSOL h_LTA h_LSOL list_emg b1 Activation_EMG_percycle
% listes_acqs = fieldnames(EMG);

% Création de l'interface de visu
f = figure('Name','Visualisation EMGs','tag','visu_emg','handlevisibility','on');
b = uiextras.HBox( 'Parent', f);
b1 = uiextras.VBox( 'Parent', b);
b2 = uiextras.VBox( 'Parent', b);

%Ajout de la liste des acquisitions ayant de l'EMG
list_emg = uicontrol( 'Style', 'listbox', 'Parent', b2, 'String', listes_acqs,'Callback',@listEMG_Callback);
uicontrol( 'Style', 'pushbutton', 'Parent', b2, 'String', 'Editer/Recharger EMG','Callback',@editEMG_Callback);
uicontrol( 'Style', 'pushbutton', 'Parent', b2, 'String', 'Tibial Antérieur D','Callback',@RTA_Callback);
uicontrol( 'Style', 'pushbutton', 'Parent', b2, 'String', 'Soléaire D','Callback',@RSOL_Callback);
uicontrol( 'Style', 'pushbutton', 'Parent', b2, 'String', 'Tibial Antérieur G','Callback',@LTA_Callback);
uicontrol( 'Style', 'pushbutton', 'Parent', b2, 'String', 'Soléaire G','Callback',@LSOL_Callback);
uicontrol( 'Style', 'pushbutton', 'Parent', b2,'Tag','Affiche_EMGs_norm','String', 'Calcul/Affiche période(s) d''activations normalisées','Callback',@affiche_activation,'Enable','Off');
uicontrol( 'Style', 'pushbutton', 'Parent', b2,'Tag','Affiche_EMGs_histo','String', 'Calcul histogramme d''activations normalisées','Callback',@affiche_histo,'Enable','Off');
uicontrol( 'Style', 'pushbutton', 'Parent', b2,'Tag','Export_EMGs_activation','String', 'Exporter temps et % d''activations normalisées + iEMG','Callback',@export_emgs,'Enable','Off');

h_RTA = axes( 'Parent', b1,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace','ylim',[-5 5]);
    
h_RSOL = axes( 'Parent', b1,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace','ylim',[-5 5]);
    
h_LTA = axes( 'Parent', b1,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace','ylim',[-5 5]);
    
h_LSOL = axes( 'Parent', b1,'ActivePositionProperty', 'Position','NextPlot','replace','ylim',[-5 5]);

if ~isempty(Activation_EMG_percycle) 
    set(findobj('tag','Affiche_EMGs_histo'),'Enable','On');
    set(findobj('tag','Export_EMGs_activation'),'Enable','On');
end

function listEMG_Callback(hObj,eventEMG,handles)
%% Affichage EMGs
global h_RTA h_LTA h_RSOL h_LSOL EMG list_emg acq_choisie Activation_EMG Corridors_EMG Histogram_EMG Sujet b1 h_marks_T0_emg h_marks_FC1_emg h_marks_FC2_emg h_T0_txt h_FC1_txt h_FC2_txt
        
%Récupération de l'acquisition séléctionnée
try
    contents = cellstr(get(list_emg,'String'));
    acq_choisie = contents{get(list_emg,'Value')};
     
     %Initialisation des plots et marqueurs si Multiplot Off
     axess = findobj('Type','axes','Parent',b1);
     for i=1:length(axess)
         set(axess(i),'NextPlot','replace'); % Multiplot Off
     end
        
     if ~isfield(Corridors_EMG,acq_choisie) && ~isfield(Histogram_EMG,acq_choisie)
         t = Sujet.(acq_choisie).t;         
         if length(t)<length(EMG.(acq_choisie).val) %% Cas ou EMG et données PF non échantillonnés à la même fréquence
             Fs = EMG.(acq_choisie).Fech;
             t = t(1):1/Fs:t(end);
         end
         
         EMGs_filtered = TraitementEMG(EMG.(acq_choisie).val,Fs);
         efface_marqueur_test(h_marks_T0_emg);
         efface_marqueur_test(h_marks_FC1_emg);
         efface_marqueur_test(h_marks_FC2_emg);
         efface_marqueur_test(h_T0_txt);
         efface_marqueur_test(h_FC1_txt);
         efface_marqueur_test(h_FC2_txt);
                  
         plot(h_RTA,t,EMGs_filtered(1:length(t),1),'r'); ylabel(h_RTA,EMG.(acq_choisie).nom(1)); axis(h_RTA,'tight'); %set(h_RTA,'ylim',[-5 5]);
         plot(h_LTA,t,EMGs_filtered(1:length(t),2),'r'); ylabel(h_LTA,EMG.(acq_choisie).nom(2)); axis(h_LTA,'tight'); %set(h_LTA,'ylim',[-5 5]);
         plot(h_RSOL,t,EMGs_filtered(1:length(t),4),'r'); ylabel(h_RSOL,EMG.(acq_choisie).nom(4)); axis(h_RSOL,'tight'); %set(h_RSOL,'ylim',[-5 5]);
         plot(h_LSOL,t,EMGs_filtered(1:length(t),3),'r'); ylabel(h_LSOL,EMG.(acq_choisie).nom(3)); axis(h_LSOL,'tight'); %set(h_LSOL,'ylim',[-5 5]);
         xlabel(h_LSOL,'Temps (sec)');
         try
             if  ~isempty(Activation_EMG.(acq_choisie))
                 set(findobj('tag','Affiche_EMGs_norm'),'Enable','On');
             end
         catch ERrr
             set(findobj('tag','Affiche_EMGs_norm'),'Enable','Off');
         end
        h_marks_T0_emg = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.T0,'-r');
        h_T0_txt = text(Sujet.(acq_choisie).tMarkers.T0,min(EMGs_filtered(:,1))/2,'T0',...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','Right',...
            'FontSize',10,...
            'Parent',h_RTA);
        h_marks_FC1_emg = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.FC1,'-m');
        h_FC1_txt = text(Sujet.(acq_choisie).tMarkers.FC1,min(EMGs_filtered(:,1))/2,'FC1',...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','Right',...
            'FontSize',10,...
            'Parent',h_RTA);
        h_marks_FC2_emg = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.FC2,'-c');
        h_FC2_txt = text(Sujet.(acq_choisie).tMarkers.FC2,min(EMGs_filtered(:,1))/2,'FC2',...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','Right',...
            'FontSize',10,...
            'Parent',h_RTA);
        
     elseif isfield(Corridors_EMG,acq_choisie)
         muscles = fieldnames(Corridors_EMG.(acq_choisie));
         Fs = EMG.(acq_choisie).Fech;
         t = (0:(length(Corridors_EMG.(acq_choisie).(muscles{1}))-1))./Fs;
         stdshade(Corridors_EMG.(acq_choisie).(muscles{1}),0.25,'r',t,0,h_RTA,1.25,1); ylabel(h_RTA,[muscles{1} ' Z-normalisé']); set(h_RTA,'ylim',[-5 5]); axis(h_RTA,'tight');
         stdshade(Corridors_EMG.(acq_choisie).(muscles{2}),0.25,'r',t,0,h_LTA,1.25,1); ylabel(h_LTA,[muscles{2} ' Z-normalisé']); set(h_LTA,'ylim',[-5 5]); axis(h_LTA,'tight');  
         stdshade(Corridors_EMG.(acq_choisie).(muscles{3}),0.25,'r',t,0,h_RSOL,1.25,1); ylabel(h_RSOL,[muscles{3} ' Z-normalisé']); set(h_RSOL,'ylim',[-5 5]); axis(h_RSOL,'tight');
         stdshade(Corridors_EMG.(acq_choisie).(muscles{4}),0.25,'r',t,0,h_LSOL,1.25,1); ylabel(h_LSOL,[muscles{4} ' Z-normalisé']); set(h_LSOL,'ylim',[-5 5]); axis(h_LSOL,'tight');
         
        h_marks_T0_emg = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.T0,'-r');
        h_T0_txt = text(Sujet.(acq_choisie).tMarkers.T0,-4,'T0',...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','Right',...
            'FontSize',10,...
            'Parent',h_RTA);
        h_marks_FC1_emg = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.FC1,'-m');
        h_FC1_txt = text(Sujet.(acq_choisie).tMarkers.FC1,-4,'FC1',...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','Right',...
            'FontSize',10,...
            'Parent',h_RTA);
     else
         muscles = fieldnames(Histogram_EMG.(acq_choisie));
         hist(Histogram_EMG.(acq_choisie).(muscles{1}),(-20:150),'Parent',h_RTA); ylabel(h_RTA,[muscles{1} ' - fréquence']); set(h_RTA,'ylim',[0 20]);
         hist(Histogram_EMG.(acq_choisie).(muscles{2}),(-20:150),'Parent',h_RSOL); ylabel(h_RSOL,[muscles{2} ' - fréquence']); set(h_RSOL,'ylim',[0 20]);
         hist(Histogram_EMG.(acq_choisie).(muscles{3}),(-20:150),'Parent',h_LTA); ylabel(h_LTA,[muscles{3} ' - fréquence']); set(h_LTA,'ylim',[0 20]);
         hist(Histogram_EMG.(acq_choisie).(muscles{4}),(-20:150),'Parent',h_LSOL); ylabel(h_LSOL,[muscles{4} ' - fréquence']); set(h_LSOL,'ylim',[0 20]);
         
         h_marks_T0_emg = affiche_marqueurs(0,'-r');
         h_T0_txt = text(0,2,'T0',...
            'HorizontalAlignment','Left',...
            'FontSize',10,'Color','r',...
            'Parent',h_RTA);
        
        h_marks_FC1_emg = affiche_marqueurs(100,'-c');
        h_FC1_txt = text(100,2,'FC2',...
            'HorizontalAlignment','Left',...
            'FontSize',10,'Color','c',...
            'Parent',h_RTA);
     end
     
catch ERR
    waitfor(warndlg('Fermer et recharger la fenêtre de visu des EMGs!','Redraw EMGs'));
end

function editEMG_Callback(hObj,eventEMG,handles)
%% Remplacer un signal EMG au cas ou la mauvaise chaine a été chargé
global EMG list_emg Subject_data

try
    %Récupération de l'acquisition séléctionnée
    contents = cellstr(get(list_emg,'String'));
    acq_choisie = contents{get(list_emg,'Value')};
    
    %Récupération des canaux
    channels = EMG.(acq_choisie).nom';
    
    %Choix du/des chaines à éliminer
    [bad_emgs,v] = listdlg('PromptString',{'EMG','Choix des canaux à remplacer'},...
    'ListSize',[150 100],...
    'ListString',channels);
    
    %Choix du fichier .c3d source
    try
        [file path] = uigetfile('*.c3d',['Choix fichier c3d source - ' Subject_data.ID '-' acq_choisie]);
    catch NO_data
        msgbox('Entrez les infos du sujet!!');
        [file path] = uigetfile('*.c3d',['Choix fichier c3d source - ' acq_choisie]);
    end
    disp('Lecture du .c3d - Veuillez patienter...');
    DATA_new = lire_donnees_c3d([path file]);
    
    %Extraction des EMGs
    if isfield(DATA_new,'EMG')
        noms = DATA_new.EMG.nom;
        %Choix du/des nouvelles chaines
        [new_emgs,v] = listdlg('PromptString',{['EMG - ' num2str(length(bad_emgs)) ' chaine(s) à remplacer!'],'Séléction des nouveaux canaux'},...
            'ListSize',[200 200],...
            'ListString',noms);
        
        noms = noms(new_emgs);
        
        EMGs = extraire_emgs(DATA_new,noms');
        if max(max(EMGs))<1  %ON applique un gain si les amplitudes sont faibles
            EMGs=EMGs*1e5;
        end
        
        %Filtrage butter [20-500] Hz (recommendations SENIAM)
        EMGs = TraitementEMG(EMGs,DATA_new.EMG.Fech);
        disp('Lecture du .c3d - OK');
        
        %Renommer les chaines
        button = questdlg('Renommer les EMGs ?','Edition EMG','Oui','Non','Non');
        if strcmp(button,'Oui')
            prompt = noms;
            default_params = noms;
            rep = inputdlg(prompt,'Renommer EMGs',1,default_params);
            noms = rep;
        end
        if length(bad_emgs)==length(new_emgs)
            try
                EMG.(acq_choisie).nom(bad_emgs) = noms;
                EMG.(acq_choisie).val(:,bad_emgs) = EMGs;
            catch Err_length
                errordlg('Durées des EMGs non concordantes! - Vérifier que le bon fichier source a été séléctionné!');
                return
            end
        else
            errordlg('Nombre de canaux à remplacer non concordants!!');
            return
        end
    else
        errordlg('Pas de signaux EMGs dans le fichier séléctionné!!');
    end
    listEMG_Callback();
catch ERR
    disp('Arrêt nouveau chargement EMGs!');
end

function RTA_Callback(hObj,eventEMG,handles)
%% Marquer les débuts/fin d'activité
global acq_choisie Activation_EMG

% Demande du nombre de périodes d'activités
try
    p = str2double(cell2mat(inputdlg('Entrez le nombre de periodes d''activitées observées','Initialisation RTA')));


% waitfor(msgbox('Clickez successivement sur les débuts/fin d''activitées successives ','Détection activitée RTA - ON/OFF'));

M = ginput(2*p);
Activation_EMG.(acq_choisie).RTA = reshape(M(:,1),2,p); %Mise en forme [Debut;Fin]x p colonnes
catch ERR
    disp('Arrêt EMG');
end

function LTA_Callback(hObj,eventEMG,handles)
%% Marquer les débuts/fin d'activité
global acq_choisie Activation_EMG

% Demande du nombre de périodes d'activités
try
    p = str2double(cell2mat(inputdlg('Entrez le nombre de periodes d''activitées observées','Initialisation LTA')));

% waitfor(msgbox('Clickez successivement sur les débuts/fin d''activitées successives ','Détection activitée LTA - ON/OFF'));

M = ginput(2*p);
Activation_EMG.(acq_choisie).LTA = reshape(M(:,1),2,p); %Mise en forme [Debut;Fin]x p colonnes
catch ERR
    disp('Arrêt EMG');
end

function RSOL_Callback(hObj,eventEMG,handles)
%% Marquer les débuts/fin d'activité
global acq_choisie Activation_EMG

% Demande du nombre de périodes d'activités
try
    p = str2double(cell2mat(inputdlg('Entrez le nombre de periodes d''activitées observées','Initialisation RSOL')));

% waitfor(msgbox('Clickez successivement sur les débuts/fin d''activitées successives ','Détection activitée RSOL - ON/OFF'));

M = ginput(2*p);
Activation_EMG.(acq_choisie).RSOL = reshape(M(:,1),2,p); %Mise en forme [Debut;Fin]x p colonnes
catch ERR
    disp('Arrêt EMG');
end

function LSOL_Callback(hObj,eventEMG,handles)
%% Marquer les débuts/fin d'activité
global acq_choisie Activation_EMG

% Demande du nombre de périodes d'activités
try
    p = str2double(cell2mat(inputdlg('Entrez le nombre de periodes d''activitées observées','Initialisation LSOL')));
    
% waitfor(msgbox('Clickez successivement sur les débuts/fin d''activitées','Détection activitée LSOL - ON/OFF'));

M = ginput(2*p);
Activation_EMG.(acq_choisie).LSOL = reshape(M(:,1),2,p); %Mise en forme [Debut;Fin]x p colonnes

set(findobj('tag','Affiche_EMGs_norm'),'Enable','On');
catch ERR
    disp('Arrêt EMG');
end

function affiche_activation(hObj,eventEMG,handles)
%% Calcul et Affichage des périodes d'activitées EMG en fonction du % de cycle
global Sujet acq_choisie Activation_EMG Activation_EMG_percycle

colors = {'r:' 'k:' 'b:' 'g:' 'm:' 'c:' 'r*'};

try
%Extraction des marqueurs
marks = fieldnames(Sujet.(acq_choisie).tMarkers);
marks(1)=[];

figure
title(acq_choisie);

for i=1:length(marks)
    eval([marks{i} '=Sujet.(acq_choisie).tMarkers.' marks{i}]);
end

%Calcul des indices de début/fin en % de cycle d'initiation (selon Mann, 1979)
Muscles = fieldnames(Activation_EMG.(acq_choisie));
K = size(Muscles,1);
% set(gca,'xlim',[-10 150],'ylim',[0 K]);    
set(gca,'Ytick',(0:1:K-1),'Yticklabel',Muscles,'Fontsize',12);
xlabel('% Gait initiation cycle');
ylabel('Muscles');

%Affichage périodes d'activations
for i=1:K
    SS = floor(((Activation_EMG.(acq_choisie).(Muscles{i})-T0)/(FC2-T0))*100);
    for j=1:size(SS,2)
        rectangle('Position',[SS(1,j),i-1,SS(2,j)-SS(1,j),0.3],'FaceColor','r','Curvature',0.1); hold on
    end
    Activation_EMG_percycle.(acq_choisie).(Muscles{i}) = SS;
end
axis tight

%Affichage marqueurs temporels
for i=1:length(marks)
    eval([marks{i} '_t=floor(((' marks{i} '-T0)/(FC2-T0))*100)']);
    eval(['afficheX_v2(' marks{i} '_t,colors{i},gca)']); 
end
legend(gca,marks);

catch ERR
    warndlg('Périodes d''activités non définies',acq_choisie);
end

function affiche_histo(hObj,eventEMG,handles)
%% Calcul de l'histogram des activations discrétisés pour un groupe d'acquisitions
global Subject_data list_emg Sujet Activation_EMG Activation_EMG_percycle Histogram_EMG

%Précalcul des activations
button = questdlg('Calcul de toutes les activations prétraités?','Calcul histogramme EMG','Oui','Non','Non');
if strcmp(button,'Oui') % 
    listes_all = fieldnames(Activation_EMG);
    h = waitbar(0,'Calcul Activation Normalisés');
    for a=1:length(listes_all)
        waitbar(a/length(listes_all),h,['Calcul ' listes_all{a}]);
        %Calcul des indices de début/fin en % de cycle d'initiation (selon Mann, 1979)
        Muscles = fieldnames(Activation_EMG.(listes_all{a}));
        K = size(Muscles,1);
        try
            T0 = Sujet.(listes_all{a}).tMarkers.T0;
            FC2 = Sujet.(listes_all{a}).tMarkers.FC2;
        catch Err_suprr
            disp(['Marche supprimée: ' listes_all{a} ', calcul non réalisé!']);
            T0 = NaN;
            FC2 = NaN;
        end
        for i=1:K
            SS = floor(((Activation_EMG.(listes_all{a}).(Muscles{i})-T0)/(FC2-T0))*100);
            Activation_EMG_percycle.(listes_all{a}).(Muscles{i}) = SS;
        end
    end
    close(h);
end
    
%Choix du nom de la moyenne
groupe_acqs = cell2mat(inputdlg('Entrez le nom du groupe d''acquisitions','Calcul histogram activation'));
groupe_acqs = [Subject_data.ID '_Histogramme_' groupe_acqs];

listes_acqs = fieldnames(Activation_EMG_percycle);

%Sélections de l'utilisateur
try
[acqs,v] = listdlg('PromptString',{strcat('Group ',groupe_acqs),'Choix des acquisitions à inclure dans le group'},...
    'ListSize',[300 300],...
    'ListString',listes_acqs);

muscles = fieldnames(Activation_EMG_percycle.(listes_acqs{acqs(1)}));
for m = 1:length(muscles)
    vecteur_activation = [];
    for i = 1:length(acqs)
        try
            vecteur_activation = [vecteur_activation convertir_activations(Activation_EMG_percycle.(listes_acqs{acqs(i)}).(muscles{m}))];
        catch No_same_EMG
            disp(['Attention!! Changements des noms des canaux EMG lors de la session! ' listes_acqs{acqs(i)}]);
        end
%         if m==length(muscles)
%             T0 = Sujet.(listes_acqs{acqs(i)}).tMarkers.T0;
%             FC2 = Sujet.(listes_acqs{acqs(i)}).tMarkers.FC2;
%             dt = 100*1/(FC2 - T0);
%             FO1(i) = (Sujet.(listes_acqs{acqs(i)}).tMarkers.TO - T0)*dt;
%             FC1(i) = (Sujet.(listes_acqs{acqs(i)}).tMarkers.FC1 - T0)*dt;
%             FO2(i) = (Sujet.(listes_acqs{acqs(i)}).tMarkers.FO2 - T0)*dt;
%         end
    end
    
    Histogram_EMG.(groupe_acqs).(muscles{m}) = vecteur_activation;
end

% FO1 = mean(FO1);
% FC1 = mean(FC1);
% FO2 = mean(FO2);

%Affichage
contents = cellstr(get(list_emg,'String'));
set(list_emg,'Value',1);
set(list_emg,'String',[contents;groupe_acqs]);
last = length(contents) + 1;
set(list_emg,'Value',last);
listEMG_Callback();
% affiche_marqueurs(FO1,'-b');
% affiche_marqueurs(FC1,'-g');
% affiche_marqueurs(FO2,'-m');

catch ERR
    disp('Arrêt calcul histogramme');
end

function export_emgs(hObj,eventEMG,handles)
%% Export des % et temps d'activations et iEMG sur excel (une feuille par muscle)
global Subject_data EMG Sujet Resultats Activation_EMG Activation_EMG_percycle

%Initialisation des structures de sorties
Export_RTA ={};
Export_LTA ={};
Export_RSOL ={};
Export_LSOL ={};

iRTA={};
iLTA={};
iRSOL={};
iLSOL={};

Export_RTA_t ={};
Export_LTA_t ={};
Export_RSOL_t ={};
Export_LSOL_t ={};

%Choix du nom du fichier d'export
fichier = cell2mat(inputdlg('Entrez le nom du fichier d''export','Export excel activation',1,{Subject_data.ID}));

%Sélections de l'utilisateur
try
    listes_acqs = fieldnames(Activation_EMG_percycle);
    [acqs,v] = listdlg('PromptString',{strcat('Export ',fichier),'Choix des acquisitions à inclure dans le fichier'},...
        'ListSize',[300 300],...
        'ListString',listes_acqs);
catch Errchoice
    acqs = (1:length(listes_acqs));
end


%Remplissage des structure de sortie
listes_acqs = listes_acqs(acqs);
h = waitbar(0,'Export Activation Normalisés');
for i=1:length(listes_acqs)
    waitbar(i/length(listes_acqs),h,['Export ' listes_acqs{i}]);
    try
        T0 = Sujet.(listes_acqs{i}).tMarkers.T0;
    catch del_acq
        disp(['Acquisition supprimée: ' listes_acqs{i}]);
        T0 = NaN;
    end
    try
        Cote = Resultats.(listes_acqs{i}).Cote;
    catch Err_cote
        Cote = NaN;
    end
    try
        [Export_RTA.(listes_acqs{i}) Export_RTA_t.(listes_acqs{i})] = export_activation(Activation_EMG_percycle.(listes_acqs{i}).RTA,Activation_EMG.(listes_acqs{i}).RTA,T0,Cote,'RTA');
        iRTA.(listes_acqs{i}) = export_iEMG(EMG.(listes_acqs{i}),Activation_EMG.(listes_acqs{i}).RTA,Cote,'RTA');
    catch Err_RTA
        disp(['Missing muscle: RTA - ' listes_acqs{i}]);
        Export_RTA.(listes_acqs{i}) = NaN;
    end
    try
        [Export_LTA.(listes_acqs{i}) Export_LTA_t.(listes_acqs{i})] = export_activation(Activation_EMG_percycle.(listes_acqs{i}).LTA,Activation_EMG.(listes_acqs{i}).LTA,T0,Cote,'LTA');
        iLTA.(listes_acqs{i}) = export_iEMG(EMG.(listes_acqs{i}),Activation_EMG.(listes_acqs{i}).LTA,Cote,'LTA');
    catch Err_LTA
        disp(['Missing muscle: LTA - ' listes_acqs{i}]);
        Export_LTA.(listes_acqs{i}) = NaN;
    end
    try
        [Export_RSOL.(listes_acqs{i}) Export_RSOL_t.(listes_acqs{i})] = export_activation(Activation_EMG_percycle.(listes_acqs{i}).RSOL,Activation_EMG.(listes_acqs{i}).RSOL,T0,Cote,'RSOL');
        iRSOL.(listes_acqs{i}) = export_iEMG(EMG.(listes_acqs{i}),Activation_EMG.(listes_acqs{i}).RSOL,Cote,'RSOL');
    catch Err_RSOL
        disp(['Missing muscle: RSOL - ' listes_acqs{i}]);
        Export_RSOL.(listes_acqs{i}) = NaN;
    end
    try
        [Export_LSOL.(listes_acqs{i}) Export_LSOL_t.(listes_acqs{i})] = export_activation(Activation_EMG_percycle.(listes_acqs{i}).LSOL,Activation_EMG.(listes_acqs{i}).LSOL,T0,Cote,'LSOL');
        iLSOL.(listes_acqs{i}) = export_iEMG(EMG.(listes_acqs{i}),Activation_EMG.(listes_acqs{i}).LSOL,Cote,'LSOL');
    catch Err_LSOL
        disp(['Missing muscle: LSOL - ' listes_acqs{i}]);
        Export_LSOL.(listes_acqs{i}) = NaN;
    end
end

%Ecriture du fichier
waitbar(1,h,'Ecriture du fichier... Veuillez patienter');
ecrireQR_xls(Export_RTA,[fichier '.xls'],'RTA');
ecrireQR_xls(Export_RTA_t,[fichier '.xls'],'RTA_t');
ecrireQR_xls(iRTA,[fichier '.xls'],'iRTA');

ecrireQR_xls(Export_LTA,[fichier '.xls'],'LTA');
ecrireQR_xls(Export_LTA_t,[fichier '.xls'],'LTA_t');
ecrireQR_xls(iLTA,[fichier '.xls'],'iLTA');

ecrireQR_xls(Export_RSOL,[fichier '.xls'],'RSOL');
ecrireQR_xls(Export_RSOL_t,[fichier '.xls'],'RSOL_t');
ecrireQR_xls(iRSOL,[fichier '.xls'],'iRSOL');

ecrireQR_xls(Export_LSOL,[fichier '.xls'],'LSOL');
ecrireQR_xls(Export_LSOL_t,[fichier '.xls'],'LSOL_t');
ecrireQR_xls(iLSOL,[fichier '.xls'],'iLSOL');
close(h);
