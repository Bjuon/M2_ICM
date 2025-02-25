function CourbureN = calcul_courbure_N(MK,N)
%
% Calcul de la courbure dans une direction N donnée
%

%
% ---> par précaution on norme N 
%
N = N ./ norm2(N) ;
%
% ---> calcul de la coubure en N
%
CourbureN = squeeze(MK(1,1,:) * N(1)^2 + MK(2,2,:) * N(2)^2 + MK(3,3,:) * N(3)^2 + ...
    2 * MK(1,2,:) * N(1) * N(2) + 2 * MK(1,3,:) * N(1) * N(3) + 2 * MK(2,3,:) * N(2) * N(3)) ;
%
% ---> Fin de la fonction