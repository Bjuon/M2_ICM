% function [N,P,Info_N,Info_P] = smoothmov(N,P,Puissance,Info_N,Info_P)
%
% Fonction permettant de lisser les objets de type movie
% __________________________________________________________________________
%
function [N,P,Info_N,Info_P] = smoothmov(N,P,Puissance,Info_N,Info_P)
%
% 1. Gestion des données d'entrées
%
if nargin < 5 ;
    % ---> Il faut calculer les infos sur les polygones
    [Info_P,P] = analyse_geometrie_polygones(P,N) ;
    if nargout == 1 ;
        warning('Les modifications du maillage ne seront pas sauvegardées') ;
    end
end
if nargin < 4 ;
    % ---> Il faut calculer les infos sur les noeuds
    [Info_N,Info_P,P] = Calcul_normale_noeuds(N,P,Info_P) ;
end
if nargin < 3 ;
    % ---> réglage de la puissance 
    Puissance = 1 ;
end
%
% 2. Boucle de lissage : autant de fois que la puissance demandée
%
for k = 1:Puissance ;
    % ---> Nombre mini et maxi de polygones pour 1 Noeud
    max_pol = max(Info_N.Nb_Polygones) ;
    min_pol = min(Info_N.Nb_Polygones) ;
    % ---> Initialisation des déplacements de points
    DP = zeros(length(N),1) ;
    Di = zeros(length(N),3) ;
    % ---> Nous traitons maintenant par bloc les différents noeuds
    for t = min_pol:max_pol ;
        liste = find(Info_N.Nb_Polygones == t) ;
        % ---> Traitement si la liste n'est pas vide :
        if ~isempty(liste) ;
            % ---> liste des polygones pour chacun des noeuds :
            I = [Info_N.Appartient{liste}]  ;
            I = reshape(I,t,length(liste))' ;
            % ---> Calcul des barycentres pondérés pour les barycentres de facettes
            G = zeros(length(liste),3) ;  % Init des barycentres
            Ng = zeros(length(liste),3) ; % Init des normales barycentres
            S = zeros(length(liste),3) ;  % Init des surfaces
            for y = 1:t ;
                G = G + (Info_P.Barycentre(I(:,y),:))./(Info_P.Surface(I(:,y)) * ones(1,3)) ;
                Ng = Ng + (Info_P.Normale(I(:,y),:))./(Info_P.Surface(I(:,y)) * ones(1,3)) ;
                S = S + 1./(Info_P.Surface(I(:,y)) * ones(1,3)) ;
            end
            G = G ./ S ;
            % ---> Calcul du déplacement des points
            Di(liste,:) = Ng ./ S ;
            DP(liste,1) = 0.1 * sum((G-N(liste,:)).*Di(liste,:),2) ;
            % DP(liste,1) = sum((G-N(liste,:)).*Di(liste,:),2) ;
        end
    end 
    % ---> Calcul du déplacement moyen en valeur absolue
    DP_moy = ones(length(N),3) * mean(abs(DP)) ;
    N =  (DP * ones(1,3) + DP_moy) .* Di + N ;
    [Info_N,Info_P,P] = Calcul_normale_noeuds(N,P) ;
end
%
% fin de la fonction