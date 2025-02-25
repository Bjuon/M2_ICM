% proche = voisinage_courbe(C,Pts,seuil) ;
%
% ---> Fonction renvoyant les numéros des noeuds proche d'une courbe (i.e. 
%      distant de * ou - une distance seuil dans la direction de la normale)
%
function proche = voisinage_courbe(C,Pts,seuil) ;
%
% ---> Détermination du polygone associé à la courbe C
%
P = creer_polygone_contour(C,seuil)  ;
%
% ---> Recherche des points dans le polygone
%
In = inpolygon(Pts(:,1),Pts(:,2),P(:,1),P(:,2)) ;
%
% ---> Création de la variable de sortie
% 
proche = find(In ~= 0) ;
%
% ---> Fin de la fonction