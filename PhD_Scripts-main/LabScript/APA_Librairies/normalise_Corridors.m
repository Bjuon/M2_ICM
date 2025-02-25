function [S_norm EMG_norm] = normalise_Corridors(GD,emg)
%% Si une structure contient les mêmes champs à +ieurs reprises alors on normalise la dimension des données vecteurs à la même taille
% Entré : GD  structure contenant par field/group, plusieurs lignes de données répétées à plusieurs reprises (par groupe == 1er champ de la structure)
%       : emg structure contenant les données EMG brutes
% Sortie: S_norm strcuture dont tous les vecteurs d'un même champ contiennent la même taille

groups = fieldnames(GD); %Extraction des noms des groupes choisies
groups_emg = fieldnames(emg); %Extraction des groups avec emg
similars = sum(compare_liste(groups,groups_emg),2);

datas = fieldnames(GD.(groups{1})); %Extraction des données stockées
try
    muscles = emg.(groups_emg{1}).nom; %Extraction des muscles d'une acquisition
catch Errt
    muscles = fieldnames(emg.(groups_emg{1})); %Extraction des muscles d'un sous-group
end

%Initialisation
S_norm = GD;
dim = NaN*ones(length(groups),1);
% debut = ones(length(groups),1);
dim_emg = NaN*ones(length(groups),1);
% debut_emg = ones(length(groups),1);

%% Extraction et normalisation des données matricielles
for i = 1:length(groups)      
    dim(i) = length(GD.(groups{i}).t);
    if similars(i)
        if isfield(emg.(groups{i}),'val')
            dim_emg(i) = length(emg.(groups{i}).val); %Acquisition
        else
            dim_emg(i) = length(emg.(groups{i}).(muscles{1})); %Sous-groupe
        end
    end
end
dim_min = min(dim);
dim_min_emg = min(dim_emg(similars==1));

for i = 1:length(groups)
    %% Données plateformes
    for j = 1:length(datas)
        if ~isstruct(GD.(groups{i}).(datas{j})) && ~sum(strcmp(datas{j},{'Fech' 'Trigger' 'Trigger_LFP'}))
            try
                S_norm.(groups{i}).(datas{j}) = GD.(groups{i}).(datas{j})(:,1:dim_min-1);
            catch Errt
                S_norm.(groups{i}).(datas{j}) = GD.(groups{i}).(datas{j})(1:dim_min-1);
            end
        end
    end
    %% EMGs
    if similars(i)
        for m = 1:length(muscles)
            EMG_norm.(groups{i}).(muscles{m}) = (emg.(groups{i}).(muscles{m})(:,1:dim_min_emg-1));
        end
    end
end