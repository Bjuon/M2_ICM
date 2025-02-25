function Pt = intersection_droite_plan(Droite,Plan)
% calcule le point d'intersection entre un plan et une droite

%
% Coordonnée linéique du point d'intersection avec le plan sur la droite d'origine Droite.pts
%
lambda = dot(Plan.pts-Droite.pts,Plan.normale)/dot(Droite.V_dir,Plan.normale) ;
%
% Calcul du point :
%
Pt = Droite.pts + lambda * Droite.V_dir ;
%
% Fin de la fonction