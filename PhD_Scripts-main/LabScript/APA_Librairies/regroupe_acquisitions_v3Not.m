function [Moy tmp Std] = regroupe_acquisitions_v3Not(GN,C,Cond,choixCond)
%% Calcul du corridor moyen (adapt� pour format Notocord Calire) et des param�tres moyens d'un ensembles d'acquisitions stock�es dans la structure Sujet
%Entr�s: structure GN contenant les acquisitions normalis�es, C : structure
%contenant le c�t� (pour s�parer les essais Gauche et Droite), Cond : structure contenant le condition (pour s�parer les essais Spontan� et Rapide)
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
    d=1;
    g=1;
    for i = 1:length(acquisitions)
        if strcmp(Cond{i},choixCond)
            if isstruct(GN.(acquisitions{i}).(datas{j})) %Marqueurs temporels et resultats pretraitement
                sub_datas = fieldnames((GN.(acquisitions{i}).(datas{j})));
                for k = 1:length(sub_datas)
                    T0 = GN.(acquisitions{i}).tMarkers.T0;
                    if strcmp(datas{j},'tMarkers') % pour les marqueurs temporels on les recalcul par rapport � T0
                        tmp_sub.(datas{j}).(sub_datas{k})(i,:) = GN.(acquisitions{i}).(datas{j}).(sub_datas{k}) - T0;
                    else
                        try
                            tmp_sub.(datas{j}).(sub_datas{k})(i,:) = GN.(acquisitions{i}).(datas{j}).(sub_datas{k});
                        catch ERRyy
                            disp(['Error on ' acquisitions{i} ' ' datas{j} ' ' sub_datas{k}]);
                        end
                    end                   
                end
            else % Donn�es vecteurs normalis�es (t, d�placements et vitesses)
                %             if iscolumn(GN.(acquisitions{i}).(datas{j}))
                try
                    if size(GN.(acquisitions{i}).(datas{j}),2)==1
                        if strcmp(datas{j},'CP_ML')
                            if strcmp(C{i},'Droit') || strcmp(C{i},'D')
                                tmp.CP_ML_D(d,:) = GN.(acquisitions{i}).(datas{j})';
                                d = d+1;
                            else
                                tmp.CP_ML_G(g,:) = GN.(acquisitions{i}).(datas{j})';
                                g = g+1;
                            end
                        end
                        tmp.(datas{j})(i,:) = GN.(acquisitions{i}).(datas{j})';
                    else
                        if strcmp(datas{j},'CP_ML')
                            if strcmp(C{i},'Droit') || strcmp(C{i},'D')
                                tmp.CP_ML_D(d,:) = GN.(acquisitions{i}).(datas{j})';
                                d = d+1;
                            else
                                tmp.CP_ML_G(g,:) = GN.(acquisitions{i}).(datas{j})';
                                g = g+1;
                            end
                        end
                        tmp.(datas{j})(i,:) = GN.(acquisitions{i}).(datas{j});
                    end
                    
                catch ERR
                    disp(['Pas de normalisation '  acquisitions{i} '.' datas{j}]);
                end
            end
        end
    end
    
    %Remplissage de la variable moyenne
    if isstruct(GN.(acquisitions{i}).(datas{j})) %Marqueurs temporels et resultats pretraitement
        sub_datas = fieldnames((GN.(acquisitions{i}).(datas{j})));
        for k = 1:length(sub_datas)
            if isint(tmp_sub.(datas{j}).(sub_datas{k}))
                Moy.(datas{j}).(sub_datas{k}) = round(nanmean(tmp_sub.(datas{j}).(sub_datas{k}),1));
%                 Std.(datas{j}).(sub_datas{k}) = nanstd(tmp_sub.(datas{j}).(sub_datas{k}),1);
            else
                Moy.(datas{j}).(sub_datas{k}) = nanmean(tmp_sub.(datas{j}).(sub_datas{k}),1);
            end
        end
    else
        try
            Moy.(datas{j}) = nanmean(tmp.(datas{j}),1);
        catch errt
            Moy.(datas{j}) = unique(tmp.(datas{j}))';
        end
        
        if ~strcmp(datas{j},'Fech') && ~strcmp(datas{j},'nom')
            Std.(datas{j}) = nanstd(tmp.(datas{j}),1);
        end
    end
    
end
       
    
end