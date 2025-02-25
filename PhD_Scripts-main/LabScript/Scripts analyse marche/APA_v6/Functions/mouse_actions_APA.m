function mouse_actions_APA(choice)

global APA TrialParams ResAPA liste_marche clean

%% on récupère l'arborescence
select = getappdata(clean,'select');

%% on récupère les courbes sur lesquelles on vient de cliquer
select_rouge = findobj(clean,'color','r');

%% on récupère les noms des acquisitions correspondantes
names = uniqueRowsCA(get(select_rouge,'displayname'));
%%
switch choice
    case 'identify' %% On remet en bleu /déséléction
        courante = uniqueRowsCA(get(select,'displayname'));
        msgbox(courante);
        set(select,'color','b');        
    case 'gait_suppression' %% On supprime les données des acquisitions séléctionnées
        button = questdlg(names,'Suppression des sélections?','Oui','Non','Non');
        if strcmp(button,'Oui')
            liste_Trial = arrayfun(@(i) APA.Trial(i).CP_Position.TrialName,1:length(APA.Trial),'uni',0);
            ind_supp = matchcells(liste_Trial,names);
            if ~isempty(ind_supp)
                APA.removedTrials = [APA.removedTrials , APA.Trial(ind_supp)];
                ResAPA.removedTrials = [ResAPA.removedTrials , ResAPA.Trial(ind_supp)];
                TrialParams.removedTrials = [TrialParams.removedTrials , TrialParams.Trial(ind_supp)];
                num_Trial = arrayfun(@(i) APA.Trial(i).CP_Position.TrialNum,1:length(APA.Trial));
                num_remTrial = arrayfun(@(i) APA.removedTrials(i).CP_Position.TrialNum,1:length(APA.removedTrials));
                [~,ind_supp_tri] = sort(unique(num_remTrial));
                APA.removedTrials = APA.removedTrials(ind_supp_tri);
                ResAPA.removedTrials = ResAPA.removedTrials(ind_supp_tri);
                TrialParams.removedTrials = TrialParams.removedTrials(ind_supp_tri);
                [~,ind_trial] = setdiff(num_Trial,num_remTrial);
                APA.Trial = APA.Trial(ind_trial);
                ResAPA.Trial = ResAPA.Trial(ind_trial);
                TrialParams.Trial = TrialParams.Trial(ind_trial);
            end   
            liste_marche = arrayfun(@(i) APA.Trial(i).CP_Position.TrialName,1:length(APA.Trial),'uni',0);    
            delete(select_rouge);
            set(findobj('tag','listbox1'), 'Value',1);
            set(findobj('tag','listbox1'),'String',liste_marche);
        else
            disp('Arrêt suppression');
        end
end
