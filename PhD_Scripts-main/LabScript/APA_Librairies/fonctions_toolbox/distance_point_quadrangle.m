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
% d'un point M à un quadranqle ABCD. Le quadranqle étant orienté (les noeuds 
% sont donnés dans le sens trigonométrique) cette distance est algébrique. 
% De plus il est possible de récupérer les coordonnées du point appartenant
% au quadranqle le plus proche du point M.
%___________________________________________________________________________
%
% Paramètres d'entrée  : 
%
% triangle : Définition du quadrangle par ses quatre sommets
% Matrice de réels - Real Array (4,n) avec n la dimension de l'espace
%
% M : Point dont on veut connaître la distance au quadrangle
% Vecteur de réels - Real Vector (1,n)
%
% Paramètres de sortie : 
%
% d : valeur de la distance algébrique point quadrangle
% Reél - real
%
% point : Coordonnées du point le plus proche de M appartenant au quadrangle
% Vecteur de réels - Real Vector (1,n)
%___________________________________________________________________________
%
% Mots clefs : Géométrie
%___________________________________________________________________________
%
% Auteurs : S.LAPORTE
% Date de création : 10 Mai 2000
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
function [d,Pt] = distance_point_quadrangle(quadrangle,M) ;
%
% Initialisation de la variable d'arrêt de recherche de la distance
%
ecart = 1 ; % ---> permet de rentrer dans la boucle
d_pre = 10000000 ; % ---> première longueur de référence
%
% tant que la différence entre les distances entre les trois point et M est supérieure à 10e-4 mm
%
while ecart > 0.00001 ;
   %
   % Récupération et mise en place des variables
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
   % Création des points N points sur la surface
   % 5 * 5 = 25 
   %
   u = linspace(0,1,5) ; j = 1 ; 
   %
   for ttt = 1:5 ;
      for yyy = 1:5 ;
         %
         % Création du point
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
   % Calcul de l'écart ;
   %
   ecart = abs(d4 - d_pre) ;
   %
   % disp(num2str(ecart))
   %
   d_pre = d4 ;
   %
   % itération suivante
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
% Evaluation du signe de la distance algébrique ....
%
d4signe = sign(sum(vecteur_normal.*(M - Pt))) ;
%
% la distance est donnée avec 3 chiffres significatifs ...
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
[value,ou] = min(d) ; % recherche du minima et du numéro du point
%
% disp(num2str(ou))
% pause
%
% création de C et b 
%
b = value ;       % valeur de la distance minimale
point = B(ou,:) ; % point le plus proche
%
% création du nouveau quadrangle
%
% création des points en cadrant le point le plus proche
%
if (fix(ou/5) - ou/5) == 0 ;
   %
   % cas où yyy = 5
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
