%
% ---> Fonction de calcul rapide de distance points segments
%
function [dist,Pts] = fast_distance_pt_seg(A,B,M) ;
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
end
%
% 1. Calculs des distances au carré
%
IC = norm2(B-A).^2 ;
%
% 2. Calculs des U
%
U = dot(M-A,B-A,2) ./ IC ;
%
% 3. Modification des U
%
I = find(U < 0); U(I) = 0 ;
I = find(U > 1); U(I) = 1 ;
%
% 4. Calcul des points et des distances
%
Pts = A + (U * [1,1,1]) .* (B - A) ;
dist = norm2(M - Pts) ;
%
% ---> Fin de la fonction