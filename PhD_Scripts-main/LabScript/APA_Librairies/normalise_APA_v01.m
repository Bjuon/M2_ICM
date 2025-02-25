function [S_norm EMG_norm] = normalise_APA_v01(GD,emg)
%% Si une structure contient les mêmes champs à +ieurs reprises alors on normalise la dimension des données vecteurs à la même taille
% Entré : GD  structure contenant un group de données répétées à plusieurs reprises (par acquisition == 1er champ de la structure)
%       : emg structure contenant les données EMG brutes
% Sortie: S_norm strcuture dont tous les vecteurs d'un même champ contiennent la même taille

acquisitions = fieldnames(GD); %Extraction des noms des acqs choisies
acquisitions_emg = fieldnames(emg); %Extraction des acqs avec emg
similars = sum(compare_liste(acquisitions,acquisitions_emg),2);

datas = fieldnames(GD.(acquisitions{1})); %Extraction des données stockées
try
    muscles = emg.(acquisitions_emg{1}).nom; %Extraction des muscles d'une acquisition
catch Errt
    muscles = fieldnames(emg.(acquisitions_emg{1})); %Extraction des muscles d'un sous-group
end

%Initialisation
S_norm = GD;
dim = NaN*ones(length(acquisitions),1);
dim_emg = NaN*ones(length(acquisitions),1);

%% Extraction et normalisation des données vecteurs (alignement sur TR/début acquisition)
for i = 1:length(acquisitions)
    dim(i) = length(GD.(acquisitions{i}).t);
    if similars(i)
        if isfield(emg.(acquisitions{i}),'val')
            dim_emg(i) = length(emg.(acquisitions{i}).val); %Acquisition
        else
            dim_emg(i) = length(emg.(acquisitions{i}).(muscles{1})); %Sous-groupe
        end
    end
end
dim_min = min(dim);
dim_min_emg = min(dim_emg(similars==1));

for i = 1:length(acquisitions)
    %% Données plateformes
    for j = 1:length(datas)
        if isfield(GD.(acquisitions{i}),datas{j})
            if ~isstruct(GD.(acquisitions{i}).(datas{j})) && ~sum(strcmp(datas{j},{'Fech' 'Fech_vid' 'Trigger' 'Trigger_LFP'}))
                try
                    S_norm.(acquisitions{i}).(datas{j}) = GD.(acquisitions{i}).(datas{j})(:,1:dim_min-1);
                catch Errt
                    S_norm.(acquisitions{i}).(datas{j}) = GD.(acquisitions{i}).(datas{j})(1:dim_min-1);
                end
            end
        end
    end
    %% EMGs (on normalise par rapport à l'écart-type - Z score)
    if similars(i)
        for m = 1:length(muscles)
            if isfield(emg.(acquisitions{i}),'val')
                EMG_norm.(acquisitions{i}).(muscles{m}) = (emg.(acquisitions{i}).val(1:dim_min_emg-1,m)')/nanstd(emg.(acquisitions{i}).val(1:dim_min_emg-1,m));
            else
                EMG_norm.(acquisitions{i}).(muscles{m}) = (emg.(acquisitions{i}).(muscles{m})(:,1:dim_min_emg-1))/nanstd(emg.(acquisitions{i}).(muscles{m})(:,1:dim_min_emg-1));
            end
        end
    end
end