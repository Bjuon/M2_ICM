function [S_norm EMG_norm] = normalise_APA_v01(GD,emg)
%% Si une structure contient les m�mes champs � +ieurs reprises alors on normalise la dimension des donn�es vecteurs � la m�me taille
% Entr� : GD  structure contenant un group de donn�es r�p�t�es � plusieurs reprises (par acquisition == 1er champ de la structure)
%       : emg structure contenant les donn�es EMG brutes
% Sortie: S_norm strcuture dont tous les vecteurs d'un m�me champ contiennent la m�me taille

acquisitions = fieldnames(GD); %Extraction des noms des acqs choisies
acquisitions_emg = fieldnames(emg); %Extraction des acqs avec emg
similars = sum(compare_liste(acquisitions,acquisitions_emg),2);

datas = fieldnames(GD.(acquisitions{1})); %Extraction des donn�es stock�es
try
    muscles = emg.(acquisitions_emg{1}).nom; %Extraction des muscles d'une acquisition
catch Errt
    muscles = fieldnames(emg.(acquisitions_emg{1})); %Extraction des muscles d'un sous-group
end

%Initialisation
S_norm = GD;
dim = NaN*ones(length(acquisitions),1);
dim_emg = NaN*ones(length(acquisitions),1);

%% Extraction et normalisation des donn�es vecteurs (alignement sur TR/d�but acquisition)
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
    %% Donn�es plateformes
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
    %% EMGs (on normalise par rapport � l'�cart-type - Z score)
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