function [h_lena b_lena] = create_lena_structs(hdr,col,pool)
%% Fonction de précondiitonnement qui à partir des données lues d'un fichier LFP/EEG va générer les structures (h et b) à écrire dans le fichier .lena
% function [h_lena b_lena] = create_lena_structs(hdr,col)
% hdr : structure d'entête du fichier enregistrement chargé
% col : matrice contenant les données binaires/numériques [N_sensor x t]
% pool: flag de regroupement G/D

if nargin<3
    pool = 0;
end

channels = hdr.label';
    
if length(channels)>7 %% cas des fichiers ou y'a 2 channels EMG en 1 et 2
    channels(2:3) = [];
    col(2:3,:) = [];
end

if pool % On groupe par côté
    super_channels = {channels{2}(end) channels{5}(end)};
    subgroup_channels{1} = channels(2:4);
    subgroup_channels{2} = channels(5:7);
else
    super_channels = channels';
    for sub=1:length(super_channels)
        subgroup_channels{1,sub} = {channels(sub)};
    end
end

%% Initialisation du fichier Header (h_lena)
h_lena={};
% champs 'dimensions'
h_lena.dimensions.datablock_range =[]; % Pour les enregistrements continus ou .datablock_range{1,1}=[Patient(f) '_' Condition(f)];
for c = 1:length(super_channels)
    h_lena.dimensions.sensor_range.sensors_list(c).name = super_channels{c};
    h_lena.dimensions.sensor_range.sensors_list(c).category = 'lfp'; % ou 'eeg'
    h_lena.dimensions.sensor_range.sensors_list(c).coil = {};
end

for s = 1:length(super_channels)
    h_lena.dimensions.sensor_range.supersensors_list(s).name = super_channels{s};
    if isempty(hdr.units{s}) % Trigger/Numérique
        h_lena.dimensions.sensor_range.sensors_list(s).category = 'dc';
        h_lena.dimensions.sensor_range.supersensors_list(s).unit = 'V';
        h_lena.dimensions.sensor_range.supersensors_list(s).scale = 1;
    else
        switch hdr.units{s}
            case 'uV'
                h_lena.dimensions.sensor_range.supersensors_list(s).unit = 'V';
                h_lena.dimensions.sensor_range.supersensors_list(s).scale = 1e-6;
            otherwise
                h_lena.dimensions.sensor_range.supersensors_list(s).unit = hdr.units{s};
                h_lena.dimensions.sensor_range.supersensors_list(s).scale = 1;
        end
    end
    for ss = 1:size(subgroup_channels{1,s},1)
        try
            h_lena.dimensions.sensor_range.supersensors_list(s).sensors_list(ss).name = cell2mat(subgroup_channels{s}(ss));
        catch
            h_lena.dimensions.sensor_range.supersensors_list(s).sensors_list(ss).name = cell2mat(subgroup_channels{s}{ss});
        end
    end
end

h_lena.dimensions.frequency_range = []; %% Mettre plus tard les fréquences d'intérêt
h_lena.dimensions.time_range.trigger = 0; %% durée avant le 0 (décalage temporel)
h_lena.dimensions.time_range.samplingRate = hdr.fs;
h_lena.dimensions.time_range.timeSamples = length(col);
h_lena.dimensions.order_dim(1).order = 'sensor_range'; %% La Ligne correspond à l'electrode/capteur
h_lena.dimensions.order_dim(2).order = 'time_range'; %% La colonne correspond au temps

% autres champs simples
h_lena.data_format = 'LittleEndian';
h_lena.data_size = 4;
h_lena.data_type = 'floating';
h_lena.data_offset = []; %% Pas de décalage pour GBMOV
h_lena.data_filename = hdr.recordID;
tags = extract_tags(hdr.recordID);
try
    Condition = [tags{end-1} '_' tags{end-2}];
catch
    Condition = tags{end};
end
try
    h_lena.history = ['GBMOV_' hdr.patientID '_' Condition '_' hdr.startdate '_' hdr.starttime];
catch
    h_lena.history = hdr.recordID;
end

%% Création du fichier Binaire (b_lena)
%     % Prétraitement du signal LFP continu ?
%     col_post = Pretraitement_LFP(col,fs);
b_lena = col;