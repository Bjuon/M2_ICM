function S_norm = normalise_APA_v2N(GD)
%% Si une structure contient les mêmes champs à +ieurs reprises alors on normalise la dimension des données vecteurs à la même taille (Normalisation)
% Entré : GD structure contenant un group de données répétées à plusieurs reprises (par acquisition == 1er champ de la structure)
% Sortie: S_norm strcuture dont tous les vecteurs d'un même champ contiennent la même taille

acquisitions = fieldnames(GD); %Extraction des noms des acqs choisies
datas = fieldnames(GD.(acquisitions{1})); %Extraction des données stockées

%Initialisation
S_norm = GD;
dim = NaN*ones(length(acquisitions),1);
debut = ones(length(acquisitions),1);
fin = ones(length(acquisitions),1);
%% Extraction et normalisation des données vecteurs
for i = 1:length(acquisitions)
    try
        t_0 = GD.(acquisitions{i}).t(1);
        debut(i) = round((GD.(acquisitions{i}).tMarkers.T0-t_0)*GD.(acquisitions{i}).Fech)-10; %On prend systématiquement 10 points (ou 20ms) avant T0
        if debut(i)<=0
            debut(i) = 1;
        end
    catch ERr
        debut(i) = 1;
    end
    fin(i) = round((GD.(acquisitions{i}).tMarkers.FC2-t_0)*GD.(acquisitions{i}).Fech)+10; %On prend systématiquement 10 points après le FC2 
  
    try
        dim(i) = length(GD.(acquisitions{i}).t(1,debut(i):fin(i)));
    catch not_ehough_data
        dim(i) = length(GD.(acquisitions{i}).t(1,debut(i):end));
    end
end
dim_min = min(dim);
taille = dim_min-1;
echant = (0:taille);
for i = 1:length(acquisitions)
    for j = 1:length(datas)
        if ~isstruct(GD.(acquisitions{i}).(datas{j})) && ~strcmp(datas{j},'Fech')
            uncycle = (0:(taille/dim(i)):taille)';
            try
                data_to_normalize = GD.(acquisitions{i}).(datas{j})(:,debut(i):debut(i)+dim(i));
            catch Errt
                try
                    data_to_normalize = GD.(acquisitions{i}).(datas{j})(debut(i):debut(i)+dim(i));
                catch last_pt_exception
                    dec = uncycle - dim(i);
                    data_to_normalize = [GD.(acquisitions{i}).(datas{j})(debut(i):end); NaN*ones(dec,1)];
                end
            end
            try
                S_norm.(acquisitions{i}).(datas{j}) = interp1(uncycle,data_to_normalize,echant,'spline') - nanmean(data_to_normalize(1:10)); % On remet la ligne de base
            catch errNorm
                disp([acquisitions{i} ': Erreur normalisation ' datas{j}]);
            end
        end
    end
end

end