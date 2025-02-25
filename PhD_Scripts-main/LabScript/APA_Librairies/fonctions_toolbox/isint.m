function Is = isint(Val) ;
%
% Renvoie 1 si le nombre est entier et 0 sinon
%
Is =  (Val - fix(Val) == 0) ;
%
% Fin