function [dist12,dist21] = distance_points_proches(Pts1,Pts2) ;
%
% Fonction permettant de recherche les points les plus proches entre 2 nuages de points
% en prenant le nuage 1 comme nuage de référence puis le nuage 2 ...
% i.e. le nombre de distances calculées sera égal au nombre de points dans Pts2
%

%
% ###############################################################################
% # 1. Calcul des distances entre les différents points de Pts1 et ceux de Pts2 #
% ###############################################################################
%
% ###################################################################################
% # 2. Recherche des valeurs minimales des distances pour chacun des points de Pts2 #
% ###################################################################################
%
Nb = size(Pts2,1) ; % nombre de points dans Pts2
%
% Cas limite : 200 points (pas de calcul)
%
pas = 200 ;
%
% Calcul pas à pas
%
for t = 1:pas:Nb ;
    if t+pas < Nb
        % pour tous les calculs
        Temp = distance_points(Pts1,Pts2(t:t+pas-1,:)) ;
        [dist12.valeurs(t:t+(pas-1)),dist12.ou(t:t+(pas-1))] = min(Temp,[],1) ; 
    else
        % fin des points
        Temp = distance_points(Pts1,Pts2(t:Nb,:)) ;
        [dist12.valeurs(t:Nb),dist12.ou(t:Nb)] = min(Temp,[],1) ; 
    end
end
%
% ###################################################################################
% # 2. Recherche des valeurs minimales des distances pour chacun des points de Pts1 #
% ###################################################################################
% ---> si demandé
%
if nargout == 2 ;
    % ---> Inversion des Pts1 et 2
    Temp = Pts1 ;
    Pts1 = Pts2 ;
    Pts2 = Temp ;
    % ---> Nouvelle longueur de points
    Nb = size(Pts2,1) ; % nombre de points dans Pts2
    %
    % Calcul pas à pas
    %
    for t = 1:pas:Nb ;
        if t+pas < Nb
            % pour tous les calculs
            Temp = distance_points(Pts1,Pts2(t:t+pas-1,:)) ;
            [dist21.valeurs(t:t+(pas-1)),dist21.ou(t:t+(pas-1))] = min(Temp,[],1) ; 
        else
            % fin des points
            Temp = distance_points(Pts1,Pts2(t:Nb,:)) ;
            [dist21.valeurs(t:Nb),dist21.ou(t:Nb)] = min(Temp,[],1) ; 
        end
    end
end
%
% fin de la fonction
