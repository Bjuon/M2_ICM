function lfp  = affiche_lfps_beta_v5(listes_acqs)
%% Fonction d'affichage des données EEG (LFP) dans une nouvelle interface lfp
global  h_01G h_12G h_23G h_01D h_12D h_23D list_lfp b4 b5 PE filtre lfp_modif multi_lfp

% Création de l'interface de visu
lfp = figure('Name','Visualisation LFPs','tag','Visu_lfp','handlevisibility','on');
b = uiextras.VBox( 'Parent', lfp);
b1 = uiextras.HBox( 'Parent', b);
b2 = uiextras.HBox( 'Parent', b);
b3 = uiextras.VBox( 'Parent', b1); % Menu des boutons
b4 = uiextras.VBox( 'Parent', b2); % LFP côté G
b5 = uiextras.VBox( 'Parent', b2); % LFP côté D

%Ajout de la liste des acquisitions ayant des LFPs
list_lfp = uicontrol( 'Style', 'listbox', 'Parent', b1, 'String', listes_acqs,'Callback',@listLFP_Callback);
b6 = uiextras.VBox( 'Parent', b1); % Menu des radio boutons
filtre = uicontrol( 'Style', 'radiobutton', 'Parent', b6, 'String', 'Appliquer Filtre','tag','Fitre_disp');
multi_lfp = uicontrol( 'Style', 'radiobutton', 'Parent', b6, 'String', 'Bad Trial','tag','Flags_lfp','Callback',@Flag_lfp);
uicontrol( 'Style', 'radiobutton', 'Parent', b6, 'String', 'Affichage multiple','tag','multi_lfp','Enable','Off');
lfp_modif = uicontrol( 'Style', 'pushbutton', 'Parent', b6, 'String', 'Trier Contacts','Callback',@Tag_lfp);

uicontrol( 'Style', 'pushbutton', 'Parent', b3, 'String', 'Calcul Moyenne','Callback',@Calcul_moyenne);
uicontrol( 'Style', 'pushbutton', 'Parent', b3, 'String', 'CPA MRP','Callback',@Calcul_mrp_cusum,'Enable','Off');
uicontrol( 'Style', 'pushbutton', 'Parent', b3, 'String', 'Calcul PE en % de cycle','Callback',@Calcul_PE,'Enable','On');
uicontrol( 'Style', 'pushbutton', 'Parent', b3, 'String', 'Efface Moyenne/PE','Callback',@Delete_PE,'tag','Del_PE');
uicontrol( 'Style', 'pushbutton', 'Parent', b3, 'String', 'Puissance-Fréquence','Callback',@Spectre_lfp);
uicontrol( 'Style', 'pushbutton', 'Parent', b3, 'String', 'Puissance-Fréquence par Période','Callback',@Spectre_lfp_per);
uicontrol( 'Style', 'pushbutton', 'Parent', b3, 'String', 'Temps-Fréquence','Callback',@Time_Freq,'Enable','Off','tag','Time_frq');
uicontrol( 'Style', 'pushbutton', 'Parent', b3, 'String', 'Exporter Figure PE/Moyenne','Callback',@Create_figure,'Enable','Off','tag','Export_fig');

h_01G = axes( 'Parent', b4,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace','ylim',[-40 40]);
% axis tight
    
h_12G = axes( 'Parent', b4,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace','ylim',[-40 40]);
% axis tight
    
h_23G = axes( 'Parent', b4,'ActivePositionProperty', 'Position','NextPlot','replace','ylim',[-40 40]);
% axis tight
    
h_01D = axes( 'Parent', b5,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace','ylim',[-40 40]);
% axis tight

h_12D = axes( 'Parent', b5,'ActivePositionProperty', 'Position','xticklabel',[],'NextPlot','replace','ylim',[-40 40]);
% axis tight

h_23D = axes( 'Parent', b5,'ActivePositionProperty', 'Position','NextPlot','replace','ylim',[-40 40]);
% axis tight

if ~isempty(PE)
    set(findobj('tag','Del_PE'),'Enable','On');
    set(findobj('tag','Time_frq'),'Enable','On');
    set(findobj('String', 'CPA MRP'),'Enable','On');
    set(findobj('tag', 'Export_fig'),'Enable','On');
else
    set(findobj('tag','Del_PE'),'Enable','Off');
end

set(filtre,'Value',1);
set(multi_lfp,'Value',0);

function listLFP_Callback(hObj,event,handles)
%% Affichage LFPs
global h_01G h_12G h_23G h_01D h_12D h_23D list_lfp acq_choisie Sujet LFP_raw LFP_base b4 b5 Corridors_LFP PE PerMarkers_PE h_stim filtre LFP_tri lfp_modif multi_lfp
        
%Récupération de l'acquisition séléctionnée
contents = cellstr(get(list_lfp,'String'));
acq_choisie = contents{get(list_lfp,'Value')};
Fs = LFP_base.Fech;
colors(1:6) = repmat('b',1,6);

try
%     if  ~get(multi_lfp,'Value')
        %Initialisation des plots et marqueurs si Multiplot Off
        axessG = findobj('Type','axes','Parent',b4);
        axessD = findobj('Type','axes','Parent',b5);
        axess = [axessG;axessD];
        for i=1:length(axess)
            set(axess(i),'NextPlot','replace'); % Multiplot Off
        end
%     end
    
     if ~isfield(Corridors_LFP,acq_choisie) && isfield(LFP_raw,acq_choisie)
         lfps = fieldnames(LFP_raw.(acq_choisie));
         t = Sujet.(acq_choisie).t;
         Fech_pf = Sujet.(acq_choisie).Fech;
         
         if Fech_pf~=Fs
             t = t(1):1/Fs:t(end);
         end
         if length(lfps)>6
             lfps(1:length(lfps)-6)=[];
         end
         
         if get(filtre,'Value') %% Si application du filtre 'ON' on filtre
             LFPs_filtered = TraitementLFPs(LFP_raw.(acq_choisie),Fs); %%
         else
             LFPs_filtered = extract_lfps_from_struct(LFP_raw.(acq_choisie)); %%
         end
         
         try
             if LFP_tri.(acq_choisie).Bad_trial
                 set(findobj('tag','Flags_lfp'),'Value',1);
                 set(lfp_modif,'Enable','Off');
                 colors(1:6) = repmat('r',1,6);
             else
                 set(findobj('tag','Flags_lfp'),'Value',0);
                 set(lfp_modif,'Enable','On');
                 for l=1:length(lfps) %% Si mauvais contact on affiche en rouge
                     if LFP_tri.(acq_choisie).(lfps{l})
                         colors(l)='r';
                     end
                 end
             end
         catch NO_tri_yet
             set(findobj('tag','Flags_lfp'),'Value',0);
             set(lfp_modif,'Enable','On');
         end
                 
         plot(h_01G,t,LFPs_filtered(1,1:length(t)),colors(1)); ylabel(h_01G,lfps(1)); axis(h_01G,'tight'); %set(h_01G,'ylim',[-5 5]);
         plot(h_12G,t,LFPs_filtered(2,1:length(t)),colors(2)); ylabel(h_12G,lfps(2)); axis(h_12G,'tight'); %set(h_12G,'ylim',[-5 5]);
         plot(h_23G,t,LFPs_filtered(3,1:length(t)),colors(3)); ylabel(h_23G,lfps(3)); axis(h_23G,'tight'); %set(h_23G,'ylim',[-5 5]);
         xlabel(h_23G,'Temps (sec)');
         
         plot(h_01D,t,LFPs_filtered(4,1:length(t)),colors(4)); ylabel(h_01D,lfps(4)); axis(h_01D,'tight'); %set(h_01D,'ylim',[-5 5]);
         plot(h_12D,t,LFPs_filtered(5,1:length(t)),colors(5)); ylabel(h_12D,lfps(5)); axis(h_12D,'tight'); %set(h_12G,'ylim',[-5 5]);
         plot(h_23D,t,LFPs_filtered(6,1:length(t)),colors(6)); ylabel(h_23D,lfps(6)); axis(h_23D,'tight'); %set(h_23G,'ylim',[-5 5]);
         xlabel(h_23D,'Temps (sec)');
         
         % Pour affichage des marqueurs temporels on relance la fonction d'affichage principale sur l'acquisition choisie
         contents = cellstr(get(findobj('Tag', 'listbox1'),'String'));
         try
             pos = find(compare_liste({acq_choisie},contents)==1);
             set(findobj('Tag', 'listbox1'),'Value',pos);
         catch affich_PE
         end
         try
             Markerslfp_Callback();
         catch Err_LFP_corrs
         end
         
     else
         if isfield(PE,acq_choisie)
             set(lfp_modif,'Enable','Off');
             lfps = fieldnames(PE.(acq_choisie));           
             window_width = length(PE.(acq_choisie).(lfps{1}))/Fs;
             tags = extract_tags(acq_choisie);
             xlabel(h_23D,'Temps (ms)');
             xlabel(h_23G,'Temps (ms)');
             if sum(compare_liste({'Moy'},tags)) || sum(compare_liste({'PE'},tags)) || sum(compare_liste({'CPA'},tags))
%                  t = (-window_width/2+0.5/Fs:1/Fs:window_width/2-0.5/Fs)*1e3;
                 t = (-PerMarkers_PE.(acq_choisie).per(1):1/Fs:PerMarkers_PE.(acq_choisie).per(2));
             elseif sum(compare_liste({'PEcycle'},tags))
                 cycle = length(PE.(acq_choisie).(lfps{1}));
                 step = 100/(cycle-1);
                 t = (0:step:100);
             else
                 t = (0:1/Fs:window_width-1/Fs)*1e3;
             end
             Data_to_plot = PE.(acq_choisie);
             if length(t)~=size(Data_to_plot.(lfps{1}),2)
                 try
                     t = t(1:size(Data_to_plot.(lfps{1}),2));
                 catch err_size
                     dec_t = size(Data_to_plot.(lfps{1}),2) - length(t);
                     vect_t = t(end)+(1:dec_t)*1/Fs;
                     t = [t vect_t];
                 end
             end
         else
            lfps = fieldnames(Corridors_LFP.(acq_choisie));
            t = (0:(length(Corridors_LFP.(acq_choisie).(lfps{1}))-1))./Fs;
            Data_to_plot = Corridors_LFP.(acq_choisie);
         end
         
         if length(lfps)>6
             lfps(1:length(lfps)-6)=[];
         end
         
         smooth=[];
         if get(filtre,'Value') %% Si application du filtre 'ON' on filtre
             smooth = 10;
         end
         
         stdshade(Data_to_plot.(lfps{1}),0.25,'b',t,smooth,h_01G,1.25,1); ylabel(h_01G,lfps{1}); axis(h_01G,'tight');
         stdshade(Data_to_plot.(lfps{2}),0.25,'b',t,smooth,h_12G,1.25,1); ylabel(h_12G,lfps{2}); axis(h_12G,'tight');  
         stdshade(Data_to_plot.(lfps{3}),0.25,'b',t,smooth,h_23G,1.25,1); ylabel(h_23G,lfps{3}); axis(h_23G,'tight');         
         
         stdshade(Data_to_plot.(lfps{4}),0.25,'b',t,smooth,h_01D,1.25,1); ylabel(h_01D,lfps{4}); axis(h_01D,'tight');
         stdshade(Data_to_plot.(lfps{5}),0.25,'b',t,smooth,h_12D,1.25,1); ylabel(h_12D,lfps{5}); axis(h_12D,'tight');  
         stdshade(Data_to_plot.(lfps{6}),0.25,'b',t,smooth,h_23D,1.25,1); ylabel(h_23D,lfps{6}); axis(h_23D,'tight');
         
         if sum(compare_liste({'Moy'},tags)) || sum(compare_liste({'CPA'},tags)) 
             efface_marqueur_test(h_stim);
                 h_stim = affiche_marqueurs(0,'-k');
                 text(0,1,PerMarkers_PE.(acq_choisie).noms,...
                     'VerticalAlignment','middle',...
                     'HorizontalAlignment','Left',...
                     'FontSize',10,...
                     'Parent',h_01D);
                 text(0,1,PerMarkers_PE.(acq_choisie).noms,...
                     'VerticalAlignment','middle',...
                     'HorizontalAlignment','Left',...
                     'FontSize',10,...
                     'Parent',h_01G);
         elseif sum(compare_liste({'PEcycle'},tags))
             xlabel(h_23D,'Pourcentage de cycle (%)');
             xlabel(h_23G,'Pourcentage de cycle (%)');
             try
                Markers_PE_callback(PerMarkers_PE.(acq_choisie));
             catch NO_interEvt
                 disp('Pas d''Evts intermédiaires');
             end
         end
         
     end
     
catch ERR
    waitfor(warndlg('Fermer et recharger la fenêtre de visu des LFPs/PE!','Redraw LFPs'));
end

function Calcul_moyenne(hObj,eventEMG,handles)
%% Moyenner autour d'un évènement
global Sujet Resultats Subject_data LFP_raw LFP_base list_lfp PE PE_base PerMarkers_PE LFP_tri

button = questdlg('Sauvegarder les images de l''analyse?','Analyse Temps-Fréquence','Oui','Non','Non');
if strcmp(button,'Oui')
    path = uigetdir(cd,'Choix du dossier pour le stockage des images');
    sauve=1;
else
    sauve=0;
end

try
    %Choix utilisateur des essais 
    acquisitions = fieldnames(LFP_raw);
    
    [acqs,v] = listdlg('PromptString',{'Calcul Moyenne','Choix des essais à inclure pour le calcul de la moyenne'},...
    'ListSize',[300 300],...
    'ListString',acquisitions);

    %Choix utilisateur de l'évènement Stimuli
    Stimuli = fieldnames(Sujet.(acquisitions{acqs(1)}).tMarkers);
    [check_stim,v] = listdlg('PromptString',{'Choix du Stimuli','Liste des évènements'},...
        'ListSize',[115 115],...
        'ListString',Stimuli,...
        'Selectionmode','Single');
    
    Evts = cell2mat(Stimuli(check_stim));
    Fs = LFP_base.Fech;
    
    %Demande de la taille de fenêtre en millisecondes
    prompt = {'Temps avant l''évènement (ms)','Temps après l''évènement (ms)'};
    default_params = {'1000','1000'};
    rep = inputdlg(prompt,'Paramètres de la fenêtre de moyenneage',1,default_params);
    
    width_Up = str2double(rep{2});
    width_Dn = str2double(rep{1});
    width = width_Up+width_Dn;
    window_width = round((width)*Fs/1e3);

    button = questdlg('Normaliser par 1STD?','Moyennage','Oui','Non','Non');
    if strcmp(button,'Oui')
        normalisation=1;
    else
        normalisation=0;
    end
    
    %Initialisation
    tags = extract_tags(Subject_data.ID);
    try
        session = cell2mat(inputdlg('Entrez le nom de la session/PE','Stockage Moyenne',1,{[tags{1} '_' tags{2} tags{3} '_' tags{4} '_' tags{5}]}));
    catch Err
        session = Subject_data.ID;
    end
    
    %Tri par pied de départ?
    buttonC = questdlg('Trier par Pied de départ?','Moyennage','Gauche','Droite','Droite');
    switch buttonC
        case 'Gauche'
            cote='Gauche';
        case 'Droite'
            cote='Droit';
        otherwise
            cote=[];
    end
    
    save_PE = [session '_Moy_' Evts '_' cote '_' num2str(width)];
    
    N_acq = length(acqs);
    contacts = fieldnames(LFP_raw.(acquisitions{1}));
    N_lfp = length(contacts);
    
    % Gestion du Foot-Contact
    FC=0;
    if strcmp(Evts,'FC1') || strcmp(Evts,'FC2')
        buttonFC = questdlg('Moyenner tous les FC?','Moyennage FC','Oui','Non','Non');
        if strcmp(buttonFC,'Oui')
            FC=1;
            Evts=['FC1';'FC2'];
            save_PE = [session '_Moy_FC_' num2str(width)];
        end
    end
    
     % Gestion du Freezing
    FOG_start=0;
    FOG_end=0;
    if strcmp(Evts,'FOG')
        buttonFOG = questdlg('Moyenner autour du Début ou Fin?','Moyennage FOG','Start','End','Start');
        if strcmp(buttonFOG,'Start')
            FOG_start=1;
            save_PE = [session '_Moy_FOGs_' num2str(width)];
        else
            FOG_end=1;
            save_PE = [session '_Moy_FOGe_' num2str(width)];
        end
    end
        
    for c=1:N_lfp
        Data_PE = NaN*ones(N_acq,window_width+1);
        Data_PE_base = NaN*ones(N_acq,2*Fs); % On stock le signal 2sec avant le GO (comme baseline)
        if FC || FOG_start || FOG_end % On double la taille de la variable de stockage (on suppose 2 FOG au max pr le moment)
            Data_PE = NaN*ones(2*N_acq,window_width+1);
            Data_PE_base = NaN*ones(2*N_acq,2*Fs); % On stocke le signal 2sec avant le GO
        end
        
        l = 0; % Initialisation variable ligne
        
        for i=1:N_acq
%             %% Tri par côté contro/ipsi-latéral (côté Contralatéral puis Ipsilatéral)
%             if strcmp(Resultats.(acquisitions{acqs(i)}).Cote,'Droit')
%                 contacts = {'Contact01G' 'Contact12G' 'Contact23G' 'Contact01D' 'Contact12D' 'Contact23D'};
%             else
%                 contacts = {'Contact01D' 'Contact12D' 'Contact23D' 'Contact01G' 'Contact12G' 'Contact23G'};
%             end
            
            try
                bad_acq = LFP_tri.(acquisitions{acqs(i)}).Bad_trial;
            catch No_tri
                bad_acq =0;
            end
            
            if ~bad_acq
                try
                    bad_contact = LFP_tri.(acquisitions{acqs(i)}).(contacts{c});
                catch exclude
                    bad_contact=0;
                end
                
                % On exclut si pas bon pied de départ
                if ~strcmp(Resultats.(acquisitions{acqs(i)}).Cote,cote) && ~isempty(cote)
                    bad_acq = 1;
                end
            else
                bad_contact=1;
            end
            
            if ~bad_acq && ~bad_contact
                t = Sujet.(acquisitions{acqs(i)}).t;
                if ~iscolumn(t)
                    t=t';
                end
                try
                    if FOG_start || FOG_end
                        n_fog = length(Sujet.(acquisitions{acqs(i)}).tMarkers.(Evts(1,:)));
                    
                        if FOG_start
                            ind = (1:2:n_fog-1)'; %Dummy variable
                        end
                        
                        if FOG_end
                            ind = (2:2:n_fog)'; %Dummy variable
                        end
                    
                        Evts = repmat('FOG',n_fog/2,1); %Dummy variable
                    else
                        ind = 1;
                    end
                    
                    for fc=1:size(Evts,1)
                        l=l+1;
                        Evt = Evts(fc,:);
                        % Extraction des indices de début et fin de fenêtre pour le PE
                        start_t = Sujet.(acquisitions{acqs(i)}).tMarkers.(Evt)(ind(fc)) - (width_Dn*1e-3);
                        start_ind = floor((start_t-t(1))*Fs);
                        stop_t = Sujet.(acquisitions{acqs(i)}).tMarkers.(Evt)(ind(fc)) + (width_Up*1e-3);
                        stop_ind = floor((stop_t-t(1))*Fs);
                        
                        current_lfp = TraitementLFPs(LFP_raw.(acquisitions{acqs(i)}).(contacts{c}),Fs);
                        current_lfp_pre = TraitementLFPs(LFP_base.(acquisitions{acqs(i)}).(contacts{c}),Fs); %% Les 2 secondes avt l'instruction
                        
                        % On complète par des NaN en cas d'absence de données
                        if stop_ind>length(current_lfp)
                            dec_end = round((stop_t - t(end))*Fs);
                            fitnan = NaN*ones(1,dec_end);
                            current_lfp = [current_lfp fitnan];
                        end
                                               
                        if start_t<0
                            dec = round((t(1)-start_t)*Fs);
                            fit_pre = current_lfp_pre(end-dec+1:end);
                            Data_PE(l,:) = [fit_pre current_lfp(1:window_width-dec+1)]; 
                        else
                            Data_PE(l,:) = current_lfp(start_ind:start_ind+window_width); 
                        end
                        
                        Data_PE_base(l,:) = current_lfp_pre;
                        
                        %Normalisation (Z-score)
                        if normalisation
                            Data_PE(l,:) = Data_PE(l,:)/nanstd(Data_PE(l,:));
%                             Data_PE_base(i,:) = Data_PE_base/nanstd(Data_PE(i,:));
                        end
                    end
                catch NO_Evt
                    disp(['Pas d''évènement ' Evt ' dans :' acquisitions{acqs(i)}]);
                end
                
            else
                disp(['Exculsion: ' acquisitions{acqs(i)} ' - ' contacts{c}]);
            end
        end
        
        PE.(save_PE).(contacts{c}) = Data_PE;
        PE_base.(save_PE).(contacts{c}) = Data_PE_base;
    end
    
    %Affichage
    PerMarkers_PE.(save_PE).noms = {Evt};
    PerMarkers_PE.(save_PE).per = [width_Dn width_Up]./1e3;
    contents = cellstr(get(list_lfp,'String'));
    set(list_lfp,'Value',1);
    set(list_lfp,'String',[contents;save_PE]);
    last = length(contents) + 1;
    set(list_lfp,'Value',last);
    set(findobj('tag','Del_PE'),'Enable','On');
    set(findobj('tag','Time_frq'),'Enable','On');
    set(findobj('String', 'CPA MRP'),'Enable','On');
    set(findobj('tag', 'Export_fig'),'Enable','On');
    listLFP_Callback();
    
    if sauve
        Create_figure(save_PE,path);
    end
    
catch ERR
    disp('Arrêt moyennage LFP');
end

function Calcul_mrp_cusum(hObj,eventEMG,handles)
%% Calcul des residus cumulés (Change-Point-Analysis) des PE
global list_lfp PE PerMarkers_PE

try
    % Extraction des Moyennes
    listes_Moy = fieldnames(PE);
    A = strfind(listes_Moy,'Moy_');
    ok = true*ones(1,length(A));
    for a=1:length(A)
        if isempty(A{a})
            ok(a)=false;
        end
    end   
    listes_Moy = listes_Moy(ok==1);
    
    %Sélections de l'utilisateur
    [i,v] = listdlg('PromptString',{'Choix du/des moyennes uniquement!'},...
        'ListSize',[300 300],...
        'ListString',listes_Moy,'SelectionMode','Multiple');
    
    selection = listes_Moy(i);
    add = length(selection);
    save_PE_cpa=cell(add,1);
    for i=1:add
        current_PE = PE.(selection{i});
        contacts = fieldnames(current_PE);
        tags = extract_tags(selection{i});
        session = [tags{1} '_' tags{2} '_' tags{3}];
        save_PE_cpa{i} = [session '_CPA_' tags{end-1} '_' tags{end}];
        for c = 1:length(contacts)
            [Data Data_PE] = change_point_analysis_cusum(current_PE.(contacts{c})');
            PE.(save_PE_cpa{i}).(contacts{c}) = Data_PE';
        end
        
        % Sauvegarde Repères temporels
        PerMarkers_PE.(save_PE_cpa{i}).noms = PerMarkers_PE.(selection{i}).noms;
        PerMarkers_PE.(save_PE_cpa{i}).per = PerMarkers_PE.(selection{i}).per ;
    end
    
    %Affichage
    
    contents = cellstr(get(list_lfp,'String'));
    set(list_lfp,'Value',1);
    set(list_lfp,'String',[contents;save_PE_cpa]);
    last = length(contents) + add;
    set(list_lfp,'Value',last);
    set(findobj('tag','Del_PE'),'Enable','On');
    set(findobj('tag','Time_frq'),'Enable','On');
    set(findobj('tag', 'Export_fig'),'Enable','On');
    listLFP_Callback();

catch Err_cpa
    disp('Arrêt change-point analysis!');
end

function Calcul_PE(hObj,eventEMG,handles)
%% Calcul d'un PE (en % de cycle d'initation ou de préparation): i.e. entre GO et T0
global Sujet Subject_data LFP_raw LFP_base list_lfp PE PerMarkers_PE Duree_cycles_PE LFP_tri

button = questdlg('Sauvegarder les images de l''analyse?','Analyse Temps-Fréquence','Oui','Non','Non');
if strcmp(button,'Oui')
    path = uigetdir(cd,'Choix du dossier pour le stockage des images');
    sauve=1;
else
    sauve=0;
end

try
    %Choix utilisateur des essais 
    acquisitions = fieldnames(LFP_raw);
    
    [acqs,v] = listdlg('PromptString',{'Calcul PE','Choix des essais à inclure pour le calcul du PE'},...
    'ListSize',[300 300],...
    'ListString',acquisitions);
    N_acq = length(acqs);
    Dt_cycle = NaN*ones(N_acq,1);
    
    %Choix utilisateur des évènements
    Stimuli = fieldnames(Sujet.(acquisitions{acqs(1)}).tMarkers);
    [check_stim,v] = listdlg('PromptString',{'Choix des 2 évènements','Liste des évènements'},...
        'ListSize',[115 115],...
        'ListString',Stimuli);
    
    try
        Evts = Stimuli(check_stim(1:2)); % On prend les 2 premiers au cas ou + de 2 evts ont été selectionnés
        d = diff(check_stim(1:2));
        if d>1
            Evts_inter = Stimuli(check_stim(1)+1:check_stim(2)-1);
            Per_evt = NaN*ones(N_acq,length(Evts_inter));
        else
            Evts_inter = {};
        end
        FOG=0;
    catch select_FOG
        FOG=1;
        Evts = Stimuli(check_stim); % cas du FOG uniquement
        Evts_inter = {};
    end
        
    
    Fs = LFP_base.Fech;
    
    button = questdlg('Normaliser par 1STD?','Moyennage','Oui','Non','Non');
    if strcmp(button,'Oui')
        normalisation=1;
    else
        normalisation=0;
    end
    
    %Initialisation
    tags = extract_tags(Subject_data.ID);
    try
        session = [tags{1} '_' tags{2} tags{3} '_' tags{4}];
    catch Err
        session = Subject_data.ID;
    end
    
    %Nom du cycle
    prompt = {'Patient/Condition','Nom du cycle'};
    default_params = {session,'Preparation'};
    rep = inputdlg(prompt,'Paramètres du cycle calculé',1,default_params);
    
    session = rep{1};
    nom_cycle = rep{2};
    save_PE = [session '_PEcycle_' nom_cycle];
    
    contacts = fieldnames(LFP_raw.(acquisitions{1}));
    N_lfp = length(contacts);
    
    for c=1:N_lfp
        if FOG
            Data_PE = NaN*ones(2*N_acq,201);
        else
            Data_PE = NaN*ones(N_acq,201);
        end
        
        l=0;
        for i=1:N_acq
            
            try
                bad_acq = LFP_tri.(acquisitions{acqs(i)}).Bad_trial;
            catch No_tri
                bad_acq =0;
            end
            
            if ~bad_acq
                try
                    bad_contact = LFP_tri.(acquisitions{acqs(i)}).(contacts{c});
                catch exclude
                    bad_contact=0;
                end
            else
                bad_contact=1;
            end
            
            if ~bad_acq && ~bad_contact
                t = Sujet.(acquisitions{acqs(i)}).t;
                current_lfp = TraitementLFPs(LFP_raw.(acquisitions{acqs(i)}).(contacts{c}),Fs);
                
                %Recuperation des 2 evts
                if FOG
                    n_fog = length(Sujet.(acquisitions{acqs(i)}).tMarkers.(Evts{1}))/2;
                    Evts = repmat({'FOG'},n_fog/2,1); %Dummy variable
                    ind = (1:n_fog);
                else
                    n_fog = 1; % Sham variable
                    ind = [1 1];
                end
                
                for p = 1:n_fog
                    l = l+1; %Incrémentation de la ligne
                    start_t = Sujet.(acquisitions{acqs(i)}).tMarkers.(Evts{1})(ind(2*(p-1)+1));
                    stop_t = Sujet.(acquisitions{acqs(i)}).tMarkers.(Evts{2})(ind(2*p));
                    debut = floor((start_t-t(1))*Fs)+1;
                    fin = floor((stop_t-t(1))*Fs);
                    if fin>length(current_lfp) % Cas ou le end est en dehors de l'acquisition
                        fitnan = NaN*ones(1,fin-length(current_lfp));
                        current_data = [current_lfp(debut:end) fitnan];
                    else
                        current_data = current_lfp(debut:fin);
                    end
                    
                    %Normalisation (Z-score) et en pourcentage de cycle
                    if normalisation %Z-Score
                        current_data = current_data/nanstd(current_data);
                    end
                    
                    uncycle = (0:(200/(fin-debut)):200)';
                    echant = (0:200);
                    Data_PE(l,:) = interp1(uncycle,current_data,echant,'spline');
                end
                
                %Recuperation des evts intermédiaires
                if c==length(contacts)
                    Dt_cycle(i) = (stop_t-start_t);
                    if ~isempty(Evts_inter)
                        for e=1:length(Evts_inter)
                            evt_t = Sujet.(acquisitions{acqs(i)}).tMarkers.(Evts_inter{e});
                            Per_evt(i,e) = (evt_t - start_t)*100/Dt_cycle(i);
                        end
                    end
                end
                                       
                
            else
                disp(['Exculsion: ' acquisitions{acqs(i)} '_' contacts{c}]);
            end
        end
        
        PE.(save_PE).(contacts{c}) = Data_PE;
    end
    if ~isempty(Evts_inter)
        PerMarkers_PE.(save_PE).noms = Evts_inter';
        PerMarkers_PE.(save_PE).per = troncature(nanmean(Per_evt,1),1); %% Variable contenant les % moyens de chaque evt intermédiaire en fonction du cycle
    end
    Duree_cycles_PE.(save_PE) = Dt_cycle;
    
    %Affichage
    contents = cellstr(get(list_lfp,'String'));
    set(list_lfp,'Value',1);
    set(list_lfp,'String',[contents;save_PE]);
    last = length(contents) + 1;
    set(list_lfp,'Value',last);
    set(findobj('tag','Del_PE'),'Enable','On');
    set(findobj('tag','Time_frq'),'Enable','On');
    listLFP_Callback();
    set(findobj('tag', 'Export_fig'),'Enable','On');
    
    if sauve
        Create_figure(save_PE,path);
    end
    
catch ERR
    disp('Arrêt calcul PE');
end

function Delete_PE(hObj,eventEMG,handles)
%% Retirer un PE si mauvais
global PE PE_base list_lfp
% hObject    handle to Clean_corridor (see GCBO)

try
listes_corr = fieldnames(PE);
%Sélections de l'utilisateur
[i,v] = listdlg('PromptString',{'Choix du/des moyennes/PE à effacer'},...
    'ListSize',[300 300],...
    'ListString',listes_corr,'SelectionMode','Multiple');

list_display = cellstr(get(list_lfp,'String'));
set(list_lfp,'Value',1);
list_remove = listes_corr(i);
to_rmv = sum(compare_liste(list_display,list_remove),2);
new_list = list_display(to_rmv==0);

for corrd=1:length(i)
    try
        PE = rmfield(PE,list_remove(corrd));
        PE_base = rmfield(PE_base,list_remove(corrd));
    catch ERr_PE
    end 
end

disp('Moyennes/PE supprimés:');
listes_corr(i)

listes_corr_post = fieldnames(PE);
if isempty(listes_corr_post)
    set(findobj('tag','Del_PE'), 'Enable','Off');
end

set(list_lfp,'String',new_list);

catch ERR
    warndlg('!!Pas de PE/Moyennes calculés!!')
end

function Time_Freq(hObj,eventEMG,handles)
%% Anayse temps-fréquence sur les variables PE déjà calculés
global PE PE_base PerMarkers_PE LFP_base

button = questdlg('Sauvegarder les images de l''analyse?','Analyse Temps-Fréquence','Oui','Non','Non');
if strcmp(button,'Oui')
    path = uigetdir(cd,'Choix du dossier pour le stockage des images');
    sauve=1;
else
    sauve=0;
end

try
% Extraction des Moyennes
    listes_Moy = fieldnames(PE);
    A = strfind(listes_Moy,'Moy_');
    ok = true*ones(1,length(A));
    for a=1:length(A)
        if isempty(A{a})
            ok(a)=false;
        end
    end   
    listes_Moy = listes_Moy(ok==1);
    
%Sélections de l'utilisateur
[i,v] = listdlg('PromptString',{'Choix du/des moyennes uniquement!'},...
    'ListSize',[300 300],...
    'ListString',listes_Moy,'SelectionMode','Multiple');

selection = listes_Moy(i);
Fs = LFP_base.Fech;

%Paramètres de l'analyse
prompt = {'Taille de fenêtre (ms)','Overlapping (%)','Fréquence min (Hz)','Fréquence max (Hz)'};
default_params = {'333','97','1','100'};
rep = inputdlg(prompt,'Paramètres de l''analyse Temps-Fréquence',1,default_params);

window_width = round(str2double(rep{1})*Fs/1e3);
overlap_width = round(str2double(rep{2})*window_width/1e2);
Fmin = str2double(rep{3});
Fmax = str2double(rep{4});

prompt2 = {'Fréquence Min(Hz)','Fréquence Max (Hz)'};
default_params2 = {'12','25'};
rep2 = inputdlg(prompt2,'Paramètres de l''analyse Puissance-Temps',1,default_params2);
FMin = str2double(rep2{1});
FMax = str2double(rep2{2});

% Pour la colorbar du spectrogram
prompt3 = {'Xmin','Xmax'};
default_params3 = {'',''};
rep3 = inputdlg(prompt3,'Paramètres des axes TF',1,default_params3);
XMin = str2double(rep3{1});
XMax = str2double(rep3{2});

try
    if ~isnan(XMin) && ~isnan(XMax)
        axes_auto = 1;
    else
        axes_auto = 0;
    end
catch
    axes_auto = 0;
end

button2 = questdlg('Calculs les spectrograms via Chronux?','Analyse Temps-Fréquence','Oui','Non','Non');
if strcmp(button2,'Oui')
    dw = str2double(rep{1})/1e3;
    dt = dw - str2double(rep{2})*dw/100;
    movingwin = [dw dt];
    parms.Fs = Fs;
    parms.fpass = [Fmin Fmax];
    parms.tapers = [2 3];
    parms.trialave = 0;
    parms.pad = 2;
    chronux=1;
else
    chronux =0;
end

button2 = questdlg('Normaliser les calculs de puissance?','Analyse Temps-Fréquence','Oui','Non','Non');
if strcmp(button2,'Oui')
    normalisation=1;
    liste_base = fieldnames(PE_base);
    
    [b,v] = listdlg('PromptString',{'Choix de la ligne de base'},...
    'ListSize',[300 300],...
    'ListString',liste_base,'SelectionMode','Single');

    lfps_to_process_pre = PE_base.(liste_base{b});
    contacts = fieldnames(lfps_to_process_pre);
    if length(contacts)>6 %% (pour évitre d'afficher les contacts inutiles (sachant que nous avons 6)
        contacts(1:length(contacts)-6)=[];
    end
    
    S_base=[];
    P_base=[];
    N_contact = length(contacts);
    wb1 = waitbar(0);
    for c = 1:N_contact
        signals_to_process_pre = lfps_to_process_pre.(contacts{c});
        waitbar(c/N_contact,wb1,['Calculating Baseline Spectrogram for: ' contacts{c}]);
        for s = 1:size(signals_to_process_pre,1)
            if ~chronux
                L = length(signals_to_process_pre(s,end-Fs/2:end)); %% Taille de la baseline [-2 ou -500 ms?]
                NFFT = 2^nextpow2(L);
                setp_f = (Fmax-Fmin)/NFFT;
                vect_F = [Fmin:setp_f:Fmax];
                [S_base(:,:,s,c),F,T,P_base(:,:,s,c)] = spectrogram(signals_to_process_pre(s,end-Fs/2:end),window_width,overlap_width,vect_F,Fs); %%
            else
                [P_b,T,F] = mtspecgramc(signals_to_process_pre(s,end-Fs/2:end),movingwin,parms); %% ON prend 500ms avant le GO
                P_base(:,:,s,c) = P_b';
            end
            % F: vecteur des fréquences
            % T: vecteur temps
            % P: matrice des puissance (dim1: par fréquence; dim2: par temps; dim3: par essai; dim4: par contact)
        end
    end
    close(wb1);
else
    normalisation=0;
end

wb = waitbar(0);
set(wb,'Name','Please wait...');
for tf = 1:length(i)
    lfps_to_process = PE.(selection{tf});
    
    tags = extract_tags(selection{tf});
    Evt = tags{end-1};
    file_to_print = [tags{1} '_' tags{3} '_' tags{4} '_' Evt '_' rep{1}];
    
    contacts = fieldnames(lfps_to_process);
    
    if length(contacts)>6 %% (pour évitre d'afficher les contacts inutiles (sachant que nous avons 6)
        contacts(1:length(contacts)-6)=[];
    end
    
    S=[];
    P=[];
    P_norm = [];
    
    f=figure('Name',file_to_print);
    waitbar(0,wb);
    set(wb,'Name',['Please wait... Calculating Time-Frequency power distributions for ' tags{1}]);
    N_contact = length(contacts);
    for c = 1:N_contact
        signals_to_process = lfps_to_process.(contacts{c});
        waitbar(c/N_contact,wb,[tags{1} '- Calculating contact: ' contacts{c}]);
        for s = 1:size(signals_to_process,1)
            if ~chronux
                L=length(signals_to_process_pre(s,:));
                NFFT = 2^nextpow2(L);
                setp_f = (Fmax-Fmin)/NFFT;
                [S(:,:,s,c),F,T,P(:,:,s,c)] = spectrogram(signals_to_process(s,:),window_width,overlap_width,vect_F,Fs);
                % F: vecteur des fréquences, T : vecteur temps
                % P: matrice des puissance (dim1: par fréquence; dim2: par temps; dim3: par essai; dim4: par contact)
            else
                [p,T,F] = mtspecgramc(signals_to_process(s,:),movingwin,parms);
                P(:,:,s,c) = p';
                vect_F = F;
            end
            if normalisation
                P_norm(:,:,s,c) = P(:,:,s,c)./repmat(nanmean(P_base(:,:,s,c),2),1,length(T));
            end
        end
        
        % Affichage du spectrogram par contact
        subplot(2,length(contacts)/2,c);
        t = (-PerMarkers_PE.(selection{tf}).per(1):1/Fs:PerMarkers_PE.(selection{tf}).per(2));
        T = t(1:length(t)/length(T):end);
        
        if ~normalisation
            surf(T,F,10*log10(abs(squeeze(nanmean(P(:,:,:,c),3)))),'edgecolor','none');
            title(contacts{c});
        else
            surf(T,F,10*log10(abs(squeeze(nanmean(P_norm(:,:,:,c),3)))),'edgecolor','none');
            title([contacts{c} ' - Normalized']);
        end
        
        axis tight;
        if axes_auto
            caxis([-XMin XMax]);
        end
        if c==3 || c==6
            colorbar
        end
        hold on
        
        pplan([0 40 0;1 0 0]);
        view(0,90);
        text(0,40,PerMarkers_PE.(selection{tf}).noms,...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','Left',...
            'FontSize',12,...
            'FontWeight','bold',...
            'Parent',gca);
    
        xlabel('Time (Seconds)'); ylabel('Hz');
        
    end
    
    %% Affichage du spectrogram moyen entre tous les bons dipôles du même hémisphère
    buttonM = questdlg('Affichage Spectrograms moyen par hémisphère?','Visualisation Temps-Fréquence','Oui','Non','Non');
    if strcmp(buttonM,'Oui')
        f2=figure('Name',file_to_print);
        cote = {'STN-Droit' 'STN-Gauche'};
        waitbar(1,wb,[tags{1} '- Plotting mean spectrogram per side']);
        for c=1:2
            subplot(2,1,c);
            t = (-PerMarkers_PE.(selection{tf}).per(1):1/Fs:PerMarkers_PE.(selection{tf}).per(2)); % On recupères les tailles de fenêtres du PE
            T = t(1:length(t)/length(T):end);
            
            if ~normalisation
                P_to_plot =  abs(nanmean(P(:,:,:,3*(c-1)+1:3*c),3));
                surf(T,F,10*log10(nanmean(P_to_plot,4)),'edgecolor','none');
                title(cote{c});
            else
                P_to_plot =  abs(nanmean(P_norm(:,:,:,3*(c-1)+1:3*c),3));
                surf(T,F,10*log10(nanmean(P_to_plot,4)),'edgecolor','none');
                title([cote{c} ' - Normalized']);
            end
            
            axis tight;
            if axes_auto
                caxis([-XMin XMax]);
            end
            
            colorbar
            hold on
            
            % Affichage de l'évènement (temps =0)
            pplan([0 40 0;1 0 0]);
            view(0,90);
            text(0,40,PerMarkers_PE.(selection{tf}).noms,...
                'VerticalAlignment','middle',...
                'HorizontalAlignment','Left',...
                'FontSize',12,...
                'FontWeight','bold',...
                'Parent',gca);
            
            xlabel('Time (Seconds)'); ylabel('Hz');
        end
    end
    
    % Sauvegarde de l'image et de la variable du spectrogram
    waitbar(1,wb,[tags{1} '- Saving...']);
    if sauve
        if normalisation
            file_to_print = [file_to_print '_Normalized'];
        end
        print(f,'-djpeg','-r300',[path '\T-Freq_' file_to_print]);
        try
            print(f2,'-djpeg','-r300',[path '\T-Freq_Mean_' file_to_print]);
        catch
        end
        eval(['save ' [path '\TFreq_' file_to_print] ' T F P P_norm']); 
    end
    
    col1 = find(vect_F>=FMin,1,'first') - 1;
    col2 = find(vect_F>=FMax,1,'first') - 1;
    
    % Calcul Puissance-Temps sur une bande de fréquence
    f1=figure;
    waitbar(1,wb,[tags{1} '- Calculating Power-Time plot']);
    title(file_to_print);
    for c = 1:length(contacts)
        h=subplot(2,length(contacts)/2,c);
        if ~normalisation
            vect_P = nanmean(nanmean(P(col1:col2,:,:,c),3),1); % On calcul la moyenne des puissances entre les acquisitions puis entre toutes les fréquences définies par la bande
        else
            vect_P = nanmean(nanmean(P_norm(col1:col2,:,:,c),3),1);
        end
        
        plot(T,10*log10(smooth(vect_P)),'Linewidth',1.5);
        axis tight
        xlabel('Time (Seconds)'); ylabel(['Puissance Moyenne(dB) - bande:' num2str(FMin) '-' num2str(FMax) ' Hz']);
        afficheX_v2(0);
        text(0,median(10*log10(vect_P)),Evt,...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','Left',...
            'FontSize',10,...
            'Parent',h);
        
        title(h,contacts{c});
    end
    if sauve
        print(f1,'-djpeg','-r300',[path '\PowT_' file_to_print]);
        eval(['save ' [path '\PowT_' file_to_print] ' T vect_P']); 
    end
end
close(wb);
catch ERR_TF
    errordlg('Arrêt analyse temps-fréquence');
end

function Spectre_lfp(hObj,eventEMG,handles)
%% Calcul du spectre de puissance
global Sujet Resultats Subject_data LFP_raw LFP_base LFP_tri

try
    %% Choix utilisateur
    acquisitions = fieldnames(LFP_raw);
    
    % Essais
    [acqs,v] = listdlg('PromptString',{'Calcul TF','Choix des essais à inclure'},...
    'ListSize',[300 300],...
    'ListString',acquisitions);
    
    %Tri par pied de départ?
    buttonC = questdlg('Trier par Pied de départ?','Moyennage','Gauche','Droite','Droite');
    switch buttonC
        case 'Gauche'
            cote='Gauche';
        case 'Droite'
            cote='Droit';
        otherwise
            cote=[];
    end
    
    % Normalisation?
    button = questdlg('Normaliser par 1STD?','Moyennage','Oui','Non','Non');
    if strcmp(button,'Oui')
        normalisation=1;
    else
        normalisation=0;
    end
    
    % Durée essai?
    buttonD = questdlg('Durée de l''essai?','Trial Duration Selection','FC2','Fin','FC2');
    if strcmp(buttonD,'FC2')
        cut_FC2=true;
    else
        cut_FC2=false;
    end
    
    % Comparaison?
    buttonC = questdlg('Comparer avec autre condition/sujet?','Visu Spectre','Oui','Non','Non');
    if strcmp(buttonC,'Oui')
        comparaison=1;
        [file_CI path_CI] = uigetfile('.mat','Variable DSP de la Condition');
        CI = load([path_CI file_CI]);
    else
        comparaison=0;
        CI.P = NaN;
        CI.P_base = NaN;
    end
    
    N_acq = length(acqs);
    contacts = fieldnames(LFP_raw.(acquisitions{1}));
    Fs = LFP_base.Fech;
    
    if length(contacts)>6 %% (pour évitre d'afficher les contacts inutiles (sachant que nous avons 6)
        contacts(1:length(contacts)-6)=[];
    end
    
    N_lfp = length(contacts);
    
    % Paramètres de calcul
    parms.Fs = Fs;
    parms.fpass = [0 100];
    parms.tapers = [2 3];
    parms.trialave = 0;
    parms.pad = 1;
    
    %% Calcul
    f=figure('Name',[Subject_data.ID '_0-49Hz']);
    f1=figure('Name',[Subject_data.ID '_51-100Hz']);
    for c=1:N_lfp
        i_check = 0;
        for i=1:N_acq            
            try
                bad_acq = LFP_tri.(acquisitions{acqs(i)}).Bad_trial;
            catch No_tri
                bad_acq =0;
            end
            
            if ~bad_acq
                try
                    bad_contact = LFP_tri.(acquisitions{acqs(i)}).(contacts{c});
                catch
                    bad_contact=0;
                end
                
                % On exclut si pas bon pied de départ
                if ~strcmp(Resultats.(acquisitions{acqs(i)}).Cote,cote) && ~isempty(cote)
                    bad_acq = 1;
                end
                
            else
                bad_contact=1;
            end
            
            if ~bad_acq && ~bad_contact
                i_check = i_check+1;
                t = Sujet.(acquisitions{i}).t;
                FC2 = Sujet.(acquisitions{i}).tMarkers.FC2;
                ind_FC2 = floor((FC2-t(1))*Fs);
                lfp = TraitementLFPs(LFP_raw.(acquisitions{acqs(i)}).(contacts{c}),Fs);
                lfp_pre = TraitementLFPs(LFP_base.(acquisitions{acqs(i)}).(contacts{c}),Fs); % 2 secondes avant le GO sonore
                
                %Conditionnement
                if cut_FC2 && ~isnan(FC2)
                    current_lfp = lfp(1:ind_FC2); % De -0.2 secondes avt l'instruction jusqu'à FC2 (~2secs)
                else
                    current_lfp = lfp; % De -0.2 secondes avt l'instruction jusqu'à la fin de l'essai
                end
                                
                %Normalisation
                if normalisation
                    z = nanstd(current_lfp);
                    current_lfp = current_lfp/z;
                end
                
                try
                    [P(i_check,:,c), F] = mtspectrumc(current_lfp,parms);
                    [P_base(i_check,:,c), F_base] = mtspectrumc(lfp_pre,parms);
                catch ERr
                    [Pp Ff] = mtspectrumc(current_lfp,parms);
                    [Pp_base Ff_base] = mtspectrumc(lfp_pre,parms);
                    
                    P(i_check,:,c) = interp1(Ff,Pp,F);
                    P_base(i_check,:,c) = interp1(Ff_base,Pp_base,F_base);
                end
            end
        end
    end
    
    buttonPlot = questdlg('Afficher spectres avant instruction?','Visu Spectre','Oui','Non','Non');
    if strcmp(buttonPlot,'Oui')
        baseline=1;
        F_plot = F_base;
        P_plot = P_base;
    else
        baseline=0;
        F_plot = F;
        P_plot = P;
    end
    
    plotype = 'n'; % ou 'n' pour affichage linéaire du spectre
    for c=1:N_lfp 
        %Affichage
        set(f,'Visible','On');
        subplot(2,N_lfp/2,c,'Parent',f);
        plot_vector(nanmean(P_plot(:,:,c),1),F_plot,plotype,[],'b');
        if comparaison
            hold on
            if ~baseline
                plot_vector(nanmean(CI.P(:,:,c),1),CI.F,plotype,[],'r');
            else
                plot_vector(nanmean(CI.P_base(:,:,c),1),CI.F_base,plotype,[],'r');
            end
        end
        
        axis tight
        set(gca,'xlim',[0 49]);
        grid
        title(contacts{c});
        
        if comparaison
            CI_tags = extract_tags(file_CI(1:end-4));
            CI_tags = [CI_tags{end-1} '-' CI_tags{end}];
            
            tags = extract_tags(acquisitions{acqs(1)});
            current_tags = [tags{end-2} '-' tags{end}(1:end-1)];
            legend(current_tags,CI_tags);
        end
        
        set(f1,'Visible','On');
        subplot(2,N_lfp/2,c,'Parent',f1);
        plot_vector(nanmean(P_plot(:,:,c),1),F_plot,plotype,[],'b');
        if comparaison
            hold on
            if ~baseline
                plot_vector(nanmean(CI.P(:,:,c),1),CI.F,plotype,[],'r');
            else
                plot_vector(nanmean(CI.P_base(:,:,c),1),CI.F_base,plotype,[],'r');
            end
        end
        
        set(gca,'xlim',[51 100]);
        set(gca,'ylim',[0 max(nanmean(P_plot(:,find(F_plot==50):end,c),1))]); %%%%
        grid
        title(contacts{c});
        if comparaison
            legend(current_tags,CI_tags);
        end
    end
    
    %% Sauvegarde
    button = questdlg('Sauvegarder l''image de l''analyse?','Analyse Spectrale','Oui','Non','Non');
    if strcmp(button,'Oui')
        path = uigetdir(cd,'Choix du dossier pour le stockage des images');
        tags = extract_tags(Subject_data.ID);
        file_to_print = ['PSD_' tags{1} '_' tags{2} '_' tags{3}];
        eval(['save ' [path '\' file_to_print] ' F F_base P P_base' ]);
        
        if normalisation
            file_to_print = [file_to_print '_N'];
        end
        if comparaison
            CI_tags = extract_tags(file_CI(1:end-4));
            file_to_print = [file_to_print '_VS_' CI_tags{end-1} '_' CI_tags{end}];
        end
        
        if baseline
            file_to_print = [file_to_print '_preInstruction'];
        end
        
        print(f,'-djpeg','-r300',[path '\' file_to_print '_0-49Hz']);
        print(f1,'-djpeg','-r300',[path '\' file_to_print '_51-100Hz']);
    end  
    
catch ERR
    disp('Arrêt calcul DSP');
end

function Spectre_lfp_per(hObj,eventEMG,handles)
%% Calcul des spectres de puissance par période d'initiation
global Sujet Resultats Subject_data LFP_raw LFP_base LFP_tri

try
    %Choix utilisateur des essais 
    acquisitions = fieldnames(LFP_raw);
    
    [acqs,v] = listdlg('PromptString',{'Calcul TF','Choix des essais à inclure'},...
    'ListSize',[300 300],...
    'ListString',acquisitions);
    
    button = questdlg('Normaliser par 1STD?','Moyennage','Oui','Non','Non');
    if strcmp(button,'Oui')
        normalisation=1;
    else
        normalisation=0;
    end
    
    buttonC = questdlg('Comparer avec autre condition/sujet?','Visu Spectre','Oui','Non','Non');
    if strcmp(buttonC,'Oui')
        comparaison=1;
        [file_CI path_CI] = uigetfile('.mat','Variable DSP de la Condition');
        CI = load([path_CI file_CI]);
    else
        comparaison=0;
        CI.P = NaN;
        CI.P_base = NaN;
    end
    
    %Tri par pied de départ?
    buttonc = questdlg('Trier par Pied de départ?','Moyennage','Gauche','Droite','Droite');
    switch buttonc
        case 'Gauche'
            cote='Gauche';
        case 'Droite'
            cote='Droit';
        otherwise
            cote=[];
    end
    
    N_acq = length(acqs);
    contacts = fieldnames(LFP_raw.(acquisitions{1}));
    Fs = LFP_base.Fech;
    
    if length(contacts)>6 %% pour évitre d'afficher les contacts inutiles (sachant que nous avons 6)
        contacts(1:length(contacts)-6)=[];
    end
    
    N_lfp = length(contacts);
    
    % Paramètres de calcul
    parms.Fs = Fs;
    parms.fpass = [4 100];
    parms.tapers = [2 3];
    parms.trialave = 0;
    parms.pad = 1;
    
    % Lancements des calculs des spectres par essai/contact/période
    for c=1:N_lfp
        i_check = 0;
        for i=1:N_acq            
            try
                bad_acq = LFP_tri.(acquisitions{acqs(i)}).Bad_trial;
            catch No_tri
                bad_acq =0;
            end
            
            if ~bad_acq
                try
                    bad_contact = LFP_tri.(acquisitions{acqs(i)}).(contacts{c});
                catch
                    bad_contact=0;
                end
                
                % On exclut si pas bon pied de départ
                if ~strcmp(Resultats.(acquisitions{acqs(i)}).Cote,cote) && ~isempty(cote)
                    bad_acq = 1;
                end
                
            else
                bad_contact=1;
            end
            
            if ~bad_acq && ~bad_contact
                i_check = i_check+1;
                t = Sujet.(acquisitions{i}).t;
                
                % Extraction des evts du pas
                GO = Sujet.(acquisitions{i}).tMarkers.TR;
                T0 = Sujet.(acquisitions{i}).tMarkers.T0;
                TO = Sujet.(acquisitions{i}).tMarkers.TO;
                FC1 = Sujet.(acquisitions{i}).tMarkers.FC1;

                ind_GO = floor((GO-t(1))*Fs);
                ind_T0 = floor((T0-t(1))*Fs);
                ind_TO = floor((TO-t(1))*Fs);
                ind_FC1 = floor((FC1-t(1))*Fs);
                
                lfp = TraitementLFPs(LFP_raw.(acquisitions{acqs(i)}).(contacts{c}),Fs);
                lfp_pre = TraitementLFPs(LFP_base.(acquisitions{acqs(i)}).(contacts{c}),Fs);
                
                %Normalisation
                if normalisation
                    lfp = zscore(lfp);
                    lfp_pre = zscore(lfp_pre);
                end
                
                %% Conditionnement par période de cycle d'initiation
                Periodes = {}; % Initialisation de la structure
                Periodes.lfp_repos = lfp_pre(end-round(Fs/2):end); % Période de repos: 500ms avant l'instruction
                
                % Période de réaction: Entre le GO et T0 (~400ms)
                if ~isnan(ind_T0) && ind_T0>ind_GO
                    try
                        Periodes.lfp_reaction = lfp(ind_GO-1:ind_T0+1);
                    catch GOequals0
                        Periodes.lfp_reaction = lfp(1:ind_T0+2);
                    end
                % Période des Ajustemens Posturaux: Entre T0 et TO (~500ms)    
                    try
                        Periodes.lfp_APA = lfp(ind_T0:ind_TO+1);
                    catch no_TO
                        Periodes.lfp_APA = NaN*ones(1,Fs/2);
                    end
                else
                    Periodes.lfp_reaction = NaN*ones(1,Fs/2);
                    Periodes.lfp_APA = NaN*ones(1,Fs/2);
                end
                
                % Période d'Execution: Entre TO et FC1 (~500ms)
                if ~isnan(ind_FC1) && ind_FC1>ind_TO
                    try
                        Periodes.lfp_exec = lfp(ind_TO:ind_FC1+1);
                    catch no_FC1
                        Periodes.lfp_exec = NaN*ones(1,Fs/2);
                    end
                else
                    Periodes.lfp_exec = NaN*ones(1,Fs/2);
                end
                
                Ts = fieldnames(Periodes);
                
                for p = 1:length(Ts)
                    lfp_periode = Periodes.(Ts{p});
                    try
                        [P(i_check,:,c,p) F] = mtspectrumc(lfp_periode,parms); 
                        % P : variable contenant les puissances par essai(dim1) puis fréquence (dim2) puis contact (dim3) puis période (dim4)
                    catch err_size % Taille des vecteurs fréquentiels différents entre essais/période, du coup on harmonise les dimensions par interpolation
                        if ~isempty(lfp_periode)
                            [Pp Ff] = mtspectrumc(lfp_periode,parms);
                            P(i_check,:,c,p) = interp1(Ff,Pp,F);
                        else
                            P(i_check,:,c,p) = NaN*ones(1,size(P,2));
                        end
                    end
                end               
            end
        end
    end
    
    % On remplace les colonnes/lignes de '0' (mauvais contact/essai) par NaN
    P(P==0)=NaN;  
    
    % Si comparaison on détermine les légendes
    if comparaison
        CI_tags = extract_tags(file_CI(1:end-4));
        CI_tags = [CI_tags{end-2} '-' CI_tags{end-1} '-' CI_tags{end}];
        
        tags = extract_tags(Subject_data.ID);
        current_tags = [cote '-' tags{end-2} '-' tags{end-1}];
    end
        
    %Affichage (fenêtre de 2 ligne (moyennes G/D) et 4 colonnes(Périodes)
    f=figure('Name',['PSD_' Subject_data.ID]);
    Periodes = {'Repos' 'Réaction' 'APA' 'Exécution'};
    plotype = 'l'; % ou 'n' pour affichage linéaire du spectre
    for p=1:size(P,4)
        % Côté D
        subplot(2,size(P,4),p,'Parent',f);
    try
        % Affichage du corridor moyen inter-essais, du signal moyen entre les bon contacts du même côté
        plot_vector_corr(nanmean(P(:,:,1:N_lfp/2,p),3),F,plotype,1,'b');
        minD = min(min(nanmean(nanmean(P(:,:,1:N_lfp/2,:),1),3))); maxD = max(max(nanmean(nanmean(P(:,:,1:N_lfp/2,:),1),3)));
    catch only_2_good_Rcontacts
        plot_vector_corr(nanmean(P(:,:,1:end,p),3),F,plotype,1,'b');
        minD = min(min(nanmean(nanmean(P(:,:,1:end,:),1),3))); maxD = max(max(nanmean(nanmean(P(:,:,1:end,:),1),3)));
    end
    if isempty(nanmean(P(:,:,1:end,p),3))
        text(.5,.5,{' Dipôles' 'hors du STND'},...
                'FontSize',10,'HorizontalAlignment','center');
    end
        if comparaison
            hold on
            try
                plot_vector_corr(nanmean(CI.P(:,:,1:N_lfp/2,p),3),F,plotype,1,'r');
                minD_ci = min(min(nanmean(nanmean(CI.P(:,:,1:N_lfp/2,:),1),3))); maxD_ci = max(max(nanmean(nanmean(CI.P(:,:,1:N_lfp/2,:),1),3)));
            catch only_2_good_Rcontacts
                plot_vector_corr(nanmean(CI.P(:,:,1:end,p),3),F,plotype,1,'r');
                minD_ci = min(min(nanmean(nanmean(CI.P(:,:,1:end,:),1),3))); maxD_ci = max(max(nanmean(nanmean(CI.P(:,:,1:end,:),1),3)));
            end
            legend(current_tags,'',CI_tags);
        else
            minD_ci=[]; maxD_ci=[];
        end
        
        grid
        set(gca,'ylim',10*log10([min([minD minD_ci])  max([maxD maxD_ci])]));
        title([Periodes{p} '-STND'],'FontSize',12);
        
        % Côté G
        subplot(2,size(P,4),p+size(P,4),'Parent',f);
        try
            plot_vector_corr(nanmean(P(:,:,1+N_lfp/2:end,p),3),F,plotype,1,'b');
            minG = min(min(nanmean(nanmean(P(:,:,1+N_lfp/2:end,:),1),3))); maxG = max(max(nanmean(nanmean(P(:,:,1+N_lfp/2:end,:),1),3)));
        catch no_good_Lcontacts
            text(.5,.5,{' Dipôles' 'hors du STNG'},...
                'FontSize',10,'HorizontalAlignment','center');
        end
        if comparaison
            hold on
            try
                plot_vector_corr(nanmean(CI.P(:,:,1+N_lfp/2:end,p),3),F,plotype,1,'r');
                minG_ci = min(min(nanmean(nanmean(CI.P(:,:,1+N_lfp/2:end,:),1),3))); maxG_ci = max(max(nanmean(nanmean(CI.P(:,:,1+N_lfp/2:end,:),1),3)));
            catch no_good_Lcontacts_CI
            end
            legend(current_tags,'',CI_tags);
        else
            minG_ci=[]; maxG_ci=[];
        end
        
        grid
        set(gca,'ylim',10*log10([min([minG minG_ci])  max([maxG maxG_ci])]));
        title([Periodes{p} '-STNG'],'FontSize',12);
    end
    
    button = questdlg('Sauvegarder l''image de l''analyse?','Analyse Spectrale','Oui','Non','Non');
    if strcmp(button,'Oui')
        path = uigetdir(cd,'Choix du dossier pour le stockage des images');
        tags = extract_tags(Subject_data.ID);
        file_to_print = ['PSD_' tags{1} '_' cote '_' tags{2} '_' tags{3}];
        eval(['save ' [path '\' file_to_print] ' F P' ]);
        
        if normalisation
            file_to_print = [file_to_print '_N'];
        end
        
        if comparaison
            CI_tags = extract_tags(file_CI(1:end-4));
            file_to_print = [file_to_print '_VS_' CI_tags{end-2} CI_tags{end-1} '_' CI_tags{end}];
        end
        
        print(f,'-djpeg','-r300',[path '\' file_to_print]);
    end 
    
catch ERR
    disp('Arrêt calcul DSP');
end

function Markerslfp_Callback(hObject, eventdata, handles)
%% Affichage des marqueurs de l'acquisition courante/sélectionnée
global h_01D h_01G h_marks_TR_lfp h_marks_T0_lfp h_marks_HO_lfp h_marks_TO_lfp h_marks_FC1_lfp h_marks_FO2_lfp h_marks_FC2_lfp h_marks_Onset_TA acq_choisie Sujet Activation_EMG h_marks_FOG h_FOG_txt h_marks_FOGe h_FOGe_txt
% hObject    handle to Markers (see GCBO)

%Nettoyage des axes d'abord (??Laisser si Multiplot On??)
efface_marqueur_test(h_marks_TR_lfp);
efface_marqueur_test(h_marks_T0_lfp);
efface_marqueur_test(h_marks_HO_lfp);
efface_marqueur_test(h_marks_TO_lfp);
efface_marqueur_test(h_marks_FC1_lfp);
efface_marqueur_test(h_marks_FO2_lfp);
efface_marqueur_test(h_marks_FC2_lfp);

efface_marqueur_test(h_marks_Onset_TA);
efface_marqueur_test(h_marks_FOG);
efface_marqueur_test(h_FOG_txt);
efface_marqueur_test(h_marks_FOGe);
efface_marqueur_test(h_FOGe_txt);

%Actualisation des marqueurs
h_marks_TR_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.TR,'*-k');
h_marks_T0_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.T0,'-r');
h_marks_HO_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.HO,'-k');
h_marks_TO_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.TO,'-b');
h_marks_FC1_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.FC1,'-m');
h_marks_FO2_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.FO2,'-g');
h_marks_FC2_lfp = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.FC2,'-c');
try
    Onset_EMG_TA = min([Activation_EMG.(acq_choisie).RTA(1,1) Activation_EMG.(acq_choisie).LTA(1,1)]); %Debut inhibition TA
    h_marks_Onset_TA = affiche_marqueurs(Onset_EMG_TA,'*-r');
catch errta
    disp('Activation TA non identifiée');
end

if isfield(Sujet.(acq_choisie).tMarkers,'FOG')
    for i=1:2:length(Sujet.(acq_choisie).tMarkers.FOG)-1 % FOG_start
        h_marks_FOG = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.FOG(i),'--k');
        h_FOG_txt = text(Sujet.(acq_choisie).tMarkers.FOG(i),2,'FOG',...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','left',...
            'FontSize',10,'FontWeight','bold',...
            'Parent',h_01G);
        h_FOG_txt = text(Sujet.(acq_choisie).tMarkers.FOG(i),2,'FOG',...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','left',...
            'FontSize',10,'FontWeight','bold',...
            'Parent',h_01D);
    end
    for i=2:2:length(Sujet.(acq_choisie).tMarkers.FOG) % FOG_end
        h_marks_FOGe = affiche_marqueurs(Sujet.(acq_choisie).tMarkers.FOG(i),'--r');
        h_FOGe_txt = text(Sujet.(acq_choisie).tMarkers.FOG(i),2,'end',...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','right',...
            'FontSize',10,'FontWeight','bold',...
            'Color','r',...
            'Parent',h_01G);
        h_FOGe_txt = text(Sujet.(acq_choisie).tMarkers.FOG(i),2,'end',...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','right',...
            'FontSize',10,'FontWeight','bold',...
            'Color','r',...
            'Parent',h_01D);
    end
 end

function Tag_lfp(hObject, eventdata, handles)
%% Tagger les contacts (bon ou mauvais)
global list_lfp LFP_tri LFP

button = questdlg('Exclure ou Réinclure?','Tri-Contact','Exclure','Réinclure','Exclure');
if strcmp(button,'Exclure')
    exclude = true;
else
    exclude = false;
end

%Récupération de(s) l'acquisition(s) séléctionnée(s)
button = questdlg('Appliquer à plusieurs Acquisition?','Tri-Contact','Oui','Non','Non');
if strcmp(button,'Non')
    contents = cellstr(get(list_lfp,'String'));
    acq_choisie = {contents{get(list_lfp,'Value')}};
else
    contents = fieldnames(LFP);
    [acqs,v] = listdlg('PromptString',{'Bad Contacts','Choix des essais ou exclure/réinclure le contact'},...
    'ListSize',[300 300],...
    'ListString',contents);
    acq_choisie = contents(acqs);
end

try
    lfps = fieldnames(LFP.(acq_choisie{1}));
    [bads,v] = listdlg('PromptString',{'Tri Contact','Contacts à exclure/réinclure?'},...
        'ListSize',[100 100],...
        'ListString',lfps);
catch No_select
    bads = 0;
end

for a = 1:length(acq_choisie)
    LFP_tri.(acq_choisie{a}).Bad_trial=0;
    for c = 1:length(lfps)
        if sum(bads==c)>=1 && exclude
            LFP_tri.(acq_choisie{a}).(lfps{c}) = 1;
        else
            LFP_tri.(acq_choisie{a}).(lfps{c}) = 0;
        end
    end
end

function Flag_lfp(hObject, eventdata, handles)
%% Tagger l'essai (bon ou mauvais)
global list_lfp LFP_tri LFP lfp_modif

%Récupération de l'acquisition séléctionnée
contents = cellstr(get(list_lfp,'String'));
acq_choisie = contents{get(list_lfp,'Value')};

bool = get(findobj('tag','Flags_lfp'),'Value');
if isfield(LFP,acq_choisie)
    LFP_tri.(acq_choisie).Bad_trial = bool;
    if bool
        set(lfp_modif,'Enable','Off');
    else
        set(lfp_modif,'Enable','On');
    end
end

function Markers_PE_callback(M)
%% Fonction qui va afficher les evts en % de cycle pour les PE calculés en % de cycle
global h_01D h_01G h_marks_T0_lfp h_marks_TO_lfp h_marks_FC1_lfp h_marks_FO2_lfp h_marks_FC2_lfp h_marks_Onset_TA
% hObject    handle to Markers (see GCBO)

%Nettoyage des axes d'abord (??Laisser si Multiplot On??)
efface_marqueur_test(h_marks_T0_lfp);;
efface_marqueur_test(h_marks_TO_lfp);
efface_marqueur_test(h_marks_FC1_lfp);
efface_marqueur_test(h_marks_FO2_lfp);
efface_marqueur_test(h_marks_FC2_lfp);

efface_marqueur_test(h_marks_Onset_TA);

%Actualisation des marqueurs
for m = 1:length(M.noms)
    switch M.noms{m}
        case 'T0'
            h_marks_T0_lfp = affiche_marqueurs(M.per(m),'-r');
        case 'TO'
            h_marks_TO_lfp = affiche_marqueurs(M.per(m),'-b');
        case 'FC1'
            h_marks_FC1_lfp = affiche_marqueurs(M.per(m),'-m');
        case 'FO2'
            h_marks_FO2_lfp = affiche_marqueurs(M.per(m),'-g');
        case 'FC2'            
            h_marks_FC2_lfp = affiche_marqueurs(M.per(m),'-c');
        case 'Onset_TA'
            h_marks_Onset_TA = affiche_marqueurs(M.per(m),'*-r');
    end
    if ~strcmp(M.noms{m},'HO')
        text(M.per(m),1,M.noms{m},...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','Left',...
            'FontSize',10,...
            'Parent',h_01D);
        text(M.per(m),1,M.noms{m},...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','Left',...
            'FontSize',10,...
            'Parent',h_01G);
    end
end

function Create_figure(selection,destination)
%% Fonction qui va créer une figure a part pour le graphe selectionné (selection)
% Sauvegarde dans le dossier 'destination'
global PE PerMarkers_PE LFP_base

if isempty(destination)
    destination = uigetdir(cd,'Choix du dossier pour le stockage des images');
    listes_Moy = fieldnames(PE);
    %Sélections de l'utilisateur
    [i,v] = listdlg('PromptString',{'Choix du/des moyennes uniquement!'},...
        'ListSize',[300 300],...
        'ListString',listes_Moy,'SelectionMode','Multiple');

    selection = listes_Moy(i);
end
Fs = LFP_base.Fech;

if ischar(selection)
    f= selection;
    clear selection
    selection{1} = f;
end

for p = 1:length(selection)

    lfps = fieldnames(PE.(selection{p}));
    window_width = length(PE.(selection{p}).(lfps{1}))/Fs;
    tags = extract_tags(selection{p});
    
    % Extraction du vecteur temps
    if sum(compare_liste({'Moy'},tags)) || sum(compare_liste({'PE'},tags)) || sum(compare_liste({'CPA'},tags))
        t = (-PerMarkers_PE.(selection{p}).per(1):1/Fs:PerMarkers_PE.(selection{p}).per(2));
    elseif sum(compare_liste({'PEcycle'},tags))
        cycle = length(PE.(selection{p}).(lfps{1}));
        step = 100/(cycle-1);
        t = (0:step:100);
    else
        t = (0:1/Fs:window_width-1/Fs)*1e3;
    end
    
    % Extraction des données
    Data_to_plot = PE.(selection{p});
    
    if length(lfps)>6
        lfps(1:length(lfps)-6)=[];
    end
    smooth = 10;
    
    % Création de la figure
    pic = figure;
    b_p = uiextras.VBox( 'Parent', pic);
    
    G01 = axes( 'Parent', b_p,'ActivePositionProperty', 'Position','xticklabel',[]);
    G12 = axes( 'Parent', b_p,'ActivePositionProperty', 'Position','xticklabel',[]);
    G23 = axes( 'Parent', b_p,'ActivePositionProperty', 'Position','xticklabel',[]);
    D01 = axes( 'Parent', b_p,'ActivePositionProperty', 'Position','xticklabel',[]);
    D12 = axes( 'Parent', b_p,'ActivePositionProperty', 'Position','xticklabel',[]);
    D23 = axes( 'Parent', b_p,'ActivePositionProperty', 'Position');
    
    stdshade(Data_to_plot.(lfps{1}),0.25,'b',t,smooth,G01,1.25,1); ylabel(G01,lfps{1}); axis(G01,'tight');
    stdshade(Data_to_plot.(lfps{2}),0.25,'b',t,smooth,G12,1.25,1); ylabel(G12,lfps{2}); axis(G12,'tight');
    stdshade(Data_to_plot.(lfps{3}),0.25,'b',t,smooth,G23,1.25,1); ylabel(G23,lfps{3}); axis(G23,'tight');
    
    stdshade(Data_to_plot.(lfps{4}),0.25,'b',t,smooth,D01,1.25,1); ylabel(D01,lfps{4}); axis(D01,'tight');
    stdshade(Data_to_plot.(lfps{5}),0.25,'b',t,smooth,D12,1.25,1); ylabel(D12,lfps{5}); axis(D12,'tight');
    stdshade(Data_to_plot.(lfps{6}),0.25,'b',t,smooth,D23,1.25,1); ylabel(D23,lfps{6}); axis(D23,'tight');
    
    if sum(compare_liste({'Moy'},tags)) || sum(compare_liste({'CPA'},tags))
        afficheX_v2(0,'k',G01); afficheX_v2(0,'k',D01);
        afficheX_v2(0,'k',G12); afficheX_v2(0,'k',D12);
        afficheX_v2(0,'k',G23); afficheX_v2(0,'k',D23);
        
        text(0,max(max(Data_to_plot.(lfps{1})))/3,PerMarkers_PE.(selection{p}).noms,...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','Left',...
            'FontSize',12,'FontWeight','bold',...
            'Parent',G01);
        xlabel(D23,'Temps (ms)');
    elseif sum(compare_liste({'PEcycle'},tags))
        xlabel(D23,'Pourcentage de cycle (%)');
        try
            Markers_PE_callback(PerMarkers_PE.(selection{p}));
            for m=1:length(PerMarkers_PE.(selection{p}).noms)
                if ~strcmp('HO',PerMarkers_PE.(selection{p}).noms(m))
                    text(PerMarkers_PE.(selection{p}).per(m),max(max(Data_to_plot.(lfps{1})))/3,PerMarkers_PE.(selection{p}).noms(m),...
                        'VerticalAlignment','middle',...
                        'HorizontalAlignment','Left',...
                        'FontSize',11,'FontWeight','bold',...
                        'Parent',G01);
                end
            end
        catch NO_interEvt
            disp('Pas d''Evts intermédiaires');
        end
    end
    
    % Sauvegarde Image
    print(pic,'-djpeg','-r300',[destination '\' selection{p}]);
end