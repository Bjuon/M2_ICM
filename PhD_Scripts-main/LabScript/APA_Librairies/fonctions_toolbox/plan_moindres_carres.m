function [normale,Point] = plan_moindres_carres(M) ;
%
% les noeuds doivent être écrit les uns sous les autres 
% afin que la fonction fonctionne correctement
% ---> Modif afin de prendre en compte toute les possibilités d'écriture d'un plan
% 

%
% Calcul du Point pour le plan des moindres carrés : Barycentre
%
Point = Barycentre(M) ;
P = M - ones(size(M,1),1) * Point ;
%
% Calcul du vecteur normal au plan : vecteur propre de P'*P associé à la plus petite valeur propre
%
[Vectors,ValeursP] = eigs(P'*P) ; % ---> Calcul des vecteurs propres et valeurs propres
ValeursP = diag(ValeursP) ;       % ---> Mise en vecteur
[value,ou] = min(ValeursP) ;      % ---> Recherche du minima
normale = Vectors(:,ou) ; normale = normale / norm(normale) ;
%
% Fin de la fonction