function [Donnes EMG] = pretraitement_dataAPA_v2(files,dossier)
%% Effectue le pré-traitement et stockage des données receuillies du répertoire d'étude (dossier)
% Donnes   = structure contenant par (champ/acquisitions) les données d'intérêts
%       .tMarkers.() = Marqueurs temporels () correspondants aux évenements du pas
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
%
% EMG     = structure contenant les noms et valeurs des 4 premières entrées analogiques de l'acquisition (EMGs du TA et SOL)

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
    if i==1 && ischar(files)
        acq = [extract_spaces(session) '_' extract_spaces(files(1:end-4))]; % On nomme chaque acquisition en commencant par le dossier ou elle se trouve
        fichier = files;
    else
        acq = [extract_spaces(session) '_' extract_spaces(files{i}(1:end-4))];
        fichier = files{i};
    end;
    
    waitbar(i/nb_acq,wb,['Lecture fichier:' fichier]);
    
    %Lecture du fichier
    ext = extract_filetype(fichier);
    switch ext
        case 'c3d'
            DATA = lire_donnees_c3d(strcat(dossier,['\' fichier]));
            h = btkReadAcquisition(strcat(dossier,['\' fichier]));
            Freq_vid = btkGetPointFrequency(h);
            fin = round(find(Fres(:,3)<50,1,'first'));
            t = (0:fin-1)*1/Freq_vid;
        case 'xls'
%             [DATA t] = extrait_notocord_excel(strcat(dossier,['\' fichier]));
%             fin = length(t);
            [DATA t fin] = extrait_notocord_excel(strcat(dossier,['\' fichier]));
        otherwise
            disp('Pas de format supporté');
            break
    end
    
    %% Extraction de la GRF sur la PF uniquement
    Fres = DATA.actmec(1:fin,7:9);
        
    %Si pas de donnée vidéo, alors données PF échantillonées à la même fréquence que l'EMG
    if isempty(DATA.coord)
        Freq_vid = DATA.EMG.Fech;
    end
    
    %Filtrage des données PF: filtre à réponse impulsionnel finie d'ordre 30 et de fréquence de coupure 20Hz
    CP = DATA.actmec(1:fin,1:2);
    
    %On retire les NaN
    l = ~isnan(CP(:,1))==1;
    CP = CP(l,:);
    t = t(l);
    
    CP_filt = filtrage(CP,'fir',30,20,Freq_vid); %%%% A changer
    
    %% Extraction des marqueurs temporels d'inititation du pas (!!Faire une fonction plus tard pour la detection automatik!!)    
    Donnes.(acq).tMarkers.TR = 1/Freq_vid;
    %Initialisation
    evts = [0.1 0.5 1 1.1 1.5 2]; %% A la louche pour pas que le chargement plante !! Mettre détéction automatik plus tard!!
    Donnes.(acq).tMarkers.T0 = 1/Freq_vid;
    try
        evts = DATA.events.temps;
        ind_1 = round(evts(1)*Freq_vid); %1er evenment noté
        if ind_1>2 % Cas ou l'acqisition commence tardivement avec l'initiation du pas
            Donnes.(acq).tMarkers.T0 = calcul_APA_T0_v3(CP_filt(1:ind_1,:),t(1:ind_1));
        else
            Donnes.(acq).tMarkers.T0 = ind_1;
        end
        
    catch ERR
        errordlg(['Pas d''évènements du pas ' fichier]);
        DATA.events.temps = evts;
    end
    
    %% Calcul des vitesses du CG
    waitbar(i/length(files),wb,['Calculs préliminaires vitesses, marche' num2str(i) '/' num2str(nb_acq)]);
%     pause(0.5);
    [V_CG_PF V_CG_Der V_CG_Vic Acc primResultats] = calcul_vitesse_CG_v3(Fres,Freq_vid,DATA);

    %% Stockage des donnes
    Donnes.(acq).tMarkers.HO = evts(1) + t(1); %Heel-Off
    Donnes.(acq).tMarkers.TO = evts(2) + t(1); %Toe-Off
    Donnes.(acq).tMarkers.FC1 = evts(3) + t(1); %Foot-contact 1
    Donnes.(acq).tMarkers.FO2 = evts(4) + t(1); %Foot-Off 2
    Donnes.(acq).tMarkers.FC2 = evts(5) + t(1); %Foot-contact 2
    
    Donnes.(acq).t = t; %Temps
    Donnes.(acq).Fech = Freq_vid; %Fréquence d'échantillonage
    Donnes.(acq).CP_AP = CP_filt(:,2); %Déplacement AP du CP
    Donnes.(acq).CP_ML = CP_filt(:,1); %Déplacement ML du CP
    
    Donnes.(acq).V_CG_AP = V_CG_PF(l,2); % Vitesse du CG AP (intégration)
    Donnes.(acq).V_CG_ML = V_CG_PF(l,1); % Vitesse du CG ML (intégration)
    Donnes.(acq).V_CG_Z = V_CG_PF(l,3); % Vitesse verticale du CG (intégration)
    
    if ~isempty(V_CG_Der)
        Donnes.(acq).V_CG_AP_d = V_CG_Der(l,2); % Vitesse du CG AP (dérivation)
        Donnes.(acq).V_CG_Z_d = V_CG_Der(l:fin,3); % Vitesse verticale du CG (dérivation)
    end 
    
    Donnes.(acq).Acc_Z = filtrage(Acc(l,3),'fir',30,20,Freq_vid); % Accélération verticale (obtenue grace à la PF)

    %Stockage des résultats extraits directement
    Donnes.(acq).primResultats.Vm = primResultats.Vm;
    Donnes.(acq).primResultats.VZmin_APA = primResultats.VZmin_APA;
    Donnes.(acq).primResultats.V1 = primResultats.V1;
    Donnes.(acq).primResultats.V2 = primResultats.V2;
    Donnes.(acq).primResultats.VML_abs = primResultats.VML_abs;
    Donnes.(acq).primResultats.Vy_FO1 = primResultats.Vy_FO1;
    
    %Calcul et stockage des APA sur le CP
    [val_min Donnes.(acq).primResultats.minAPAy_AP(1)] = min(Donnes.(acq).CP_AP);
    Donnes.(acq).primResultats.minAPAy_AP(2) = mean(Donnes.(acq).CP_AP(Donnes.(acq).tMarkers.TR*Freq_vid:Donnes.(acq).tMarkers.T0*Freq_vid))...
                                                 - val_min;
    
    try
        [Donnes.(acq).primResultats.APAy_ML(1) Donnes.(acq).primResultats.APAy_ML(2)] ...
                                               = trouve_APAy(Donnes.(acq).CP_ML(1:Donnes.(acq).tMarkers.HO*Freq_vid));
    catch Err_APAy
        Donnes.(acq).primResultats.APAy_ML(1:2)= NaN;
    end
    
    Donnes.(acq).primResultats.Largeur_pas = range(CP_filt(1:Donnes.(acq).tMarkers.FC1*Freq_vid,1));
    Donnes.(acq).primResultats.Longueur_pas = range(CP_filt(Donnes.(acq).tMarkers.FC1*Freq_vid:Donnes.(acq).tMarkers.FO2*Freq_vid,2));
    
    % EMGs
    if isfield(DATA,'EMG')
        EMG.(acq).nom = DATA.EMG.nom(1:4); %On stocke les 4 premières entrées (par défaut)
        EMGs = extraire_emgs(DATA,EMG.(acq).nom');
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
