function [ind APAy] = trouve_APAy(CP_ML)
%% Calcul du min/max lors des APA (entre T0 et HO) du déplacement ML du CP
% CP_ML  : vecteur colonne du déplacement du CP (supposé jusqu'au décollement du talon (Heel-Off))
% Sorties
% ind : indice/frame d'occurence de l'extrema recherché
% APAy : valeur absolue de ce déplacement max (par rapport à la position initiale)
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