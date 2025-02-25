% Fonction : [d,point] = distance_point_triangle(triangle,M)   
%
% Version:     1.1 (2000)  
% Langage:     Matlab    Version: 5.3
% Plate-forme: PC windows 98
%___________________________________________________________________________
%
% Niveau de Validation : 1
%___________________________________________________________________________
%
% Description de la fonction : Fonction permettant de calculer la distance 
% d'un point M à un triangle ABC. Le triangle étant orienté (les noeuds sont donnés
% dans le sens trigonométrique) cette distance est algébrique. De plus il est
% possible de récupérer les coordonnées du point appartenant au triangle le 
% plus proche du point M.
%___________________________________________________________________________
%
% Paramètres d'entrée  : 
%
% triangle : Définition du triangle par ses trois sommets
% Matrice de réels - Real Array (3,n) avec n la dimension de l'espace
%
% M : Point dont on veut connaître la distance au triangle
% Vecteur de réels - Real Vector (1,n)
%
% Paramètres de sortie : 
%
% d : valeur de la distance algébrique point triangle
% Reél - real
%
% point : Coordonnées du point le plus proche de M appartenant au triangle
% Vecteur de réels - Real Vector (1,n)
%___________________________________________________________________________
%
% Fichiers, Fonctions ou Sous-Programmes associés :
% distance_point_segment, fichier matlab .m
%___________________________________________________________________________
%
% Mots clefs : Géométrie,
%___________________________________________________________________________
%
% Auteurs : S.LAPORTE
% Date de création : 10 MAI 2000
% Créé dans le cadre de :  Thèse
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
function [d,point] = distance_point_triangle(triangle,M) ;
%
% Mise en forme des données pour le traitement 
%
A = triangle(1,:); B = triangle(2,:); C = triangle(3,:); 
%
% Calcul des coordonnées de la projection de M dans le repère (A,AB,AC) :
%
Mat(1,1) = norm(B-A)^2 ; Mat(2,2) = norm(C-A)^2; % terme diagonaux de la matrice
Mat(2,1) = sum((B-A).*(C-A)) ; Mat(1,2) = Mat(2,1) ; % matrice symétrique
%
V(1,1) = sum((M-A).*(B-A)) ; % vecteur résultat
V(2,1) = sum((M-A).*(C-A)) ; % 
%
coor = inv(Mat)*V ; % coordonnées dans le plan 
%
% Calcul du vecteur normal normé au plan contenant le triangle 
%
vecteur_normal = cross((B-A),(C-A)) ;                    % AB x AC  défini le demi espace + et le -
vecteur_normal = vecteur_normal/(norm(vecteur_normal)) ; % norme = 1
%
% Nous pouvons alors calculer la distance algébrique au plan
% si M dans demi-espace positif d > 0
% si M dans demi-espace negatif d < 0
%
d = sum((M-A).*vecteur_normal) ;
%
% Test pour savoir si la projection orthogonale de M est dans le triangle
%
if ((coor(1)>=0)&(coor(1)<=1))&((coor(2)>=0)&(coor(2)<=(1-coor(1)))) ;
   %
   % dans ce cas d est la distance au plan ...
   %
   % Evaluation des coordonnées de N point le plus proche de M appartenant au triangle
   %
   point = A + coor(1) * (B-A) + coor(2) * (C-A) ; % avec les coordonnées de la projection 
   %
   return % fin de la fonction dans ce cas
   %
end
%
% Cas où la projection n'est pas dans le triangle
%
demi = sign(d) ; % dans quel demi espace ce trouve M
if d == 0 ; d = 1 ; end % cas où le point est dans le plan du triangle
%
% ---> calcul des distances entre le point et les sommets du triangle
%
dA = norm(M-A); dB = norm(M-B); dC = norm(M-C);
distances = [dA dB dC] ;
%
% choix des deux points les plus proche
%
for ttt = 1:2 ;
   %
   [val,ou] = min(distances) ;  % recherche du minima
   Pt(ttt,:) = triangle(ou,:) ; % point le plus proche
   %
   % pour ce point distances devient maximale
   %
   distances(ou) = Inf ;
   %
   % deuxième point ...
   %
end
%
% Calcul de la distance du point au segment [Pt(1),Pt(2)] et récupération du point le plus proche
%
[d,point] = distance_point_segment(Pt,M) ;
%
% Il faut maintenant donner le bon signe à la distance algébrique
%
d = demi * d ;
%
% fin de la fonction