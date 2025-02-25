function [NonVide,ArrBts] = test_non_vide_boite(Nb,NPb,N,Arr) ;
% _________________________________________________________________________
%
% Test permettant de savoir si une boite contient ou non des aretes
% _________________________________________________________________________
%
% 1. Mise en forme des variables : simplification des écritures
% a) Noeuds extrèmes des boites 
%
U = Nb(NPb(:,1),:) ;
V = Nb(NPb(:,7),:) ;
%
% b) Hauteur, largeur et profondeur des boites
%
DX = V(1,1) - U(1,1) ; 
DY = V(1,2) - U(1,2) ; 
DZ = V(1,3) - U(1,3) ;
%
% c) Mise en forme pour les extrémités des aretes
%
A = N(Arr(:,1),:) ; 
B = N(Arr(:,2),:) ;
%
% d) Préparation de la mémoire : purge & remise à plat
%
clear N Nb NPb Arr
pack
%
% e) Matrices de simplification des calculs
%
M1 = ones(1,size(A,1)) ;
M2 = ones(size(U,1),1) ;
%
% 2. Analyse de contenance par groupes
% 2.1 Calcul des différents coefficients
%
warning off
% ---> Pour la direction X
% a) Calcul des intersections
kXmin = (U(:,1) * M1 - M2 * A(:,1)') ./ (M2 * (B(:,1) - A(:,1))') ;
kXmax = kXmin + DX ./ (M2 * (B(:,1) - A(:,1))') ;
% b) Mise en ordre
l1 = find(kXmax < kXmin) ;
TEMP = kXmax ;
kXmax(l1) = kXmin(l1) ; 
kXmin(l1) = TEMP(l1) ;
% ---> Pour la direction Y
% a) Calcul des intersections
kYmin = (U(:,2) * M1 - M2 * A(:,2)') ./ (M2 * (B(:,2) - A(:,2))') ;
kYmax = kYmin + DY ./ (M2 * (B(:,2) - A(:,2))')  ;
% b) Mise en ordre
l1 = find(kYmax < kYmin) ;
TEMP = kYmax ;
kYmax(l1) = kYmin(l1) ; 
kYmin(l1) = TEMP(l1) ;
% ---> Pour la direction Z
% a) Calcul des intersections
kZmin = (U(:,3) * M1 - M2 * A(:,3)') ./ (M2 * (B(:,3) - A(:,3))') ;
kZmax = kZmin + DZ ./ (M2 * (B(:,3) - A(:,3))')  ;
% b) Mise en ordre
l1 = find(kZmax < kZmin) ;
TEMP = kZmax ;
kZmax(l1) = kZmin(l1) ; 
kZmin(l1) = TEMP(l1) ;
warning on
clear TEMP
%
% 2.2 Recherche des intersections
% a) recherche des boites ayant une intersection
%
[I,J] = find((kXmin <= 1)&(kYmin <= 1)&(kZmin <= 1)&(kXmax >= 0)&(kYmax >= 0)&(kZmax >= 0)) ;
NonVide = unique(I) ;
%
% b) Recherche des aretes contenues par les boites
%
[I,ordre] = sort(I) ; J = J(ordre) ;
liste = [[1;find(diff(I))+1],[find(diff(I));size(J,1)]] ;
for t = 1:length(NonVide) ;
    ArrBts{t} = J([liste(t,1):liste(t,2)]) ; 
end
%
% Fin de la fonction