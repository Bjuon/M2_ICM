function [h_multi b_multi h_multi_emg b_multi_emg h_multi_kin b_multi_kin] = create_lena_structs_multi_all(Subject_struct,EMG_struct,trials,lfp_tri_struct)
%% Fonction de pr�condiitonnement qui � partir des donn�es lues d'un fichier .c3d va g�n�rer les structures (h, b) � �crire dans le fichier .lena
% function [h_multi b_multi h_multi_emg b_multi_emg h_multi_kin b_multi_kin] = create_lena_structs_multi_all(Subject_struct,EMG_struct,trials,lfp_tri_struct)
% Subject_struct : structure ('Sujet' du programme Test_APA) contenant les donn�es plateforme par essai
% EMG_struct : structure ('EMG' du programme Test_APA) contenant les donn�es EMGs par essai
% trials : liste des essais � inclure (�quivalent � ceux de la strcture LFP par d�faut)
% lfp_tri_struct : variable de tri des essais avec mauvais signaux LFP (� �xclure)
% *_emg : sorties pour les canaux EMG (cr��e � la demande de l'utilisateur si �chantillon�s � une fr�quence diff�rente des signaux d�placements/vitesses)
% *_kin : sorties pour les angles articulaires (cr��e � la demande de l'utilisateur si �chantillon�s � une fr�quence diff�rente des signaux d�placements/vitesses)

if nargin<3
    trials = fieldnames(Subject_struct);
    lfp_tri_struct = {};
end

%% Initialisation du fichier Header (h_multi) et binaire (b_multi)
h_multi={}; h_multi_emg={}; h_multi_kin={};
b_multi=[]; b_multi_emg=[]; b_multi_kin=[];

% Choix des bonnes voies analogiques
channels = fieldnames(Subject_struct.(trials{1}));
[sortiesuj,validation] = listdlg('PromptString','S�lectionnez les channels Vitesses/D�placements � exporter :',...
        'SelectionMode','Multiple',...
        'ListString',channels);
    
channels = channels(sortiesuj);

% Choix des bonnes voies EMGs
try
    channels_emg = EMG_struct.(trials{1}).nom;
    [sortiesuj,validation] = listdlg('PromptString','S�lectionnez les channels EMG � exporter :',...
        'SelectionMode','Multiple',...
        'ListString',channels_emg);
    
    channels_emg = channels_emg(sortiesuj)';
catch NO_emg
    channels_emg = [];
end

% Choix des articulations
iskin = compare_liste({'Angles'},channels);
channels(iskin==1) = [];
if sum(iskin)
    try
        channels_kin = fieldnames(Subject_struct.(trials{1}).Angles);
        [sortiesuj,validation] = listdlg('PromptString','S�lectionnez les articulations � exporter :',...
            'SelectionMode','Multiple',...
            'ListString',channels_kin);
        
        channels_kin = channels_kin(sortiesuj)
    catch NO_kin
        disp('Aucune donn�es angulaire calcul�e!');
        channels_kin = [];
    end
else
    channels_kin = [];
end

% Groupement des canaux dans un premier temps
super_channels = [channels; channels_emg; channels_kin];

% Champs 'dimensions'
N_acq = length(trials);
bads =zeros(1,N_acq);
for t = 1:N_acq
    
    % Tri des mauvais essais
    try
        bad_acq = lfp_tri_struct.(trials{t}).Bad_trial;
    catch No_tri
        bad_acq =0;
    end
    
    if ~bad_acq
        h_multi.dimensions.datablock_range(t).trial_name = trials{t};
    else
        Subject_struct = rmfield(Subject_struct,trials(t));
        EMG_struct = rmfield(EMG_struct,trials(t));
        bads(t) = true;
    end
end
trials = trials(~bads); % On retire les mauvais essais

% Sous-Champ 'sensor_range' (contenant les sous-champs nom/cat�gorie/unit� et �chelle)
for c = 1:length(super_channels)
    h_multi.dimensions.sensor_range.sensors_list(c).name = super_channels{c};
    h_multi.dimensions.sensor_range.sensors_list(c).category = 'Analog';
    h_multi.dimensions.sensor_range.sensors_list(c).coil = {};
end

for s = 1:length(super_channels)
    h_multi.dimensions.sensor_range.supersensors_list(s).name = super_channels{s};
    if strfind(super_channels{s},'CP')
        h_multi.dimensions.sensor_range.sensors_list(s).category = 'TrajectoryCP';
        h_multi.dimensions.sensor_range.supersensors_list(s).unit = 'm';
        h_multi.dimensions.sensor_range.supersensors_list(s).scale = 1e-3;
    elseif strfind(super_channels{s},'V_CG')
        h_multi.dimensions.sensor_range.sensors_list(s).category = 'VitesseCG';
        h_multi.dimensions.sensor_range.supersensors_list(s).unit = 'm/sec';
        h_multi.dimensions.sensor_range.supersensors_list(s).scale = 1;
    elseif strfind(super_channels{s},'Puissance_CG')
        h_multi.dimensions.sensor_range.sensors_list(s).category = 'PuissanceCG';
        h_multi.dimensions.sensor_range.supersensors_list(s).unit = 'Watt';
        h_multi.dimensions.sensor_range.supersensors_list(s).scale = 1;
    elseif strfind(super_channels{s},'Angles')
        h_multi.dimensions.sensor_range.sensors_list(s).category = 'Kinematic';
        h_multi.dimensions.sensor_range.supersensors_list(s).unit = 'Deg';
        h_multi.dimensions.sensor_range.supersensors_list(s).scale = 1;
    else % EMG
        h_multi.dimensions.sensor_range.sensors_list(s).category = 'emg';
        h_multi.dimensions.sensor_range.supersensors_list(s).unit = 'V';
        h_multi.dimensions.sensor_range.supersensors_list(s).scale = 1e-4; %% � verifier???
    end
    
    h_multi.dimensions.sensor_range.supersensors_list(s).sensors_list(1).name = super_channels{s};
    
end

%% Champs restants dans 'dimensions'
h_multi.dimensions.frequency_range = []; %% Fr�quences d'int�r�ts � analyser (vide par d�faut)
h_multi.dimensions.time_range.trigger = 0.2; %% dur�e avant le GO (occurence du GO � partir de 0 - �quivalent au 'Time to capture before start' sur VICON)

%% Fr�quence(s) d'�chantillonage
F_pf  = Subject_struct.(trials{1}).Fech;
h_multi.dimensions.time_range.samplingRate = F_pf;
    % EMG
emg_resampling = true;
try
    F_emg = EMG_struct.(trials{1}).Fech;
    if F_emg ~= F_pf
        choiceFs = questdlg('R��chantillonner EMGs?','Fs PF/EMG diff�rentes!','Oui','Non','Oui');
        if strcmp(choiceFs,'Non')
            emg_resampling = false;
        end
    end
catch
end

    % Cin�matique
pf_resampling = false;
try
    F_vid = Subject_struct.(trials{1}).Fech_vid;
    if F_vid ~= F_pf
        choiceFs = questdlg('R��chantillonner PFs?','Fs PF/Vid�o diff�rentes!','Oui','Non','Non');
        if strcmp(choiceFs,'Oui')
            pf_resampling = true;
        end
    end
catch
end

%% Conditionnement des donn�es (pour la lecture de la matrice b)
h_multi.dimensions.order_dim(1).order = 'datablock_range'; %% La Ligne correspond � l'essai (Dim1)
h_multi.dimensions.order_dim(2).order = 'time_range'; %% La colonne correspond au temps (Dim2)
h_multi.dimensions.order_dim(3).order = 'sensor_range'; %% La 3�me dimension correspond au signal analogique (Dim3)

%% autres champs simples (valeurs par d�faut)
h_multi.data_format = 'LittleEndian';
h_multi.data_size = 4;
h_multi.data_type = 'floating';
h_multi.data_offset = []; %% Pas de d�calage pour GBMOV
tags = extract_tags(trials{1});
h_multi.data_filename = colle_labels(tags(1:end-2),' ');
Condition = [tags{end-1} '_' tags{end-2}];
h_multi.history = ['GBMOV_' tags{1} '_' Condition];

% Param�tre pour la cr�ation de(s) matrice(s) Binaire(s) (b_multi)
N_acq = length(trials);
T = length(Subject_struct.(trials{3}).(channels{1})); % Temps signaux analogiques (on prend le temps de la 3�me acquisition comme r�f�rence)

    % Ecriture de la bonne fr�quence (si l'utilisateur accepte de r��chantilloner tout � la plus petite fr�quence == F_vid par d�faut) ou cr�ation des nouveaux fichier ent�tes correspondants � chaque type de donn�es
if pf_resampling
    h_multi.dimensions.time_range.samplingRate = F_vid;
    T = length(Subject_struct.(trials{2}).Angles.(channels_kin{1})); % Temps signaux vid�o
elseif ~isempty(channels_kin)
    % Cr�ation de l'ent�te pour les donn�s cin�matiques
    h_multi_kin = h_multi;
    % Par en-t�te on retire/conserve les champs/canaux ad�quats
    h_multi.dimensions.sensor_range.sensors_list(logical(sum(compare_liste(channels_kin,super_channels)==1)))=[]; % On retire les Angles
    h_multi.dimensions.sensor_range.supersensors_list(logical(sum(compare_liste(channels_kin,super_channels)==1)))=[];
    h_multi_kin.dimensions.sensor_range.sensors_list(logical(sum(compare_liste([channels; channels_emg],super_channels)==1)))=[]; % On retire les signaux PF et EMG
    h_multi_kin.dimensions.sensor_range.supersensors_list(logical(sum(compare_liste([channels; channels_emg],super_channels))==1))=[];
    
    h_multi_kin.dimensions.time_range.samplingRate = F_vid;
    
    % Cr�ation de la matrice binaire pour les donn�s cin�matiques
    T_kin = length(Subject_struct.(trials{2}).Angles.(channels_kin{1})); % Temps
    b_multi_kin = zeros(N_acq,T_kin,length(channels_kin));
    % Vecteur temporel
    h_multi_kin.dimensions.time_range.timeSamples = T_kin; % On donne le nombre d'�chantillons
    
    % On r�-initialise la liste restante dans h_multi
    super_channels = cell(length(h_multi.dimensions.sensor_range.sensors_list),1);
    for i=1:length(super_channels)
        super_channels{i}= h_multi.dimensions.sensor_range.sensors_list(i).name;
    end
end

if ~emg_resampling
    % Cr�ation de l'ent�te pour les donn�s EMG
    h_multi_emg = h_multi;
    % Par en-t�te on retire/conserve les champs/canaux ad�quats
    h_multi.dimensions.sensor_range.sensors_list(logical(sum(compare_liste(channels_emg,super_channels)==1)))=[];
    h_multi.dimensions.sensor_range.supersensors_list(logical(sum(compare_liste(channels_emg,super_channels)==1)))=[];
    h_multi_emg.dimensions.sensor_range.sensors_list(logical(sum(compare_liste(channels,super_channels)==1)))=[];
    h_multi_emg.dimensions.sensor_range.supersensors_list(logical(sum(compare_liste(channels,super_channels)==1)))=[];
    
    h_multi_emg.dimensions.time_range.samplingRate = F_emg;
    
    % Cr�ation de la matrice binaire pour les donn�s emg
    T_emg = length(EMG_struct.(trials{2}).val); % Temps
    b_multi_emg = zeros(N_acq,T_emg,length(channels_emg));
    % Vecteur temporel
    h_multi_emg.dimensions.time_range.timeSamples = T_emg; % On donne le nombre d'�chantillons
    
    % On r�-initialise la liste restante dans h_multi
    super_channels = cell(length(h_multi.dimensions.sensor_range.sensors_list),1);
    for i=1:length(super_channels)
        super_channels{i}= h_multi.dimensions.sensor_range.sensors_list(i).name;
    end
end

%% Cr�ation de(s) la matrice(s) Binaire pour les donn�es analogiques restantes (b_multi)
C = length(super_channels);
    % Vecteur temporel
h_multi.dimensions.time_range.timeSamples = T; % On donne le nombre d'�chantillons

b_multi = NaN(N_acq,T,C);

% ReGroupement de tous les canaux pour remplissage de(s) matrice(s)
super_channels = [channels; channels_emg; channels_kin];
F = h_multi.dimensions.time_range.samplingRate; % On r�cup�re la fr�quence d'�chantillonage principale

%% Remplissage de(s) la matrice(s) celon l'ordre d�fini plus haut
for i=1:N_acq
    % Matrice principale (h_multi)
    pf=1;
    a=1;
    e=1;
    
    % Matrice de buffer temporel, pour faire coincider le temps du Trigger � t=0.2 sec (car pour certains sujet, le temps avant le trigger est variable entre les acquisitions)
    buff_t = 0.2 - Subject_struct.(trials{i}).tMarkers.TR;
    for c = 1:length(super_channels)
        % Signaux CP/V
        if sum(compare_liste(super_channels(c),channels))
            buff_pf = Subject_struct.(trials{i}).(super_channels{c})(1)*ones(1,round(buff_t*F_pf)); % Cr�ation d'un buffer 'plateau' (on r�plique la 1�re valeur)
            try
                b_multi(i,:,pf) = [buff_pf Subject_struct.(trials{i}).(super_channels{c})(1:F_pf/F:T-length(buff_pf))'];
            catch diff_acq_end_i % Cas ou l'acquisition est plus courte que la duree fix�e T
                dim_acq = length(Subject_struct.(trials{i}).(super_channels{c})(1:F_pf/F:end));
                b_multi(i,1:dim_acq+length(buff_pf),pf) = [buff_pf Subject_struct.(trials{i}).(super_channels{c})(1:F_pf/F:end)'];    
            end
            pf = pf+1;
        % Angles (plan saggital uniquement pour le moment!! %% � developper)
        elseif sum(compare_liste(super_channels(c),channels_kin))
            try
                Data_kin_raw = replaceNaNs(Subject_struct.(trials{i}).Angles.(super_channels{c})(:,1)'); % On remplace les NaN par les valeur les plus proches
                buff_kin = Data_kin_raw(1)*ones(1,round(buff_t*F_vid));
                if pf_resampling
                    try
                        b_multi(i,:,pf) = [buff_kin Data_kin_raw(1:F_vid/F:T-length(buff_kin))];
                    catch diff_acqKin_end_i % Cas ou l'acquisition est plus courte que la duree fix�e T
                        dim_acq = length(Data_kin_raw(1:F_vid/F:end));
                        b_multi(i,1:dim_acq,pf) = [buff_kin Data_kin_raw(1:F_vid/F:end-length(buff_kin))];
                    end
                    pf = pf+1;
                else
                    try
                        b_multi_kin(i,:,a) = [buff_kin Data_kin_raw(1:T_kin-length(buff_kin))];
                    catch diff_acqKin_end_i % Cas ou l'acquisition est plus courte que la duree fix�e T
                        b_multi_kin(i,1:length(Data_kin_raw),a) = [buff_kin Data_kin_raw(1:end-length(buff_kin))];
                    end
                    a = a+1;
                end
            catch no_kin_acq_i
                disp(['Pas d''angle ' super_channels{c} ' pour l''acquisition: ' trials{i}]);
            end
        % Signaux EMG    
        else
            try
                Data_emg_raw = EMG_struct.(trials{i}).val(:,compare_liste(channels_emg,super_channels(c))==1)';
                if emg_resampling
                    buff_emg = zeros(1,round(buff_t*F));
                    try
                        b_multi(i,:,pf) = [buff_emg Data_emg_raw(1:F_emg/F:end)];
                    catch diff_acqEmg_end_i% Cas ou l'acquisition a une duree diff�rente de T
                        Data_emg_resampled = Data_emg_raw(1:F_emg/F:end);
                        dim_acq = length(Data_emg_raw(1:F_emg/F:end));
                        if dim_acq<T
                            b_multi(i,1:dim_acq,pf) = [buff_emg Data_emg_resampled(1:end-length(buff_emg))];
                        else
                            b_multi(i,:,pf) = [buff_emg Data_emg_resampled(1:T-length(buff_emg))];
                        end
                    end
                    pf = pf+1;
                else
                    buff_emg = zeros(1,round(buff_t*F_emg));
                    try
                        b_multi_emg(i,:,e) = [buff_emg Data_emg_raw(1:end-length(buff_emg))];
                    catch diff_acqEmg_end_i% Cas ou l'acquisition a une duree diff�rente de T
                        dim_acq = length(Data_emg_raw);
                        if dim_acq<T_emg 
                            b_multi_emg(i,1:dim_acq,e) = [buff_emg Data_emg_raw(1:end-length(buff_emg))];
                        else
                            b_multi_emg(i,:,e) = [buff_emg Data_emg_raw(1:T_emg-length(buff_emg))];
                        end
                    end
                    e = e+1;
                end
             catch no_emg_acq_i
                disp(['Pas d''EMG ' super_channels{c} ' pour l''acquisition: ' trials{i}]);
            end   
        end
    end       
end