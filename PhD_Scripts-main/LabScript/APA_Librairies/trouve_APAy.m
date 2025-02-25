function [ind APAy] = trouve_APAy(CP_ML)
%% Calcul du min/max lors des APA (entre T0 et HO) du d�placement ML du CP
% CP_ML  : vecteur colonne du d�placement du CP (suppos� jusqu'au d�collement du talon (Heel-Off))
% Sorties
% ind : indice/frame d'occurence de l'extrema recherch�
% APAy : valeur absolue de ce d�placement max (par rapport � la position initiale)
if length(CP_ML)>10
    [Mx Mn] = MaxMin(CP_ML);
    
    try
        ind =find(CP_ML==max(abs(CP_ML(sort([Mx Mn])))));
    catch ERR
        disp('Erreur calcul APAy');
        ind = 1;
        APAy = NaN;
    end
    % %Affichage
    % plot(CP_ML); hold on
    % plot(ind,CP_ML(ind),'x','Markersize',11);

    APAy = abs(mean(CP_ML(1:10)) - CP_ML(ind));
else
    ind = 1;
    APAy = NaN;
end

end