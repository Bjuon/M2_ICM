function [Donnes Res] = extraction_dataAPA_Notocord_v3(files,dossier)
%% Effectue l'extraction de fichiers (XX_XX_year_XXX_XX_XX_XX_sessions.mat) pré-traités et stockage des données receuillies du répertoire d'étude (dossier)
% Donnes   = structure contenant par (champ/acquisitions) les données d'intérêts
%       .tMarkers.() = Marqueurs temporels () correspondants aux évenements du pas
%       .t = Vecteur temporel
%       .Fech = Fréquence d'échantillonage (video)
%       .primResultats.() = Résultats préliminaires () du prétraitement sous forme [#occurence/frame, valeur] (1x2)
%                     .Vy_FO1 = vitesse AP du CG lors du FO1
%                     .Vm = vitesse maximale AP du CG (qnd Acc == 0)
%                     .VZmin_APA = vitesse minimale verticale du CG lors des APA
%                     .V1 = vitesse minimale verticale du CG lors de l'éxecution du pas
%                     .V2 = vitesse verticale du CG lors du FC1 (Foot-Contact du pied oscillant)
%                     .VML_abs = valeur absolue de la vitesse moyenne médiolatérale
%                     .minAPAy_AP = déplacement postérieur max lors des APA
%                     .APAy_ML = valeur absolue du déplacement latéral max lors des APA

%       .CP_AP = Déplacement antéropostérieur du CP sur la durée du vecteur temporel
%       .CP_ML = Déplacement médiolatéral du CP sur la durée du vecteur temporel
%       .V_CG_AP = Vitesse antéropostérieur du CG (obtenue par intégration) sur la durée du vecteur temporel
%       .V_CG_ML = Vitesse médiolatérale du CG (obtenue par intégration) sur la durée du vecteur temporel
%       .V_CG_Z = Vitesse verticale du CG (obtenue par intégration) sur la durée du vecteur temporel
%
% EMG     = structure contenant les noms et valeurs des 4 premières entrées analogiques de l'acquisition (EMGs du TA et SOL)

if nargin<2
    dossier = cd;
end

%% Lancement du chargement
Donnes = {};
Res = {};
EMG = {};
wb = waitbar(0);
set(wb,'Name','Please wait... loading data');

%% Cas / selection d'un fichier unique
if iscell(files)
    nb_fich = length(files);
else
    nb_fich = 1;
end

for i = 1:nb_fich
    if nb_fich == 1
        fichier = files;
    else
        fichier = files{i};
    end;
    
    %Lecture du fichier ("_sessions.mat") contenant toutes les acquisitions d'un sujet
    load([dossier '\' fichier]);
    
    %Extraction du Nb d'acquisitions
    nb_acq = length(subject);
    
    for k = 1:nb_acq
        sujet = subject{1,k};
        
        acq = extract_spaces(sujet.filename(1:end-4)); %% acq = [session '_' acq]; ??
        waitbar(k/nb_acq,wb,['Lecture acquisition:' acq]);
    
        %Définition du début et fin de la zone d'intérêt
        Freq_vid = 500; %% Fréquence d'échantillonage de la plateforme sous NOTOCORD (Fixe)
    
        debut = 0; %Instant à partir duquel on veut afficher les signaux (==0 par défaut pour prendre dès l'instant du click)
        ind_debut = floor(debut*Freq_vid)+1;
        
        if length(sujet.V.depl_X)/Freq_vid > sujet.V.T_FC2
            ind_fin = length(sujet.V.depl_X)-5;
        else
            ind_fin = floor(sujet.V.T_FC2*Freq_vid);
        end
    
        t = (ind_debut-1:ind_fin-1)*1/Freq_vid; %% vecteur Temporel (en sec)
        
        %Initialisation du vecteur vitesse
        V_CG_AP = NaN*ones(ind_fin,1);
        V_CG_Z = NaN*ones(ind_fin,1);
        Donnes.(acq).V_CG_ML = NaN*ones(ind_fin,1); % Vitesse du CG ML (intégration)
        
        %Extraction des signaux
        CP_filt = [sujet.V.depl_X(ind_debut:ind_fin) sujet.V.depl_Y(ind_debut:ind_fin)]; %% Déplacement du CP (1:ML, 2:AP) en (mm)
        
        %Extraction des marqueurs temporels d'inititation du pas (en sec)
        Donnes.(acq).tMarkers.TR = debut; %Instant de lancement de l'acquisition ('Marchez!')
        
        Donnes.(acq).tMarkers.T0 = sujet.V.T0;
        Donnes.(acq).tMarkers.HO = sujet.V.T_FO1 - 0.25; % Heel-Off: On prend 0.25 sec avant le Toe-Off au hazard
        Donnes.(acq).tMarkers.TO = sujet.V.T_FO1;
        Donnes.(acq).tMarkers.FC1 = sujet.V.T_FC1;
        Donnes.(acq).tMarkers.FO2 = sujet.V.T_FO2;
        Donnes.(acq).tMarkers.FC2 = sujet.V.T_FC2;
        
        %Extraction des vitesses du CG
        debut_V = floor((sujet.V.T_OnsetACC - debut)*Freq_vid) +1;
        fin_V = round(sujet.V.T_OnsetACC*Freq_vid) +length(sujet.V.Vy)+1;
        
        V_CG_AP(1:fin_V,1) = [zeros(debut_V,1); sujet.V.Vy]; % Vitesse du CG AP (intégration) %On place des 0 jusqu'au OnsetACC
        Donnes.(acq).V_CG_AP = V_CG_AP;
        
        V_CG_Z(1:fin_V) = [zeros(debut_V,1); sujet.V.Vz']; % Vitesse verticale du CG (intégration) %On place des 0 jusqu'au OnsetACC
        Donnes.(acq).V_CG_Z = V_CG_Z;
        
        Donnes.(acq).Acc_Z = sujet.V.acc_z(ind_debut:ind_fin); % Accélération verticale (obtenue grace à la PF)
        
        %Stockage des donnes
        Donnes.(acq).t = t; %Temps
        Donnes.(acq).Fech = Freq_vid; %Fréquence d'échantillonage
        Donnes.(acq).CP_AP = CP_filt(:,2); %Déplacement AP du CP
        Donnes.(acq).CP_ML = CP_filt(:,1); %Déplacement ML du CP
        
        %Stockage des résultats préliminaires extraits directement
        Donnes.(acq).primResultats.Vm = [floor(sujet.t_vymax_real*Freq_vid) sujet.vymax];
         %VZmin_APA
        [Donnes.(acq).primResultats.VZmin_APA(2) Donnes.(acq).primResultats.VZmin_APA(1)] = min(Donnes.(acq).V_CG_Z(1:round(sujet.V.T_FO1*Freq_vid),1));
        
        Donnes.(acq).primResultats.V1 = [floor(sujet.t_vzmin_real*Freq_vid)/1e3 sujet.V.Vz_min_value] ; %%%%
        Donnes.(acq).primResultats.V2 = [floor(sujet.V.T_FC1*Freq_vid) sujet.V.Vz_FC1];
        Donnes.(acq).primResultats.VML_abs = NaN;
        Donnes.(acq).primResultats.Vy_FO1 = [floor(sujet.V.T_FO1*Freq_vid) sujet.vy_FO1];
        
        %Calcul et stockage des APA sur le CP
        [Donnes.(acq).primResultats.minAPAy_AP(2) Donnes.(acq).primResultats.minAPAy_AP(1)] = min(CP_filt(:,2));
        [Donnes.(acq).primResultats.APAy_ML(2) Donnes.(acq).primResultats.APAy_ML(1)] = min(CP_filt(1:round(sujet.V.T_FO1*Freq_vid),1));
        
        Donnes.(acq).primResultats.Largeur_pas = sujet.largeur_pas;
        Donnes.(acq).primResultats.Longueur_pas = sujet.longueur_pas;
        
        %Stockage des résultats finaux dans la variable Res(ultats) celon le tableau proposée par Claire
        tags = extract_tags(acq);
        Res.(acq).Code_patient = tags{1};
        Res.(acq).Initiales = tags{2};
        Res.(acq).Num = tags{4};
        Res.(acq).Groupe = tags{5};
        Res.(acq).Condition = [upper(tags{end}(1)) ' ' tags{6}];
        Res.(acq).Filename = acq;
        Res.(acq).t_OnsetACCy = sujet.V.T_OnsetACC;
        Res.(acq).t_T0_Deplx = sujet.V.T0;
        Res.(acq).t_APAx = sujet.V.T_APAx;
        Res.(acq).t_FO1 = sujet.V.T_FO1;
        Res.(acq).t_Vzmin_real = sujet.t_vzmin_real/1e3; %%%%%%%%%%%
        Res.(acq).t_FC1 = sujet.V.T_FC1;
        Res.(acq).t_Vymax_real = sujet.t_vymax_real;
        Res.(acq).t_FO2 = sujet.V.T_FO2;
        Res.(acq).T_FC2 = sujet.V.T_FC2;
        Res.(acq).Deplx_t0 = sujet.depl_x_to;
        Res.(acq).Deplx_APAx = sujet.depl_x_apax;
        Res.(acq).Deplx_FC1 = sujet.depl_x_fc1;
        Res.(acq).Deply_T0 = sujet.depl_y_to;
        Res.(acq).Deply_APAy = sujet.depl_y_apay;
        Res.(acq).Deply_FO1 = sujet.depl_y_fo1;
        Res.(acq).Deply_FO2 =  sujet.depl_y_fo2;
        Res.(acq).Vy_FO1 = sujet.vy_FO1;
        Res.(acq).Vy_max = sujet.vymax;
        Res.(acq).Vz_min = sujet.vzmin;
        Res.(acq).Vz_FC1 = sujet.vz_FC1;
        
        if sujet.foot_is_right_side
            Res.(acq).Pied = 'Droit';
        else
            Res.(acq).Pied = 'Gauche';
        end
        
        try
            Res.(acq).Mark_Changed = sujet.V.MrkChanged;
        catch ERR
            Res.(acq).Mark_Changed = NaN;
        end
        
        if isfield(sujet.V,'ignore_FC2')
            Res.(acq).IgnoreFC2 = sujet.V.ignore_FC2;
        else
            Res.(acq).IgnoreFC2 = NaN;
        end
        
        if isfield(sujet.V,'bad_baseline')
            Res.(acq).Bad_Baseline = sujet.V.bad_baseline;
        else
            Res.(acq).Bad_Baseline = NaN;
        end
        
        if isfield(sujet.V,'hesitation')
            Res.(acq).Hesitation = sujet.V.hesitation;
        else
            Res.(acq).Hesitation = NaN;
        end
        
        try
            Res.(acq).Manual_Marking = sujet.V.manual_marking;
        catch ERRR
            Res.(acq).Manual_Marking = NaN;
        end
        
        Res.(acq).Tags = sujet.V.Tags;
%         if strcmp(sujet.V.Tags,'KO')
%             KO = KO+1;
%         end
        Res.(acq).Nombre_essais = nb_acq;
%         Res.(acq).Nombe_essaisOK = KO; %%%%%
        
        Res.(acq).Duree_Anticipation = sujet.anticipation;
        Res.(acq).Duree_Execution = sujet.tmps_execution;
        Res.(acq).Duree_1erCycle = sujet.first_cycle;
        Res.(acq).Duree_Initiation = sujet.tmps_initiation;
        Res.(acq).Duree_DbleAppui = sujet.tmps_double_appui;
        Res.(acq).Ratio_Anticipation_Execution = sujet.ratio_anticipation_execution;
        Res.(acq).Ratio_Anticipation_1erCycle = sujet.ratio_anticipation_first_cycle;
        Res.(acq).Ratio_DoubleAppui_1erCycle = sujet.ratio_double_appui_first_cycle;
        
        Res.(acq).APAx = sujet.distance_apax;
        Res.(acq).APAy = sujet.distance_apay;
        Res.(acq).Largeur_pas = sujet.largeur_pas;
        Res.(acq).Longueur_pas = sujet.longueur_pas;
        Res.(acq).VyFO1 = sujet.vy_FO1;
        Res.(acq).Vymax = sujet.vymax;
        Res.(acq).Temps_Freinage = sujet.tmps_freinage;
        Res.(acq).Degre_Freinage = sujet.degre_freinage;
        Res.(acq).Capacite = sujet.capacite;
        Res.(acq).Surface_Triangle = sujet.surface_triangle;
        Res.(acq).Surface_Distance_Moy_Freinage = sujet.dist_moy_frein;
        Res.(acq).MoyFreinage_LongeurPas = sujet.ratio_moy_frein_longueur_pas;
    end
    
end
close(wb);
