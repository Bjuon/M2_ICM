%
% Fonction de recalage élastique de 2 nuages de points
%
function [Pts2,Recalage] = Recalage_elastique_2D(Pts1,Pts2)
%
% 1. Recherche de la compatibilité entre les données d'entrée
%
[N1,Dim1] = size(Pts1) ; [N2,Dim2] = size(Pts2) ;
if (N1~=N2)|(Dim1~=2)|(Dim2~=2) ;
    error('Erreur : données incompatibles avec la fonction ...') ;
end
%
% 2. Calcul du recalage 
%
% a) Matrice de calcul :
%
Sommes2 = sum(Pts2) ; Sommes1 = sum(Pts1) ; % ---> Vecteurs des sommes des coordonnées de points
Mat = Pts2' * Pts2 ;                        % ---> Matrice des produits de coordonnées pour le nuage 2
V1 = reshape(Pts2'*Pts1,4,1)  ;             % ---> Vecteur des produits de coordonnées entre 1 & 2
%
% b) Création de la matrice :
%
MP = [eye(2)*N1,[Sommes2;zeros(1,2)],[zeros(1,2);Sommes2];...
        [Sommes2;zeros(1,2)]',Mat,zeros(2,2);...
        [zeros(1,2);Sommes2]',zeros(2,2),Mat] ;
%
% c) Création du vecteur
%
VC = [Sommes1';V1] ;
%
% d) Résolution du système :
%
Temp = inv(MP) * VC ;
%
% 3. Traitement du recalage :
%
% a) Extraction de la tranlation :
%
Recalage.Translation = Temp(1:2,1)' ;
%
% b) Extraction de la matrice de rotation homotétie
%
Recalage.Matrice = reshape(Temp(3:6,1),2,2)' ;
%
% c) Calcul des coefficients homotétiques
%
Recalage.kx = sqrt(Temp(3)^2 + Temp(5)^2) ;
Recalage.ky = sqrt(Temp(4)^2 + Temp(6)^2) ;
%
% d) Calcul de l'angle de rotation en radian
%
Recalage.alpha = acos(Temp(3)/Recalage.kx) ;
if Temp(5) < 0 ;
    Recalage.alpha = - Recalage.alpha ;
end
%
% Fin de la fonction