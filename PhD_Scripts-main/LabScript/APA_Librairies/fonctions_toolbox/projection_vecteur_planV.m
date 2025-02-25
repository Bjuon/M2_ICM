function V3 = projection_vecteur_planV(V1,V2) ;
%
% Fonction de projection d'un vecteur 3D V1 dans un plan vectoriel de
% normale V2.
%
V3 = cross(V2,cross(V1,V2)) ;
%
% Fin de la fonction