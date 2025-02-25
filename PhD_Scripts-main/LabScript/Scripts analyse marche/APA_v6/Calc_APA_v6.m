function varargout = Calc_APA_v6(varargin)
% CALC_APA_V6 MATLAB code for Calc_APA_v6.fig
%      CALC_APA_V6, by itself, creates a new CALC_APA_V6 or raises the existing
%      singleton*.
%
%      H = CALC_APA_V6 returns the handle fo1 a new CALC_APA_V6 or the handle fo1
%      the existing singleton*.
%
%      CALC_APA_V6('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALC_APA_V6.M with the given input arguments.
%
%      CALC_APA_V6('Property','Value',...) creates a new calc_apa_v6 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied fo1 the GUI before Calc_APA_v6_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed fo1 Calc_APA_v6_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance fo1 run (singleton)".
%
%See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text fo1 modify the response fo1 help Calc_APA_v6

% Last Modified by GUIDE v2.5 18-May-2016 18:05:29

% Modif le 22/06/2016
% Dans APA_Vitesses_Callback, décalage temporel pour le tracé des infos sur
% les axes, correspondant au décalage du trigger (en lien avec modifs
% faites dans calculs_parametres_initiationPas_v5.m et
% calcul_auto_APA_marker_v2.m

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Calc_APA_v6_OpeningFcn, ...
    'gui_OutputFcn',  @Calc_APA_v6_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

%

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
%% Calc_APA_v6_OpeningFcn -Funcion principale
% --- Executes just before Calc_APA_v6 is made visible.
function Calc_APA_v6_OpeningFcn(hObject, ~, handles, varargin)
global haxes1 haxes2 haxes3 haxes4 haxes6 haxes7 h_marks_T0 h_marks_HO h_marks_FO1 ...
    h_marks_FC1 h_marks_FO2 h_marks_FC2 Aff_corr
% Funcion principale (Interface)
% This function has no output args, see OutputFcn.
% hObject    handle fo1 figure
% eventdata  reserved - fo1 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments fo1 Calc_APA_v6 (see VARARGIN)

% Choose default command line output for Calc_APA_v6
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Calc_APA_v6 wait for user response (see UIRESUME)
% uiwait(handles.Calc_APA_v6);
set(gcf,'Name','Calcul des APA v6');

scrsz = get(0,'ScreenSize');
set(hObject,'Position',[scrsz(4)/20 scrsz(3)/20 scrsz(3)*9/10 scrsz(4)*8.5/10]);

ylabel(haxes1,'Axe antéro-postérieur (mm)','FontName','Times New Roman','FontSize',10);
set(haxes1,'Visible','Off');

ylabel(haxes2,'Axe médio-latéral(mm)','FontName','Times New Roman','FontSize',10);
set(haxes2,'Visible','Off');

ylabel(haxes3,'Axe antéro-postérieur (m/s)','FontName','Times New Roman','FontSize',10);
set(haxes3,'Visible','Off');

ylabel(haxes4,'Axe vertical(m/s)','FontName','Times New Roman','FontSize',10);
xlabel(haxes4,'Temps (sec)','FontName','Times New Roman','FontSize',10);
set(haxes4,'Visible','Off');

ylabel(haxes6,'Axe vertical(m²/s)','FontName','Times New Roman','FontSize',10);
xlabel(haxes6,'Temps (sec)','FontName','Times New Roman','FontSize',10);
set(haxes6,'Visible','Off');

ylabel(haxes7,'Axe antéro-post (mm)','FontName','Times New Roman','FontSize',10);
xlabel(haxes7,'Axe médio-lat (mm)','FontName','Times New Roman','FontSize',10);
set(haxes7,'Visible','Off');

% test modifs
h_marks_T0 = [];
h_marks_HO = [];
h_marks_FO1 = [];
h_marks_FC1 = [];
h_marks_FO2 = [];
h_marks_FC2= [];
Aff_corr = 0;

%Initialisation des états d'affichages pour la vitesse
set(findobj('tag','V_intgr'),'Value',1); %Intégration
set(findobj('tag','V_der'),'Value',0);   %Dérivation
set(findobj('tag','V_der_Vic'),'Value',0); %Dérivation (vicon)
set(findobj('tag','PlotHeels'),'Value',1); %Affichage marqueurs talons

%FILE MENU
h = uimenu('Parent',hObject,'Label','FILE','Tag','menu_fichier','handlevisibility','On') ;
h1= uimenu(h,'Label','NOUVEAU SUJET','handlevisibility','on') ;
uimenu(h1,'Label','Charger acquisitions','Callback',@uipushtool1_ClickedCallback);
uimenu(h,'Label','CHARGER SUJET','handlevisibility','On','Callback',@uipushtool4_ClickedCallback) ; %% uipushtool4_ClickedCallback(findobj('tag','uipushtool4'), eventdata, handles))

% EXPORT MENU
e = uimenu('Parent',hObject,'Label','EXPORT','Tag','Export','handlevisibility','On','Enable','On') ;
uimenu(e,'Label','Export evts -> c3d','Callback',@export_events);

% --- Outputs from this function are returned fo1 the command line.
function varargout = Calc_APA_v6_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle fo1 figure
% eventdata  reserved - fo1 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% listbox1_Callback - Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
% Choix/Click dans la liste actualisée
global haxes1 haxes2 haxes3 haxes4 haxes5 haxes6 haxes7 APA TrialParams ResAPA liste_marche acq_courante ...
    flag_afficheV Notocord
% hObject    handle fo1 listbox1 (see GCBO)

%Récupération de l'acquisition séléctionnée
pos = get(hObject,'Value');
acq_courante = liste_marche{pos};

% On check la présence de données de vitesse dérivé (pour l'affichage)
flag_der = isfield(APA.Trial(pos),'CG_Speed_d');
if flag_der
    set(findobj('tag','V_der'),'Enable','On');
    set(findobj('tag','Vy_FO1'),'Enable','On');
    set(findobj('tag','V2'),'Enable','On');
else
    set(findobj('tag','V_der'),'Value',0);
    set(findobj('tag','V_der'),'Enable','Off');
    set(findobj('tag','Vy_FO1'),'Enable','Off');
    set(findobj('tag','V2'),'Enable','Off');
end

%Initialisation des plots/axes et marqueurs si Multiplot Off
axess = findobj('Type','axes');
for i=1:length(axess)
    if get(findobj('tag','Multiplot'),'Value') %% Si bouton Multiplot pressé
        set(axess(i),'NextPlot','add'); % Multiplot On
    else
        set(axess(i),'NextPlot','replace'); % Multiplot Off
    end
end

t = APA.Trial(pos).CP_Position.Time;
Fin = length(t);
TFin = floor(2*max(t))/2+0.5;

% Affichage des courbes déplacements (CP) et Puissance/Acc
plot(haxes1,t,APA.Trial(pos).CP_Position.Data(1,1:Fin)); axis(haxes1,'tight');
xlim(haxes1,[0 TFin])
plot(haxes2,t,APA.Trial(pos).CP_Position.Data(2,1:Fin)); axis(haxes2,'tight');
xlim(haxes2,[0 TFin])

flagPF=get(findobj('tag','PlotPF'),'Value');
flagHeels=get(findobj('tag','PlotHeels'),'Value');
flagAccelCG=get(findobj('tag','PlotAccelCG'),'Value');
if flagPF
    try
        set(findobj('Tag','Title_haxes6'),'String','Trajectoire CP');
        xlabel(haxes6,'Axe Antéropostérieur(mm)','FontName','Times New Roman','FontSize',10);
        ylabel(haxes6,'Axe Médio-Latéral (mm)','FontName','Times New Roman','FontSize',10);
        plot(haxes6,APA.Trial(pos).CP_Position.Data(2,:),APA.Trial(pos).CP_Position.Data(1,:)); %axis tight
        set(haxes6,'YDir','reverse');
        set(findobj('tag','PlotHeels'),'Value',0); set(findobj('tag','PlotAccelCG'),'Value',0);
    catch
    end
elseif flagHeels
    try
        set(findobj('Tag','Title_haxes6'),'String','Marqueurs Talons');
        xlabel(haxes6,'Temps (s)','FontName','Times New Roman','FontSize',10);
        leg(1) = plot(haxes6,APA.Trial(pos).LHEE.Time,APA.Trial(pos).LHEE.Data(3,:),'r');
        set(haxes6,'NextPlot','add');
        leg(2) = plot(haxes6,APA.Trial(pos).LHEE.Time,APA.Trial(pos).RHEE.Data(3,:),'g');
        xlabel(haxes6,'Temps (s)','FontName','Times New Roman','FontSize',10);
        ylabel(haxes6,'Z marqueurs talons (mm)','FontName','Times New Roman','FontSize',12);
        legend(leg,'Left','Right');
        xlim(haxes6,[0 TFin]);
        set(findobj('tag','PlotPF'),'Value',0); set(findobj('tag','PlotAccelCG'),'Value',0);
    catch
    end
elseif flagAccelCG
    set(findobj('Tag','Title_haxes6'),'String','Accélération/Puissance CG');
    plot(haxes6,t,APA.Trial(pos).CG_Power.Data(1:Fin)); afficheY_v2(0,':k',haxes6);
    xlabel(haxes6,'Temps (s)','FontName','Times New Roman','FontSize',10);
    ylabel(haxes6,'Puissance (Watt)','FontName','Times New Roman','FontSize',12);
    xlim(haxes6,[0 TFin]);
    set(findobj('tag','PlotPF'),'Value',0); set(findobj('tag','PlotHeels'),'Value',0);
end

% affichage de la trajectoire du CP dans le axes7 % en 3 couleurs
set(findobj('Tag','Title_haxes7'),'String','Trajectoire CP');
nb_frames = length(APA.Trial(pos).CP_Position.Data(2,:));
plot(haxes7,APA.Trial(pos).CP_Position.Data(2,1:round(nb_frames/3)),APA.Trial(pos).CP_Position.Data(1,1:round(nb_frames/3)),'color',[0 162 232]./255);
set(haxes7,'NextPlot','add');
plot(haxes7,APA.Trial(pos).CP_Position.Data(2,round(nb_frames/3):round(2*nb_frames/3)),APA.Trial(pos).CP_Position.Data(1,round(nb_frames/3):round(2*nb_frames/3)),'color',[0.5 0.5 0.5]);
plot(haxes7,APA.Trial(pos).CP_Position.Data(2,round(2*nb_frames/3):nb_frames),APA.Trial(pos).CP_Position.Data(1,round(2*nb_frames/3):nb_frames),'color',[255 201 14]./255);
ylabel(haxes7,'Axe Antéro-post(mm)','FontName','Times New Roman','FontSize',10);
xlabel(haxes7,'Axe Médio-Latéral(mm)','FontName','Times New Roman','FontSize',10);

%Affichage des vitesses en fonction des choix de l'utilisateur et présence de données dérivées
flags_V = [get(findobj('tag','V_intgr'),'Value') get(findobj('tag','V_der'),'Value') get(findobj('tag','V_der_Vic'),'Value')];
flag_afficheV = sum(flags_V); %Flag d'affichage

% Extraction des maximas/minimas pour affichage des vitesses dans la bonne échelle
Fech = APA.Trial(pos).CP_Position.Fech;
T0 = round(TrialParams.Trial(pos).EventsTime(2)*Fech)+1;
FC2 = round(TrialParams.Trial(pos).EventsTime(7)*Fech);
if isnan(FC2)
    FC2 = size(APA.Trial(pos).GroundWrench.Time,2);
end
Min_AP=min(APA.Trial(pos).CG_Speed.Data(1,T0:FC2))*1.25;
Max_AP=max(APA.Trial(pos).CG_Speed.Data(1,T0:FC2))*1.25;
Min_Z=min(APA.Trial(pos).CG_Speed.Data(3,T0:FC2))*1.25;
Max_Z=max(APA.Trial(pos).CG_Speed.Data(3,T0:FC2))*1.25;
if any([isempty(Min_AP),isempty(Max_AP),isempty(Min_Z),isempty(Max_Z)])
    Min_AP=min(APA.Trial(pos).CG_Speed.Data(1,:))*1.25;
    Max_AP=max(APA.Trial(pos).CG_Speed.Data(1,:))*1.25;
    Min_Z=min(APA.Trial(pos).CG_Speed.Data(3,:))*1.25;
    Max_Z=max(APA.Trial(pos).CG_Speed.Data(3,:))*1.25;
end

switch flag_afficheV
    case 0 %Aucune sélection
        plot(haxes3,t,zeros(1,length(t)),'Color','w');
        plot(haxes4,t,zeros(1,length(t)),'Color','w');
    case 1
        if flags_V(2) %Courbes dérivées
            plot(haxes3,t,APA.Trial(pos).CG_Speed_d.Data(1,1:Fin),'r-');
            xlim(haxes3,[0 TFin])
            plot(haxes4,t,APA.Trial(pos).CG_Speed_d.Data(3,1:Fin),'r-');
            xlim(haxes4,[0 TFin])
            afficheY_v2(0,':k',haxes3); afficheY_v2(0,':k',haxes4);
            set(haxes3,'ylim',[Min_AP Max_AP]);
            set(haxes4,'ylim',[Min_Z Max_Z]);
        elseif flags_V(3) %Courbes dérivées
            plot(haxes3,t,APA.Trial(pos).CG_Speed_d_VIC.Data(1,1:Fin),'g-');
            xlim(haxes3,[0 TFin])
            plot(haxes4,t,APA.Trial(pos).CG_Speed_d_VIC.Data(3,1:Fin),'g-');
            xlim(haxes4,[0 TFin])
            afficheY_v2(0,':k',haxes3); afficheY_v2(0,':k',haxes4);
            set(haxes3,'ylim',[Min_AP Max_AP]);
            set(haxes4,'ylim',[Min_Z Max_Z]);
        else %Courbes intégrées
            plot(haxes3,t,APA.Trial(pos).CG_Speed.Data(1,1:Fin)); afficheY_v2(0,':k',haxes3);
            xlim(haxes3,[0 TFin])
            plot(haxes4,t,APA.Trial(pos).CG_Speed.Data(3,1:Fin)); afficheY_v2(0,':k',haxes4);
            xlim(haxes4,[0 TFin])
            set(haxes3,'ylim',[Min_AP Max_AP]);
            set(haxes4,'ylim',[Min_Z Max_Z]);
        end
    case 2 % 2 courbes sur 3
        if flags_V(2) %Courbes dérivées
            plot(haxes3,t,APA.Trial(pos).CG_Speed_d.Data(1,1:Fin),'r-');
            xlim(haxes3,[0 TFin])
            plot(haxes4,t,APA.Trial(pos).CG_Speed_d.Data(3,1:Fin),'r-');
            xlim(haxes3,[0 TFin])
            afficheY_v2(0,':k',haxes3); afficheY_v2(0,':k',haxes4);
            set(haxes3,'ylim',[Min_AP Max_AP]);
            set(haxes4,'ylim',[Min_Z Max_Z]);
        end
        if flags_V(3) %Courbes dérivées
            plot(haxes3,t,APA.Trial(pos).CG_Speed_d_VIC.Data(1,1:Fin),'g-');
            xlim(haxes3,[0 TFin])
            plot(haxes4,t,APA.Trial(pos).CG_Speed_d_VIC.Data(3,1:Fin),'g-');
            xlim(haxes4,[0 TFin])
            afficheY_v2(0,':k',haxes3); afficheY_v2(0,':k',haxes4);
            set(haxes3,'ylim',[Min_AP Max_AP]);
            set(haxes4,'ylim',[Min_Z Max_Z]);
        end
        if flags_V(1)%Courbes intégrées
            plot(haxes3,t,APA.Trial(pos).CG_Speed.Data(1,1:Fin)); afficheY_v2(0,':k',haxes3);
            xlim(haxes3,[0 TFin])
            plot(haxes4,t,APA.Trial(pos).CG_Speed.Data(3,1:Fin)); afficheY_v2(0,':k',haxes4);
            xlim(haxes4,[0 TFin])
            set(haxes3,'ylim',[Min_AP Max_AP]);
            set(haxes4,'ylim',[Min_Z Max_Z]);
        end
    case 3 %Les 3
        plot(haxes3,t,APA.Trial(pos).CG_Speed.Data(1,1:Fin)); afficheY_v2(0,':k',haxes3);
        plot(haxes4,t,APA.Trial(pos).CG_Speed.Data(3,1:Fin)); afficheY_v2(0,':k',haxes4);
        plot(haxes3,t,APA.Trial(pos).CG_Speed_d.Data(1,1:Fin),'r-');
        plot(haxes4,t,APA.Trial(pos).CG_Speed_d.Data(3,1:Fin),'r-');
        plot(haxes3,t,APA.Trial(pos).CG_Speed_d_VIC.Data(1,1:Fin),'g-');
        plot(haxes4,t,APA.Trial(pos).CG_Speed_d_VIC.Data(3,1:Fin),'g-');
        
        afficheY_v2(0,':k',haxes3); afficheY_v2(0,':k',haxes4);
        set(haxes3,'ylim',[min([Min_AP Min_AP_D]) max([Max_AP Max_AP_D])]);
        xlim(haxes3,[0 TFin])
        set(haxes4,'ylim',[min([Min_Z Min_Z_D]) max([Max_Z Max_Z_D])]);
        xlim(haxes4,[0 TFin])
end

% Si affichage automatique 'On'
if get(findobj('tag','Automatik_display'),'Value') %% Si bouton Affichage automatique pressé
    Markers_Callback(findobj('tag','Markers'));
    APA_Vitesses_Callback(findobj('tag','Vitesses'), eventdata,handles);
    if ~Notocord
        Calc_current_Callback(findobj('tag','Calc_current'), eventdata,handles); %Arret le calcul automatique
        affiche_resultat_APA(ResAPA.Trial(pos));
    else
        try
            affiche_resultat_APA(ResAPA.Trial(pos));
        catch ERR
            warning(ERR.identifier,['Aucun calcul réalisé ' acq_courante ' / ' ERR.message]);
        end
    end
end

if  get(findobj('tag','Affich_corridor'),'Value')
    Affich_corridor_Callback;
end

set(haxes1,'XTick',NaN);
set(haxes2,'XTick',NaN);
set(haxes3,'XTick',NaN);
set(haxes4,'XTick',NaN);

%Activation des boutons/toolbars et legendes d'axes
set(findobj('tag','text_cp'),'Visible','On');
ylabel(haxes1,'Axe antéro-postérieur (mm)','FontName','Times New Roman','FontSize',10);
ylabel(haxes2,'Axe médio-latéral(mm)','FontName','Times New Roman','FontSize',10);
ylabel(haxes3,'Axe antéro-postérieur (m/s)','FontName','Times New Roman','FontSize',10);
ylabel(haxes4,'Axe vertical(m/s)','FontName','Times New Roman','FontSize',10);
xlabel(haxes6,'Temps (sec)','FontName','Times New Roman','FontSize',10);

set(haxes1,'ButtonDownFcn',@(hObject, eventdata)Calc_APA_v6('graph_zoom',hObject, eventdata,guidata(hObject)));
set(haxes2,'ButtonDownFcn',@(hObject, eventdata)Calc_APA_v6('graph_zoom',hObject, eventdata,guidata(hObject)));
set(haxes3,'ButtonDownFcn',@(hObject, eventdata)Calc_APA_v6('graph_zoom',hObject, eventdata,guidata(hObject)));
set(haxes4,'ButtonDownFcn',@(hObject, eventdata)Calc_APA_v6('graph_zoom',hObject, eventdata,guidata(hObject)));
set(haxes5,'ButtonDownFcn',@(hObject, eventdata)Calc_APA_v6('graph_zoom',hObject, eventdata,guidata(hObject)));
set(haxes6,'ButtonDownFcn',@(hObject, eventdata)Calc_APA_v6('graph_zoom',hObject, eventdata,guidata(hObject)));

set(findobj('tag','text_cg'),'Visible','On');
set(findobj('tag','Title_haxes6'),'Visible','On');
set(findobj('tag','Group_APA'),'Visible','On');
set(findobj('tag','time_normalize'), 'Visible','On');
set(findobj('tag','real_time'), 'Visible','On');
set(findobj('tag','InfosButton'), 'Visible','On');

set(findobj('tag','normalized_time'), 'Visible','On');
set(findobj('tag','Calc_current'),'Visible','On');
set(findobj('tag','Calc_batch'),'Visible','On');
set(findobj('tag','Clean_data'), 'Visible','On');
set(findobj('tag','Results'), 'Visible','On');

set(findobj('tag','Markers'), 'Visible','On');
set(findobj('tag','Vitesses'),'Visible','On');
set(findobj('tag','uitable1'),'Visible','On');
set(findobj('tag','Delete_current'),'Enable','On');

%Bouton de sauvegarde
set(findobj('tag','uipushtool3'),'Enable','On');

%% listbox1_CreateFcn - Création de la liste
function listbox1_CreateFcn(hObject, ~, ~)
% Création de la liste
% hObject    handle fo1 listbox1 (see GCBO)
% eventdata  reserved - fo1 be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% togglebutton1_Callback - Activation des boutton de Zoom/Translation
function togglebutton1_Callback(hObject, ~, ~)
% Activation des boutton de Zoom/Translation
% hObject    handle fo1 togglebutton1 (see GCBO)
% Hint: get(hObject,'Value') returns toggle state of togglebutton1

if get(hObject,'Value')==1
    set(findobj('tag','uitoggletool1'),'Enable','On');
    set(findobj('tag','uitoggletool2'),'Enable','On');
    set(findobj('tag','uitoggletool3'),'Enable','On');
else
    set(findobj('tag','uitoggletool1'),'Enable','Off');
    set(findobj('tag','uitoggletool2'),'Enable','Off');
    set(findobj('tag','uitoggletool3'),'Enable','Off');
end

%% uipushtool1_ClickedCallback - Charger acquisition
function uipushtool1_ClickedCallback(~, ~, ~)
% Choix fichier(s) (simple/multiple)
% hObject    handle fo1 uipushtool1 (see GCBO)
global dossier_c3d APA TrialParams ResAPA APA_T TrialParams_T Subject_data liste_marche Notocord

try
    %Choix manuel des fichiers
    [files, dossier_c3d] = uigetfile('*.c3d; *.xls','Choix du/des fichier(s) c3d ou notocord(xls)','Multiselect','on'); % Ajouter plus tard les autres file types
    
    %Initialisation
    Subject_data = {};
    
    %Extraction des données d'intérêts
    button_cut = questdlg('Lire toute l''acquisition?','Durée acquisition','Oui','PF','PF');
    [APA_T, TrialParams_T, ResAPA] = Data_Preprocessing(files,dossier_c3d(1:end-1),button_cut);
    APA = APA_T;
    TrialParams = TrialParams_T;
    
    % Mise à jour interface et activation des boutons
    set(findobj('tag','listbox1'), 'Visible','On');
    set(findobj('tag','togglebutton1'),'Visible','On');
    set(findobj('tag','AutoScale'),'Visible','On');
    set(findobj('tag','Multiplot'),'Visible','On');
    set(findobj('tag','APA_auto'),'Visible','On');
    set(findobj('tag','Automatik_display'),'Visible','On');
    set(findobj('tag','Results'), 'Visible','Off');
    set(findobj('tag','Results'), 'Data',zeros(30,1));
    
    set(findobj('Tag','sujet_courant'),'Enable','On');
    set(findobj('Tag','subject_info'),'Enable','On');
    set(findobj('Tag','Delete_current'),'Visible','On');
    set(findobj('tag','Export_trigs'), 'Visible','On');
    set(findobj('tag','PlotPF'), 'Visible','On');
    set(findobj('tag','PlotHeels'), 'Visible','On');
    set(findobj('tag','PlotAccelCG'), 'Visible','On');
    Notocord =0; %% Chargement de fichiers brut d'acquisitions  et non de fichiers pré-traités
    
    %Activation des axes
    axess = findobj('Type','axes');
    for i=1:length(axess)
        set(axess(i),'Visible','On');
    end
    
    %Mise à jour de la liste
    set(findobj('tag','listbox1'), 'Value',1);
    liste_marche = arrayfun(@(i) APA.Trial(i).CP_Position.TrialName, 1:length(APA.Trial),'uni',0);
    set(findobj('tag','listbox1'),'String',liste_marche);
    
    set(findobj('tag','time_normalize'), 'Enable','On');
    set(findobj('tag','real_time'), 'Enable','On');
    set(findobj('tag','Calc_batch'), 'Enable','On');
    set(findobj('tag','Clean_data'), 'Enable','On');
    if length(files)>1
        set(findobj('tag','Group_APA'), 'Enable','On');
    end
    
catch ERR_Charg
    warning(ERR_Charg.identifier,['Annulation chargement fichiers / ',ERR_Charg.message])
    waitfor(warndlg('Annulation chargement fichiers!'));
    
    
    % Chargement des évènements si dispo dans le c3d
%     try
%     catch
%     end
    
end

%% ajouter_acquisitions - Ajouter des acquisitions au sujet en cours de traitement
% --- Ajout acquisitions au sujet courant
function ajouter_acquisitions(~,~,~)
% Ajouter des acquisitions au sujet en cour de traitement
global dossier_c3d APA TrialParams ResAPA liste_marche

try
    %Choix manuel des fichiers
    [files, dossier_c3d] = uigetfile('*.c3d; *.xls','Choix du/des fichier(s) c3d ou notocord(xls)','Multiselect','on'); %%Ajouter plus tard les autres file types
    
    %Extraction des données d'intérêts
    button_cut = questdlg('Lire toute l''acquisition?','Durée acquisition','Oui','PF','PF');
    [APA_add, TrialParams_add, ResAPA_add]= Data_Preprocessing(files,dossier_c3d(1:end-1),button_cut);
    
    % On modifie le nom des acquisitions/fields similaires
    liste_new = arrayfun(@(i) APA_add.Trial(i).CP_Position.TrialName, 1:length(APA_add.Trial),'uni',0);
    
    [~,b,~] = matchcells(liste_marche,liste_new,'exact');
    if any(b==1)
        for i = 1 : length(b)
            if b(i)==1
                warning(['Attention acquisition en double / Données non chargées pour :' APA_add.Trial(i).CP_Position.TrialName])
            end
        end
    end
    APA_add.Trial = APA_add.Trial(b==0);
    TrialParams_add.Trial = TrialParams_add.Trial(b==0);
    ResAPA_add.Trial = ResAPA_add.Trial(b==0);
    
    liste_new = arrayfun(@(i) APA_add.Trial(i).CP_Position.TrialName, 1:length(APA_add.Trial),'uni',0);
    liste_rem = arrayfun(@(i) APA.removedTrials(i).CP_Position.TrialName, 1:length(APA.removedTrials),'uni',0);
    
    [a,b,~] = matchcells(liste_rem,liste_new,'exact');
    if any(b==1)
        for i = 1 : length(b)
            if b(i)==1
                warning(['Attention acquisition déjà supprimée / Données re-chargées pour :' APA_add.Trial(i).CP_Position.TrialName])
            end
        end
        APA.removedTrials = APA.removedTrials(setdiff(1:length(APA.removedTrials),a));
        ResAPA.removedTrials = ResAPA.removedTrials(setdiff(1:length(ResAPA.removedTrials),a));
        TrialParams.removedTrials = TrialParams.removedTrials(setdiff(1:length(TrialParams.removedTrials),a));
    end
    
    APA.Trial = [APA.Trial , APA_add.Trial];
    ResAPA.Trial = [ResAPA.Trial , ResAPA_add.Trial];
    TrialParams.Trial = [TrialParams.Trial , TrialParams_add.Trial];
    num_Trial = arrayfun(@(i) APA.Trial(i).CP_Position.TrialNum,1:length(APA.Trial));
    [~,ind_tri] = sort(unique(num_Trial));
    APA.Trial = APA.Trial(ind_tri);
    ResAPA.Trial = ResAPA.Trial(ind_tri);
    TrialParams.Trial = TrialParams.Trial(ind_tri);
    
    set(findobj('tag','listbox1'), 'Value',1);
    liste_marche = arrayfun(@(i) APA.Trial(i).CP_Position.TrialName, 1:length(APA.Trial),'uni',0);
    set(findobj('tag','listbox1'),'String',liste_marche);
    
catch ERR_Charg
    warning(ERR_Charg.identifier,['Annulation chargement fichiers / ',ERR_Charg.message])
    waitfor(warndlg('Annulation chargement fichiers!'));
end

%% axes1_CreateFcn - Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, ~, ~)
global haxes1
% hObject    handle fo1 axes1 (see GCBO)
haxes1 = hObject;
delete(get(haxes1,'Children'));

%% axes2_CreateFcn - Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, ~, ~)
global haxes2
% hObject    handle fo1 axes2 (see GCBO)
haxes2 = hObject;
delete(get(haxes2,'Children'));

%% axes3_CreateFcn - Executes during object creation, after setting all properties.
function axes3_CreateFcn(hObject, ~, ~)
global haxes3
% hObject    handle fo1 axes2 (see GCBO)
haxes3 = hObject;
delete(get(haxes3,'Children'));

%% axes4_CreateFcn - Executes during object creation, after setting all properties.
function axes4_CreateFcn(hObject, ~, ~)
global haxes4
% hObject    handle fo1 axes2 (see GCBO)
haxes4 = hObject;
delete(get(haxes4,'Children'));

%% axes6_CreateFcn
function axes6_CreateFcn(hObject, ~, ~)
global haxes6
% hObject    handle fo1 axes2 (see GCBO)
haxes6 = hObject;
delete(get(haxes6,'Children'));

%% uipushtool4_ClickedCallback - Chargement d'un fichier deja traité
function uipushtool4_ClickedCallback(~, ~, ~)
% Chargement d'un fichier deja traité
global APA ResAPA TrialParams APA_T TrialParams_T liste_marche acq_courante

try
    
    APA = {};
    ResAPA = {};
    TrialParams = {};
    
    [var, dossier] = uigetfile('*_APA.mat','Choix du fichier APA à charger');
    if ischar(var)
        eval(['APA0 = load (''' fullfile(dossier,var) ''');']);
        nom_APA = fieldnames(APA0);
        eval(['APA = APA0.' nom_APA{1} ';']);
        
        eval(['ResAPA0 = load (''' fullfile(dossier,strrep(var,'APA','ResAPA')) ''');']);
        nom_ResAPA = fieldnames(ResAPA0);
        eval(['ResAPA = ResAPA0.'  nom_ResAPA{1} ';']);
        
        eval(['TrialParams0 = load (''' fullfile(dossier,strrep(var,'APA','TrialParams')) ''');']);
        nom_TrialParams0 = fieldnames(TrialParams0);
        eval(['TrialParams = TrialParams0.' nom_TrialParams0{1} ';'])  ;
    end
    APA_T = APA;
    TrialParams_T = TrialParams;
    
    % Mise à jour interface et activation des boutons
    set(findobj('tag','listbox1'), 'Visible','On');
    liste_marche = arrayfun(@(i) APA.Trial(i).CP_Position.TrialName, 1:length(APA.Trial),'uni',0);
    set(findobj('tag','listbox1'),'String',liste_marche);
    set(findobj('tag','listbox1'), 'Value',1);
    acq_courante = liste_marche{1};
    set(findobj('tag','togglebutton1'),'Visible','On');
    set(findobj('tag','AutoScale'),'Visible','On');
    set(findobj('tag','Multiplot'),'Visible','On');
    set(findobj('tag','APA_auto'),'Visible','On');
    set(findobj('tag','Automatik_display'),'Visible','On');
    set(findobj('tag','Results'), 'Visible','Off');
    set(findobj('tag','Results'), 'Data',zeros(30,1));
    set(findobj('tag','Affich_corridor'), 'Visible','On');
    set(findobj('tag','PlotPF'), 'Visible','On');
    set(findobj('tag','PlotHeels'), 'Visible','On');
    set(findobj('tag','PlotAccelCG'), 'Visible','On');
    
    set(findobj('tag','pushbutton20'),'Visible','On');
    
    set(findobj('Tag','sujet_courant'),'Enable','On');
    set(findobj('Tag','subject_info'),'Enable','On');
    set(findobj('Tag','Delete_current'),'Visible','On');
    
    set(findobj('tag','time_normalize'), 'Visible','On');
    set(findobj('tag','time_normalize'), 'Enable','On');
    set(findobj('tag','real_time'), 'Enable','On');
    set(findobj('tag','Group_APA'), 'Visible','On');
    if length(APA.Trial)>1
        set(findobj('tag','Group_APA'), 'Enable','On');
    end
    
    axess = findobj('Type','axes');
    for i=1:length(axess)
        set(axess(i),'Visible','On');
        set(axess(i),'NextPlot','add');
    end
catch ERR
    error(['Annulation chargement / ' ERR.message]);
end

%% uipushtool3_ClickedCallback -Sauvegarde d'un fichier en cours
function uipushtool3_ClickedCallback(~, ~, ~)
% Sauvegarde d'un fichier en cours
% hObject    handle fo1 uipushtool3 (see GCBO)
global APA TrialParams ResAPA

[nom_fich,chemin] = uiputfile('*.mat','Nom Du fichier à sauvegarder',[APA.Infos.FileName '_APA']);
if any(nom_fich ~= 0)
    eval([APA.Infos.FileName '_APA = APA;'])
    eval(['save(fullfile(chemin,nom_fich),''' APA.Infos.FileName '_APA'',''-mat'');'])
    eval([APA.Infos.FileName '_ResAPA = ResAPA;'])
    eval(['save(fullfile(chemin,strrep(nom_fich,''APA'',''ResAPA'')),''' ResAPA.Infos.FileName '_ResAPA'',''-mat'');'])
    eval([APA.Infos.FileName '_TrialParams = TrialParams;'])
    eval(['save(fullfile(chemin,strrep(nom_fich,''APA'',''TrialParams'')),''' TrialParams.Infos.FileName '_TrialParams'',''-mat'');'])
    msgbox('.MAT sauvegardés');
       
    % Export Excel
    button = questdlg('Exporter sur Excel?','Sauvegarde résultats','Oui','Non','Non');
    if strcmp(button,'Oui')
        fichier = strrep(nom_fich,'APA.mat','ResAPA.xlsx');
        champs = fieldnames(ResAPA.Trial(1));
        Tab.tag(1,:) = [champs(end-2:end-1);champs(1:end-3)]';
        for i = 1 : length(ResAPA.Trial)
            Tab.tag(i+1,1) = {ResAPA.Trial(i).TrialName};
            Tab.tag(i+1,2) = num2cell(ResAPA.Trial(i).TrialNum);
            Tab.tag(i+1,3) = {ResAPA.Trial(i).Cote};
            for j = 2 : length(champs)-3
                try
                    Tab.data(i,j-1) = ResAPA.Trial(i).(champs{j})(1);
                catch
                end
            end
        end
        xlswrite(fullfile(chemin,fichier),Tab.tag,1,'A1')
        xlswrite(fullfile(chemin,fichier),Tab.data,1,'D2')
    end
end

%% AutoScale_Callback - Remise à l'échelle
function AutoScale_Callback(~, ~, ~)
% Remise à l'échelle
% hObject    handle fo1 AutoScale (see GCBO)
axess = findobj('Type','axes');
for i=1:length(axess)
    axis(axess(i),'tight');
end

%% T0_Callback - Choix T0 (1er évt Biomécanique)
function T0_Callback(~, eventdata, handles)
% Choix T0 (1er évt Biomécanique)
global haxes1 haxes2 haxes3 haxes4 APA TrialParams TrialParams_N TrialParams_T liste_marche acq_courante h_marks_T0
% hObject    handle fo1 T0 (see GCBO)
pos = matchcells(liste_marche,{acq_courante},'exact');
if ~ismac
    Manual_click = ginput(1);
else
    Manual_click = myginput(1,'crosshair');
end
TrialParams.Trial(pos).EventsTime(2) = Manual_click(1);
efface_marqueur_test(h_marks_T0);
h_marks_T0=affiche_marqueurs(Manual_click(1),'-r');
[~,I] = min(abs(APA.Trial(pos).CG_Speed.Time - TrialParams.Trial(pos).EventsTime(2)));
APA.Trial(pos).CP_Position.Data(1,:) = APA.Trial(pos).CP_Position.Data(1,:) - mean(APA.Trial(pos).CP_Position.Data(1,1:I));
ch = get(haxes1,'children');
set(ch(end),'XData',APA.Trial(pos).CP_Position.Time);
set(ch(end),'YData',APA.Trial(pos).CP_Position.Data(1,:));
APA.Trial(pos).CP_Position.Data(2,:) = APA.Trial(pos).CP_Position.Data(2,:) - mean(APA.Trial(pos).CP_Position.Data(2,1:I));
ch = get(haxes2,'children');
set(ch(end),'XData',APA.Trial(pos).CP_Position.Time);
set(ch(end),'YData',APA.Trial(pos).CP_Position.Data(2,:));
APA.Trial(pos).CG_Speed.Data(3,:) = APA.Trial(pos).CG_Speed.Data(3,:) - APA.Trial(pos).CG_Speed.Data(3,I);
ch = get(haxes4,'children');
set(ch(end),'XData',APA.Trial(pos).CG_Speed.Time);
set(ch(end),'YData',APA.Trial(pos).CG_Speed.Data(3,:));
APA.Trial(pos).CG_Speed.Data(1,:) = APA.Trial(pos).CG_Speed.Data(1,:) - APA.Trial(pos).CG_Speed.Data(1,I);
ch = get(haxes3,'children');
set(ch(end),'XData',APA.Trial(pos).CG_Speed.Time);
set(ch(end),'YData',APA.Trial(pos).CG_Speed.Data(1,:));
Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles);
APA_Vitesses_Callback;
if get(findobj('tag','real_time'),'Value')
    TrialParams_T = TrialParams;
elseif get(findobj('tag','normalized_time'),'Value')
    TrialParams_N = TrialParams;
end
listbox1_Callback(handles.listbox1, eventdata, handles); % on répète pour l'affichage auto après la mise à l'échelle

%% HO_Callback - Choix HO (Heel-Off)
function HO_Callback(~, eventdata, handles)
% Choix HO (Heel-Off)
global TrialParams liste_marche acq_courante h_marks_HO TrialParams_T TrialParams_N
% hObject    handle fo1 HO (see GCBO)
pos = matchcells(liste_marche,{acq_courante},'exact');
if ~ismac
    Manual_click = ginput(1);
else
    Manual_click = myginput(1,'crosshair');
end
TrialParams.Trial(pos).EventsTime(3) = Manual_click(1);
efface_marqueur_test(h_marks_HO);
h_marks_HO=affiche_marqueurs(Manual_click(1),'-k');
Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles);
APA_Vitesses_Callback;
if get(findobj('tag','real_time'),'Value')
    TrialParams_T = TrialParams;
elseif get(findobj('tag','normalized_time'),'Value')
    TrialParams_N = TrialParams;
end
listbox1_Callback(handles.listbox1, eventdata, handles); % on répète pour l'affichage auto après la mise à l'échelle


%% FO1_Callback - Choix FO1 (1st foot off)
function FO1_Callback(~, eventdata, handles)
% Choix FO1 (Toe-Off = Foot Off 1)
global TrialParams liste_marche acq_courante h_marks_FO1 h_marks_Vy_FO1 TrialParams_T TrialParams_N
% hObject    handle fo1 FO1 (see GCBO)
pos = matchcells(liste_marche,{acq_courante},'exact');

if ~ismac
    Manual_click = ginput(1);
else
    Manual_click = myginput(1,'crosshair');
end
TrialParams.Trial(pos).EventsTime(4) = Manual_click(1);
efface_marqueur_test(h_marks_FO1);
efface_marqueur_test(h_marks_Vy_FO1);
h_marks_FO1=affiche_marqueurs(Manual_click(1),'-b');
Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles);
APA_Vitesses_Callback;
if get(findobj('tag','real_time'),'Value')
    TrialParams_T = TrialParams;
elseif get(findobj('tag','normalized_time'),'Value')
    TrialParams_N = TrialParams;
end
listbox1_Callback(handles.listbox1, eventdata, handles); % on répète pour l'affichage auto après la mise à l'échelle

%% Choix FC1 - FC1_Callback
function FC1_Callback(~, eventdata, handles)
% Choix FC1 (Foot-Contact du pied oscillant)
global haxes4 APA TrialParams liste_marche acq_courante h_marks_FC1 h_marks_V2 TrialParams_T TrialParams_N
% hObject    handle fo1 FC1 (see GCBO)
pos = matchcells(liste_marche,{acq_courante},'exact');
if ~ismac
    Manual_click = ginput(1);
else
    Manual_click = myginput(1,'crosshair');
end
TrialParams.Trial(pos).EventsTime(5) = Manual_click(1);
ind = find(APA.Trial(pos).CG_Speed.Time>= Manual_click(1),1,'first') - 1;
efface_marqueur_test(h_marks_FC1);
efface_marqueur_test(h_marks_V2);
h_marks_FC1=affiche_marqueurs(Manual_click(1),'-m');
% Choix sur la courbe intégrée ou dérivée
if get(findobj('tag','V_intgr'),'Value')
    V2 = APA.Trial(pos).CG_Speed.Data(3,ind);
else
    try
        V2 = APA.Trial(pos).CG_Speed_d.Data(3,ind);
    catch ERR
        warndlg('Veuillez cocher une courbe de vitesse!!');
        warning(ERR.identifier,['Veuillez cocher une courbe de vitesse / ' ERR.message])
        V2 = APA.Trial(pos).CG_Speed.Data(3,ind);
    end
end
h_marks_V2 = plot(haxes4,APA.Trial(pos).CG_Speed.Time(ind),V2,'x','Markersize',11);
Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles);
APA_Vitesses_Callback;
if get(findobj('tag','real_time'),'Value')
    TrialParams_T = TrialParams;
elseif get(findobj('tag','normalized_time'),'Value')
    TrialParams_N = TrialParams;
end
listbox1_Callback(handles.listbox1, eventdata, handles); % on répète pour l'affichage auto après la mise à l'échelle

%% FO2_Callback - Choix FO2
function FO2_Callback(~, eventdata, handles)
% Choix FO2 (Foot-Off du pied d'appui)
global TrialParams liste_marche acq_courante h_marks_FO2 TrialParams_T TrialParams_N
% hObject    handle fo1 FO2 (see GCBO)
pos = matchcells(liste_marche,{acq_courante},'exact');
if ~ismac
    Manual_click = ginput(1);
else
    Manual_click = myginput(1,'crosshair');
end
TrialParams.Trial(pos).EventsTime(6) = Manual_click(1);

efface_marqueur_test(h_marks_FO2);
h_marks_FO2=affiche_marqueurs(Manual_click(1),'-g');

Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles);
APA_Vitesses_Callback;
if get(findobj('tag','real_time'),'Value')
    TrialParams_T = TrialParams;
elseif get(findobj('tag','normalized_time'),'Value')
    TrialParams_N = TrialParams;
end
listbox1_Callback(handles.listbox1, eventdata, handles); % on répète pour l'affichage auto après la mise à l'échelle


%% FC2_Callback -  Choix FC2
function FC2_Callback(~, eventdata, handles)
% Choix FC2 (Foot-Contact du pied d'appui)
global TrialParams liste_marche acq_courante h_marks_FC2 TrialParams_T TrialParams_N
% hObject    handle fo1 FC2 (see GCBO)
pos = matchcells(liste_marche,{acq_courante},'exact');
if ~ismac
    Manual_click = ginput(1);
else
    Manual_click = myginput(1,'crosshair');
end
TrialParams.Trial(pos).EventsTime(7) = Manual_click(1);

efface_marqueur_test(h_marks_FC2);
h_marks_FC2=affiche_marqueurs(Manual_click(1),'-c');

Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles);
APA_Vitesses_Callback;
if get(findobj('tag','real_time'),'Value')
    TrialParams_T = TrialParams;
elseif get(findobj('tag','normalized_time'),'Value')
    TrialParams_N = TrialParams;
end
listbox1_Callback(handles.listbox1, eventdata, handles); % on répète pour l'affichage auto après la mise à l'échelle

%% yAPA_AP_Callback - Detection manuelle du déplacement postérieur max du CP lors des APA
function yAPA_AP_Callback(~, eventdata, handles)
% Detection manuelle du déplacement postérieur max du CP lors des APA
global  ResAPA APA TrialParams liste_marche acq_courante
% hObject    handle fo1 yAPA_AP (see GCBO)
pos = matchcells(liste_marche,{acq_courante},'exact');
set(findobj('tag','APA_auto'),'Value',0)
if ~ismac
    Manual_click = ginput(1);
else
    Manual_click = myginput(1,'crosshair');
end

ind = find(APA.Trial(pos).CP_Position.Time>= Manual_click(1),1,'first') - 1;

%Stockage du résultats
ResAPA.Trial(pos).APA_antpost(1:2) = [mean(APA.Trial(pos).CP_Position.Data(1,round(TrialParams.Trial(pos).EventsTime(1)*APA.Trial(pos).CP_Position.Fech):round(TrialParams.Trial(pos).EventsTime(2)*APA.Trial(pos).CP_Position.Fech))) - APA.Trial(pos).CP_Position.Data(1,ind) ind];

Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles);
APA_Vitesses_Callback;

%% yAPA_ML_Callback - Detection valeur minimale/maximale du déplacement médiolatéral du CP lors des APA
function yAPA_ML_Callback(~, eventdata, handles)
global  ResAPA APA TrialParams liste_marche acq_courante
% Detection valeur minimale/maximale du déplacement médiolatéral du CP lors des APA
% hObject    handle fo1 yAPA_ML (see GCBO)
pos = matchcells(liste_marche,{acq_courante},'exact');
set(findobj('tag','APA_auto'),'Value',0)
if ~ismac
    Manual_click = ginput(1);
else
    Manual_click = myginput(1,'crosshair');
end

ind = find(APA.Trial(pos).CP_Position.Time>= Manual_click(1),1,'first') - 1;

%Stockage du résultats
ResAPA.Trial(pos).APA_lateral = [abs(mean(APA.Trial(pos).CP_Position.Data(2,round(TrialParams.Trial(pos).EventsTime(1)*APA.Trial(pos).CP_Position.Fech):round(TrialParams.Trial(pos).EventsTime(2)*APA.Trial(pos).CP_Position.Fech))) - APA.Trial(pos).CP_Position.Data(2,ind))...
    ind];

Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles);
APA_Vitesses_Callback;

%% Vy_FO1_Callback - Détection manuelle de la Vitesse AP du CG lors de FO1
function Vy_FO1_Callback(~, ~, ~)
% Détection manuelle de la Vitesse AP du CG lors de FO1
% global haxes3 Sujet acq_courante h_marks_Vy_FO1
% pos = matchcells(liste_marche,{acq_courante},'exact');
% set(findobj('tag','APA_auto'),'Value',0)
% % hObject    handle fo1 Vy_FO1 (see GCBO)
% % Choix sur la courbe dérivée
% if get(findobj('tag','V_der_Vic'),'Value') && get(findobj('tag','V_der'),'Value') && ~get(findobj('tag','V_intgr'),'Value')
%     if ~ismac
%         Manual_click = ginput(1);
%     else
%         Manual_click = myginput(1,'crosshair');
%     end
%     ind = find(Sujet.(acq_courante).t >= Manual_click(1),1,'first') - 1;
%
%     efface_marqueur_test(h_marks_Vy_FO1);
%     Vy_FO1 = Sujet.(acq_courante).V_CG_AP_d(ind);
%     h_marks_Vy_FO1 = plot(haxes3,Sujet.(acq_courante).t(ind),Vy_FO1,'x','Markersize',11);
%     %Réactualisation de VyFO1 et recalcul des largeur/longueur du pas
%     Sujet.(acq_courante).primResultats.Vy_FO1 = [ind Vy_FO1];
%     %Réactualisation des calculs
%     Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles)
% else
%     waitfor(warndlg('VyFO1 dépend de FO1!!'));
% end
waitfor(warndlg('VyFO1 dépend de FO1!!'));

%% Vm_Callback - Détection manuelle Vitesse max AP du CG
function Vm_Callback(~, eventdata, handles)
% Détection manuelle Vitesse max AP du CG
% hObject    handle fo1 Vm (see GCBO)
global  ResAPA APA  liste_marche acq_courante
pos = matchcells(liste_marche,{acq_courante},'exact');
set(findobj('tag','APA_auto'),'Value',0)
if ~ismac
    Manual_click = ginput(1);
else
    Manual_click = myginput(1,'crosshair');
end

ind = find(APA.Trial(pos).CG_Speed.Time>= Manual_click(1),1,'first') - 1;

% Choix sur la courbe intégrée ou dérivée
if get(findobj('tag','V_intgr'),'Value')
    Vm = APA.Trial(pos).CG_Speed.Data(1,ind);
else
    try
        Vm = APA.Trial(pos).CG_Speed_d.Data(1,ind);
    catch ERR
        warning(ERR.identifier,['Veuillez cocher une courbe de vitesse!!' ERR.message])
        waitfor(warndlg('Veuillez cocher une courbe de vitesse!!'));
        Vm = APA.Trial(pos).CG_Speed.Data(1,ind);
    end
end

% Stockage du résultats
ResAPA.Trial(pos).Vm = [Vm ind];

Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles);
APA_Vitesses_Callback;

%% Vmin_APA_Callback - Détection manuelle Vitesse min verticale du CG lors des APA
function Vmin_APA_Callback(~, eventdata, handles)
% Détection manuelle Vitesse min verticale du CG lors des APA
global  ResAPA APA  liste_marche acq_courante
% hObject    handle fo1 Vmin_APA (see GCBO)
pos = matchcells(liste_marche,{acq_courante},'exact');
set(findobj('tag','APA_auto'),'Value',0)
if ~ismac
    Manual_click = ginput(1);
else
    Manual_click = myginput(1,'crosshair');
end
ind = find(APA.Trial(pos).CG_Speed.Time>= Manual_click(1),1,'first') - 1;

% Choix sur la courbe intégrée ou dérivée
if get(findobj('tag','V_intgr'),'Value')
    Vmin_APA = APA.Trial(pos).CG_Speed.Data(3,ind);
else
    try
        Vmin_APA = APA.Trial(pos).CG_Speed_d.Data(3,ind);
    catch ERR
        warning(ERR.identifier,['Veuillez cocher une courbe de vitesse!!' ERR.message])
        waitfor(warndlg(['Veuillez cocher une courbe de vitesse!!' ERR]));
        Vmin_APA = APA.Trial(pos).CG_Speed.Data(3,ind);
    end
end

% Stockage du résultats
ResAPA.Trial(pos).VZmin_APA = [Vmin_APA ind];

Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles);
APA_Vitesses_Callback;

%% V1_Callback - Détection manuelle du 1er min de la Vitesse vertciale du CG lors de l'éxecution du pas
function V1_Callback(~, eventdata, handles)
% Détection manuelle du 1er min de la Vitesse vertciale du CG lors de l'éxecution du pas
global ResAPA APA  liste_marche acq_courante
% hObject    handle fo1 V1 (see GCBO)
pos = matchcells(liste_marche,{acq_courante},'exact');
set(findobj('tag','APA_auto'),'Value',0)
if ~ismac
    Manual_click = ginput(1);
else
    Manual_click = myginput(1,'crosshair');
end
ind = find(APA.Trial(pos).CG_Speed.Time>= Manual_click(1),1,'first') - 1;

% Choix sur la courbe intégrée ou dérivée
if get(findobj('tag','V_intgr'),'Value')
    V1 = APA.Trial(pos).CG_Speed.Data(3,ind);
else
    try
        V1 = APA.Trial(pos).CG_Speed_d.Data(3,ind);
    catch ERR
        warning(ERR.identifier,['Veuillez cocher une courbe de vitesse!!' ERR.message])
        waitfor(warndlg(['Veuillez cocher une courbe de vitesse!!' ERR]));
        V1 = APA.Trial(pos).CG_Speed.Data(3,ind);
    end
end

% Stockage du résultats
ResAPA.Trial(pos).V1 = [V1 ind];

Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles);
APA_Vitesses_Callback;

%% V2_Callback - Détection manuelle de la Vitesse vertciale du CG lors du FC1
function V2_Callback(~, ~, ~)
% Détection manuelle de la Vitesse vertciale du CG lors du FC1
% global ResAPA APA  liste_marche acq_courante
% Choix sur la courbe dérivée
% if get(findobj('tag','V_der'),'Value')
%     if ~ismac
%         Manual_click = ginput(1);
%     else
%         Manual_click = myginput(1,'crosshair');
%     end
%     %ind = round(Manual_click(1)*Sujet.(acq_courante).Fech)+1;
%     ind = find(Sujet.(acq_courante).t >= Manual_click(1),1,'first') - 1;
%
%     efface_marqueur_test(h_marks_V2);
%     V2 = Sujet.(acq_courante).V_CG_Z_d(ind);
%     h_marks_V2 = plot(haxes4,Sujet.(acq_courante).t(ind),V2,'x','Markersize',11,'Color','m','Linewidth',1.5);
%     %Réactualisation de VyFO1 et recalcul des largeur/longueur du pas
%     Sujet.(acq_courante).primResultats.V2 = [ind V2];
%     %Réactualisation des calculs
%     Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles)
% else
%     waitfor(warndlg('V2 dépend de FC1!!'));
% end
waitfor(warndlg('V2 dépend de FC1!!'));

%% Markers_Callback - Affichage des marqueurs de l'acquisition courante/sélectionnée
function Markers_Callback(~, ~, ~)
% Affichage des marqueurs de l'acquisition courante/sélectionnée
global haxes1 TrialParams liste_marche acq_courante h_marks_T0 h_marks_HO h_marks_FO1 h_marks_FC1 h_marks_FO2 h_marks_FC2  ...
    h_marks_Trig h_trig_txt h_marks_FOG h_FOG_txt
% hObject    handle fo1 Markers (see GCBO)

%Nettoyage des axes d'abord (??Laisser si Multiplot On??)
efface_marqueur_test(h_marks_T0);
efface_marqueur_test(h_marks_HO);
efface_marqueur_test(h_marks_FO1);
efface_marqueur_test(h_marks_FC1);
efface_marqueur_test(h_marks_FO2);
efface_marqueur_test(h_marks_FC2);

efface_marqueur_test(h_marks_Trig);
efface_marqueur_test(h_trig_txt);
efface_marqueur_test(h_marks_FOG);
efface_marqueur_test(h_FOG_txt);

ind_acq = matchcells(liste_marche,{acq_courante},'exact');

%Actualisation des marqueurs
h_marks_T0 = affiche_marqueurs(TrialParams.Trial(ind_acq).EventsTime(2),'-r');
h_marks_HO = affiche_marqueurs(TrialParams.Trial(ind_acq).EventsTime(3),'-k');
h_marks_FO1 = affiche_marqueurs(TrialParams.Trial(ind_acq).EventsTime(4),'-b');
h_marks_FC1 = affiche_marqueurs(TrialParams.Trial(ind_acq).EventsTime(5),'-m');
h_marks_FO2 = affiche_marqueurs(TrialParams.Trial(ind_acq).EventsTime(6),'-g');
h_marks_FC2 = affiche_marqueurs(TrialParams.Trial(ind_acq).EventsTime(7),'-c');

%Affichage du trigger externe (si existe) et si pas trop éloigné
if ~isnan(TrialParams.Trial(ind_acq).EventsTime(1))
    h_marks_Trig = affiche_marqueurs(TrialParams.Trial(ind_acq).EventsTime(1),'*-k');
    h_trig_txt = text(TrialParams.Trial(ind_acq).EventsTime(1),1000,'GO/Trigger',...
        'VerticalAlignment','middle',...
        'HorizontalAlignment','left',...
        'FontSize',8,...
        'Parent',haxes1);
end

%Activation des boutons de modification manuelle des marqueurs
set(findobj('tag','T0'),'Visible','On');
set(findobj('tag','HO'),'Visible','On');
set(findobj('tag','FO1'),'Visible','On');
set(findobj('tag','FC1'),'Visible','On');
set(findobj('tag','FO2'),'Visible','On');
set(findobj('tag','FC2'),'Visible','On');

%% Vitesses_Callback - Affichage des pics de Vitesse déjà calculés
function APA_Vitesses_Callback(~, ~, ~)
% Affichage des pics de Vitesse déjà calculés
global haxes1 haxes2 haxes3 haxes4 APA ResAPA TrialParams liste_marche acq_courante h_marks_APA_antpost h_marks_APA_lateral h_marks_Vy_FO1 h_marks_Vm h_marks_VZ_min h_marks_V1 h_marks_V2
% hObject    handle fo1 Vitesses (see GCBO)

pos = matchcells(liste_marche,{acq_courante},'exact');

%Nettoyage des axes d'abord (??Laisser si Multiplot On??)
efface_marqueur_test(h_marks_APA_antpost);
efface_marqueur_test(h_marks_APA_lateral);
efface_marqueur_test(h_marks_Vy_FO1);
efface_marqueur_test(h_marks_Vm);
efface_marqueur_test(h_marks_VZ_min);
efface_marqueur_test(h_marks_V1);
efface_marqueur_test(h_marks_V2);

axess = findobj('Type','axes');
for i=1:length(axess)
    set(axess(i),'NextPlot','add'); % Multiplot On
end

% Calcul du décalage temporel (pour si trigger décalé)
Time_offset = TrialParams.Trial(pos).EventsTime(1);

%Affichage des APA et vitesses
try
    h_marks_APA_antpost = plot(haxes1,TrialParams.Trial(pos).EventsTime(1)+APA.Trial(pos).CP_Position.Time(ResAPA.Trial(pos).APA_antpost(2)),APA.Trial(pos).CP_Position.Data(1,ResAPA.Trial(pos).APA_antpost(2)+TrialParams.Trial(pos).EventsTime(1)*APA.Trial(pos).CP_Position.Fech),'x','Markersize',11,'Color','b');
    h_marks_APA_lateral = plot(haxes2,TrialParams.Trial(pos).EventsTime(1)+APA.Trial(pos).CP_Position.Time(ResAPA.Trial(pos).APA_lateral(2)),APA.Trial(pos).CP_Position.Data(2,ResAPA.Trial(pos).APA_lateral(2)+TrialParams.Trial(pos).EventsTime(1)*APA.Trial(pos).CP_Position.Fech),'x','Markersize',11,'Color','c');
catch NO_APA
    warning(NO_APA.identifier,['NO_APA' NO_APA.message])
end

try % Vt à FO1
    h_marks_Vy_FO1 = plot(haxes3,APA.Trial(pos).CG_Speed.Time(round(ResAPA.Trial(pos).Vy_FO1(2)+TrialParams.Trial(pos).EventsTime(1)*APA.Trial(pos).CP_Position.Fech)),ResAPA.Trial(pos).Vy_FO1(1),'x','Markersize',11,'color',[0.85 0.326 0.098]);
catch ERR_FO1
    warning(ERR_FO1.identifier,['ERR_FO1' ERR_FO1.message])
end

try
    h_marks_Vm = plot(haxes3,APA.Trial(pos).CG_Speed.Time(ResAPA.Trial(pos).Vm(2)+TrialParams.Trial(pos).EventsTime(1)*APA.Trial(pos).CP_Position.Fech),ResAPA.Trial(pos).Vm(1),'x','Markersize',11,'Color','r','Linewidth',1.5);
catch ERR_Vm
    warning(ERR_Vm.identifier,['ERR_Vm' ERR_Vm.message])
end

try
    h_marks_VZ_min = plot(haxes4,APA.Trial(pos).CG_Speed.Time(ResAPA.Trial(pos).VZmin_APA(2)+TrialParams.Trial(pos).EventsTime(1)*APA.Trial(pos).CP_Position.Fech),ResAPA.Trial(pos).VZmin_APA(1),'x','Markersize',11,'Color','k');
catch ERR_Vz_min
    warning(ERR_Vz_min.identifier,['ERR_Vz_min' ERR_Vz_min.message])
end

try
    h_marks_V1 = plot(haxes4,APA.Trial(pos).CG_Speed.Time(ResAPA.Trial(pos).V1(2)+TrialParams.Trial(pos).EventsTime(1)*APA.Trial(pos).CP_Position.Fech),ResAPA.Trial(pos).V1(1),'x','Markersize',11,'Color','r','Linewidth',1.25);
catch ERR_V1
    warning(ERR_V1.identifier,['ERR_V1' ERR_V1.message])
end

try
    h_marks_V2 = plot(haxes4,APA.Trial(pos).CG_Speed.Time(ResAPA.Trial(pos).V2(2)+TrialParams.Trial(pos).EventsTime(1)*APA.Trial(pos).CP_Position.Fech),ResAPA.Trial(pos).V2(1),'x','Markersize',11,'Color','m','Linewidth',1.5);
catch ERR_V2
    warning(ERR_V2.identifier,['ERR_V2' ERR_V2.message])
end

%Activation des bouton de modification manuelle des vitesses
set(findobj('tag','yAPA_AP'),'Visible','On');
set(findobj('tag','yAPA_ML'),'Visible','On');
set(findobj('tag','Vy_FO1'),'Visible','On');
set(findobj('tag','Vm'),'Visible','On');
set(findobj('tag','Vmin_APA'),'Visible','On');
set(findobj('tag','V1'),'Visible','On');

set(findobj('tag','V_der'),'Visible','On');
set(findobj('tag','V_der_Vic'),'Visible','On');
set(findobj('tag','V_intgr'),'Visible','On');

%% Calc_current_Callback - Calculs des APA sur l'acquisition selectionnée
function Calc_current_Callback(~, ~, ~)
% Calculs des APA sur l'acquisition selectionnée
% hObject    handle fo1 Calc_current (see GCBO)
global APA ResAPA TrialParams liste_marche acq_courante

pos = matchcells(liste_marche,{acq_courante},'exact');

if get(findobj('tag','APA_auto'),'Value')
    ResAPA.Trial(pos) = calcul_auto_APA_marker_v2(APA.Trial(pos),TrialParams.Trial(pos),ResAPA.Trial(pos));
end
ResAPA.Trial(pos) = calculs_parametres_initiationPas_v5(APA.Trial(pos),TrialParams.Trial(pos),ResAPA.Trial(pos));
%Affichage
affiche_resultat_APA(ResAPA.Trial(pos));

function CR = affiche_resultat_APA(Acq)
%% Mise à jour des resultats sur le tableau d'affichage

% if isfield(Acq,'primResultats') %% Si les calculs n'ont pas été
%     Acq = calculs_parametres_initiationPas_v1(Acq);
% end

param = fieldnames(Acq);
CR=cell(length(param),2);
for i=1:length(param)
    CR{i,1} = param{i};
    try
        if ischar(Acq.(param{i}))
            CR{i,2} = Acq.(param{i});
        elseif isnumeric(Acq.(param{i}))
            CR{i,2} = Acq.(param{i})(1);
        end
    catch
    end
end
set(findobj('tag','Results'),'Data',CR);

%% Calc_batch_Callback - Calculs des APA sur toutes les acquisitions
function Calc_batch_Callback(~, ~, ~)
% Calculs des APA sur toutes les acquisitions
% hObject    handle fo1 Calc_batch (see GCBO)
global APA ResAPA TrialParams liste_marche

% Calculs
wb = waitbar(0);
set(wb,'Name','Please wait... Calculating data');

for i=1:length(liste_marche)
    waitbar(i/length(liste_marche),wb,['Calcul acquisition: ' liste_marche{i}]);
    try
        if get(findobj('tag','APA_auto'),'Value')
            ResAPA.Trial(i) = calcul_auto_APA_marker_v2(APA.Trial(i),TrialParams.Trial(i),ResAPA.Trial(i));
        end
        ResAPA.Trial(i) = calculs_parametres_initiationPas_v5(APA.Trial(i),TrialParams.Trial(i),ResAPA.Trial(i));
    catch No_data
        warning(No_data.identifier,['Erreur calcul : ' liste_marche{i} ' / ' No_data.message])
    end
end
close(wb);

%% V_der_Callback - Etat d'affichage de la vitesse obtenue par dérivation
function V_der_Callback(hObject, ~, ~)
% Etat d'affichage de la vitesse obtenue par dérivation
global haxes3 haxes4 APA liste_marche acq_courante flag_afficheV
% hObject    handle fo1 V_der (see GCBO)
% Hint: get(hObject,'Value') returns toggle state of V_der
pos = matchcells(liste_marche,{acq_courante},'exact');
flags_V = [get(findobj('tag','V_intgr'),'Value') get(findobj('tag','V_der'),'Value') get(findobj('tag','V_der_Vic'),'Value')];
flag_afficheV = sum(flags_V); %Flag d'affichage
if get(hObject,'Value')
    if flag_afficheV==2
        set(haxes3,'Nextplot','add');
        set(haxes4,'Nextplot','add');
    end
    if isfield(APA.Trial(pos),'CG_Speed_d')
        plot(haxes3,APA.Trial(pos).CG_Speed_d.Time,APA.Trial(pos).CG_Speed_d.Data(1,:),'r-');
        plot(haxes4,APA.Trial(pos).CG_Speed_d.Time,APA.Trial(pos).CG_Speed_d.Data(3,:),'r-');
    else
        disp('Pas de vitesse calculée à partir de la dérivé du CoM')
    end
end

%% V_der_VICON_Callback - Etat d'affichage de la vitesse obtenue par dérivation pour le CG de VICON
function V_der_VICON_Callback(hObject, ~, ~)
% Etat d'affichage de la vitesse obtenue par dérivation pour le CG de VICON
global haxes3 haxes4 APA liste_marche acq_courante flag_afficheV
% hObject    handle fo1 V_der (see GCBO)
% Hint: get(hObject,'Value') returns toggle state of V_der
pos = matchcells(liste_marche,{acq_courante},'exact');
flags_V = [get(findobj('tag','V_intgr'),'Value') get(findobj('tag','V_der'),'Value') get(findobj('tag','V_der_Vic'),'Value')];
flag_afficheV = sum(flags_V); %Flag d'affichage
if get(hObject,'Value')
    if flag_afficheV==2
        set(haxes3,'Nextplot','add');
        set(haxes4,'Nextplot','add');
    end
    if isfield(APA.Trial(pos),'CG_Speed_d_VIC')
        plot(haxes3,APA.Trial(pos).CG_Speed_d_VIC.Time,APA.Trial(pos).CG_Speed_d_VIC.Data(1,:),'r-');
        plot(haxes4,APA.Trial(pos).CG_Speed_d_VIC.Time,APA.Trial(pos).CG_Speed_d_VIC.Data(3,:),'r-');
    else
        disp('Pas de vitesse calculée à partir de la dérivé du CoM_VICON')
    end
end

%% V_intgr_Callback - Etat d'affichage de la vitesse obtenue par intégration
function V_intgr_Callback(hObject, ~, ~)
% Etat d'affichage de la vitesse obtenue par intégration
global haxes3 haxes4 APA liste_marche acq_courante flag_afficheV
% hObject    handle fo1 V_intgr (see GCBO)
% Hint: get(hObject,'Value') returns toggle state of V_intgr
pos = matchcells(liste_marche,{acq_courante},'exact');
flags_V = [get(findobj('tag','V_intgr'),'Value') get(findobj('tag','V_der'),'Value') get(findobj('tag','V_der_Vic'),'Value')];
flag_afficheV = sum(flags_V); %Flag d'affichage
if get(hObject,'Value')
    if flag_afficheV==2
        set(haxes3,'Nextplot','add');
        set(haxes4,'Nextplot','add');
    end
    if isfield(APA.Trial(pos),'CG_Speed')
        plot(haxes3,APA.Trial(pos).CG_Speed.Time,APA.Trial(pos).CG_Speed.Data(1,:),'b-');
        plot(haxes4,APA.Trial(pos).CG_Speed.Time,APA.Trial(pos).CG_Speed.Data(3,:),'b-');
    else
        disp('Pas de vitesse calculée à partir de la dérivé du CoM_VICON')
    end
end

%% Clean_data_Callback - Nettoyage des données en éliminant manuellement les mauvaises acquisitions
function Clean_data_Callback(~, ~, ~)
% Nettoyage des données en éliminant manuellement les mauvaises acquisitions
global APA TrialParams liste_marche clean
% hObject    handle fo1 Clean_data (see GCBO)

%Extraction des acquisitions sur la liste
% listes_acqs = filednames(Sujet);

%Sélections de l'utilisateur
[ind_acq,~] = listdlg('PromptString',{'Nettoyage données','Choix des acquisitions à vérifier'},...
    'ListSize',[300 300],...
    'ListString',liste_marche);

%Affichage dans une nouvelle fenêtre contrôlable (clean)
clean=figure;
c=uicontextmenu('Parent',clean);
cb1 = 'mouse_actions_APA(''identify'')';
cb2 = 'mouse_actions_APA(''gait_suppression'')';
uimenu(c, 'Label', 'Repérer/déséléctionner acquisition', 'Callback',cb1);
uimenu(c, 'Label', 'Supprimer marche', 'Callback',cb2);

%Création des fenêtres
h1 = subplot(411); hold on
ylabel('Déplacement CP AP (mm)');
h2 = subplot(412); hold on
ylabel('Déplacement CP ML (mm)');
h3 = subplot(413); hold on
ylabel('Vitesse CG AP (m/sec)');
h4 = subplot(414); hold on
ylabel('Vitesse CG verticale (m/sec)');

%Chargement des acquisitions et affichage dans la fenêtre de contrôle
acqs = liste_marche(ind_acq);
try
    for i = 1:length(acqs)
        tags = extract_tags(acqs{i});
        
        if ~strcmp(tags(end),'KO')
            endFC2 = round(TrialParams.Trial(ind_acq(i)).EventsTime(7)*(APA.Trial(ind_acq(i)).CP_Position.Fech));
            try
                plot(h1,APA.Trial(ind_acq(i)).CP_Position.Data(1,1:endFC2),'ButtonDownFcn',@maselection,'uicontextmenu',c,'displayname',acqs{i});
                plot(h2,APA.Trial(ind_acq(i)).CP_Position.Data(2,1:endFC2),'ButtonDownFcn',@maselection,'uicontextmenu',c,'displayname',acqs{i});
                plot(h3,APA.Trial(ind_acq(i)).CG_Speed.Data(1,1:endFC2),'ButtonDownFcn',@maselection,'uicontextmenu',c,'displayname',acqs{i});
                plot(h4,APA.Trial(ind_acq(i)).CG_Speed.Data(3,1:endFC2),'ButtonDownFcn',@maselection,'uicontextmenu',c,'displayname',acqs{i});
            catch FC2_far
                warning(FC2_far.identifier,'%s',FC2_far.message)
                plot(h1,APA.Trial(ind_acq(i)).CP_Position.Data(1,:),'ButtonDownFcn',@maselection,'uicontextmenu',c,'displayname',acqs{i});
                plot(h2,APA.Trial(ind_acq(i)).CP_Position.Data(2,:),'ButtonDownFcn',@maselection,'uicontextmenu',c,'displayname',acqs{i});
                plot(h3,APA.Trial(ind_acq(i)).CG_Speed.Data(1,:),'ButtonDownFcn',@maselection,'uicontextmenu',c,'displayname',acqs{i});
                plot(h4,APA.Trial(ind_acq(i)).CG_Speed.Data(3,:),'ButtonDownFcn',@maselection,'uicontextmenu',c,'displayname',acqs{i});
            end
        end
    end
    %On retire les mauvaises acquisitions de la variable Sujet et on remet à jour la liste et la variable Resultats
    msgbox('Cliquez sur les courbes/acquisitions à retirer (click droit pour déséléctionner) - puis appuyer sur OK');
catch ERR
    warning(ERR.identifier,['Une seule acquisition chargée / ' ERR.message])
    warndlg(['!!Une seule acquisition chargée!!' ERR]);
end

%% Automatik_display_Callback
function Automatik_display_Callback(~, ~, ~)
% hObject    handle fo1 Automatik_display (see GCBO)
% Hint: get(hObject,'Value') returns toggle state of Automatik_display

%% Test_APA_v4_ResizeFcn
function Test_APA_v4_ResizeFcn(~, ~, ~)
% hObject    handle fo1 Calc_APA_v6 (see GCBO)
% eventdata  reserved - fo1 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Normalisation temporelle des données
function normalise_time(~, eventdata, handles)

global APA TrialParams APA_T TrialParams_T APA_N TrialParams_N

champs = fieldnames(APA_T.Trial(1));
APA_N = APA_T;
TrialParams_N = TrialParams_T;
for i_champs = 1 : length(champs)
    for i = 1 : length(APA_N.Trial)
        
        if ~isempty(APA_T.Trial(i).(champs{i_champs}).Data) &&  ...
                any(APA_T.Trial(i).(champs{i_champs}).Data(~isnan(APA_T.Trial(i).(champs{i_champs}).Data))~=0)
            try
                [APA_N.Trial(i).(champs{i_champs}),TrialParams_N.Trial(i)] = Normalise_APA_signal(APA_T.Trial(i).(champs{i_champs}),TrialParams_T.Trial(i));
            catch
                APA_N.Trial(i).(champs{i_champs}) = APA_T.Trial(i).(champs{i_champs});
                APA_N.Trial(i).(champs{i_champs}).Data = zeros(size(APA_N.Trial(i).(champs{i_champs}).Data,1),401);
                APA_N.Trial(i).(champs{i_champs}).Time = 1:size(APA_N.Trial(i).(champs{i_champs}).Data,2);
            end
        else
            APA_N.Trial(i).(champs{i_champs}) = APA_T.Trial(i).(champs{i_champs});
            APA_N.Trial(i).(champs{i_champs}).Data = zeros(size(APA_N.Trial(i).(champs{i_champs}).Data,1),401);
            APA_N.Trial(i).(champs{i_champs}).Time = 1:size(APA_N.Trial(i).(champs{i_champs}).Data,2);
        end
    end
end

set(findobj('tag','normalized_time'),'Visible','on')
set(findobj('tag','real_time'),'Visible','on')
set(findobj('tag','normalized_time'),'Enable','on')
set(findobj('tag','real_time'),'Enable','on')

set(findobj('Tag','real_time'), 'Value',0);
set(findobj('Tag','normalized_time'), 'Value',1);

APA  = APA_N;
TrialParams = TrialParams_N;
listbox1_Callback(handles.listbox1, eventdata, handles)


%% Group_APA_Callback - Moyennage des acquisitions sélectionnées et stockage dans une variable acquisition (Corridors)
function Group_APA_Callback
% Moyennage des acquisitions sélectionnées et stockage dans une variable acquisition (Corridors)
global APA TrialParams APA_Corr TrialParams_Corr liste_marche

% hObject    handle fo1 Group_APA (see GCBO)

%Choix du nom de la moyenne
tag_groupe = cell2mat(inputdlg('Entrez le nom du groupe d''acquisitions','Calcul corridor Moyen',1,{APA.Infos.FileName}));

%Sélections de l'utilisateur
try
    APA_Corr.Infos = APA.Infos;
    TrialParams_Corr.Infos = TrialParams.Infos;
    
    champs = fieldnames(APA.Trial(1));
    for i_champs = 1 : length(champs)
        clear temp Data_moy
        dim_max = max(arrayfun(@(i) size(APA.Trial(i).(champs{i_champs}).Time,2),1:length(liste_marche),'uni',1));
        for j_trial = 1 : length(liste_marche)
            APA.Trial(j_trial).(champs{i_champs}).Data = cat(2,APA.Trial(j_trial).(champs{i_champs}).Data,...
                nan(size(APA.Trial(j_trial).(champs{i_champs}).Data,1),dim_max - size(APA.Trial(j_trial).(champs{i_champs}).Data,2)));
            APA.Trial(j_trial).(champs{i_champs}).Time = cat(2,APA.Trial(j_trial).(champs{i_champs}).Time,...
                nan(1,dim_max - size(APA.Trial(j_trial).(champs{i_champs}).Time,2)));
            if matchcell(champs(i_champs),{'CP_Position'})
                if matchcell({TrialParams.Trial(j_trial).StartingFoot},{'left'})
                    signe = -1;
                else
                    signe = 1;
                end
                APA.Trial(j_trial).(champs{i_champs}).Data(2,:) = signe*APA.Trial(j_trial).(champs{i_champs}).Data(2,:);
            end
            
        end
        temp = arrayfun(@(i) APA.Trial(i).(champs{i_champs}).Data,1:length(liste_marche),'uni',0);
        Data_moy(:,:,1) = nanmean(cat(3,temp{:}),3);
        Data_moy(:,:,2) = nanmean(cat(3,temp{:}),3) + nanstd(cat(3,temp{:}),[],3);
        Data_moy(:,:,3) = nanmean(cat(3,temp{:}),3) - nanstd(cat(3,temp{:}),[],3);
        
        %Stockage
        for j = 1:3
            APA_Corr.Trial(j).(champs{i_champs}) = Signal(Data_moy(:,:,j),APA.Trial(1).(champs{i_champs}).Fech,...
                'time',(1:size(Data_moy(:,:,j),2))/APA.Trial(1).(champs{i_champs}).Fech,...
                'tag',APA.Trial(1).(champs{i_champs}).Tag,...
                'units',APA.Trial(1).(champs{i_champs}).Units,...
                'TrialNum',0,...
                'TrialName',tag_groupe);
        end
    end
    
    clear Data_moy temp
    temp = arrayfun(@(i) TrialParams.Trial(i).EventsTime,1:length(liste_marche),'uni',0);
    Data_moy(:,:,1) = nanmean(cat(1,temp{:}),1);
    Data_moy(:,:,2) = nanmean(cat(1,temp{:}),1) + nanstd(cat(1,temp{:}),[],1);
    Data_moy(:,:,3) = nanmean(cat(1,temp{:}),1) - nanstd(cat(1,temp{:}),[],1);
    for i = 1:3
        TrialParams_Corr.Trial(i) = TrialParams.Trial(1);
        TrialParams_Corr.Trial(i).EventsTime = Data_moy(:,:,i);
        TrialParams_Corr.Trial(i).TrialNum = 0;
        TrialParams_Corr.Trial(i).TrialName = tag_groupe;
    end
    
    %Affichage
    set(findobj('tag','Affich_corridor'), 'Visible','On');
    set(findobj('tag','Affich_corridor'), 'Enable','On');
    set(findobj('tag','Corridors_add'), 'Enable','On');
    set(findobj('tag','Clean_corridor'), 'Visible','On');
    set(findobj('tag','Clean_corridor'), 'Enable','On');
    set(findobj('tag','Affich_corridor'), 'Value',1);
    if  get(findobj('tag','Affich_corridor'),'Value')
        Affich_corridor_Callback;
    end
catch ERR
    warning(ERR.identifier,['Arret création groupe / ' ERR.message])
    warndlg('Arret création groupe');
end

%% Affich_corridor_Callback - Affichage des corridors pour les données brutes
% --- Executes on button press in Affich_corridor.
function [corr1, corr2, corr3, corr4, handle_corr1, handle_corr2, handle_corr3, handle_corr4 ] = Affich_corridor_Callback(corr1)
% Affichage des corridors pour les données brutes
global haxes1 haxes2 haxes3 haxes4 Aff_corr ...
    APA_Corr TrialParams_Corr h_marks_T0_C h_marks_HO_C h_marks_FO1_C h_marks_FC1_C h_marks_FO2_C h_marks_FC2_C
% hObject    handle fo1 Affich_corridor (see GCBO)

try
    if ~isempty(APA_Corr) && isempty(findobj('tag','Corr1_L'))
        
        set(gcf,'CurrentAxes',haxes1)
        set(gca,'NextPlot','replace')
        if Aff_corr == 1
            set(gca,'NextPlot','add')
        end
        corr1 = plot(haxes1,APA_Corr.Trial(1).CP_Position.Time,APA_Corr.Trial(1).CP_Position.Data(1,:),'Linewidth',2,'Color',[0 0 1],'Tag','Corr1_L'); axis(haxes1,'tight');
        t = APA_Corr.Trial(1).CP_Position.Time;
        N=[t';t'];
        T=[APA_Corr.Trial(3).CP_Position.Data(1,:)';APA_Corr.Trial(2).CP_Position.Data(1,:)'];
        Noeuds=[N,T];
        P=[(1:length(t)-1)',(2:length(t))',(length(t)+2:length(t)*2)',(length(t)+1:length(t)*2-1)'];
        handle_corr1=patch(...
            'Vertices',Noeuds,...
            'faces',P,...
            'facecolor',[0 0 1],...
            'edgecolor','none',...
            'FaceAlpha',0.3,...
            'Tag','Corr1_P');
        
        set(gcf,'CurrentAxes',haxes2)
        set(gca,'NextPlot','replace')
        if Aff_corr == 1
            set(gca,'NextPlot','add')
        end
        corr2 = plot(haxes2,APA_Corr.Trial(1).CP_Position.Time,APA_Corr.Trial(1).CP_Position.Data(2,:),'Linewidth',2,'Color',[0 0 1],'Tag','Corr2_L'); axis(haxes2,'tight');
        t = APA_Corr.Trial(1).CP_Position.Time;
        N=[t';t'];
        T=[APA_Corr.Trial(3).CP_Position.Data(2,:)';APA_Corr.Trial(2).CP_Position.Data(2,:)'];
        Noeuds=[N,T];
        P=[(1:length(t)-1)',(2:length(t))',(length(t)+2:length(t)*2)',(length(t)+1:length(t)*2-1)'];
        handle_corr2=patch(...
            'Vertices',Noeuds,...
            'faces',P,...
            'facecolor',[0 0 1],...
            'edgecolor','none',...
            'FaceAlpha',0.3,...
            'Tag','Corr2_P');
        
        set(gcf,'CurrentAxes',haxes3)
        set(gca,'NextPlot','replace')
        if Aff_corr == 1
            set(gca,'NextPlot','add')
        end
        corr3 = plot(haxes3,APA_Corr.Trial(1).CG_Speed.Time,APA_Corr.Trial(1).CG_Speed.Data(1,:),'Linewidth',2,'Color',[0 0 1],'Tag','Corr3_L'); axis(haxes2,'tight');
        t = APA_Corr.Trial(1).CG_Speed.Time;
        N=[t';t'];
        T=[APA_Corr.Trial(3).CG_Speed.Data(1,:)';APA_Corr.Trial(2).CG_Speed.Data(1,:)'];
        Noeuds=[N,T];
        P=[(1:length(t)-1)',(2:length(t))',(length(t)+2:length(t)*2)',(length(t)+1:length(t)*2-1)'];
        handle_corr3=patch(...
            'Vertices',Noeuds,...
            'faces',P,...
            'facecolor',[0 0 1],...
            'edgecolor','none',...
            'FaceAlpha',0.3,...
            'Tag','Corr3_P');
        
        set(gcf,'CurrentAxes',haxes4)
        set(gca,'NextPlot','replace')
        if Aff_corr == 1
            set(gca,'NextPlot','add')
        end
        corr4 = plot(haxes4,APA_Corr.Trial(1).CG_Speed.Time,APA_Corr.Trial(1).CG_Speed.Data(3,:),'Linewidth',2,'Color',[0 0 1],'Tag','Corr4_L'); axis(haxes2,'tight');
        t = APA_Corr.Trial(1).CG_Speed.Time;
        N=[t';t'];
        T=[APA_Corr.Trial(3).CG_Speed.Data(3,:)';APA_Corr.Trial(2).CG_Speed.Data(3,:)'];
        Noeuds=[N,T];
        P=[(1:length(t)-1)',(2:length(t))',(length(t)+2:length(t)*2)',(length(t)+1:length(t)*2-1)'];
        handle_corr4=patch(...
            'Vertices',Noeuds,...
            'faces',P,...
            'facecolor',[0 0 1],...
            'edgecolor','none',...
            'FaceAlpha',0.3,...
            'Tag','Corr4_P');
        
        %Actualisation des marqueurs
        h_marks_T0_C = affiche_marqueurs(TrialParams_Corr.Trial(1).EventsTime(2),'--r');
        h_marks_HO_C = affiche_marqueurs(TrialParams_Corr.Trial(1).EventsTime(3),'--k');
        h_marks_FO1_C = affiche_marqueurs(TrialParams_Corr.Trial(1).EventsTime(4),'--b');
        h_marks_FC1_C = affiche_marqueurs(TrialParams_Corr.Trial(1).EventsTime(5),'--m');
        h_marks_FO2_C = affiche_marqueurs(TrialParams_Corr.Trial(1).EventsTime(6),'--g');
        h_marks_FC2_C = affiche_marqueurs(TrialParams_Corr.Trial(1).EventsTime(7),'--c');
        
        set(haxes1,'ButtonDownFcn',@(hObject, eventdata)Calc_APA_v6('graph_zoom',hObject, eventdata,guidata(hObject)));
        set(haxes2,'ButtonDownFcn',@(hObject, eventdata)Calc_APA_v6('graph_zoom',hObject, eventdata,guidata(hObject)));
        set(haxes3,'ButtonDownFcn',@(hObject, eventdata)Calc_APA_v6('graph_zoom',hObject, eventdata,guidata(hObject)));
        set(haxes4,'ButtonDownFcn',@(hObject, eventdata)Calc_APA_v6('graph_zoom',hObject, eventdata,guidata(hObject)));
        Aff_corr = 1;
        
    else
        if Aff_corr == 1;
            Aff_corr = 0;
            set(findobj('tag','Corr1_L'),'Visible','off');
            set(findobj('tag','Corr1_P'),'Visible','off');
            set(findobj('tag','Corr2_L'),'Visible','off');
            set(findobj('tag','Corr2_P'),'Visible','off');
            set(findobj('tag','Corr3_L'),'Visible','off');
            set(findobj('tag','Corr3_P'),'Visible','off');
            set(findobj('tag','Corr4_L'),'Visible','off');
            set(findobj('tag','Corr4_P'),'Visible','off');
        elseif Aff_corr == 0;
            Aff_corr = 1;
            set(findobj('tag','Corr1_L'),'Visible','on');
            set(findobj('tag','Corr1_P'),'Visible','on');
            set(findobj('tag','Corr2_L'),'Visible','on');
            set(findobj('tag','Corr2_P'),'Visible','on');
            set(findobj('tag','Corr3_L'),'Visible','on');
            set(findobj('tag','Corr3_P'),'Visible','on');
            set(findobj('tag','Corr4_L'),'Visible','on');
            set(findobj('tag','Corr4_P'),'Visible','on');
        end
        
    end
catch ERR
    waitfor(warndlg('!!!Pas de corridors calculés/sélectionnés!!!'));
    warning(ERR.identifier,'%s',ERR.message)
end

%% Delete_current_Callback
% --- Executes on button press in Delete_current.
function Delete_current_Callback(~, ~, ~)
global APA ResAPA TrialParams liste_marche acq_courante
% hObject    handle fo1 Delete_current (see GCBO)
pos = matchcells(liste_marche,{acq_courante},'exact');

%Supression de l'acquisition séléctionné
if isfield(APA,'removedTrials')
    APA.removedTrials = [APA.removedTrials,APA.Trial(pos)];
    ResAPA.removedTrials = [ResAPA.removedTrials,ResAPA.Trial(pos)];
    TrialParams.removedTrials = [TrialParams.removedTrials,TrialParams.Trial(pos)];
else
    APA.removedTrials = APA.Trial(pos);
    ResAPA.removedTrials = ResAPA.Trial(pos);
    TrialParams.removedTrials = TrialParams.Trial(pos);
end

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
set(findobj('tag','listbox1'),'Value',1);
liste_marche = arrayfun(@(i) APA.Trial(i).CP_Position.TrialName, 1:length(APA.Trial),'uni',0);
set(findobj('tag','listbox1'),'String',liste_marche);

%% PlotPF_Callback - Affichage de la trajectoire du CP sur la PF
% --- Executes on button press in PlotPF.
function PlotPF_Callback(~, ~, ~)
% Affichage de la trajectoire du CP sur la PF
global haxes6 APA liste_marche acq_courante
% hObject    handle fo1 PlotPF (see GCBO) 
% eventdata  reserved - fo1 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PlotPF
pos = matchcells(liste_marche,{acq_courante},'exact');

flagPF=get(findobj('tag','PlotPF'),'Value');
set(haxes6,'NextPlot','replace');

if flagPF
    set(findobj('tag','PlotHeels'),'Value',0); set(findobj('tag','PlotAccelCG'),'Value',0);
    set(findobj('Tag','Title_haxes6'),'String','Trajectoire CP');
    plot(haxes6,APA.Trial(pos).CP_Position.Data(1,:),APA.Trial(pos).CP_Position.Data(2,:));
    xlabel(haxes6,'Axe Antéropostérieur(mm)','FontName','Times New Roman','FontSize',10);
    ylabel(haxes6,'Axe Médio-Latéral (mm)','FontName','Times New Roman','FontSize',10);
    set(haxes6,'YDir','Reverse');
else
    plot(haxes6,0,0);
    xlabel(haxes6,' '); ylabel(haxes6,' ');
    set(findobj('Tag','Title_haxes6'),'String',' ');
end

%% Export des evenements du pas sur les fichiers c3d
function export_events(~, ~, ~)
global TrialParams ResAPA

path = cd;
chemin_c3d = uigetdir('','Choix du repertoire des c3d');
cd(chemin_c3d)
A = dir('*.c3d');
liste_files = { A(:).name}';
liste_acq = get(findobj('Style','listbox'),'String');
for i_acq = 1 : length(liste_acq)
    disp(['Export events pour : ' liste_acq{i_acq}]);
    try   
        % correspondance entre le num d'acquisition de la liste chargée et le .c3d
        nom_fich = [liste_acq{i_acq} '.c3d'];
        
        acq = btkReadAcquisition(fullfile(chemin_c3d,nom_fich));
        btkClearEvents(acq)
        btkAppendEvent(acq,'Event',TrialParams.Trial(i_acq).EventsTime(2)+btkGetFirstFrame(acq),'General');
        btkAppendEvent(acq,'Event',TrialParams.Trial(i_acq).EventsTime(3)+btkGetFirstFrame(acq),'General');
        if ~isempty(strfind(ResAPA.Trial(i_acq).Cote,'Left'))
            btkAppendEvent(acq,'Foot Off',TrialParams.Trial(i_acq).EventsTime(4)+btkGetFirstFrame(acq),'Left');
            btkAppendEvent(acq,'Foot Strike',TrialParams.Trial(i_acq).EventsTime(5)+btkGetFirstFrame(acq),'Left');
            btkAppendEvent(acq,'Foot Off',TrialParams.Trial(i_acq).EventsTime(6)+btkGetFirstFrame(acq),'Right');
            btkAppendEvent(acq,'Foot Strike',TrialParams.Trial(i_acq).EventsTime(7)+btkGetFirstFrame(acq),'Right');
        elseif ~isempty(strfind(ResAPA.Trial(i_acq).Cote,'Right'))
            btkAppendEvent(acq,'Foot Off',TrialParams.Trial(i_acq).EventsTime(4)+btkGetFirstFrame(acq),'Right');
            btkAppendEvent(acq,'Foot Strike',TrialParams.Trial(i_acq).EventsTime(5)+btkGetFirstFrame(acq),'Right');
            btkAppendEvent(acq,'Foot Off',TrialParams.Trial(i_acq).EventsTime(6)+btkGetFirstFrame(acq),'Left');
            btkAppendEvent(acq,'Foot Strike',TrialParams.Trial(i_acq).EventsTime(7)+btkGetFirstFrame(acq),'Left');
        end
        btkSetEventId(acq, 'Event', 0);
        btkSetEventId(acq, 'Foot Strike', 1);
        btkSetEventId(acq, 'Foot Off', 2);
        %     btkWriteAcquisition(acq,fullfile(chemin_c3d,strrep(nom_fich,'.c3d','_2.c3d')))
        btkWriteAcquisition(acq,fullfile(chemin_c3d,nom_fich))
        disp([nom_fich ' --> OK'])
    catch 
        warning('Attention évènements non exportés vers c3d');
    end
end
cd(path);
% --- Executes on button press in APA_auto.
function APA_auto_Callback(~, eventdata, handles)
% hObject    handle fo1 APA_auto (see GCBO)
% eventdata  reserved - fo1 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles);
APA_Vitesses_Callback;
% Hint: get(hObject,'Value') returns toggle state of APA_auto

%% data_preprocessing
function [APA, TrialParams, ResAPA] = Data_Preprocessing(files,dossier,b_c)
% Effectue le pré-traitement et stockage des données receuillies du répertoire d'étude (dossier)

if nargin<2
    dossier = cd;
    b_c = 'PF';
end

if nargin<3
    b_c = 'PF';
end

%%Lancement du chargement
wb = waitbar(0);
set(wb,'Name','Please wait... loading data');


%Cas ou selection d'un fichier unique
if iscell(files)
    nb_acq = length(files);
else
    nb_acq =1;
end
% initialisation
try
    myFile = files{1}(1:end-4);
    ind_tag = find(myFile=='_');
    myProt = myFile(1:ind_tag(1) - 1);
    mySession = myFile(ind_tag(1) + 1 : ind_tag(2) - 1);
    mySubject = myFile(ind_tag(2) + 1 : ind_tag(3) - 1);
    myTreat = myFile(ind_tag(3) + 1 : ind_tag(4) - 1);
    if size(ind_tag,2) > 4
        mySpeed = myFile(ind_tag(4) + 1 : ind_tag(5) - 1);
    else
        mySpeed = myFile(ind_tag(4) + 1 : end - 4);
    end
catch
    myProt = 'Protocol';
    mySession = 'Session';
    mySubject = 'Subject';
    myTreat = 'Treatment';
    mySpeed = 'Speed';
end

nom_fich = upper([myProt '_' mySession '_' mySubject '_' myTreat '_' mySpeed]);
APA.Infos.Protocole = myProt;
APA.Infos.Session = mySession;
APA.Infos.Subject = mySubject;
APA.Infos.MedCondition = myTreat;
APA.Infos.SpeedCondition = mySpeed;
APA.Infos.FileName = nom_fich;
APA.removedTrials = [];

TrialParams.Infos.Protocole = myProt;
TrialParams.Infos.Session = mySession;
TrialParams.Infos.Subject = mySubject;
TrialParams.Infos.MedCondition = myTreat;
TrialParams.Infos.SpeedCondition = mySpeed;
TrialParams.Infos.FileName = nom_fich;
TrialParams.removedTrials = [];

ResAPA.Infos.Protocole = myProt;
ResAPA.Infos.Session = mySession;
ResAPA.Infos.Subject = mySubject;
ResAPA.Infos.MedCondition = myTreat;
ResAPA.Infos.SpeedCondition = mySpeed;
ResAPA.Infos.FileName = nom_fich;
ResAPA.removedTrials = [];

% On demande si enrg commence avant trigger ou non
delay = str2num(cell2mat(inputdlg('Quel est le délai du trigger (en sec)?','Delay Trigger',1,{'1'})));

cpt = 0;
for i = 1:nb_acq
    
    myTrialName = upper(files{i}(1:end-4));
    myNum = str2double(files{i}(end-5:end-4));
    myFile = files{i};
    waitbar(i/nb_acq,wb,['Lecture fichier:' ,strrep(myFile,'_','-')]);
    try
        %======================================================================
        % initialisation des structures
        
        %======================================================================
        %Lecture du fichier
        DATA = lire_donnees_c3d_all(fullfile(dossier,myFile));
        h = btkReadAcquisition(fullfile(dossier,myFile));
        Freq_ana = btkGetAnalogFrequency(h); %% Modif' v6, on conserve les données PF à la fréquence de base pour export .lena
        t_all = (0:btkGetAnalogFrameNumber(h)-1)*1/Freq_ana;
        Fin = round(find(DATA.actmec(:,9)<70,1,'first'));  %%%% Choix ou on coupe l'acquisition!!! (defaut = PF)
        if isempty(Fin) || strcmp(b_c,'Oui')
            Fin = length(t_all);
        end
        
        %======================================================================
        % Extraction des efforts sur la PF
        if Fin<10 %% On a des 0 sur les données PF en début d'acquisitions
            Fin = length(t_all);
        end
        
        % traitement des efforts au sol
        [forceplates, ~] = btkGetForcePlatforms(h) ;
        av = btkGetAnalogs(h);
        channels=fieldnames(forceplates(1).channels);
        analog_RPLATEFORME=nan(size(av.(channels{1}),1),length(channels));
        for kk=1:length(channels)
            analog_RPLATEFORME(:,kk) = av.(channels{kk});
        end
        RES=Analog_2_forces_plates(analog_RPLATEFORME,forceplates(1).corners',forceplates(1).origin');
        RES=double(RES);
        
        clear Data
        Data = RES(1:Fin,7:12)'; % Données analog_SURFACE
        Trial_APA.GroundWrench = Signal(Data,Freq_ana,'tag',{'FX','FY','FZ','MX','MY','MZ'},...
            'units',{'N','N','N','Nmm','Nmm','Nmm'},'TrialNum',myNum,'TrialName',myTrialName);
        
        % traitement de la position du CP
        t = t_all(1:Fin);
        CP = RES(1:Fin,1:3);
        CP_filt = NaN*ones(size(CP));
        l = ~isnan(CP(:,1));
        CP_pre = CP(l,:);
        %Filtrage des données PF: filtre à réponse impulsionnel finie d'ordre 50 et de fréquence de coupure 45Hz
        CP_post = filtrage(CP_pre,'fir',50,45,Freq_ana); %%%% A changer?
        try
            CP_filt(l,:) = CP_post;
            % On complète le vecteur CP par la dernière valeur lue sur la PF
            CP0 = CP_post(end,:);
            dim_buff = Fin-sum(l);
            CP_filt(~l,:) = repmat(CP0,dim_buff,1);
        catch empty_CP
            warning(empty_CP.identifier,'%s',empty_CP.message)
            CP_filt = CP;
        end
        
        clear Data
        Data = CP_filt(:,[2 1])';
        Trial_APA.CP_Position = Signal(Data,Freq_ana,'tag',{'X','Y'},...
            'units',{'mm','mm'},'TrialNum',myNum,'TrialName',myTrialName);
        
        
        %======================================================================
        % Extraction des marqueurs temporels d'inititation du pas
        % Extraction du temps de l'instruction (à partir du FSW) pour le calcul du temps de réaction

        Trial_TrialParams.EventsTime = NaN(1,7);
        Trial_TrialParams.EventsNames = {'TR','T0','HO','FO1','FC1','FO2','FC2'};
        Trial_TrialParams.TrialName = myTrialName;
        Trial_TrialParams.TrialNum = myNum;
        Trial_TrialParams.Description = '';
        
        if isfield(DATA,'ANLG')
            signal = btkGetAnalog(h,'GO');
            if any(isnan(signal))
                signal = btkGetAnalog(h,'FSW'); %% Le trigger est sur un canal nommé 'FSW'
            end
            
            if ~any(isnan(signal))
                signal = signal - nanmean(signal);
                try
                    TR_ind = find(signal>0.2,1,'first');
                    Trial_TrialParams.EventsTime(1) = TR_ind/DATA.ANLG.Fech;
                catch GO_start
                    warning(GO_start.identifier,'%s',GO_start.message)
                    Trial_TrialParams.EventsTime(1) = t(1);
                end
            else
                disp('Pas de go sonore!');
                Trial_TrialParams.EventsTime(1) = t(1);
            end
        elseif delay >0
            Trial_TrialParams.EventsTime(1) = delay;
        else
            disp('Pas de go sonore!');
            Trial_TrialParams.EventsTime(1) = t(1);
        end
        
        try
            % extraction des evts du pas notés sur Nexus (VICON) // Modifié par AVH 24/11/2016
%             evts = sort(DATA.events.temps - t(1));
%             Trial_TrialParams.EventsTime(2:7) = evts(1:6) + t(1);
            
            ev = btkGetEvents(h);
            evts = sort(struct2array(btkGetEvents(h)));
            Trial_TrialParams.EventsTime(2:7) = evts(1:6) + t(1);
            
        catch ERR % Détection automatique
            warning(ERR.identifier,'%s',ERR.message)
            disp(['Pas d''évènements du pas ' myFile]);
            disp('...Détection automatique des évènements');
            evts = calcul_APA_all(CP_filt,t) - t(1);
            Trial_TrialParams.EventsTime(2:7) = [evts(1) + t(1), evts(2)-0.01, evts(2:5)]; % 1er evt biomécanique
            disp('...Terminé!');
        end
        
        
        %======================================================================
        % Calcul des vitesses du CG
        waitbar(i/length(files),wb,['Calculs préliminaires vitesses et APA, marche' num2str(i) '/' num2str(nb_acq)]);
        
        V_CG = [];
        Fres = Trial_APA.GroundWrench.Data(1:3,:)';
        
        % Extraction du poids
        P = mean(Fres(20:Freq_ana/2,:),1); % on prend la moyenne de la composante Z sur la 1ère demi-seconde de l'acquisition
        if ~exist('Fin','var')
            Fin = round(find(Fres(:,3)<10,1,'first')); % Dernière frame sur la PF
            if isempty(Fin)
                Fin = length(Fres);
            end
        end
        
        gravite = 9.80928; % observatoire gravimétrique de strasbourg
        M = P/gravite;
        Acc = (Fres-repmat(P,length(Fres),1))./repmat(M,length(Fres),1); % Accéleration = GRF/m
        
        %Préconditionnement du vecteur réaction sur la bonne durée (pour l'intégration)
        Fin_pf = find(Fres(:,3)<15,1,'first');
        if  isempty(Fin_pf)
            Fin_pf = length(Fres);
        end
        Fres = (Fres - repmat(P,length(Fres),1))./(P(3)/gravite); % Vecteur (GRF - P) à integré
        
        % Intégration
        t_PF=(0:Fin-1).*1/Freq_ana; % on ajoute la variable temporelle
        V_new=zeros(length(t_PF),3);
        for ii=1:3
            y=Fres(:,ii);
            try % via la toolbox 'Curve Fitting'
                y_t = csaps(t_PF,y);  % on créé une spline
                intgrf = fnint(y_t); % on intègre
                V_new(:,ii)= fnval(intgrf,t_PF);
            catch ERR % sinon par intégration numérique par la méthode des trapèzes
                disp(ERR)
                V_new(:,ii) = cumtrapz(t_PF,y); %Intégration grossière par la méthode des trapèzes
            end
        end
        
        % Pour la visu, on remplace toutes les valeurs suivant la PF par la dernière valeure
        V0 = V_new(Fin_pf,:);
        dim_end = length(V_new)-Fin_pf;
        V_new(Fin_pf+1:end,:) = repmat(V0,dim_end,1);
        
        % stockage
        clear Data
        Data = V_new(:,[2 1 3])';
        Trial_APA.CG_Speed = Signal(Data,Freq_ana,'tag',{'X','Y','Z'},...
            'units',{'m/s','m/s','m/s'},'TrialNum',myNum,'TrialName',myTrialName);
        
        % Dérivation
        if exist('DATA','var')
            % Calcul du Centre de Gravité du sujet
            try
                CG_Vic = squeeze(extraire_coordonnees_v2(DATA,{'CentreOfMass'}))'; % Calculé par Plug-In-Gait
                CoM = squeeze(barycentre_v2(extraire_coordonnees_v2(DATA,{'RASI','LASI','RPSI','LPSI'})))'; % Calculé comme barycentre des épines iliaques du bassin
                Fech_vid = round(Freq_ana * length(DATA.coord)/length(DATA.actmec)); % On réestime la fréquence d'échantillonage vidéo
                
                Fin_vid = round(Fin * Fech_vid/Freq_ana); % On réestime la dernière 'frame' vidéo
                t_vid=(0:Fin_vid-1).*1/Fech_vid; % on ajoute la variable temporelle
                VCoM=zeros(length(t_vid),3);
                V_CG=zeros(length(t_vid),3);
                
                %On retire les NaN avant dérivation et filtrage
                l = sum(isnan(CoM(1:Fin_vid,:)),2)>1;
                ll = sum(isnan(CG_Vic(1:Fin_vid,:)),2)>1;
                
                for ii=1:3
                    y=CoM(~l,ii);
                    %Dérivation barycentre marqueurs bassin
                    y_t_vid = csaps(t_vid(~l),y);  % on créé une spline
                    derCoM = fnder(y_t_vid); % on dérive
                    VCoM_pre= fnval(derCoM,t_vid(~l))./1000;
                    VCoM(~l,ii) = filtrage(VCoM_pre,'b',3,5,Fech_vid); %Lissage (filtre passe-bas de ButterWorth à 5Hz)
                    
                    %Dérivation CG Plug-In-Gait
                    if ~isnan(CG_Vic)
                        yy = CG_Vic(~ll,ii);
                        try
                            yy_t = csaps(t_vid(~ll),yy);
                            derCG = fnder(yy_t);
                            V_CG((~ll),ii) = fnval(derCG,t_vid(~ll))/1000;
                        catch ERR
                            warning(ERR.identifier,'%s',ERR.message)
                            V_CG((~ll),ii) = derive_MH_VAH(yy,Fech_vid)/1000;
                        end
                    end
                end
                
                % Interpolation du vecteur dérivé (sur-échantillonnage à Fech)
                if Fech_vid<Freq_ana
                    try
                        %                         VCoM = interp1(t_vid,VCoM,t_PF);
                        V_CG = interp1(t_vid,V_CG,t_PF);
                    catch ERR
                        warning(ERR.identifier,'%s',ERR.message)
                        disp('Pas d''interpolation à la vitesse derivée');
                    end
                end
            catch ERR
                warning(ERR.identifier,'%s',ERR.message)
                disp('Pas de données vidéos pour le calcul du CG' );
                
            end
        end
        
        % stockage
        clear Data
        Data = V_CG(:,[2 1 3])';
        Trial_APA.CG_Speed_d = Signal(Data,Freq_ana,'tag',{'X','Y','Z'},...
            'units',{'m/s','m/s','m/s'},'TrialNum',myNum,'TrialName',myTrialName);
        
        clear Data
        Data = filtrage(Acc,'fir',30,20,Freq_ana)';
        Data = Data([2 1 3],:);
        Trial_APA.CG_Acceleration = Signal(Data,Freq_ana,'tag',{'X','Y','Z'},...
            'units',{'m.s-2','m.s-2','m.s-2'},'TrialNum',myNum,'TrialName',myTrialName);
        
        clear Data
        Data = dot(Trial_APA.CG_Speed.Data,Trial_APA.GroundWrench.Data(1:3,:),1);
        Trial_APA.CG_Power = Signal(Data,Freq_ana,'tag',{'X','Y','Z'},...
            'units',{'W','W','W'},'TrialNum',myNum,'TrialName',myTrialName);
        
        % on ajoute les données de trajectoires des marqueurs talons (si données ciném dispos)
        try
        cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
        indx = 1:length(DATA.noms);
        Freq_kin = btkGetPointFrequency(h);
        Fin_cin = floor(Fin/(Freq_ana/Freq_kin)); % pour savoir où on coupe les données cinématiques
        % R_HEE
        idx_RHEE = indx(cellfun(cellfind('RHEE'),DATA.noms));
        clear Data,
        Data = DATA.coord(1:Fin_cin,(idx_RHEE-1)*3+1:idx_RHEE*3)';
        Trial_APA.RHEE = Signal(Data,Freq_kin,'tag',{'X','Y','Z'},'units',{'mm','mm','mm'},'TrialNum',myNum,'TrialName',myTrialName);
        % L_HEE
        idx_LHEE = indx(cellfun(cellfind('LHEE'),DATA.noms));
        clear Data,
        Data = DATA.coord(1:Fin_cin,(idx_LHEE-1)*3+1:idx_LHEE*3)';
        Trial_APA.LHEE = Signal(Data,Freq_kin,'tag',{'X','Y','Z'},'units',{'mm','mm','mm'},'TrialNum',myNum,'TrialName',myTrialName);
        catch
            warning('Pas de marqueurs sur talons disponibles');
        end
        champs = {'Cote','t_Reaction','t_APA','APA_antpost','APA_lateral','StepWidth','t_swing1',...
            't_DA','t_swing2','t_cycle_marche','Longueur_pas','V_swing1','Vy_FO1','t_VyFO1','Vm','t_Vm',...
            'VML_absolue','Freq_InitiationPas','Cadence','VZmin_APA','V1','V2','Diff_V','Freinage',...
            't_chute','t_freinage','t_V1','t_V2'};
        Trial_Res_APA={};
        for j = 1 : length(champs)
            Trial_Res_APA.(champs{j})=[];
        end
        
        Trial_Res_APA = calcul_auto_APA_marker_v2(Trial_APA, Trial_TrialParams,Trial_Res_APA);
        Trial_Res_APA = calculs_parametres_initiationPas_v5(Trial_APA, Trial_TrialParams,Trial_Res_APA);
        Trial_TrialParams.StartingFoot = Trial_Res_APA.Cote;
        
        cpt = cpt+1;
        APA.Trial(cpt) = Trial_APA;
        TrialParams.Trial(cpt) = Trial_TrialParams;
        ResAPA.Trial(cpt) = Trial_Res_APA;
    catch Err_load
        warning(Err_load.identifier,'%s',Err_load.message)
        disp(['Erreur de chargement pour ' myFile])
    end
end
close(wb);

%% Graph selection
function graph_zoom(hObject, ~, ~)
% crée une nouvelle figure avec le graph à afficher dedans

global  acq_courante

h=get(hObject,'children');
f=figure('Name',acq_courante);
set(f,'Color',[1 1 1]) ;
set(gca,'FontSize',12);
h1=copyobj(h,gca);
set(h1, 'LineWidth',2) ;
ylabel(get(get(hObject,'YLabel'),'String'))
xlabel('Temps (s)')

%% bouton temps réel
% --- Executes on button press in real_time.
function real_time_Callback(hObject, eventdata, handles)
% hObject    handle fo1 real_time (see GCBO)
% eventdata  reserved - fo1 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global APA TrialParams APA_T TrialParams_T

set(hObject, 'Value',1);
set(findobj('Tag','normalized_time'), 'Value',0);

APA = APA_T;
TrialParams = TrialParams_T;
listbox1_Callback(handles.listbox1, eventdata, handles)

% Hint: get(hObject,'Value') returns toggle state of real_time

%% bouton temps normalisé
% --- Executes on button press in normalized_time.
function normalized_time_Callback(hObject, eventdata, handles)
% hObject    handle fo1 normalized_time (see GCBO)
% eventdata  reserved - fo1 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global APA TrialParams APA_N TrialParams_N

set(findobj('Tag','real_time'), 'Value',0);
set(hObject, 'Value',1);

APA = APA_N;
TrialParams = TrialParams_N;
listbox1_Callback(handles.listbox1, eventdata, handles)

% Hint: get(hObject,'Value') returns toggle state of normalized_time



% --- Executes on button press in InfosButton.
function InfosButton_Callback(hObject, eventdata, handles)
% hObject    handle fo1 InfosButton (see GCBO)
% eventdata  reserved - fo1 be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global APA ResAPA  TrialParams

Tag_items = {'Protocole','Session','Code_Sujet','Traitement','Vitesse'};
items = {APA.Infos.Protocole,APA.Infos.Session,APA.Infos.Subject,APA.Infos.MedCondition,APA.Infos.SpeedCondition};
items = inputdlg(Tag_items,'Infos',1,items);

nom_fich = upper([items{1} '_' items{2} '_' items{3} '_' items{4} '_' items{5}]);
APA.Infos.Protocole = items{1};
APA.Infos.Session = items{2};
APA.Infos.Subject = items{3};
APA.Infos.MedCondition = items{4};
APA.Infos.SpeedCondition = items{5};
APA.Infos.FileName = nom_fich;

ResAPA.Infos = APA.Infos;
TrialParams.Infos = APA.Infos;


%% subject_info -Enregistrement des données sujet
% --- Execute when choosing fo1 set subject data
function Data = subject_info(~,~,~)
% Enregistrement des données sujet
global Subject_data

prompt = {'ID','Nom','Sexe',...
    'Age (ans)','Pathologie'};

if ~isempty(Subject_data)
    def = {num2str(Subject_data.ID),Subject_data.Name,Subject_data.Sexe,num2str(Subject_data.Age),Subject_data.Patho};
else
    def = {'ID','Nom','M','25','Sain'};
end

try
    rep = inputdlg(prompt,'Données Sujet',1,def);
    Data.ID = rep{1};
    Data.Name = rep{2};
    Data.Sexe = rep{3};
    Data.Age = str2double(rep{4});
    Data.Patho = rep{5};
    
    Subject_data = Data;
catch ERR
    warning(ERR.identifier, ['Erreur acquisition données sujet / ' ERR.message]);
end

% --- Executes on button press in PlotHeels.
function PlotHeels_Callback(hObject, eventdata, handles)

global TrialParams haxes6 APA liste_marche acq_courante h_marks_T0 h_marks_HO h_marks_FO1 h_marks_FC1 h_marks_FO2 h_marks_FC2
pos = matchcells(liste_marche,{acq_courante},'exact');

flagHeels=get(findobj('tag','PlotHeels'),'Value'); set(findobj('Tag','Title_haxes6'),'String','Accélération/Puissance CG');

if flagHeels
    set(findobj('tag','PlotPF'),'Value',0); set(findobj('tag','PlotAccelCG'),'Value',0);
    try
        set(findobj('Tag','Title_haxes6'),'String','Marqueurs Talons');
        xlabel(haxes6,'Temps (s)','FontName','Times New Roman','FontSize',10);
        leg(1) = plot(haxes6,APA.Trial(pos).LHEE.Time,APA.Trial(pos).LHEE.Data(3,:),'r');
        set(haxes6,'NextPlot','add');
        leg(2) = plot(haxes6,APA.Trial(pos).LHEE.Time,APA.Trial(pos).RHEE.Data(3,:),'g');
        xlabel(haxes6,'Temps (s)','FontName','Times New Roman','FontSize',10);
        ylabel(haxes6,'Z marqueurs talons (mm)','FontName','Times New Roman','FontSize',12);
        legend(leg,'Left','Right');
    catch
    end
else
    plot(haxes6,0,0);
    xlabel(haxes6,' '); ylabel(haxes6,' ');
    set(findobj('Tag','Title_haxes6'),'String',' ');
end

h_marks_T0 = affiche_marqueurs(TrialParams.Trial(pos).EventsTime(2),'-r');
h_marks_HO = affiche_marqueurs(TrialParams.Trial(pos).EventsTime(3),'-k');
h_marks_FO1 = affiche_marqueurs(TrialParams.Trial(pos).EventsTime(4),'-b');
h_marks_FC1 = affiche_marqueurs(TrialParams.Trial(pos).EventsTime(5),'-m');
h_marks_FO2 = affiche_marqueurs(TrialParams.Trial(pos).EventsTime(6),'-g');
h_marks_FC2= affiche_marqueurs(TrialParams.Trial(pos).EventsTime(7),'-c');

% --- Executes on button press in PlotAccelCG.
function PlotAccelCG_Callback(hObject, eventdata, handles)
global TrialParams haxes6 APA liste_marche acq_courante h_marks_T0 h_marks_HO h_marks_FO1 h_marks_FC1 h_marks_FO2 h_marks_FC2
pos = matchcells(liste_marche,{acq_courante},'exact');

flagAccelCG=get(findobj('tag','PlotAccelCG'),'Value'); 

if flagAccelCG
    set(findobj('tag','PlotHeels'),'Value',0); set(findobj('tag','PlotPF'),'Value',0);
    xlabel(haxes6,'Temps (s)','FontName','Times New Roman','FontSize',10);
    try
        plot(haxes6,APA.Trial(pos).CG_Power.Time,APA.Trial(pos).CG_Power.Data); afficheY_v2(0,':k',haxes6);
        xlabel(haxes6,'Temps (s)','FontName','Times New Roman','FontSize',10);
        ylabel(haxes6,'Puissance (Watt)','FontName','Times New Roman','FontSize',12);
        set(findobj('Tag','Title_haxes6'),'String','Accélération/Puissance CG');
    catch
    end
else
    plot(haxes6,0,0);
    xlabel(haxes6,' '); ylabel(haxes6,' ');
    set(findobj('Tag','Title_haxes6'),'String',' ');
end

h_marks_T0 = affiche_marqueurs(TrialParams.Trial(pos).EventsTime(2),'-r');
h_marks_HO = affiche_marqueurs(TrialParams.Trial(pos).EventsTime(3),'-k');
h_marks_FO1 = affiche_marqueurs(TrialParams.Trial(pos).EventsTime(4),'-b');
h_marks_FC1 = affiche_marqueurs(TrialParams.Trial(pos).EventsTime(5),'-m');
h_marks_FO2 = affiche_marqueurs(TrialParams.Trial(pos).EventsTime(6),'-g');
h_marks_FC2= affiche_marqueurs(TrialParams.Trial(pos).EventsTime(7),'-c');


% --- Executes during object creation, after setting all properties.
function axes7_CreateFcn(hObject, eventdata, handles)
global haxes7
% hObject    handle fo1 axes2 (see GCBO)
haxes7 = hObject;
delete(get(haxes7,'Children'));
