function [t0 indT0]=calcul_APA_T0_v4(xCP,t,flag)
%% Calcul du T0 à partir de la technique des change-points (Taylor 2000)
% (t0,indT0) = coordonnés de T0 (1er évt Biomécanique lors de l'initiation du pas)

% Données d'entrées : xCP: positions du CP, t : durée de l'intervalle à étudier, 
%                     flag : flag d'affichage

t0 = NaN;
indT0 = NaN;


try
    T0s = change_point_analysis_cusum(xCP,0,flag);
catch NO_display
    T0s = change_point_analysis_cusum(xCP);
end

%Sur le signal ML en fonction de Gauche/Droite on capte le 1er changement de courbure
indT0_ML = NaN;
try
    if ~isempty(T0s(1).derive_positive)
        indT0_ML = T0s(1).derive_positive(1);
    end
    if ~isempty(T0s(1).derive_negative)
        indT0_ML(2) = T0s(1).derive_negative(1);
    end
catch NO_ML
    indT0_ML = NaN;
end

%Sur le signal AP on capte le 1er changement de courbure négative
try
    indT0_AP = T0s(1).derive_negative(1);
catch NO_AP
    indT0_AP = NaN;
end

indT0 = min([indT0_ML indT0_AP]);
t0 = t(indT0);

end