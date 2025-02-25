% Dim = Dimension_nuage(MPts) ;
%
% Fonction renvoyant les dimensions hors tout d'un nuage :
% i.e. les dimensions du parallélépipède englobant le nuage de points
%
function Dim = Dimension_nuage(MPts) ;
%
Dim = max(MPts) - min(MPts) ;
%
% Fin de la fonction