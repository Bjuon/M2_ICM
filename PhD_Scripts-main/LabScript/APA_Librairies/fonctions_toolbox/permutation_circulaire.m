function M2 = permutation_circulaire(M1,Nb) ;
%
% Fonction créant une permutation circulaire dans une matrice colonne 
% du bas vers le haut !
%
if nargin == 1 ; Nb = 1 ; end ; % dans le cas normal seul 1 permutation
%
% Taille de la matrice de points :
%
nb_pts = size(M1,1) ; 
%
% Extraction des valeurs
%
valeurs_fin = M1(nb_pts-Nb+1:end,:) ;
valeurs_debut = M1(1:nb_pts-Nb,:) ;
%
% Création de M2
%
M2 = [valeurs_fin;valeurs_debut] ;
%
% FIN de la fonction