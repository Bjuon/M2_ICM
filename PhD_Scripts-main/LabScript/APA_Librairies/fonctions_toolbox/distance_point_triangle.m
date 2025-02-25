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
% d'un point M � un triangle ABC. Le triangle �tant orient� (les noeuds sont donn�s
% dans le sens trigonom�trique) cette distance est alg�brique. De plus il est
% possible de r�cup�rer les coordonn�es du point appartenant au triangle le 
% plus proche du point M.
%___________________________________________________________________________
%
% Param�tres d'entr�e  : 
%
% triangle : D�finition du triangle par ses trois sommets
% Matrice de r�els - Real Array (3,n) avec n la dimension de l'espace
%
% M : Point dont on veut conna�tre la distance au triangle
% Vecteur de r�els - Real Vector (1,n)
%
% Param�tres de sortie : 
%
% d : valeur de la distance alg�brique point triangle
% Re�l - real
%
% point : Coordonn�es du point le plus proche de M appartenant au triangle
% Vecteur de r�els - Real Vector (1,n)
%___________________________________________________________________________
%
% Fichiers, Fonctions ou Sous-Programmes associ�s :
% distance_point_segment, fichier matlab .m
%___________________________________________________________________________
%
% Mots clefs : G�om�trie,
%___________________________________________________________________________
%
% Auteurs : S.LAPORTE
% Date de cr�ation : 10 MAI 2000
% Cr�� dans le cadre de :  Th�se
% Professeur responsable : W.Skalli & D.Mitton
%___________________________________________________________________________
%
% Laboratoire de Biom�canique LBM
% ENSAM C.E.R. de PARIS                          email: lbm@paris.ensam.fr
% 151, bld de l'H�pital                          tel:   01.44.24.63.63
% 75013 PARIS                                    fax:   01.44.24.63.66
%___________________________________________________________________________
%
% Toutes copies ou diffusions de cette fonction ne peut �tre r�alis�e sans
% l'accord du LBM
%___________________________________________________________________________
%
function [d,point] = distance_point_triangle(triangle,M) ;
%
% Mise en forme des donn�es pour le traitement 
%
A = triangle(1,:); B = triangle(2,:); C = triangle(3,:); 
%
% Calcul des coordonn�es de la projection de M dans le rep�re (A,AB,AC) :
%
Mat(1,1) = norm(B-A)^2 ; Mat(2,2) = norm(C-A)^2; % terme diagonaux de la matrice
Mat(2,1) = sum((B-A).*(C-A)) ; Mat(1,2) = Mat(2,1) ; % matrice sym�trique
%
V(1,1) = sum((M-A).*(B-A)) ; % vecteur r�sultat
V(2,1) = sum((M-A).*(C-A)) ; % 
%
coor = inv(Mat)*V ; % coordonn�es dans le plan 
%
% Calcul du vecteur normal norm� au plan contenant le triangle 
%
vecteur_normal = cross((B-A),(C-A)) ;                    % AB x AC  d�fini le demi espace + et le -
vecteur_normal = vecteur_normal/(norm(vecteur_normal)) ; % norme = 1
%
% Nous pouvons alors calculer la distance alg�brique au plan
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
   % Evaluation des coordonn�es de N point le plus proche de M appartenant au triangle
   %
   point = A + coor(1) * (B-A) + coor(2) * (C-A) ; % avec les coordonn�es de la projection 
   %
   return % fin de la fonction dans ce cas
   %
end
%
% Cas o� la projection n'est pas dans le triangle
%
demi = sign(d) ; % dans quel demi espace ce trouve M
if d == 0 ; d = 1 ; end % cas o� le point est dans le plan du triangle
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
   % deuxi�me point ...
   %
end
%
% Calcul de la distance du point au segment [Pt(1),Pt(2)] et r�cup�ration du point le plus proche
%
[d,point] = distance_point_segment(Pt,M) ;
%
% Il faut maintenant donner le bon signe � la distance alg�brique
%
d = demi * d ;
%
% fin de la fonction