% Fonction :   [d,point] = distance_point_segment(segment,M) ; 
%
% Version:     1.0 (2000)  
% Langage:     Matlab    Version: 5.3
% Plate-forme: PC windows 98
%___________________________________________________________________________
%
% Niveau de Validation : 1
%___________________________________________________________________________
%
% Description de la fonction : Fonction permettant de calculer la distance 
% entre un point et un segment défini par ces deux points extrémités.
%___________________________________________________________________________
%
% Paramètres d'entrée  : 
%
% Segment : Définition du segment par ses deux extrémités
% Matrice de réels - Real Array (2,n) avec n la dimension de l'espace
%
% M : Point dont on veut connaître la distance au segment
% Vecteur de réels - Real Vector (1,n)
%
% Paramètres de sortie : 
%
% d : valeur de la distance point segment
% Reél positif - positive real
%
% point : Coordonnées du point le plus proche de M appartenant au segment
% Vecteur de réels - Real Vector (1,n)
%___________________________________________________________________________
%
% Mots clefs : Géométrie 
%___________________________________________________________________________
%
% Auteurs :          Sébastien LAPORTE
% Date de création : 25 Avril 2000
% Créé dans le cadre de : Thèse
% Professeur responsable : W.Skalli & D.Mitton
%___________________________________________________________________________
%
% Laboratoire de Biomécanique LBM
% ENSAM C.E.R. de PARIS                          email: lbm@paris.ensam.fr
% 151, bld de l'Hôpital                          tel:   01.44.24.63.63
% 75013 PARIS                                    fax:   01.44.24.63.66
%___________________________________________________________________________
%
% Toutes copies ou diffusions de cette fonction ne peut être réalisée sans
% l'accord du LBM
%___________________________________________________________________________
%
function [d,point] = distance_point_segment(segment,M) ;
%
% Calcul du vecteur directeur normé du segment
%
vecteur_directeur = (segment(2,:) - segment(1,:))/norm(segment(2,:) - segment(1,:)) ;
%
% Calcul du produit vectoriel entre le vecteur extrémité 1 du segment point M et le
% vecteur directeur du segment
%
gamma = sum((M - segment(1,:)).*vecteur_directeur) ;
%
% traitement des cas suivant la valeur de gamma
%
if gamma <= 0 ; % point à gauche du segment
   %
   d = norm(M - segment(1,:)) ; % distance entre point 1 et M 
   point = segment(1,:) ;       % le point le plus proche est le point 1
   %
elseif gamma >= norm(segment(2,:) - segment(1,:)) ; % point à droite du segment
   %
   d = norm(M - segment(2,:)) ; % distance entre point 2 et M
   point = segment(2,:) ;       % le point le plus proche est le point 2
   %
else % cas ou la projection est dans le segment 1 2 
   %
   point = segment(1,:) + gamma * vecteur_directeur ; % point le plus proche est entre I et J 
   d = norm(M - point) ;                              % distance du point au segment
end
%
% La distance est donnée avec 3 chiffres significatifs
%
d = fix(1000 * d) / 1000 ;
%
% fin de la fonction