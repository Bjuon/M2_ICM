function G = barycentre_v2(M,Poids) ;
%
% Calcul de la taille de M ;
% les noeuds doivent être écrit les uns sous les autres :
%
[N,Dim] = size(M) ;
%
% Création des poids
%
if nargin == 1 ;
   P = ones(size(M)) ; Poids = ones([N,1]) ;
else
   P = Poids*ones([1,Dim]) ;
end
%
% Calcul du Barycentre
%
G = nansum(P.*M,1)/sum(Poids) ;
%
% fin de la fonction