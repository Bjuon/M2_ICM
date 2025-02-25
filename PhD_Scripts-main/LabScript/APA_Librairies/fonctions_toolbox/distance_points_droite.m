% dist = distance_points_droite(Droite,Pts) 
%
% Fonction de calcul de distance entre une droite et des points
%
function [dist,dpto] = distance_points_droite(D,P) ;
%
% 1. Gestion des données d'entrée
%
if (length(D) ~= size(P,1))&(length(D) ~= 1) ;
    % ---> Erreur : impossibilité de calculer
    error('Données d''entrée incompatible') ;
end
%
% 2. Mise en forme des variables
%
dim = size(P,2) ; % ---> Dimension de l'espace de travail
N = size(P,1) ;   % ---> Nombre de points
if length(D) == 1 ;
    % ---> Matrice des points origines & des vecteurs directeurs
    Pto = ones(N,1) * D.pts ;
    MVd = ones(N,1) * D.V_dir ;
else
    % ---> Matrice des points origines & des vecteurs directeurs
    Pto = reshape([D(:).pts],Dim,N)' ;
    MVd = reshape([D(:).V_dir],Dim,N)' ;
end
% ---> Nous normons tous les vecteurs directeurs
MVd = norme_vecteur(MVd) ;
%
% 3. Calcul des distances
%
dpto = dot(MVd,P-Pto,2) ; % ---> distance de la projection des points sur la droite
dist = sqrt(norm2(P-Pto).^2 - dpto.^2) ;
%
% Fin de la fonction