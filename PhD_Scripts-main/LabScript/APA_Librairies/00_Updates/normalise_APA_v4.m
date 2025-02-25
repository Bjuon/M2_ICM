function [S_norm EMG_norm] = normalise_APA_v4(GD,emg)
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
debut = ones(length(acquisitions),1);
dim_emg = NaN*ones(length(acquisitions),1);
debut_emg = ones(length(acquisitions),1);

%% Extraction et normalisation des données vecteurs
for i = 1:length(acquisitions)
    try
        t_0 = GD.(acquisitions{i}).t(1);
        Fech_vic = GD.(acquisitions{i}).Fech;
        debut(i) = round((GD.(acquisitions{i}).tMarkers.T0-t_0)*Fech_vic)-0.25*Fech_vic; %On prend systématiquement 250ms avant T0
        if similars(i)
            if isfield(emg.(acquisitions{i}),'Fech')
                debut_emg(i) = round((GD.(acquisitions{i}).tMarkers.T0-t_0)*emg.(acquisitions{i}).Fech)-floor(emg.(acquisitions{i}).Fech/50); %On prend systématiquement 0.02 sec avant T0
            else
                debut_emg(i) = round((GD.(acquisitions{i}).tMarkers.T0-t_0)*2000)-500; %On suppose que Fech == 2000Hz (défaut)
            end
        end
        
        if debut(i)<=0 || isnan(debut(i))
            debut(i) = 1;
        end
        if debut_emg(i)<=0 || isnan(debut_emg(i))
            disp(['Pas assez de data EMG avant T0 pour ' acquisitions{i}]);
            debut_emg(i) = 1;
        end
        
    catch ERr
        debut(i) = 1;
        debut_emg(i) = 1;
    end
  
    dim(i) = length(GD.(acquisitions{i}).t(debut(i):end));
    if similars(i)
        if isfield(emg.(acquisitions{i}),'val')
            dim_emg(i) = length(emg.(acquisitions{i}).val(debut_emg(i):end,:)); %Acquisition
        else
            dim_emg(i) = length(emg.(acquisitions{i}).(muscles{1})(:,debut_emg(i):end)); %Sous-groupe
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
                    S_norm.(acquisitions{i}).(datas{j}) = GD.(acquisitions{i}).(datas{j})(:,debut(i):debut(i)+dim_min-1);
                catch Errt
                    S_norm.(acquisitions{i}).(datas{j}) = GD.(acquisitions{i}).(datas{j})(debut(i):debut(i)+dim_min-1);
                end
            end
        end
    end
    %% EMGs (on normalise par rapport à l'écart-type - Z score)
    if similars(i)
        for m = 1:length(muscles)
            if isfield(emg.(acquisitions{i}),'val')
                EMG_norm.(acquisitions{i}).(muscles{m}) = (emg.(acquisitions{i}).val(debut_emg(i):debut_emg(i)+dim_min_emg-1,m)')/nanstd(emg.(acquisitions{i}).val(debut_emg(i):debut_emg(i)+dim_min_emg-1,m));
            else
                EMG_norm.(acquisitions{i}).(muscles{m}) = (emg.(acquisitions{i}).(muscles{m})(:,debut_emg(i):debut_emg(i)+dim_min_emg-1))/nanstd(emg.(acquisitions{i}).(muscles{m})(:,debut_emg(i):debut_emg(i)+dim_min_emg-1));
            end
        end
    end
end