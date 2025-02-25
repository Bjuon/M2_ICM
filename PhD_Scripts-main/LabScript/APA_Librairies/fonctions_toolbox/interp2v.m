% function [U,liste] = interp2v(Na,Np,Va,Vp) ;
%
% Fonction d'interpolation sur un segment en fonction de deux vecteurs par extrémiété
%
function [U,l] = interp2v(Na,Np,Va,Vp) ;
%
% 1. Mise en forme des variables pour le calcul
%
DA = dot(Na,Va,2) ;                % Point A
DP = dot(Np,Vp,2) ;                % Point P
Ep = dot(Na,Vp,2) + dot(Np,Va,2) ; % Produit croisé
%
% 2. Calcul du disciminant et recherche des valeurs positives
%    Modification des variables pour le calcul
% 
% a) Discriminant et valeurs positives
Delta = Ep.^2 - 4 * DP .* DA ;
l = find(Delta >= 0) ;
% b) Mise en forme des variables de calcul
Delta = Delta(l) ;
DA = DA(l) ; DP = DP(l) ; Ep = Ep(l) ;
%
% 3. Calcul des solutions
%
l1 = find(DA + DP - Ep ~= 0) ;
V(l1,1) = ((2 * DP(l1) - Ep(l1)) + sqrt(Delta(l1))) ./ (2 * (DA(l1) + DP(l1) - Ep(l1))) ;
V(l1,2) = ((2 * DP(l1) - Ep(l1)) - sqrt(Delta(l1))) ./ (2 * (DA(l1) + DP(l1) - Ep(l1))) ;
l1 = find(DA + DP - Ep < 100*eps) ;
V(l1,1) = DP(l1) ./ (DP(l1) - DA(l1)) ;
V(l1,2) = -Inf ;
%
% 4. Recherche des solutions réelles comprises entre 0 et 1
%
% ---> Il y a des racines complexes : le problème est mal posé
%
if ~isreal(V) ;
    error('Certaines interpolations n''existent pas') ;
end
%
% ---> Recherche des valeurs :
%
[I,J] = find((V >= 0) & (V <= 1)) ;
%
% ---> 2 cas : première colonne ou seconde
%
liste1 = I(find(J == 1)) ;
liste2 = I(find(J == 2)) ;
%
% ---> Le problème est mal posé si il y a deux valeurs ok pour le meme segment
%
if ~isempty(intersect(liste1,liste2)) ;
    error('Problème mal posé') ;
end
%
% ---> Liste des couples concernés
%
l = l([liste1;liste2]) ;
%
% ---> Initialisation de U
%
U = NaN * ones(size(V,1),1) ;
%
% ---> Traitement des colonnes 1
%
U(liste1,1) = V(liste1,1) ;
%
% ---> Traitement des colonnes 2
%
U(liste2,1) = V(liste2,2) ;
%
% ---> Correction de U
%
U = U(~isnan(U)) ;
%
% ---> fin de la fonction