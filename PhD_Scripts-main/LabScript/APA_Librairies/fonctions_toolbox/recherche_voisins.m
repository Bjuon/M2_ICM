% Voisins = Recherche_voisins(Polygones,Arr)
%
% Fonction de recherche des voisins pour un polygone ou
% un ensemble de polygones : voisinage défini par l'arrete
% ---> Cette fonction ne fonctionne seulement que pour les maillages
%      définis par un ensemble de triangles
%
function Voisins = Recherche_voisins(Polygones,Arr) ; 
%
% 1. Calcul des arretes pour l'objet courant
%
if nargin == 1 ;
    Arr = analyse_arretes(Polygones) ;
end
%
% 2. Deux triangles sont voisins si ils partagent une arretes
%
% a) recherche de la liste des arretes s'appuyant sur 2 triangles
%
l2p = find(Arr.Polygones(:,2) ~= 0) ;
%
% b) création d'une sparse matrice pour les voisins
%
D = sparse(size(Polygones,1),size(Polygones,1)) ;
%
% c) Remplissage de cette matrice
%
indok = sub2ind(size(D),Arr.Polygones(l2p,1),Arr.Polygones(l2p,2)) ;
D(indok) = 1 ; D = D + D' ;
%
% d) création de la variable de sortie
%
% ---> Recherche et mise en forme des voisins
[l1,l2] = find(D ~= 0) ; 
[l1,ordre] = sort(l1) ;
l2 = l2(ordre) ;
% ---> Variables de construction de la matrice de sortie
v = find(diff(l1) ~= 0) ;
X = [1;1+v] ;                % ---> localisation des voisins
Y = diff([0;v;length(l1)]) ; % ---> Nombre de voisins
% ---> Boucle de remplissage de la variable de sortie
%      par nombre de voisins
for t = min(Y):max(Y) ;
    % ---> Quels sont les polygones dans ce cas ?
    I = find(Y == t) ;
    % ---> Remplissage
    for y = 0:t-1 ;
        Voisins(l1(X(I)),y+1) = l2(X(I)+y) ;
    end
end
%
% ---> Fin de la fonction