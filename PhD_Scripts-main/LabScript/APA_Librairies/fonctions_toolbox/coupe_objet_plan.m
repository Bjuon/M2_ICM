% CCo = Coupe_objet_plan(P,N,Plan) ;
%
% fonction de découpe d'un objet défini par des noeuds et des polygones 
% suivant un plan donné
%
function [CCo,CCoP,Tr,Arr,Dist] = Coupe_objet_plan(P,N,Plan,Arr) ;
%
% 2. Gestion des variables d'entrée
%
if nargin < 4
    Arr = analyse_arretes(P) ; % Définitions des arretes
end
%
% 1. Gestion de la variable Plan
%
[Dist,Plan] = distance_points_plan(N,Plan) ;
%
% 2. Calcul des points du contour de coupe
%
% a) Arretes candidates
%
deltA = Dist(Arr.Definition(:,1)) ; 
deltB = Dist(Arr.Definition(:,2)) ;
Possibles = abs(sign(deltA) + sign(deltB));
Pok = find(Possibles ~= 2) ; clear Possibles ;
if isempty(Pok) ;
    warning('Il n''y a pas d''intersections') ;
    CCo = [] ; CCoP = [] ;
    return
end 
deltA = abs(deltA(Pok)) ;
deltB = abs(deltB(Pok)) ;
%
% b) Calcul des points du contour
% ---> Calcul des points 
warning off
CCo.coord(:,1:3) = (((deltB) * [1,1,1]) .* N(Arr.Definition(Pok,1),:) + ...
    (deltA * [1,1,1]) .* N(Arr.Definition(Pok,2),:)) ...
    ./ ((deltA + deltB) * [1,1,1]) ;
warning on
% Polygones d'appartenance
CCo.Pol = Arr.Polygones(Pok,:) ;
%
% 3. génération des contours
%
CCo.Normale = ones(length(Pok),3) ;
CCo = creer_connections(CCo) ;
CCo = rmfield(CCo,'Normale') ;
CCo.elem = Pok(CCo.elem) ;
%
% 4. Projection des points dans le plan de coupe
%    si demandé
%
if nargout >= 2 ;
    CCoP = CCo ;
    [V,C] = eigs(eye(3) - Plan(2,:)' * Plan(2,:)) ; 
    CCoP.coord = (V'*(CCo.coord - ones(size(CCo.coord,1),1) * Plan(1,:))')' ; 
    % ---> coordonnées à conserver et à éliminer
    ok = find(abs(diag(C)) > 10e-6) ; 
    % ---> Extraction des informations de coordonné
    CCoP.coord = CCoP.coord(:,ok) ;
    % ---> Calcul des éléments de transformation 
    %      entre le plan et l'espace 3D    
    if nargout >= 3 ;
        % ---> Matrice de changement de base
        Tr.M2D3D = V' ;
        % ---> Translation : 
        Tr.Translation = Plan(1,:) ;
    end
end
%
% fin de la fonction