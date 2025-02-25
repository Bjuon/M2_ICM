% C2 = smoothcurv2(C1,Puis) ;
%
% Fonction permettant de lisser une courbe 2D ou 3D
%
function C1 = smoothcurv2(C1,iterations) ;
%
% ##########################################
% ### 0. Gestion des donn�es du filtre : ###
% ##########################################
% ---> Param�tres du filtre lambda Nu et kpb
lambda = .6307 ; nu = - .6732 ; kpb = 1/lambda + 1/nu ;
% ---> Nombre d'it�rations de lissage
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
% Cr�ation des poids : 
%
C = spdiags([0.5 * ones(size(C1,1),1),0.5 * ones(size(C1,1),1)],[1,-1],size(C1,1),size(C1,1)) ;
C(1,2) = 1 ; C(end,end-1) = 1 ;
%
% Boucle de lissage : plusieurs possibilit�s : cr�ation des poids, de
% l'op�rateur laplacien, ...
%
for t = 1:iterations
    %
    % cr�ation de l'op�rateur Laplacien K :
    %
    K = sparse(size(C1,1),size(C1,1)) ;
    K = speye(size(C)) - C ; 
    %
    % cr�ation de l'op�rateur de lissage f(K) : K modifi�
    %
    if (t/2) - fix(t/2) ~= 0 ;
        % Utilisation de lambda :
        K = speye(size(K)) - lambda * K ;
    else
        % Utilisation de nu
        K = speye(size(K)) - nu * K ;
    end
    %
    % calcul des nouveaux points :  autant de fois que la puissance demand�e
    %
    C2 = K * C1 ;
    %
    % repla�ons les points 1 et final
    %
    C1 = [C1(1,:);C2(2:end-1,:);C1(end,:)] ;
end
%
% Fin de la fonction