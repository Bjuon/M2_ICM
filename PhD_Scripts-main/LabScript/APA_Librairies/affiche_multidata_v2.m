function multi = affiche_multidata_v2(list,choix_PF,choix_muscles,choix_contacts)
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
    h_axes_pf = axes( 'Parent', b1,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace','handlevisibility','on');
    
    list_V = {'V_CG_AP' 'V_CG_Z' 'Acc_Z'};
    ind_V = sum(compare_liste(choix_PF,list_V),2);
    if sum(ind_V)~=0
        Affiche.PF = choix_PF(~ind_V);
        Affiche.PF_V = choix_PF(ind_V==1);
        h_axes_pf_V = axes( 'Parent', b1,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace','handlevisibility','on');
    else
        Affiche.PF = choix_PF;
        h_axes_pf_V = [];
    end
end

% Cr?ation axes donn?es EMG
if ~isempty(choix_muscles)
    Affiche.EMG = choix_muscles;
    h_axes_emg = axes( 'Parent', b1,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace');
end

% Cr?ation axes donn?es LFP
if ~isempty(choix_contacts)
    button_Spec = questdlg('Affichage des spectrograms ou LFP?','Visu Temps-Fréquence?','Spectrograms','LFP','LFP'); % Spectrogram ou Signaux continus?    
    if strcmp(button_Spec,'LFP')
        Affiche.LFP = choix_contacts;
        h_axes_lfp = axes( 'Parent', b1,'ActivePositionProperty', 'Position','NextPlot','replace');
    else
        Affiche.TF = choix_contacts;
        for c=1:length(choix_contacts)
            h_axes_lfp(c) = axes( 'Parent', b1,'ActivePositionProperty', 'Position','NextPlot','replace');
        end
    end
    
    
end

function list_multi_Callback(hObj,event,handles)
%% Affichage acquisition choisie
global b1 h_axes_pf h_axes_pf_V h_axes_emg h_axes_lfp list_multi acq_choisie Sujet Corridors EMG Corridors_EMG LFP LFP_base LFP_raw Corridors_LFP Corridors_LFP_raw Affiche
        
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
%     fin = Sujet.(acq_choisie).tMarkers.FC2 + 0.05;
    fin = t(end);
%     try
%         t_debut = Sujet.(acq_choisie).tMarkers.TR - 0.2; % 200ms avant le GO
%     catch NO_EMG
%         t_debut = 0;
%     end
%     if t_debut<t(1)
        t_debut=t(1);
%     end
    
    debut = floor((t_debut - t(1))*Sujet.(acq_choisie).Fech) +1;
%     t(t>fin)=[];
%     t = t(debut:end);
    if isfield(Affiche,'PF')
        Data_PF = Affiche.PF;
        colors = {'r' 'b' 'r' 'g'};
        Offset_pf =  0;
        for p=1:length(Data_PF)
            try
                if isfield(Corridors,acq_choisie)
                    Data_to_plot = Corridors.(acq_choisie).(Data_PF{p})*0.1 - (p-1)*Offset_pf;
%                     t_PF = (0:(length(Corridors.(acq_choisie).(Data_PF{p}))-1))./Sujet.(acq_choisie).Fech;
                    stdshade(Data_to_plot,0.4,colors{p},t,1,h_axes_pf,2,[],0.5);
                else
                    Data_to_plot = Sujet.(acq_choisie).(Data_PF{p})*0.1 - (p-1)*Offset_pf;
                    plot(h_axes_pf,t,Data_to_plot(debut:debut + length(t)-1),colors{p}); set(h_axes_pf,'Nextplot','add');
                end
%                 Offset_pf = max(range(Data_to_plot));
            catch Err_pf
                disp(['Erreur affichage ' Data_PF(p)]);
            end
        end
        axis(h_axes_pf,'tight');
        label_PF = colle_labels(Data_PF);
        ylabel(h_axes_pf,label_PF);
    end
    
    if isfield(Affiche,'PF_V')
        Data_PF_V = Affiche.PF_V;
        colors = {'r' 'g'};
        Offset_pf =  0;
        for p=1:length(Data_PF_V)
            try
                if isfield(Corridors,acq_choisie)
                    Data_to_plot = Corridors.(acq_choisie).(Data_PF_V{p})*0.1 - (p-1)*Offset_pf;
                    stdshade(Data_to_plot,0.4,colors{p},t,1,h_axes_pf_V,2,[],0.5);
                else
                    Data_to_plot = Sujet.(acq_choisie).(Data_PF_V{p}) - (p-1)*Offset_pf;
                    plot(h_axes_pf_V,t,Data_to_plot(debut:debut + length(t)-1),colors{p}); set(h_axes_pf_V,'Nextplot','add');
                end
%                 Offset_pf = max(max(Data_to_plot));
            catch Err_pf
                disp(['Erreur affichage ' Data_PF_V(p)]);
            end
        end
        axis(h_axes_pf_V,'tight');
        label_PF_V = colle_labels(Data_PF_V);
        ylabel(h_axes_pf_V,label_PF_V);
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
                        debut_emg = floor((t_debut - t(1))*EMG.(acq_choisie).Fech) +1;
                        fin_emg = debut_emg + (floor((fin - t(1))*EMG.(acq_choisie).Fech));
                        EMG_resampled = EMG.(acq_choisie).val(debut_emg:fin_emg,EMG_col(m));
                        EMG_resampled = resample(EMG_resampled,length(t),length(EMG_resampled));
                        Offset_emg=  max(abs(EMG.(acq_choisie).val(:,EMG_col(m))))/2;
                        plot(h_axes_emg,t,EMG_resampled-(m-1)*Offset_emg,'r'); set(h_axes_emg,'Nextplot','add'); ylabel(h_axes_emg,muscles(p));
                    end
                catch ERr_emg
                    disp(['Erreur affichage ' muscles(m)]);
                end
            end
            axis(h_axes_emg,'tight');
            label_EMG = colle_labels(muscles);
            ylabel(h_axes_emg,label_EMG);
        catch NO_EMG
            disp('Pas d''EMG pour cette acquisition/moyenne');
        end
    end
    
    if isfield(Affiche,'LFP')
        contacts = Affiche.LFP;
        for l=1:length(contacts)
            try
                Offset_lfp = 10;
                if isfield(Corridors_LFP,acq_choisie)
                    Data_to_plot = Corridors_LFP.(acq_choisie).(contacts{l}) - (l-1)*Offset_lfp;
                    Data_to_plot = resample(Data_to_plot',length(t),length(Data_to_plot));
                    stdshade(Data_to_plot',0.4,'b',t,1,h_axes_lfp,1.5,[],0.5);
                else 
                    LFP_to_plot = TraitementLFPs(LFP.(acq_choisie).(contacts{l}),Sujet.(acq_choisie).Fech);
                    LFP_to_plot = LFP_to_plot-(l-1)*Offset_lfp/2;
                    plot(h_axes_lfp,t,LFP_to_plot(debut:debut + length(t)-1)); set(h_axes_lfp,'Nextplot','add'); ylabel(h_axes_lfp,contacts{l});
                end
            catch ERr_emg
                disp(['Erreur affichage ' contacts(l)]);
            end
        end
        axis(h_axes_lfp,'tight');
        label_LFP = colle_labels(contacts,1);
        ylabel(h_axes_lfp,label_LFP);
        xlabel(h_axes_lfp,'Temps(s)');
    end
    
    if isfield(Affiche,'TF')
        contacts = Affiche.TF;
        dw = 0.25; % Taille de fenêtre glissante (sec)
        overlap = 0.95; % en pourcentage
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
%                 plot_matrix_multi(flipdim(X./X0_mat,2),t,flipdim(f,1),'l',h_axes_lfp(l));
                plot_matrix_multi(X./X0_mat,t,f,'l',h_axes_lfp(l));

%                 surf(t,f,10*log10(X./X0_mat)','edgecolor','none','Parent',h_axes_lfp(l));
%                 ylabel(h_axes_lfp(l),contacts{l});
%                 axis(h_axes_lfp(l),'tight');
%                 view(h_axes_lfp(l),0,90);
                
            catch ERr_emg
                disp(['Erreur affichage ' contacts(l)]);
            end
            set(h_axes_lfp(l),'YDir','reverse');
        end
        
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
global h_axes_pf h_marks_T0_lfp h_T0_txt h_marks_HO_lfp h_marks_TO_lfp h_FO1_txt h_marks_FC1_lfp h_FC1_txt h_marks_FO2_lfp h_marks_FC2_lfp h_marks_Onset_TA acq_choisie Sujet Activation_EMG h_marks_Trig h_trig_txt
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

%Actualisation des marqueurs
h_marks_T0_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.T0,'-r');
h_marks_HO_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.HO,'-k');
h_marks_TO_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.TO,'-b');
h_marks_FC1_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.FC1,'-m');
h_marks_FO2_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.FO2,'-g');
h_marks_FC2_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.FC2,'-c');

h_T0_txt = text(Sujet.(acq_choisie).tMarkers.T0,41,'T0',...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','Left',...
            'FontSize',10,...
            'Parent',h_axes_pf);
h_FC1_txt = text(Sujet.(acq_choisie).tMarkers.FC1,41,'FC1',...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','Left',...
            'FontSize',10,...
            'Parent',h_axes_pf);
h_FO1_txt = text(Sujet.(acq_choisie).tMarkers.TO,41,'FO1',...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','Left',...
            'FontSize',10,...
            'Parent',h_axes_pf);        
        
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
            h_marks_Trig = affiche_marqueurs(Sujet.(acq_choisie).Trigger,'*-k');
            h_trig_txt = text(Sujet.(acq_choisie).Trigger,1000,'GO/Trigger',...
                'VerticalAlignment','middle',...
                'HorizontalAlignment','left',...
                'FontSize',8,...
                'Parent',h_axes_pf);
        else
            h_marks_Trig = affiche_marqueurs(Sujet.(acq_choisie).t(1),'*-k');
            h_trig_txt = text(Sujet.(acq_choisie).t(1),1000,['<- Trigger décalé de ' num2str(dec) ' sec'],...
                'VerticalAlignment','middle',...
                'HorizontalAlignment','left',...
                'FontSize',8,...
                'Parent',h_axes_pf);
        end
    end
catch NO_GO
    disp('Pas de GO sonore');
end
    