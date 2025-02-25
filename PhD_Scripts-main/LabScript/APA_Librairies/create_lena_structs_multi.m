function [h_multi b_multi] = create_lena_structs_multi(hdr,lfp_struct,lfp_tri_struct,res_struct,pool)
%% Fonction de précondiitonnement qui à partir des données lues d'un fichier LFP/EEG va générer les structures (h, b et e) à écrire dans le fichier .lena
% function [h_multi b_multi e_multi] = create_lena_structs_multi(hdr,lfp_struct,res_struct,pool)
% hdr : structure d'entête du fichier enregistrement chargé
% lfp_struct : structure contenant les données numériques par essai
% lfp_tri_struct : structure de tri des essais/contacts
% res_struct : structure contenant les resultats du prétraitement par essai
% pool: flag de regroupement Contra/Ipsi latéral au pied de départ

if nargin<3
    pool = 0;
end

channels = hdr.label';
    
if length(channels)>7 %% cas des fichiers ou y'a 2 channels EMG en 1 et 2
    channels(2:3) = [];
    col(2:3,:) = [];
end

if pool % On groupe par côté par rapport au pied de départ
    super_channels = {'Trigger' 'ContraL01' 'ContraL12' 'ContraL23' 'IpsiL01' 'IpsiL12' 'IpsiL23'};
else
    super_channels = channels';
end

for sub=1:length(super_channels)
    subgroup_channels{1,sub} = {super_channels(sub)};
end

%% Initialisation du fichier Header (h_multi)
h_multi={};

% champs 'dimensions'
trials = fieldnames(lfp_struct);
N_acq = length(trials);

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
        lfp_struct = rmfield(lfp_struct,trials(t));
    end
end

for c = 1:length(super_channels)
    h_multi.dimensions.sensor_range.sensors_list(c).name = super_channels{c};
    h_multi.dimensions.sensor_range.sensors_list(c).category = 'lfp'; %% ou 'eeg'
    h_multi.dimensions.sensor_range.sensors_list(c).coil = {};
end

for s = 1:length(super_channels)
    h_multi.dimensions.sensor_range.supersensors_list(s).name = super_channels{s};
    if isempty(hdr.units{s}) % Trigger/Numérique
        h_multi.dimensions.sensor_range.sensors_list(s).category = 'dc';
        h_multi.dimensions.sensor_range.supersensors_list(s).unit = 'V';
        h_multi.dimensions.sensor_range.supersensors_list(s).scale = 1;
    else
        switch hdr.units{s}
            case 'uV'
                h_multi.dimensions.sensor_range.supersensors_list(s).unit = 'V';
                h_multi.dimensions.sensor_range.supersensors_list(s).scale = 1e-6;
            otherwise
                h_multi.dimensions.sensor_range.supersensors_list(s).unit = hdr.units{s};
                h_multi.dimensions.sensor_range.supersensors_list(s).scale = 1;
        end
    end
    for ss = 1:size(subgroup_channels{1,s},1)
        try
            h_multi.dimensions.sensor_range.supersensors_list(s).sensors_list(ss).name = cell2mat(subgroup_channels{s}(ss));
        catch
            h_multi.dimensions.sensor_range.supersensors_list(s).sensors_list(ss).name = cell2mat(subgroup_channels{s}{ss});
        end
    end
end

trials = fieldnames(lfp_struct);
N_acq = length(trials);
T = length(lfp_struct.(trials{1}).(channels{1})); % Temps
h_multi.dimensions.frequency_range = []; %% Mettre plus tard les fréquences d'intérêt
h_multi.dimensions.time_range.trigger = 2; %% durée avant le 0 (décalage temporel)
h_multi.dimensions.time_range.samplingRate = hdr.fs;
h_multi.dimensions.time_range.timeSamples = T;
h_multi.dimensions.order_dim(1).order = 'datablock_range'; %% La Ligne correspond à l'essai
h_multi.dimensions.order_dim(2).order = 'time_range'; %% La colonne correspond au temps
h_multi.dimensions.order_dim(3).order = 'sensor_range'; %% La 3ème dimension correspond à l'electrode/capteur

% autres champs simples
h_multi.data_format = 'LittleEndian';
h_multi.data_size = 4;
h_multi.data_type = 'floating';
h_multi.data_offset = []; %% Pas de décalage pour GBMOV
h_multi.data_filename = hdr.recordID;
tags = extract_tags(hdr.recordID);
Condition = [tags{end-1} '_' tags{end-2}];
h_multi.history = ['GBMOV_' hdr.patientID '_' Condition '_' hdr.startdate '_' hdr.starttime];

%% Création du fichier Binaire (b_multi)
C = length(super_channels);
b_multi = NaN*ones(N_acq,T,C);

for i=1:N_acq
    % Remplissage du vecteur binaire
    
    % Tri par côté contro/ipsi-latéral au pied de départ (ordre: côté Contralatéral puis Ipsilatéral toujours)
    if pool && strcmp(res_struct.(trials{i}).Cote,'Droit')
        contacts = {channels{1} 'Contact01G' 'Contact12G' 'Contact23G' 'Contact01D' 'Contact12D' 'Contact23D'};
    else
        %Ordre par défaut (à modifier !! rendre plus flexible au cas ou les channels ont des noms différents
        contacts = {channels{1} 'Contact01D' 'Contact12D' 'Contact23D' 'Contact01G' 'Contact12G' 'Contact23G'};
%         contacts = channels;
    end
    
    
    
    for c = 1:length(contacts)
        try
            bad_contact = lfp_tri_struct.(trials{i}).(contacts{c}); %%%!! ou (c+1) si on ne veut pas garder le trigger
        catch exclude
            bad_contact=0;
        end
        
        if ~bad_contact
            try
                b_multi(i,:,c) = lfp_struct.(trials{i}).(contacts{c})(1:T);
            catch err_size % Cas ou pour une acquisition la durée est + petite
                dim = length(lfp_struct.(trials{i}).(contacts{c}));
                b_multi(i,1:dim,c) = lfp_struct.(trials{i}).(contacts{c});
            end
        end
    end
    
end
