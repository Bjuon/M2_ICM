function varargout = Test_APA_v0i(varargin)
% TEST_APA_V0I MATLAB code for Test_APA_v0i.fig
%      TEST_APA_V0I, by itself, creates a new TEST_APA_V0I or raises the existing
%      singleton*.
%
%      H = TEST_APA_V0I returns the handle to a new TEST_APA_V0I or the handle to
%      the existing singleton*.
%
%      TEST_APA_V0I('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST_APA_V0I.M with the given input arguments.
%
%      TEST_APA_V0I('Property','Value',...) creates a new TEST_APA_V0I or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Test_APA_v0i_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Test_APA_v0i_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Test_APA_v0i

% Last Modified by GUIDE v2.5 15-May-2012 12:11:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Test_APA_v0i_OpeningFcn, ...
                   'gui_OutputFcn',  @Test_APA_v0i_OutputFcn, ...
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

% --- Executes just before Test_APA_v0i is made visible.
function Test_APA_v0i_OpeningFcn(hObject, eventdata, handles, varargin)
global haxes1 haxes2 haxes3 haxes4 haxes6 h_marks_T0 h_marks_HO h_marks_TO h_marks_FC1 h_marks_FO2 h_marks_FC2
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Test_APA_v0i (see VARARGIN)

% Choose default command line output for Test_APA_v0i
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Test_APA_v0i wait for user response (see UIRESUME)
% uiwait(handles.figure1);
set(gcf,'Name','Calcul des APA v.0i');

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

%Initialisation des �tats d'affichages pour la vitesse
set(findobj('tag','V_intgr'),'Value',1); %Int�gration
set(findobj('tag','V_der'),'Value',0); %D�rivation

%FILE MENU
h = uimenu('Parent',hObject,'Label','FILE','Tag','menu_fichier','handlevisibility','On') ;
h1= uimenu(h,'Label','NOUVEAU SUJET','handlevisibility','on') ;
uimenu(h1,'Label','Charger acquisitions','Callback',@uipushtool1_ClickedCallback);
uimenu(h1,'Label','Charger dossier','Callback',@uipushtool2_ClickedCallback) ; %% uipushtool2_ClickedCallback(findobj('tag','uipushtool2'), eventdata, handles))
h2 = uimenu(h,'Label','SUJET COURANT','handlevisibility','on','Tag','sujet_courant','Enable','off') ;
uimenu(h2,'Label','Ajouter acquistions','Callback',@ajouter_acquisitions) ;
uimenu(h2,'Label','Ajouter dossier','Callback',@ajouter_dossier) ;

uimenu(h,'Label','CHARGER SUJET','handlevisibility','On','Callback',@uipushtool4_ClickedCallback) ; %% uipushtool4_ClickedCallback(findobj('tag','uipushtool4'), eventdata, handles))
uimenu(h,'Label','DONNEES SUJET','handlevisibility','On','Tag','subject_info','Callback',@subject_info,'Enable','off') ;

%GROUP MENU
g = uimenu('Parent',hObject,'Label','GROUPE','handlevisibility','On') ;
uimenu(g,'Label','NOUVEAU GROUPE','handlevisibility','on','Callback',@Group_subjects_Callback) ;
uimenu(g,'Label','CHARGER GROUPE','handlevisibility','on','Callback',@Group_subjects_load,'Enable','off') ;

% NOTOCORD load MENU
n = uimenu('Parent',hObject,'Label','Notocord','Tag','menu_notocord','handlevisibility','On','Enable','off') ;
uimenu(n,'Label','Charger acquisitions (*.xls)','Callback',@load_notocord_files); %%Cr�eer les fonctions plus tard
uimenu(n,'Label','Charger dossier/sujet (*.xls)','Callback',@load_notocord_dir) ;
uimenu(n,'Label','Charger resultats (*.mat)','Callback',@load_notocord_results) ;
uimenu(n,'Label','Charger dossier de resultats (*.mat)','Callback',@load_notocord_results_dir) ;

% --- Outputs from this function are returned to the command line.
function varargout = Test_APA_v0i_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
%% Choix/Click dans la liste actualis�e
global haxes1 haxes2 haxes3 haxes4 haxes6 Sujet acq_courante flag_afficheV
% hObject    handle to listbox1 (see GCBO)

%R�cup�ration de l'acquisition s�l�ctionn�e
contents = cellstr(get(hObject,'String'));
acq_courante = contents{get(hObject,'Value')};

%V�rification que l'acquisition existe sinon mise � jour de la liste
if ~isfield(Sujet,acq_courante)
    contents(get(hObject,'Value'))=[];
    set(hObject,'String',contents);
    set(hObject,'Value',1);
    acq_courante = contents{1};
end

% On check la pr�sence de donn�es de vitesse d�riv� (pour l'affichage)
flag_der = isfield(Sujet.(acq_courante),{'V_CG_AP_d' 'V_CG_Z_d'});
% flag_der = ~isempty(Sujet.(acq_courante),{'V_CG_AP_d' 'V_CG_Z_d'});
if flag_der
    set(findobj('tag','V_der'),'Enable','On');
    set(findobj('tag','Vy_FO1'),'Enable','On');
    set(findobj('tag','V2'),'Enable','On');
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
plot(haxes6,Sujet.(acq_courante).t,Sujet.(acq_courante).Acc_Z); afficheY_v2(0,':k',haxes6);

%Affichage des vitesses en fonction des choix de l'utilisateur et pr�sence de donn�es d�riv�es
flags_V = [get(findobj('tag','V_intgr'),'Value') get(findobj('tag','V_der'),'Value')];
flag_afficheV = sum(flags_V); %Flag d'affichage
switch flag_afficheV
    case 0 %Aucune s�lection
    	plot(haxes3,Sujet.(acq_courante).t,zeros(1,length(Sujet.(acq_courante).t)),'Color','w');
        plot(haxes4,Sujet.(acq_courante).t,zeros(1,length(Sujet.(acq_courante).t)),'Color','w');
    case 1 
        if flags_V(2) %Courbes d�riv�es
            plot(haxes3,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_AP_d,'r-'); afficheY_v2(0,':k',haxes3);
            plot(haxes4,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_Z_d,'r-'); afficheY_v2(0,':k',haxes4);
        else %Courbes int�gr�es
            plot(haxes3,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_AP); afficheY_v2(0,':k',haxes3);
            plot(haxes4,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_Z); afficheY_v2(0,':k',haxes4);
        end
    case 2 %Les 2
        plot(haxes3,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_AP); set(haxes3,'NextPlot','add');
        plot(haxes3,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_AP_d,'r-'); afficheY_v2(0,':k',haxes3);
        plot(haxes4,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_Z); set(haxes4,'NextPlot','add');
        plot(haxes4,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_Z_d,'r-'); afficheY_v2(0,':k',haxes4);
end
% Si affichage automatique des marqueurs vitesses 'On'
if get(findobj('tag','Automatik_display'),'Value') %% Si bouton Affichage automatique press�
    Markers_Callback(findobj('tag','Markers'));
    Vitesses_Callback(findobj('tag','Vitesses'));
    Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles)
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
ylabel(haxes6,'Axe vertical(m�/s)','FontName','Times New Roman','FontSize',10);
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

%Bouton de sauvegarde
set(findobj('tag','uipushtool3'),'Enable','On');

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
global Sujet Resultats dossier EMG Corridors Subject_data

try
%Choix manuel des fichiers
[files dossier] = uigetfile('*.c3d','Choix du/des fichier(s) c3d','Multiselect','on'); %%Ajouter plus tard les autres file types

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

%Extraction des donn�es d'int�r�ts
[Sujet EMG] = pretraitement_dataAPA(files,dossier(1:end-1));

%% Mise � jour interface et activation des boutons
set(findobj('tag','listbox1'), 'Visible','On');
set(findobj('tag','togglebutton1'),'Visible','On');
set(findobj('tag','AutoScale'),'Visible','On');
set(findobj('tag','Multiplot'),'Visible','On');
set(findobj('tag','Automatik_display'),'Visible','On');
set(findobj('tag','Results'), 'Visible','Off');
set(findobj('tag','Results'), 'Data',zeros(30,1));
set(findobj('tag','Affiche_corridor'), 'Visible','On');
set(findobj('tag','Clean_corridor'), 'Visible','On');
set(findobj('tag','Clean_corridor'), 'Enable','On');

set(findobj('Tag','sujet_courant'),'Enable','On');
set(findobj('Tag','subject_info'),'Enable','On');

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

catch ERR
    waitfor(warndlg('Annulation chargement fichiers!'));
end

% --------------------------------------------------------------------
 function uipushtool2_ClickedCallback(hObject, eventdata, handles)
%% Choix dossier (directory)
% hObject handle to uipushtool2 (see GCBO)
global Sujet Resultats dossier EMG Corridors Subject_data

try
%Choix du dossier et extraction de la liste des fichiers existants
dossier = uigetdir(pwd,'Repertoire de stockage des acquisitions du sujet') ;
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
filetype = 'c3d'; %%Ajouter une dialogbox ou liste d�roulante pour le choix du type de fichier
files = extrait_liste_acquisitions(list_rep,filetype); 
[Sujet EMG] = pretraitement_dataAPA(files,dossier);

%% Mise � jour interface et activation des boutons
set(findobj('tag','listbox1'), 'Visible','On');
set(findobj('tag','listbox1'), 'String',fieldnames(Sujet));
set(findobj('tag','togglebutton1'),'Visible','On');
set(findobj('tag','AutoScale'),'Visible','On');
set(findobj('tag','Multiplot'),'Visible','On');
set(findobj('tag','Automatik_display'),'Visible','On');
set(findobj('tag','Results'), 'Visible','Off');
set(findobj('tag','Results'), 'Data',zeros(30,1));
set(findobj('tag','Affiche_corridor'), 'Visible','On');
set(findobj('tag','Clean_corridor'), 'Visible','On');
set(findobj('tag','Clean_corridor'), 'Enable','On');

set(findobj('Tag','sujet_courant'),'Enable','On');
set(findobj('Tag','subject_info'),'Enable','On');

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
if ~isempty(EMG)
    set(findobj('tag','Visu_EMG'), 'Enable','On');
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
global haxes1 haxes2 haxes3 haxes4 haxes6 Sujet EMG

try
%Choix manuel des fichiers
[files dossier] = uigetfile('*.c3d','Choix du/des fichier(s) c3d','Multiselect','on'); %%Ajouter plus tard les autres file types

%Initialisation
Add = {};
Add_emg = {};

%Extraction des donn�es d'int�r�ts
[Add Add_emg]= pretraitement_dataAPA(files,dossier(1:end-1));

% On modifie le nom des acquisitions/fields similaires
new_acqs = fieldnames(Add);
old_acqs = fieldnames(Sujet);

if size(old_acqs,1) > size(old_acqs,1)
    similars = sum(compare_liste(new_acqs,old_acqs),1);
else
    similars = sum(compare_liste(new_acqs,old_acqs),2);
end

for k = 1:size(new_acqs,1)
    if similars(k)
        button = questdlg(new_acqs{k},'!Nom de marche d�j� existant!','Ajouter','Skip','Ecraser','Ecraser');
        switch button
            case 'Ajouter' % On modifie le nom et ajoute
                Sujet.(strcat(new_acqs{k},'_1')) = Add.(new_acqs{k});
                new_acqs{k} = strcat(new_acqs{k},'_1');
            case 'Skip'
                disp(['Pas de chargement' new_acqs{k}]);
            otherwise
                Sujet.(new_acqs{k}) = Add.(new_acqs{k});
        end
    else
        Sujet.(new_acqs{k}) = Add.(new_acqs{k});
    end
    
    try
       EMG.(new_acqs{k}) = Add_emg.(new_acqs{k});
    catch ERRR
        disp(['Pas d''EMG : ' (new_acqs{k})]);
    end
       
end

%Mise � jour de la liste et EMGs
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
end

catch ERR
    warndlg('Arr�t/Erreur chargement des nouvelles acquisitions');
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
global Sujet Resultats Corridors Subject_data EMG Activation_EMG Activation_EMG_percycle
% hObject    handle to uipushtool4 (see GCBO)

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
set(findobj('tag','Affiche_corridor'), 'Visible','On');
set(findobj('tag','Visu_EMG'), 'Visible','On');
if ~isempty(EMG)
    set(findobj('tag','Visu_EMG'), 'Enable','On');
end

set(findobj('tag','pushbutton20','Visible','On'));

set(findobj('Tag','sujet_courant'),'Enable','On');
set(findobj('Tag','subject_info'),'Enable','On');

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
    button = questdlg('Choix des acquisitions � charger sur la liste?','Mise � jour liste','Tous','Moyennes','Dernier','Dernier');
        switch button
            case 'Moyennes'
                set(findobj('tag','listbox1'), 'String',fieldnames(Corridors));
            case 'Tous'
                set(findobj('tag','listbox1'), 'String',fieldnames(Sujet));
            otherwise
                set(findobj('tag','listbox1'), 'String',liste_actuelle);
        end
    set(findobj('tag','Affiche_corridor'), 'Enable','On');
else
%     set(findobj('tag','listbox1'), 'String',liste_actuelle);
    set(findobj('tag','listbox1'), 'String',fieldnames(Sujet));
    set(findobj('tag','Affiche_corridor'), 'Enable','Off');
    set(findobj('tag','Clean_corridor'), 'Enable','Off');
end

catch ERR
    disp('Annulation chargement');
end

% --------------------------------------------------------------------
function uipushtool3_ClickedCallback(hObject, eventdata, handles)
%% Sauvegarde d'un fichier en cours
% hObject    handle to uipushtool3 (see GCBO)
global Sujet Resultats Corridors Subject_data EMG Activation_EMG Activation_EMG_percycle

if isempty(Subject_data)
    Subject_data = subject_info();
end

liste_actuelle = cellstr(get(findobj('tag','listbox1'),'String'));

eval(['save ' Subject_data.ID ' Sujet Resultats Corridors Subject_data EMG liste_actuelle Activation_EMG Activation_EMG_percycle']);

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
ind = round(Manual_click(1)*Sujet.(acq_courante).Fech)+1; %%

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
ind = round(Manual_click(1)*Sujet.(acq_courante).Fech)+1;

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
Sujet.(acq_courante).primResultats.Longueur_pas = range(Sujet.(acq_courante).CP_AP(ind:Sujet.(acq_courante).tMarkers.FO2*Sujet.(acq_courante).Fech));

%R�actualisation des calculs
Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles)

% --- Executes on button press in FO2.
function FO2_Callback(hObject, eventdata, handles)
%% Choix FO2 (Foot-Off du pied d'appui)
global Sujet acq_courante h_marks_FO2
% hObject    handle to FO2 (see GCBO)

Manual_click = ginput(1);
Sujet.(acq_courante).tMarkers.FO2 = Manual_click(1);
ind = round(Manual_click(1)*Sujet.(acq_courante).Fech);

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
ind = round(Manual_click(1)*Sujet.(acq_courante).Fech)+1;

efface_marqueur_test(h_marks_APAy1);

set(haxes1,'NextPlot','add');
h_marks_APAy1 = plot(haxes1,Sujet.(acq_courante).t(ind),Sujet.(acq_courante).CP_AP(ind),'x','Markersize',11);
set(haxes1,'NextPlot','new');

%Stockage du r�sultats
Sujet.(acq_courante).primResultats.minAPAy_AP = [ind mean(Sujet.(acq_courante).CP_AP(1:Sujet.(acq_courante).tMarkers.T0*Sujet.(acq_courante).Fech)) - Sujet.(acq_courante).CP_AP(ind)];

%R�actualisation des calculs
Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles)

% --- Executes on button press in yAPA_ML.
function yAPA_ML_Callback(hObject, eventdata, handles)
global haxes2 Sujet acq_courante h_marks_APAy2
% Detection valeur minimale/maximale du d�placement m�diolat�ral du CP lors des APA
% hObject    handle to yAPA_ML (see GCBO)

Manual_click = ginput(1);
ind = round(Manual_click(1)*Sujet.(acq_courante).Fech)+1;

efface_marqueur_test(h_marks_APAy2);

set(haxes2,'NextPlot','add');
Extrema = Sujet.(acq_courante).CP_ML(ind);
h_marks_APAy2 = plot(haxes2,Sujet.(acq_courante).t(ind),Extrema,'x','Markersize',11);
set(haxes2,'NextPlot','new');

%Stockage du r�sultats
Sujet.(acq_courante).primResultats.APAy_ML = [ind abs(mean(Sujet.(acq_courante).CP_ML(1:Sujet.(acq_courante).tMarkers.T0*Sujet.(acq_courante).Fech) - Extrema))];
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
    ind = round(Manual_click(1)*Sujet.(acq_courante).Fech)+1;
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
ind = round(Manual_click(1)*Sujet.(acq_courante).Fech)+1;
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
ind = round(Manual_click(1)*Sujet.(acq_courante).Fech)+1;
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
ind = round(Manual_click(1)*Sujet.(acq_courante).Fech)+1;
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
    ind = round(Manual_click(1)*Sujet.(acq_courante).Fech)+1;
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
    h_marks_APAy2 
% hObject    handle to Markers (see GCBO)

%Nettoyage des axes d'abord (??Laisser si Multiplot On??)
efface_marqueur_test(h_marks_T0);
efface_marqueur_test(h_marks_HO);
efface_marqueur_test(h_marks_TO);
efface_marqueur_test(h_marks_FC1);
efface_marqueur_test(h_marks_FO2);
efface_marqueur_test(h_marks_FC2);

%Actualisation des marqueurs
h_marks_T0 = affiche_marqueurs(Sujet.(acq_courante).tMarkers.T0,'-r');
h_marks_HO = affiche_marqueurs(Sujet.(acq_courante).tMarkers.HO,'-k');
h_marks_TO = affiche_marqueurs(Sujet.(acq_courante).tMarkers.TO,'-b');
h_marks_FC1 = affiche_marqueurs(Sujet.(acq_courante).tMarkers.FC1,'-m');
h_marks_FO2 = affiche_marqueurs(Sujet.(acq_courante).tMarkers.FO2,'-g');
h_marks_FC2 = affiche_marqueurs(Sujet.(acq_courante).tMarkers.FC2,'-c');

%Affichage des APA pr�-trait�s
ind_1 = round(Sujet.(acq_courante).primResultats.minAPAy_AP(1));
h_marks_APAy1 = plot(haxes1,Sujet.(acq_courante).t(ind_1),Sujet.(acq_courante).CP_AP(ind_1),'x','Markersize',11);

ind_2 = round(Sujet.(acq_courante).primResultats.APAy_ML(1));
h_marks_APAy2 = plot(haxes2,Sujet.(acq_courante).t(ind_2),Sujet.(acq_courante).CP_ML(ind_2),'x','Markersize',11);

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
ind_Vy = round(Sujet.(acq_courante).primResultats.Vy_FO1(1));
Vy = Sujet.(acq_courante).primResultats.Vy_FO1(2);
h_marks_Vy_FO1 = plot(haxes3,Sujet.(acq_courante).t(ind_Vy),Vy,'x','Markersize',11);

ind_Vm = round(Sujet.(acq_courante).primResultats.Vm(1));
Vm = Sujet.(acq_courante).primResultats.Vm(2);
h_marks_Vm = plot(haxes3,Sujet.(acq_courante).t(ind_Vm),Vm,'x','Markersize',11,'Color','r','Linewidth',1.5);

ind_Vmin = round(Sujet.(acq_courante).primResultats.VZmin_APA(1));
Vmin = Sujet.(acq_courante).primResultats.VZmin_APA(2);
h_marks_VZ_min = plot(haxes4,Sujet.(acq_courante).t(ind_Vmin),Vmin,'x','Markersize',11,'Color','k');

ind_V1 = round(Sujet.(acq_courante).primResultats.V1(1));
V1 = Sujet.(acq_courante).primResultats.V1(2);
h_marks_V1 = plot(haxes4,Sujet.(acq_courante).t(ind_V1),V1,'x','Markersize',11,'Color','r','Linewidth',1.25);

ind_V2 = round(Sujet.(acq_courante).primResultats.V2(1));
V2 = Sujet.(acq_courante).primResultats.V2(2);
h_marks_V2 = plot(haxes4,Sujet.(acq_courante).t(ind_V2),V2,'x','Markersize',11,'Color','m','Linewidth',1.5);

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
global Sujet acq_courante Resultats

% Calculs  %%% METTRE Condition si NOTOCORD ????!!��
Resultats.(acq_courante) = calculs_parametres_initiationPas_v1(Sujet.(acq_courante));
    
%Affichage
Current_Res = affiche_resultat_APA(Resultats.(acq_courante));

% --- Executes on button press in Calc_batch.
function Calc_batch_Callback(hObject, eventdata, handles)
%% Calculs des APA sur toutes les acquisitions
% hObject    handle to Calc_batch (see GCBO)
global Sujet Resultats Subject_data

% Calculs
liste = fieldnames(Sujet);
wb = waitbar(0);
set(wb,'Name','Please wait... Calculating data');

for i=1:length(liste)
    waitbar(i/length(liste)-1,wb,['Calcul acquisition: ' liste{i}]);
    Resultats.(liste{i}) = calculs_parametres_initiationPas_v1(Sujet.(liste{i}));
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
    plot(haxes3,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_AP_d,'r-');
    plot(haxes4,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_Z_d,'r-');
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
global Sujet clean
% hObject    handle to Clean_data (see GCBO)

%Extraction des acquisitions sur la liste
% listes_acqs = filednames(Sujet);
listes_acqs = cellstr(get(findobj('tag','listbox1'),'String'));

%S�lections de l'utilisateur
[acqs,v] = listdlg('PromptString',{'Nettoyage donn�es','Choix des acquisitions � v�rifier'},...
    'ListSize',[300 300],...
    'ListString',listes_acqs);
    
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
        plot(h1,Sujet.(acqs{i}).t,Sujet.(acqs{i}).CP_AP,'ButtonDownFcn',@maselection,'uicontextmenu',c,'displayname',acqs{i});
        plot(h2,Sujet.(acqs{i}).t,Sujet.(acqs{i}).CP_ML,'ButtonDownFcn',@maselection,'uicontextmenu',c,'displayname',acqs{i});
        plot(h3,Sujet.(acqs{i}).t,Sujet.(acqs{i}).V_CG_AP,'ButtonDownFcn',@maselection,'uicontextmenu',c,'displayname',acqs{i});
        plot(h4,Sujet.(acqs{i}).t,Sujet.(acqs{i}).V_CG_Z,'ButtonDownFcn',@maselection,'uicontextmenu',c,'displayname',acqs{i});
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
%% Moyennage des acquisitions s�lectionn�es et stockage dans une variable acquisition (groupe)
global Sujet Resultats Corridors Activation_EMG_percycle
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
% Group_emg={};
for i=1:length(acqs)
    Group_data.(listes_acqs{acqs(i)}) = Sujet.(listes_acqs{acqs(i)});
    if ~isfield(listes_acqs{acqs(i)},Resultats) % Calculs des param�tres si non effectu�s
        disp(['Calculs acquisition ' listes_acqs{acqs(i)}]);
        Resultats.(listes_acqs{acqs(i)})=calculs_parametres_initiationPas_v1(Sujet.(listes_acqs{acqs(i)}));
    end
    
    try
        if isfield(listes_acqs{acqs(i)},Activation_EMG_percycle) % Moyenneage des activations EMG (si existent)
           %%% Rassembler les periodes d'activation EMG
         % Group_emg={};
        end
    catch ERR
        disp('Pas de calcul moyen EMG');
    end
    
    Moy_data.(listes_acqs{acqs(i)}) = Resultats.(listes_acqs{acqs(i)});      
end

%Normalisation des donn�es brutes
Group_norm = normalise_APA(Group_data);

%Calcul du corridor et des resultats moyens
[Acq_moy Data_group Ecarts_acqs] = regroupe_acquisitions(Group_norm);
[Res_moy Res_group Ecarts_res] = regroupe_acquisitions(Moy_data);

%Stockage
% Corridors.(groupe_acqs) = stockage_corridor(Acq_moy,Ecarts_acqs);
Corridors.(groupe_acqs) = Data_group;
Sujet.(groupe_acqs) = Acq_moy;
Resultats.(groupe_acqs) = Res_moy;

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
catch ERR
    warndlg('Arret cr�ation groupe'); 
end

% --- Executes on button press in Group_subjects.
function Group_subjects_Callback(hObject, eventdata, handles)
%% Moyennage des acquisitions des sujets s�lectionn�s et stockage dans une variable acquisition (groupe)
% hObject    handle to Group_subjects (see GCBO)


% --- Executes on button press in Affich_corridor.
function Affich_corridor_Callback(hObject, eventdata, handles)
%% Affichage des corridors pour les donn�es brutes
global axes1 axes2 axes3 axes4 Corridors Sujet list Sujet_tmp
% hObject    handle to Affich_corridor (see GCBO)
Sujet_tmp = Sujet;
choix_corr = {};
%Extraction des corridors calcul�s
try
i=1;
legendes={};
    if isempty(eventdata)
        listes_corr = fieldnames(Corridors);
        %S�lections de l'utilisateur
        [i,v] = listdlg('PromptString',{'Choix du corridor � afficher'},...
             'ListSize',[300 300],...
             'ListString',listes_corr,'SelectionMode','Multiple');
    else
        listes_corr{1} = eventdata;
    end
    
    listes_acqs = fieldnames(Sujet_tmp);
    %Affichage
    % Cr�ation de l'interface de visu
    f = figure();
    b = uiextras.HBox( 'Parent', f);
    b1 = uiextras.VBox( 'Parent', b);
    %Ajout de la liste sans la moyenne du/des corridor(s) venant d'�tre calcul�(s)
    list = uicontrol( 'Style', 'listbox', 'Parent', b, 'String', listes_acqs(1:end-length(i),:),'Callback',@list_Callback);
    
    axes1 = axes( 'Parent', b1, ...
    'ActivePositionProperty', 'Position','xticklabel',[]);
    for k=1:length(i)
        h_corr_CP_AP = stdshade(Corridors.(listes_corr{i(k)}).CP_AP,0.4,[0.5/k 0.5/k 1],Corridors.(listes_corr{i(k)}).t(1,:),1,axes1);
        legendes{2*(k-1)+1} = listes_corr{i(k)};
        legendes{2*k} = [listes_corr{i(k)} '�1STD'];
    end
    ylabel(axes1,'D�placememt AP CP (mm)');
    axis tight
   
    legend(legendes);
    
    axes2 = axes( 'Parent', b1, ...
    'ActivePositionProperty', 'Position','xticklabel',[]);
    for k=1:length(i)
        h_corr_CP_ML = stdshade(Corridors.(listes_corr{i(k)}).CP_ML,0.4,[0.5/k 0.5/k 1],Corridors.(listes_corr{i(k)}).t(1,:),1,axes2);
    end
    ylabel(axes2,'D�placememt ML CP (mm)');
    axis tight
    
    axes3 = axes( 'Parent', b1, ...
    'ActivePositionProperty', 'Position','xticklabel',[]);
    for k=1:length(i)
        if get(findobj('tag','V_intgr'),'Value')
            h_corr_CG_AP = stdshade(Corridors.(listes_corr{i(k)}).V_CG_AP,0.4,[0.5/k 0.5/k 1],Corridors.(listes_corr{i(k)}).t(1,:),1,axes3);
        else
            h_corr_CG_AP = stdshade(Corridors.(listes_corr{i(k)}).V_CG_AP_d,0.4,[1 0.5/k 0.5/k],Corridors.(listes_corr{i(k)}).t(1,:),1,axes3);
        end
    end
    ylabel(axes3,'Vitesse CG AP (m/sec)');
    axis tight
    
    axes4 = axes( 'Parent', b1, ...
    'ActivePositionProperty', 'Position');
    xlabel(axes4,'Temps (sec)')
    for k=1:length(i)
        if get(findobj('tag','V_intgr'),'Value')
            h_corr_CG_Z = stdshade(Corridors.(listes_corr{i(k)}).V_CG_Z,0.4,[0.5/k 0.5/k 1],Corridors.(listes_corr{i(k)}).t(1,:),1,axes4);
        else
            h_corr_CG_Z = stdshade(Corridors.(listes_corr{i(k)}).V_CG_Z_d,0.4,[1 0.5/k 0.5/k],Corridors.(listes_corr{i(k)}).t(1,:),1,axes4);
        end
    end
    ylabel(axes4,'Vitesse CG Z (m/sec)');
    axis tight

catch ERR
     waitfor(warndlg('!!!Pas de corridors calcul�s/s�lectionn�s!!!'));
end

% --- Execute when pressing corridor interface list
function list_Callback(hObj,eventdata,handles)
%% Affichage courbes avec corridors
global axes1 axes2 axes3 axes4 Sujet_tmp list
        
%R�cup�ration de l'acquisition s�l�ctionn�e
try
    contents = cellstr(get(list,'String'));
    acq_choisie = contents{get(list,'Value')};

     plot(axes1,Sujet_tmp.(acq_choisie).t,Sujet_tmp.(acq_choisie).CP_AP); axis(axes1,'tight');
     plot(axes2,Sujet_tmp.(acq_choisie).t,Sujet_tmp.(acq_choisie).CP_ML); axis(axes2,'tight');
     plot(axes3,Sujet_tmp.(acq_choisie).t,Sujet_tmp.(acq_choisie).V_CG_AP); axis(axes3,'tight');
     plot(axes4,Sujet_tmp.(acq_choisie).t,Sujet_tmp.(acq_choisie).V_CG_Z); axis(axes4,'tight');
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
catch ERR
    disp('Erreur acquisition donn�es sujet');
end

Data.ID = rep{1};
Data.Name = rep{2};
Data.Sexe = rep{3};
Data.Age = str2double(rep{4});
Data.Patho = rep{5};

% --- Executes on button press in Visu_EMG.
function Visu_EMG_Callback(hObject, eventdata, handles)
%% Affichage et traitement de l'EMG
global Sujet Corridors EMG Activation_EMG Activation_EMG_percycle
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
if size(all,1) < size(existing,1)
    similars = sum(compare_liste(all,existing),1);
else
    similars = sum(compare_liste(all,existing),2);
end

check = similars==1;
liste_a_traiter = all(check); %On garde que les acquisitions conserv�es

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

affiche_emgs(liste_a_traiter);

% --- Executes during object creation, after setting all properties.
function axes6_CreateFcn(hObject, eventdata, handles)
global haxes6
% hObject    handle to axes2 (see GCBO)
haxes6 = hObject;

function load_notocord_results(hObject, eventdata, handles)
%% Chargement de fichiers d�j� trait�s via NOTOCORD en mode Nouveau Sujet
global Sujet dossier EMG Resultats

try
%Choix manuel des fichiers
[files dossier] = uigetfile('*.mat','Choix du/des fichier(s) mat','Multiselect','on'); %%Ajouter plus tard les autres file types

%Initialisation
Sujet = {};
EMG = {};
Resultats = {};

%Extraction des donn�es d'int�r�ts
[Sujet Resultats] = extraction_dataAPA_Notocord(files,dossier(1:end-1));

%% Mise � jour interface et activation des boutons
set(findobj('tag','listbox1'), 'Visible','On');
set(findobj('tag','togglebutton1'),'Visible','On');
set(findobj('tag','AutoScale'),'Visible','On');
set(findobj('tag','Multiplot'),'Visible','On');
set(findobj('tag','Automatik_display'),'Visible','On');
set(findobj('tag','Results'), 'Visible','Off');
set(findobj('tag','Results'), 'Data',zeros(30,1));
set(findobj('tag','Affiche_corridor'), 'Visible','On');

set(findobj('Tag','sujet_courant'),'Enable','On');
set(findobj('Tag','subject_info'),'Enable','On');

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

catch ERR
    waitfor(warndlg('Annulation chargement fichiers!'));
end


% --- Executes on button press in Clean_corridor.
function Clean_corridor_Callback(hObject, eventdata, handles)
%% Retirer un corridor si mauvais
global Sujet Corridors Resultats
% hObject    handle to Clean_corridor (see GCBO)

try
listes_corr = fieldnames(Corridors);
%S�lections de l'utilisateur
[i,v] = listdlg('PromptString',{'Choix du/des corridor(s) � effacer'},...
    'ListSize',[300 300],...
    'ListString',listes_corr,'SelectionMode','Multiple');

Sujet = rmfield(Sujet,listes_corr{i});
Corridors = rmfield(Corridors,listes_corr{i});
Resultats = rmfield(Resultats,listes_corr{i});

catch ERR
    warndlg('!!Pas de Corridors calcul�s!!')
end
