% S = surface_polygone_plan(N) ;
%
% Fonction de calcul de la surface d'un polygone plan
% N est la liste des coordonn�es des noeuds du contour 
% telle que la premi�re colonne soit les abscisses et la
% seconde les ordonn�es 
%
function S = surface_polygone_plan(N) ;
%
% 1. Il faut replacer le premier point en fin de liste
%
N = [N;N(1,:)] ;
%
% 2. Calcul de la surface par int�gration de Green
%
X = N(1:end-1,1) + N(2:end,1) ;
dY =  N(2:end,2) - N(1:end-1,2) ;
S = .5 * X' * dY ;
%
% Fin de la fonction