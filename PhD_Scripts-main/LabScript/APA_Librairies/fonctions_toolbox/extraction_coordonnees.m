function MN = extraction_coordonnees(M) ;
%
% Explications : pas encore réfléchie
%

%
% 1. liste numérique des points contenus dans M
%
liste = [1:size(M,1)] ;
%
% 2. calcul des distances entre les points
%
Mq = distance_points(M) ;
%
% 3. recherche des doublons
%
cmpt = 1 ; % compteur de points finaux
pt = 1 ; 
%
while 1 
    % ---> Récupération des coordonnées
    MN(cmpt,:) = M(pt,:) ; cmpt = cmpt + 1 ;
    % ---> Notification des points de memes coordonnées
    liste(find(Mq(pt,:) == 0)) = 0 ;
    % ---> Recherche du prmier point non traité
    x = find(liste ~= 0); 
    if isempty(x) ;
        break ;
    end
    pt = liste(x(1)) ;
end
%
% fin de la fonction
    