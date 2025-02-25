function B = norm2(A)
%
% Calcul la norme d'un tableau de vecteurs en ligne
%
B = sqrt(sum(A.^2,2)) ;
%
% fin de la fonction