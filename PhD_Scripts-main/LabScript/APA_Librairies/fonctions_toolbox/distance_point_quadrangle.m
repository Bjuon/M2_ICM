% Fonction : [d,point] = distance_point_quadrangle(quadrangle,M) ;   
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
% d'un point M � un quadranqle ABCD. Le quadranqle �tant orient� (les noeuds 
% sont donn�s dans le sens trigonom�trique) cette distance est alg�brique. 
% De plus il est possible de r�cup�rer les coordonn�es du point appartenant
% au quadranqle le plus proche du point M.
%___________________________________________________________________________
%
% Param�tres d'entr�e  : 
%
% triangle : D�finition du quadrangle par ses quatre sommets
% Matrice de r�els - Real Array (4,n) avec n la dimension de l'espace
%
% M : Point dont on veut conna�tre la distance au quadrangle
% Vecteur de r�els - Real Vector (1,n)
%
% Param�tres de sortie : 
%
% d : valeur de la distance alg�brique point quadrangle
% Re�l - real
%
% point : Coordonn�es du point le plus proche de M appartenant au quadrangle
% Vecteur de r�els - Real Vector (1,n)
%___________________________________________________________________________
%
% Mots clefs : G�om�trie
%___________________________________________________________________________
%
% Auteurs : S.LAPORTE
% Date de cr�ation : 10 Mai 2000
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
function [d,Pt] = distance_point_quadrangle(quadrangle,M) ;
%
% Initialisation de la variable d'arr�t de recherche de la distance
%
ecart = 1 ; % ---> permet de rentrer dans la boucle
d_pre = 10000000 ; % ---> premi�re longueur de r�f�rence
%
% tant que la diff�rence entre les distances entre les trois point et M est sup�rieure � 10e-4 mm
%
while ecart > 0.00001 ;
   %
   % R�cup�ration et mise en place des variables
   % ---> pour le quadrangle
   %
   A = quadrangle(1,:) ;
   B = quadrangle(2,:) ;
   C = quadrangle(3,:) ;
   D = quadrangle(4,:) ;
   %
   % ---> pour les vecteurs
   %
   AB = B - A ;
   BC = C - B ;
   AD = D - A ;
   DC = C - D ;
   %
   % Cr�ation des points N points sur la surface
   % 5 * 5 = 25 
   %
   u = linspace(0,1,5) ; j = 1 ; 
   %
   for ttt = 1:5 ;
      for yyy = 1:5 ;
         %
         % Cr�ation du point
         %
         point(j,:) = A(1,:) +  u(ttt)*AB + u(yyy)*(-u(ttt)*AB + AD + u(ttt)*DC) ; 
         %
         j = j + 1 ;
         %
      end
   end
   %
   % Calcul des distances entre les points et M
   %
   for ttt = 1:25 ;
      distance(ttt) = norm(point(ttt,:)-M) ;
   end
   %
   % Recherche de la petite surface la plus proche
   %
   [quadrangle,d4,Pt] = proche(point,distance) ;
   %
   % Calcul de l'�cart ;
   %
   ecart = abs(d4 - d_pre) ;
   %
   % disp(num2str(ecart))
   %
   d_pre = d4 ;
   %
   % it�ration suivante
   %
end
%
% Evaluation de la normale au point Pt ...
%
% proche de la solution nous supposons que le dernier petit quadrangle est quasi plan
% ---> vecteur normal choisi AB x AD
%
% Mise en place des variables
%
A = quadrangle(1,:) ; B = quadrangle(2,:) ; D = quadrangle(4,:) ; C = quadrangle(3,:) ; % ---> pour le quadrangle
AB = B - A ; AD = D - A ; BC = C - B ; DC = C - D ;                                     % ---> pour les vecteurs
%
% Calcul du vecteur normal
%
vecteur_normal = cross(AB,AD) / norm(cross(AB,AD)) ;
%
% Evaluation du signe de la distance alg�brique ....
%
d4signe = sign(sum(vecteur_normal.*(M - Pt))) ;
%
% la distance est donn�e avec 3 chiffres significatifs ...
%
d = d4signe * fix(1000*max(d4))/1000 ; % valeur de la distance
%
% fin de la fonction
%
% #######################################################################################
%
% Sous fonction : [C,b] = proche(B,d)
%
function [C,b,point] = proche(B,d) ;
%
% recherche du point le plus proche
%
[value,ou] = min(d) ; % recherche du minima et du num�ro du point
%
% disp(num2str(ou))
% pause
%
% cr�ation de C et b 
%
b = value ;       % valeur de la distance minimale
point = B(ou,:) ; % point le plus proche
%
% cr�ation du nouveau quadrangle
%
% cr�ation des points en cadrant le point le plus proche
%
if (fix(ou/5) - ou/5) == 0 ;
   %
   % cas o� yyy = 5
   %
   yyy = 5 ; ttt = fix(ou/5) ;
   %
else
   %
   % autres cas
   %
   ttt = fix(ou/5) + 1 ; yyy = ou - (ttt-1) * 5 ;
   %
end
%
% Indice des points pour le calcul des nouveaux
%
% premier point
%
tttn = ttt - 1 ; if tttn == 0 ; tttn = 1 ; elseif tttn == 6 ; tttn = 5 ; end
yyyn = yyy - 1 ; if yyyn == 0 ; yyyn = 1 ; elseif yyyn == 6 ; yyyn = 5 ; end
C(1,:) = B(5*(tttn-1)+yyyn,:) ;
%
% 2 point
%
tttn = ttt + 1 ; if tttn == 0 ; tttn = 1 ; elseif tttn == 6 ; tttn = 5 ; end
C(2,:) = B(5*(tttn-1)+yyyn,:) ;
%
% 3 point
%
yyyn = yyy + 1 ; if yyyn == 0 ; yyyn = 1 ; elseif yyyn == 6 ; yyyn = 5 ; end
C(3,:) = B(5*(tttn-1)+yyyn,:) ;
%
% 4 point
%
tttn = ttt - 1 ; if tttn == 0 ; tttn = 1 ; elseif tttn == 6 ; tttn = 5 ; end
C(4,:) = B(5*(tttn-1)+yyyn,:) ;
%
% fin de la sous fonction
