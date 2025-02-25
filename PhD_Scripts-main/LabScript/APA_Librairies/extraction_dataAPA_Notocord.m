function [Donnes Res] = extraction_dataAPA_Notocord(files,dossier)
%% Effectue l'extraction de fichiers (.mat) pr�-trait�s et stockage des donn�es receuillies du r�pertoire d'�tude (dossier)
% Donnes   = structure contenant par (champ/acquisitions) les donn�es d'int�r�ts
%       .tMarkers.() = Marqueurs temporels () correspondants aux �venements du pas
%       .t = Vecteur temporel
%       .Fech = Fr�quence d'�chantillonage (video)
%       .primResultats.() = R�sultats pr�liminaires () du pr�traitement sous forme [#occurence/frame, valeur] (1x2)
%                     .Vy_FO1 = vitesse AP du CG lors du FO1
%                     .Vm = vitesse maximale AP du CG (qnd Acc == 0)
%                     .VZmin_APA = vitesse minimale verticale du CG lors des APA
%                     .V1 = vitesse minimale verticale du CG lors de l'�xecution du pas
%                     .V2 = vitesse verticale du CG lors du FC1 (Foot-Contact du pied oscillant)
%                     .VML_abs = valeur absolue de la vitesse moyenne m�diolat�rale
%                     .minAPAy_AP = d�placement post�rieur max lors des APA
%                     .APAy_ML = valeur absolue du d�placement lat�ral max lors des APA

%       .CP_AP = D�placement ant�ropost�rieur du CP sur la dur�e du vecteur temporel
%       .CP_ML = D�placement m�diolat�ral du CP sur la dur�e du vecteur temporel
%       .V_CG_AP = Vitesse ant�ropost�rieur du CG (obtenue par int�gration) sur la dur�e du vecteur temporel
%       .V_CG_ML = Vitesse m�diolat�rale du CG (obtenue par int�gration) sur la dur�e du vecteur temporel
%       .V_CG_Z = Vitesse verticale du CG (obtenue par int�gration) sur la dur�e du vecteur temporel
%
% EMG     = structure contenant les noms et valeurs des 4 premi�res entr�es analogiques de l'acquisition (EMGs du TA et SOL)

if nargin<2
    dossier = cd;
end

%%Extraction du nom du dossier/session courant
[upperPath, session] = fileparts(dossier);

%%Lancement du chargement
Donnes = {};
EMG = {};
wb = waitbar(0);
set(wb,'Name','Please wait... loading data');

%%Cas ou selection d'un fichier unique
if iscell(files)
    nb_acq = length(files);
else
    nb_acq =1;
end

for i = 1:nb_acq
%     if i==1 && ischar(files)
%         acq = [session '_' extract_spaces(files(1:end-4))]; % On nomme chaque acquisition en commencant par le dossier ou elle se trouve
%         fichier = files;
%     else
%         acq = [session '_' extract_spaces(files{i}(1:end-4))];
%         fichier = files{i};
%     end;
    
    %Lecture du fichier
    load(fichier);
    acq = extract_spaces(sujet.filename(1:end-4)); %% acq = [session '_' acq]; ??
    waitbar(i/nb_acq,wb,['Lecture acquisition:' acq]);
    
    %D�finition du d�but et fin de la zone d'int�r�t
    t_decalage = 30; %en ms le temps choisi avant T0 pour avoir une bonne visualisation
    Freq_vid = 500; %% Fr�quence d'�chantillonage de la plateforme sous NOTOCORD (Fixe)
    
    debut = sujet.V.T0 - t_decalage; % On prend 20ms avant, juste pour la visualisation
    fin = sujet.V.T_OnsetACC + length(sujet.V.Vy)*1e3/Freq_vid;
    
    t = (debut*1e-3:1/Freq_vid:fin*1e-3); %% vecteur Temporel (en sec)
    
    ind_debut = floor(debut/2); %% = *Freq_vid/1000
    ind_fin = floor(fin/2);
    
    %Extraction des signaux
    CP_filt = [sujet.V.depl_X(ind_debut:ind_fin) sujet.V.depl_Y(ind_debut:ind_fin)]; %% D�placement du CP (1:ML, 2:AP) en (mm)
    
    %Extraction des marqueurs temporels d'inititation du pas (en sec)
    Donnes.(acq).tMarkers.TR = debut/1e3; %Instant de lancement de l'acquisition ('Marchez!')

    Donnes.(acq).tMarkers.T0 = sujet.V.T0/1e3; 
    Donnes.(acq).tMarkers.HO = (sujet.V.T_FO1 - 250)/1e3; % Heel-Off: On prend 250ms avant le Toe-Off au hazard
    Donnes.(acq).tMarkers.TO = sujet.V.T_FO1/1e3;
    Donnes.(acq).tMarkers.FC1 = sujet.V.T_FC1/1e3;
    Donnes.(acq).tMarkers.FO2 = sujet.V.T_FO2/1e3;
    Donnes.(acq).tMarkers.FC2 = sujet.V.T_FC2/1e3;
    
    %Extraction des vitesses du CG %On place des 0 entre (T0-t_decalage) et T0
     debut_V = sujet.V.T_OnsetACC - debut;
     Donnes.(acq).V_CG_AP = [zeros(floor(debut_V/2)+1,1); sujet.V.Vy]; % Vitesse du CG AP (int�gration)
     Donnes.(acq).V_CG_ML = NaN; % Vitesse du CG ML (int�gration)
     Donnes.(acq).V_CG_Z = [zeros(floor(debut_V/2)+1,1); sujet.V.Vz']; % Vitesse verticale du CG (int�gration)
     Donnes.(acq).Acc_Z = sujet.V.acc_z(ind_debut:ind_fin); % Acc�l�ration verticale (obtenue grace � la PF)

    %Stockage des donnes
    Donnes.(acq).t = t; %Temps
    Donnes.(acq).Fech = Freq_vid; %Fr�quence d'�chantillonage
    Donnes.(acq).CP_AP = CP_filt(:,2); %D�placement AP du CP
    Donnes.(acq).CP_ML = CP_filt(:,1); %D�placement ML du CP
    
    %Stockage des r�sultats pr�liminaires extraits directement
    Donnes.(acq).primResultats.Vm = [floor(sujet.V.T_VyMax/2) sujet.vymax];
    Donnes.(acq).primResultats.VZmin_APA = [NaN NaN]; %% A calculer plus tard
    Donnes.(acq).primResultats.V1 = [floor(sujet.V.T_VzMin/2) sujet.V.Vz_min_value] ;
    Donnes.(acq).primResultats.V2 = [floor(sujet.V.T_FC1/2) sujet.V.Vz_FC1];
    Donnes.(acq).primResultats.VML_abs = NaN;
    Donnes.(acq).primResultats.Vy_FO1 = [floor(sujet.V.T_FO1/2) sujet. ...]; %%%% � remplir
    
    %Calcul et stockage des APA sur le CP
    Donnes.(acq).primResultats.minAPAy_AP(1) = sujet. ...; %% A calcul�?
    Donnes.(acq).primResultats.minAPAy_AP(2) = sujet.distance_apay ; %%% ? ordre de grandeur
    
    Donnes.(acq).primResultats.APAy_ML(1) = sujet. ...; %% A calcul�?
    Donnes.(acq).primResultats.APAy_ML(2) = sujet.distance_apax; %%% ? ordre de grandeur
    
    Donnes.(acq).primResultats.Largeur_pas = sujet. ...;
    Donnes.(acq).primResultats.Longueur_pas = sujet.l_pas; %% A valider plus tard...
    
    %Stockage des r�sultats finaux dans la variable Res
    Resultats.(acq)... %%%%%%
    
    
end
close(wb);
