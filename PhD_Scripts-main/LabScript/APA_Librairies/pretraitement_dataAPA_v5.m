function [Donnes EMG] = pretraitement_dataAPA_v5(files,dossier,b_c)
%% Effectue le pré-traitement et stockage des données receuillies du répertoire d'étude (dossier)
% b_c : flag pour couper l'acquisition (plateforme uniquement ou toute l'acquisition)
% Donnes   = structure contenant par (champ/acquisitions) les données d'intérêts
%       .tMarkers.() = Marqueurs temporels () correspondants aux évenements du pas (valeurs brutes)
%       .t = Vecteur temporel
%       .Fech = Fréquence d'échantillonage (video)
%       .primResultats.() = Résultats préliminaires () du prétraitement sous forme [#occurence/frame valeur] (1x2)
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
%       .Puissance_CG = Puissance interne globale au CG (Kuo et al. 2005) - Inter-Limb method
%       .Acc = Accéleration verticale du CG
%
% EMG     = structure contenant les noms et valeurs des 4 premières entrées analogiques de l'acquisition (EMGs du TA et SOL)

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
Donnes = {};
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
    if i==1 && ischar(files)
        acq = [extract_spaces(session) '_' extract_spaces(files(1:end-4))]; % On nomme chaque acquisition en commencant par le dossier ou elle se trouve
        fichier = files;
    else
        acq = [extract_spaces(session) '_' extract_spaces(files{i}(1:end-4))];
        fichier = files{i};
    end;
    
    [Tags fich_ier]= extract_tags(fichier);
    waitbar(i/nb_acq,wb,['Lecture fichier:' fich_ier]);
    
    %Lecture du fichier
    ext = extract_filetype(fichier);
    switch ext
        case 'c3d'
            DATA = lire_donnees_c3d(strcat(dossier,['\' fichier]));
            h = btkReadAcquisition(strcat(dossier,['\' fichier]));
            Freq_vid = btkGetPointFrequency(h);
            t_all = (0:btkGetLastFrame(h)-1)*1/Freq_vid;
            fin = round(find(DATA.actmec(:,9)<70,1,'first'));  %%%% Choix ou on coupe l'acquisition!!! (defauut = PF)
            if isempty(fin) || strcmp(b_c,'Oui')
                fin = length(t_all);
            end
            %Si pas de donnée vidéo, alors données PF échantillonées à la même fréquence que l'EMG
            if isempty(DATA.coord)
                Freq_vid = DATA.EMG.Fech;
            end
        case 'xls'
%             [DATA t] = extrait_notocord_excel(strcat(dossier,['\' fichier]));
%             fin = length(t);
            [DATA t_all fin] = extrait_notocord_excel(strcat(dossier,['\' fichier]));
            Freq_vid = 500; %Fréquence d'acquisition NOtocord
        otherwise
            disp('Pas de format supporté');
            break
    end
    
    %% Extraction de la GRF sur la PF uniquement
    if fin<10 %% On a des 0 sur les données PF en début d'acquisitions
        fin = length(t_all);
    end
    
    Fres = DATA.actmec(1:fin,7:9);
    t = t_all(1:fin);
    
    %Filtrage des données PF: filtre à réponse impulsionnel finie d'ordre 50 et de fréquence de coupure 45Hz
    CP = DATA.actmec(1:fin,1:2);
    
    %On retire les NaN avant filtrage
    l = ~isnan(CP(:,1))==1;
    CP_pre = CP(l,:);
%     t = t(l);
    
    CP_post = filtrage(CP_pre,'fir',50,45,Freq_vid); %%%% A changer?
    CP_filt = [CP_post;NaN*ones(sum(~l),2)]; %% ON recomplète le vecteur (à modifier en cas de NaN sur la PF!!!)
    
    %% Extraction des marqueurs temporels d'inititation du pas  
    % Extraction du temps de l'instruction (à partir du FSW) pour le calcul du temps de réaction
    if isfield(DATA,'ANLG')
        signal = extraire_anlg(DATA,{'GO'});
        if isnan(signal)
            signal = extrait_FSW_analog(DATA.ANLG); %% Le trigger est sur un canal nommé 'FSW'
        end
        
        if ~isnan(signal)
            signal = signal - nanmean(signal);
            try
                TR_ind = find(signal>0.2,1,'first');
                Donnes.(acq).tMarkers.TR = TR_ind/DATA.ANLG.Fech;
                DATA.T_trigs = TR_ind/DATA.ANLG.Fech; % GO = TRigger de synchro LFP
            catch GO_start
                DATA.T_trigs = t(1);
                Donnes.(acq).tMarkers.TR = t(1);
            end
        else
            disp('Pas de go sonore!');
            Donnes.(acq).tMarkers.TR = t(1);
        end
    else
        disp('Pas de go sonore!');
        Donnes.(acq).tMarkers.TR = t(1);
    end
    
    try 
        % Détection T0 + extraction des evts du pas notés sur Nexus (VICON)
        evts = sort(DATA.events.temps - t(1));
        ind_1 = round((evts(1)-t(1))*Freq_vid); %1er evenment noté manuellement sur le VICON (Heel-Off)
        if ind_1>10 % Cas ou l'acqisition commence tardivement avec l'initiation du pas
            Donnes.(acq).tMarkers.T0 = calcul_APA_T0_v4(CP_filt(1:ind_1,:),t(1:ind_1)) + t(1); % 1er evt biomécanique
        else
            Donnes.(acq).tMarkers.T0 = NaN;
        end
        
        % Gestion des FOG %%% (à rendre plus flexible)
        if sum(compare_liste({'FOG_start'},DATA.events.noms)) || sum(compare_liste({'FOG_end'},DATA.events.noms))% Evts de Freezing
            disp([fichier ': ' num2str(sum(compare_liste({'FOG_start'},DATA.events.noms))) ' épisodes de Freezing detectés!']);
            tags_fog = logical(sum([compare_liste({'FOG_start'},DATA.events.noms);compare_liste({'FOG_end'},DATA.events.noms)],1));
            evts_fog = DATA.events.temps(tags_fog);
            
            % On les retire de la liste des evts si il y'a d'autres evts marqués
            evts = DATA.events.temps(~tags_fog);
        end
        pause(1);
        
        if length(evts)<5
            disp('...Pas assez d''évènements du pas détectés ');
            disp('...Détection automatique ...');
            evts = calcul_APA_all(CP_filt,t) - t(1);
            Donnes.(acq).tMarkers.T0 = evts(1) + t(1); % 1er evt biomécanique
            evts(1) = evts(2)-0.01; % ON crée le Heel-Off
            DATA.events.temps = evts;
        end
        
        
    catch ERR % Détection automatique
        disp(['Pas d''évènements du pas ' fichier]);
        disp('...Détection automatique des évènements');
        evts = calcul_APA_all(CP_filt,t) - t(1);
        Donnes.(acq).tMarkers.T0 = evts(1) + t(1); % 1er evt biomécanique
        evts(1) = evts(2)-0.01; % ON crée le Heel-Off
        DATA.events.temps = evts;
        disp('...Terminé!');
    end
    
    %% Calcul des vitesses du CG
    waitbar(i/length(files),wb,['Calculs préliminaires vitesses et APA, marche' num2str(i) '/' num2str(nb_acq)]);
%     pause(0.5);
    [V_CG_PF V_CG_Der V_CG_Vic Acc primResultats] = calcul_vitesse_CG_v3(Fres,Freq_vid,DATA);

    %% Stockage des donnes
    if ~isempty(evts)
        Donnes.(acq).tMarkers.HO = evts(1) + t(1); %Heel-Off
        Donnes.(acq).tMarkers.TO = evts(2) + t(1); %Toe-Off
        Donnes.(acq).tMarkers.FC1 = evts(3) + t(1); %Foot-contact 1
        Donnes.(acq).tMarkers.FO2 = evts(4) + t(1); %Foot-Off 2
        Donnes.(acq).tMarkers.FC2 = evts(5) + t(1); %Foot-contact
    else
        Donnes.(acq).tMarkers.HO = NaN; %Heel-Off
        Donnes.(acq).tMarkers.TO = NaN; %Toe-Off
        Donnes.(acq).tMarkers.FC1 = NaN; %Foot-contact 1
        Donnes.(acq).tMarkers.FO2 = NaN; %Foot-Off 2
        Donnes.(acq).tMarkers.FC2 = NaN; %Foot-contact
    end
    
    if exist('evts_fog','var') % Evts de Freezing
        Donnes.(acq).tMarkers.FOG = evts_fog; % Stockés sous forme [Start Stop ...]
    end 
    
    Donnes.(acq).t = t; %Temps
    Donnes.(acq).Fech = Freq_vid; %Fréquence d'échantillonage
    Donnes.(acq).CP_AP = CP_filt(:,2); %Déplacement AP du CP
    Donnes.(acq).CP_ML = CP_filt(:,1); %Déplacement ML du CP
    
    Donnes.(acq).V_CG_AP = V_CG_PF(:,2); % Vitesse du CG AP (intégration)
    Donnes.(acq).V_CG_ML = V_CG_PF(:,1); % Vitesse du CG ML (intégration)
    Donnes.(acq).V_CG_Z = V_CG_PF(:,3); % Vitesse verticale du CG (intégration)
    
    if ~isempty(V_CG_Der)
        Donnes.(acq).V_CG_AP_d = V_CG_Der(:,2); % Vitesse du CG AP (dérivation)
        Donnes.(acq).V_CG_Z_d = V_CG_Der(:,3); % Vitesse verticale du CG (dérivation)
    end 
    
    Donnes.(acq).Acc_Z = filtrage(Acc(:,3),'fir',30,20,Freq_vid); % Accélération verticale (obtenue grace à la PF)
    
    try
        Donnes.(acq).Puissance_CG = dot(V_CG_PF,Fres,2); % Calcul de la puissance totale au CG (=F.V)
    catch Err_cg
        disp('Erreur calcul Puissance au CG');
    end
    
    %Stockage des résultats extraits directement
    Donnes.(acq).primResultats.Vm = primResultats.Vm;
    Donnes.(acq).primResultats.VZmin_APA = primResultats.VZmin_APA;
    Donnes.(acq).primResultats.V1 = primResultats.V1;
    Donnes.(acq).primResultats.V2 = primResultats.V2;
    Donnes.(acq).primResultats.VML_abs = primResultats.VML_abs;
    Donnes.(acq).primResultats.Vy_FO1 = primResultats.Vy_FO1;
    
    %Calcul et stockage des APA sur le CP
    try
        [val_min Donnes.(acq).primResultats.minAPAy_AP(1)] = min(Donnes.(acq).CP_AP);
        Donnes.(acq).primResultats.minAPAy_AP(2) = mean(Donnes.(acq).CP_AP(1:round(evts(1)*Freq_vid))) - val_min;
    catch Err_APA_AP
        Donnes.(acq).primResultats.minAPAy_AP(1:2) = NaN;
    end
    
    try
        [Donnes.(acq).primResultats.APAy_ML(1) Donnes.(acq).primResultats.APAy_ML(2)] ...
                                               = trouve_APAy(Donnes.(acq).CP_ML(1:round(evts(1)*Freq_vid)));
    catch Err_APAy
        Donnes.(acq).primResultats.APAy_ML(1:2)= NaN;
    end
    
    try
        Donnes.(acq).primResultats.Largeur_pas = range(CP_filt(round(evts(3)*Freq_vid):round(evts(4)*Freq_vid),1)); 
        Donnes.(acq).primResultats.Longueur_pas = range(CP_filt(round(evts(3)*Freq_vid):round(evts(4)*Freq_vid),2));
    catch ERr_Step
        Donnes.(acq).primResultats.Largeur_pas = NaN; 
        Donnes.(acq).primResultats.Longueur_pas = NaN;
    end
    
    % EMGs
    if isfield(DATA,'EMG')
        EMG.(acq).nom = DATA.EMG.nom(1:4); %On stocke les 4 premières entrées (par défaut)
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
    
    %Triggers externes (i.e. LFP)
    if isfield(DATA,'T_trigs')
        Donnes.(acq).Trigger = DATA.T_trigs;
    end
end
close(wb);
warning on