function CR = affiche_resultat_APA(Acq)
%% Mise à jour des resultats sur le tableau d'affichage
CR={};
% if isfield(Acq,'primResultats') %% Si les calculs n'ont pas été
%     Acq = calculs_parametres_initiationPas_v1(Acq);
% end

param = fieldnames(Acq);
for i=1:length(param)
    CR{i,1} = param{i};
    CR{i,2} = getfield(Acq,param{i});
end
set(findobj('tag','Results'),'Data',CR);
end
