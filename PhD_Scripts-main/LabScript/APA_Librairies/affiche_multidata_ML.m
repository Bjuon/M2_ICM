function multi = affiche_multidata_ML(list,choix_PF,choix_muscles,choix_contacts)
%% Fonction d'affichage simultané des données choisie par l'opérateur dans une nouvelle interface 'multi' (customization pour graphes de publication)
% list = liste des acquisitions contenant des donn?es multiples
% choix_PF = liste des choix de donn?es analogiques
% choix_muscles = liste des choix de donn?es EMG
% choix_contacts = liste des choix de donn?es LFP

global list_multi b1 h_axes_pf h_axes_pf_cpAP h_axes_pf_cpML h_axes_pf_Vap h_axes_pf_Vz h_axes_emg h_axes_lfp Affiche

Affiche={};
% Cr?ation de l'interface de visu
multi = figure('Name','Visualisation Multiple','tag','visu_multi','handlevisibility','on');
b = uiextras.HBox( 'Parent', multi);
b1 = uiextras.VBox( 'Parent', b);
% b2 = uiextras.VBox( 'Parent', b);

%Ajout de la liste des acquisitions ayant plusieurs sources de donn?es
list_multi = uicontrol( 'Style', 'listbox', 'Parent', b, 'String', list,'Callback',@list_multi_Callback);

% Cr?ation axes donn?es PF (un axe/hande par signal)
if ~isempty(choix_PF)
    Affiche.PF = choix_PF;
    for i=1:length(choix_PF)
        switch choix_PF{i}
            case 'CP_AP'
                h_axes_pf_cpAP = axes( 'Parent', b1,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace','handlevisibility','on','Tag','AfficheAP','XColor','w');
            case 'CP_ML'
                h_axes_pf_cpML = axes( 'Parent', b1,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace','handlevisibility','on','Tag','AfficheML','XColor','w');
            case 'V_CG_AP'
                h_axes_pf_Vap = axes( 'Parent', b1,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace','handlevisibility','on','Tag','AfficheVap','XColor','w'); 
            case 'V_CG_Z'
                h_axes_pf_Vz = axes( 'Parent', b1,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace','handlevisibility','on','Tag','AfficheVz','XColor','w'); 
            otherwise
                h_axes_pf(i) = axes( 'Parent', b1,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace','handlevisibility','on','Tag',choix_PF{i},'XColor','w');
        end
    end
else
    h_axes_pf_cpAP = [];
    h_axes_pf_cpML = [];
    h_axes_pf_Vap = [];
    h_axes_pf_Vz = [];
    h_axes_pf = [];
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
global b1 h_axes_pf h_axes_pf_cpAP h_axes_pf_cpML h_axes_pf_Vap h_axes_pf_Vz h_axes_emg h_axes_lfp list_multi acq_choisie Sujet EMG Corridors LFP Affiche
        
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
    
%     debut = floor((t_debut - t(1))*Sujet.(acq_choisie).Fech) +1;
    t(t>fin)=[];
%     t = t(debut:end);
    if isfield(Affiche,'PF')
        Data_PF = Affiche.PF;
        colors = {'r' 'b' 'r' 'g'};
        for p=1:length(Data_PF)
            try
                switch Data_PF{p}
                    case 'CP_AP'
                        curr_axis = h_axes_pf_cpAP; scale = 0.1;
                    case 'CP_ML'
                        curr_axis = h_axes_pf_cpML; scale = 0.1;
                    case 'V_CG_AP'
                        curr_axis = h_axes_pf_Vap; scale = 1;
                    case 'V_CG_Z'
                        curr_axis = h_axes_pf_Vz; scale = 1;
                    otherwise
                        curr_axis = h_axes_pf(i); scale = 1;
                end
                if isfield(Corridors,acq_choisie)
                    Data_to_plot = (Corridors.(acq_choisie).(Data_PF{p}) - Sujet.(acq_choisie).(Data_PF{p})(1))*scale;
                    t=(1:length(Data_to_plot))*1/Sujet.(acq_choisie).Fech;
                    stdshade(Data_to_plot,0.4,'k',t,1,curr_axis,2,[],0.2105);
                else
                    Data_to_plot = (Sujet.(acq_choisie).(Data_PF{p}) - Sujet.(acq_choisie).(Data_PF{p})(1))*scale;
                    plot(curr_axis,t,smooth(Data_to_plot(1:length(t))),colors{p},'Linewidth',1.5);
                end
            catch Err_pf
                disp(['Erreur affichage ' Data_PF(p)]);
            end
            afficheY_v3(0,'k',curr_axis,0.5);
            if isvector(Data_to_plot)
                M = [min(Data_to_plot) max(Data_to_plot)];
                set(curr_axis,'ylim',1.05*M);
            else
                M = [min(nanmean(Data_to_plot,1)) max(nanmean(Data_to_plot,1))];
                set(curr_axis,'ylim',1.20*M);
%                 axis(curr_axis,'tight');
            end            
            set(curr_axis,'XColor','w');
        end
        set(curr_axis,'xtick',[0 0.5 1 1.5 2 2.5],'XColor','k','Box','off');
        ylabel(h_axes_pf_cpAP,'cm'); ylabel(h_axes_pf_cpML,'cm'); ylabel(h_axes_pf_Vap,'m/sec'); ylabel(h_axes_pf_Vz,'m/sec');
        xlabel(curr_axis,'Time (sec)');
    end
    
    if isfield(Affiche,'EMG')
        EMG_col = Affiche.EMG;
        try
            muscles = EMG.(acq_choisie).nom(EMG_col);
            for m=1:length(EMG_col)
                try
                    Offset_emg=  max(abs(EMG.(acq_choisie).val(:,EMG_col(m))))/2;
                    debut_emg = floor(t(1)*EMG.(acq_choisie).Fech) +1;
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
global h_axes_pf h_axes_pf_cpAP h_T0_txt h_FO1_txt h_FO2_txt h_FC2_txt h_marks_FC1_lfp h_FC1_txt h_marks_Onset_TA acq_choisie Sujet  h_trig_txt
% hObject    handle to Markers (see GCBO)

% %Nettoyage des axes d'abord (??Laisser si Multiplot On??)
% efface_marqueur_test(h_marks_T0_lfp);
% efface_marqueur_test(h_marks_HO_lfp);
% efface_marqueur_test(h_marks_TO_lfp);
efface_marqueur_test(h_marks_FC1_lfp);
% efface_marqueur_test(h_marks_FO2_lfp);
% efface_marqueur_test(h_marks_FC2_lfp);
% 
efface_marqueur_test(h_marks_Onset_TA);
efface_marqueur_test(h_T0_txt);
efface_marqueur_test(h_FC1_txt);
efface_marqueur_test(h_FO1_txt);
efface_marqueur_test(h_FO2_txt);
efface_marqueur_test(h_FC2_txt);
efface_marqueur_test(h_trig_txt);

% 
% %Actualisation des marqueurs
% h_marks_T0_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.T0,'-r');
% % h_marks_HO_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.HO,'-k');
% h_marks_TO_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.TO,'-b');
h_marks_FC1_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.FC1,'-k');
% h_marks_FO2_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.FO2,'-g');
% h_marks_FC2_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.FC2,'-c');

% Identification de l'axe supérieur
if ~isempty(h_axes_pf_cpAP)
    curr_axis = h_axes_pf_cpAP;
else
    curr_axis = h_axes_pf(1);
end

% Extraction des Maximas (Pour affichage 'Normalisé')
Max = get(curr_axis,'ylim');
TMax = 1.915*get(curr_axis,'xlim'); % Bidouille pour adapter l'affichage des flèches au bon instants (car la fonction 'annotation' ne fonctionne qu'avec les unités normalisées

h_T0_txt = annotation('textarrow',[(Sujet.(acq_choisie).tMarkers.T0)/TMax(2) (Sujet.(acq_choisie).tMarkers.T0)/TMax(2)],[0.98 0.93],'String','t0',...
            'FontSize',14,...
            'Parent',curr_axis);
h_FC1_txt = annotation('textarrow',[(Sujet.(acq_choisie).tMarkers.FC1)/TMax(2) (Sujet.(acq_choisie).tMarkers.FC1)/TMax(2)],[0.98 0.93],'String','FC',...
            'FontSize',14,...
            'Parent',curr_axis);
h_FO1_txt = annotation('textarrow',[(Sujet.(acq_choisie).tMarkers.TO)/TMax(2) (Sujet.(acq_choisie).tMarkers.TO)/TMax(2)],[0.97 0.93],'String','FO_1',...
            'FontSize',14,...
            'Parent',curr_axis);
h_FO2_txt = annotation('textarrow',[(Sujet.(acq_choisie).tMarkers.FO2)/TMax(2) (Sujet.(acq_choisie).tMarkers.FO2)/TMax(2)],[0.97 0.93],'String','FO_2',...
            'FontSize',14,...
            'Parent',curr_axis);
h_FC2_txt = annotation('textarrow',[(Sujet.(acq_choisie).tMarkers.FC2)/TMax(2) (Sujet.(acq_choisie).tMarkers.FC2)/TMax(2)],[0.97 0.93],'String','FC_2',...
            'FontSize',14,...
            'Parent',curr_axis);
        
% h_T0_txt = text(Sujet.(acq_choisie).tMarkers.T0,TMax,'t0',...
%             'VerticalAlignment','Bottom',...
%             'HorizontalAlignment','left',...
%             'FontSize',14,...
%             'Parent',curr_axis);        
% h_FC1_txt = text(Sujet.(acq_choisie).tMarkers.FC1,Max,'\leftarrowFC',...
%             'VerticalAlignment','middle',...
%             'HorizontalAlignment','Left',...
%             'FontSize',10,...
%             'Parent',curr_axis);
% h_FO1_txt = text(Sujet.(acq_choisie).tMarkers.TO,Max,'FO1',...
%             'VerticalAlignment','middle',...
%             'HorizontalAlignment','Left',...
%             'FontSize',10,...
%             'Parent',curr_axis);
% h_FO2_txt = text(Sujet.(acq_choisie).tMarkers.FO2,Max,'FO2',...
%             'VerticalAlignment','middle',...
%             'HorizontalAlignment','Left',...
%             'FontSize',10,...
%             'Parent',curr_axis);

try
    Onset_EMG_TA = min([Activation_EMG.(acq_choisie).RTA(1,1) Activation_EMG.(acq_choisie).LTA(1,1)]); %Debut inhibition TA
    h_marks_Onset_TA = annotation('textarrow',[Onset_EMG_TA/TMax(2) Onset_EMG_TA/TMax(2)],[0.98 0.94],'String','Onset_TA',...
            'FontSize',14,...
            'Parent',curr_axis);
    
catch errta
    disp('Activation TA non identifi?e');
end

try
    %Affichage du trigger externe (si existe) et si pas trop éloigné
    if isfield(Sujet.(acq_choisie),'Trigger')
        dec = Sujet.(acq_choisie).Trigger - Sujet.(acq_choisie).t(1);
        dec = troncature(dec,1);
        if abs(dec)<2
%             h_marks_Trig = affiche_marqueurs(Sujet.(acq_choisie).Trigger,'*-k');
%             h_trig_txt = text(Sujet.(acq_choisie).Trigger,Sujet.(acq_choisie).CP_AP(2),'\UparrowGO',...
%                 'VerticalAlignment','Top',...
%                 'HorizontalAlignment','Center',...
%                 'FontSize',8,...
%                 'Parent',h_axes_pf);
             h_trig_txt = annotation('textarrow',[Sujet.(acq_choisie).Trigger/TMax(2) Sujet.(acq_choisie).Trigger/TMax(2)],[0.98 0.94],'String','GO',...
                 'FontSize',14,...
                 'Parent',curr_axis);
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
    