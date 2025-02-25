function [Pts,Err] = Intersection_de_droites(droites1,droites2) ;
%
% Récupération du nombre d'intersections à calculer ...
%
N_int = size(droites1.pts,1) ;
%
% Calculs réalisés pour chacun des couples de droites ...
%
for ttt = 1:N_int ;
   %
   % calcul du produit scalaire entre les 2 vecteurs directeurs ...
   %
   n1n2 = sum(droites1.V_dir(ttt,:).*droites2.V_dir(ttt,:)) ;
   %
   % Ainsi que leurs normes
   %
   n1n1 = sum(droites1.V_dir(ttt,:).*droites1.V_dir(ttt,:)) ;
   n2n2 = sum(droites2.V_dir(ttt,:).*droites2.V_dir(ttt,:)) ;
   %
   % calcul du vecteur p1p2
   %
   P1P2 = droites2.pts(ttt,:) - droites1.pts(ttt,:) ;
   %
   % calculs des produits scalaires p1p2.n1 et p1p2.n2
   %
   P1P2n1 = sum(droites1.V_dir(ttt,:).*P1P2) ;
   P1P2n2 = sum(droites2.V_dir(ttt,:).*P1P2) ;
   %
   % Création des matrices de calculs
   %
   A(1,1) = n1n1 ; A(2,2) = n2n2 ; A(1,2) = - n1n2 ; A(2,1) = - n1n2 ;
   V(1,1) = P1P2n1 ; V(2,1) = -P1P2n2 ;
   %
   % Coefficients linéaires points les plus proches
   %
   Coefs = inv(A)*V ; 
   %
   % Calcul des coordonnées des point M et N les plus proches sur les 2 droites
   %
   OM = droites1.pts(ttt,:) + Coefs(1,1) * droites1.V_dir(ttt,:) ; % droite n°1
   ON = droites2.pts(ttt,:) + Coefs(2,1) * droites2.V_dir(ttt,:) ; % droite n°2
   %
   % L'intersection est définie comme étant le milieu du segment MN
   %
   Pts(ttt,:) = (OM + ON) / 2 ;
   %
   % L'erreur est la moitié de la distance MN
   %
   Err(ttt,1) = 0.5 * norm(OM - ON) ;
   %
   % Cas suivant
   %
end
%
% Fin de la fonction