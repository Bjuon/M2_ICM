function S_norm = normalise_APA(GD)
%% Si une structure contient les mêmes champs à +ieurs reprises alors on normalise la dimension des données vecteurs à la même taille
% Entré : GD structure contenant un group de données répétées à plusieurs reprises (par acquisition == 1er champ de la structure)
% Sortie: S_norm strcuture dont tous les vecteurs d'un même champ contiennent la même taille

acquisitions = fieldnames(GD); %Extraction des noms des acqs choisies
datas = fieldnames(GD.(acquisitions{1})); %Extraction des données stockées

%Initialisation
S_norm = GD;
dim = NaN*ones(length(datas),length(acquisitions));
%% Extraction et normalisation des données vecteurs
for j = 1:length(datas)
    if ~isstruct(GD.(acquisitions{1}).(datas{j}))
        for i = 1:length(acquisitions) 
            try
                debut(j,i) = round(GD.(acquisitions{i}).tMarkers.TR*GD.(acquisitions{i}).Fech); %%ou T0
            catch ERR
                debut(j,i) = 1;
            end
            dim(j,i) = length(GD.(acquisitions{i}).(datas{j})(debut(j,i):end));
        end
    for i = 1:length(acquisitions)
        S_norm.(acquisitions{i}).(datas{j}) = GD.(acquisitions{i}).(datas{j})(debut(j,i):min(dim(j,:)));
    end
    end
end

end