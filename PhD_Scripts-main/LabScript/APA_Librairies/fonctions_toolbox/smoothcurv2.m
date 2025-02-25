% C2 = smoothcurv2(C1,Puis) ;
%
% Fonction permettant de lisser une courbe 2D ou 3D
%
function C1 = smoothcurv2(C1,iterations) ;
%
% ##########################################
% ### 0. Gestion des données du filtre : ###
% ##########################################
% ---> Paramètres du filtre lambda Nu et kpb
lambda = .6307 ; nu = - .6732 ; kpb = 1/lambda + 1/nu ;
% ---> Nombre d'itérations de lissage
if nargin == 1 
    iterations = 50 ;
end
%
% ################################
% ### 1. Algorithme de lissage ###
% ################################
%
Arr = [[1:size(C1,1)-1]',[2:size(C1,1)]'] ;
%
% Création des poids : 
%
C = spdiags([0.5 * ones(size(C1,1),1),0.5 * ones(size(C1,1),1)],[1,-1],size(C1,1),size(C1,1)) ;
C(1,2) = 1 ; C(end,end-1) = 1 ;
%
% Boucle de lissage : plusieurs possibilités : création des poids, de
% l'opérateur laplacien, ...
%
for t = 1:iterations
    %
    % création de l'opérateur Laplacien K :
    %
    K = sparse(size(C1,1),size(C1,1)) ;
    K = speye(size(C)) - C ; 
    %
    % création de l'opérateur de lissage f(K) : K modifié
    %
    if (t/2) - fix(t/2) ~= 0 ;
        % Utilisation de lambda :
        K = speye(size(K)) - lambda * K ;
    else
        % Utilisation de nu
        K = speye(size(K)) - nu * K ;
    end
    %
    % calcul des nouveaux points :  autant de fois que la puissance demandée
    %
    C2 = K * C1 ;
    %
    % replaçons les points 1 et final
    %
    C1 = [C1(1,:);C2(2:end-1,:);C1(end,:)] ;
end
%
% Fin de la fonction