function multi = affiche_multidata_v3(list,choix_PF,choix_muscles,choix_contacts)
%% Fonction d'affichage simultan? des donn?es choisie par l'op?rateur dans une nouvelle interface 'multi'
% list = liste des acquisitions contenant des donn?es multiples
% choix_PF = liste des choix de donn?es analogiques
% choix_muscles = liste des choix de donn?es EMG
% choix_contacts = liste des choix de donn?es LFP

global list_multi b1 h_axes_pf h_axes_pf_cpAP h_axes_pf_cpML h_axes_pf_Vap h_axes_pf_Vz h_axes_emg h_axes_lfp h_axes_TF Affiche

Affiche={};
% Cr?ation de l'interface de visu
multi = figure('Name','Visualisation Multiple','tag','visu_multi','handlevisibility','on');
b = uiextras.HBox( 'Parent', multi);
b1 = uiextras.VBox( 'Parent', b);
% b2 = uiextras.VBox( 'Parent', b);

%Ajout de la liste des acquisitions ayant plusieurs sources de donn?es
list_multi = uicontrol( 'Style', 'listbox', 'Parent', b, 'String', list,'Callback',@list_multi_Callback);

% Cr?ation axes donn?es PF
h_axes_pf_cpAP = [];
h_axes_pf_cpML = [];
h_axes_pf_Vap = [];
h_axes_pf_Vz = [];
h_axes_pf = [];
a=0;

if ~isempty(choix_PF)
    Affiche.PF = choix_PF;
    for i=1:length(choix_PF)
        switch choix_PF{i}
            case 'CP_AP'
                h_axes_pf_cpAP = axes( 'Parent', b1,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace','handlevisibility','on','Tag','AfficheAP','XColor','w');
            case 'CP_ML'
                h_axes_pf_cpML = axes( 'Parent', b1,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace','handlevisibility','on','Tag','AfficheML','XColor','w');
            case {'V_CG_AP' 'V_CG_AP_d'}
                if isempty(h_axes_pf_Vap)
                    h_axes_pf_Vap = axes( 'Parent', b1,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace','handlevisibility','on','Tag','AfficheVap','XColor','w');
                end
            case {'V_CG_Z' 'V_CG_Z_d'}
                if isempty(h_axes_pf_Vz)
                    h_axes_pf_Vz = axes( 'Parent', b1,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace','handlevisibility','on','Tag','AfficheVz','XColor','w');
                end
            otherwise
                a=a+1;
                h_axes_pf(a) = axes( 'Parent', b1,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace','handlevisibility','on','Tag',choix_PF{i},'XColor','w');
        end
    end
end

% Cr?ation axes donn?es EMG
h_axes_emg =[];
if ~isempty(choix_muscles)
    Affiche.EMG = choix_muscles;
    h_axes_emg = axes( 'Parent', b1,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace');
end

% Cr?ation axes donn?es LFP
h_axes_lfp =[];
h_axes_TF=[];
if ~isempty(choix_contacts)
    button_Spec = questdlg('Affichage des spectrograms ou LFP?','Visu Temps-Fréquence?','Spectrograms','LFP','Les 2','LFP'); % Spectrogram ou Signaux continus?    
    switch button_Spec
        case 'LFP'
            Affiche.LFP = choix_contacts;
            h_axes_lfp = axes( 'Parent', b1,'ActivePositionProperty', 'Position','NextPlot','replace');
        case 'Spectrograms'
            Affiche.TF = choix_contacts;
            for c=1:length(choix_contacts)
                h_axes_TF(c) = axes( 'Parent', b1,'ActivePositionProperty', 'Position','NextPlot','replace');
            end
        otherwise
            Affiche.LFP = choix_contacts;
            Affiche.TF = choix_contacts;
            h_axes_lfp = axes( 'Parent', b1,'ActivePositionProperty', 'Position','NextPlot','replace');
            for c=1:length(choix_contacts)
                h_axes_TF(c) = axes( 'Parent', b1,'ActivePositionProperty', 'Position','NextPlot','replace');
            end
    end
end 

function list_multi_Callback(hObj,event,handles)
%% Affichage acquisition choisie
global b1 h_axes_pf h_axes_pf_cpAP h_axes_pf_cpML h_axes_pf_Vap h_axes_pf_Vz h_axes_emg h_axes_lfp h_axes_TF list_multi acq_choisie Sujet Corridors EMG Corridors_EMG LFP LFP_base LFP_raw Corridors_LFP Corridors_LFP_raw Affiche
        
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
    fin = t(end);
    
    if isfield(Affiche,'PF')
        Data_PF = Affiche.PF;
        colors = {'r' 'b' 'r' 'g' '--r' '--g' 'k'};
        a=0;
        for p=1:length(Data_PF)
            try
                switch Data_PF{p}
                    case 'CP_AP'
                        curr_axis = h_axes_pf_cpAP; scale = 0.1;
                    case 'CP_ML'
                        curr_axis = h_axes_pf_cpML; scale = 0.1;
                    case {'V_CG_AP' 'V_CG_AP_d'}
                        curr_axis = h_axes_pf_Vap; scale = 1;
                    case {'V_CG_Z' 'V_CG_Z_d'}
                        curr_axis = h_axes_pf_Vz; scale = 1;
                    otherwise
                        a=a+1;
                        curr_axis = h_axes_pf(a); scale = 1;
                end
                if isfield(Corridors,acq_choisie)
                    Data_to_plot = (Corridors.(acq_choisie).(Data_PF{p}) - Sujet.(acq_choisie).(Data_PF{p})(1))*scale;
                    t=(1:length(Data_to_plot))*1/Sujet.(acq_choisie).Fech;
                    stdshade(Data_to_plot,0.4,'k',t,1,curr_axis,2,[],0.2105);
                else
                    Data_to_plot = (Sujet.(acq_choisie).(Data_PF{p}) - Sujet.(acq_choisie).(Data_PF{p})(1))*scale;
                    try
                        plot(curr_axis,t,smooth(Data_to_plot(1:length(t))),colors{p},'Linewidth',1.5);
                    catch V_vicon % Vitesses dérivation
                        tt=(0:length(Data_to_plot)-1)*1/Sujet.(acq_choisie).Fech_vid;
                        plot(curr_axis,tt,smooth(Data_to_plot(1:length(tt))),colors{p},'Linewidth',1.5);
                    end
                end
            catch Err_pf
                disp(['Erreur affichage ' Data_PF(p)]);
            end
            afficheY_v3(0,'k',curr_axis,0.5);
            if isvector(Data_to_plot)
                M = [min(Data_to_plot(1:end/1.5)) max(Data_to_plot)];
                set(curr_axis,'ylim',[1 1.05].*M);
            else
                M = [min(nanmean(Data_to_plot,1)) max(nanmean(Data_to_plot,1))];
                set(curr_axis,'ylim',1.20*M);
%                 axis(curr_axis,'tight');
            end            
            set(curr_axis,'XColor','w');
        end
        set(curr_axis,'xtick',[0 0.5 1 1.5 2 2.5 3 3.5 4],'XColor','k','Box','off');
        if ~isempty(h_axes_pf_cpAP)
            ylabel(h_axes_pf_cpAP,'cm'); 
        end
        if ~isempty(h_axes_pf_cpML)
            ylabel(h_axes_pf_cpML,'cm');
        end
        if ~isempty(h_axes_pf_Vap)
            ylabel(h_axes_pf_Vap,'m/sec');
        end
        if ~isempty(h_axes_pf_Vz)
            ylabel(h_axes_pf_Vz,'m/sec');
        end
        if ~isempty(h_axes_pf)
            for a=1:length(h_axes_pf)
                ylabel(h_axes_pf(a),'m²/sec - Watt');
            end
        end
        xlabel(curr_axis,'Time (sec)');
    end
    
    if isfield(Affiche,'EMG')
        EMG_col = Affiche.EMG;
        try
            muscles = EMG.(acq_choisie).nom(EMG_col);
            for m=1:length(EMG_col)
                try
                    if isfield(Corridors_EMG,acq_choisie)
                        Offset_emg = 2;
                        EMG_group = resample(Corridors_EMG.(acq_choisie).(muscles{m})',length(t),length(Corridors_EMG.(acq_choisie).(muscles{m})));
                        stdshade(EMG_group'-(m-1)*Offset_emg,0.25,'r',t,0,h_axes_emg,1.25);
                    else
                        fin_emg = 1 + (floor((fin - t(1))*EMG.(acq_choisie).Fech));
                        EMG_resampled = EMG.(acq_choisie).val(1:fin_emg,EMG_col(m));
                        EMG_resampled = resample(EMG_resampled,length(t),length(EMG_resampled));
                        Offset_emg=  max(abs(EMG.(acq_choisie).val(:,EMG_col(m))));
                        plot(h_axes_emg,t,EMG_resampled-(m-1)*Offset_emg,'r'); set(h_axes_emg,'Nextplot','add');
                    end
                catch ERr_emg
                    disp(['Erreur affichage ' muscles(m)]);
                end
            end
            axis(h_axes_emg,'tight');
            label_EMG = colle_labels(muscles);
            ylabel(h_axes_emg,label_EMG);
            xlabel(h_axes_emg,'Temps (seconds)');
        catch NO_EMG
            disp('Pas d''EMG pour cette acquisition/moyenne');
        end
    end
    
    if isfield(Affiche,'LFP')
        contacts = Affiche.LFP;
        for l=1:length(contacts)
            try
                Offset_lfp = 20;
                if isfield(Corridors_LFP,acq_choisie)
                    Data_to_plot = Corridors_LFP.(acq_choisie).(contacts{l}) - (l-1)*Offset_lfp;
                    Data_to_plot = resample(Data_to_plot',length(t),length(Data_to_plot));
                    stdshade(Data_to_plot',0.4,'b',t,1,h_axes_lfp,1.5,[],0.5);
                else 
                    LFP_to_plot = TraitementLFPs(replaceNaNs(LFP.(acq_choisie).(contacts{l})),Sujet.(acq_choisie).Fech);
                    LFP_to_plot = LFP_to_plot-(l-1)*Offset_lfp/2;
                    plot(h_axes_lfp,t,LFP_to_plot(1:length(t))); set(h_axes_lfp,'Nextplot','add');
                end
            catch ERr_emg
                disp(['Erreur affichage ' contacts(l) ': check time vectors!']);
                LFP_to_plot = TraitementLFPs(LFP_raw.(acq_choisie).(contacts{l}),LFP_base.Fech);
                LFP_to_plot = LFP_to_plot-(l-1)*Offset_lfp/2;
                t = (0:length(LFP_to_plot)-1).*1/LFP_base.Fech;
                plot(h_axes_lfp,t,LFP_to_plot); set(h_axes_lfp,'Nextplot','add');
            end
        end
        axis(h_axes_lfp,'tight');
        label_LFP = colle_labels(contacts,1);
        ylabel(h_axes_lfp,label_LFP);
        xlabel(h_axes_lfp,'Temps (seconds)');
    end
    
    if isfield(Affiche,'TF')
        contacts = Affiche.TF;
        dw = 0.2; % Taille de fenêtre glissante (sec)
        overlap = 0.97; % en pourcentage
        movingwin = [dw (1-overlap)*dw];
        parms.Fs = LFP_base.Fech;
        parms.fpass = [0 100];
        parms.tapers = [2 3];
        parms.pad = 2;
        for l=1:length(contacts)
            try
                if isfield(Corridors_LFP_raw,acq_choisie)
                    parms.trialave = 1; % Moyenne
                    LFPs_to_TF = Corridors_LFP_raw.(acq_choisie).(contacts{l});
                    [X,t,f] = mtspecgramc(LFPs_to_TF',movingwin,parms);                    
                else 
                    parms.trialave = 0; % Essai
                    LFPs_to_TF = LFP_raw.(acq_choisie).(contacts{l});
                    [X,t,f] = mtspecgramc(LFPs_to_TF,movingwin,parms);
                end
                %Normalisation
                LFPs_to_TF_base = LFP_base.(acq_choisie).(contacts{l});
                [X0,t0,f0] = mtspecgramc(LFPs_to_TF_base',movingwin,parms);
                X0_mat = repmat(nanmean(X0,1),size(X,1),1);
                
                %Affichage
%                 plot_matrix_multi(flipdim(X./X0_mat,2),t,flipdim(f,2),'l',h_axes_lfp(l));
                plot_matrix_multi(X./X0_mat,t,f,'l',h_axes_TF(l));

%                 surf(t,f,10*log10(X./X0_mat)','edgecolor','none','Parent',h_axes_lfp(l));
%                 ylabel(h_axes_lfp(l),contacts{l});
%                 axis(h_axes_lfp(l),'tight');
%                 view(h_axes_lfp(l),0,90);
                
            catch ERr_emg
                disp(['Erreur affichage ' contacts(l)]);
            end
            set(h_axes_TF(l),'YDir','Reverse');
        end
        
        xlabel(h_axes_TF(l),'Temps (seconds)');
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
global b1 h_axes_pf_cpAP h_marks_T0_lfp h_T0_txt h_marks_HO_lfp h_marks_TO_lfp h_FO1_txt h_marks_FC1_lfp h_FC1_txt h_marks_FO2_lfp h_marks_FC2_lfp h_marks_Onset_TA acq_choisie Sujet Activation_EMG h_marks_Trig h_trig_txt h_marks_FOG h_FOG_txt
% hObject    handle to Markers (see GCBO)

%Nettoyage des axes d'abord (??Laisser si Multiplot On??)
efface_marqueur_test(h_marks_T0_lfp);
efface_marqueur_test(h_marks_HO_lfp);
efface_marqueur_test(h_marks_TO_lfp);
efface_marqueur_test(h_marks_FC1_lfp);
efface_marqueur_test(h_marks_FO2_lfp);
efface_marqueur_test(h_marks_FC2_lfp);

efface_marqueur_test(h_marks_Onset_TA);
efface_marqueur_test(h_T0_txt);
efface_marqueur_test(h_FC1_txt);
efface_marqueur_test(h_FO1_txt);
efface_marqueur_test(h_trig_txt);

efface_marqueur_test(h_marks_FOG);
efface_marqueur_test(h_FOG_txt);

% Actualisation des marqueurs
h_marks_T0_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.T0,'-r');
h_marks_HO_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.HO,'-k');
h_marks_TO_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.TO,'-b');
h_marks_FC1_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.FC1,'-m');
h_marks_FO2_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.FO2,'-g');
h_marks_FC2_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.FC2,'-c');


% Identification de l'axe supérieur
if ~isempty(h_axes_pf_cpAP)
    curr_axis = h_axes_pf_cpAP;
else
    axess = findobj('Type','axes','Parent',b1);
    curr_axis = axess(1);
end

% Extraction des Maximas (Pour affichage 'Normalisé')
TMax = get(curr_axis,'xlim'); % Pour adapter l'affichage des flèches au bon instants (car la fonction 'annotation' ne fonctionne qu'avec les unités normalisées)

h_T0_txt = annotation('textarrow',0.5*[(Sujet.(acq_choisie).tMarkers.T0)/TMax(2) (Sujet.(acq_choisie).tMarkers.T0)/TMax(2)],[0.98 0.93],'String','t0',...
            'FontSize',14,...
            'Parent',curr_axis);
h_FC1_txt = annotation('textarrow',0.5*[(Sujet.(acq_choisie).tMarkers.FC1)/TMax(2) (Sujet.(acq_choisie).tMarkers.FC1)/TMax(2)],[0.98 0.93],'String','FC',...
            'FontSize',14,...
            'Parent',curr_axis);
h_FO1_txt = annotation('textarrow',0.5*[(Sujet.(acq_choisie).tMarkers.TO)/TMax(2) (Sujet.(acq_choisie).tMarkers.TO)/TMax(2)],[0.975 0.93],'String','FO_1',...
            'FontSize',14,...
            'Parent',curr_axis);
        
try
    Onset_EMG_TA = min([Activation_EMG.(acq_choisie).RTA(1,1) Activation_EMG.(acq_choisie).LTA(1,1)]); %Debut inhibition TA
    h_marks_Onset_TA = affiche_marqueurs(Onset_EMG_TA,'*-r');
catch errta
    disp('Activation TA non identifi?e');
end

try
    %Affichage du trigger externe (si existe) et si pas trop éloigné
    if isfield(Sujet.(acq_choisie),'Trigger')
        dec = Sujet.(acq_choisie).Trigger - Sujet.(acq_choisie).t(1);
        dec = troncature(dec,1);
        if abs(dec)<2
            h_marks_Trig = affiche_marqueurs(Sujet.(acq_choisie).Trigger,'-k');
             h_trig_txt = annotation('textarrow',0.5*[Sujet.(acq_choisie).Trigger/TMax(2) Sujet.(acq_choisie).Trigger/TMax(2)],[0.98 0.93],'String','GO',...
                 'FontSize',14,...
                 'Parent',curr_axis);
        else
            h_marks_Trig = affiche_marqueurs(Sujet.(acq_choisie).t(1),'-k');
            h_trig_txt = text(Sujet.(acq_choisie).t(1),1000,['<- Trigger décalé de ' num2str(dec) ' sec'],...
                'VerticalAlignment','middle',...
                'HorizontalAlignment','left',...
                'FontSize',8,...
                'Parent',curr_axis);
        end
    end
catch NO_GO
    disp('Pas de GO sonore');
end

try
    %Affichage des épisodes de Freezing(si existe)
    if isfield(Sujet.(acq_choisie).tMarkers,'FOG')
        f=1;
        for i=1:2:length(Sujet.(acq_choisie).tMarkers.FOG)-1
            h_marks_FOG = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.FOG(i),'--k');
            h_FOG_txt(f) = annotation('textarrow',0.5*[(Sujet.(acq_choisie).tMarkers.FOG(i))/TMax(2) (Sujet.(acq_choisie).tMarkers.FOG(i))/TMax(2)],[0.98 0.93],'String','FOG-Start',...
                'FontSize',14,...
                'Parent',curr_axis);
            f=f+1;
        end
    end
catch NO_FOG
    disp('Pas de FOG');
end
    