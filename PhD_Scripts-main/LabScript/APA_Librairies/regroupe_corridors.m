function [Moy tmp Std] = regroupe_corridors(GN)
%% Calcul du groupe ainsi que les paramètres moyens d'un ensembles de corridors stockées dans la structure GN
%Entrés: structure GN contenant les corridors normalisées (!!sans sous-structure/marqueurs temporels et resultats préliminaires!!)
%Sorties: Moy structure équivalente à la moyenne du groupe
%         Std structure équivalente à l'écart-type du groupe
%         tmp structure pour l'affichage du corridor moyen contenant toutes les données

corridors = fieldnames(GN); %Extraction des noms des acqs choisies
datas = fieldnames(GN.(corridors{1})); %Extraction des données stockées

tmp={};
tmp_sub={};
Moy={};
Std={};

%% Reorganisation des données dans la structure sortante
for j = 1:length(datas)
    n_acqs = zeros(length(corridors)+1,1);
    for i = 1:length(corridors)
        try
            n_acqs(i+1) = n_acqs(i) + size(GN.(corridors{i}).(datas{j}),1);
            tmp.(datas{j})(n_acqs(i)+1:n_acqs(i+1),:) = GN.(corridors{i}).(datas{j});
        catch ERR
            disp(['Pas de normalisation '  corridors{i} '.' datas{j}]);
        end
        
        if i==length(corridors)
            Moy.(datas{j}) = nanmean(tmp.(datas{j}),1);
            if ~strcmp(datas{j},'Fech')
                Std.(datas{j}) = nanstd(tmp.(datas{j}),1);
            end
        end
        
    end
end       
    
end
