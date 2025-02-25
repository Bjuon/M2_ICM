function [Pts2,Recalage] = Recalage_moindres_carres(Pts1,Pts2,precision) ;
%
% Cette fonction permet d'optimiser le calage de 2 nuages de N points appareill�s
% par une m�thode de moindres carr�s ... Pour le moment pour des nuages 3D
%


% Si la pr�cision n'est pas sp�cifi�e celle-ci sera �gale � 0.001
if nargin == 2 ;
   precision = 0.001 ;
end
%
% ##################################
% # 0. Initialisation de variables #
% ##################################
%
% 0.a. Gestion des nombres de points dans les nuages
%
[N1,Dim] = size(Pts1);   % Nombre de points dans les nuages
N2 = length(Pts2) ;
if N2 ~= N1 ;
   % Pas autant de points dans les deux nuages de points
   warning(['Pas le meme nombre de points dans les deux nuages : ',...
         'Pts1 n''est pas modifi� ...'])
   Recalage = [] ;
   return
end
%
% 0.b. Initialisation des variables pour le calcul en boucle (i.e. lin�arisation des rotations)
%
Recalage.translation = zeros(Dim,1) ;
Recalage.MR2R1 = eye(Dim) ;
ecart = 1 ;
%
% ---------- Calcul du recalage par les moindres carr�s ---------------------------
%
while ecart > precision ;
   %
   % ############################################################################ 
   % # 1. Cr�ation de la matrice des moindres carr�s ---> Rapport au nuage Pts2 #
   % ############################################################################ 
   % la matrice peut etre d�finie en 4 sous matrices : A11, A12 et A12' , A22
   %
   % 1.a. Matrice A11 : simplement une matrice 3x3 avec N sur la diagonale
   %
   A11 = N1 * eye(Dim) ;
   %
   % 1.b. Matrice A12 : fait intervenir les sommes des diff�rentes coordon�es
   %
   S = sum(Pts2) ; % Calcul des sommes des x, y et z
   if Dim == 3 ;
       A12 = [0,S(3),-S(2);-S(3),0,S(1);S(2),-S(1),0] ;
   elseif Dim == 2 ;
       A12 = [-S(2);S(1)] ;
   end
   %
   % 1.c. Matrice A22 : fait intervenir les "inerties"
   %
   I = Pts2'*Pts2 ;
   C = trace(I)*eye(Dim) ;     
   if Dim == 3 ;
       A22 = C - I ;
   elseif Dim == 2 ;
       A22 = trace(I) ;
   end
   %
   % 1.d. Assemblage de la matrice : 
   %
   A = [A11,A12;A12',A22] ;
   %
   % ############################################### 
   % # 2. Cr�ation du vecteurs des moindres carr�s #
   % ###############################################
   % le vecteur peut etre d�fini en 2 sous vecteurs B1 et B2
   %
   % 2.a. Vecteur B1 : somme des vecteurs entre les points appareill�s
   %
   B1 = (sum(Pts1-Pts2))' ;
   %
   % 2.b. Vecteur B2 : somme des produits vectoriels de vecteurs points appareill�s
   %
   if Dim == 3 ;
       B2 = (sum(cross(Pts2,Pts1)))' ;
   elseif Dim == 2 ;
       Temp = Pts1'*Pts2 ;
       B2 = Temp(2,1) - Temp(1,2) ;
   end
   %
   % 2.c. Assemblage du vecteur :
   %
   B = [B1;B2] ;
   %
   % ###############################################
   % # 3. R�solution du syst�me de moindres carr�s #
   % ###############################################
   %
   X = inv(A)*B ;
   %
   % ######################################
   % # 4. Modification des points de Pts2 #
   % ######################################
   %
   % 4.a. Extraction de la translation 
   %
   if Dim == 3 ;
       Trans = X(1:3,1)' ;
   elseif Dim == 2 ;
       Trans = X(1:2,1)' ;
   end
   Tc = ones(N1,1) * Trans ; % mise en forme pour le calcul
   %
   % 4.b. Extraction des rotations
   %
   if Dim == 3 ;
       Rot = X(4:6,1)' ; % pour les rotations
       % ---> matrices de rotation �l�mentaire
       A1 = [1,0,0;0,cos(Rot(1)),-sin(Rot(1));0,sin(Rot(1)),cos(Rot(1))] ;
       B2 = [cos(Rot(2)),0,sin(Rot(2));0,1,0;-sin(Rot(2)),0,cos(Rot(2))] ;
       C3 = [cos(Rot(3)),-sin(Rot(3)),0;sin(Rot(3)),cos(Rot(3)),0;0,0,1] ;
       % ---> matrice globale de rotation (X,Y',Z'')
       R = A1*B2*C3 ;
   elseif Dim == 2 ;
       R = [cos(X(3)),-sin(X(3));sin(X(3)),cos(X(3))] ;
   end
   %
   % 4.c. D�placement des points
   %
   Pts2 = Tc + (R * Pts2')' ;
   %
   % ################################################
   % # 5. Saugegarde des valeurs de transformations #
   % ################################################
   %
   Recalage.translation = Trans'+ R*Recalage.translation ;
   Recalage.MR2R1 = R*Recalage.MR2R1 ;
   %
   % #######################################################
   % # 6. Calcul de la variable de suite de l'optimisation #
   % #######################################################
   %
   ecart = max(abs(X)) ;
end
%
% FIN DE LA FONCTION