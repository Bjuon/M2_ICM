function lfp  = affiche_lfps(listes_acqs)
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
uicontrol( 'Style', 'pushbutton', 'Parent', b3, 'String', 'Calcul PE cycle','Callback',@Calcul_PE,'Enable','On');
uicontrol( 'Style', 'pushbutton', 'Parent', b3, 'String', 'Efface Moyenne/PE','Callback',@Delete_PE,'tag','Del_PE');
uicontrol( 'Style', 'pushbutton', 'Parent', b3, 'String', 'Puissance-Fréquence','Callback',@Spectre_lfp);
uicontrol( 'Style', 'pushbutton', 'Parent', b3, 'String', 'Temps-Fréquence','Callback',@Time_Freq,'Enable','Off','tag','Time_frq');

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
else
    set(findobj('tag','Del_PE'),'Enable','Off');
end

set(filtre,'Value',1);
set(multi_lfp,'Value',0);

function listLFP_Callback(hObj,event,handles)
%% Affichage LFPs
global h_01G h_12G h_23G h_01D h_12D h_23D list_lfp acq_choisie Sujet LFP LFP_base b4 b5 Corridors_LFP PE h_stim filtre LFP_tri lfp_modif multi_lfp
        
%Récupération de l'acquisition séléctionnée
contents = cellstr(get(list_lfp,'String'));
acq_choisie = contents{get(list_lfp,'Value')};
Fs = 500;
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
    
%     if length(t)<length(EMG.(acq_choisie).val) %% Cas ou EMG et données PF non échantillonnés à la même fréquence
%         Fs = EMG.(acq_choisie).Fech;
%         t = t(1):1/Fs:t(end);
%     end
        
     if ~isfield(Corridors_LFP,acq_choisie) && isfield(LFP,acq_choisie)
         lfps = fieldnames(LFP.(acq_choisie));
         t = Sujet.(acq_choisie).t;
         if length(lfps)>6
             lfps(1:length(lfps)-6)=[];
         end
         
         if get(filtre,'Value') %% Si application du filtre 'ON' on filtre
             LFPs_filtered = TraitementLFPs(LFP.(acq_choisie),Fs); %%
%              LFPs_filtered = TraitementLFPs(LFP_base.(acq_choisie),Fs); %%
         else
             LFPs_filtered = extract_lfps_from_struct(LFP.(acq_choisie)); %%
%              LFPs_filtered = extract_lfps_from_struct(LFP_base.(acq_choisie)); %%
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
             if sum(compare_liste({'Moy'},tags)) || sum(compare_liste({'PE'},tags)) || sum(compare_liste({'CPA'},tags))
                 t = (-window_width/2+0.5/Fs:1/Fs:window_width/2-0.5/Fs)*1e3;
             elseif sum(compare_liste({'PEcycle'},tags))
                 t = (0:100);
             else
                 t = (0:1/Fs:window_width-1/Fs)*1e3;
             end
             Data_to_plot = PE.(acq_choisie);    
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
         xlabel(h_23G,'Temps (ms)');
         
         stdshade(Data_to_plot.(lfps{4}),0.25,'b',t,smooth,h_01D,1.25,1); ylabel(h_01D,lfps{4}); axis(h_01D,'tight');
         stdshade(Data_to_plot.(lfps{5}),0.25,'b',t,smooth,h_12D,1.25,1); ylabel(h_12D,lfps{5}); axis(h_12D,'tight');  
         stdshade(Data_to_plot.(lfps{6}),0.25,'b',t,smooth,h_23D,1.25,1); ylabel(h_23D,lfps{6}); axis(h_23D,'tight');
         xlabel(h_23D,'Temps (ms)');
         
         efface_marqueur_test(h_stim);
         h_stim = affiche_marqueurs(0,'-k');
     end
     
catch ERR
    waitfor(warndlg('Fermer et recharger la fenêtre de visu des LFPs/PE!','Redraw LFPs'));
end

function Calcul_moyenne(hObj,eventEMG,handles)
%% Moyenner autour d'un évènement
global Sujet Subject_data LFP LFP_base list_lfp PE PE_base LFP_tri

try
    %Choix utilisateur des essais 
    acquisitions = fieldnames(LFP);
    
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
    Fs = Sujet.(acquisitions{1}).Fech;
    
    %Demande de la taille de fenêtre en millisecondes
    width = str2double(cell2mat(inputdlg('Entrez la taille de la fenêtre (ms)','Moyennage')));
    window_width = round(width*Fs/1e3);
    
    button = questdlg('Normaliser par 1STD?','Moyennage','Oui','Non','Non');
    if strcmp(button,'Oui')
        normalisation=1;
    else
        normalisation=0;
    end
    
    %Initialisation
    tags = extract_tags(Subject_data.ID);
    try
        session = cell2mat(inputdlg('Entrez le nom de la session','Stockage Moyenne',1,{[tags{1} '_' tags{2} tags{3} '_' tags{4} '_' tags{5}]}));
    catch Err
        session = Subject_data.ID;
    end
    N_acq = length(acqs);
    contacts = fieldnames(LFP.(acquisitions{1}));
    N_lfp = length(contacts);
    
    FC=0;
    if strcmp(Evts,'FC1') || strcmp(Evts,'FC2')
        buttonFC = questdlg('Moyenner tous les FC?','Moyennage FC','Oui','Non','Non');
        if strcmp(buttonFC,'Oui')
            FC=1;
            Evts=['FC1';'FC2'];
            save_PE = [session '_Moy_FC_' num2str(width)];
        else
            save_PE = [session '_Moy_' Evts '_' num2str(width)];
        end
    end
        
    for c=1:N_lfp
        Data_PE = NaN*ones(N_acq,window_width+1);
        Data_PE_base = NaN*ones(N_acq,round(Fs/2)); % On stocke le signal entre -1 et -0.5sec avant T0
        
        if FC
            Data_PE = NaN*ones(2*N_acq,window_width+1);
            Data_PE_base = NaN*ones(2*N_acq,round(Fs/2)); % On stocke le signal entre -1 et -0.5sec avant T0
        end
        
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
                try
                    for fc=1:size(Evts,1)
                        Evt = Evts(fc,:);
                        start_t = Sujet.(acquisitions{acqs(i)}).tMarkers.(Evt) - (width*1e-3)/2;
                        start_ind = length(t) - find(flipdim(t,1)<=start_t,1,'first');
                        stop_t = Sujet.(acquisitions{acqs(i)}).tMarkers.(Evt) + (width*1e-3)/2;
                        stop_ind = find(t>=stop_t,1,'first')-1;
                        
                        start_t_pre = Sujet.(acquisitions{acqs(i)}).tMarkers.T0 - 1;
                        start_ind_pre = length(t) - find(flipdim(t,1)<=start_t_pre,1,'first');
                        stop_t_pre = Sujet.(acquisitions{acqs(i)}).tMarkers.T0 - 0.5;
                        stop_ind_pre = length(t) - find(flipdim(t,1)<=stop_t_pre,1,'first')-1;
                        
                        current_lfp = TraitementLFPs(LFP.(acquisitions{acqs(i)}).(contacts{c}),Fs);
                        current_lfp_pre = TraitementLFPs(LFP_base.(acquisitions{acqs(i)}).(contacts{c}),Fs);
                        
                        if isempty(stop_ind)
                            dec_end = round((stop_t - t(end))*Fs);
                            fitnan = NaN*ones(1,dec_end);
                            current_lfp = [current_lfp fitnan];
                        end
                                               
                        if isempty(start_ind)
                            dec = round((t(1)-start_t)*Fs);
                            %                     fitnan = NaN*ones(1,dec);
                            fit_pre = current_lfp_pre(end-dec+1:end);
                            Data_PE(i,:) = [fit_pre current_lfp(1:window_width-dec+1)];
                        else
                            Data_PE(i,:) = current_lfp(start_ind:start_ind+window_width);
                        end
                        
                        if isempty(stop_ind_pre)
                            start_ind_pre = length(current_lfp_pre) - floor((t(1) - start_t_pre)*Fs);
                            Data_PE_base(i,:) = current_lfp_pre(start_ind_pre:start_ind_pre+round(Fs/2)-1);
                        elseif isempty(start_ind_pre)
                            start_ind_pre = length(current_lfp_pre) - round((t(1) - start_t_pre)*Fs);
                            try
                                Data_PE_base(i,:) = [current_lfp_pre(start_ind_pre:end) current_lfp(1:stop_ind_pre)];
                            catch size_mismatch
                                Data_PE_base(i,:) = [current_lfp_pre(start_ind_pre-1:end) current_lfp(1:stop_ind_pre)];
                            end
                        else
                            Data_PE_base(i,:) = current_lfp(start_ind_pre:start_ind_pre+round(Fs/2)-1);
                        end
                        
                        %Normalisation (Z-score)
                        if normalisation
                            Data_PE(i,:) = Data_PE(i,:)/nanstd(Data_PE(i,:));
                            %Data_PE_base(i,:) = Data_PE_base/nanstd(Data_PE(i,:));
                        end
                    end
                catch NO_Evt
                    disp(['Pas d''evenement ' Evt ' dans :' acquisitions{acqs(i)}]);
                end
                
            else
                disp(['Exculsion: ' acquisitions{acqs(i)} '_' contacts{c}]);
            end
        end
        
        PE.(save_PE).(contacts{c}) = Data_PE;
        PE_base.(save_PE).(contacts{c}) = Data_PE_base;
    end
    
    %Affichage
    contents = cellstr(get(list_lfp,'String'));
    set(list_lfp,'Value',1);
    set(list_lfp,'String',[contents;save_PE]);
    last = length(contents) + 1;
    set(list_lfp,'Value',last);
    set(findobj('tag','Del_PE'),'Enable','On');
    set(findobj('tag','Time_frq'),'Enable','On');
    listLFP_Callback();
    
catch ERR
    disp('Arrêt moyennage LFP');
end

function Calcul_mrp_cusum(hObj,eventEMG,handles)
%% Calcul des residus cumulés (cusum) des MRPs
global list_lfp PE

try
    listes_Moy = fieldnames(PE);
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
    end
    
    %Affichage
    contents = cellstr(get(list_lfp,'String'));
    set(list_lfp,'Value',1);
    set(list_lfp,'String',[contents;save_PE_cpa]);
    last = length(contents) + add;
    set(list_lfp,'Value',last);
    set(findobj('tag','Del_PE'),'Enable','On');
    set(findobj('tag','Time_frq'),'Enable','On');
    listLFP_Callback();

catch Err_cpa
    disp('Arrêt change-point analysis!');
end

function Calcul_PE(hObj,eventEMG,handles)
%% Calcul d'un PE (en % de cycle d'initation)
global Sujet Subject_data LFP LFP_base list_lfp PE LFP_tri

try
    %Choix utilisateur des essais 
    acquisitions = fieldnames(LFP);
    
    [acqs,v] = listdlg('PromptString',{'Calcul PE','Choix des essais à inclure pour le calcul du PE'},...
    'ListSize',[300 300],...
    'ListString',acquisitions);
    
    Fs = Sujet.(acquisitions{1}).Fech;
    
%     %Taille de fenêtre en millisecondes
%     width = str2double(cell2mat(inputdlg('Entrez la taille de la fenêtre (ms) a prendre avant et après l''instruction','Calcul PE')));
%     window_width = round(width*Fs/1e3);
    
    button = questdlg('Normaliser par 1STD?','Moyennage','Oui','Non','Non');
    if strcmp(button,'Oui')
        normalisation=1;
    else
        normalisation=0;
    end
    
    %Initialisation
    tags = extract_tags(Subject_data.ID);
    try
        session = cell2mat(inputdlg('Entrez le nom de la session','Stockage PE',1,{[tags{1} '_' tags{2} tags{3} '_' tags{4}]}));
    catch Err
        session = Subject_data.ID;
    end
    N_acq = length(acqs);
    contacts = fieldnames(LFP.(acquisitions{1}));
    N_lfp = length(contacts);
    
    for c=1:N_lfp
        Data_PE = NaN*ones(N_acq,101);
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
                current_lfp = TraitementLFPs(LFP.(acquisitions{acqs(i)}).(contacts{c}),Fs);
%                 current_lfp_pre = TraitementLFPs(LFP_base.(acquisitions{acqs(i)}).(contacts{c}),Fs);
                
                %Recuperation de T0 et FC2
                debut = find(Sujet.(acquisitions{acqs(i)}).t >= Sujet.(acquisitions{acqs(i)}).tMarkers.T0,1,'first');
                fin = find(Sujet.(acquisitions{acqs(i)}).t >= Sujet.(acquisitions{acqs(i)}).tMarkers.FC2,1,'first');
                current_data = current_lfp(debut:fin);
                
                %Normalisation (Z-score) et en pourcentage de cycle 
                if normalisation %Z-Score
                    current_data = current_data/nanstd(current_data);
                end
                
                uncycle = (0:(100/(fin-debut)):100)';
                echant = (0:100);
                Data_PE(i,:) = interp1(uncycle,current_data,echant);
            else
                disp(['Exculsion: ' acquisitions{acqs(i)} '_' contacts{c}]);
            end
        end
        save_PE = [session '_PEcycle'];
        PE.(save_PE).(contacts{c}) = Data_PE;
%         PE_base.(save_PE).(contacts{c}) = Data_PE_base;
    end
    
    %Affichage
    contents = cellstr(get(list_lfp,'String'));
    set(list_lfp,'Value',1);
    set(list_lfp,'String',[contents;save_PE]);
    last = length(contents) + 1;
    set(list_lfp,'Value',last);
    set(findobj('tag','Del_PE'),'Enable','On');
    set(findobj('tag','Time_frq'),'Enable','On');
    listLFP_Callback();
    
catch ERR
    disp('Arrêt calcul PE');
end

function Delete_PE(hObj,eventEMG,handles)
%% Retirer un corridor si mauvais
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
%% Anayse temps-fréquence sur les variables MRP déjà calculés
global Sujet PE PE_base

button = questdlg('Sauvegarder les images de l''analyse?','Analyse Temps-Fréquence','Oui','Non','Non');
if strcmp(button,'Oui')
    path = uigetdir(cd,'Choix du dossier pour le stockage des images');
    sauve=1;
else
    sauve=0;
end

try
listes_Moy = fieldnames(PE);
%Sélections de l'utilisateur
[i,v] = listdlg('PromptString',{'Choix du/des moyennes uniquement!'},...
    'ListSize',[300 300],...
    'ListString',listes_Moy,'SelectionMode','Multiple');

selection = listes_Moy(i);
acqs = fieldnames(Sujet);
Fs = Sujet.(acqs{1}).Fech;

%Paramètres de l'analyse
prompt = {'Taille de fenêtre (ms)','Overlapping (%)','Fréquence min (Hz)','Fréquence max (Hz)'};
default_params = {'250','50','0.1','75'};
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
    Pmean_base = [];
    N_contact = length(contacts);
%     f0=figure;
    wb1 = waitbar(0);
    for c = 1:N_contact
        signals_to_process_pre = lfps_to_process_pre.(contacts{c});
        waitbar(c/N_contact,wb1,['Calculating Baseline Spectrogram for: ' contacts{c}]);
        for s = 1:size(signals_to_process_pre,1)
            if ~chronux
                L = length(signals_to_process_pre(s,:));
                NFFT = 2^nextpow2(L);
                setp_f = (Fmax-Fmin)/NFFT;
                vect_F = [Fmin:setp_f:Fmax];
                [S_base(:,:,s,c),F,T,P_base(:,:,s,c)] = spectrogram(signals_to_process_pre(s,:),window_width,overlap_width,vect_F,Fs);
            else
                [P_b,T,F] = mtspecgramc(signals_to_process_pre(s,:),movingwin,parms);
                P_base(:,:,s,c) = P_b';
            end
            
            % Pmean_base(:,s,c) = nanmean(P_base(:,:,s,c),2);
            % F: vecteur des fréquences, T : vecteur temps
            % P: matrice des puissance (dim1: par fréquence; dim2: par temps; dim3: par essai; dim4: par contact)
        end
%         subplot(2,length(contacts)/2,c,'Parent',f0);
%         surf(T,F,10*log10(squeeze(nanmean(P_base(:,:,:,c),3))),'edgecolor','none');
%         title(contacts{c});
    end
    close(wb1);
else
    normalisation=0;
    Pmean_base = NaN;
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
                %             L=length(signals_to_process(s,:));
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
        
        subplot(2,length(contacts)/2,c);
        
        if ~normalisation
            surf(T,F,10*log10(abs(squeeze(nanmean(P(:,:,:,c),3)))),'edgecolor','none');
            title(contacts{c});
        else
            surf(T,F,10*log10(abs(squeeze(nanmean(P_norm(:,:,:,c),3)))),'edgecolor','none');
            title([contacts{c} ' - Normalized']);
        end
        
        axis tight;
        view(0,90);
        xlabel('Time (Seconds)'); ylabel('Hz');
    end
    
    if sauve
        if normalisation
            file_to_print = [file_to_print '_Normalized'];
        end
        print(f,'-djpeg','-r300',[path '\T-Freq_' file_to_print]);
        eval(['save ' [path '\TFreq_' file_to_print] ' T F P P_norm Pmean_base']); 
    end
    close(f)
    
    col1 = find(vect_F>=FMin,1,'first') - 1;
    col2 = find(vect_F>=FMax,1,'first') - 1;
    
    f1=figure;
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
%         plot(T,vect_P); axis tight
        xlabel('Time (Seconds)'); ylabel(['Puissance Moyenne(dB) - bande:' num2str(FMin) '-' num2str(FMax) ' Hz']);
        afficheX_v2(median(T));
        text(median(T),median(10*log10(vect_P)),Evt,...
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
    close(f1);
end
close(wb);
catch ERR_TF
    errordlg('Arrêt analyse temps-fréquence');
end

function Spectre_lfp(hObj,eventEMG,handles)
%% Calcul du spectre de puissance
global Sujet Subject_data LFP LFP_base LFP_tri

try
    %Choix utilisateur des essais 
    acquisitions = fieldnames(LFP);
    
    [acqs,v] = listdlg('PromptString',{'Calcul TF','Choix des essais à inclure'},...
    'ListSize',[300 300],...
    'ListString',acquisitions);
    
    button = questdlg('Normaliser par 1STD?','Moyennage','Oui','Non','Non');
    if strcmp(button,'Oui')
        normalisation=1;
    else
        normalisation=0;
    end
    
    N_acq = length(acqs);
    contacts = fieldnames(LFP.(acquisitions{1}));
    
    if length(contacts)>6 %% (pour évitre d'afficher les contacts inutiles (sachant que nous avons 6)
        contacts(1:length(contacts)-6)=[];
    end
    
    N_lfp = length(contacts);
    
    f=figure('Name',Subject_data.ID);
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
            else
                bad_contact=1;
            end
            
            if ~bad_acq && ~bad_contact
                i_check = i_check+1;
                Fs = Sujet.(acquisitions{i}).Fech;
                T0 = Sujet.(acquisitions{i}).tMarkers.T0;
                ind_T0 = find(Sujet.(acquisitions{i}).t>=T0,1,'first');
                lfp = TraitementLFPs(LFP.(acquisitions{acqs(i)}).(contacts{c}),Fs);
                lfp_pre = TraitementLFPs(LFP_base.(acquisitions{acqs(i)}).(contacts{c}),Fs);
                
                %Conditionnement
                current_lfp = lfp(ind_T0:end); % Après T0
                dim = length(current_lfp);
                current_lfp_pre = [lfp_pre lfp(1:ind_T0-1)];
                current_lfp_pre = current_lfp_pre(end-dim:end); % Avant T0
                
                %Normalisation
                if normalisation
                    z = nanstd([current_lfp_pre current_lfp]);
                    current_lfp = current_lfp/z;
                    current_lfp_pre = current_lfp_pre/z;
                end
                
                try
                    %                 [P(i,:,c) F] =  pwelch(current_lfp,[],[],[],Fs);
                    [P(i_check,:,c) F] = psd(current_lfp,Fs,Fs, hanning(Fs), Fs/2, 'mean'); % Tout l'essai
%                     [P_T0(i_check,:,c) F_T0] = psd(current_lfp(1:ind_T0),Fs,Fs, hanning(Fs), Fs/2, 'mean'); % Entre l'instruction et T0
                    [P_base(i_check,:,c) F_base] = psd(current_lfp_pre,Fs,Fs, hanning(Fs), Fs/2, 'mean'); % Avant T0
                catch ERr
                    %                 [Pp Ff]=pwelch(current_lfp,[],[],[],Fs);
                    [Pp Ff] = psd(current_lfp,Fs,Fs, hanning(Fs), Fs/2, 'mean'); % Tout l'essai
%                     [Pp_T0 Ff_T0] = psd(current_lfp(1:ind_T0),Fs,Fs, hanning(Fs), Fs/2, 'mean'); %Entre l'instruction et T0
                    [Pp_base Ff_base] = psd(current_lfp_pre,Fs,Fs, hanning(Fs), Fs/2, 'mean'); % Avant T0
                    
                    P(i_check,:,c) = interp1(Ff,Pp,F);
%                     P_T0(i_check,:,c) = interp1(Ff_T0,Pp_T0,F_T0);
                    P_base(i_check,:,c) = interp1(Ff_base,Pp_base,F_base);
                end
            end
        end
        
        %Affichage
        subplot(2,N_lfp/2,c);
%         plot(F,10*log10(mean(P(:,:,c),1)));
        area(F_base(1:80),mean(P_base(:,1:80,c),1),'Linewidth',1.2,'FaceColor','r','Linestyle','--'); hold on
%         area(F_T0(1:80),mean(P_T0(:,1:80,c),1),'Linewidth',1.5,'FaceColor','g','Linestyle','-.'); hold on
        area(F(1:80),mean(P(:,1:80,c),1),'Linewidth',2,'FaceColor','b'); 
        set(gca,'ylim',[0 max([mean(P(:,1:80,c)) mean(P_base(:,1:80,c))])]); alpha 0.85 % mean(P_T0(:,1:80,c))/2
        grid
        title(contacts{c});
        ylabel('DSP Moyenne (V²/Hz)'); xlabel('Frequence Hz');
%         legend('Before Instruction','Before T0','Whole trial');
        legend('Before Movement','After Movement');
    end
    
    button = questdlg('Sauvegarder l''image de l''analyse?','Analyse Spectrale','Oui','Non','Non');
    if strcmp(button,'Oui')
        path = uigetdir(cd,'Choix du dossier pour le stockage des images');
        tags = extract_tags(acquisitions{acqs(i)});
        file_to_print = ['PSD_' tags{1} tags{3} '_' tags{4}];
        if normalisation
            file_to_print = [file_to_print '_N'];
        end
        print(f,'-djpeg','-r300',[path '\' file_to_print]);
%         eval(['save ' [path '\' file_to_print] ' F F_T0 F_base P P_T0 P_base']);
        eval(['save ' [path '\' file_to_print] ' F F_base P P_base' ]);
    end  
    
catch ERR
    disp('Arrêt calcul DSP');
end

function Markerslfp_Callback(hObject, eventdata, handles)
%% Affichage des marqueurs de l'acquisition courante/sélectionnée
global h_marks_T0_lfp h_marks_HO_lfp h_marks_TO_lfp h_marks_FC1_lfp h_marks_FO2_lfp h_marks_FC2_lfp h_marks_Onset_TA acq_choisie Sujet Activation_EMG
% hObject    handle to Markers (see GCBO)

%Nettoyage des axes d'abord (??Laisser si Multiplot On??)
efface_marqueur_test(h_marks_T0_lfp);
efface_marqueur_test(h_marks_HO_lfp);
efface_marqueur_test(h_marks_TO_lfp);
efface_marqueur_test(h_marks_FC1_lfp);
efface_marqueur_test(h_marks_FO2_lfp);
efface_marqueur_test(h_marks_FC2_lfp);

efface_marqueur_test(h_marks_Onset_TA);

%Actualisation des marqueurs
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

function Tag_lfp(hObject, eventdata, handles)
%% Tagger les contacts (bon ou mauvais)
global list_lfp LFP_tri LFP

%Récupération de l'acquisition séléctionnée
contents = cellstr(get(list_lfp,'String'));
acq_choisie = contents{get(list_lfp,'Value')};

try
lfps = fieldnames(LFP.(acq_choisie));
LFP_tri.(acq_choisie).Bad_trial = 0;
[bads,v] = listdlg('PromptString',{'Tri Contact','Contacts à exclure'},...
    'ListSize',[100 100],...
    'ListString',lfps);
catch No_select
    bads = 0;
end

for c = 1:length(lfps)
    if find(bads==c)
        LFP_tri.(acq_choisie).(lfps{c}) = 1;
    else
        LFP_tri.(acq_choisie).(lfps{c}) = 0;
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