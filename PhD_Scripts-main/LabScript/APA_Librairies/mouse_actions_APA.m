function mouse_actions_APA(choice)

global Sujet Resultats clean EMG

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
            Sujet = rmfield(Sujet,names);
            try
                EMG = rmfield(EMG,names);
            catch no_emg
            end
            % On supprime également les résultats déjà calculés (si présents)
            liste_res = fieldnames(Resultats);
            list_non_res = compare_liste(liste_res,names);
            if ~isempty(Resultats) && sum(sum(list_non_res))
                try
                    ind = find(list_non_res==1);
                    Resultats = rmfield(Resultats,liste_res(ind));
                catch ERR
                    warndlg('Resultats non mis à jour!! Relancer calculs!!');
                end
            end
            delete(select_rouge);
            set(findobj('tag','listbox1'), 'Value',1);
            liste_actuelle = cellstr(get(findobj('tag','listbox1'),'String'));
            similars = sum(compare_liste(names,liste_actuelle),1);
            set(findobj('tag','listbox1'),'String',liste_actuelle(similars==0));
        else
            disp('Arrêt suppression');
        end
end
