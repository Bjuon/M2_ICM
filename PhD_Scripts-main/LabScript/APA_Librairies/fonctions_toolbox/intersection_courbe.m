function [Pts,Ou] = intersection_courbe(C1,C2) ;
%
% ---> Fonction de calcul de l'intersection entre 2 courbes C1 et C2 définies par leurs noeuds
%      Si une courbe est une courbe fermée il faut que le premier et le dernier noeud est les 
%      memes coordonnées.
%      Si une seule courbe est entrée nous cherchons les intersectiones avec elle-meme, càd la
%      localisation de boucles
%

%
% 1. Gestion des données d'entrées ...
%
if nargin == 1 ;
    % cas d'une seule courbe
    C2 = C1 ;
end
%
% 2. Calcul des intersections
%
% a) Mise en forme des données
%
dC1 = diff(C1,1,1) ; % Pour les vecteurs M1M2
dC2 = diff(C2,1,1) ; % Pour les vecteur PiPi+1
%
% b) Calcul de la matrice des intesections 
% ---> Segment M1M2
B = dC1(:,1) * dC2(:,2)' - dC1(:,2) * dC2(:,1)' ;
A = C1(1:end-1,1) * dC2(:,2)' - C1(1:end-1,2) * dC2(:,1)' - ...
    ones(size(dC1,1),1) * (C2(1:end-1,1) .* C2(2:end,2) - C2(1:end-1,2) .* C2(2:end,1))' ;
A(find(abs(A) < 10 * eps)) = 0 ; % Prise en compte des erreurs de calcul
warning off
Lambda = -A./B  ;
warning on ;
% ---> Segment PiPi+1
A = dC1(:,1) * C2(1:end-1,2)' -  dC1(:,2) * C2(1:end-1,1)' + ...
    (C1(1:end-1,1) .* C1(2:end,2) - C1(1:end-1,2) .* C1(2:end,1)) * ones(1,size(dC2,1)) ;
A(find(abs(A) < 10 * eps)) = 0 ; % Prise en compte des erreurs de calcul
warning off
Kappa = -A./B ;
warning on
%
% c) Recherche des intersections vraies (c'est à dire pas de parrallélisme)
%
[I,J] = find((Lambda < 1)&(Lambda > 0)&(Lambda ~= NaN)&(abs(Lambda) ~= Inf) & ...
    (Kappa < 1)&(Kappa > 0)&(Kappa ~= NaN)&(abs(Kappa) ~= Inf));
%
% 3. Calcul des coordonnées des intersections
%
if ~isempty(I) ;
    Pts = C1(I,:) + (Lambda(sub2ind(size(Lambda),I,J)) * [1,1]) .* dC1(I,:) ;
    Ou = [I,J] ;
    if nargin == 1 ;
        % ---> Cas d'une seule courbe : cas particulier pour les Ou
        liste = find(abs(diff(Ou,1,2)) ~= 1) ;
        if ~isempty(liste) ;
            Pts = Pts(liste,:) ; Ou = Ou(liste,:) ;
        else
            Pts = [] ; Ou = [] ;
        end
    end
else
    Pts = [] ; Ou = [] ;
end
%
% Fin de la fonction