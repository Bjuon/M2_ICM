function [Moy tmp Std] = regroupe_acquisitions(GN)
%% Calcul du corridor moyen et des param�tres moyens d'un ensembles d'acquisitions stock�es dans la structure Sujet
%Entr�s: structure GN contenant les acquisitions normalis�es
%Sorties: Moy structure �quivalente � l'acquisition moyenne
%         Std structure �quivalente � l'�cart-type des acquisitions
%         tmp structure pour l'affichage du corridor moyen contenant toutes les donn�es

acquisitions = fieldnames(GN); %Extraction des noms des acqs choisies
datas = fieldnames(GN.(acquisitions{1})); %Extraction des donn�es stock�es

tmp={};
tmp_sub={};
Moy={};
Std={};

%% Reorganisation des donn�es dans la structure sortante
for j = 1:length(datas)
    for i = 1:length(acquisitions)
        if isstruct(GN.(acquisitions{i}).(datas{j})) %Marqueurs temporels et resultats pretraitement
            sub_datas = fieldnames((GN.(acquisitions{i}).(datas{j})));
            for k = 1:length(sub_datas)
                tmp_sub.(datas{j}).(sub_datas{k})(i,:) = GN.(acquisitions{i}).(datas{j}).(sub_datas{k});
                if i==length(acquisitions)
                    if isint(tmp_sub.(datas{j}).(sub_datas{k}))
                        Moy.(datas{j}).(sub_datas{k}) = round(nanmean(tmp_sub.(datas{j}).(sub_datas{k}),1));
%                     Std.(datas{j}).(sub_datas{k}) = nanstd(tmp_sub.(datas{j}).(sub_datas{k}),1);
                    else
                        Moy.(datas{j}).(sub_datas{k}) = nanmean(tmp_sub.(datas{j}).(sub_datas{k}),1);
                    end
                end
            end
        else % Donn�es vecteurs normalis�es (t, d�placements et vitesses)
%             if iscolumn(GN.(acquisitions{i}).(datas{j}))
            try
                if size(GN.(acquisitions{i}).(datas{j}),2)==1
                    tmp.(datas{j})(i,:) = GN.(acquisitions{i}).(datas{j})';
                else
                    tmp.(datas{j})(i,:) = GN.(acquisitions{i}).(datas{j});
                end
            catch ERR
                disp(['Pas de normalisation '  acquisitions{i} '.' datas{j}]);
            end
            
            if i==length(acquisitions)
                try
                    Moy.(datas{j}) = nanmean(tmp.(datas{j}),1);
                catch Errt
                    Moy.(datas{j}) = unique(tmp.(datas{j}))';
                end
                if ~strcmp(datas{j},'Fech') && ~strcmp(datas{j},'nom')
                    Std.(datas{j}) = nanstd(tmp.(datas{j}),1);
                end
            end
        end
    end
end       
    
end
