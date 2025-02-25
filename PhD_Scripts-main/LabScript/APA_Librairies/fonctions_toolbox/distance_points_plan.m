function [D,Plan] = distance_points_plan(N,Plan) ;
%
% 1. Gestion de la variable Plan
%
[nl,nc] = size(Plan) ;
if (nl == 1)&(nc == 4) ;
    % ---> On met en forme [2,3] ;
    Temp(2,1:3) = Plan(1:3)  ;                                    % Pour la normale
    Temp(1,1:3) = - (Plan(4) / (norm(Plan(1:3).^2))) * Plan(1:3) ; % Pour le point
    % ---> On écrase la variable précédante
    Plan = Temp ;
end
Plan(2,1:3) = Plan(2,1:3) / norm(Plan(2,1:3)) ;                   % Normale normée
%
% 2. Calcul des distances signées des points au plan 
%
D = sum((N - ones(length(N),1)*Plan(1,:)) .* (ones(length(N),1) * Plan(2,:)),2) ;
%
% Fin de la fonction