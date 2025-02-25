function [l,Abscurv] = calcul_longueur_arc(M) ;
%
% Calcul la longueur d'une courbe 
%
N_Pts = size(M,1) ; % nombre de points pour la courbe
%
% Calcul de la longueur :
%
Abscurv(1,1) = 0 ; % abscisse curviligne du point 1
for t = 1:N_Pts-1 ;
   Abscurv(t+1,1) = norm(M(t,:) - M(t+1,:)) + Abscurv(t,1) ;
end
l = Abscurv(end,1) ;
%
% fin de la fonction