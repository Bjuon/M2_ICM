function S_norm = normalise_APA_lfps(GD,lfps,fs)
%% Si une structure contient les mêmes champs à +ieurs reprises alors on normalise la dimension des données vecteurs à la même taille
% Entré : GD  structure contenant un group de données répétées à plusieurs reprises (par acquisition == 1er champ de la structure)
%       : lfps structure contenant les données LFPs brutes
% Sortie: S_norm strcuture dont tous les vecteurs d'un même champ contiennent la même taille

acquisitions = fieldnames(GD); %Extraction des noms des acqs choisies
acquisitions_lfp = fieldnames(lfps); %Extraction des acqs avec lfp
if nargin<3
    fs = GD.(acquisitions_lfp{1}).Fech;
%     fs=500; %% LFP réechantillonés à la même fréquence que datas PF
end

similars = sum(compare_liste(acquisitions,acquisitions_lfp),2);

datas = fieldnames(GD.(acquisitions{1})); %Extraction des données stockées
try
    lfp_channels = lfps.(acquisitions_lfp{1}).nom; %Extraction des signaux lfps d'une acquisition
catch Errt
    lfp_channels = fieldnames(lfps.(acquisitions_lfp{1})); %Extraction des muscles d'un sous-group
end

%Initialisation
S_norm = lfps;
dim = NaN*ones(length(acquisitions),1);
debut = ones(length(acquisitions),1);
dim_emg = NaN*ones(length(acquisitions),1);
debut_emg = ones(length(acquisitions),1);

%% Extraction et normalisation des données vecteurs
for i = 1:length(acquisitions)
    try
        if similars(i)
            t_0 = GD.(acquisitions{i}).t(1);
            try
                debut_emg(i) = round((GD.(acquisitions{i}).tMarkers.Onset_TA-t_0)*fs)-floor(fs/4); % On prend l'activation de l'EMG
            catch ERR_EMG
                debut_emg(i) = round((GD.(acquisitions{i}).tMarkers.T0-t_0)*fs)-floor(fs/4); % On prend 0.25 sec avt T0
            end
        end
        
        if debut_emg<=0
            disp(['Pas assez de data avant T0/Onset_TA pour ' acquisitions{i}]);
            debut_emg(i) = 1;
        end
        
        dim_emg(i) = length(lfps.(acquisitions{i}).(lfp_channels{1})(:,debut_emg(i):end)); %Sous-groupe
    catch ERr
        debut_emg(i) = 1;
        dim_emg(i) = length(GD.(acquisitions{i}).t(:,debut_emg(i):end));
    end
    
end
dim_min = min(dim);
dim_min_emg = min(dim_emg(similars==1));

for i = 1:length(acquisitions)
    %% LFPs
    if similars(i)
        for m = 1:length(lfp_channels)
            try
                % On filtre avant de stocker
                S_norm.(acquisitions{i}).(lfp_channels{m}) = TraitementLFPs(lfps.(acquisitions{i}).(lfp_channels{m})(:,debut_emg(i):debut_emg(i)+dim_min_emg-1),fs);
            catch Err_normLfp
                disp(['Pas de normalisation LFP ' acquisitions{i} ' channel:' lfp_channels{m}]);
            end
        end
    end
end