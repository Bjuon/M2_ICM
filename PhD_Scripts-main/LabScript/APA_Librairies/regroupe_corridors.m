function [Moy tmp Std] = regroupe_corridors(GN)
%% Calcul du groupe ainsi que les param�tres moyens d'un ensembles de corridors stock�es dans la structure GN
%Entr�s: structure GN contenant les corridors normalis�es (!!sans sous-structure/marqueurs temporels et resultats pr�liminaires!!)
%Sorties: Moy structure �quivalente � la moyenne du groupe
%         Std structure �quivalente � l'�cart-type du groupe
%         tmp structure pour l'affichage du corridor moyen contenant toutes les donn�es

corridors = fieldnames(GN); %Extraction des noms des acqs choisies
datas = fieldnames(GN.(corridors{1})); %Extraction des donn�es stock�es

tmp={};
tmp_sub={};
Moy={};
Std={};

%% Reorganisation des donn�es dans la structure sortante
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
