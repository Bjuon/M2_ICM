function B = renumt(A,av,ap) ;
%
% fonction renumérotant un tableau i.e. changeant les valeurs 
% avec de nouvelles
%
B = A ;
for t = 1:length(av) ;
    qui = find(A == av(t)) ;
    B(qui) = ap(t) ;
end
%
% Fin de la fonction