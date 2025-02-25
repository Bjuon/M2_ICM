function [Donnes Res] = extraction_dataAPA_Notocord_v2(files,dossier)
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
EMG = {};
wb = waitbar(0);
set(wb,'Name','Please wait... loading data');

%% Cas ou selection d'un fichier unique
nb_fich = size(files,2);

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
        waitbar(i/nb_acq,wb,['Lecture acquisition:' acq]);
    
        %Définition du début et fin de la zone d'intérêt
        t_decalage = 0.03; %en sec le temps choisi avant T0 pour avoir une bonne visualisation
        Freq_vid = 500; %% Fréquence d'échantillonage de la plateforme sous NOTOCORD (Fixe)
    
        debut = sujet.V.T0 - t_decalage; % On prend t_decalage sec avant, juste pour la visualisation
        fin = sujet.V.T_OnsetACC + length(sujet.V.Vy)/Freq_vid;
    
        t = (debut:1/Freq_vid:fin); %% vecteur Temporel (en sec)
    
        ind_debut = floor(debut*Freq_vid);
        ind_fin = floor(fin*Freq_vid);
        
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
        
        %Extraction des vitesses du CG %On place des 0 entre (T0-t_decalage) et T0
        debut_V = sujet.V.T_OnsetACC - debut;
        Donnes.(acq).V_CG_AP = [zeros(floor(debut_V*Freq_vid)+1,1); sujet.V.Vy]; % Vitesse du CG AP (intégration)
        Donnes.(acq).V_CG_ML = NaN; % Vitesse du CG ML (intégration)
        Donnes.(acq).V_CG_Z = [zeros(floor(debut_V*Freq_vid)+1,1); sujet.V.Vz']; % Vitesse verticale du CG (intégration)
        Donnes.(acq).Acc_Z = sujet.V.acc_z(ind_debut:ind_fin); % Accélération verticale (obtenue grace à la PF)
        
        %Stockage des donnes
        Donnes.(acq).t = t; %Temps
        Donnes.(acq).Fech = Freq_vid; %Fréquence d'échantillonage
        Donnes.(acq).CP_AP = CP_filt(:,2); %Déplacement AP du CP
        Donnes.(acq).CP_ML = CP_filt(:,1); %Déplacement ML du CP
        
        %Stockage des résultats préliminaires extraits directement
        Donnes.(acq).primResultats.Vm = [floor(sujet.V.T_VyMax*Freq_vid) sujet.vymax];
         %VZmin_APA
            [Mx Mn] = MaxMin(sujet.V.Vz);
            Donnes.(acq).primResultats.VZmin_APA = [floor(debut_V*Freq_vid)+1 0] + [Mn(1) sujet.V.Vz(Mn(1))];
        
        Donnes.(acq).primResultats.V1 = [floor(sujet.V.T_VzMin*Freq_vid) sujet.V.Vz_min_value] ;
        Donnes.(acq).primResultats.V2 = [floor(sujet.V.T_FC1*Freq_vid) sujet.V.Vz_FC1];
        Donnes.(acq).primResultats.VML_abs = NaN;
        Donnes.(acq).primResultats.Vy_FO1 = [floor(sujet.V.T_FO1*Freq_vid) sujet.vy_FO1];
        
        %Calcul et stockage des APA sur le CP
        [Donnes.(acq).primResultats.minAPAy_AP(2) Donnes.(acq).primResultats.minAPAy_AP(1)] = min(CP_filt(:,2));
        [Donnes.(acq).primResultats.APAy_ML(2) Donnes.(acq).primResultats.APAy_ML(1)] = min(CP_filt(1:round(sujet.V.T_FO1*Freq_vid,1)));
        
        Donnes.(acq).primResultats.Largeur_pas = sujet.largeur_pas;
        Donnes.(acq).primResultats.Longueur_pas = sujet.longueur_pas;
        
        %Stockage des résultats finaux dans la variable Resultats celon le tableau proposée par Claire
        tags = extract_tags(acq);
        Resultats.(acq).Code_patient = tags{1};
        Resultats.(acq).Initiales = tags{2};
        Resultats.(acq).Num = tags{4};
        Resultats.(acq).Groupe = tags{5};
        Resultats.(acq).Condition = [upper(tags{end}(1)) ' ' tags{6}];
        Resultats.(acq).Filename = acq;
        ...
        
    end
    
end
close(wb);
