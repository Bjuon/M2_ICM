function multi = affiche_multidata(list,choix_PF,choix_muscles,choix_contacts)
%% Fonction d'affichage simultan? des donn?es choisie par l'op?rateur dans une nouvelle interface 'multi'
% list = liste des acquisitions contenant des donn?es multiples
% choix_PF = liste des choix de donn?es analogiques
% choix_muscles = liste des choix de donn?es EMG
% choix_contacts = liste des choix de donn?es LFP

global list_multi b1 h_axes_pf h_axes_pf_V h_axes_emg h_axes_lfp Affiche

Affiche={};
% Cr?ation de l'interface de visu
multi = figure('Name','Visualisation Multiple','tag','visu_multi','handlevisibility','on');
b = uiextras.HBox( 'Parent', multi);
b1 = uiextras.VBox( 'Parent', b);
% b2 = uiextras.VBox( 'Parent', b);

%Ajout de la liste des acquisitions ayant plusieurs sources de donn?es
list_multi = uicontrol( 'Style', 'listbox', 'Parent', b, 'String', list,'Callback',@list_multi_Callback);

% Cr?ation axes donn?es PF
if ~isempty(choix_PF)
    
    for i=1:length(choix_PF)
        h_axes_pf(i) = axes( 'Parent', b1,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace','handlevisibility','on','Tag',choix_PF{i},'XColor','w','YColor','w');
    end
    h=findobj('Tag',choix_PF{i});
%     set(h,'xticklabel',[-0.5 0 0.5 1 1.5]);
    xlabel(h,'Time (sec)');
    
    Affiche.PF = choix_PF;
    
%     list_V = {'V_CG_AP' 'V_CG_Z' 'Acc_Z'};
%     ind_V = sum(compare_liste(choix_PF,list_V),2);
%     if sum(ind_V)~=0
%         Affiche.PF = choix_PF(~ind_V);
%         Affiche.PF_V = choix_PF(ind_V==1);
%         h_axes_pf_V = axes( 'Parent', b1,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace','handlevisibility','on');
%     else
%         Affiche.PF = choix_PF;
%         h_axes_pf_V = [];
%     end
end

% Cr?ation axes donn?es EMG
if ~isempty(choix_muscles)
    Affiche.EMG = choix_muscles;
    h_axes_emg = axes( 'Parent', b1,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace');
end

% Cr?ation axes donn?es LFP
if ~isempty(choix_contacts)
    Affiche.LFP = choix_contacts;
    h_axes_lfp = axes( 'Parent', b1,'ActivePositionProperty', 'Position','NextPlot','replace');
end

function list_multi_Callback(hObj,event,handles)
%% Affichage LFPs
global b1 h_axes_pf h_axes_pf_V h_axes_emg h_axes_lfp list_multi acq_choisie Sujet EMG Corridors_EMG LFP Corridors_LFP Affiche
        
%R?cup?ration de l'acquisition s?l?ctionn?e
try
    %Initialisation des plots et marqueurs si Multiplot Off
    axess = findobj('Type','axes','Parent',b1);
    for i=1:length(axess)
        set(axess(i),'NextPlot','replace'); % Multiplot Off
    end
    
    contents = cellstr(get(list_multi,'String'));
    acq_choisie = contents{get(list_multi,'Value')};
    t = Sujet.(acq_choisie).t;
    fin = Sujet.(acq_choisie).tMarkers.FC2 + 0.2;
    if fin>t(end)
        fin=t(end);
    end
%     try
%         t_debut = Sujet.(acq_choisie).tMarkers.TR - 0.2; % 200ms avant le GO
%     catch NO_EMG
%         t_debut = 0;
%     end
%     if t_debut<t(1)
%         t_debut=t(1);
%     end
    
%     debut = floor((t_debut - t(1))*Sujet.(acq_choisie).Fech) +1;
    t(t>fin)=[];
%     t = t(debut:end);
    if isfield(Affiche,'PF')
        Data_PF = Affiche.PF;
        colors = {'r' 'b' 'r' 'g'};
        for p=1:length(Data_PF)
            try
                curr_axis = h_axes_pf(p);
                Data_to_plot = Sujet.(acq_choisie).(Data_PF{p}) - Sujet.(acq_choisie).(Data_PF{p})(1);
                plot(curr_axis,t,smooth(Data_to_plot(1:length(t))),colors{p},'Linewidth',1.5);
            catch Err_pf
                disp(['Erreur affichage ' Data_PF(p)]);
            end
            afficheY_v3(0,'k',curr_axis,0.5);
            axis(curr_axis,'tight');
            set(curr_axis,'XColor','w','YColor','w');
        end
        set(curr_axis,'xtick',[0 0.5 1 1.5 2 2.5],'XColor','k','Box','off');
        ylabel(curr_axis,'Time (sec)');
%         label_PF = colle_labels(Data_PF);
%         ylabel(h_axes_pf,label_PF);
    end
    
%     if isfield(Affiche,'PF_V')
%         Data_PF_V = Affiche.PF_V;
%         colors = {'r' 'g'};
%         for p=1:length(Data_PF_V)
%             try
%                 Offset_pf =  0;
%                 Data_to_plot = Sujet.(acq_choisie).(Data_PF_V{p}) - (p-1)*Offset_pf;
%                 plot(h_axes_pf_V,t,Data_to_plot(debut:debut + length(t)-1),colors{p}); set(h_axes_pf_V,'Nextplot','add');
%             catch Err_pf
%                 disp(['Erreur affichage ' Data_PF_V(p)]);
%             end
%         end
%         axis(h_axes_pf_V,'tight');
%         label_PF_V = colle_labels(Data_PF_V);
%         ylabel(h_axes_pf_V,label_PF_V);
%     end
    
    if isfield(Affiche,'EMG')
        EMG_col = Affiche.EMG;
        try
            muscles = EMG.(acq_choisie).nom(EMG_col);
            for m=1:length(EMG_col)
                try
                    Offset_emg=  max(abs(EMG.(acq_choisie).val(:,EMG_col(m))))/2;
                    debut_emg = floor((t_debut - t(1))*EMG.(acq_choisie).Fech) +1;
                    fin_emg = debut_emg + (floor((fin - t(1))*EMG.(acq_choisie).Fech));
                    EMG_resampled = EMG.(acq_choisie).val(debut_emg:fin_emg,EMG_col(m));
                    EMG_resampled = resample(EMG_resampled,length(t),length(EMG_resampled));
                    plot(h_axes_emg,t,EMG_resampled-(m-1)*Offset_emg,'r'); set(h_axes_emg,'Nextplot','add'); ylabel(h_axes_emg,muscles(p));
                catch ERr_emg
                    disp(['Erreur affichage ' muscles(m)]);
                end
            end
            axis(h_axes_emg,'tight');
            label_EMG = colle_labels(muscles);
            ylabel(h_axes_emg,label_EMG);
        catch NO_EMG
            disp('Pas d''EMG pour cette acquisition');
        end
    end
    
    if isfield(Affiche,'LFP')
        contacts = Affiche.LFP;
        for l=1:length(contacts)
            try
%                 Offset_lfp =  max(abs(LFP.(acq_choisie).(contacts{l})))+1;
                Offset_lfp = 10;
                LFP_to_plot = TraitementLFPs(LFP.(acq_choisie).(contacts{l}),Sujet.(acq_choisie).Fech);
                LFP_to_plot = LFP_to_plot-(l-1)*Offset_lfp/2;
                plot(h_axes_lfp,t,LFP_to_plot(debut:debut + length(t)-1)); set(h_axes_lfp,'Nextplot','add'); ylabel(h_axes_lfp,contacts{l});
            catch ERr_emg
                disp(['Erreur affichage ' contacts(l)]);
            end
        end
        axis(h_axes_lfp,'tight');
        label_LFP = colle_labels(contacts,1);
        ylabel(h_axes_lfp,label_LFP);
        xlabel(h_axes_lfp,'Temps(s)');
    end
catch ERR_visuall
    disp('Erreur visu - check time vectors!');
end

try
    Markers_Callback();
catch Err_Visu_mrkrs
end

function Markers_Callback(hObject, eventdata, handles)
%% Affichage des marqueurs de l'acquisition courante/s?lectionn?e
global h_axes_pf h_marks_T0_lfp h_T0_txt h_marks_HO_lfp h_marks_TO_lfp h_FO1_txt h_FO2_txt h_marks_FC1_lfp h_FC1_txt h_marks_FO2_lfp h_marks_FC2_lfp h_marks_Onset_TA acq_choisie Sujet Activation_EMG h_marks_Trig h_trig_txt
% hObject    handle to Markers (see GCBO)

% %Nettoyage des axes d'abord (??Laisser si Multiplot On??)
efface_marqueur_test(h_marks_T0_lfp);
% efface_marqueur_test(h_marks_HO_lfp);
efface_marqueur_test(h_marks_TO_lfp);
efface_marqueur_test(h_marks_FC1_lfp);
efface_marqueur_test(h_marks_FO2_lfp);
efface_marqueur_test(h_marks_FC2_lfp);
% 
efface_marqueur_test(h_marks_Onset_TA);
efface_marqueur_test(h_T0_txt);
efface_marqueur_test(h_FC1_txt);
efface_marqueur_test(h_FO1_txt);
efface_marqueur_test(h_FO2_txt);

% 
% %Actualisation des marqueurs
h_marks_T0_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.T0,'-r');
% h_marks_HO_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.HO,'-k');
h_marks_TO_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.TO,'-b');
h_marks_FC1_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.FC1,'-k');
h_marks_FO2_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.FO2,'-g');
h_marks_FC2_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.FC2,'-c');

TMax = max(Sujet.(acq_choisie).CP_AP)-10;
curr_axis = findobj('Tag','CP_AP');

h_T0_txt = text(Sujet.(acq_choisie).tMarkers.T0,TMax,'t0',...
            'VerticalAlignment','Bottom',...
            'HorizontalAlignment','left',...
            'FontSize',14,...
            'Parent',curr_axis);        
h_FC1_txt = text(Sujet.(acq_choisie).tMarkers.FC1,TMax,'\leftarrowFC',...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','Left',...
            'FontSize',10,...
            'Parent',curr_axis);
h_FO1_txt = text(Sujet.(acq_choisie).tMarkers.TO,TMax,'FO1',...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','Left',...
            'FontSize',10,...
            'Parent',curr_axis);
h_FO2_txt = text(Sujet.(acq_choisie).tMarkers.FO2,TMax,'FO2',...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','Left',...
            'FontSize',10,...
            'Parent',curr_axis);
               
% try
%     Onset_EMG_TA = min([Activation_EMG.(acq_choisie).RTA(1,1) Activation_EMG.(acq_choisie).LTA(1,1)]); %Debut inhibition TA
%     h_marks_Onset_TA = affiche_marqueurs(Onset_EMG_TA,'*-r');
% catch errta
%     disp('Activation TA non identifi?e');
% end

try
    %Affichage du trigger externe (si existe) et si pas trop éloigné
    if isfield(Sujet.(acq_choisie),'Trigger')
        dec = Sujet.(acq_choisie).Trigger - Sujet.(acq_choisie).t(1);
        dec = troncature(dec,1);
        if abs(dec)<2
%             h_marks_Trig = affiche_marqueurs(Sujet.(acq_choisie).Trigger,'*-k');
            h_trig_txt = text(Sujet.(acq_choisie).Trigger,Sujet.(acq_choisie).CP_AP(2),'\UparrowGO',...
                'VerticalAlignment','Top',...
                'HorizontalAlignment','Center',...
                'FontSize',8,...
                'Parent',h_axes_pf);
        else
%             h_marks_Trig = affiche_marqueurs(Sujet.(acq_choisie).t(1),'*-k');
            h_trig_txt = text(Sujet.(acq_choisie).t(1),0,['\leftarrowTrigger décalé de ' num2str(dec) ' sec'],...
                'VerticalAlignment','Top',...
                'HorizontalAlignment','Center',...
                'FontSize',8,...
                'Parent',h_axes_pf);
        end
    end
catch NO_GO
    disp('Pas de GO sonore');
end
    