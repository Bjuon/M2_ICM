%
% Fonction de projection d'un point sur une droite
%
function [Pt2,dist] = Projection_point_droite(Pt,Droite) ;

Droite.V_dir = Droite.V_dir / norm(Droite.V_dir) ;
Pt2 = Droite.pts + dot(Droite.V_dir,Pt-Droite.pts)*Droite.V_dir ;
dist = norm(Pt-Pt2) ;

% fini