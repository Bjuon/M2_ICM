function D = Courbe_condition_tangence(A,B,ta,tb) ;
%
% ---> Nombre de points
%
N = 50 ;
U = linspace(0,1,N)' * [1,1,1] ; 
%
% ---> Fonctions de forme
%
f = [2,-3,0,1] ;
g = [-2,3,0,0] ;
h1 = [1,-1,0,0] ;
h2 = [1,-2,1,0] ;
%
% ---> Calcul des points
%
D = polyval(f,U) .* ((ones(N,1))*A) + ...
    polyval(g,U) .* ((ones(N,1))*B) + ...
    polyval(h2,U) .* ((ones(N,1))*ta) + ...
    polyval(h1,U) .* ((ones(N,1))*tb) ;
%
% Fin de la fonction