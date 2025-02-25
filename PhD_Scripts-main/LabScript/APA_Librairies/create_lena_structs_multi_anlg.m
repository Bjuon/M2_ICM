function [h_multi b_multi] = create_lena_structs_multi_anlg(Subject_struct,EMG_struct,trials,lfp_tri_struct)
%% Fonction de précondiitonnement qui à partir des données lues d'un fichier .c3d va générer les structures (h, b) à écrire dans le fichier .lena
% function [h_multi b_multi] = create_lena_structs_multi_anlg(Subject_struct,EMG_struct,trials,lfp_tri_struct)
% Subject_struct : structure ('Sujet' du programme Test_APA) contenant les données plateforme par essai
% EMG_struct : structure ('EMG' du programme Test_APA) contenant les données EMGs par essai
% trials : liste des essais à inclure (équivalent à ceux de la strcture LFP!!)
% lfp_tri_struct : variable de tri des essais avec mauvais signaux LFP (à éxclure)

if nargin<3
    trials = fieldnames(Subject_struct);
    lfp_tri_struct = {};
end

%% Initialisation du fichier Header (h_multi)
h_multi={};

% Choix des bonnes voies analogiques
channels = fieldnames(Subject_struct.(trials{1}));
[sortiesuj,validation] = listdlg('PromptString','Sélectionnez les channels Vitesses/Déplacements à exporter :',...
        'SelectionMode','Multiple',...
        'ListString',channels);
    
channels = channels{sortiesuj};

% Choix des bonnes voies EMGs
try
    channels_emg = EMG_struct.(trials{1}).nom;
    [sortiesuj,validation] = listdlg('PromptString','Sélectionnez les channels EMG à exporter :',...
        'SelectionMode','Multiple',...
        'ListString',channels_emg);
    
    channels_emg = channels_emg{sortiesuj};
catch NO_emg
    channels_emg = [];
end

super_channels = [channels channels_emg];

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

% Sous-Champ 'sensor_range' (contenant les sous-champs nom/catégorie/unité et échelle)
for c = 1:length(super_channels)
    h_multi.dimensions.sensor_range.sensors_list(c).name = super_channels{c};
    h_multi.dimensions.sensor_range.sensors_list(c).category = 'Analog';
    h_multi.dimensions.sensor_range.sensors_list(c).coil = {};
end

for s = 1:length(super_channels)
    h_multi.dimensions.sensor_range.supersensors_list(s).name = super_channels{s};
    if strfind(super_channels{s},'CP')
        h_multi.dimensions.sensor_range.sensors_list(s).category = 'PF';
        h_multi.dimensions.sensor_range.supersensors_list(s).unit = 'mm';
        h_multi.dimensions.sensor_range.supersensors_list(s).scale = 1;
    elseif strfind(super_channels{s},'V')
        h_multi.dimensions.sensor_range.sensors_list(s).category = 'Vitesse';
        h_multi.dimensions.sensor_range.supersensors_list(s).unit = 'm/sec';
        h_multi.dimensions.sensor_range.supersensors_list(s).scale = 1;
    else % EMG
        h_multi.dimensions.sensor_range.sensors_list(s).category = 'emg';
        h_multi.dimensions.sensor_range.supersensors_list(s).unit = 'V';
        h_multi.dimensions.sensor_range.supersensors_list(s).scale = 1e-4; %% à verifier???
    end
    
    h_multi.dimensions.sensor_range.supersensors_list(s).sensors_list(ss).name = super_channels{s};
    
end

% Champs restants dans 'dimensions'
N_acq = length(trials);
T = length(Subject_struct.(trials{1}).(channels{1})); % Temps
h_multi.dimensions.frequency_range = []; %% Fréquences d'intérêts à analyser (vide par défaut)
h_multi.dimensions.time_range.trigger = 0.2; %% durée avant le GO (occurence du GO à partir de 0)

% Fréquence(s) d'échantillonage
F_pf  = Subject_struct.(trials{1}).Fech;
bool_emg_resampling = true;
try
    F_emg = EMG_struct.(trials{1}).Fech;
    if F_emg ~= F_pf
        choiceFs = questdlg('Fréquences d''échantillonnages PF/EMG différentes!','Rééchantillonner EMGs?','Oui','Non','Oui');
        if strcmp(choiceFs,'Non')
            %%% développer la possibilité de créer 2 structures différentes au cas ou F_emg>F_pf
            bool_emg_resampling = false;
            return
        end
    end
catch
end

h_multi.dimensions.time_range.samplingRate = F_pf;

% Vecteur temporel
h_multi.dimensions.time_range.timeSamples = T; % On donne la durée

% Conditionnement des données (pour la lecture de la matrice b)
h_multi.dimensions.order_dim(1).order = 'datablock_range'; %% La Ligne correspond à l'essai (Dim1)
h_multi.dimensions.order_dim(2).order = 'time_range'; %% La colonne correspond au temps (Dim2)
h_multi.dimensions.order_dim(3).order = 'sensor_range'; %% La 3ème dimension correspond au signal analogique (Dim3)

% autres champs simples (valeurs par défaut)
h_multi.data_format = 'LittleEndian';
h_multi.data_size = 4;
h_multi.data_type = 'floating';
h_multi.data_offset = []; %% Pas de décalage pour GBMOV
tags = extract_tags(trials{1});
h_multi.data_filename = colle_labels(tags{1:end-2});
Condition = [tags{end-1} '_' tags{end-2}];
h_multi.history = ['GBMOV_' tags{1} '_' Condition];

%% Création de la matrice Binaire (b_multi)
C = length(super_channels);
b_multi = NaN*ones(N_acq,T,C);

for i=1:N_acq
    % Remplissage de la matrice celon l'ordre défini plus haut
    for c = 1:C
        % Signaux CP/V
        if sum(compare_liste(super_channels(c),channels))
            b_multi(i,:,c) = Subject_struct.(trials{i}).(super_channels{c});
        else % Signaux EMG
            Data_emg_raw = EMG_struct.(trials{i}).(super_channels{c});
            if bool_emg_resampling %besoin de réechantilloner ?
                b_multi(i,:,c) = Data_emg_raw(1:F_emg/F_pf:end);
            else
                b_multi(i,:,c) = NaN*ones(1,T); %% Non fonctionnelle pour le moment car si on ne veut pas réchantilloner l'export est arrêté
            end
        end
    end       
end
