% Ct = centroide_polygone_plan(N) ;
%
% Fonction de calcul du centroide (barycentre) d'un polygone plan
% N est la liste des coordonn�es des noeuds du contour 
% telle que la premi�re colonne soit les abscisses et la
% seconde les ordonn�es 
%
function Ct = centroide_polygone_plan(N) ;
%
% 1. Il faut replacer le premier point en fin de liste
%
N = [N;N(1,:)] ;
%
% 2. Calcul du centroide par int�gration de Green
% ---> Surface du polygone
S = surface_polygone_plan(N(1:end-1,:)) ;
% ---> Abscisse de G 
Ct(1,1) = (N(2:end,1).^2 + N(1:end-1,1).*N(2:end,1) + N(1:end-1,1).^2)' * diff(N(:,2)) / (6 * S) ;
% ---> Ordonn�e de G
Ct(1,2) = - (N(2:end,2).^2 + N(1:end-1,2).*N(2:end,2) + N(1:end-1,2).^2)' * diff(N(:,1)) / (6 * S) ;
%
% Fin de la fonction