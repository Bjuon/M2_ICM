function varargout = Test_APA_v2(varargin)
% TEST_APA_V2 MATLAB code for Test_APA_v2.fig
%      TEST_APA_V2, by itself, creates a new TEST_APA_V2 or raises the existing
%      singleton*.
%
%      H = TEST_APA_V2 returns the handle to a new TEST_APA_V2 or the handle to
%      the existing singleton*.
%
%      TEST_APA_V2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST_APA_V2.M with the given input arguments.
%
%      TEST_APA_V2('Property','Value',...) creates a new TEST_APA_V2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Test_APA_v2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Test_APA_v2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Test_APA_v2

% Last Modified by GUIDE v2.5 06-Dec-2013 13:16:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Test_APA_v2_OpeningFcn, ...
                   'gui_OutputFcn',  @Test_APA_v2_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before Test_APA_v2 is made visible.
function Test_APA_v2_OpeningFcn(hObject, eventdata, handles, varargin)
global haxes1 haxes2 haxes3 haxes4 haxes6 h_marks_T0 h_marks_HO h_marks_TO h_marks_FC1 h_marks_FO2 h_marks_FC2 Resultats
%% Funcion principale (Interface)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Test_APA_v2 (see VARARGIN)

% Choose default command line output for Test_APA_v2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Test_APA_v2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
set(gcf,'Name','Calcul des APA v.2');

scrsz = get(0,'ScreenSize');
set(hObject,'Position',[scrsz(3)/20 scrsz(4)/20 scrsz(3)*9/10 scrsz(4)*9/10]);

ylabel(haxes1,'Axe ant�ro-post�rieur (mm)','FontName','Times New Roman','FontSize',10);
set(haxes1,'Visible','Off');

ylabel(haxes2,'Axe m�dio-lat�ral(mm)','FontName','Times New Roman','FontSize',10);
set(haxes2,'Visible','Off');

ylabel(haxes3,'Axe ant�ro-post�rieur (m/s)','FontName','Times New Roman','FontSize',10);
set(haxes3,'Visible','Off');

ylabel(haxes4,'Axe vertical(m/s)','FontName','Times New Roman','FontSize',10);
set(haxes4,'Visible','Off');
xlabel(haxes4,'Temps (sec)','FontName','Times New Roman','FontSize',10);

ylabel(haxes6,'Axe vertical(m�/s)','FontName','Times New Roman','FontSize',10);
set(haxes6,'Visible','Off');
xlabel(haxes6,'Temps (sec)','FontName','Times New Roman','FontSize',10);

h_marks_T0 = [];
h_marks_HO = [];
h_marks_TO = [];
h_marks_FC1 = [];
h_marks_FO2 = [];
h_marks_FC2= [];
Resultats = {};

%Initialisation des �tats d'affichages pour la vitesse
set(findobj('tag','V_intgr'),'Value',1); %Int�gration
set(findobj('tag','V_der'),'Value',0); %D�rivation

%FILE MENU
h = uimenu('Parent',hObject,'Label','FILE','Tag','menu_fichier','handlevisibility','On') ;
h1= uimenu(h,'Label','NOUVEAU SUJET','handlevisibility','on') ;
uimenu(h1,'Label','Charger acquisitions','Callback',@uipushtool1_ClickedCallback);
uimenu(h1,'Label','Charger dossier','Callback',@uipushtool2_ClickedCallback) ;
h2 = uimenu(h,'Label','SUJET COURANT','handlevisibility','on','Tag','sujet_courant','Enable','off') ;
uimenu(h2,'Label','Ajouter acquistions','Callback',@ajouter_acquisitions) ; %% Ajouter modif' pour ajout .xls
uimenu(h2,'Label','Ajouter sous-dossier','Callback',@ajouter_dossier) ; %% Ajouter modif' pour ajout .xls
uimenu(h2,'Label','Ajouter .mat pr�trait�','Callback',@ajouter_mat) ;

uimenu(h,'Label','CHARGER SUJET','handlevisibility','On','Callback',@uipushtool4_ClickedCallback) ; %% uipushtool4_ClickedCallback(findobj('tag','uipushtool4'), eventdata, handles))
uimenu(h,'Label','DONNEES SUJET','handlevisibility','On','Tag','subject_info','Callback',@subject_info,'Enable','off') ;

%GROUP MENU
g = uimenu('Parent',hObject,'Label','MOYENNE/GROUPE','handlevisibility','On') ;
uimenu(g,'Label','NOUVEAU GROUPE','handlevisibility','on','Callback',@Group_subjects_Callback) ;
uimenu(g,'Label','AJOUTER A UN CORRIDOR','handlevisibility','on','Callback',@Corridors_add,'Tag','Corridors_add','Enable','off') ;
uimenu(g,'Label','AJOUTER A UN GROUPE','handlevisibility','on','Callback',@Group_subjects_add,'Tag','Group_subjects_add','Enable','off') ;
uimenu(g,'Label','CHARGER GROUPE','handlevisibility','on','Callback',@Group_subjects_load,'Enable','off') ;

% NOTOCORD load MENU
n = uimenu('Parent',hObject,'Label','Notocord pr�trait�','Tag','menu_notocord','handlevisibility','On','Enable','on') ;
uimenu(n,'Label','Charger session(s) (*.mat)','Callback',@load_notocord_results) ;
uimenu(n,'Label','Charger dossier de sessions (*.mat)','Callback',@load_notocord_results_dir) ;
uimenu(n,'Label','Ajouter session(s) (*.mat)','Callback',@add_notocord_results,'handlevisibility','On','Tag','add_not','Enable','off');
uimenu(n,'Label','Ajouter dossier de sessions (*.mat)','Callback',@add_notocord_results_dir,'handlevisibility','On','Tag','add_not_dir','Enable','off');
uimenu(n,'Label','Exporter Excel','Callback',@export_excel_notocord,'handlevisibility','On','Tag','excel_not','Enable','off');

% LFP load MENU
l = uimenu('Parent',hObject,'Label','LFP','Tag','menu_lfp','handlevisibility','On','Enable','off') ;
uimenu(l,'Label','Charger fichier (*.edf; *.trc; *.Poly5)','Callback',@load_lfp) ;
uimenu(l,'Label','Exporter format LENA (.lena)','Callback',@export_lena,'Enable','off','Tag','lena_out') ;

% --- Outputs from this function are returned to the command line.
function varargout = Test_APA_v2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
%% Choix/Click dans la liste actualis�e
global haxes1 haxes2 haxes3 haxes4 haxes6 Sujet acq_courante flag_afficheV Notocord Resultats
% hObject    handle to listbox1 (see GCBO)

%R�cup�ration de l'acquisition s�l�ctionn�e
if ~isempty(eventdata)
    acq_courante = eventdata;
else
    contents = cellstr(get(hObject,'String'));
    pos = get(hObject,'Value');
    acq_courante = contents{pos};
end

%V�rification que l'acquisition existe sinon mise � jour de la liste
if ~isfield(Sujet,acq_courante)
    contents(pos) = [];
    try
        set(hObject,'Value',pos);
        acq_courante = contents{pos};
    catch ERrrt
        set(hObject,'Value',1);
        acq_courante = contents{1};
    end
end

% On check la pr�sence de donn�es de vitesse d�riv� (pour l'affichage)
flag_der = isfield(Sujet.(acq_courante),{'V_CG_AP_d' 'V_CG_Z_d'});
% flag_der = ~isempty(Sujet.(acq_courante),{'V_CG_AP_d' 'V_CG_Z_d'});
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

%Initialisation des plots et marqueurs si Multiplot Off
axess = findobj('Type','axes');
for i=1:length(axess)
    if get(findobj('tag','Multiplot'),'Value') %% Si bouton Multiplot press�
        set(axess(i),'NextPlot','add'); % Multiplot On
    else
        set(axess(i),'NextPlot','replace'); % Multiplot Off
    end
end
    
plot(haxes1,Sujet.(acq_courante).t,Sujet.(acq_courante).CP_AP);
plot(haxes2,Sujet.(acq_courante).t,Sujet.(acq_courante).CP_ML);

flagPF=get(findobj('tag','PlotPF'),'Value');
if ~flagPF
    set(findobj('Tag','Acc_txt'),'String','Acc�l�ration/Puissance CG');
    xlabel(haxes6,'Temps (s)','FontName','Times New Roman','FontSize',10);
    try
        plot(haxes6,Sujet.(acq_courante).t,Sujet.(acq_courante).Puissance_CG); afficheY_v2(0,':k',haxes6);
        ylabel(haxes6,'Puissance (Watt)','FontName','Times New Roman','FontSize',12);
    catch Err       
        plot(haxes6,Sujet.(acq_courante).t,Sujet.(acq_courante).Acc_Z); afficheY_v2(0,':k',haxes6);
        ylabel(haxes6,'Axe vertical(m�/s)','FontName','Times New Roman','FontSize',10);
    end
else
    set(findobj('Tag','Acc_txt'),'String','Trajectoire CP');
    xlabel(haxes6,'Axe Ant�ropost�rieur(mm)','FontName','Times New Roman','FontSize',10);
    ylabel(haxes6,'Axe M�dio-Lat�ral (mm)','FontName','Times New Roman','FontSize',10);
    plot(haxes6,Sujet.(acq_courante).CP_AP,Sujet.(acq_courante).CP_ML); %axis tight
    set(haxes6,'YDir','reverse');
end

%Affichage des vitesses en fonction des choix de l'utilisateur et pr�sence de donn�es d�riv�es
flags_V = [get(findobj('tag','V_intgr'),'Value') get(findobj('tag','V_der'),'Value')];
flag_afficheV = sum(flags_V); %Flag d'affichage
t = length(Sujet.(acq_courante).t);

% Extraction des maximas/minimas pour affichage des vitesses dans la bonne �chelle
Fech = Sujet.(acq_courante).Fech;
T0 = round(Sujet.(acq_courante).tMarkers.T0*Fech)-10;
FC2 = round(Sujet.(acq_courante).tMarkers.FC2*Fech);
if isnan(T0) || T0<=0
    T0 = 1;
end
if isnan(FC2)
    FC2=length(Sujet.(acq_courante).V_CG_AP)-100;
end

try
    Min_AP_D=min(Sujet.(acq_courante).V_CG_AP_d(T0:FC2+10))*1.1;
    Max_AP_D=max(Sujet.(acq_courante).V_CG_AP_d(T0:FC2+10))*1.1+0.001;
    Min_Z_D=min(Sujet.(acq_courante).V_CG_Z_d(T0:FC2+10))*1.1;
    Max_Z_D=max(Sujet.(acq_courante).V_CG_Z_d(T0:FC2+10))*1.1+0.001;
    
    Min_AP=min(Sujet.(acq_courante).V_CG_AP(T0:FC2+10))*1.1;
    Max_AP=max(Sujet.(acq_courante).V_CG_AP(T0:FC2+10))*1.1+0.001;
    Min_Z=min(Sujet.(acq_courante).V_CG_Z(T0:FC2+10))*1.1;
    Max_Z=max(Sujet.(acq_courante).V_CG_Z(T0:FC2+10))*1.1+0.001;
catch
    Min_AP_D=min(Sujet.(acq_courante).V_CG_AP_d);
    Max_AP_D=max(Sujet.(acq_courante).V_CG_AP_d);
    Min_Z_D=min(Sujet.(acq_courante).V_CG_Z_d);
    Max_Z_D=max(Sujet.(acq_courante).V_CG_Z_d);
    
    Min_AP=min(Sujet.(acq_courante).V_CG_AP);
    Max_AP=max(Sujet.(acq_courante).V_CG_AP);
    Min_Z=min(Sujet.(acq_courante).V_CG_Z);
    Max_Z=max(Sujet.(acq_courante).V_CG_Z);
end
    
switch flag_afficheV
    case 0 %Aucune s�lection
    	plot(haxes3,Sujet.(acq_courante).t,zeros(1,length(Sujet.(acq_courante).t)),'Color','w');
        plot(haxes4,Sujet.(acq_courante).t,zeros(1,length(Sujet.(acq_courante).t)),'Color','w');
    case 1 
        if flags_V(2) %Courbes d�riv�es
            try
                plot(haxes3,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_AP_d,'r-'); afficheY_v2(0,':k',haxes3);
                plot(haxes4,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_Z_d,'r-'); afficheY_v2(0,':k',haxes4);
            catch err_size
                plot(haxes3,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_AP_d(1:t),'r-'); afficheY_v2(0,':k',haxes3);
                plot(haxes4,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_Z_d(1:t),'r-'); afficheY_v2(0,':k',haxes4);
            end
            set(haxes3,'ylim',[Min_AP_D Max_AP_D]);
            set(haxes4,'ylim',[Min_Z_D Max_Z_D]);
        else %Courbes int�gr�es
            plot(haxes3,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_AP); afficheY_v2(0,':k',haxes3);
            plot(haxes4,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_Z); afficheY_v2(0,':k',haxes4);
            
            set(haxes3,'ylim',[Min_AP Max_AP]);
            set(haxes4,'ylim',[Min_Z Max_Z]);
        end
    case 2 %Les 2
        plot(haxes3,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_AP); set(haxes3,'NextPlot','add');        
        plot(haxes4,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_Z); set(haxes4,'NextPlot','add');      
        
        try
            plot(haxes3,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_AP_d,'r-'); afficheY_v2(0,':k',haxes3);
            plot(haxes4,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_Z_d,'r-'); afficheY_v2(0,':k',haxes4);
        catch err_size            
            plot(haxes3,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_AP_d(1:t),'r-'); afficheY_v2(0,':k',haxes3);
            plot(haxes4,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_Z_d(1:t),'r-'); afficheY_v2(0,':k',haxes4);
        end
        set(haxes3,'ylim',[min([Min_AP Min_AP_D]) max([Max_AP Max_AP_D])]);
        set(haxes4,'ylim',[min([Min_Z Min_Z_D]) max([Max_Z Max_Z_D])]);
end

% Si affichage automatique 'On'
if get(findobj('tag','Automatik_display'),'Value') %% Si bouton Affichage automatique press�
    Markers_Callback(findobj('tag','Markers'));
    Vitesses_Callback(findobj('tag','Vitesses'));
    if ~Notocord
        Calc_current_Callback(findobj('tag','Calc_current'), eventdata,handles); %Arret le calcul automatique
    else
        try
            affiche_resultat_APA(Resultats.(acq_courante));
        catch ERR
            disp(['Aucun calcul r�alis� ' acq_courante]);
        end
    end
end 
    
set(haxes1,'XTick',NaN);
set(haxes2,'XTick',NaN);
set(haxes3,'XTick',NaN);
set(haxes4,'XTick',NaN);

%Activation des boutons/toolbars et legendes d'axes 
set(findobj('tag','text_cp'),'Visible','On');
ylabel(haxes1,'Axe ant�ro-post�rieur (mm)','FontName','Times New Roman','FontSize',10);
ylabel(haxes2,'Axe m�dio-lat�ral(mm)','FontName','Times New Roman','FontSize',10);
ylabel(haxes3,'Axe ant�ro-post�rieur (m/s)','FontName','Times New Roman','FontSize',10);
ylabel(haxes4,'Axe vertical(m/s)','FontName','Times New Roman','FontSize',10);
xlabel(haxes6,'Temps (sec)','FontName','Times New Roman','FontSize',10);

set(findobj('tag','text_cg'),'Visible','On');
set(findobj('tag','Acc_txt'),'Visible','On');
set(findobj('tag','Group_APA'),'Visible','On');
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

%Export Triggers
if isfield(Sujet.(acq_courante),'Trigger')
    set(findobj('tag','Export_trigs'),'Enable','On');
    set(findobj('tag','menu_lfp'),'Enable','On');
else
    set(findobj('tag','Export_trigs'),'Enable','Off');
    set(findobj('tag','menu_lfp'),'Enable','Off');
end

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
%% Cr�ation de la liste
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
%% Activation des boutton de Zoom/Translation
% hObject    handle to togglebutton1 (see GCBO)
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

% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
%% Choix fichier(s) (simple/multiple)
% hObject    handle to uipushtool1 (see GCBO)
global Sujet Resultats Corridors Subject_data EMG Activation_EMG Activation_EMG_percycle Notocord Corridors_EMG LFP Corridors_LFP

try
%Choix manuel des fichiers
[files dossier] = uigetfile('*.c3d; *.xls','Choix du/des fichier(s) c3d ou notocord(xls)','Multiselect','on'); %%Ajouter plus tard les autres file types

%Initialisation
Sujet = {};
EMG = {};
Activation_EMG = {};
Activation_EMG_percycle = {};
Subject_data = {};

% Conservation des vieux corridors/resulats ?
if ~isempty(Corridors) || ~isempty(Resultats)
    button = questdlg('Conserver Resultats/Corridors existants?','Nouveau Sujet','Oui','Non','Non');
    if strcmp(button,'Non')
        Resultats = {};
        Corridors = {};
        Corridors_EMG ={};
        Corridors_LFP ={};
    end
end

if ~isempty(LFP)
    LFP ={};
end

%Extraction des donn�es d'int�r�ts
button_cut = questdlg('Lire toute l''acquisition?','Dur�e acquisition','Oui','PF','PF');
[Sujet EMG] = pretraitement_dataAPA_v5(files,dossier(1:end-1),button_cut);

%% Mise � jour interface et activation des boutons
set(findobj('tag','listbox1'), 'Visible','On');
set(findobj('tag','togglebutton1'),'Visible','On');
set(findobj('tag','AutoScale'),'Visible','On');
set(findobj('tag','Multiplot'),'Visible','On');
set(findobj('tag','Automatik_display'),'Visible','On');
set(findobj('tag','Results'), 'Visible','Off');
set(findobj('tag','Results'), 'Data',zeros(30,1));

set(findobj('Tag','sujet_courant'),'Enable','On');
set(findobj('Tag','subject_info'),'Enable','On');
set(findobj('Tag','Delete_current'),'Visible','On');
set(findobj('tag','Export_trigs'), 'Visible','On');
set(findobj('tag','PlotPF'), 'Visible','On');
Notocord =0; %% Chargement de fichiers brut d'acquisitions  et non de fichiers pr�-trait�s

%Activation des axes
axess = findobj('Type','axes');
for i=1:length(axess)
    set(axess(i),'Visible','On');
end

%Mise � jour de la liste
try
    set(findobj('tag','listbox1'), 'Value',1);
catch ERR
    disp('Liste non existante');
end
set(findobj('tag','listbox1'),'String',fieldnames(Sujet));

if length(files)>1
    set(findobj('tag','Group_APA'), 'Enable','On');
    set(findobj('tag','Clean_data'), 'Enable','On');
    set(findobj('tag','Calc_batch'), 'Enable','On');
end

set(findobj('tag','Visu_EMG'), 'Visible','On');
set(findobj('tag','visu_lfp'), 'Visible','On');
set(findobj('tag','Visu_multiple'), 'Visible','On');

if ~isempty(EMG)
    set(findobj('tag','Visu_EMG'), 'Enable','On');
    set(findobj('tag','Visu_multiple'), 'Enable','On');
end

catch ERR
    waitfor(warndlg('Annulation chargement fichiers!'));
end

% --------------------------------------------------------------------
 function uipushtool2_ClickedCallback(hObject, eventdata, handles)
%% Choix dossier (directory)
% hObject handle to uipushtool2 (see GCBO)
global Sujet Resultats Corridors Subject_data EMG Activation_EMG Activation_EMG_percycle Notocord Corridors_EMG LFP Corridors_LFP

try
%Choix du dossier et extraction de la liste des fichiers existants
dossier = uigetdir(pwd,'Repertoire de stockage des acquisitions du sujet') ;
list_rep= dir(dossier) ;
list_rep(1) = [];
list_rep(1) = [];

%Initialisation
Sujet = {};
EMG = {};
Activation_EMG = {};
Activation_EMG_percycle = {};
Subject_data = {};

% Conservation des vieux corridors/resulats ?
if ~isempty(Corridors) || ~isempty(Resultats)
    button = questdlg('Conserver Resultats/Corridors existants?','Nouveau Sujet','Oui','Non','Non');
    if strcmp(button,'Non')
        Resultats = {};
        Corridors = {};
        Corridors_EMG ={};
        Corridors_LFP ={};
    end
end

if ~isempty(LFP)
    LFP ={};
end
%% Extraction des fichiers et donn�ers utiles
filetypes = {'c3d','xls'};
[Selection,ok] = listdlg('ListString',filetypes,'Name','FILES?','ListSize',[125 30]);
filetype = filetypes(Selection);
files = extrait_liste_acquisitions(list_rep,filetype); 
%Extraction des donn�es d'int�r�ts
button_cut = questdlg('Lire toute l''acquisition?','Dur�e acquisition','Oui','PF','PF');
[Sujet EMG] = pretraitement_dataAPA_v5(files,dossier,button_cut);

%% Mise � jour interface et activation des boutons
set(findobj('tag','listbox1'), 'Visible','On');
set(findobj('tag','listbox1'), 'String',fieldnames(Sujet));
set(findobj('tag','togglebutton1'),'Visible','On');
set(findobj('tag','AutoScale'),'Visible','On');
set(findobj('tag','Multiplot'),'Visible','On');
set(findobj('tag','Automatik_display'),'Visible','On');
set(findobj('tag','Results'), 'Visible','Off');
set(findobj('tag','Results'), 'Data',zeros(30,1));

set(findobj('Tag','sujet_courant'),'Enable','On');
set(findobj('Tag','subject_info'),'Enable','On');
set(findobj('Tag','Delete_current'),'Visible','On');
set(findobj('tag','Export_trigs'), 'Visible','On');
set(findobj('tag','PlotPF'), 'Visible','On');
Notocord =0; %% Chargement de fichiers brut d'acquisitions  et non de fichiers pr�-trait�s

%Activation des axes
axess = findobj('Type','axes');
for i=1:length(axess)
    set(axess(i),'Visible','On');
end

if length(files)>1
    set(findobj('tag','Group_APA'), 'Enable','On');
    set(findobj('tag','Clean_data'), 'Enable','On');
    set(findobj('tag','Calc_batch'), 'Enable','On');
end

set(findobj('tag','Visu_EMG'), 'Visible','On');
set(findobj('tag','visu_lfp'), 'Visible','On');
set(findobj('tag','Visu_multiple'), 'Visible','On');

if ~isempty(EMG)
    set(findobj('tag','Visu_EMG'), 'Enable','On');
    set(findobj('tag','Visu_multiple'), 'Enable','On');
end

%Mise � jour de la liste
try
    set(findobj('tag','listbox1'), 'Value',1);
catch ERR
    disp('Liste non existante');
end
set(findobj('tag','listbox1'),'String',fieldnames(Sujet));

catch ERR
    waitfor(warndlg('Annulation chargement dossier'));
end

% --- Ajout acquisitions au sujet courant
function ajouter_acquisitions(hObject, eventdata, handles)
%% Ajouter des acquisitions au sujet en cour de traitement
global Sujet EMG

try
%Choix manuel des fichiers
[files dossier] = uigetfile('*.c3d; *.xls','Choix du/des fichier(s) c3d ou notocord(xls)','Multiselect','on'); %%Ajouter plus tard les autres file types

%Initialisation
Add = {};
Add_emg = {};

%Extraction des donn�es d'int�r�ts
button_cut = questdlg('Lire toute l''acquisition?','Dur�e acquisition','Oui','PF','PF');
[Add Add_emg]= pretraitement_dataAPA_v5(files,dossier(1:end-1),button_cut);

% On modifie le nom des acquisitions/fields similaires
new_acqs = fieldnames(Add);
old_acqs = fieldnames(Sujet);

if size(new_acqs,1) > size(old_acqs,1)
    similars = sum(compare_liste(new_acqs,old_acqs),1);
else
    similars = sum(compare_liste(new_acqs,old_acqs),2);
end

pf_write = 1;
emg_write = 1;
if sum(similars)
    button = questdlg('Ecraser les r�sultats du traitement PF d�j� effectu�?','PF DATA','Oui','Non','Oui');
    if strcmp(button,'Non')
        pf_write = 0;
    end
    if ~isempty(fieldnames(EMG))
        button = questdlg('Ecraser donn�es EMGs existantes?','EMG DATA','Oui','Non','Oui');
        if strcmp(button,'Non')
            emg_write = 0;
        end
    end
end
for k = 1:size(new_acqs,1)
    if similars(k)
        button = questdlg(['Donn�es PF: ' new_acqs{k}],'!Nom de marche d�j� existant!','Ajouter','Skip','Ecraser','Ecraser');
        switch button
            case 'Ajouter' % On modifie le nom et ajoute
                Sujet.(strcat(new_acqs{k},'_1')) = Add.(new_acqs{k});
                new_acqs{k} = strcat(new_acqs{k},'_1');
            case 'Skip'
                disp(['Pas de chargement' new_acqs{k}]);
            otherwise
                if pf_write
                    Sujet.(new_acqs{k}) = Add.(new_acqs{k});
                else % On garde les pretraitements (Markers et APA) et met a jour le trigger et donn�es
                    tMarkers = Sujet.(new_acqs{k}).tMarkers;
                    primResultats  = Sujet.(new_acqs{k}).primResultats;
                    Sujet.(new_acqs{k}) = Add.(new_acqs{k});
                    Sujet.(new_acqs{k}).tMarkers = tMarkers;
                    Sujet.(new_acqs{k}).tMarkers.TR = Add.(new_acqs{k}).tMarkers.TR;
                    Sujet.(new_acqs{k}).primResultats = primResultats;
                end
        end
        
        if emg_write
            try
                EMG.(new_acqs{k}) = Add_emg.(new_acqs{k});
            catch ERRR
                disp(['Pas d''EMG : ' (new_acqs{k})]);
            end
        end
    else
        Sujet.(new_acqs{k}) = Add.(new_acqs{k});
        try
            EMG.(new_acqs{k}) = Add_emg.(new_acqs{k});
        catch ERRR
            disp(['Pas d''EMG : ' (new_acqs{k})]);
        end            
    end
       
end

% Mise � jour de la liste et EMGs
set(findobj('tag','listbox1'), 'Value',1);
button2 = questdlg('Ajouter � liste actuelle ?','Mise � jour de la liste','Ajouter','Afficher tout','Ajouter');
if strcmp(button2,'Ajouter')
    liste_actuelle = cellstr(get(findobj('tag','listbox1'),'String'));
    set(findobj('tag','listbox1'),'String',[liste_actuelle; new_acqs]);
else
    set(findobj('tag','listbox1'),'String',fieldnames(Sujet));
end

if ~isempty(EMG)
    set(findobj('tag','Visu_EMG'), 'Enable','On');
    set(findobj('tag','Visu_multiple'), 'Enable','On');
end

catch ERR
    warndlg('Arr�t/Erreur chargement des nouvelles acquisitions');
end

% --- Ajout dossier au sujet courant
function ajouter_dossier(hObject, eventdata, handles)
%% Ajouter des acquisitions au sujet en cour de traitement
global Sujet EMG

try
%Choix manuel du dossier
dossier = uigetdir(pwd,'Repertoire de stockage des acquisitions du sujet') ;
list_rep= dir(dossier) ;
list_rep(1) = [];
list_rep(1) = [];

%Initialisation
Add = {};
Add_emg = {};

%% Extraction des fichiers et donn�ers utiles
filetypes = {'c3d','xls'};
[Selection,ok] = listdlg('ListString',filetypes,'Name','FILES?','ListSize',[125 30]);
filetype = filetypes(Selection);
files = extrait_liste_acquisitions(list_rep,filetype); 

button_cut = questdlg('Lire toute l''acquisition?','Dur�e acquisition','Oui','PF','PF');
[Add Add_emg] = pretraitement_dataAPA_v5(files,dossier,button_cut);

% On modifie le nom des acquisitions/fields similaires
new_acqs = fieldnames(Add);
old_acqs = fieldnames(Sujet);

if size(new_acqs,1) > size(old_acqs,1)
    similars = sum(compare_liste(new_acqs,old_acqs),1);
else
    similars = sum(compare_liste(new_acqs,old_acqs),2);
end

pf_write = 1;
emg_write = 1;
if sum(similars)
    button = questdlg('Ecraser les r�sultats du traitement PF d�j� effectu�?','PF DATA','Oui','Non','Oui');
    if strcmp(button,'Non')
        pf_write = 0;
    end
    if ~isempty(fieldnames(EMG))
        button = questdlg('Ecraser donn�es EMGs existantes?','EMG DATA','Oui','Non','Oui');
        if strcmp(button,'Non')
            emg_write = 0;
        end
    end
end

for k = 1:size(new_acqs,1)
    if similars(k)
        button = questdlg(['Donn�es PF: ' new_acqs{k}],'!Nom de marche d�j� existant!','Ajouter','Skip','Ecraser','Ecraser');
        switch button
            case 'Ajouter' % On modifie le nom et ajoute
                Sujet.(strcat(new_acqs{k},'_1')) = Add.(new_acqs{k});
                new_acqs{k} = strcat(new_acqs{k},'_1');
            case 'Skip'
                disp(['Pas de chargement' new_acqs{k}]);
            otherwise
                if pf_write
                    Sujet.(new_acqs{k}) = Add.(new_acqs{k});
                else % On garde les pretraitements (Markers et APA) et met a jour le trigger et donn�es
                    tMarkers = Sujet.(new_acqs{k}).tMarkers;
                    primResultats  = Sujet.(new_acqs{k}).primResultats;
                    Sujet.(new_acqs{k}) = Add.(new_acqs{k});
                    Sujet.(new_acqs{k}).tMarkers = tMarkers;
                    Sujet.(new_acqs{k}).tMarkers.TR = Add.(new_acqs{k}).tMarkers.TR;
                    Sujet.(new_acqs{k}).primResultats = primResultats;
                end
        end
        
        if emg_write
            try
                EMG.(new_acqs{k}) = Add_emg.(new_acqs{k});
            catch ERRR
                disp(['Pas d''EMG : ' (new_acqs{k})]);
            end
        end
    else
        Sujet.(new_acqs{k}) = Add.(new_acqs{k});
        try
            EMG.(new_acqs{k}) = Add_emg.(new_acqs{k});
        catch ERRR
            disp(['Pas d''EMG : ' (new_acqs{k})]);
        end            
    end
       
end

% Mise � jour de la liste et EMGs
set(findobj('tag','listbox1'), 'Value',1);
button2 = questdlg('Ajouter � liste actuelle ?','Mise � jour de la liste','Ajouter','Afficher tout','Ajouter');
if strcmp(button2,'Ajouter')
    liste_actuelle = cellstr(get(findobj('tag','listbox1'),'String'));
    set(findobj('tag','listbox1'),'String',[liste_actuelle; new_acqs]);
else
    set(findobj('tag','listbox1'),'String',fieldnames(Sujet));
end

if ~isempty(EMG)
    set(findobj('tag','Visu_EMG'), 'Enable','On');
    set(findobj('tag','Visu_multiple'), 'Enable','On');
end

catch ERR
    warndlg('Arr�t/Erreur chargement des nouvelles acquisitions');
end

% --- Union de +ieurs fichier .mat
function ajouter_mat(hObject, eventdata, handles)
%% Ajouter un fichier .mat au sujet en cour de traitement
global Sujet EMG Activation_EMG Activation_EMG_percycle Resultats Corridors Group Corridors_EMG LFP LFP_raw LFP_base Corridors_LFP PE PE_base LFP_tri

try
%Choix manuel des fichiers
[files dossier] = uigetfile('*.mat','Choix du/des fichier(s) mat','Multiselect','on');

nb_fich = size(files,1);
Add_corr = [];
for i = 1:nb_fich
    if nb_fich == 1
        fichier = files;
    else
        fichier = files{i};
    end;
    
    %Lecture du fichier ("_sessions.mat") contenant toutes les acquisitions d'un sujet
    Add = load([dossier '\' fichier]);
    
    % On modifie le nom des acquisitions/fields similaires
    new_acqs = fieldnames(Add.Sujet);
    old_acqs = fieldnames(Sujet);

    if size(new_acqs,1) < size(old_acqs,1)
        similars = sum(compare_liste(new_acqs,old_acqs),1);
    else
        similars = sum(compare_liste(new_acqs,old_acqs),2);
    end

    for k = 1:size(new_acqs,1)
        add = 0;
        if similars(k)
            button = questdlg(new_acqs{k},'!Nom de marche d�j� existant!','Ajouter','Skip','Ecraser','Ecraser');
            switch button
                case 'Ajouter' % On modifie le nom et ajoute
                    Sujet.(strcat(new_acqs{k},'_1')) = Add.Sujet.(new_acqs{k});
                    try
                        Resultats.(strcat(new_acqs{k},'_1')) = Add.Resultats.(new_acqs{k});
                    catch No_results
                        disp(['Pas de Calculs pour: ' new_acqs{k}]);
                    end
                    add = 1;
                case 'Skip'
                    disp(['Pas de chargement' new_acqs{k}]);
                otherwise
                    Sujet.(new_acqs{k}) = Add.Sujet.(new_acqs{k});
                    try
                        Resultats.(new_acqs{k}) = Add.Resultats.(new_acqs{k});
                    catch No_results
                        disp(['Pas de Calculs pour: ' new_acqs{k}]);
                    end
            end
        else
            Sujet.(new_acqs{k}) = Add.Sujet.(new_acqs{k});
            try
                Resultats.(new_acqs{k}) = Add.Resultats.(new_acqs{k});
            catch No_results
                disp(['Pas de Calculs pour: ' new_acqs{k}]);
            end
        end
    
        try
            if add
                EMG.(strcat(new_acqs{k},'_1')) = Add.EMG.(new_acqs{k});
                try
                    Activation_EMG.(strcat(new_acqs{k},'_1')) = Add.Activation_EMG.(new_acqs{k});
                catch NO_Activation
                    disp(['Pas d''Activation EMG identifi�s: ' (new_acqs{k})]);
                end
            else
                EMG.(new_acqs{k}) = Add.EMG.(new_acqs{k});
                try
                    Activation_EMG.(new_acqs{k}) = Add.Activation_EMG.(new_acqs{k});
                catch NO_Activation
                    disp(['Pas d''Activation EMG identifi�s: ' (new_acqs{k})]);
                end
                
                try
                    Activation_EMG_percycle.(new_acqs{k}) = Add.Activation_EMG_percycle.(new_acqs{k});
                catch NO_calculs_EMG
                end
            end
        catch ERRR
            disp(['Pas d''EMG : ' (new_acqs{k})]);
        end
        
        try
            if add
                LFP.(strcat(new_acqs{k},'_1')) = Add.LFP.(new_acqs{k});
                LFP_raw.(strcat(new_acqs{k},'_1')) = Add.LFP_raw.(new_acqs{k});
                LFP_base.(strcat(new_acqs{k},'_1')) = Add.LFP_base.(new_acqs{k});
            else
                LFP.(new_acqs{k}) = Add.LFP.(new_acqs{k});
                LFP_raw.(new_acqs{k}) = Add.LFP_raw.(new_acqs{k});
                LFP_base.(new_acqs{k}) = Add.LFP_base.(new_acqs{k});
            end
        catch ERRR
            disp(['Pas de LFP : ' (new_acqs{k})]);
        end
        
        try
            if add
                LFP_tri.(strcat(new_acqs{k},'_1')) = Add.LFP_tri.(new_acqs{k});
            else
                LFP_tri.(new_acqs{k}) = Add.LFP_tri.(new_acqs{k});
            end
        catch ERRR
        end
        
    end
    
    % On modifie le nom des Corridors similaires (si existent!)
    try
        new_corr = fieldnames(Add.Corridors);
        old_corr = fieldnames(Corridors);
        
        if size(new_corr,1) < size(old_corr,1)
            similars_corr = sum(compare_liste(new_corr,old_corr),1);
        else
            similars_corr = sum(compare_liste(new_corr,old_corr),2);
        end
    
        for j=1:size(new_corr,1)
            if similars_corr(j)
                button = questdlg(new_acqs{j},'!Nom de corridor d�j� existant!','Ajouter','Skip','Ecraser','Ajouter');
                add_corr = 0;
                switch button
                    case 'Ajouter' % On modifie le nom et ajoute
                        Corridors.(strcat(new_corr{j},'_1')) = Add.Corridors.(new_corr{j});
                        add_corr = 1;
                    case 'Skip'
                        disp(['Pas de chargement' new_corr{j}]);
                    otherwise
                        Corridors.(new_corr{j}) = Add.Corridors.(new_corr{j});
                end
            else
                Corridors.(new_corr{j}) = Add.Corridors.(new_corr{j});
            end
        end
        Add_corr = 1;
        
        try
            if add_corr
                Corridors_EMG.(strcat(new_corr{j},'_1')) = Add.Corridors_EMG.(new_corr{j});
            else
                Corridors_EMG.(new_corr{j}) = Add.Corridors_EMG.(new_corr{j});
            end
        catch ERRR
            disp(['Pas de corridor EMG : ' (new_corr{j})]);
        end
        
        try
            if add_corr
                Corridors_LFP.(strcat(new_corr{j},'_1')) = Add.Corridors_LFP.(new_corr{j});
            else
                Corridors_LFP.(new_corr{j}) = Add.Corridors_LFP.(new_corr{j});
            end
        catch ERRR
            disp(['Pas de corridor LFP : ' (new_corr{j})]);
        end
        
    catch ERR
        msgbox('Pas de Corridors dans le fichier charg�');
    end
    
    % On ajoute les PE (si existent!) et modifie les similaires
    try
        new_PEs = fieldnames(Add.PE);
        old_PEs = fieldnames(PE);
        
        if size(new_PEs,1) < size(old_PEs,1)
            similars_PE = sum(compare_liste(new_PEs,old_PEs),1);
        else
            similars_PE = sum(compare_liste(new_PEs,old_PEs),2);
        end
        
        for l = 1:length(new_PEs)
            if similars_PE(l)
                button = questdlg(new_acqs{l},'!Nom de PE d�j� existant!','Ajouter','Skip','Ecraser','Ajouter');
                switch button
                    case 'Ajouter' % On modifie le nom et ajoute
                        PE.(strcat(new_PEs{l},'_1')) = Add.PE.(new_PEs{l});
                        PE_base.(strcat(new_PEs{l},'_1')) = Add.PE_base.(new_PEs{l});
                    case 'Skip'
                        disp(['Pas de chargement' new_PEs{l}]);
                    otherwise
                        PE.(new_PEs{l}) = Add.PE.(new_PEs{l});
                        PE_base.(new_PEs{l}) = Add.PE_base.(new_PEs{l});
                end
            else
                PE.(new_PEs{l}) = Add.PE.(new_PEs{l});
                PE_base.(new_PEs{l}) = Add.PE_base.(new_PEs{l});
            end
        end
    catch ERR_PE
        disp('Pas de PE � ajouter');
    end
    
    % On modifie le nom des Groupes similaires (si existent!)
    try
        new_corr = fieldnames(Add.Group);
        old_corr = fieldnames(Group);
        
        if size(new_corr,1) < size(old_corr,1)
            similars_corr = sum(compare_liste(new_corr,old_corr),1);
        else
            similars_corr = sum(compare_liste(new_corr,old_corr),2);
        end
    
        for j=1:size(new_corr,1)
            if similars_corr(j)
                button = questdlg(new_acqs{j},'!Nom de groupe d�j� existant!','Ajouter','Skip','Ecraser','Ajouter');
                switch button
                    case 'Ajouter' % On modifie le nom et ajoute
                        Group.(strcat(new_corr{j},'_1')) = Add.Group.(new_corr{j});
                        new_corr{k} = strcat(new_corr{j},'_1');
                    case 'Skip'
                        disp(['Pas de chargement' new_corr{j}]);
                    otherwise
                        Group.(new_corr{j}) = Add.Group.(new_corr{j});
                end
            else
                Group.(new_corr{j}) = Add.Group.(new_corr{j});
            end
        end
        Add_corr = 1;
    catch ERR
        msgbox('Pas de groupes dans le fichier charg�');
    end
    
    %Mise � jour de la liste et EMGs
    set(findobj('tag','listbox1'), 'Value',1);
    liste_actuelle = cellstr(get(findobj('tag','listbox1'),'String'));
    button2 = questdlg('Ajouter les nouvelles marches � liste actuelle ?','Mise � jour de la liste','Ajouter Tout','Non','Ajouter Corridors','Ajouter Tout');
    switch button2
        case 'Ajouter Tout'
            set(findobj('tag','listbox1'),'String',[liste_actuelle; new_acqs]);
%             set(findobj('tag','listbox1'),'String',fieldnames(Sujet));
        case 'Ajouter Corridors'
            if ~isempty(Add_corr)
                set(findobj('tag','listbox1'),'String',[liste_actuelle; new_corr]);
            else
                msgbox('Pas de corridors existants pour ajout!');
            end
        otherwise
            disp('Pas d''ajout');
    end

    if ~isempty(EMG)
        set(findobj('tag','Visu_EMG'), 'Enable','On');
        set(findobj('tag','Visu_multiple'), 'Enable','On');
    end
    
     if ~isempty(LFP)
        set(findobj('tag','visu_lfp'), 'Enable','On');
        set(findobj('tag','Visu_multiple'), 'Enable','On');
    end

end

catch ERR
    warndlg('Arr�t/Erreur chargement des nouvelles acquisitions .mat');
end

% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
global haxes1
% hObject    handle to axes1 (see GCBO)
haxes1 = hObject;
% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
global haxes2
% hObject    handle to axes2 (see GCBO)
haxes2 = hObject;
% --- Executes during object creation, after setting all properties.
function axes3_CreateFcn(hObject, eventdata, handles)
global haxes3
% hObject    handle to axes2 (see GCBO)
haxes3 = hObject;
% --- Executes during object creation, after setting all properties.
function axes4_CreateFcn(hObject, eventdata, handles)
global haxes4
% hObject    handle to axes2 (see GCBO)
haxes4 = hObject;

% --------------------------------------------------------------------
function uipushtool4_ClickedCallback(hObject, eventdata, handles)
%% Chargement d'un fichier deja trait�
global Sujet Resultats Corridors Subject_data EMG Activation_EMG Activation_EMG_percycle Notocord Corridors_EMG LFP LFP_raw LFP_base Corridors_LFP Corridors_LFP_raw PE PE_base LFP_tri Histogram_EMG PerMarkers_PE h_lena b_lena e_lena e_multi LFP_lena hdr
% hObject    handle to uipushtool4 (see GCBO)

%Initialisation
Sujet = {};
EMG = {};
LFP ={};
LFP_raw = {};
LFP_base = {};
Subject_data = {};
Activation_EMG ={};
Activation_EMG_percycle ={};
LFP_tri ={};
LFP_lena ={};
h_lena ={};
b_lena ={};
e_lena ={};
e_multi = {};
hdr = {};

% Conservation des vieux corridors/resulats ?
if ~isempty(Corridors) || ~isempty(Resultats)
    button = questdlg('Conserver Resultats/Corridors existants?','Nouveau Sujet','Oui','Non','Non');
    if strcmp(button,'Non')
        Resultats = {};
        Corridors = {};
        Corridors_EMG ={};
        Corridors_LFP ={};
        Corridors_LFP_raw = {};
        PE = {};
        PE_base = {};
        Histogram_EMG = {};
        PerMarkers_PE = {};
    end
end

try
    [var dossier] = uigetfile('*.mat','Choix du sujet � charger');
    cd(dossier)
    eval(['load ' var]);

%% Mise � jour interface et activation des boutons
set(findobj('tag','listbox1'), 'Visible','On');
try
    set(findobj('tag','listbox1'), 'Value',1);
catch ERR
    disp('Liste non remplie');
end

set(findobj('tag','togglebutton1'),'Visible','On');
set(findobj('tag','AutoScale'),'Visible','On');
set(findobj('tag','Multiplot'),'Visible','On');
set(findobj('tag','Automatik_display'),'Visible','On');
set(findobj('tag','Results'), 'Visible','Off');
set(findobj('tag','Results'), 'Data',zeros(30,1));
set(findobj('tag','Affich_corridor'), 'Visible','On');
set(findobj('tag','Visu_EMG'), 'Visible','On');
set(findobj('tag','visu_lfp'), 'Visible','On');
set(findobj('tag','Export_trigs'), 'Visible','On');
set(findobj('tag','PlotPF'), 'Visible','On');

if ~isempty(EMG)
    set(findobj('tag','Visu_EMG'), 'Enable','On');
    set(findobj('tag','Visu_multiple'), 'Visible','On');
    set(findobj('tag','Visu_multiple'), 'Enable','On');
else
    set(findobj('tag','Visu_EMG'), 'Enable','Off');
    set(findobj('tag','Visu_multiple'), 'Enable','Off');
end

if ~isempty(LFP)
    set(findobj('tag','visu_lfp'), 'Enable','On');
    set(findobj('tag','Visu_multiple'), 'Enable','On');
else
    set(findobj('tag','visu_lfp'), 'Enable','Off');
end

set(findobj('tag','pushbutton20','Visible','On'));

set(findobj('Tag','sujet_courant'),'Enable','On');
set(findobj('Tag','subject_info'),'Enable','On');
set(findobj('Tag','Delete_current'),'Visible','On');

if length(fieldnames(Sujet))>1
    set(findobj('tag','Group_APA'), 'Enable','On');
    set(findobj('tag','Clean_data'), 'Enable','On');
    set(findobj('tag','Calc_batch'), 'Enable','On');
end

axess = findobj('Type','axes');
for i=1:length(axess)
    set(axess(i),'Visible','On');
    set(axess(i),'NextPlot','new');
end

% On demande d'afficher uniquement les courbes moyennes sur la liste?
if ~isempty(Corridors) && ~isempty(liste_actuelle)
    button = questdlg('Choix des acquisitions � charger sur la liste?','Mise � jour liste','Tous','Corridors','Dernier','Dernier');
        switch button
            case 'Corridors'
                set(findobj('tag','listbox1'), 'String',fieldnames(Corridors));
            case 'Tous'
                set(findobj('tag','listbox1'), 'String',fieldnames(Sujet));
            otherwise
                set(findobj('tag','listbox1'), 'String',liste_actuelle);
        end
    set(findobj('tag','Affich_corridor'), 'Enable','On');
    set(findobj('tag','Corridors_add'), 'Enable','On');
    set(findobj('tag','Clean_corridor'), 'Visible','On');
    set(findobj('tag','Clean_corridor'), 'Enable','On');
else
%     set(findobj('tag','listbox1'), 'String',liste_actuelle);
    set(findobj('tag','listbox1'), 'String',fieldnames(Sujet));
    set(findobj('tag','Affiche_corridor'), 'Enable','Off');
    set(findobj('tag','Clean_corridor'), 'Enable','Off');
end

if Notocord
    set(findobj('Tag','excel_not'),'Enable','On');
else
    Notocord = 0;
end

Subject_data.ID = var(1:end-4);
if ~isempty(h_lena)
    set(findobj('Tag','lena_out'),'Enable','On');
end
catch ERR
    disp('Annulation chargement');
end

% --------------------------------------------------------------------
function uipushtool3_ClickedCallback(hObject, eventdata, handles)
%% Sauvegarde d'un fichier en cours
% hObject    handle to uipushtool3 (see GCBO)
global Sujet Resultats Corridors Subject_data EMG Activation_EMG Activation_EMG_percycle Notocord Corridors_EMG Group LFP LFP_raw LFP_base Corridors_LFP Corridors_LFP_raw PE PE_base LFP_tri Histogram_EMG PerMarkers_PE h_lena b_lena e_lena hdr LFP_lena e_multi
% Sujet = structure contenant les donn�es PF+EMG et marqueurs temporels/Trigger par essai (champ)
% Resultats = structure contenant les resultats des param�tres biom�caniques et temps par rapports � un trigger (si existe) par essai (champ)
% Corridors = structure contenant les variable d'affichage des moyennes pour les signaux PF (Deplacements CP + Vitesses CG)
% Subject_data  = structure contenant les infos du sujet
% EMG = structure contenant les donn�es EMG par essai (champ)
% Activation_EMG =  structure contenant les temps d'activation/stop des muscles (champ2) par essai (champ1)
% Activation_EMG_percycle =  structure contenant les temps d'activation/stop en % de cycle de marche, des muscles (champ2) par essai (champ1)
% Notocord = flag (==1 si donn�es acquises sur Notocord)
% Corridors_EMG = structure contenant les variable d'affichage des moyennes pour les signaux EMG (TAs et SOLs)
% Group = structure pour un groupe (�quivalente � Sujet) avec la moyenne d'un sujet par champ
% LFP = structure contenant les donn�es LFP par essai (champ), re�chantillonn�e � 200Hz (pou affichage synchrone avec autres donn�es)
% LFP_raw = structure contenant les donn�es LFP par essai (champ)
% LFP_base = structure contenant les baseline LFP par essai (champ) (2 secondes avant le GO/Trigger)
% Corridors_LFP = structure contenant les variable d'affichage des moyennes pour les signaux LFP r�echantillon�s � Freq_vid (peu utilis�e...)
% Corridors_LFP_raw = structure contenant les donn�es brut des signaux LFP par moyennes calcul�s (utilis� pour l'affichage multiple avec spectrogram)
% PE = structure contenant les PE calcul�s par l'utilisateur � partir des LFPs
% PE_base = structure contenant les baseline des PE calcul�s par l'utilisateur � partir des LFPs (pour calcul des spectrograms normalis�s)
% LFP_tri = structure contenant les flags des mauvais essais/contacts par essai (champ)
% Histogram_EMG = structure contenant les histogrammes calcul�s � partir des % activation EMG
% PerMarkers_PE = structure contenant pour chaque PE calcul� (champ) les infos sur la taille de la fen�tre temporelle [temps avant et apr�s l'�v�nement s�lectionn�]
% h_lena = structre d'ent�te pour l'export des LFP au format lena (si existe), cr��e lors du chargement du fichier d'enregistrement continu
% b_lena = matrice binaire contenant les valeurs des signaux LFP, cr��e lors du chargement du fichier d'enregistrement continu
% e_lena = structure des �v�nements (piste technique) correspondants pour l'export au format lena du fichier continu, cr��e lors de l'export des Evts/Trigger
% hdr = structrue d'ent�te du fichier d'enregistrement LFP (n�cessaire pour cr�er la structure lena pour l'export au format d�coup�)
% e_multi = structure des �v�nements (piste technique) correspondants pour l'export au format lena du fichier d�coup�, cr��e lors de l'export des Evts/Trigger


if isempty(Subject_data)
    Subject_data = subject_info();
end

liste_actuelle = cellstr(get(findobj('tag','listbox1'),'String'));
save_name = cell2mat(inputdlg('Entrez le nom de la variable de sauvegarde','SAVE',1,{Subject_data.ID}));

try 
    if ~isempty(save_name)
        eval(['save ' save_name ' Sujet Resultats Corridors Subject_data EMG liste_actuelle Activation_EMG Activation_EMG_percycle Notocord Corridors_EMG Group LFP LFP_raw LFP_base Corridors_LFP Corridors_LFP_raw PE PE_base LFP_tri Histogram_EMG PerMarkers_PE h_lena b_lena e_lena hdr LFP_lena e_multi']);
    else
        disp('Annulation sauvegartde');
    end
catch ERrSave
    disp('Annulation sauvegartde');
%     eval(['save ' Subject_data.ID ' Sujet Resultats Corridors Subject_data EMG liste_actuelle Activation_EMG Activation_EMG_percycle Notocord Corridors_EMG Group LFP Corridors_LFP PE LFP_tri']);
end

% --- Executes on button press in AutoScale.
function AutoScale_Callback(hObject, eventdata, handles)
%% Remise � l'�chelle
% hObject    handle to AutoScale (see GCBO)
axess = findobj('Type','axes');
for i=1:length(axess)
    axis(axess(i),'tight');
end

% --- Executes on button press in T0.
function T0_Callback(hObject, eventdata, handles)
%% Choix T0 (1er �vt Biom�canique)
global Sujet acq_courante h_marks_T0
% hObject    handle to T0 (see GCBO)

Manual_click = ginput(1);
Sujet.(acq_courante).tMarkers.T0 = Manual_click(1);

efface_marqueur_test(h_marks_T0);
h_marks_T0=affiche_marqueurs(Manual_click(1),'-r');

%R�actualisation des calculs
Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles)

% --- Executes on button press in HO.
function HO_Callback(hObject, eventdata, handles)
%% Choix HO (Heel-Off)
global Sujet acq_courante h_marks_HO
% hObject    handle to HO (see GCBO)

Manual_click = ginput(1);
Sujet.(acq_courante).tMarkers.HO = Manual_click(1);

efface_marqueur_test(h_marks_HO);
h_marks_HO=affiche_marqueurs(Manual_click(1),'-k');

%R�actualisation des calculs
Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles)

% --- Executes on button press in TO.
function TO_Callback(hObject, eventdata, handles)
%% Choix TO (Toe-Off)

global haxes3 Sujet acq_courante h_marks_TO h_marks_Vy_FO1
% hObject    handle to TO (see GCBO)

Manual_click = ginput(1);
Sujet.(acq_courante).tMarkers.TO = Manual_click(1);
% ind = round(Manual_click(1)*Sujet.(acq_courante).Fech)+1; %%
ind = find(Sujet.(acq_courante).t >= Manual_click(1),1,'first') - 1;

efface_marqueur_test(h_marks_TO);
efface_marqueur_test(h_marks_Vy_FO1);
h_marks_TO=affiche_marqueurs(Manual_click(1),'-b');

% Choix sur la courbe int�gr�e ou d�riv�e
if get(findobj('tag','V_intgr'),'Value')
    Vy_FO1 = Sujet.(acq_courante).V_CG_AP(ind);
else
    try
        Vy_FO1 = Sujet.(acq_courante).V_CG_AP_d(ind);
    catch ERR
        warndlg('Veuillez cocher une courbe de vitesse!!');
        Vy_FO1 = Sujet.(acq_courante).V_CG_AP(ind);
    end
end

h_marks_Vy_FO1 = plot(haxes3,Sujet.(acq_courante).t(ind),Vy_FO1,'x','Markersize',11);

%R�actualisation de VyFO1
Sujet.(acq_courante).primResultats.Vy_FO1 = [ind Vy_FO1];
%R�actualisation des calculs
Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles)

% --- Executes on button press in FC1.
function FC1_Callback(hObject, eventdata, handles)
%% Choix FC1 (Foot-Contact du pied oscillant)
global haxes4 Sujet acq_courante h_marks_FC1 h_marks_V2
% hObject    handle to FC1 (see GCBO)

Manual_click = ginput(1);
Sujet.(acq_courante).tMarkers.FC1 = Manual_click(1);
%ind = round(Manual_click(1)*Sujet.(acq_courante).Fech)+1;
ind = find(Sujet.(acq_courante).t >= Manual_click(1),1,'first') - 1;

efface_marqueur_test(h_marks_FC1);
efface_marqueur_test(h_marks_V2);

h_marks_FC1=affiche_marqueurs(Manual_click(1),'-m');
% Choix sur la courbe int�gr�e ou d�riv�e
if get(findobj('tag','V_intgr'),'Value')
    V2 = Sujet.(acq_courante).V_CG_Z(ind);
else
    try
        V2 = Sujet.(acq_courante).V_CG_Z_d(ind);
    catch ERR
        warndlg('Veuillez cocher une courbe de vitesse!!');
        V2 = Sujet.(acq_courante).V_CG_Z(ind);
    end
end

h_marks_V2 = plot(haxes4,Sujet.(acq_courante).t(ind),V2,'x','Markersize',11);

%R�actualisation de V2 et recalcul des largeur/longueur du pas
Sujet.(acq_courante).primResultats.V2 = [ind V2];
Sujet.(acq_courante).primResultats.Largeur_pas = range(Sujet.(acq_courante).CP_ML(1:ind));
try
    Sujet.(acq_courante).primResultats.Longueur_pas = range(Sujet.(acq_courante).CP_AP(ind:(Sujet.(acq_courante).tMarkers.FO2 - Sujet.(acq_courante).t(1))*Sujet.(acq_courante).Fech));
catch ERR
    Sujet.(acq_courante).primResultats.Longueur_pas = NaN;
    disp('Placez FO2 pour calcul Longueur pas!');
end

%R�actualisation des calculs
Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles)

% --- Executes on button press in FO2.
function FO2_Callback(hObject, eventdata, handles)
%% Choix FO2 (Foot-Off du pied d'appui)
global Sujet acq_courante h_marks_FO2
% hObject    handle to FO2 (see GCBO)

Manual_click = ginput(1);
Sujet.(acq_courante).tMarkers.FO2 = Manual_click(1);
%ind = round(Manual_click(1)*Sujet.(acq_courante).Fech);
ind = find(Sujet.(acq_courante).t >= Manual_click(1),1,'first') - 1;

efface_marqueur_test(h_marks_FO2);
h_marks_FO2=affiche_marqueurs(Manual_click(1),'-g');

%Actualisation de la longueur du pas
Sujet.(acq_courante).primResultats.Longueur_pas = range(Sujet.(acq_courante).CP_AP(Sujet.(acq_courante).tMarkers.FC1*Sujet.(acq_courante).Fech:ind));

%R�actualisation des calculs
Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles)

% --- Executes on button press in FC2.
function FC2_Callback(hObject, eventdata, handles)
%% Choix FC2 (Foot-Contact du pied d'appui)
global Sujet acq_courante h_marks_FC2
% hObject    handle to FC2 (see GCBO)

Manual_click = ginput(1);
Sujet.(acq_courante).tMarkers.FC2 = Manual_click(1);

efface_marqueur_test(h_marks_FC2);
h_marks_FC2=affiche_marqueurs(Manual_click(1),'-c');

%R�actualisation des calculs
Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles)

% --- Executes on button press in yAPA_AP.
function yAPA_AP_Callback(hObject, eventdata, handles)
%% Detection manuelle du d�placement post�rieur max du CP lors des APA
global haxes1 Sujet acq_courante h_marks_APAy1
% hObject    handle to yAPA_AP (see GCBO)

Manual_click = ginput(1);
%ind = round(Manual_click(1)*Sujet.(acq_courante).Fech)+1;
ind = find(Sujet.(acq_courante).t >= Manual_click(1),1,'first') - 1;

efface_marqueur_test(h_marks_APAy1);

set(haxes1,'NextPlot','add');
h_marks_APAy1 = plot(haxes1,Sujet.(acq_courante).t(ind),Sujet.(acq_courante).CP_AP(ind),'x','Markersize',11);
set(haxes1,'NextPlot','new');

%Stockage du r�sultats
Sujet.(acq_courante).primResultats.minAPAy_AP = [ind mean(Sujet.(acq_courante).CP_AP(1:(Sujet.(acq_courante).tMarkers.T0-Sujet.(acq_courante).t(1))*Sujet.(acq_courante).Fech)) - Sujet.(acq_courante).CP_AP(ind)];

%R�actualisation des calculs
Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles)

% --- Executes on button press in yAPA_ML.
function yAPA_ML_Callback(hObject, eventdata, handles)
global haxes2 Sujet acq_courante h_marks_APAy2
% Detection valeur minimale/maximale du d�placement m�diolat�ral du CP lors des APA
% hObject    handle to yAPA_ML (see GCBO)

Manual_click = ginput(1);
%ind = round(Manual_click(1)*Sujet.(acq_courante).Fech)+1;
ind = find(Sujet.(acq_courante).t >= Manual_click(1),1,'first') - 1;

efface_marqueur_test(h_marks_APAy2);

set(haxes2,'NextPlot','add');
Extrema = Sujet.(acq_courante).CP_ML(ind);
h_marks_APAy2 = plot(haxes2,Sujet.(acq_courante).t(ind),Extrema,'x','Markersize',11);
set(haxes2,'NextPlot','new');

%Stockage du r�sultats
Sujet.(acq_courante).primResultats.APAy_ML = [ind abs(mean(Sujet.(acq_courante).CP_ML(1:(Sujet.(acq_courante).tMarkers.T0-Sujet.(acq_courante).t(1))*Sujet.(acq_courante).Fech) - Extrema))];
%R�actualisation des calculs
Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles)

% --- Executes on button press in Vy_FO1.
function Vy_FO1_Callback(hObject, eventdata, handles)
%% D�tection manuelle de la Vitesse AP du CG lors de FO1
global haxes3 Sujet acq_courante h_marks_VyFO1
% hObject    handle to Vy_FO1 (see GCBO)
% Choix sur la courbe d�riv�e
if get(findobj('tag','V_der'),'Value') && ~get(findobj('tag','V_intgr'),'Value')
    Manual_click = ginput(1);
    %ind = round(Manual_click(1)*Sujet.(acq_courante).Fech)+1;
    ind = find(Sujet.(acq_courante).t >= Manual_click(1),1,'first') - 1;
    
    efface_marqueur_test(h_marks_VyFO1);
    Vy_FO1 = Sujet.(acq_courante).V_CG_AP_d(ind);
    h_marks_VyFO1 = plot(haxes3,Sujet.(acq_courante).t(ind),Vy_FO1,'x','Markersize',11);
    %R�actualisation de VyFO1 et recalcul des largeur/longueur du pas
    Sujet.(acq_courante).primResultats.Vy_FO1 = [ind Vy_FO1];
    %R�actualisation des calculs
    Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles)
else
    waitfor(warndlg('VyFO1 d�pend de TO!!'));
end

% --- Executes on button press in Vm.
function Vm_Callback(hObject, eventdata, handles)
%% D�tection manuelle Vitesse max AP du CG
% hObject    handle to Vm (see GCBO)
global haxes3 Sujet acq_courante h_marks_Vm

Manual_click = ginput(1);
%ind = round(Manual_click(1)*Sujet.(acq_courante).Fech)+1;
ind = find(Sujet.(acq_courante).t >= Manual_click(1),1,'first') - 1;

efface_marqueur_test(h_marks_Vm);

% Choix sur la courbe int�gr�e ou d�riv�e
if get(findobj('tag','V_intgr'),'Value')
    Vm = Sujet.(acq_courante).V_CG_AP(ind);
else
    try
        Vm = Sujet.(acq_courante).V_CG_AP_d(ind);
    catch ERR
        waitfor(warndlg('Veuillez cocher une courbe de vitesse!!'));
        Vm = Sujet.(acq_courante).V_CG_AP(ind);
    end
end

set(haxes3,'NextPlot','add');
h_marks_Vm = plot(haxes3,Sujet.(acq_courante).t(ind),Vm,'x','Markersize',11,'Color','r','Linewidth',1.2);
set(haxes3,'NextPlot','new');

% Stockage du r�sultats
Sujet.(acq_courante).primResultats.Vm = [ind Vm];

%R�actualisation des calculs
Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles)

% --- Executes on button press in Vmin_APA.
function Vmin_APA_Callback(hObject, eventdata, handles)
%% D�tection manuelle Vitesse min verticale du CG lors des APA
global haxes4 Sujet acq_courante h_marks_Vmin_APA
% hObject    handle to Vmin_APA (see GCBO)

Manual_click = ginput(1);
%ind = round(Manual_click(1)*Sujet.(acq_courante).Fech)+1;
ind = find(Sujet.(acq_courante).t >= Manual_click(1),1,'first') - 1;

efface_marqueur_test(h_marks_Vmin_APA);

% Choix sur la courbe int�gr�e ou d�riv�e
if get(findobj('tag','V_intgr'),'Value')
    Vmin_APA = Sujet.(acq_courante).V_CG_Z(ind);
else
    try
        Vmin_APA = Sujet.(acq_courante).V_CG_Z_d(ind);
    catch ERR
        waitfor(warndlg('Veuillez cocher une courbe de vitesse!!'));
        Vmin_APA = Sujet.(acq_courante).V_CG_Z(ind);
    end
end

set(haxes4,'NextPlot','add');
h_marks_Vmin_APA = plot(haxes4,Sujet.(acq_courante).t(ind),Vmin_APA,'x','Markersize',11,'Color','k');
set(haxes4,'NextPlot','new');

% Stockage du r�sultats
Sujet.(acq_courante).primResultats.VZmin_APA = [ind Vmin_APA];

%R�actualisation des calculs
Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles)

% --- Executes on button press in V1.
function V1_Callback(hObject, eventdata, handles)
%% D�tection manuelle du 1er min de la Vitesse vertciale du CG lors de l'�xecution du pas
global haxes4 Sujet acq_courante h_marks_V1
% hObject    handle to V1 (see GCBO)

Manual_click = ginput(1);
%ind = round(Manual_click(1)*Sujet.(acq_courante).Fech)+1;
ind = find(Sujet.(acq_courante).t >= Manual_click(1),1,'first') - 1;

efface_marqueur_test(h_marks_V1);

% Choix sur la courbe int�gr�e ou d�riv�e
if get(findobj('tag','V_intgr'),'Value')
    V1 = Sujet.(acq_courante).V_CG_Z(ind);
else
    try
        V1 = Sujet.(acq_courante).V_CG_Z_d(ind);
    catch ERR
        waitfor(warndlg('Veuillez cocher une courbe de vitesse!!'));
        V1 = Sujet.(acq_courante).V_CG_Z(ind);
    end
end

set(haxes4,'NextPlot','add');
h_marks_V1 = plot(haxes4,Sujet.(acq_courante).t(ind),V1,'x','Markersize',11,'Color','r','Linewidth',1.4);
set(haxes4,'NextPlot','new');

% Stockage du r�sultats
Sujet.(acq_courante).primResultats.V1 = [ind V1];

%R�actualisation des calculs
Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles)

% --- Executes on button press in V2.
function V2_Callback(hObject, eventdata, handles)
%% D�tection manuelle de la Vitesse vertciale du CG lors du FC1
global haxes4 Sujet acq_courante h_marks_V2
% Choix sur la courbe d�riv�e
if get(findobj('tag','V_der'),'Value')
    Manual_click = ginput(1);
    %ind = round(Manual_click(1)*Sujet.(acq_courante).Fech)+1;
    ind = find(Sujet.(acq_courante).t >= Manual_click(1),1,'first') - 1;
    
    efface_marqueur_test(h_marks_V2);
    V2 = Sujet.(acq_courante).V_CG_Z_d(ind);
    h_marks_V2 = plot(haxes4,Sujet.(acq_courante).t(ind),V2,'x','Markersize',11,'Color','m','Linewidth',1.5);
    %R�actualisation de VyFO1 et recalcul des largeur/longueur du pas
    Sujet.(acq_courante).primResultats.V2 = [ind V2];
    %R�actualisation des calculs
    Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles)
else
    waitfor(warndlg('V2 d�pend de FC1!!'));
end

% --- Executes on button press in Markers.
function Markers_Callback(hObject, eventdata, handles)
%% Affichage des marqueurs de l'acquisition courante/s�lectionn�e
global haxes1 haxes2 Sujet acq_courante h_marks_T0 h_marks_HO h_marks_TO h_marks_FC1 h_marks_FO2 h_marks_FC2 h_marks_APAy1 ...
    h_marks_APAy2 h_marks_Trig h_trig_txt h_marks_FOG h_FOG_txt
% hObject    handle to Markers (see GCBO)

%Nettoyage des axes d'abord (??Laisser si Multiplot On??)
efface_marqueur_test(h_marks_T0);
efface_marqueur_test(h_marks_HO);
efface_marqueur_test(h_marks_TO);
efface_marqueur_test(h_marks_FC1);
efface_marqueur_test(h_marks_FO2);
efface_marqueur_test(h_marks_FC2);

efface_marqueur_test(h_marks_Trig);
efface_marqueur_test(h_trig_txt);
efface_marqueur_test(h_marks_FOG);
efface_marqueur_test(h_FOG_txt);

%Actualisation des marqueurs
h_marks_T0 = affiche_marqueurs(Sujet.(acq_courante).tMarkers.T0,'-r');
h_marks_HO = affiche_marqueurs(Sujet.(acq_courante).tMarkers.HO,'-k');
h_marks_TO = affiche_marqueurs(Sujet.(acq_courante).tMarkers.TO,'-b');
h_marks_FC1 = affiche_marqueurs(Sujet.(acq_courante).tMarkers.FC1,'-m');
h_marks_FO2 = affiche_marqueurs(Sujet.(acq_courante).tMarkers.FO2,'-g');
h_marks_FC2 = affiche_marqueurs(Sujet.(acq_courante).tMarkers.FC2,'-c');

%Affichage du trigger externe (si existe) et si pas trop �loign�
if isfield(Sujet.(acq_courante),'Trigger')
    dec = Sujet.(acq_courante).Trigger - Sujet.(acq_courante).t(1);
    dec = troncature(dec,1);
    if abs(dec)<2
        h_marks_Trig = affiche_marqueurs(Sujet.(acq_courante).Trigger,'*-k');
        h_trig_txt = text(Sujet.(acq_courante).Trigger,1000,'GO/Trigger',...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','left',...
            'FontSize',8,...
            'Parent',haxes1);
    else
        h_marks_Trig = affiche_marqueurs(Sujet.(acq_courante).t(1),'*-k');
        h_trig_txt = text(Sujet.(acq_courante).t(1),1000,['<- Trigger d�cal� de ' num2str(dec) ' sec'],...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','left',...
            'FontSize',8,...
            'Parent',haxes1);
    end
end

if isfield(Sujet.(acq_courante).tMarkers,'FOG')
    for i=1:2:length(Sujet.(acq_courante).tMarkers.FOG)-1
        h_marks_FOG = affiche_marqueurs(Sujet.(acq_courante).tMarkers.FOG(i),'--k');
        h_FOG_txt = text(Sujet.(acq_courante).tMarkers.FOG(i),1200,'FOG',...
            'VerticalAlignment','middle',...
            'HorizontalAlignment','left',...
            'FontSize',8,...
            'Parent',haxes1);
    end
 end


%Affichage des APA pr�-trait�s
try
    ind_1 = round(Sujet.(acq_courante).primResultats.minAPAy_AP(1));
    h_marks_APAy1 = plot(haxes1,Sujet.(acq_courante).t(ind_1),Sujet.(acq_courante).CP_AP(ind_1),'x','Markersize',11);

    ind_2 = round(Sujet.(acq_courante).primResultats.APAy_ML(1));
    h_marks_APAy2 = plot(haxes2,Sujet.(acq_courante).t(ind_2),Sujet.(acq_courante).CP_ML(ind_2),'x','Markersize',11);
catch NO_APA
    disp('Calcul automatique des APA AP et ML non r�alis�');
end

%Activation des boutons de modification manuelle des marqueurs
set(findobj('tag','T0'),'Visible','On');
set(findobj('tag','HO'),'Visible','On');
set(findobj('tag','TO'),'Visible','On');
set(findobj('tag','FC1'),'Visible','On');
set(findobj('tag','FO2'),'Visible','On');
set(findobj('tag','FC2'),'Visible','On');

set(findobj('tag','yAPA_AP'),'Visible','On');
set(findobj('tag','yAPA_ML'),'Visible','On');

% --- Executes on button press in Vitesses.
function Vitesses_Callback(hObject, eventdata, handles)
%% Affichage des pics de Vitesse d�j� calcul�s
global haxes3 haxes4 Sujet acq_courante h_marks_Vy_FO1 h_marks_Vm h_marks_VZ_min h_marks_V1 h_marks_V2
% hObject    handle to Vitesses (see GCBO)

%Nettoyage des axes d'abord (??Laisser si Multiplot On??)
efface_marqueur_test(h_marks_Vy_FO1);
efface_marqueur_test(h_marks_Vm);
efface_marqueur_test(h_marks_VZ_min);
efface_marqueur_test(h_marks_V1);
efface_marqueur_test(h_marks_V2);

axess = findobj('Type','axes');
for i=1:length(axess)
    set(axess(i),'NextPlot','add'); % Multiplot On
end

%Actualisation des marqueurs
try
    ind_Vy = round(Sujet.(acq_courante).primResultats.Vy_FO1(1));
    Vy = Sujet.(acq_courante).primResultats.Vy_FO1(2);
    h_marks_Vy_FO1 = plot(haxes3,Sujet.(acq_courante).t(ind_Vy),Vy,'x','Markersize',11);
catch ERr_FO1
end

try
    ind_Vm = round(Sujet.(acq_courante).primResultats.Vm(1));
    Vm = Sujet.(acq_courante).primResultats.Vm(2);
    h_marks_Vm = plot(haxes3,Sujet.(acq_courante).t(ind_Vm),Vm,'x','Markersize',11,'Color','r','Linewidth',1.5);

    ind_Vmin = round(Sujet.(acq_courante).primResultats.VZmin_APA(1));
    Vmin = Sujet.(acq_courante).primResultats.VZmin_APA(2);
    h_marks_VZ_min = plot(haxes4,Sujet.(acq_courante).t(ind_Vmin),Vmin,'x','Markersize',11,'Color','k');
catch ERr_Vm
end

try
    ind_V1 = round(Sujet.(acq_courante).primResultats.V1(1));
    V1 = Sujet.(acq_courante).primResultats.V1(2);
    h_marks_V1 = plot(haxes4,Sujet.(acq_courante).t(ind_V1),V1,'x','Markersize',11,'Color','r','Linewidth',1.25);
catch ERr_V1
end

try
    ind_V2 = round(Sujet.(acq_courante).primResultats.V2(1));
    V2 = Sujet.(acq_courante).primResultats.V2(2);
    h_marks_V2 = plot(haxes4,Sujet.(acq_courante).t(ind_V2),V2,'x','Markersize',11,'Color','m','Linewidth',1.5);
catch ERr_V2
end

%Activation des bouton de modification manuelle des vitesses
set(findobj('tag','Vy_FO1'),'Visible','On');
set(findobj('tag','Vm'),'Visible','On');
set(findobj('tag','Vmin_APA'),'Visible','On');
set(findobj('tag','V1'),'Visible','On');
set(findobj('tag','V2'),'Visible','On');

set(findobj('tag','V_der'),'Visible','On');
set(findobj('tag','V_intgr'),'Visible','On');

% --- Executes on button press in Calc_current.
function Calc_current_Callback(hObject, eventdata, handles)
%% Calculs des APA sur l'acquisition selectionn�e
% hObject    handle to Calc_current (see GCBO)
global Sujet acq_courante Resultats Notocord

% Calculs  %%% METTRE Condition si NOTOCORD ????!!��
if isempty(Notocord) || ~Notocord
    Resultats.(acq_courante) = calculs_parametres_initiationPas_v1(Sujet.(acq_courante));
else
    Resultats.(acq_courante) = calculs_parametres_initiationPas_Not(Sujet.(acq_courante),Resultats.(acq_courante));
end
    
%Affichage
Current_Res = affiche_resultat_APA(Resultats.(acq_courante));

% --- Executes on button press in Calc_batch.
function Calc_batch_Callback(hObject, eventdata, handles)
%% Calculs des APA sur toutes les acquisitions
% hObject    handle to Calc_batch (see GCBO)
global Sujet Resultats Subject_data Notocord

% Calculs
liste = fieldnames(Sujet);
wb = waitbar(0);
set(wb,'Name','Please wait... Calculating data');

for i=1:length(liste)
    waitbar(i/length(liste)-1,wb,['Calcul acquisition: ' liste{i}]);
    if ~Notocord
        try
            Resultats.(liste{i}) = calculs_parametres_initiationPas_v1(Sujet.(liste{i}));
        catch No_data
            disp(['Erreur calcul: ' liste{i}]);
            Resultats.(liste{i}) = NaN;
        end
    end
end
if isempty(Subject_data)
    Subject_data = subject_info();
end

% Export Excel
button = questdlg('Exporter sur Excel??','Sauvegarde r�sultats','Oui','Non','Non');
if strcmp(button,'Oui')
    fichier = inputdlg({'Nom du fichier/sujet' 'Nom de la feuille/session'},'Ecriture .xls',1,{Subject_data.ID 'Synth�se'});
    ecrireQR_xls(Resultats,[fichier{1} '.xls'],fichier{2});
else
    warndlg('Attention donn�es non export�es!');
end
close(wb);

% --- Executes on button press in V_der.
function V_der_Callback(hObject, eventdata, handles)
%% Etat d'affichage de la vitesse obtenue par d�rivation
global haxes3 haxes4 Sujet acq_courante flag_afficheV
% hObject    handle to V_der (see GCBO)
% Hint: get(hObject,'Value') returns toggle state of V_der
flags_V = [get(findobj('tag','V_intgr'),'Value') get(findobj('tag','V_der'),'Value')];
flag_afficheV = sum(flags_V); %Flag d'affichage
if get(hObject,'Value')
    if flag_afficheV==2
        set(haxes3,'Nextplot','add');
        set(haxes4,'Nextplot','add'); 
    end
    try
        plot(haxes3,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_AP_d,'r-');
        plot(haxes4,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_Z_d,'r-');
    catch err_size
        t = length(Sujet.(acq_courante).t);
        plot(haxes3,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_AP_d(1:t),'r-');
        plot(haxes4,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_Z_d(1:t),'r-');
    end
end

% --- Executes on button press in V_intgr.
function V_intgr_Callback(hObject, eventdata, handles)
%% Etat d'affichage de la vitesse obtenue par int�gration
global haxes3 haxes4 Sujet acq_courante flag_afficheV
% hObject    handle to V_intgr (see GCBO)
% Hint: get(hObject,'Value') returns toggle state of V_intgr
flags_V = [get(findobj('tag','V_intgr'),'Value') get(findobj('tag','V_der'),'Value')];
flag_afficheV = sum(flags_V); %Flag d'affichage
if get(hObject,'Value')
    if flag_afficheV==2
        set(haxes3,'Nextplot','add');
        set(haxes4,'Nextplot','add'); 
    end
    plot(haxes3,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_AP);
    plot(haxes4,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_Z);
end

% --- Executes on button press in Clean_data.
function Clean_data_Callback(hObject, eventdata, handles)
%% Nettoyage des donn�es en �liminant manuellement les mauvaises acquisitions
global Sujet Resultats Notocord clean
% hObject    handle to Clean_data (see GCBO)

%Extraction des acquisitions sur la liste
% listes_acqs = filednames(Sujet);
listes_acqs = cellstr(get(findobj('tag','listbox1'),'String'));

%S�lections de l'utilisateur
[acqs,v] = listdlg('PromptString',{'Nettoyage donn�es','Choix des acquisitions � v�rifier'},...
    'ListSize',[300 300],...
    'ListString',listes_acqs);

% TRi par conditions? (pour les donn�es Notocord surtout)
butTri = questdlg('Trier par condition?','Tri automatique','Oui','Non','Non');
if strcmp(butTri,'Oui')
    choixC = inputdlg({'Condition � s�lectionner? (MN-MR_OFF-ON'},'Choix TRi',1);
    choixC = cell2mat(choixC);
else
    choixC = '';
end

%Affichage dans une nouvelle fen�tre contr�lable (clean)
clean=figure;
c=uicontextmenu('Parent',clean);
cb1 = 'mouse_actions_APA(''identify'')';
cb2 = 'mouse_actions_APA(''gait_suppression'')';
uimenu(c, 'Label', 'Rep�rer/d�s�l�ctionner acquisition', 'Callback',cb1);
uimenu(c, 'Label', 'Supprimer marche', 'Callback',cb2);

%Cr�ation des fen�tres
h1 = subplot(411); hold on
ylabel('D�placement CP AP (mm)');
h2 = subplot(412); hold on
ylabel('D�placement CP ML (mm)');
h3 = subplot(413); hold on
ylabel('Vitesse CG AP (m/sec)');
h4 = subplot(414); hold on
ylabel('Vitesse CG verticale (m/sec)');

%Chargement des acquisitions et affichage dans la fen�tre de contr�le
acqs = listes_acqs(acqs);
try 
    for i = 1:length(acqs)
        tags = extract_tags(acqs{i});
        if Notocord
            cond = Resultats.(acqs{i}).Condition;
        else
            cond = [tags{3} '_' extract_spaces_v3(tags{end},'\d')]; %%% Adapt� � la nomenclature de GBMOV
        end
        
        % Astuce de d�tournement au cas ou pas de tri
        if isempty(choixC)
                choixC = cond;
        end
        
        if ~strcmp(tags(end),'KO') && strcmp(cond,choixC)
            endFC2 = Sujet.(acqs{i}).tMarkers.FC2;
            endFC2 = round(endFC2*(Sujet.(acqs{i}).Fech));
            try
                plot(h1,Sujet.(acqs{i}).CP_AP(1:endFC2),'ButtonDownFcn',@maselection,'uicontextmenu',c,'displayname',acqs{i});
                plot(h2,Sujet.(acqs{i}).CP_ML(1:endFC2),'ButtonDownFcn',@maselection,'uicontextmenu',c,'displayname',acqs{i});
                plot(h3,Sujet.(acqs{i}).V_CG_AP(1:endFC2),'ButtonDownFcn',@maselection,'uicontextmenu',c,'displayname',acqs{i});
                plot(h4,Sujet.(acqs{i}).V_CG_Z(1:endFC2),'ButtonDownFcn',@maselection,'uicontextmenu',c,'displayname',acqs{i});
            catch FC2_far
                plot(h1,Sujet.(acqs{i}).CP_AP,'ButtonDownFcn',@maselection,'uicontextmenu',c,'displayname',acqs{i});
                plot(h2,Sujet.(acqs{i}).CP_ML,'ButtonDownFcn',@maselection,'uicontextmenu',c,'displayname',acqs{i});
                plot(h3,Sujet.(acqs{i}).V_CG_AP,'ButtonDownFcn',@maselection,'uicontextmenu',c,'displayname',acqs{i});
                plot(h4,Sujet.(acqs{i}).V_CG_Z,'ButtonDownFcn',@maselection,'uicontextmenu',c,'displayname',acqs{i});
            end
        end
    end
    %On retire les mauvaises acquisitions de la variable Sujet et on remet � jour la liste et la variable Resultats
    msgbox('Cliquez sur les courbes/acquisitions � retirer (click droit pour d�s�l�ctionner) - puis appuyer sur OK');
catch ERR
    warndlg('!!Une seule acquisition charg�e!!');
end  

% --- Executes on button press in Automatik_display.
function Automatik_display_Callback(hObject, eventdata, handles)
% hObject    handle to Automatik_display (see GCBO)
% Hint: get(hObject,'Value') returns toggle state of Automatik_display

% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in Group_APA.
function Group_APA_Callback(hObject, eventdata, handles)
%% Moyennage des acquisitions s�lectionn�es et stockage dans une variable acquisition (Corridors)
global Sujet Resultats Corridors Activation_EMG_percycle Notocord EMG Corridors_EMG LFP LFP_raw Corridors_LFP Corridors_LFP_raw LFP_base
% hObject    handle to Group_APA (see GCBO)

%Extraction des acquisitions
button = questdlg('Choisir parmis toutes les acquisitions (Oui)?, ou celles de la liste (Non)?','Calcul corridor','Oui','Non','Non');
if strcmp(button,'Oui') % On affiche le corridor dans une nouvelle fen�tre de visualisation de l'interface
    listes_acqs = fieldnames(Sujet);
else
    listes_acqs = cellstr(get(findobj('tag','listbox1'),'String'));
end

%Choix du nom de la moyenne
groupe_acqs = cell2mat(inputdlg('Entrez le nom du groupe d''acquisitions','Calcul corridor Moyen'));

%S�lections de l'utilisateur
try
[acqs,v] = listdlg('PromptString',{strcat('Group ',groupe_acqs),'Choix des acquisitions � inclure dans le group'},...
    'ListSize',[300 300],...
    'ListString',listes_acqs);
    
%Stockage des acquisitions choisies dans une structure �quivalente
Group_data={};
Moy_data={};
Group_emg={};
Activation_emg={};
Group_lfp={};
Side = {};

for i=1:length(acqs)
    tags = extract_tags(listes_acqs{acqs(i)});
    if ~strcmp(tags(end),'KO') && ~isfield(Corridors,listes_acqs{acqs(i)}) %% Retire les acquisitions 'KO' (NOtocord) et Corridors
        
    Group_data.(listes_acqs{acqs(i)}) = Sujet.(listes_acqs{acqs(i)});
    try
        Group_emg.(listes_acqs{acqs(i)}) = EMG.(listes_acqs{acqs(i)});
    catch ErrEMG
        disp(['Pas d''EMGs pour l''acquisition: ' listes_acqs{acqs(i)}]);
    end
    
    try
        Group_lfp.(listes_acqs{acqs(i)}) = LFP.(listes_acqs{acqs(i)}); % Pour la visu (donn�es r�echantillon�s � Freq_vis)
        Group_lfp_raw.(listes_acqs{acqs(i)}) = LFP_raw.(listes_acqs{acqs(i)}); % Donn�es brut durant l'essai
        Group_lfp_base.(listes_acqs{acqs(i)}) = LFP_base.(listes_acqs{acqs(i)}); % Donn�es baseline
    catch ErrLFP
        disp(['Pas de LFPs pour l''acquisition: ' listes_acqs{acqs(i)}]);
    end
        
    if ~isfield(Resultats,listes_acqs{acqs(i)}) % Calculs des param�tres si non effectu�s
        disp(['Calculs acquisition ' listes_acqs{acqs(i)}]);
        if Notocord
            Resultats.(listes_acqs{acqs(i)})=calculs_parametres_initiationPas_Not(Sujet.(listes_acqs{acqs(i)}),Resultats.(listes_acqs{acqs(i)}));           
        else
            Resultats.(listes_acqs{acqs(i)})=calculs_parametres_initiationPas_v1(Sujet.(listes_acqs{acqs(i)}));
        end
    end
    
    try
        Side{i} = Resultats.(listes_acqs{acqs(i)}).Cote; %Extraction Cot�
        tagss = extract_tags(listes_acqs{acqs(i)});
        Cnd{i} = tagss{3}; %Extraction Condition de Marche
    catch isNotocord
        Side{i} = Resultats.(listes_acqs{acqs(i)}).Pied;
        Cnd{i} = Resultats.(listes_acqs{acqs(i)}).Condition;
    end
    
    try
        if isfield(Activation_EMG_percycle,listes_acqs{acqs(i)}) % Moyenneage des activations EMG (si existent)
           % Rassembler les periodes d'activation EMG
            Activation_emg.(listes_acqs{acqs(i)}) = Activation_EMG_percycle.(listes_acqs{acqs(i)});
        else
            disp(['Pas d''activations EMG pour l''acquisition: ' listes_acqs{acqs(i)}]);
        end
    catch ERR
        disp('Pas de calcul moyen EMG');
    end
    
    Moy_data.(listes_acqs{acqs(i)}) = Resultats.(listes_acqs{acqs(i)});
    end
end

%Normalisation des donn�es brutes
if isempty(Group_emg)
    butN = questdlg('Normaliser les donn�es?','Moyennage','Oui','Non','Non');
    if strcmp(butN,'Oui')
        Group_norm = normalise_APA_v2N(Group_data);
    else
        Group_norm = normalise_APA_v2(Group_data);
    end
else
    butA = questdlg('Aligner les donn�es sur T0?','Moyennage','GO','T0','T0');
    if strcmp(butA,'T0')
        [Group_norm EMGs_norm] = normalise_APA_v4(Group_data,Group_emg);
    else
        [Group_norm EMGs_norm] = normalise_APA_v0(Group_data,Group_emg);
    end
    [EMG_moy EMG_group Ecarts_emg] = regroupe_acquisitions(EMGs_norm);
end

if ~isempty(Group_lfp)
    if strcmp(butA,'T0') 
        LFPs_norm = normalise_APA_lfps(Group_data,Group_lfp);
        LFPs_norm_raw = normalise_APA_lfps(Group_data,Group_lfp_raw);
    else
        LFPs_norm = normalise_APA_lfps0(Group_data,Group_lfp);
        LFPs_norm_raw = normalise_APA_lfps0(Group_data,Group_lfp_raw);
    end
    [LFP_moy_base LFP_group_base Ecarts_lfps] = regroupe_acquisitions(Group_lfp_base);
    [LFP_moy LFP_group Ecarts_lfps] = regroupe_acquisitions(LFPs_norm);
    [LFP_moy_raw LFP_group_raw Ecarts_lfps] = regroupe_acquisitions(LFPs_norm_raw);
end
    
%Moyennage des activations EMG
EMG_activation_moy={};
if ~isempty(Activation_emg)
    [EMG_activation_moy EMG_activation_std] = regroupe_EMGs(Activation_emg);
end

%Calcul du corridor et des resultats moyens
[Res_moy Res_group Ecarts_res] = regroupe_acquisitions(Moy_data);
% [Acq_moy Data_group Ecarts_acqs] = regroupe_acquisitions_v2(Group_norm);
butTri = questdlg('Trier par condition?','Tri automatique','Oui','Non','Non');
if strcmp(butTri,'Oui')
    choixC = inputdlg({'Condition � s�lectionner?'},'Choix TRi',1);
    choixC = cell2mat(choixC);
    [Acq_moy Data_group Ecarts_acqs] = regroupe_acquisitions_v3Not(Group_norm,Side,Cnd,choixC);
else
    [Acq_moy Data_group Ecarts_acqs] = regroupe_acquisitions_v3(Group_norm,Side);
end

%Stockage
Corridors.(groupe_acqs) = Data_group;
Sujet.(groupe_acqs) = Acq_moy;
Resultats.(groupe_acqs) = Res_moy;

%EMG
if ~isempty(Group_emg)
    Corridors_EMG.(groupe_acqs) = EMG_group;
    Activation_EMG_percycle.(groupe_acqs) = EMG_activation_moy;
    Muscles = fieldnames(EMG_moy);
    EMG.(groupe_acqs).nom = Muscles;
    EMG.(groupe_acqs).Fech = EMG.(listes_acqs{acqs(i)}).Fech;
    
    for m = 1:length(Muscles)
        EMG.(groupe_acqs).val(:,m) = EMG_moy.(Muscles{m})';
    end
end

%LFP
if ~isempty(Group_lfp)
    Corridors_LFP.(groupe_acqs) = LFP_group; %Pour la visu (�chantillon�s � Freq_vid)
    Corridors_LFP_raw.(groupe_acqs) = LFP_group_raw; %Donn�s brut pour calcul T-F
    LFP.(groupe_acqs) = LFP_moy;
    LFP_raw.(groupe_acqs) = LFP_moy_raw;
    LFP_base.(groupe_acqs) = LFP_moy_base; %Baseline moyenne pour calcul T-F
end

%Affichage
set(findobj('tag','Affich_corridor'), 'Visible','On');
set(findobj('tag','Affich_corridor'), 'Enable','On');
set(findobj('tag','Corridors_add'), 'Enable','On');
set(findobj('tag','Clean_corridor'), 'Visible','On');
set(findobj('tag','Clean_corridor'), 'Enable','On');
button = questdlg('Afficher corridor ?','Affichage interface','Oui','Non','Non');
if strcmp(button,'Oui') % On affiche le corridor dans une nouvelle fen�tre de visualisation de l'interface
    Affich_corridor_Callback(findobj('tag','Affich_corridor'), groupe_acqs);
end

% On demande si on veut supprimer les acquisitions
button = questdlg('Retirer les acquisitions du groupe de la liste ?','R�duction de la liste','Oui','Non','Non');
listes_acqs = [listes_acqs;groupe_acqs];
if strcmp(button,'Oui') % On supprime uniquement de la liste les acquisitions qui ont �t� prises dans les groupe
    listes_acqs(acqs,:)=[];
end
set(findobj('tag','listbox1'), 'Value',1);
set(findobj('tag','listbox1'),'String',listes_acqs);

catch ERR
    warndlg('Arret cr�ation groupe'); 
end

    function Corridors_add(hObject, eventdata, handles)
        %% Ajout d'acquisition(s) � un corridor existant
        global Sujet Resultats Corridors Activation_EMG_percycle Notocord EMG Corridors_EMG
        % hObject    handle to Corridors_add (see GCBO)
        try
        %Choix du corridors
        listes_grp = fieldnames(Corridors);
        %S�lections de l'utilisateur
        [i,v] = listdlg('PromptString',{'Choix du corridor � incr�menter'},...
            'ListSize',[300 300],...
            'ListString',listes_grp);
        
        groupe_acqs = cell2mat(listes_grp(i));
        
        listes_acqs = fieldnames(Sujet);
        [acqs,v] = listdlg('PromptString',{strcat('Group ',groupe_acqs),'Choix des acquisitions � ajouter dans le corridor'},...
            'ListSize',[300 300],...
            'ListString',listes_acqs);
        
        %Stockage des acquisitions choisies dans une structure �quivalente
        Group_data={};
        Moy_data={};
        Group_emg={};
        Activation_emg={};
        for i=1:length(acqs)
            Group_data.(listes_acqs{acqs(i)}) = Sujet.(listes_acqs{acqs(i)});
            try
                Group_emg.(listes_acqs{acqs(i)}) = EMG.(listes_acqs{acqs(i)});
            catch ErrEMG
                disp(['Pas d''EMGs pour l''acquisition: ' listes_acqs{acqs(i)}]);
            end
            
            if ~isfield(Resultats,listes_acqs{acqs(i)}) % Calculs des param�tres si non effectu�s
                disp(['Calculs groupe ' listes_acqs{acqs(i)}]);
                if Notocord
                    Resultats.(listes_acqs{acqs(i)})=calculs_parametres_initiationPas_Not(Sujet.(listes_acqs{acqs(i)}),Resultats.(listes_acqs{acqs(i)}));
                else
                    Resultats.(listes_acqs{acqs(i)})=calculs_parametres_initiationPas_v1(Sujet.(listes_acqs{acqs(i)}));
                end
            end
            
            try
                if isfield(Activation_EMG_percycle,listes_acqs{acqs(i)}) % Moyenneage des activations EMG (si existent)
                    % Rassembler les periodes d'activation EMG
                    Activation_emg.(listes_acqs{acqs(i)}) = Activation_EMG_percycle.(listes_acqs{acqs(i)});
                else
                    disp(['Pas d''activations EMG pour l''acquisition: ' listes_acqs{acqs(i)}]);
                end
            catch ERR
                disp('Pas de calcul moyen EMG');
            end
            
            Moy_data.(listes_acqs{acqs(i)}) = Resultats.(listes_acqs{acqs(i)});
        end
        
        %Normalisation des nouvelles donn�es       
        if isempty(Group_emg)
            Group_norm = normalise_APA_v2(Group_data);
        else
            [Group_norm EMGs_norm] = normalise_APA_v4(Group_data,Group_emg);
            [EMG_moy_new EMG_group_new Ecarts_emg_new] = regroupe_acquisitions(EMGs_norm);
        end

        %Moyennage des activations EMG
        EMG_activation_moy={};
        if ~isempty(Activation_emg)
            EMG_activation_moy_new = regroupe_EMGs(Activation_emg);
            try
                EMG_activation_moy_old = Activation_EMG_percycle.(groupe_acqs);
            catch ERrEMG %pas d'activation au groupe pr�cedent
                EMG_activation_moy_old ={};
            end
            
            if isempty(EMG_activation_moy_old)
                EMG_activation_moy = EMG_activation_moy_new;
            else
                tmp_emg.old_grp = EMG_activation_moy_old;
                tmp_emg.new_grp = EMG_activation_moy_new;
                EMG_activation_moy = regroupe_EMGs(tmp_emg);
            end
            
        end
        
        %Cr�ation d'un groupe provisoire
        [Acq_moy_new Data_group_new Ecarts_acqs_new] = regroupe_acquisitions_v2(Group_norm);
        
        %Ajout du groupe
        Group_data2.add_acqs = Data_group_new;
        Group_data2.old_group = Corridors.(groupe_acqs);
        
        %Renormalisation avec le corridor de base      
        if isempty(Group_emg)
            Group_norm2 = normalise_APA_v2(Group_data2);
        else
            Group_emg2.add_acqs = EMG_group_new;
            Group_emg2.old_group = Corridors_EMG.(groupe_acqs);
            [Group_norm2 EMGs_norm2] = normalise_APA_v4(Group_data2,Group_emg2);
%             EMG_moy.add_accqs = EMG_moy_new;
%             EMG_moy.old_group = EMG.(groupe_acqs);
%             EMG_moy_norm = normalise_APA_v2(EMG_moy);
            [EMG_moy_all EMG_group Ecarts_emg] = regroupe_corridors(EMGs_norm2);
%             [EMG_moy_corr EMG_corr_group Ecarts_emg] = regroupe_acquisitions(EMG_moy_norm);
        end
        
        
        Acqs_moy.add_acqs  = Acq_moy_new;
        Acqs_moy.old_group = Sujet.(groupe_acqs);       
        Moy_data.old_group = Resultats.(groupe_acqs);
        
        %Calcul du corridor et des resultats moyens
        [Corr_moy Data_group Ecarts_corrs] = regroupe_corridors(Group_norm2);
        [Acq_moy Data_group2 Ecarts_acqs] = regroupe_acquisitions_v2(Acqs_moy);
        [Res_moy Res_group Ecarts_res] = regroupe_acquisitions(Moy_data);
        
        %Stockage
        Corridors.(groupe_acqs) = Data_group;
        Sujet.(groupe_acqs) = Acq_moy;
        Resultats.(groupe_acqs) = Res_moy;
        
        %EMG
        if ~isempty(Group_emg)
            Corridors_EMG.(groupe_acqs) = EMG_group;
            Activation_EMG_percycle.(groupe_acqs) = EMG_activation_moy;
            Muscles = fieldnames(EMG_moy_all);
            EMG.(groupe_acqs).nom = Muscles;
            EMG.(groupe_acqs).Fech = EMG.(listes_acqs{acqs(i)}).Fech;
            
            for m = 1:length(Muscles)
                EMG.(groupe_acqs).val(:,m) = EMG_moy_all.(Muscles{m})';
            end
        end
        %Affichage
        set(findobj('tag','Affich_corridor'), 'Visible','On');
        set(findobj('tag','Affich_corridor'), 'Enable','On');
        set(findobj('tag','Clean_corridor'), 'Visible','On');
        set(findobj('tag','Clean_corridor'), 'Enable','On');
        button = questdlg('Afficher corridor ?','Affichage interface','Oui','Non','Non');
        if strcmp(button,'Oui') % On affiche le corridor dans une nouvelle fen�tre de visualisation de l'interface
            Affich_corridor_Callback(findobj('tag','Affich_corridor'), groupe_acqs);
        end
        
        % On demande si on veut supprimer les acquisitions
        button = questdlg('Retirer les acquisitions du groupe de la liste ?','R�duction de la liste','Oui','Non','Non');
        if strcmp(button,'Oui') % On supprime uniquement de la liste les acquisitions qui ont �t� prises dans les groupe
            listes_acqs(acqs,:)=[];
            set(findobj('tag','listbox1'), 'Value',1);
            set(findobj('tag','listbox1'),'String',listes_acqs);
        end
        catch ERrt
            warndlg('Arr�t ajout groupe!');
        end
        
% --- Executes on button press in Group_subjects.
function Group_subjects_Callback(hObject, eventdata, handles)
%% Moyennage des acquisitions des sujets s�lectionn�s et stockage dans une variable acquisition (Group)
global Sujet Resultats Corridors Activation_EMG_percycle Notocord Group EMG Corridors_EMG
% hObject    handle to Group_subjects (see GCBO)

%Extraction des corridors
listes_acqs = fieldnames(Corridors);

%Choix du nom du group
groupe_acqs = cell2mat(inputdlg('Entrez le nom du groupe:','Calcul corridor groupe'));

%S�lections de l'utilisateur
try
[acqs,v] = listdlg('PromptString',{strcat('Group ',groupe_acqs),'Choix des corridors � inclure dans le group'},...
    'ListSize',[300 300],...
    'ListString',listes_acqs);
    
%Stockage des acquisitions choisies dans une structure �quivalente
Group_data={};
Moy_data={};
Group_emg={};
Group_emg2={};
Activation_emg={};

for i=1:length(acqs)
    Group_data.(listes_acqs{acqs(i)}) = Corridors.(listes_acqs{acqs(i)});
    Group_data2.(listes_acqs{acqs(i)}) = Sujet.(listes_acqs{acqs(i)}); %% Pour calculer les marqueurs temporels moyens
    
    try
        Group_emg.(listes_acqs{acqs(i)}) = Corridors_EMG.(listes_acqs{acqs(i)});
    catch ErrEMG
        disp(['Pas de corridor EMG pour le groupe: ' listes_acqs{acqs(i)}]);
    end
    
    try
        Group_emg2.(listes_acqs{acqs(i)}) = EMG.(listes_acqs{acqs(i)});
    catch ErrEMG2
        disp(['Pas d''EMG moyen pour le groupe: ' listes_acqs{acqs(i)}]);
    end
    
    if ~isfield(Resultats,listes_acqs{acqs(i)}) % Calculs des param�tres si non effectu�s
        disp(['Calculs groupe ' listes_acqs{acqs(i)}]);
        if Notocord
            Resultats.(listes_acqs{acqs(i)})=calculs_parametres_initiationPas_Not(Sujet.(listes_acqs{acqs(i)}),Resultats.(listes_acqs{acqs(i)}));
        else
            Resultats.(listes_acqs{acqs(i)})=calculs_parametres_initiationPas_v1(Sujet.(listes_acqs{acqs(i)}));
        end
    end
    
    try
        if isfield(Activation_EMG_percycle,listes_acqs{acqs(i)}) % Moyenneage des activations EMG (si existent)
           % Rassembler les periodes d'activation EMG
            Activation_emg.(listes_acqs{acqs(i)}) = Activation_EMG_percycle.(listes_acqs{acqs(i)});
        else
            disp(['Pas d''activations EMG pour le groupe: ' listes_acqs{acqs(i)}]);
        end
    catch ERR
        disp('Pas de calcul moyen EMG');
    end
    
    Moy_data.(listes_acqs{acqs(i)}) = Resultats.(listes_acqs{acqs(i)});      
end


%Normalisation des donn�es brutes
if isempty(Group_emg)
    Group_norm = normalise_APA_v2(Group_data);
    Group_norm2 = normalise_APA_v2(Group_data2);
else
%     [Group_norm EMGs_norm] = normalise_APA_v4(Group_data,Group_emg);
    [Group_norm EMGs_norm] = normalise_Corridors(Group_data,Group_emg);
    [Group_norm2 EMGs_norm2] = normalise_APA_v4(Group_data2,Group_emg2);
end

%Moyennage des activations EMG
EMG_activation_moy={};
if ~isempty(Activation_emg)
    EMG_activation_moy = regroupe_EMGs(Activation_emg);
end

%Calcul du corridor et des resultats moyens
[Corr_moy Data_group Ecarts_corrs] = regroupe_corridors(Group_norm);
[Corr_emg_moy EMG_group_all Ecarts_corrs] = regroupe_corridors(EMGs_norm);
[Acq_moy Data_group2 Ecarts_acqs] = regroupe_acquisitions_v2(Group_norm2);
[Res_moy Res_group Ecarts_res] = regroupe_acquisitions(Moy_data);
[EMG_moy EMG_group_moy Ecarts_emg] = regroupe_acquisitions(EMGs_norm2);

%Stockage
Group.(groupe_acqs) = Data_group;
Corridors.(groupe_acqs) = Data_group;
Sujet.(groupe_acqs) = Acq_moy;
Resultats.(groupe_acqs) = Res_moy;

%EMG
if ~isempty(Group_emg)
    Corridors_EMG.(groupe_acqs) = EMG_group_all;
    if ~isempty(EMG_activation_moy)
        Activation_EMG_percycle.(groupe_acqs) = EMG_activation_moy;
    end
    Muscles = fieldnames(EMG_moy);
    EMG.(groupe_acqs).nom = Muscles;
    EMG.(groupe_acqs).Fech = EMG.(listes_acqs{acqs(i)}).Fech;
    
    for m = 1:length(Muscles)
        EMG.(groupe_acqs).val(:,m) = EMG_moy.(Muscles{m})';
    end
end

%Affichage
set(findobj('tag','Affich_corridor'), 'Visible','On');
set(findobj('tag','Affich_corridor'), 'Enable','On');
set(findobj('tag','Clean_corridor'), 'Visible','On');
set(findobj('tag','Clean_corridor'), 'Enable','On');
set(findobj('tag','Group_subjects_add'),'Enable','On');
button = questdlg('Afficher corridor ?','Affichage interface','Oui','Non','Non');
if strcmp(button,'Oui') % On affiche le corridor dans une nouvelle fen�tre de visualisation de l'interface
    Affich_corridor_Callback(findobj('tag','Affich_corridor'), groupe_acqs);
end

% On demande si on veut supprimer les acquisitions
button = questdlg('Retirer les acquisitions du groupe de la liste ?','R�duction de la liste','Oui','Non','Non');
if strcmp(button,'Oui') % On supprime uniquement de la liste les acquisitions qui ont �t� prises dans les groupe
    listes_acqs(acqs,:)=[];
    set(findobj('tag','listbox1'), 'Value',1);
    set(findobj('tag','listbox1'),'String',listes_acqs);
end
catch ERR
    warndlg('Arret cr�ation groupe'); 
end

    function Group_subjects_add(hObject, eventdata, handles)
        %% Ajout de corridors � un group existant
        global Sujet Resultats Corridors Activation_EMG_percycle Notocord Group EMG Corridors_EMG
        % hObject    handle to Group_subjects_add (see GCBO)
        
        try
        %Choix du groupe
        listes_grp = fieldnames(Group);
        %S�lections de l'utilisateur
        [i,v] = listdlg('PromptString',{'Choix du goupe � incr�menter'},...
            'ListSize',[300 300],...
            'ListString',listes_grp);
        
        groupe_acqs = cell2mat(listes_grp(i));
        
        listes_acqs = fieldnames(Corridors);
        [acqs,v] = listdlg('PromptString',{strcat('Group ',groupe_acqs),'Choix des corridors � inclure dans le group'},...
            'ListSize',[300 300],...
            'ListString',listes_acqs);
        
        %Stockage des acquisitions choisies dans une structure �quivalente
        Group_data={};
        Moy_data={};
        Group_emg={};
        Group_emg2={};
        Activation_emg={};
        for i=1:length(acqs)
            Group_data.(listes_acqs{acqs(i)}) = Corridors.(listes_acqs{acqs(i)});
            Group_data2.(listes_acqs{acqs(i)}) = Sujet.(listes_acqs{acqs(i)}); %% Pour calculer les marqueurs temporels moyens
            
            try
                Group_emg.(listes_acqs{acqs(i)}) = Corridors_EMG.(listes_acqs{acqs(i)});
            catch ErrEMG
                disp(['Pas de corridor EMG pour le groupe: ' listes_acqs{acqs(i)}]);
            end
            
            try
                Group_emg2.(listes_acqs{acqs(i)}) = EMG.(listes_acqs{acqs(i)});
            catch ErrEMG2
                disp(['Pas d''EMG moyen pour le groupe: ' listes_acqs{acqs(i)}]);
            end
    
            if ~isfield(Resultats,listes_acqs{acqs(i)}) % Calculs des param�tres si non effectu�s
                disp(['Calculs groupe ' listes_acqs{acqs(i)}]);
                if Notocord
                    Resultats.(listes_acqs{acqs(i)})=calculs_parametres_initiationPas_Not(Sujet.(listes_acqs{acqs(i)}),Resultats.(listes_acqs{acqs(i)}));
                else
                    Resultats.(listes_acqs{acqs(i)})=calculs_parametres_initiationPas_v1(Sujet.(listes_acqs{acqs(i)}));
                end
            end
            
            try
                if isfield(Activation_EMG_percycle,listes_acqs{acqs(i)}) % Moyenneage des activations EMG (si existent)
                    % Rassembler les periodes d'activation EMG
                    Activation_emg.(listes_acqs{acqs(i)}) = Activation_EMG_percycle.(listes_acqs{acqs(i)});
                else
                    disp(['Pas d''activations EMG pour l''acquisition: ' listes_acqs{acqs(i)}]);
                end
            catch ERR
                disp('Pas de calcul moyen EMG');
            end
            
            Moy_data.(listes_acqs{acqs(i)}) = Resultats.(listes_acqs{acqs(i)});
        end
        
        %Ajout du groupe
        Group_data.(groupe_acqs) = Group.(groupe_acqs);
        Group_data2.(groupe_acqs) = Sujet.(groupe_acqs);
        
        %Normalisation des donn�es brutes
        if isempty(Group_emg)
            Group_norm = normalise_APA_v2(Group_data);
            Group_norm2 = normalise_APA_v2(Group_data2);
        else
            Group_emg.(groupe_acqs) = Corridors_EMG.(groupe_acqs);
            Group_emg2.(groupe_acqs) = EMG.(groupe_acqs);
            [Group_norm EMGs_norm] = normalise_APA_v4(Group_data,Group_emg);
            [Group_norm2 EMGs_norm2] = normalise_APA_v4(Group_data2,Group_emg2);
            [EMG_all_moy EMG_group_all Ecarts_corrs] = regroupe_corridors(EMGs_norm);
        	[EMG_Acq_moy EMG_group_moy Ecarts_acqs] = regroupe_acquisitions(EMGs_norm2);
        end
        
        %Moyennage des activations EMG
        EMG_activation_moy={};
        if ~isempty(Activation_emg)
            EMG_activation_moy_new = regroupe_EMGs(Activation_emg);
            try
                EMG_activation_moy_old = Activation_EMG_percycle.(groupe_acqs);
            catch ERrEMG %pas d'activation au groupe pr�cedent
                EMG_activation_moy_old ={};
            end
            
            if isempty(EMG_activation_moy_old)
                EMG_activation_moy = EMG_activation_moy_new;
            else
                tmp_emg.old_grp = EMG_activation_moy_old;
                tmp_emg.new_grp = EMG_activation_moy_new;
                EMG_activation_moy = regroupe_EMGs(tmp_emg);
            end
            
        end
        
        %Calcul du corridor et des resultats moyens
        [Corr_moy Data_group Ecarts_corrs] = regroupe_corridors(Group_norm);
        [Acq_moy Data_group2 Ecarts_acqs] = regroupe_acquisitions_v2(Group_norm2);
        [Res_moy Res_group Ecarts_res] = regroupe_acquisitions(Moy_data);
        
        %Stockage
        Group.(groupe_acqs) = Data_group;
        Corridors.(groupe_acqs) = Data_group;
        Sujet.(groupe_acqs) = Acq_moy;
        Resultats.(groupe_acqs) = Res_moy;
        
        %EMG
        if ~isempty(Group_emg)
            Corridors_EMG.(groupe_acqs) = EMG_group_all;
            Activation_EMG_percycle.(groupe_acqs) = EMG_activation_moy;
            Muscles = fieldnames(EMG_all_moy);
            EMG.(groupe_acqs).nom = Muscles;
            EMG.(groupe_acqs).Fech = EMG.(listes_acqs{acqs(i)}).Fech;
            
            try
                for m = 1:length(Muscles)
                    EMG.(groupe_acqs).val(:,m) = EMG_all_moy.(Muscles{m})';
                end
            catch Err_size
                EMG = rmfield(EMG.(groupe_acqs),'val');
                for m = 1:length(Muscles)
                    EMG.(groupe_acqs).val(:,m) = EMG_all_moy.(Muscles{m})';
                end
            end
                
        end
        %Affichage
        set(findobj('tag','Affich_corridor'), 'Visible','On');
        set(findobj('tag','Affich_corridor'), 'Enable','On');
        set(findobj('tag','Clean_corridor'), 'Visible','On');
        set(findobj('tag','Clean_corridor'), 'Enable','On');
        button = questdlg('Afficher corridor ?','Affichage interface','Oui','Non','Non');
        if strcmp(button,'Oui') % On affiche le corridor dans une nouvelle fen�tre de visualisation de l'interface
            Affich_corridor_Callback(findobj('tag','Affich_corridor'), groupe_acqs);
        end
        
        % On demande si on veut supprimer les acquisitions
        button = questdlg('Retirer les acquisitions du groupe de la liste ?','R�duction de la liste','Oui','Non','Non');
        if strcmp(button,'Oui') % On supprime uniquement de la liste les acquisitions qui ont �t� prises dans les groupe
            listes_acqs(acqs,:)=[];
            set(findobj('tag','listbox1'), 'Value',1);
            set(findobj('tag','listbox1'),'String',listes_acqs);
        end
        catch ERrt
            warndlg('Arr�t ajout groupe!');
        end
                     
        % --- Executes on button press in Affich_corridor.
function Affich_corridor_Callback(hObject, eventdata, handles)
%% Affichage des corridors pour les donn�es brutes
global axes1 axes2 axes3 axes4 Corridors Sujet list Sujet_tmp listes_corr i t T_FC1_base Activation_EMG_percycle
% hObject    handle to Affich_corridor (see GCBO)
Sujet_tmp = Sujet;
choix_corr = {};
%Extraction des corridors calcul�s
try
legendes={};
    if isempty(eventdata)
        listes_corr = fieldnames(Corridors);
        %S�lections de l'utilisateur
        [i,v] = listdlg('PromptString',{'Choix du corridor � afficher'},...
             'ListSize',[300 300],...
             'ListString',listes_corr,'SelectionMode','Multiple');
    else
        if iscell(eventdata)
            listes_corr = eventdata;
            i = 1:size(listes_corr,1);
        else
            listes_corr{1} = eventdata;
            i = 1;
        end
    end
    
    buttonSTD = questdlg('Modifier Epaisseur corridors?','Affichage Corridors','Oui','Non','Oui');
    if strcmp(buttonSTD,'Oui')
        facK = inputdlg({'(0-1)'},'Facteur de r�duction ?',1,{'1'});
        facK = str2double(facK);
    else
        facK = 1;
    end
    
    listes_acqs = fieldnames(Sujet_tmp);
    %Affichage
    % Cr�ation de l'interface de visu
    f = figure();
    b = uiextras.HBox( 'Parent', f);
    b1 = uiextras.VBox( 'Parent', b);
    %Ajout de la liste sans la moyenne du/des corridor(s) venant d'�tre calcul�(s)
    list = uicontrol( 'Style', 'listbox', 'Parent', b, 'String', listes_acqs,'Callback',@list_Callback);
    
    axes1 = axes( 'Parent', b1, ...
    'ActivePositionProperty', 'Position','xticklabel',[]);
    
    colors={'r' 'g' 'b' 'm' 'k' 'c' 'y'};
    for k=1:length(i)
        t=(0:size(Corridors.(listes_corr{i(k)}).CP_AP,2)-1)*1/max(Corridors.(listes_corr{i(k)}).Fech);
        Offset_CPAP = Sujet_tmp.(listes_corr{i(k)}).CP_AP(1)*1e-1;
%         h_corr_CP_AP = stdshade(Corridors.(listes_corr{i(k)}).CP_AP,0.4,[0.5/k 0.5/k 1],Corridors.(listes_corr{i(k)}).t(1,:),1,axes1);
        try
            h_corr_CP_AP = stdshade(Corridors.(listes_corr{i(k)}).CP_AP*1e-1-Offset_CPAP,0.3,colors{k},t,1,axes1,[],[],facK);
        catch more_than7corrs
            h_corr_CP_AP = stdshade(Corridors.(listes_corr{i(k)}).CP_AP*1e-1-Offset_CPAP,0.3,[(k-0.5)/length(i) (k-1)/length(i) k/length(i)],t,1,axes1,[],[],facK);
        end
        
        txt1 = listes_corr{i(k)};
        txt2 = [listes_corr{i(k)} '�1STD'];
        txt1(regexp(txt1,'_'))=' ';
        txt2(regexp(txt2,'_'))=' ';
        legendes{2*(k-1)+1} = txt1;
        legendes{2*k} = txt2;
    end
    ylabel(axes1,'D�placememt AP CP (cm)');
    axis tight
   
    legend(legendes);
    
    axes2 = axes( 'Parent', b1, ...
    'ActivePositionProperty', 'Position','xticklabel',[]);
    for k=1:length(i)
        t=(0:size(Corridors.(listes_corr{i(k)}).CP_ML,2)-1)*1/max(Corridors.(listes_corr{i(k)}).Fech);
        if isfield(Corridors.(listes_corr{i(k)}),'CP_ML_D') || isfield(Corridors.(listes_corr{i(k)}),'CP_ML_G')
            try
                Offset_CPMLD = nanmean(Corridors.(listes_corr{i(1)}).CP_ML_D(:,1))*1e-1;
                stdshade(Corridors.(listes_corr{i(k)}).CP_ML_D*1e-1-Offset_CPMLD,0.3,colors{k},t,1,axes2,[],[],facK);
            catch NO_CP_D
                disp('Pas de moyennage c�t� D!');
            end
            
            try
                Offset_CPMLG = nanmean(Corridors.(listes_corr{i(1)}).CP_ML_G(:,1))*1e-1;
                stdshade(Corridors.(listes_corr{i(k)}).CP_ML_G*1e-1-Offset_CPMLG,0.3,[colors{k} '--'],t,1,axes2,[],[],facK);
            catch NO_CP_G
                disp('Pas de moyennage c�t� G!');
            end
%             legend('Pied D','','Pied G','');
        else
            Offset_CPML = Sujet_tmp.(listes_corr{i(k)}).CP_ML(1)*1e-1;
            try
                h_corr_CP_ML = stdshade(Corridors.(listes_corr{i(k)}).CP_ML*1e-1-Offset_CPML,0.3,colors{k},t,1,axes2,[],[],facK);
            catch more_than7corrs
                h_corr_CP_ML = stdshade(Corridors.(listes_corr{i(k)}).CP_ML*1e-1-Offset_CPML,0.3,[(k-0.5)/length(i) (k-1)/length(i) k/length(i)],t,1,axes2,[],[],facK);
            end
        end
    end
    ylabel(axes2,'D�placememt ML CP (cm)');
    axis tight
    
    axes3 = axes( 'Parent', b1, ...
    'ActivePositionProperty', 'Position','xticklabel',[]);
    for k=1:length(i)
        t=(0:size(Corridors.(listes_corr{i(k)}).V_CG_AP,2)-1)*1/max(Corridors.(listes_corr{i(k)}).Fech);
        if get(findobj('tag','V_intgr'),'Value')
            try
                h_corr_CG_AP = stdshade(Corridors.(listes_corr{i(k)}).V_CG_AP,0.3,colors{k},t,1,axes3,[],[],facK);
            catch more_than7corrs
                h_corr_CG_AP = stdshade(Corridors.(listes_corr{i(k)}).V_CG_AP,0.3,[(k-0.5)/length(i) (k-1)/length(i) k/length(i)],t,1,axes3,[],[],facK);
            end
        else
            try
                h_corr_CG_AP = stdshade(Corridors.(listes_corr{i(k)}).V_CG_AP_d,0.3,colors{k},t,1,axes3,[],[],facK);
            catch more_than7corrs
                h_corr_CG_AP = stdshade(Corridors.(listes_corr{i(k)}).V_CG_AP_d,0.3,[(k-0.5)/length(i) (k-1)/length(i) k/length(i)],t,1,axes3,[],[],facK);
            end
        end
    end
    ylabel(axes3,'Vitesse CG AP (m/sec)');
    axis tight
    
    axes4 = axes( 'Parent', b1, ...
    'ActivePositionProperty', 'Position');
    xlabel(axes4,'Temps (sec)')
    
    %On recale les courbes de vitesses verticales au moment FC1
    T_FC1_base = Sujet_tmp.(listes_corr{i(1)}).tMarkers.FC1-Sujet_tmp.(listes_corr{i(1)}).tMarkers.T0;
    for k=1:length(i)
        fin = size(Corridors.(listes_corr{i(k)}).V_CG_Z,2);
        t=(0:fin-1)*1/max(Corridors.(listes_corr{i(k)}).Fech);
        V_CG_Z = Corridors.(listes_corr{i(k)}).V_CG_Z;
        
%         % Recalage sur FC1 (� revoir)
%         t_FC1 = Sujet_tmp.(listes_corr{i(k)}).tMarkers.FC1;%-Sujet_tmp.(listes_corr{i(k)}).tMarkers.T0;
% %         afficheX_v2(t_FC1,'.-k',axes4);
%         Offset_ind = round((t_FC1 - T_FC1_base)*Sujet_tmp.(listes_corr{1}).Fech);
%         
%         try
%             V_CG_Z_d = Corridors.(listes_corr{i(k)}).V_CG_Z_d;
%         catch NO_Vder
%             disp('Pas de vitesse d�riv�e');
%             V_CG_Z_d = NaN*ones(1,length(V_CG_Z));
%         end
%         if Offset_ind<0
%             V_CG_Z = [NaN*ones(size(V_CG_Z,1),abs(Offset_ind)) V_CG_Z(:,1:end-abs(Offset_ind))];
%             V_CG_Z_d = [NaN*ones(size(V_CG_Z_d,1),abs(Offset_ind)) V_CG_Z_d(:,1:end-abs(Offset_ind))];
%         else
%             V_CG_Z = [V_CG_Z(:,abs(Offset_ind)+1:end) zeros(size(V_CG_Z,1),abs(Offset_ind))];
%             V_CG_Z_d = [V_CG_Z_d(:,abs(Offset_ind)+1:end) zeros(size(V_CG_Z_d,1),abs(Offset_ind))];
%         end
        
        if get(findobj('tag','V_intgr'),'Value')
            try
                h_corr_CG_Z = stdshade(V_CG_Z,0.3,colors{k},t,1,axes4,[],[],facK);
            catch more_than7corrs
                h_corr_CG_Z = stdshade(V_CG_Z,0.3,[(k-0.5)/length(i) (k-1)/length(i) k/length(i)],t,1,axes4,[],[],facK);
            end
        else
            try
                h_corr_CG_Z = stdshade(V_CG_Z_d,0.3,colors{k},t,1,axes4,[],[],facK);
            catch more_than7corrs
                h_corr_CG_Z = stdshade(V_CG_Z_d,0.3,[(k-0.5)/length(i) (k-1)/length(i) k/length(i)],t,1,axes4,[],[],facK);
            end
        end
    end
    axis tight
%     afficheX_v2(T_FC1_base,'k',axes4);
%     y = get(h_corr_CG_Z,'YData');
%     text(T_FC1_base,max(y)/2,'\leftarrowFoot-Contact',...
% 	'VerticalAlignment','middle',...
% 	'HorizontalAlignment','left',...
% 	'FontSize',8,...
%     'Parent',axes4)
    
    ylabel(axes4,'Vitesse CG Z (m/sec)');

catch ERR
     waitfor(warndlg('!!!Pas de corridors calcul�s/s�lectionn�s!!!'));
end

% --- Execute when pressing corridor interface list
function list_Callback(hObj,eventdata,handles)
%% Affichage courbes avec corridors
global axes1 axes2 axes3 axes4 Sujet_tmp list listes_corr i t T_FC1_base
        
%R�cup�ration de l'acquisition s�l�ctionn�e et affichage � partir de T0
try
    contents = cellstr(get(list,'String'));
    acq_choisie = contents{get(list,'Value')};
    t_0 = Sujet_tmp.(acq_choisie).t(1);
    T0 = round((Sujet_tmp.(acq_choisie).tMarkers.T0-t_0)*Sujet_tmp.(acq_choisie).Fech);
    
    dimm = length(t);
    FC1 = round((Sujet_tmp.(acq_choisie).tMarkers.FC1-t_0)*Sujet_tmp.(acq_choisie).Fech) - T0;
    FC1_corr = round(T_FC1_base*Sujet_tmp.(listes_corr{i(1)}).Fech);
    decalage_V = abs(FC1 - FC1_corr);
    V_CG_Z = Sujet_tmp.(acq_choisie).V_CG_Z;
%     V_CG_Z_d = Sujet_tmp.(acq_choisie).V_CG_Z_d;
    diff = dimm - length(V_CG_Z(T0+decalage_V:end));
    
    
    if diff<0
        try
            V_CG_Z = V_CG_Z(T0+decalage_V:end+diff);
        catch Errt
            V_CG_Z = [Nan*ones(abs(T0+decalage_V),1) V_CG_Z(1:end+diff)];
        end
    else   
        try
            V_CG_Z = [V_CG_Z(T0+decalage_V:end);NaN*ones(diff,1)];
        catch Errrt
            V_CG_Z = [Nan*ones(abs(T0+decalage_V),1) V_CG_Z(1:end) NaN*ones(diff,1)];
        end
    end
    
    txt = acq_choisie;
    txt(regexp(acq_choisie,'_')) = ' ';
     
     Offset_CPAP = Sujet_tmp.(acq_choisie).CP_AP(1)*1e-1;%-Sujet_tmp.(listes_corr{i(1)}).CP_AP(1);
     try
        hh1 = plot(axes1,t,Sujet_tmp.(acq_choisie).CP_AP(T0:dimm+T0-1)*1e-1-Offset_CPAP,'r','Linewidth',1.5);
     catch Err_CPAP
         K_AP = length(Sujet_tmp.(acq_choisie).CP_AP);
         hh1 = plot(axes1,t(1:K_AP-T0+1),Sujet_tmp.(acq_choisie).CP_AP(T0:K_AP)*1e-1-Offset_CPAP,'r','Linewidth',1.5);
     end
         
     set(hh1,'Displayname',txt);
     affiche_label(hh1,txt,axes1);    axis(axes1,'tight');
     
     Offset_CPML = Sujet_tmp.(acq_choisie).CP_ML(1)*1e-1;%-Sujet_tmp.(listes_corr{i(1)}).CP_ML(1);
     try
        hh2 = plot(axes2,t,Sujet_tmp.(acq_choisie).CP_ML(T0:dimm+T0-1)*1e-1-Offset_CPML,'r','Linewidth',1.5);
     catch Err_CPML
         hh2 = plot(axes2,t(1:K_AP-T0+1),Sujet_tmp.(acq_choisie).CP_ML(T0:K_AP)*1e-1-Offset_CPML,'r','Linewidth',1.5);
     end
     
     set(axes2,'Visible','On');
     affiche_label(hh2,txt,axes2);    axis(axes2,'tight');
     
     try
         hh3 = plot(axes3,t,Sujet_tmp.(acq_choisie).V_CG_AP(T0:dimm+T0-1),'r','Linewidth',1.5);
     catch Err_V_CG
         hh3 = plot(axes3,t(1:K_AP-T0+1),Sujet_tmp.(acq_choisie).V_CG_AP(T0:K_AP),'r','Linewidth',1.5);
     end
     
     affiche_label(hh3,txt,axes3);    axis(axes3,'tight');
     
     hh4 = plot(axes4,t,V_CG_Z,'r','Linewidth',1.5);
     affiche_label(hh4,txt,axes4);    axis(axes4,'tight');
%      afficheX_v2(Sujet_tmp.(acq_choisie).tMarkers.FC1-Sujet_tmp.(acq_choisie).tMarkers.T0,'k',axes4);
     
catch ERR
    waitfor(warndlg('Fermer et recharger la fen�tre de visu des corrdidors!','Redraw corridors'));
end

% --- Execute when choosing to set subject data
function Data = subject_info(hObj,eventdata,handles)
%% Enregistrement des donn�es sujet
global Subject_data

prompt = {'ID','Nom','Sexe',...
        'Age (ans)','Pathologie'};

if ~isempty(Subject_data)    
    def = {num2str(Subject_data.ID),Subject_data.Name,Subject_data.Sexe,num2str(Subject_data.Age),Subject_data.Patho};
else
    def = {'ID','Nom','M','25','Sain'};
end

try
    rep = inputdlg(prompt,'Donn�es Sujet',1,def);
    Data.ID = rep{1};
    Data.Name = rep{2};
    Data.Sexe = rep{3};
    Data.Age = str2double(rep{4});
    Data.Patho = rep{5};
    
    Subject_data = Data;
catch ERR
    disp('Erreur acquisition donn�es sujet');
end

% --- Executes on button press in Visu_EMG.
function Visu_EMG_Callback(hObject, eventdata, handles)
%% Affichage et traitement de l'EMG
global Sujet Corridors EMG Corridors_EMG Histogram_EMG
% hObject    handle to Visu_EMG (see GCBO)
all = fieldnames(EMG);
existing = fieldnames(Sujet);
try
    moys = fieldnames(Corridors);
    
    %On vire les corridors
    similars_moy = sum(compare_liste(moys,existing),1);
    check_moy = similars_moy==0;
    existing = existing(check_moy);
catch ERR
    disp('Pas de corridors');
end 

%On comapre les 2 listes (EMG et Sujet pour ne pas prendre en compte les acquisitions effac�es et les corridors/moyennes
if size(all,1) > size(existing,1)
    similars = sum(compare_liste(all,existing),2);
else
    similars = sum(compare_liste(all,existing),1);
end

check = similars==1;
liste_a_traiter = all(check); %On garde que les acquisitions conserv�es

try
    moys_emg = fieldnames(Corridors_EMG);
    liste_a_traiter = [liste_a_traiter;moys_emg];
catch Errt
    disp('Pas de corridors EMGs');
end
    
%Choix de l'utilisateur
button = questdlg('Choix des acquisitions ?','Calcul EMG','Toutes','Liste','Manuelle','Toutes');
switch button
    case 'Liste'        
    liste_a_traiter = cellstr(get(findobj('tag','listbox1'),'String'));
    
    case 'Manuelle'
    %S�lections de l'utilisateur
    [acqs,v] = listdlg('PromptString',{'Choix des donn�es','Choix des acquisitions � traiter'},...
    'ListSize',[300 300],...
    'ListString',liste_a_traiter);
    liste_a_traiter = liste_a_traiter(acqs);
end

try
    histo_emg = fieldnames(Histogram_EMG);
    liste_a_traiter = [liste_a_traiter;histo_emg];
catch Errt
    disp('Pas d''hisotgrammes EMG');
end

affiche_emgs_v2(liste_a_traiter);

% --- Executes during object creation, after setting all properties.
function axes6_CreateFcn(hObject, eventdata, handles)
global haxes6
% hObject    handle to axes2 (see GCBO)
haxes6 = hObject;

function load_notocord_results(hObject, eventdata, handles)
%% Chargement de fichiers d�j� trait�s via NOTOCORD en mode Nouveau Sujet
global Sujet dossier EMG Resultats Notocord Corridors Idx Stops

try
%Choix manuel des fichiers
[files dossier] = uigetfile('*.mat','Choix du/des fichier(s) mat','Multiselect','on'); %%Ajouter plus tard les autres file types

%Initialisation
Sujet = {};
EMG = {};

% Conservation des vieux corridors/resulats ?
if ~isempty(Corridors) || ~isempty(Resultats)
    button = questdlg('Conserver Resultats/Corridors existants?','Nouveau Sujet','Oui','Non','Non');
    if strcmp(button,'Non')
        Resultats = {};
        Corridors = {};
    end
end

%Extraction des donn�es d'int�r�ts
button2 = questdlg('Ajouter � un sous-groupe?','Cr�ation Sous-Groupe','Oui','Non','Non');
    if strcmp(button2,'Oui')
        grp = cell2mat(inputdlg('Nom/Tag du sous-groupe?','Cr�ation Sous-Groupe',1));
    else
        grp = [];
    end
    
orders = zeros(length(files),2);
    for i=1:length(files)
        ff = cell2mat(files(i));
        tags = extract_tags(ff(1:end-4));
        num = str2double(cell2mat(tags(4)));
        orders(i,:) = [num i];
    end
orders = sortrows(orders);
    
[Sujet Resultats Idx Stops] = extraction_dataAPA_Notocord_v5(files,dossier(1:end-1),grp,orders(:,2));

%% Mise � jour interface et activation des boutons
set(findobj('tag','listbox1'), 'Visible','On');
set(findobj('tag','togglebutton1'),'Visible','On');
set(findobj('tag','AutoScale'),'Visible','On');
set(findobj('tag','Multiplot'),'Visible','On');
set(findobj('tag','Automatik_display'),'Visible','On');
set(findobj('tag','Results'), 'Visible','Off');
set(findobj('tag','Results'), 'Data',zeros(30,1));

set(findobj('Tag','sujet_courant'),'Enable','On');
set(findobj('Tag','subject_info'),'Enable','On');
set(findobj('Tag','excel_not'),'Enable','On');
set(findobj('Tag','add_not'),'Enable','On');
set(findobj('Tag','add_not_dir'),'Enable','On');
set(findobj('Tag','Delete_current'),'Visible','On');

%Activation des axes
axess = findobj('Type','axes');
for i=1:length(axess)
    set(axess(i),'Visible','On');
end

%Mise � jour de la liste
try
    set(findobj('tag','listbox1'), 'Value',1);
catch ERR
    disp('Liste non existante');
end
set(findobj('tag','listbox1'),'String',fieldnames(Sujet));

if length(files)>1
    set(findobj('tag','Group_APA'), 'Enable','On');
    set(findobj('tag','Clean_data'), 'Enable','On');
    set(findobj('tag','Calc_batch'), 'Enable','On');
end

set(findobj('tag','Visu_EMG'), 'Visible','On');
if ~isempty(EMG)
    set(findobj('tag','Visu_EMG'), 'Enable','On');
end

Notocord =1; %Flag de Notocord

catch ERR
    waitfor(warndlg('Annulation chargement fichiers!'));
end

function add_notocord_results(hObject, eventdata, handles)
%% Ajouter fichier(s) de session.mat au sujet/groupe courant
global Sujet dossier Resultats Idx Stops

try
%Choix manuel des fichiers
[files dossier] = uigetfile('*.mat','Choix du/des fichier(s) mat','Multiselect','on');

%Initialisation
Add_Sujet = {};
Add_Resultats = {};

%Extraction des donn�es d'int�r�ts
button = questdlg('Ajouter � un sous-groupe?','Cr�ation Sous-Groupe','Oui','Non','Non');
    if strcmp(button,'Oui')
        grp = cell2mat(inputdlg('Nom/Tag du sous-groupe?','Cr�ation Sous-Groupe',1));
    else
        grp = [];
    end
    
orders = zeros(length(files),2);
    for i=1:length(files)
        ff = cell2mat(files(i));
        tags = extract_tags(ff(1:end-4));
        num = str2double(cell2mat(tags(4)));
        orders(i,:) = [num i];
    end
orders = sortrows(orders);

[Add_Sujet Add_Resultats Idx_add Stops_add] = extraction_dataAPA_Notocord_v5(files,dossier(1:end-1),grp,orders(:,2));

% On fusionne les 2 structures en supposant que les noms de champs/acquisitions sont strictement diff�rents (sinon �craser en cas de noms de champs similaires)
Sujet = mergestruct(Sujet,Add_Sujet);
Resultats  = mergestruct(Resultats,Add_Resultats);
Idx = [Idx; Idx_add];
Stops_add =  Stops_add + Stops(end) - 1;
Stops = [Stops; Stops_add];

% Mise � jour de la liste
set(findobj('tag','listbox1'), 'Value',1);
button2 = questdlg('Ajouter � liste actuelle ?','Mise � jour de la liste','Ajouter','Afficher tout','Ajouter');
if strcmp(button2,'Ajouter')
    liste_actuelle = cellstr(get(findobj('tag','listbox1'),'String'));
    set(findobj('tag','listbox1'),'String',[liste_actuelle; fieldnames(Add_Sujet)]);
else
    set(findobj('tag','listbox1'),'String',fieldnames(Sujet));
end

catch ERR
    warndlg('!Erreur ajout session!');
end

function load_notocord_results_dir(hObject, eventdata, handles)
%% Chargement d'un dossier d�j� trait� via NOTOCORD en mode Nouveau Sujet
    global Sujet dossier EMG Resultats Notocord Corridors Subject_data Idx Stops

try
    %Choix du dossier et extraction de la liste des fichiers existants
    dossier = uigetdir(pwd,'Repertoire de stockage des sessions par sujet') ;
    list_rep= dir(dossier) ;
    list_rep(1) = [];
    list_rep(1) = [];

    %Initialisation
    Sujet = {};
    EMG = {};
    Subject_data = {};

    % Conservation des vieux corridors/resulats ?
    if ~isempty(Corridors) || ~isempty(Resultats)
        button = questdlg('Conserver Resultats/Corridors existants?','Nouveau Sujet','Oui','Non','Non');
        if strcmp(button,'Non')
            Resultats = {};
            Corridors = {};
        end
    end

    %% Extraction des fichiers et donn�ers utiles
%     filetype = '_sessions.mat';
%     files = extrait_liste_acquisitions(list_rep,filetype);
    files = extrait_liste_sessions(list_rep);
    orders = zeros(length(files),2);
    for i=1:length(files)
        ff = cell2mat(files(i));
        tags = extract_tags(ff(1:end-4));
        num = str2double(cell2mat(tags(4)));
        orders(i,:) = [num i];
    end
    orders = sortrows(orders);
    %Extraction des donn�es d'int�r�ts
    button2 = questdlg('Ajouter � un sous-groupe?','Cr�ation Sous-Groupe','Oui','Non','Non');
    if strcmp(button2,'Oui')
        grp = cell2mat(inputdlg('Nom/Tag du sous-groupe?','Cr�ation Sous-Groupe',1));
    else
        grp = [];
    end
    
    [Sujet Resultats Idx Stops] = extraction_dataAPA_Notocord_v5(files,dossier,grp,orders(:,2));

    %% Mise � jour interface et activation des boutons
    set(findobj('tag','listbox1'), 'Visible','On');
    set(findobj('tag','togglebutton1'),'Visible','On');
    set(findobj('tag','AutoScale'),'Visible','On');
    set(findobj('tag','Multiplot'),'Visible','On');
    set(findobj('tag','Automatik_display'),'Visible','On');
    set(findobj('tag','Results'), 'Visible','Off');
    set(findobj('tag','Results'), 'Data',zeros(30,1));

    set(findobj('Tag','sujet_courant'),'Enable','On');
    set(findobj('Tag','subject_info'),'Enable','On');
    set(findobj('Tag','excel_not'),'Enable','On');
    set(findobj('Tag','add_not'),'Enable','On');
    set(findobj('Tag','add_not_dir'),'Enable','On');
    set(findobj('Tag','Delete_current'),'Visible','On');

    %Activation des axes
    axess = findobj('Type','axes');
    for i=1:length(axess)
        set(axess(i),'Visible','On');
    end

    %Mise � jour de la liste
    try
        set(findobj('tag','listbox1'), 'Value',1);
    catch ERR
        disp('Liste non existante');
    end
    set(findobj('tag','listbox1'),'String',fieldnames(Sujet));

    if length(files)>1
        set(findobj('tag','Group_APA'), 'Enable','On');
        set(findobj('tag','Clean_data'), 'Enable','On');
        set(findobj('tag','Calc_batch'), 'Enable','On');
    end

    set(findobj('tag','Visu_EMG'), 'Visible','On');
    if ~isempty(EMG)
        set(findobj('tag','Visu_EMG'), 'Enable','On');
    end

    Notocord = 1; %Flag de Notocord

catch ERR
    waitfor(warndlg('Annulation chargement fichiers!'));
end

function add_notocord_results_dir(hObject, eventdata, handles)
%% Ajouter dossier de session.mat au sujet/groupe courant
global Sujet dossier Resultats Idx Stops

try
    %Choix du dossier et extraction de la liste des fichiers existants
    dossier = uigetdir(pwd,'Repertoire de stockage des sessions') ;
    list_rep= dir(dossier) ;
    list_rep(1) = [];
    list_rep(1) = [];

    %Initialisation
    Add_Sujet = {};
    Add_Resultats = {};

    %Extraction des donn�es d'int�r�ts
    button = questdlg('Ajouter � un sous-groupe?','Cr�ation Sous-Groupe','Oui','Non','Non');
        if strcmp(button,'Oui')
            grp = cell2mat(inputdlg('Nom/Tag du sous-groupe?','Cr�ation Sous-Groupe',1));
        else
            grp = [];
        end
    
    % Extraction des fichiers et donn�ers utiles
%     filetype = '_sessions.mat';
%     files = extrait_liste_acquisitions(list_rep,filetype);
    files = extrait_liste_sessions(list_rep);
    orders = zeros(length(files),2);
    for i=1:length(files)
        ff = cell2mat(files(i));
        tags = extract_tags(ff(1:end-4));
        num = str2double(cell2mat(tags(4)));
        orders(i,:) = [num i];
    end
    orders = sortrows(orders);

    [Add_Sujet Add_Resultats Idx_add Stops_add] = extraction_dataAPA_Notocord_v5(files,dossier,grp,orders(:,2));

    % On fusionne les 2 structures en supposant que les noms de champs/acquisitions sont strictement diff�rents (sinon �craser en cas de noms de champs similaires)
    Sujet = mergestruct(Sujet,Add_Sujet);
    Resultats  = mergestruct(Resultats,Add_Resultats);
    Idx = [Idx; Idx_add];
    Stops_add =  Stops_add + Stops(end)-1;
    Stops = [Stops; Stops_add];
    
    % Mise � jour de la liste
    set(findobj('tag','listbox1'), 'Value',1);
    button2 = questdlg('Ajouter � liste actuelle ?','Mise � jour de la liste','Ajouter','Afficher tout','Ajouter');
    if strcmp(button2,'Ajouter')
        liste_actuelle = cellstr(get(findobj('tag','listbox1'),'String'));
        set(findobj('tag','listbox1'),'String',[liste_actuelle; fieldnames(Add_Sujet)]);
    else
        set(findobj('tag','listbox1'),'String',fieldnames(Sujet));
    end

catch ERR
    wrndlg('!Erreur ajout dossier de sessions!');
end

function export_excel_notocord(hObject, eventdata, handles)
    %% --- Exporter Tableau des Resultats Notocord ---
        global Resultats Idx Stops
        options.Resize = 'On';
        fichier = cell2mat(inputdlg({'Nom du fichier/sujet'} ,'Ecriture .xls',1,{'Synth�se'},options));
%         ecrireAPA_xls_Claire_v2(Resultats,[fichier '.xls'],cd,Idx);
        space = max(Idx(:,3)) + 2;
        ecrireAPA_xls_Claire_v3(Resultats,[fichier '.xls'],cd,Stops,space);
            
% --- Executes on button press in Clean_corridor.
function Clean_corridor_Callback(hObject, eventdata, handles)
%% Retirer un corridor si mauvais
global Sujet Corridors Resultats Corridors_EMG EMG Activation_EMG_percycle LFP Corridors_LFP
% hObject    handle to Clean_corridor (see GCBO)

try
listes_corr = fieldnames(Corridors);
%S�lections de l'utilisateur
[i,v] = listdlg('PromptString',{'Choix du/des corridor(s) � effacer'},...
    'ListSize',[300 300],...
    'ListString',listes_corr,'SelectionMode','Multiple');

for corrd=1:length(i)
    try
        Sujet = rmfield(Sujet,listes_corr{i(corrd)});
        Resultats = rmfield(Resultats,listes_corr{i(corrd)});
        EMG = rmfield(EMG,listes_corr{i(corrd)});
        LFP = rmfield(LFP,listes_corr{i(corrd)});
    catch ERr_S
    end
    Corridors = rmfield(Corridors,listes_corr{i(corrd)});
    Corridors_EMG = rmfield(Corridors_EMG,listes_corr{i(corrd)});
    Activation_EMG_percycle = rmfield(Activation_EMG_percycle,listes_corr{i(corrd)});
    Corridors_LFP = rmfield(Corridors_LFP,listes_corr{i(corrd)});
end

disp('Corridors supprim�s');
listes_corr{i}

listes_corr_post = fieldnames(Corridors);
if isempty(listes_corr_post)
    set(findobj('tag','Affich_corridor'), 'Enable','Off');
    set(findobj('tag','Clean_corridor'), 'Enable','Off');
end
    
catch ERR
    warndlg('!!Pas de Corridors calcul�s!!')
end

% --- Executes on button press in Delete_current.
function Delete_current_Callback(hObject, eventdata, handles)
global Sujet acq_courante Resultats EMG LFP
% hObject    handle to Delete_current (see GCBO)
list_Object = findobj('Tag','listbox1');
contents = get(list_Object,'String');
pos = get(list_Object,'Value');

%V�rification que l'acquisition existe et mise � jour de la liste
if isfield(Sujet,acq_courante)
    %Supression de l'acquisition s�l�ctionn�
    Sujet = rmfield(Sujet,acq_courante);
    EMG = rmfield(EMG,acq_courante);
    
    try
        Resultats = rmfield(Resultats,acq_courante);
    catch ERR_noresult
    end
    
    try
        LFP = rmfield(LFP,acq_courante);
    catch ERR_nolfp
    end
    
end
contents(pos)=[];
set(list_Object,'String',contents);
try
    set(list_Object,'Value',pos);
    acq_courante = contents{pos};
catch Err
    set(list_Object,'Value',1);
    acq_courante = contents{1};
end

% --- Executes on button press in Export_trigs.
function Export_trigs_Callback(hObject, eventdata, handles)
%% Fonction d'export des �v�nements temporels par rapport � la pr�sence �ventuelle d'un trigger num�rique
% hObject    handle to Export_trigs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Sujet Resultats Subject_data Activation_EMG LFP e_lena e_multi

% Calculs
liste = fieldnames(LFP); %% On extrait la liste des essais valides
% liste = fieldnames(Sujet);

wb = waitbar(0);
set(wb,'Name','Please wait... Exporting trigger data');

Resultats_new={};
Export={};
for i=1:length(liste)
    waitbar(i/length(liste)-1,wb,['V�rification acquisition: ' liste{i}]);
    if isfield(Sujet.(liste{i}),'Trigger')
        if ~isfield(Resultats,liste{i})
           Resultats.(liste{i}) = calculs_parametres_initiationPas_v1(Sujet.(liste{i}));
        end
        if isfield(Sujet.(liste{i}),'Trigger_LFP')
            Resultats_new.(liste{i}) = calculs_parametres_initiationPas_v2(Sujet.(liste{i}));
        end
        Export.(liste{i}).tTrig_Debut_essai = Resultats.(liste{i}).tTrig_Debut_essai;
        try
            T_trig_lfp = Sujet.(liste{i}).Trigger_LFP;
            Export.(liste{i}).Trigger_LFP = Sujet.(liste{i}).Trigger_LFP;
        catch NO_LFP
            Export.(liste{i}).Trigger_LFP = NaN;
            T_trig_lfp = 0;
        end
        
        T_trig = Sujet.(liste{i}).Trigger;
        if isempty(T_trig)
            T_trig = NaN;
            disp(['Pas de synchro pour l''acquisition: ' liste{i}]);
        end   
        Export.(liste{i}).Trigger = T_trig;
        
        try
            Onset_EMG_TA = min([Activation_EMG.(liste{i}).RTA(1,1) Activation_EMG.(liste{i}).LTA(1,1)]); %Debut inhibition
            Export.(liste{i}).Onset_TA = Sujet.(liste{i}).tMarkers.Onset_TA;
            Export.(liste{i}).tTrig_Onset_TA =  T_trig_lfp + (Onset_EMG_TA - T_trig);
        catch NO_EMG
            disp(['EMG non trait� ' liste{i}]);
            Export.(liste{i}).Onset_TA = NaN;
            Export.(liste{i}).tTrig_Onset_TA = NaN;
        end
        
        % Base temp LFP/EEG
        Export.(liste{i}).tTrig_T0 = Resultats_new.(liste{i}).tTrig_T0;
        Export.(liste{i}).tTrig_HO = Resultats_new.(liste{i}).tTrig_HO;
        Export.(liste{i}).tTrig_TO = Resultats_new.(liste{i}).tTrig_TO;
        Export.(liste{i}).tTrig_FC1 = Resultats_new.(liste{i}).tTrig_FC1;
        Export.(liste{i}).tTrig_FO2 = Resultats_new.(liste{i}).tTrig_FO2;
        Export.(liste{i}).tTrig_FC2 = Resultats_new.(liste{i}).tTrig_FC2;
        
        % Base temp PF (utile uniquement si enregistrement continu - Notocord)
        Export.(liste{i}).T0 = Sujet.(liste{i}).tMarkers.T0;
        Export.(liste{i}).HO = Sujet.(liste{i}).tMarkers.HO;
        Export.(liste{i}).TO = Sujet.(liste{i}).tMarkers.TO;
        Export.(liste{i}).FC1 = Sujet.(liste{i}).tMarkers.FC1;
        Export.(liste{i}).FO2 = Sujet.(liste{i}).tMarkers.FO2;
        Export.(liste{i}).FC2 = Sujet.(liste{i}).tMarkers.FC2;      
    end
end
if isempty(Subject_data)
    Subject_data = subject_info();
end
% Export Excel
button = questdlg('Export Excel?','Exporter Trigger/Temps sous Excel?','Oui','Non','Non');
if strcmp(button,'Oui')
    fichier = inputdlg({'Nom du fichier/sujet' 'Nom de la feuille/session'},'Ecriture .xls',1,{Subject_data.ID 'Triggers'});
    ecrireQR_xls(Export,[fichier{1} '.xls'],fichier{2});
end
close(wb);

% Export du vecteur temporel des evts (base PF) format Lena
try
    button = questdlg('Type d''export?','Export pistes techniques base temporelle LFP(.ptx) ou PF(.txt)','ptx','txt','Les 2','Les 2');
    switch button
        case 'ptx'
            e_lena = ecrire_evts_ptx(Export,0);
        case 'txt'
            e_lena = ecrire_evts_ptx(Export,1);
        case 'Les 2'
%             e_lena = ecrire_evts_ptx(Export,2);
            [e_lena e_multi] = ecrire_evts_ptx_v2(Export,Resultats,2);
    end
    
catch Err
    disp('Pas d''export pistes techniques');
end

function load_lfp(hObject, eventdata, handles)
%% Charger fichier lfp
global Sujet LFP LFP_raw LFP_base Resultats Notocord h_lena b_lena LFP_lena hdr
[files dossier] = uigetfile('*.edf; *.trc; *.Poly5','Choix du fichier LFP','Multiselect','off');
ext = extract_filetype(files);
switch lower(ext)
    case 'edf'
        [hdr,col]=edfRead(strcat(dossier,files));
        hdr.fs = 512; %Hz
    case 'trc'
        [hdr,col]=trc_read_lfp(strcat(dossier,files));
        hdr.fs = 512; %Hz
    case 'poly5'
        [hdr col] = tms_read_to_edf_struct(strcat(dossier,files));
    otherwise
        return
end

% Concat�nation/ajout d'un autre fichier d'enregistrement (cas de plusieurs fichiers d�coup�s)
button = questdlg('Concat�ner d''autre(s) fichier(s)?','Multi-enregistrements','Oui','Non','Non');
if strcmp(button,'Oui')
    [files_add dossier] = uigetfile('*.edf; *.trc; *.Poly5','Choix du fichier LFP','Multiselect','on');
    if ischar(files_add)
        files_add = {files_add};
    end
    files_add = sort(files_add);
    for fa=1:length(files_add)
        ext = extract_filetype(files_add{fa});
        switch lower(ext)
            case 'edf'
                [hdr2,col2]=edfRead(strcat(dossier,files_add{fa}));
            case 'trc'
                [hdr2,col2]=trc_read_lfp(strcat(dossier,files_add{fa}));
            case 'poly5'
                [hdr2,col2] = tms_read_to_edf_struct(strcat(dossier,files_add{fa}));
            otherwise
                return
        end
        try
            col = [col col2];
        catch err
            disp('Pas d''ajouts! Nombre de canaux non �gales dans les 2 fichiers LFP!');
        end
    end
end

% Cr�ation des structures pour export .lena
% button = questdlg('Regrouper Contacts?','Pooling/Super_sensors - Export .lena','Oui','Non','Non');
% if strcmp(button,'Oui')
%     pool=1;
% else
%     pool=0;    
% end

% Pr�conditionnement pour export .lena
try
    [h_lena b_lena] = create_lena_structs(hdr,col);
catch Err_Lena
    disp('Erreur conditionnement .lena!');
    h_lena = {};
    b_lena = NaN;
end

LFP = {};
LFP_raw = {};
LFP_base = {};
LFP_base.Fech = hdr.fs; % On stock la fr�quence d'�chantillonnage des LFPs dans une variable globale
channels = hdr.label(1,2:end)';

%% Pr�traitement du signal LFP continu
col_post = Pretraitement_LFP(col,hdr.fs);

%% Extraction trigger du fichier LFP
Trigger = clean_trigger_v2(col(1,:),hdr.fs);
N_trigs = sum(Trigger);
ind_trigs = find(Trigger==1);
t_trigs = ind_trigs/hdr.fs;

button = questdlg([num2str(N_trigs) '  TOPs d�tect�s dans le fichier LFP, faire les correspondances de mani�re automatique?'],'Associations Triggers-Acquisitions','Automatique','Manuelle','Importer','Automatique');
switch button
    case 'Automatique'
        [file_sync dossier_sync] = uigetfile({'*.xls;*.xlsx'},'Choix du fichier de synchronisation Acquisitions','Multiselect','off');
        [liste_acqs_lfp n_trig] = extract_sync_lfp(strcat(dossier_sync,file_sync));
%         liste_acqs_lfp = extract_sync_lfp(strcat(dossier_sync,file_sync));
        if length(liste_acqs_lfp)~=N_trigs
            button2 = questdlg(['Nombres de triggers PF(' num2str(length(liste_acqs_lfp)) ')/LFP(' num2str(N_trigs) ') non correspondants! Continuer?'],'Synchro','Oui','Non','Oui');
            if strcmp(button2,'Non')
                return
            else
                N_trigs = length(liste_acqs_lfp);
                try
                    ind_trigs = ind_trigs(n_trig);
                catch err_trigs_match
                    % On refait la detection des triggers
                    disp('... Re-d�tection des Triggers!');
                    if N_trigs<max(n_trig) % Moins de triggers d�tect�
                        Trigger = clean_trigger_v2(col(1,:),hdr.fs,2,2.5); % On diminue le seuil de d�tection
                    else % Plus de triggers
                        Trigger = clean_trigger_v2(col(1,:),hdr.fs,2,1.5); % On augmente le seuil de d�tection
                    end
                    
                    ind_trigs = find(Trigger==1);
                    ind_trigs = ind_trigs(n_trig);
                    t_trigs = ind_trigs/hdr.fs;  
                end
            end
        end
    case 'Manuelle' % Pour chaque trigger ou choisit l'acquisition correspondante
        listes_acqs = fieldnames(Sujet);
        liste_acqs_lfp = {};
        a=0;
        for l=1:N_trigs
            [acqs,v] = listdlg('PromptString',{'Liste des acquisitions charg�s',['Acquisition - Trigger N� ' num2str(l)]},...
                'ListSize',[300 300],...
                'ListString',listes_acqs,...
                'SelectionMode','single');
            if v
                a=a+1;
                liste_acqs_lfp(a) = listes_acqs(acqs);
                listes_aqs(acqs)=[];
            end
                
        end
    otherwise
        [file_sync dossier_sync] = uigetfile({'*.xls;*.xlsx'},'Choix du fichier de synchronisation Temps-Acquisition','Multiselect','off');
        [liste_acqs_lfp t_trigs] = extract_sync_lfp(strcat(dossier_sync,file_sync));
        N_trigs = length(t_trigs);
        ind_trigs = floor(t_trigs*hdr.fs); % On passe des temps au indices
end

LFP_lena = {};
for l=1:N_trigs
  
    Sujet.(liste_acqs_lfp{l}).Trigger_LFP = t_trigs(l); % Stockage du temps dans la base LFP
     Fech_pf = Sujet.(liste_acqs_lfp{l}).Fech;
    if ~isfield(Resultats.(liste_acqs_lfp{l}),'tTrig_Debut_essai') 
        Resultats.(liste_acqs_lfp{l}) = calculs_parametres_initiationPas_v1(Sujet.(liste_acqs_lfp{l}));
    end
    % Alignement des donn�es
    if Notocord
        ind_debut = ind_trigs(l) + floor((Resultats.(liste_acqs_lfp{l}).tTrig_Debut_essai)/hdr.fs); % PPN: enregistrement continu des donn�es PF et Triggers avant marqueur du debut d'essai
    else
        ind_debut = ind_trigs(l) - floor((Resultats.(liste_acqs_lfp{l}).tTrig_Debut_essai)*hdr.fs); % GBMOV: enregistrement essai/essai et Trigger=GO
    end
    
%     duree_essai = length(Sujet.(liste_acqs_lfp{l}).t)/Fech_pf;
    duree_essai = Sujet.(liste_acqs_lfp{l}).t(end) - Sujet.(liste_acqs_lfp{l}).t(1)+1/Fech_pf;
%     ind_fin = ind_trigs(l) + floor(duree_essai*fs);
    ind_fin = ind_debut + floor(duree_essai*hdr.fs);
    
    try
        LFP_lena.(liste_acqs_lfp{l}).Trigger = col(1,ind_trigs(l)- 2*hdr.fs:ind_trigs(l) + 5*hdr.fs); % Triger sur l'essai [-2 +5] (export .lena)
    catch err
        fill_nans = zeros(1,abs(ind_trigs(l)- 2*hdr.fs)+1);
        LFP_lena.(liste_acqs_lfp{l}).Trigger = [fill_nans col(1,1:ind_trigs(l) + 5*hdr.fs)]; % Triger sur l'essai [-2 +5] (export .lena)
    end
    
    for c=1:length(channels)
        data = col_post(c+1,ind_debut:ind_fin); %Apr�s l'instruction de marche et sur la dur�e de l'essai
        
        try
            data_base = col_post(c+1,ind_debut - 2*hdr.fs:ind_debut-1); %Avant l'instruction de marche et sur une fen�tre de dur�e 2 secondes
            % Donn�es binaires pour export .lena
            data_lena = col(c+1,ind_trigs(l)- 2*hdr.fs:ind_trigs(l) + 5*hdr.fs); %2 secondes avant l'instruction de marche jusqu'� 5 secondes apr�s
        catch not_enough_pre_data
            data_base = NaN*ones(1,2*hdr.fs);
            data_base(end-ind_debut+1:end)= col_post(c+1,1:ind_debut);
            data_lena = [NaN*ones(1,2*hdr.fs - ind_trigs(l)+1) col(c+1,1:ind_trigs(l) + 5*hdr.fs)]; %2 secondes avant l'instruction de marche jusqu'� 5 secondes apr�s
        end
        
        try
            LFP.(liste_acqs_lfp{l}).(['Contact' channels{c}]) = data(1:hdr.fs/Fech_pf:end); % On reechantillone pour aligner sur le temps
            LFP_raw.(liste_acqs_lfp{l}).(['Contact' channels{c}]) = data;
            LFP_base.(liste_acqs_lfp{l}).(['Contact' channels{c}]) = data_base;% (1:hdr.fs/Fech_pf:end); Non reechantillonn�s
        catch ERR
            disp([ERR.message ' not loaded!']);
        end
        
        try
            LFP_lena.(liste_acqs_lfp{l}).(['Contact' channels{c}]) = data_lena;
        catch err_lena
            disp(['Donn�es binaires lena non conditionn�es: ' liste_acqs_lfp{l}]);
            LFP_lena.(liste_acqs_lfp{l}).(['Contact' channels{c}]) = NaN*ones(7*hdr.fs);
        end
            
    end
    set(findobj('tag','visu_lfp'), 'Enable','On');
    set(findobj('tag','Visu_multiple'), 'Enable','On');
    if ~isempty(h_lena)
        set(findobj('Tag','lena_out'),'Enable','On');
    end
end

function export_lena(hObject, eventdata, handles)
%% Export structures .Lena
global Subject_data h_lena b_lena e_lena e_multi hdr LFP_lena LFP_tri Resultats

if isempty(e_lena)
    warndlg('Structure des Ev�nements non cr��e/export�e!');
end
dossier = uigetdir(pwd,'Repertoire de stockage des .mat pour export LENA') ;

save_var = [dossier '\' Subject_data.ID '_lena'];
h = h_lena; b = b_lena; e = e_lena;
eval(['save ' save_var ' h b e']);

save_var_m = [dossier '\' Subject_data.ID '_Dec_lena'];
button = questdlg('Ordonner/Trier Contacts?','Contra/Ipsi - Export .lena','Oui','Non','Non');
if strcmp(button,'Oui')
    pool=1;
else
    pool=0;
end

try
    [h_multi b_multi] = create_lena_structs_multi(hdr,LFP_lena,LFP_tri,Resultats,pool);
    h = h_multi; b = b_multi; e = e_multi;
    eval(['save ' save_var_m ' h b e']);
catch err_m
    disp('Pas d''export lena d�coup�');
end

% --- Executes on button press in visu_lfp.
function visu_lfp_Callback(hObject, eventdata, handles)
%% Visualiser LFP
global LFP PE
% hObject    handle to visu_lfp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    liste_lfps = fieldnames(LFP);
catch ERR_LFP
    errordlg('Pas de LFP charg�s!');
    set(findobj('tag','visu_lfp'), 'Enable','Off');
end


try
    liste_pe = fieldnames(PE);
catch NO_PE
    PE={};
    liste_pe = [];
    disp('Pas de PE calcul�');
end

affiche_lfps_beta_v5([liste_lfps;liste_pe]);

% --- Executes on button press in Visu_multiple.
function Visu_multiple_Callback(hObject, eventdata, handles)
%% Visualisation multiple de donn�es
global Sujet Corridors EMG Corridors_EMG LFP Corridors_LFP
% hObject    handle to Visu_multiple (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    liste = fieldnames(LFP);
    % Choix utilisateur des donn�es PF
    PF = {'CP_AP' 'CP_ML' 'V_CG_AP' 'V_CG_Z' 'Acc_Z'};
    try
        [check_pf,v] = listdlg('PromptString',{'Choisir les donn�es Plateformes � afficher','Liste donn�es analogiques PF'},...
                    'ListSize',[150 80],...
                    'ListString',PF);

        PF = PF(check_pf);
    catch NO_selectionPF
        PF={};
    end
    
    % Choix utilisateur des donn�es EMG
    muscles = EMG.(liste{1}).nom;
    try
        [check_m,v] = listdlg('PromptString',{'Choisir les EMG � afficher','Liste donn�es analogiques EMG'},...
                    'ListSize',[150 80],...
                    'ListString',muscles);

        muscles = check_m;
    catch NO_selectionEMG
        muscles=[];
    end
    
    % Choix utilisateur des donn�es LFP
    if ~isempty(LFP)
        contacts = fieldnames(LFP.(liste{1}));
        try
        [check_l,v] = listdlg('PromptString',{'Choisir les LFP � afficher','Liste donn�es analogiques EMG'},...
                    'ListSize',[150 100],...
                    'ListString',contacts);

        contacts = contacts(check_l);
        catch NO_selectionLFP
            contacts={};
        end
    else
        contacts ={};
    end
    
    affiche_multidata_v2(liste,PF,muscles,contacts);
    
catch ERR_visumulti
    disp('Arr�t multivisu!');
end


% --- Executes on button press in PlotPF.
function PlotPF_Callback(hObject, eventdata, handles)
%% Affichage de la trajectoire du CP sur la PF
global haxes6 Sujet acq_courante
% hObject    handle to PlotPF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PlotPF

flagPF=get(findobj('tag','PlotPF'),'Value');
set(haxes6,'NextPlot','replace');
if flagPF
    set(findobj('Tag','Acc_txt'),'String','Trajectoire CP');
    plot(haxes6,Sujet.(acq_courante).CP_AP,Sujet.(acq_courante).CP_ML);
    xlabel(haxes6,'Axe Ant�ropost�rieur(mm)','FontName','Times New Roman','FontSize',10);
    ylabel(haxes6,'Axe M�dio-Lat�ral (mm)','FontName','Times New Roman','FontSize',10);
else
    set(findobj('Tag','Acc_txt'),'String','Acc�l�ration/Puissance CG');
    xlabel(haxes6,'Temps (s)','FontName','Times New Roman','FontSize',10);
    try
        plot(haxes6,Sujet.(acq_courante).t,Sujet.(acq_courante).Puissance_CG); afficheY_v2(0,':k',haxes6);
        ylabel(haxes6,'Puissance (Watt)','FontName','Times New Roman','FontSize',12);
    catch Err       
        plot(haxes6,Sujet.(acq_courante).t,Sujet.(acq_courante).Acc_Z); afficheY_v2(0,':k',haxes6);
        ylabel(haxes6,'Axe vertical(m�/s)','FontName','Times New Roman','FontSize',10);
    end
end
