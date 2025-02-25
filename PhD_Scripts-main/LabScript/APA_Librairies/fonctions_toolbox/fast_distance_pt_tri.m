%
% ---> Fonction de calcul rapide de distance points triangles
%
function [dist,Pts] = fast_distance_pt_tri(A,B,C,M) ;
%
% 0. Gestion des données d'entrées
%
Nt = size(A,1) ; % Nombre de triangles
Np = size(M,1) ; % Nombre de points
% 
if (Nt > Np) & (Np == 1) ;
  % ---> Nous duplicons les points
  M = ones(Nt,1) * M ;
elseif (Np > Nt) & (Nt == 1) ;
  % ---> Nous duplicons les triangles
  A = ones(Np,1) * A ;
  B = ones(Np,1) * B ;
  C = ones(Np,1) * C ;
end
%
% 1. Calcul des déterminants ...
%
DetM = (norm2(B-A).^2) .* (norm2(C-A).^2) - dot(B-A,C-A,2).^2 ;
%
% 2. Calcul des U & V ...
%
U = ((norm2(C-A).^2).*(dot(M-A,B-A,2)) - dot(B-A,C-A,2).*dot(M-A,C-A,2)) ./ DetM ;
V = ((norm2(B-A).^2).*(dot(M-A,C-A,2)) - dot(B-A,C-A,2).*dot(M-A,B-A,2)) ./ DetM ;
%
% 3. Calcul des points & des distances
%
Pts = A + (U * [1,1,1]).*(B-A) + (V * [1,1,1]).*(C-A) ;
dist = norm2(M - Pts)' ;
%
% 4. Modification des U & V :
%
I = find((U < 0) | (V < 0) | (U + V > 1)) ; % ---> Liste des points ne se projettant pas dans le triangle
if ~isempty(I) ;
  % ---> Pour ces points nous calculons la distance avec avec les segments
  [dist1,Pts1] = fast_distance_pt_seg(A(I,:),B(I,:),M(I,:)) ;
  [dist2,Pts2] = fast_distance_pt_seg(B(I,:),C(I,:),M(I,:)) ;
  [dist3,Pts3] = fast_distance_pt_seg(C(I,:),A(I,:),M(I,:)) ;
  % ---> Nous recherchons le plus proches
  [dist(I),ou] = min([dist1,dist2,dist3],[],2) ;
  J = find(ou == 1) ; Pts(I(J),:) = Pts1(J,:) ; % Pour le point 1
  J = find(ou == 2) ; Pts(I(J),:) = Pts2(J,:) ; % Pour le point 2
  J = find(ou == 3) ; Pts(I(J),:) = Pts3(J,:) ; % Pour le point 3
end
%
% ---> Fin