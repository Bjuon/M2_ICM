function [Donnees EMG] = pretraitement_dataAPA_v8(files,dossier,b_c)
%% Effectue le pr�-traitement et stockage des donn�es receuillies du r�pertoire d'�tude (dossier)
% b_c : flag pour couper l'acquisition (plateforme uniquement ou toute l'acquisition)
% Donnees.()   = structure contenant par (champ/acquisitions) les donn�es d'int�r�ts (PF+VICON)
% par essai on retrouve les sous-champs correspondants
%       .tMarkers.() = Marqueurs temporels () correspondants aux �venements du pas (valeurs brutes en secondes)
%                 .TR = Signal sonore / GO
%                 .T0 = 1er �v�nement biom�canique (d�but du mouvement)
%                 .HO = Heel-Off ou d�collement du Talon
%                 .TO = Toe-Off ou d�collement de l'orteil du pied oscillant
%                 .FC1 = Foot-Contact ou pos� du talon du pied oscillant
%                 .FO2 = Foot-Off2 ou d�collement de l'orteil du pied d'appui
%                 .FC2 = Foot-Contact2 ou pos� du talon du pied d'appui (Fin du cycle d'initiation)
%                 .FOG = Freezing of Gait [d�but fin] (si il y'en a eut)
%                 .DT = D�but di demi-tour (si enregistr�)
%       .t = Vecteur temporel
%       .Fech = Fr�quence d'�chantillonage analogique (au lieu de video, version 6)
%       .Fech_vid = Fr�quence d'�chantillonage VICON/vid�o (version 6)
%       .primResultats.() = R�sultats pr�liminaires () du pr�traitement sous forme [#occurence/frame valeur] (1x2) (Do et al.)
%                     .Vy_FO1 = vitesse AP du centre de gravit� (CG) lors du FO1
%                     .Vm = vitesse maximale AP du CG (qnd Acc == 0)
%                     .VZmin_APA = vitesse minimale verticale du CG lors des APA
%                     .V1 = vitesse minimale verticale du CG lors de l'�xecution du pas
%                     .V2 = vitesse verticale du CG lors du FC1 (Foot-Contact du pied oscillant)
%                     .VML_abs = valeur absolue de la vitesse moyenne m�diolat�rale
%                     .minAPAy_AP = d�placement post�rieur max lors des APA
%                     .APAy_ML = valeur absolue du d�placement lat�ral max lors des APA
%                     .Largeur_pas = Largeur du 1er pas en mm (1x1)
%                     .Longueur_pas = Longueur du 1er pas en mm (1x1)

%       .CP_AP = [N x 1] D�placement ant�ropost�rieur du centre des pressions (CP) enregistr� sur la plateforme sur la dur�e du vecteur temporel
%       .CP_ML = [N x 1] D�placement m�diolat�ral du CP enregistr� sur la plateforme sur la dur�e du vecteur temporel
%       .V_CG_AP/_d = [N x 1] Vitesse ant�ropost�rieur du CG (obtenue par int�gration des donn�es PF / d�rivation de la position du CG) sur la dur�e du vecteur temporel
%       .V_CG_ML = [N x 1] Vitesse m�diolat�rale du CG (obtenue par int�gration) sur la dur�e du vecteur temporel
%       .V_CG_Z/_d = [N x 1] Vitesse verticale du CG (obtenue par int�gration/d�rivation) sur la dur�e du vecteur temporel
%       .Puissance_CG = [N x 1] Puissance interne globale au CG (Kuo et al. 2005) - Inter-Limb method r�adapt�e car une seule PF
%       .Acc = [N x 1] Acc�leration verticale du CG
%       .Angles.() = Angles articulaires calcul� celon le protocole Plug-In-Gait (si calcul�s) (Davis et al. 1991; Hayes et al. 1996) (version 6 - principalement pour export .lena et analyse multi-modale EEG-Cin�matique)
%              .LHipAngles = [n x 3] angle de l'articulation de la hanche Gauche suivant les 3 plans (1:Sagittal, 2:Frontal, 3:Transversal) �chantillon� � Fech_vid
%              .RHipAngles = [n x 3] angle de l'articulation de la hanche Droite....
%              .(C�t�ArticulationAngles) = [n x3] angle de l'Articulation....
% EMG.()     = structure contenant par (champ/acquisitions) les donn�es EMG sous forme
%    .nom = cellule/liste contenant les noms des muscles enregistr�s (d�faut: 4 premi�res entr�es analogiques de l'acquisition (EMGs du TA et SOL) (%% � reparam�trer si + que 4 EMGs)
%    .val = matrice [N x m] contenant par muscle/colonne (m) les valeurs du signal pour le muscle nom(m)  

if nargin<2
    dossier = cd;
    b_c = 'PF';
end

if nargin<3
    b_c = 'PF';
end


%%Extraction du nom du dossier/session courant
[Parts full] = extract_tags(dossier,filesep);

try
    session = [Parts{end-1} '_' Parts{end}];
catch
    session = Parts{end};
end

%%Lancement du chargement
Donnees = {};
EMG = {};
wb = waitbar(0);
set(wb,'Name','Please wait... loading data');
warning off

%%Cas ou selection d'un fichier unique
if iscell(files)
    nb_acq = length(files);
else
    nb_acq =1;
end

for i = 1:nb_acq
    %     if i==1 && ischar(files)
    %         acq = [extract_spaces(session) '_' extract_spaces(files(1:end-4))]; % On nomme chaque acquisition en commencant par le dossier ou elle se trouve
    %         fichier = files;
    %     else
    %         acq = [extract_spaces(session) '_' extract_spaces(files{i}(1:end-4))];
    %         fichier = files{i};
    %     end;
    %
        
    acq = files{i}(1:end-4);
    fichier = files{i};
    [Tags fich_ier]= extract_tags(fichier);
    waitbar(i/nb_acq,wb,['Lecture fichier:' fich_ier]);
    
    %     if ~isnan(str2double(acq(1)))
    %         acq = ['Trial_' acq];
    %     end
    

    
    %Lecture du fichier
    ext = extract_filetype(fichier);
    switch ext
        case 'c3d'
            disp(['Lecture acquisition: ' acq]);
            DATA = lire_donnees_c3d_all(strcat(dossier,[filesep fichier]));
            h = btkReadAcquisition(strcat(dossier,[filesep fichier]));
            Freq_ana = btkGetAnalogFrequency(h); %% Modif' v6, on conserve les donn�es PF � la fr�quence de base pour export .lena
            Freq_vid = btkGetPointFrequency(h);
            t_all = (0:btkGetAnalogFrameNumber(h)-1)*1/Freq_ana;
            fin = round(find(DATA.actmec(:,9)<70,1,'first'));  %%%% Choix ou on coupe l'acquisition!!! (defaut = PF)
            if isempty(fin) || strcmp(b_c,'Oui')
                fin = length(t_all);
            end
            %Si pas de donn�e vid�o, alors donn�es PF �chantillon�es � la m�me fr�quence que l'EMG
%             if isempty(DATA.coord)
%                 try
%                 Freq_ana = DATA.EMG.Fech;
% 
%                     
%                 end
%             end
        case 'xls'
%             [DATA t] = extrait_notocord_excel(strcat(dossier,['\' fichier]));
%             fin = length(t);
            [DATA t_all fin] = extrait_notocord_excel(strcat(dossier,[filesep fichier]));
            Freq_ana = 500; %Fr�quence d'acquisition NOtocord
        otherwise
            disp('Pas de format support�');
            break
    end
    
    %% Extraction de la GRF sur la PF uniquement
    if fin<10 %% On a des 0 sur les donn�es PF en d�but d'acquisitions
        fin = length(t_all);
    end
    
    Fres = DATA.actmec(1:fin,7:9);
    Loads = DATA.actmec(1:fin,7:12);
    t = t_all(1:fin);
    CP = DATA.actmec(1:fin,1:3);
    CP_filt = NaN*ones(size(CP));
    
    %On retire les NaN avant filtrage
    l = ~isnan(CP(:,1))==1;
    CP_pre = CP(l,:);
    
    %Filtrage des donn�es PF: filtre � r�ponse impulsionnel finie d'ordre 50 et de fr�quence de coupure 45Hz
    CP_post = filtrage(CP_pre,'fir',50,45,Freq_ana); %%%% A changer?
    try
        CP_filt(l,:) = CP_post;
        % On compl�te le vecteur CP par la derni�re valeur lue sur la PF
        CP0 = CP_post(end,:);
        dim_buff = fin-sum(l);
        CP_filt(~l,:) = repmat(CP0,dim_buff,1);
    catch empty_CP
        CP_filt = CP;
    end
    
    %% Extraction des marqueurs temporels d'inititation du pas  
    % Extraction du temps de l'instruction (� partir du FSW) pour le calcul du temps de r�action
    if isfield(DATA,'Analogs')
        signal = extraire_anlg(DATA,{'GO'});
        if isnan(signal)
            signal = extrait_FSW_analog(DATA.Analogs); %% Le trigger est sur un canal nomm� 'FSW'
        end
        
        if ~isnan(signal)
            signal = signal - nanmean(signal);
            try
                TR_ind = find(signal>0.2,1,'first');
                Donnees.(acq).tMarkers.TR = TR_ind/DATA.Analogs.Fech;
                DATA.T_trigs = TR_ind/DATA.Analogs.Fech; % GO = TRigger de synchro LFP
            catch GO_start
                DATA.T_trigs = t(1);
                Donnees.(acq).tMarkers.TR = t(1);
            end
        else
            disp('Pas de go sonore!');
            Donnees.(acq).tMarkers.TR = t(1);
        end
    else
        disp('Pas de go sonore!');
        Donnees.(acq).tMarkers.TR = t(1);
    end
    
    evts_fog = [];
    evts_dt = [];
    try 
        % D�tection T0 + extraction des evts du pas not�s sur Nexus (VICON)
        evts = sort(DATA.events.temps - t(1));
        ind_1 = round((evts(1)-t(1))*Freq_ana); %1er evenment not� manuellement sur le VICON (Heel-Off)
        if ind_1>10 % Cas ou l'acqisition commence tardivement avec l'initiation du pas
            Donnees.(acq).tMarkers.T0 = calcul_APA_T0_v4(CP_filt(1:ind_1,:),t(1:ind_1)) + t(1); % 1er evt biom�canique
        else
            Donnees.(acq).tMarkers.T0 = NaN;
        end
        
        % Gestion des FOG %%% (� rendre plus flexible)
        if sum(compare_liste({'FOG_start'},DATA.events.noms)) || sum(compare_liste({'FOG_end'},DATA.events.noms))% Evts de Freezing
            disp([fichier ': ' num2str(sum(compare_liste({'FOG_start'},DATA.events.noms))) ' �pisodes de Freezing detect�s!']);
            tags_fog = logical(sum([compare_liste({'FOG_start'},DATA.events.noms);compare_liste({'FOG_end'},DATA.events.noms)],1));
            evts_fog = DATA.events.temps(tags_fog);
            
            % On les retire de la liste des evts si il y'a d'autres evts marqu�s
            evts = DATA.events.temps(~tags_fog);
        end
        pause(1);
        
        % Gestion du Demi-Tour %%% (� d�velopper) (1 par acquisition normalement)
        if sum(compare_liste({'DT_start' 'DT_end'},DATA.events.noms)) % Evts g�n�ral - V�rifier le nom/label de l'�v�nement cr�� sous NEXUS ou Mokka
            disp([fichier ': ' num2str(sum(compare_liste({'DT_start'},DATA.events.noms))) ' demi-tour detect�!']);
            tags_dt = logical(sum([compare_liste({'DT_start'},DATA.events.noms);compare_liste({'DemiTour'},DATA.events.noms)],1));
            evts_dt = DATA.events.temps(tags_dt);
            
            % On les retire de la liste des evts si il y'a d'autres evts marqu�s
            evts = DATA.events.temps(~tags_dt);
        end
        pause(1);
        
        if length(evts)<5
            disp('...Ev�nements de l''Initiation du pas non identifi�e... ');
            disp('...D�tection automatique ...');
            evts = calcul_APA_all(CP_filt,t) - t(1);
            Donnees.(acq).tMarkers.T0 = evts(1) + t(1); % 1er evt biom�canique
            evts(1) = evts(2)-0.01; % ON cr�e le Heel-Off
            DATA.events.temps = evts;
        end
        
        
    catch ERR % D�tection automatique
        disp(['Pas d''�v�nements du pas ' fichier]);
        disp('...D�tection automatique des �v�nements');
        evts = calcul_APA_all(CP_filt,t) - t(1);
        Donnees.(acq).tMarkers.T0 = evts(1) + t(1); % 1er evt biom�canique
        evts(1) = evts(2)-0.01; % ON cr�e le Heel-Off
        DATA.events.temps = evts;
        disp('...Termin�!');
    end
    
    %% Calcul des vitesses du CG
    waitbar(i/length(files),wb,['Calculs pr�liminaires vitesses et APA, marche' num2str(i) '/' num2str(nb_acq)]);
%     pause(0.5);
    [V_CG_PF V_CG_Der V_CG_Vic Acc primResultats] = calcul_vitesse_CG_v6(Fres,Freq_ana,DATA,fin);

    %% Stockage des donnes
    if ~isempty(evts)
        Donnees.(acq).tMarkers.HO = evts(1) + t(1); %Heel-Off
        Donnees.(acq).tMarkers.TO = evts(2) + t(1); %Toe-Off
        Donnees.(acq).tMarkers.FC1 = evts(3) + t(1); %Foot-contact 1
        Donnees.(acq).tMarkers.FO2 = evts(4) + t(1); %Foot-Off 2
        Donnees.(acq).tMarkers.FC2 = evts(5) + t(1); %Foot-contact
    else
        Donnees.(acq).tMarkers.HO = NaN; %Heel-Off
        Donnees.(acq).tMarkers.TO = NaN; %Toe-Off
        Donnees.(acq).tMarkers.FC1 = NaN; %Foot-contact 1
        Donnees.(acq).tMarkers.FO2 = NaN; %Foot-Off 2
        Donnees.(acq).tMarkers.FC2 = NaN; %Foot-contact
    end
    
    if ~isempty(evts_fog) % Evts de Freezing
        Donnees.(acq).tMarkers.FOG = evts_fog; % Stock�s sous forme [Start Stop Start Stop...]
    end
    
    if ~isempty(evts_dt) % Evts du Demi-Tour
        Donnees.(acq).tMarkers.DT = evts_dt; % Stock�s sous forme [Start Stop ...] ??
    end 
    
    Donnees.(acq).t = t; %Temps
    Donnees.(acq).Fech = Freq_ana; %Fr�quence d'�chantillonage (Analogique)
    Donnees.(acq).Fech_vid = Freq_vid; %Fr�quence d'�chantillonage (Analogique)
    Donnees.(acq).CP_AP = CP_filt(:,2); %D�placement AP du CP
    Donnees.(acq).CP_ML = CP_filt(:,1); %D�placement ML du CP
    
    Donnees.(acq).V_CG_AP = V_CG_PF(:,2); % Vitesse du CG AP (int�gration)
    Donnees.(acq).V_CG_ML = V_CG_PF(:,1); % Vitesse du CG ML (int�gration)
    Donnees.(acq).V_CG_Z = V_CG_PF(:,3); % Vitesse verticale du CG (int�gration)
    
    if ~isempty(V_CG_Der)
        Donnees.(acq).V_CG_AP_d = V_CG_Der(:,2); % Vitesse du CG (OBassin) AP (d�rivation)
        Donnees.(acq).V_CG_Z_d = V_CG_Der(:,3); % Vitesse verticale du CG (OBassin) (d�rivation)
    end 
    
    if ~isempty(V_CG_Vic)
        Donnees.(acq).V_CG_Vic_AP_d = V_CG_Vic(:,2); % Vitesse du CG de VICON AP (d�rivation)
        Donnees.(acq).V_CG_Vic_Z_d = V_CG_Vic(:,3); % Vitesse verticale du CG de VICON (d�rivation)
    end 
    
    Donnees.(acq).Acc_Z = filtrage(Acc(:,3),'fir',30,20,Freq_ana); % Acc�l�ration verticale (obtenue grace � la PF)
    
    Donnees.(acq).Loads = Loads;
    Donnees.(acq).Acc_CG = filtrage(Acc,'fir',30,20,Freq_ana);
    
    try
        Donnees.(acq).Puissance_CG = dot(V_CG_PF,Fres,2); % Calcul de la puissance totale au CG (=F.V - Kuo et al. 2005)
    catch Err_cg
        disp('Erreur calcul Puissance au CG');
    end
    
    %Stockage des r�sultats extraits directement
    Donnees.(acq).primResultats.Vm = primResultats.Vm;
    Donnees.(acq).primResultats.VZmin_APA = primResultats.VZmin_APA;
    Donnees.(acq).primResultats.V1 = primResultats.V1;
    Donnees.(acq).primResultats.V2 = primResultats.V2;
    Donnees.(acq).primResultats.VML_abs = primResultats.VML_abs;
    Donnees.(acq).primResultats.Vy_FO1 = primResultats.Vy_FO1;
    
    %Calcul et stockage des APA sur le CP
    try
        [val_min Donnees.(acq).primResultats.minAPAy_AP(1)] = min(Donnees.(acq).CP_AP);
        %         Donnees.(acq).primResultats.minAPAy_AP(2) = mean(Donnees.(acq).CP_AP(1:round(evts(1)*Freq_ana))) - val_min;
        Donnees.(acq).primResultats.minAPAy_AP(2) = Donnees.(acq).CP_AP(round(evts(1)*Freq_ana)) - val_min; %modif XD
    catch Err_APA_AP
        Donnees.(acq).primResultats.minAPAy_AP(1:2) = NaN;
    end
    
    try
        [Donnees.(acq).primResultats.APAy_ML(1) Donnees.(acq).primResultats.APAy_ML(2)] ...
                                               = trouve_APAy(Donnees.(acq).CP_ML(1:round(evts(1)*Freq_ana)));
    catch Err_APAy
        Donnees.(acq).primResultats.APAy_ML(1:2)= NaN;
    end
    
    try
        Donnees.(acq).primResultats.Largeur_pas = range(CP_filt(round(evts(3)*Freq_ana):round(evts(4)*Freq_ana),1)); 
        Donnees.(acq).primResultats.Longueur_pas = range(CP_filt(round(evts(3)*Freq_ana):round(evts(4)*Freq_ana),2));
    catch ERr_Step
        Donnees.(acq).primResultats.Largeur_pas = NaN; 
        Donnees.(acq).primResultats.Longueur_pas = NaN;
    end
    
    % EMGs
    if isfield(DATA,'EMG')
        EMG.(acq).nom = DATA.EMG.nom; %On stocke les 4 premi�res entr�es (par d�faut) %%% Modifier si +ieurs voies � visualiser
        EMGs = extraire_emgs(DATA,EMG.(acq).nom);
        if max(max(EMGs))<1  %ON applique un gain si les amplitudes sont faibles
            EMGs=EMGs*1e5;
        end
        try
            % Filtrage butter [20-500] Hz (recommendations SENIAM)
            EMG.(acq).val = TraitementEMG(EMGs,DATA.EMG.Fech);
        catch Err_filt
            disp(['Erreur filtrage EMGs ' acq]);
            EMG.(acq).val = EMGs;
        end
        EMG.(acq).Fech = DATA.EMG.Fech;
    end
    
    % Angles articulaires/Cin�matique
    if isfield(DATA,'Angles')
        Donnees.(acq).Angles = DATA.Angles;
        Donnees.(acq).Fech_vid = btkGetPointFrequency(h);
    end
    
    %Triggers externes (i.e. LFP)
    if isfield(DATA,'T_trigs')
        Donnees.(acq).Trigger = DATA.T_trigs;
    end
end
close(wb);
warning on