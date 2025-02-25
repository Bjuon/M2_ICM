% proche = voisinage_courbe(C,Pts,seuil) ;
%
% ---> Fonction renvoyant les num�ros des noeuds proche d'une courbe (i.e. 
%      distant de * ou - une distance seuil dans la direction de la normale)
%
function proche = voisinage_courbe(C,Pts,seuil) ;
%
% ---> D�termination du polygone associ� � la courbe C
%
P = creer_polygone_contour(C,seuil)  ;
%
% ---> Recherche des points dans le polygone
%
In = inpolygon(Pts(:,1),Pts(:,2),P(:,1),P(:,2)) ;
%
% ---> Cr�ation de la variable de sortie
% 
proche = find(In ~= 0) ;
%
% ---> Fin de la fonction