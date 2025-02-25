function plot_LabTools_General(varargin)

% Création d'une figure ou utilisation de la figure existante
h = figure('Name','plot Segment APA');
% on définit la position de la fenêtre par défaut
if min(min(get(groot, 'MonitorPositions'))) < 0
    set(h,'Units','normalized','Position',[-0.98 0.01 0.95 0.9]);
else
    set(h,'Units','normalized','Position',[0.02 0.01 0.95 0.9]);
end

% A l'ouverture, on exécute loadSeg si pas de Seg chargé dans le workspace
if size(varargin,1) == 0
    loadSeg();
else
    Seg = varargin{1};
end

% création de la liste des essais présents dans Seg
acq_list = linq(Seg).select(@(x) x.info('trial').trial).toList;
c = uicontrol(h,'Style','listbox','Units','normalized','Position',[0.7 0.8 0.25 0.1],...
    'String',acq_list,'Callback', @list_acq_Callback);

% Affichage de la session en cours de traitement
Session_all = [Seg(1).info('trial').patient ' ' Seg(1).info('trial').session ' ' Seg(1).info('trial').medcondition ' ' Seg(1).info('trial').speedcondition];
Session_All = uicontrol(h,'Style','Text','Units','normalized','Position',[0.84 0.97 0.15 0.02],'String',Session_all,'FontSize',14);

% création de 2 boites pour déterminer xmin et  xmax
XminBox = uicontrol(h,'Style','edit','Units','normalized','Position',[0.7 0.95 0.05 0.02],'Callback', @Xmin_Callback);
XmaxBox = uicontrol(h,'Style','edit','Units','normalized','Position',[0.77 0.95 0.05 0.02],'Callback', @Xmax_Callback);

XminTxt = uicontrol(h,'Style','Text','Units','normalized','Position',[0.7 0.97 0.05 0.02],'String','Xmin en sec');
XmaxTxt = uicontrol(h,'Style','Text','Units','normalized','Position',[0.77 0.97 0.05 0.02],'String','Xmax en sec');

% création d'un bouton pour actualiser le calcul des APA
Calc_APA = uicontrol(h,'Style','pushbutton', 'String', 'Calc_APA','Units','normalized',...
    'Position',[0.7 0.7 0.05 0.02],'Callback', @act_Calc_APA);

% création du tableau pour mettre les résultats des APA
Res_APA = uicontrol(h,'Style','Text','Units','normalized',...
    'Position',[0.7 0.1 0.25 0.60],'Tag','Res_APA');

% création d'un bouton pour afficher info de Stim
Screen_Infos = uicontrol(h,'Style','checkbox', 'Units','normalized',...
    'Position',[0.68 0.75 0.1 0.02],'Tag','Screen_Infos','Callback', @Disp_Screen_Infos,'String','Display Screen Infos');

% création d'un bouton pour supprimer l'essai courant
Delete_Trial = uicontrol(h,'Style','pushbutton', 'Units','normalized',...
    'Position',[0.88 0.75 0.1 0.02],'Tag','Delete_trial','Callback', @Delete_trial,'String','Delete Trial');

% création du bouton pour la sauvegarde
Export_and_save = uicontrol(h,'Style','pushbutton', 'String', 'Save Segment','Units','normalized',...
    'FontSize',12,'Position',[0.9 0.1 0.07 0.04],'Callback', @export_and_save);

% création du bouton pour 'export des Events vers les c3d
export_evts = uicontrol(h,'Style','pushbutton', 'String', 'Export -> c3d','Units','normalized',...
    'FontSize',12,'Position',[0.7 0.1 0.07 0.04],'Callback', @export_evts_c3d);

sb = plot_LabTools(Seg);

    function sb = plot_LabTools(Seg,varargin)
        h = gcf;
        % par défaut trace le 1er trial
        if isempty(varargin)
            i_trial = 1;
        else
            i_trial = varargin{1};
            sb = varargin{2};
            for i_sb = sb;
                i_sb.Children.delete;
            end
        end
        
        wid = 0.6 ; hei = 0.15;
        Position_subplot = [0.05 0.82 wid hei;0.05 0.63 wid hei; 0.05 0.44 wid hei; 0.05 0.25 wid hei; 0.05 0.06 wid hei];
        temp = linq(extract(Seg(i_trial),'sCP')).toArray();
        i_sbpl = 1; sb(i_sbpl) = subplot('Position',Position_subplot(i_sbpl,:)); plot(temp.times{:},temp.values{:}(:,2));
        sb(i_sbpl).YLabel.String = cellstr(temp.labels(2).name);
        i_sbpl = 2; sb(i_sbpl) = subplot('Position',Position_subplot(i_sbpl,:)); plot(temp.times{:},temp.values{:}(:,1));
        sb(i_sbpl).YLabel.String = cellstr(temp.labels(1).name);
        clear temp; temp = linq(extract(Seg(i_trial),'sCGSpeed')).toArray();
        i_sbpl = 3; sb(i_sbpl) = subplot('Position',Position_subplot(i_sbpl,:)); plot(temp.times{:},temp.values{:}(:,1));
        sb(i_sbpl).YLabel.String = cellstr(temp.labels(1).name);
        i_sbpl = 4; sb(i_sbpl) = subplot('Position',Position_subplot(i_sbpl,:)); plot(temp.times{:},temp.values{:}(:,3));
        sb(i_sbpl).YLabel.String = cellstr(temp.labels(3).name);
        clear temp; temp = linq(extract(Seg(i_trial),'sHeels')).toArray();
        i_sbpl = 5; sb(i_sbpl) = subplot('Position',Position_subplot(i_sbpl,:)); hold on,
        plot(temp.times{:},temp.values{:}(:,1),'r'); plot(temp.times{:},temp.values{:}(:,2),'g');
        sb(i_sbpl).YLabel.String = cellstr(temp.labels(1).name);
        clear temp;
        
        set(h,'ButtonDownFcn',@(~,~)graph_zoom); % permet de zoomer sur un subplot, après avoir cliqué sur le bon current axis
        
        linkaxes(sb(:),'x'); axis tight;
        
        for i_sbpl = 1:5
            plot(Seg(i_trial).eventProcess(1),'handle',sb(i_sbpl));
        end
        Xmin_Callback(XminBox); Xmax_Callback(XmaxBox);
        
        switch get(findobj(h,'Tag','Screen_Infos'),'Value')
            case 1
                try
                    for i_sbpl = 1:5
                        plot(Seg(i_trial).eventProcess(2),'handle',sb(i_sbpl));
                    end
                end
        end
    end

% ATTENTION !!!
% Move ne fct pas pour preAPA et FoG pour l'instant --> A revoir
    function loadSeg()
        
        [var, dossier] = uigetfile('*_Seg.mat','Choix du fichier Segment à charger');
        eval(['load(''' dossier var ''')']);
        
    end


    function list_acq_Callback(src,callbackdata)
        pos = get(src,'Value');
        % on recalcule la position du CP en fonction de la valeur à T0
        T0 = Seg(pos).eventProcess(1).find('func',@(x) strcmp(x.name.name,'T0'));
        A = Seg(pos).processes{1}.values{:};
        val1 = Seg(pos).processes{1}.valueAt(T0.tStart,'method','nearest');
        A = A - repmat(val1,Seg(pos).processes{1}.dim{:}(1),1);
        Seg(pos).processes{1}.map(@(x) A);
        % on recalcule la vitesse du CG en fonction de la valeur à T0
        B = Seg(pos).processes{2}.values{:};
        val2 = Seg(pos).processes{2}.valueAt(T0.tStart,'method','nearest');
        B = B - repmat(val2,Seg(pos).processes{2}.dim{:}(1),1);
        Seg(pos).processes{2}.map(@(x) B);
        
        % on retrace les données
        plot_LabTools(Seg,pos,sb);
        
        act_Calc_APA;
    end

%% Graph selection + zoom
    function graph_zoom %(src)
        % crée une nouvelle figure avec le graph à afficher dedans
        h=get(gca,'children');
        hf = gcf;
        list_acq = findobj(hf,'Type','uicontrol','-and','Style','listbox');
        ax = gca;
        f=figure('Units','normalized','Position',[0.1 0.5 0.7 0.4],'Name',list_acq.String{list_acq.Value});
        set(f,'Color',[1 1 1]) ;
        set(gca,'FontSize',12);
        h1=copyobj(h,gca,'legacy');
        set(h1, 'LineWidth',2);
        ax2 = gca;
        ax2.YLabel.String = ax.YLabel.String;
        ax2.XLim = ax.XLim;
        xlabel('Temps (s)')
    end

%% pour définir X min et Xmax
    function Xmin_Callback(src,callbackdata)
        hf = src.Parent;
        Xmin = str2num(src.String);
        Ax = findobj(hf,'Type','Axes');
        try
            Ax(1).XLim(1) = Xmin;
        catch
            Ax(1).XLim(1) = 0;
        end
    end
    function Xmax_Callback(src,callbackdata)
        hf = src.Parent;
        Xmax = str2num(src.String);
        Ax = findobj(hf,'Type','Axes');
        try
            Ax(1).XLim(2) = Xmax;
        catch
            Ax(1).XLim(2) = Ax(1).XLim(2);
        end
    end

%% pour actualiser les données de calculs APA
    function act_Calc_APA(src,callbackdata)
        hf = gcf;
        list_acq = findobj(hf,'Type','uicontrol','-and','Style','listbox');
        
        % 1ère étape : on met la position du CP à [0,0] à T0
        T0 = Seg(list_acq.Value).eventProcess(1).find('func',@(x) strcmp(x.name.name,'T0'));
        A = Seg(list_acq.Value).processes{1}.values{:};
        A = A - repmat(valueAt(Seg(list_acq.Value).processes{1},T0.tStart,'method','nearest'),size(Seg(list_acq.Value).processes{1}.values{:},1),1);
        Seg(list_acq.Value).processes{1}.map(@(x) A);
        Seg(list_acq.Value).processes{1}.fix;
        
        % pour lancer le calcul des paramètres actualisés
        Seg(list_acq.Value) = calculs_parametres_initiationPas_v5_LabTools(Seg(list_acq.Value));
        
        % pour afficher les résultats dans la fenêtre
        str = evalc(['disp(Seg(' num2str(list_acq.Value) ').info(''trial''))']);
        set(findobj(hf.Children,'Type','uicontrol','-and','Tag','Res_APA'),...
            'String',str([(strfind(str,'nTrial')):(strfind(str,'freezing')-1),strfind(str,'startingfoot'):strfind(str,'DuraS1')-1]),'FontSize',14);
        
    end

%% pour enregistrer les données
    function export_and_save(src,callbackdata)
        % on relance le calcul des paramètres APA avant le Save Segment sur l'ensemble des trials
        for i_trial = 1:numel(Seg)
            Seg(i_trial).eventProcess.fix;
            % 1ère étape : on met la position du CP à [0,0] à T0
            T0 = Seg(i_trial).eventProcess(1).find('func',@(x) strcmp(x.name.name,'T0'));
            A = Seg(i_trial).processes{1}.values{:};
            A = A - repmat(valueAt(Seg(i_trial).processes{1},T0.tStart,'method','nearest'),size(Seg(i_trial).processes{1}.values{:},1),1);
            Seg(i_trial).processes{1}.map(@(x) A);
            Seg(i_trial).processes{1}.fix;
            try
                Seg(i_trial) = calculs_parametres_initiationPas_v5_LabTools(Seg(i_trial));
            catch
                warning(['Trial ' num2str(i_trial) ' : calculs parametres initiationPas non calculés']);
            end
        end
        file_export = [Seg(1).info('trial').patient '_' Seg(1).info('trial').session '_' Seg(1).info('trial').medcondition '_' Seg(1).info('trial').speedcondition '_Seg'];
        [FileName,PathName] = uiputfile('*.mat','Sélectionner le dossier de destination du Segment à enregistrer',file_export);
        save([PathName FileName],'Seg');
        disp([char(FileName) ' saved to ' char(PathName)]);
    end

%% pour afficher timings de Stim de l'écran
    function Disp_Screen_Infos(src,callbackdata)
        switch get(findobj(h,'Tag','Screen_Infos'),'Value')
            case 1
                hf = gcf;
                list_acq = findobj(hf,'Type','uicontrol','-and','Style','listbox');
                try
                    for i_sbpl = 1:5
                        plot(Seg(list_acq.Value).eventProcess(2),'handle',sb(i_sbpl));
                    end
                catch
                    warning('Screen Infos Non dispo');
                end
        end
    end

    function export_evts_c3d(src,callbackdata)
        chemin_c3d = uigetdir('','Choix du repertoire des c3d');
        All_trials = linq(Seg).select(@(x) x.info('trial').trial).toList;
        for i_trial = 1:numel(Seg)
            try
                T0 = Seg(i_trial).eventProcess(1).find('func',@(x) strcmp(x.name.name,'T0'));
                HO = Seg(i_trial).eventProcess(1).find('func',@(x) strcmp(x.name.name,'HO'));
                FO1 = Seg(i_trial).eventProcess(1).find('func',@(x) strcmp(x.name.name,'FO1'));
                FC1 = Seg(i_trial).eventProcess(1).find('func',@(x) strcmp(x.name.name,'FC1'));
                FO2 = Seg(i_trial).eventProcess(1).find('func',@(x) strcmp(x.name.name,'FO2'));
                FC2 = Seg(i_trial).eventProcess(1).find('func',@(x) strcmp(x.name.name,'FC2'));
                
                acq = btkReadAcquisition(fullfile(chemin_c3d,Seg(i_trial).info('trial').trial));
                btkClearEvents(acq);
                btkAppendEvent(acq,'Event',T0.tStart,'General');
                btkAppendEvent(acq,'Event',HO.tStart,'General');
                
                if ~isempty(strfind(Seg(i_trial).info('trial').startingfoot,'Left'))
                    btkAppendEvent(acq,'Foot Off',FO1.tStart,'Left');
                    btkAppendEvent(acq,'Foot Strike',FC1.tStart,'Left');
                    btkAppendEvent(acq,'Foot Off',FO2.tStart,'Right');
                    btkAppendEvent(acq,'Foot Strike',FC2.tStart,'Right');
                elseif  ~isempty(strfind(Seg(i_trial).info('trial').startingfoot,'Right'))
                    btkAppendEvent(acq,'Foot Off',FO1.tStart,'Right');
                    btkAppendEvent(acq,'Foot Strike',FC1.tStart,'Right');
                    btkAppendEvent(acq,'Foot Off',FO2.tStart,'Left');
                    btkAppendEvent(acq,'Foot Strike',FC2.tStart,'Left');
                end
                
                btkSetEventId(acq, 'Event', 0);
                btkSetEventId(acq, 'Foot Strike', 1);
                btkSetEventId(acq, 'Foot Off', 2);
                btkWriteAcquisition(acq,fullfile(chemin_c3d,Seg(i_trial).info('trial').trial))
                disp([Seg(i_trial).info('trial').trial ' --> OK'])
            catch
                warning('Attention évènements non exportés vers c3d');
            end
        end
    end
%% pour supprimer un essai non valide
    function Delete_trial(src,callbackdata)
        hf = gcf;
        list_acq = findobj(hf,'Type','uicontrol','-and','Style','listbox');
        Seg(list_acq.Value)=[];
        acq_list = linq(Seg).select(@(x) x.info('trial').trial).toList;
        obj = findobj(hf,'Type','uicontrol','-and','Style','listbox');
        obj.String = acq_list;
        list_acq_Callback(src,callbackdata);
        disp('trial deleted');
    end
end


