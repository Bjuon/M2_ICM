% MP = projection_conique(M3D,Source,Plan) ; 
%
% Fonction de projection conique de points 3D (M3D) avec une Source
% et 1 plan :
%
% M3D :    matrice des points à projeter [N,3]
% Source : point source pour la projection conique [1,3]
% Plan :   plan image : deux possibilités :
%                [2,3] : première ligne ---> point du plan
%                        deuxième ligne ---> normale au plan
%                [1,4] : équation du plan [a,b,c,d] :
%                        ax + by + cz + d = 0 ;
% __________________________________________________________________
%
function [MP,PS] = projection_conique(M3D,S,P) ;
%
% 1. Gestion de la variable P : plan
%
[nl,nc] = size(P) ;
if (nl == 1)&(nc == 4) ;
    % ---> On met en forme [2,3] ;
    Temp(2,1:3) = P(1:3)  ;                              % Pour la normale
    Temp(1,1:3) = - (P(4) / (norm(P(1:3)^2))) * P(1:3) ; % Pour le point
    % ---> On écrase la variable précédante
    P = Temp ;
end
P(2,1:3) = P(2,1:3) / norm(P(2,1:3)) ;                   % Normale normée
%
% 2. Projection de la source S dans le plan P
%
PS = S - dot(S - P(1,:),P(2,:))*P(2,:) ;
%
% 3. Calcul des points projetés
%
NPts = size(M3D,1) ; % Nombre de points 3D 
% ---> Coefficient de colinéarité : SMP = Lambda * SM3D :
Lambda = (ones(NPts,1) * dot(PS - S,P(2,:))) ./ ...
    dot((M3D - ones(NPts,1) * S),ones(NPts,1) * P(2,:),2) ;
% ---> Calcul des points projetés
MP = ones(NPts,1) * S + (M3D - ones(NPts,1) * S).*(Lambda * ones(1,3)) ;
%
% ____ Fin de la fonction ____