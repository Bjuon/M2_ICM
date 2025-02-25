f1=figure;
c=uicontextmenu('Parent',f1);
cb1 = 'mouse_actions_APA(''identify'')';
cb2 = 'mouse_actions_APA(''gait_suppression'')';
uimenu(c, 'Label', 'repérer dans le navigateur', 'Callback',cb1);
uimenu(c, 'Label', 'supprimer marche', 'Callback',cb2);


plot(Sujet.Marche_normale1_trimmed.t,Sujet.Marche_normale1_trimmed.CP_AP,'ButtonDownFcn',@maselection,'uicontextmenu',c,'displayname','Marche_normale1_trimmed');hold on
plot(Sujet.Marche_normale9_trimmed.t,Sujet.Marche_normale9_trimmed.CP_AP,'ButtonDownFcn',@maselection,'uicontextmenu',c,'displayname','Marche_normale9_trimmed');
plot(Sujet.Marche_normale_postTMS4_trimmed.t,Sujet.Marche_normale_postTMS4_trimmed.CP_AP,'ButtonDownFcn',@maselection,'uicontextmenu',c,'displayname','Marche_normale_postTMS4_trimmed');


legend('Marche_normale1_trimmed','Marche_normale9_trimmed');