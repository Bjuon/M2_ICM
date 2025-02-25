function C = stockage_corridor(Moy,STD)
%% Fonction qui stocke pour chaque champ vectoriel de Moy les courbes : moyenne±STD
% Entrées: Moy/STD structures contenants les valeurs moyennes/ecart-types
% Sortie: C contient le vecteur temporel et pour chaque autre variable une
%        matrice [Nx3] ou la colonne 1 correspond à la courbe moyenne
%                                 et 2/3 aux enveloppes du corridor = ±1STD

%Stockage du vecteur temps normalisé
C.t = Moy.t';

%Exclusion de la liste des variables d'affichages
variables = fieldnames(STD);
indx_t = find(compare_liste({'t'},variables)==1);

for i= 1 :length(variables)
    if isrow(Moy.(variables{i})) && i~=indx_t  
       C.(variables{i})(:,1) = Moy.(variables{i})';
       C.(variables{i})(:,2) = Moy.(variables{i}) + STD.(variables{i});
       C.(variables{i})(:,3) = Moy.(variables{i}) - STD.(variables{i});
    end
end
end