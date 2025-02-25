function P_clean = nettoie_points_proches(P,width)
%% Fonction qui dans un vecteur colonne va éliminer les éléments dont la distance est < width en les remplacants par leur moyenne
% P : vecteur 1D à nettoyer
% width : taille de l'espacement minimal (defaut == 5)

for i=2:length(P)
    if abs(P(i-1)-P(i))<=width
        P_clone = floor(mean([P(i-1) P(i)]));
        P(i-1) = P_clone;
        P(i) = NaN;
    end
end

P_clean = unique(P);
P_clean(isnan(P_clean))=[];