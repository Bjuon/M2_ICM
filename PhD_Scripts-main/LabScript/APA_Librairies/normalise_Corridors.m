function [S_norm EMG_norm] = normalise_Corridors(GD,emg)
%% Si une structure contient les m�mes champs � +ieurs reprises alors on normalise la dimension des donn�es vecteurs � la m�me taille
% Entr� : GD  structure contenant par field/group, plusieurs lignes de donn�es r�p�t�es � plusieurs reprises (par groupe == 1er champ de la structure)
%       : emg structure contenant les donn�es EMG brutes
% Sortie: S_norm strcuture dont tous les vecteurs d'un m�me champ contiennent la m�me taille

groups = fieldnames(GD); %Extraction des noms des groupes choisies
groups_emg = fieldnames(emg); %Extraction des groups avec emg
similars = sum(compare_liste(groups,groups_emg),2);

datas = fieldnames(GD.(groups{1})); %Extraction des donn�es stock�es
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

%% Extraction et normalisation des donn�es matricielles
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
    %% Donn�es plateformes
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