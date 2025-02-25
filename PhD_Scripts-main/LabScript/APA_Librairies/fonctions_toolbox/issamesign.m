function [ms,rg] = issamesign(A) ;
%
% Recherche dans le vecteur A si les �l�ments sont de m�me signe
%

% 1. recherche dans A les valeurs positives n�gatives et nulles
%
rg.positif = find(A > 0) ; nposi = length(rg.positif) ; % les points positifs
rg.negatif = find(A < 0) ; nnega = length(rg.negatif) ; % les points n�gatifs
rg.nul = find(A == 0) ; nnul = length(rg.nul) ;         % Les points nuls
rg.nbs = [nposi, nnega, nnul] ;
%
% 2. si deux sont vides alors les termes de A sont de m�me signe
%
if length(find(rg.nbs ~= 0)) == 1 ;
   ms = 1 ; % m�me signe
else 
   ms = 0 ; % signes diff�rents
end
%
% fin d'un fichier