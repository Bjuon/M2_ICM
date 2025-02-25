function S_norm = normalise_APA(GD)
%% Si une structure contient les m�mes champs � +ieurs reprises alors on normalise la dimension des donn�es vecteurs � la m�me taille
% Entr� : GD structure contenant un group de donn�es r�p�t�es � plusieurs reprises (par acquisition == 1er champ de la structure)
% Sortie: S_norm strcuture dont tous les vecteurs d'un m�me champ contiennent la m�me taille

acquisitions = fieldnames(GD); %Extraction des noms des acqs choisies
datas = fieldnames(GD.(acquisitions{1})); %Extraction des donn�es stock�es

%Initialisation
S_norm = GD;
dim = NaN*ones(length(datas),length(acquisitions));
%% Extraction et normalisation des donn�es vecteurs
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