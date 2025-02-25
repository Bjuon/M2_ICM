function [ms,rg] = issamesign(A) ;
%
% Recherche dans le vecteur A si les éléments sont de même signe
%

% 1. recherche dans A les valeurs positives négatives et nulles
%
rg.positif = find(A > 0) ; nposi = length(rg.positif) ; % les points positifs
rg.negatif = find(A < 0) ; nnega = length(rg.negatif) ; % les points négatifs
rg.nul = find(A == 0) ; nnul = length(rg.nul) ;         % Les points nuls
rg.nbs = [nposi, nnega, nnul] ;
%
% 2. si deux sont vides alors les termes de A sont de même signe
%
if length(find(rg.nbs ~= 0)) == 1 ;
   ms = 1 ; % même signe
else 
   ms = 0 ; % signes différents
end
%
% fin d'un fichier