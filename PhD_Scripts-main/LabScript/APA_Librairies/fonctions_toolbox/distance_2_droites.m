% function d = distance_2_droites(O1,d1,O2,d2) ;
%
% O1 : un point de la première droite (1,3)
% d1 : vecteur directeur de la première droite (1,3)
% O2 : un point de la seconde droite (1,3)
% d2 : vecteur directeur de la deuxième droite (1,3)
%
% d : distance entre les deux droites
%
function [d,P] = distance_2_droites(O1,d1,O2,d2) ;

%
% 1. Normalisation des vecteurs directeurs
%
d1 = d1 / norm(d1) ;
d2 = d2 / norm(d2) ;
%
% 2. Calcul du produit scalaire entre les 2 vecteurs directeurs ...
%
n1n2 = dot(d1,d2) ;
%
% 3. Calcul du vecteur p1p2
%
P1P2 = O2 - O1 ;
%
% 4. Calculs des produits scalaires p1p2.n1 et p1p2.n2
%
P1P2n1 = dot(d1,P1P2) ;
P1P2n2 = dot(d2,P1P2) ;
%
% 5. Création des matrices de calculs
%
A(1,1) = 1 ; A(2,2) = 1 ; A(1,2) = - n1n2 ; A(2,1) = - n1n2 ;
V(1,1) = P1P2n1 ; V(2,1) = -P1P2n2 ;
%
% 6. Coefficients linéaires points les plus proches
%
if det(A) < 10 * eps ;
    % ---> matrice non inversible
    warning('Les droites sont parallèles ...')
    % ---> La distance entre les deux droite est données par la distance
    % d'un point de D2 à la droite D1
    d = norm(P1P2 - P1P2n1 * d1) ;
    P = [NaN,NaN,NaN] ;
    return
end
warning off
Coefs = inv(A)*V ; 
warning on
%
% 7. Calcul des coordonnées des point M et N les plus proches sur les 2 droites
%
OM = O1 + Coefs(1,1) * d1 ; % droite n°1
ON = O2 + Coefs(2,1) * d2 ; % droite n°2
%
% 8. L'intersection est définie comme étant le milieu du segment MN
%
P = (OM + ON) / 2 ;
%
% 9. calcul de la distance MN
%
d = norm(OM - ON) ;
%
% Fin de la fonction