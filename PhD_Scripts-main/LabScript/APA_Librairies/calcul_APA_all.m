function [evts]=calcul_APA_all(CP,t,flag)
%% Calcul automatique des ev�nements du pas � partir de la technique des change-points (Taylor 2000)
% evts = T0 TO FC1 FO2 FC2
% Donn�es d'entr�es : CP: positions ML et AP du CP, t : dur�e de l'interval � �tudier, 
%                     flag : flag d'affichage

evts(1:5)=NaN;

%% ON utilise 2 it�rations lors de l'analyse change-points car nous supposons qu'il y'a 4 diff�rents r�gimes du CP lors du 1er cycle de marche
try
    Pts = change_point_analysis_cusum(CP,2,flag);
catch NO_display
    Pts = change_point_analysis_cusum(CP);
end

All_ML = sort([Pts(1).derive_negative Pts(1).derive_positive]);
All_AP = sort([Pts(2).derive_negative Pts(2).derive_positive]);

All = unique(sort([All_ML All_AP]));

ind = nettoie_points_proches(All,5);

if length(ind)<5
    evts(1:length(ind)) = t(ind);
else
    evts = t(ind(1:5));
end

end