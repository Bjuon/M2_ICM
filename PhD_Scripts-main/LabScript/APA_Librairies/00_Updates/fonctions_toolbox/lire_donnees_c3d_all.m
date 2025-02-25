function FICH=lire_donnees_c3d_all(nom_c3d);

%  FICH=extraire_donnees(fichier);
%
% Version:     18 (2011)
% Langage:     Matlab    Version: 7.11.0
% Plate-forme: PC
%
%___________________________________________________________________________
%
% Niveau de Validation : ?
%___________________________________________________________________________
%
% Description de la fonction : extrait les données du fichier intitulé
% "fichier" dnas une structure "FICH"
%___________________________________________________________________________
%
% Paramètres d'entrée  :
%
% fichier : string nom du fichier csv exporté à partir de VICON en ASCII
%
% Paramètres de sortie :
%
% FICH : structure a 4 champs : noms, coord, actmec, corners, events et EMG contenant la liste
% des noms de marqueurs, la matrice des coordonnees des marqueurs, la
% matrice des actions mécaniques avec le moment à la surface de la plateforme, les coordonné des coins de 
% la PF, les evenements de cycles si déjà identifiés et la matrice des EMG
%___________________________________________________________________________
%
% Notes : Utilisation des fonctions b-tk
%___________________________________________________________________________
%
% Fichiers, Fonctions ou Sous-Programmes associés
%
% Appelants :
% recherche_points
%
% Appelés : extraire_noms
%___________________________________________________________________________
%
% Mots clefs : extraction de donnees dans un fichier csv, analyse de la
% marche
%___________________________________________________________________________
%
% Exemples d'utilisation de la fonction : (si nécessaire)
%___________________________________________________________________________
%
% Auteurs : C. Villa
% Date de création : 19-10-11
% Créé dans le cadre de : Thèse
% Professeur responsable : F. Lavaste
%_________________________________________________________________________
%
% Laboratoire de Biomécanique LBM
% ENSAM C.E.R. de PARIS                          email: lbm@paris.ensam.fr
% 151, bld de l'Hôpital                          tel:   01.44.24.63.63
% 75013 PARIS                                    fax:   01.44.24.63.66
%___________________________________________________________________________
%
% Toutes copies ou diffusions de cette fonction ne peut être réalisée sans
% l'accord du LBM
%___________________________________________________________________________

%% Read c3d
[h, OrderNotApplicable, StorageNotApplicable] = btkReadAcquisition(nom_c3d);

%% Noms des marqueurs et valeurs

%FICH.noms :noms des marqueurs
[markers, markersInfo, markersResidual] = btkGetMarkers(h);
% FICH.noms=fieldnames(markers)';  %attention au nom du sujet parfois avant le nom du mq
noms_marqueurs = fieldnames(markers);
for ii=1:length(noms_marqueurs)
    if strfind(noms_marqueurs{ii},':')
        emp=strfind(noms_marqueurs{ii},':');
        noms_marqueurs{ii}= noms_marqueurs{ii}(emp+1:end)
    elseif strfind(noms_marqueurs{ii},'_')
        emp=strfind(noms_marqueurs{ii},'_');
        noms_marqueurs{ii}= noms_marqueurs{ii}(emp+1:end);
    end;
end;
FICH.noms=noms_marqueurs;

%FICH.coord : valeurs des marqueurs
FICH.coord = btkGetMarkersValues(h) ;
[l,c]=find(FICH.coord==0);
for kkk=1:length(l)
    FICH.coord(l(kkk),c(kkk))=NaN;
end;

%% Plateformes

[forceplates, forceplatesInfo] = btkGetForcePlatforms(h) ;
%  av = btkGetAnalogsValues(h);
av = btkGetAnalogs(h);
% FICH.actmec : [cop, centre, F, M]
FICH.actmec=[];

nb_plat=length(forceplates);
channels_old = []; % On initialise la liste de stockage des chaines analogiques des PF
channels_pf = [];
if nb_plat~=0
    for j=1:nb_plat
        analog_RPLATEFORME=[];

        channels=fieldnames(forceplates(j,1).channels);
     
        for kk=1:length(channels)
            analog_RPLATEFORME=[analog_RPLATEFORME,av.(channels{kk})];
        end; 
        
        corners_VICON=(forceplates(j,1).corners)';
        origin_RPLATEFORME=(forceplates(j,1).origin)';
        RES=Analog_2_forces_plates(analog_RPLATEFORME,corners_VICON,origin_RPLATEFORME);
        FICH.actmec=[FICH.actmec,double(RES)];
        
        % Modif AMine: On stock tous les noms des signaux PF (à condition que les noms aient les mêmes tailles)
        channels_pf =[channels_old;channels];
        channels_old = channels_pf;
    end
    
    %FICH.corner : coins PFF
    for i=1:1:nb_plat
        FICH.corner (i,:) =[i,forceplates(i,1).corners(:,1)', forceplates(i,1).corners(:,2)',forceplates(i,1).corners(:,3)' ,forceplates(i,1).corners(:,4)'];
    end
    
end

%% Modif AMine pour extraire EMG (et autres signaux analogiques)
channels_all = fieldnames(av);
list_non_pf = ~sum(compare_liste(channels_pf,channels_all),1);
channels_anlg = channels_all(list_non_pf);
[channels_emg channels_anlg]= extraire_emgs_liste(channels_anlg);
cc = 1; cc_a = 1;
if ~isempty(channels_emg) || ~isempty(channels_anlg)
    for e=1:length(channels_all)
        if sum(compare_liste(channels_all(e),channels_emg))
            FICH.EMG.nom(cc) = channels_all(e);
            FICH.EMG.valeurs(:,cc) = av.(cell2mat(channels_all(e)));
            FICH.EMG.Fech = btkGetAnalogFrequency(h);
            cc = cc+1;
        elseif sum(compare_liste(channels_all(e),channels_anlg))
            FICH.ANLG.nom(cc_a) = channels_all(e);
            FICH.ANLG.valeurs(:,cc_a) = av.(cell2mat(channels_all(e)));
            FICH.ANLG.Fech = btkGetAnalogFrequency(h);
            cc_a = cc_a+1;
        end
    end
end

%% Réechantillonage a la plus petite des fréquences (?)
% try
%     tt = size(FICH.actmec,1)/size(FICH.coord,1);
%     %FICH.actmec = FICH.actmec(1:tt:end,:);
%     %FICH.EMG.valeurs=FICH.EMG.valeurs(1:tt:end,:); % Ajout Amine
%     %FICH.EMG.Fech = btkGetPointFrequency(h);
% catch ERR
%     disp('Pas de données vidéos!');
% end

 %% Modif' AMINE pour récupérer les cycles (Noms Events) si existent
srv = btkEmulateC3Dserver();
srv.Open(nom_c3d,3);
nIndex = srv.GetParameterIndex('EVENT', 'USED');
try
    nb_cycle=srv.GetParameterValue(nIndex,0);
% if nIndex~=-1 && nb_cycle>0
    for ii=1:nb_cycle
        nIndex = srv.GetParameterIndex('EVENT', 'LABELS');
        noms_evts{ii}=srv.GetParameterValue(nIndex,ii-1);
        nIndex2 = srv.GetParameterIndex('EVENT', 'CONTEXTS');
        cote{ii}=srv.GetParameterValue(nIndex2,ii-1);
    end

    % Temps events/cycles
    tag=cherche_valeur_dans_C3D(srv,'EVENT','TIMES');
    tag=tag(2:2:end);
    %En cas de fichier croppé dont la 1ère frame n'est pas numerotée à 1
    nIndex_start = srv.GetParameterIndex('TRIAL', 'ACTUAL_START_FIELD');
    start_frame=double(srv.GetParameterValue(nIndex_start,0));
    if start_frame ~=1
        nIndex_freqcam = srv.GetParameterIndex('POINT', 'RATE');
        freq=srv.GetParameterValue(nIndex_freqcam,0);
        decalage=start_frame/freq;
        tag=tag-decalage;
    end
    %% Remise dans l'ordre chronologique
    [tag,IX] = sort(tag);
    FICH.events.noms=noms_evts(IX);
    FICH.events.cote=cote(IX);
    FICH.events.temps=tag;%%
catch Error
%     errordlg([Error.identifier ' - Empty events']);
     disp([Error.identifier ' - Empty events']);
end

%% Angles celon le PLug-In-Gait
Angles = btkGetAngles(h);
if ~isempty(fieldnames(Angles))
    FICH.Angles = Angles;
else
    disp('Pas d''Angles calculés!');
end

end
