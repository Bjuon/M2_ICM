% function Mail = creer_barres(P,N)
%
% Fonction de cr�ation de maillage de barre avec une limite de nombre de connection
%
function M = creer_barres(P,N) ;
%
% 0. Gestion des donn�es d'entr�e
%
nP = size(P,1) ; 
if nargin == 1 ;
    % ---> Dans ce cadre toutes les connections sont prises en compte
    N = nP - 1 ;
end
if N > nP - 1 ;
    % ---> Un point ne peut pas ^etre associ� � plus de nP-1 pooints
    N = nP - 1 ;
end
%
% 1. D�finition d'une taille limite de calcul ---> Rapidit� du calcul
%
limite = 1e5 ;
%
% 2. Boucle de cr�ation du maillage de barre
%
% if nP*nP <= limite ;
% ---> Nous sommes sous la valeurs de la limite
Temp = distance_points(P) ; % Calcul de la distance entre tous les points de l'objet
Temp = Temp +  diag(Inf*ones(length(Temp),1)) ;
[Temp,I] = sort(Temp) ;
% ---> Mise en forme du maillage
Temp = I(1:N,:) ;             % S�lection des points utiles
P = ones(N,1) * [1:nP] ;      % Association des points
Temp = reshape(Temp,nP*N,1) ; % Mise en place
P = reshape(P,nP*N,1) ;       % des variables d'�criture
% ---> Premi�re �valuation
M = [P,Temp] ;
% Retrait des doublons
M = sort(M')' ;               % On trie par ordre croissant
M = sortrows(M) ;             % les num�ros de noeuds
k = norm2(diff(M)) ;
k = find(k ~= 0) ; k = [k;size(M,1)] ;
M = M(k,:) ;                  % Retrait des doublons
% end
% 
% Fin de la fonction