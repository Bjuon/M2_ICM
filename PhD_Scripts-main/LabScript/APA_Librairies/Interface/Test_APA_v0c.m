function varargout = Test_APA_v0c(varargin)
% TEST_APA_V0C MATLAB code for Test_APA_v0c.fig
%      TEST_APA_V0C, by itself, creates a new TEST_APA_V0C or raises the existing
%      singleton*.
%
%      H = TEST_APA_V0C returns the handle to a new TEST_APA_V0C or the handle to
%      the existing singleton*.
%
%      TEST_APA_V0C('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST_APA_V0C.M with the given input arguments.
%
%      TEST_APA_V0C('Property','Value',...) creates a new TEST_APA_V0C or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Test_APA_v0c_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Test_APA_v0c_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Test_APA_v0c

% Last Modified by GUIDE v2.5 03-Apr-2012 19:03:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Test_APA_v0c_OpeningFcn, ...
                   'gui_OutputFcn',  @Test_APA_v0c_OutputFcn, ...
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

% --- Executes just before Test_APA_v0c is made visible.
function Test_APA_v0c_OpeningFcn(hObject, ~, handles, varargin)
global haxes1 haxes2 haxes3 haxes4 h_marks_T0 h_marks_HO h_marks_TO h_marks_FC1 h_marks_FO2 h_marks_FC2
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Test_APA_v0c (see VARARGIN)

% Choose default command line output for Test_APA_v0c
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Test_APA_v0c wait for user response (see UIRESUME)
% uiwait(handles.figure1);

scrsz = get(0,'ScreenSize');
set(hObject,'Position',[scrsz(3)/20 scrsz(4)/20 scrsz(3)*9/10 scrsz(4)*9/10]);

ylabel(haxes1,'Axe antéro-postérieur (mm)','FontName','Times New Roman','FontSize',10);
set(haxes1,'Visible','Off');

ylabel(haxes2,'Axe médio-latéral(mm)','FontName','Times New Roman','FontSize',10);
set(haxes2,'Visible','Off');

ylabel(haxes3,'Axe antéro-postérieur (mm/s)','FontName','Times New Roman','FontSize',10);
set(haxes3,'Visible','Off');

ylabel(haxes4,'Axe vertical(mm/s)','FontName','Times New Roman','FontSize',10);
set(haxes4,'Visible','Off');
xlabel(haxes4,'Temps (sec)','FontName','Times New Roman','FontSize',10);

set(gcf,'Name','Calcul des APA v.0c');

h_marks_T0 = [];
h_marks_HO = [];
h_marks_TO = [];
h_marks_FC1 = [];
h_marks_FO2 = [];
h_marks_FC2= [];

%Initialisation des états d'affichages pour la vitesse
set(findobj('tag','V_intgr'),'Value',1); %Intégration
set(findobj('tag','V_der'),'Value',0); %Dérivation

% --- Outputs from this function are returned to the command line.
function varargout = Test_APA_v0c_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
%% Choix/Click dans la liste actualisée
global haxes1 haxes2 haxes3 haxes4 Sujet acq_courante flag_afficheV %h_marks_T0 h_marks_HO h_marks_TO h_marks_FC1 h_marks_FO2 h_marks_FC2
% hObject    handle to listbox1 (see GCBO)

%Récupération de l'acquisition séléctionnée
contents = cellstr(get(hObject,'String'));
acq_courante = contents{get(hObject,'Value')};

% On check la présence de données de vitesse dérivé (pour l'affichage)
flag_der = isfield(Sujet.(acq_courante),{'V_CG_AP_d' 'V_CG_Z_d'});
if flag_der
    set(findobj('tag','V_der'),'Enable','On');
end

%Initialisation des plots et marqueurs si Multiplot Off
axess = findobj('Type','axes');
for i=1:length(axess)
    if get(findobj('tag','Multiplot'),'Value') %% Si bouton Multiplot pressé
        set(axess(i),'NextPlot','add'); % Multiplot On
    else
        set(axess(i),'NextPlot','replace'); % Multiplot Off
    end
end
    
plot(haxes1,Sujet.(acq_courante).t,Sujet.(acq_courante).CP_AP);
plot(haxes2,Sujet.(acq_courante).t,Sujet.(acq_courante).CP_ML);

%Affichage des vitesses en fonction des choix de l'utilisateur et présence de données dérivées
flags_V = [get(findobj('tag','V_intgr'),'Value') get(findobj('tag','V_der'),'Value')];
flag_afficheV = sum(flags_V); %Flag d'affichage
switch flag_afficheV
    case 0 %Aucune sélection
    	plot(haxes3,Sujet.(acq_courante).t,zeros(1,length(Sujet.(acq_courante).t)),'Color','w');
        plot(haxes4,Sujet.(acq_courante).t,zeros(1,length(Sujet.(acq_courante).t)),'Color','w');
    case 1 
        if flags_V(2) %Courbes dérivées
            plot(haxes3,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_AP_d,'r-');
            plot(haxes4,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_Z_d,'r-');
        else %Courbes intégrées
            plot(haxes3,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_AP);
            plot(haxes4,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_Z);
        end
    case 2 %Les 2
        plot(haxes3,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_AP); set(haxes3,'NextPlot','add');
        plot(haxes3,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_AP_d,'r-');
        plot(haxes4,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_Z); set(haxes4,'NextPlot','add');
        plot(haxes4,Sujet.(acq_courante).t,Sujet.(acq_courante).V_CG_Z_d,'r-');
end

% Si affichage automatique des marqueurs vitesses 'On'
if get(findobj('tag','Automatik_display'),'Value') %% Si bouton Affichage automatique pressé
    Markers_Callback(findobj('tag','Markers'));
    Vitesses_Callback(findobj('tag','Vitesses'));
%     Calc_current_Callback(findobj('tag','Calc_current'), eventdata, handles)
end 
    
set(haxes1,'XTick',NaN);
set(haxes3,'XTick',NaN);

%Activation des boutons/toolbars et legendes d'axes 
set(findobj('tag','text_cp'),'Visible','On');
ylabel(haxes1,'Axe antéro-postérieur (mm)','FontName','Times New Roman','FontSize',10);
ylabel(haxes2,'Axe médio-latéral(mm)','FontName','Times New Roman','FontSize',10);
ylabel(haxes3,'Axe antéro-postérieur (mm/s)','FontName','Times New Roman','FontSize',10);
ylabel(haxes4,'Axe vertical(mm/s)','FontName','Times New Roman','FontSize',10);
xlabel(haxes4,'Temps (sec)','FontName','Times New Roman','FontSize',10);

set(findobj('tag','text_cg'),'Visible','On');
set(findobj('tag','Group_APA'),'Visible','On');
set(findobj('tag','Calc_current'),'Visible','On');
set(findobj('tag','Calc_batch'),'Visible','On');
set(findobj('tag','Clean_data'), 'Visible','On');

set(findobj('tag','Markers'), 'Visible','On');
set(findobj('tag','Vitesses'),'Visible','On');
set(findobj('tag','uitable1'),'Visible','On');

%Bouton de sauvegarde
set(findobj('tag','uipushtool3'),'Enable','On');

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
%% Création de la liste
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
global haxes1 haxes2 haxes3 haxes4 Sujet dossier

%Choix manuel des fichiers
[files dossier] = uigetfile('*.c3d','Choix du/des fichier(s) c3d','Multiselect','on'); %%Ajouter plus tard les autres file types

%Initialisation
Sujet = {};

%Extraction des données d'intérêts
Sujet = pretraitement_dataAPA(files,dossier);

%% Mise à jour interface et activation des boutons
set(findobj('tag','listbox1'), 'Visible','On');
set(findobj('tag','listbox1'), 'String',fieldnames(Sujet));
set(findobj('tag','togglebutton1'),'Visible','On');
set(findobj('tag','AutoScale'),'Visible','On');
set(findobj('tag','Multiplot'),'Visible','On');
set(findobj('tag','Automatik_display'),'Visible','On');

set(haxes1,'Visible','On');
set(haxes2,'Visible','On');
set(haxes3,'Visible','On');
set(haxes4,'Visible','On');
set(findobj('tag','pushbutton20','Visible','On'));

if length(files)>1
    set(findobj('tag','Group_APA'), 'Enable','On');
    set(findobj('tag','Clean_data'), 'Enable','On');
    set(findobj('tag','Calc_batch'), 'Enable','On');
end

% --------------------------------------------------------------------
function uipushtool2_ClickedCallback(hObject, eventdata, handles)
%% Choix dossier (directory)
% hObject handle to uipushtool2 (see GCBO)
global haxes1 haxes2 haxes3 haxes4 Sujet dossier

%Choix du dossier et extraction de la liste des fichiers existants
dossier = uigetdir(pwd,'Repertoire de stockage des acquisitions du sujet') ;
list_rep= dir(dossier) ;
list_rep(1) = [];
list_rep(1) = [];

%Initialisation
Sujet = {};

%% Extraction des fichiers et donnéers utiles
filetype = 'c3d'; %%Ajouter une dialogbox ou liste déroulante pour le choix du type de fichier
files = extrait_liste_acquisitions(list_rep,filetype); 
Sujet = pretraitement_dataAPA(files,[dossier '\']);

%% Mise à jour interface et activation des boutons
set(findobj('tag','listbox1'), 'Visible','On');
set(findobj('tag','listbox1'), 'String',fieldnames(Sujet));
set(findobj('tag','togglebutton1'),'Visible','On');
set(findobj('tag','AutoScale'),'Visible','On');
set(findobj('tag','Multiplot'),'Visible','On');
set(findobj('tag','Automatik_display'),'Visible','On');

set(haxes1,'Visible','On');
set(haxes2,'Visible','On');
set(haxes3,'Visible','On');
set(haxes4,'Visible','On');
set(findobj('tag','pushbutton20','Visible','On'));

if length(files)>1
    set(findobj('tag','Group_APA'), 'Enable','On');
    set(findobj('tag','Clean_data'), 'Enable','On');
    set(findobj('tag','Calc_batch'), 'Enable','On');
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
%% Chargement d'un fichier deja traité
global Sujet Resultats
% hObject    handle to uipushtool4 (see GCBO)

[var dossier] = uigetfile('*.mat','Choix de la variable à charger');
cd(dossier)
eval(['load ' var]);

%% Mise à jour interface et activation des boutons
set(findobj('tag','listbox1'), 'Visible','On');
set(findobj('tag','listbox1'), 'String',fieldnames(Sujet));
set(findobj('tag','togglebutton1'),'Visible','On');
set(findobj('tag','AutoScale'),'Visible','On');
set(findobj('tag','Multiplot'),'Visible','On');
set(findobj('tag','Automatik_display'),'Visible','On');

set(findobj('tag','pushbutton20','Visible','On'));

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
% --------------------------------------------------------------------
function uipushtool3_ClickedCallback(hObject, eventdata, handles)
%% Sauvegarde d'un fichier en cours
% hObject    handle to uipushtool3 (see GCBO)
global Sujet Resultats

var = cell2mat(inputdlg('Nom de la variable','Sauvegarde données brutes'));

eval(['save ' var ' Sujet Resultats']);

% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in AutoScale.
function AutoScale_Callback(hObject, eventdata, handles)
%% Remise à l'échelle
% hObject    handle to AutoScale (see GCBO)
axis tight

% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
%% Remise à l'échelle
% hObject    handle to pushbutton20 (see GCBO)
axis tight

% --- Executes on button press in T0.
function T0_Callback(hObject, eventdata, handles)
%% Choix T0 (1er évt Biomécanique)
global Sujet acq_courante h_marks_T0
% hObject    handle to T0 (see GCBO)

Manual_click = ginput(1);
Sujet.(acq_courante).tMarkers.T0 = Manual_click(1);

efface_marqueur_test(h_marks_T0);
h_marks_T0=affiche_marqueurs(Manual_click(1),'-r');

% --- Executes on button press in HO.
function HO_Callback(hObject, eventdata, handles)
%% Choix HO (Heel-Off)
global Sujet acq_courante h_marks_HO
% hObject    handle to HO (see GCBO)

Manual_click = ginput(1);
Sujet.(acq_courante).tMarkers.HO = Manual_click(1);

efface_marqueur_test(h_marks_HO);
h_marks_HO=affiche_marqueurs(Manual_click(1),'-g');

% --- Executes on button press in TO.
function TO_Callback(hObject, eventdata, handles)
%% Choix TO (Toe-Off)

global haxes3 Sujet acq_courante h_marks_TO h_marks_Vy_FO1
% hObject    handle to TO (see GCBO)

Manual_click = ginput(1);
Sujet.(acq_courante).tMarkers.TO = Manual_click(1);
ind = floor(Manual_click(1)*Sujet.(acq_courante).Fech);

efface_marqueur_test(h_marks_TO);
efface_marqueur_test(h_marks_Vy_FO1);
h_marks_TO=affiche_marqueurs(Manual_click(1),'-b');
h_marks_Vy_FO1 = plot(haxes3,Sujet.(acq_courante).t(ind),Sujet.(acq_courante).V_CG_AP(ind),'x','Markersize',11);

%Réactualisation de VyFO1
Sujet.(acq_courante).primResultats.VyFO1 = [ind Sujet.(acq_courante).V_CG_AP(ind)];

% --- Executes on button press in FC1.
function FC1_Callback(hObject, eventdata, handles)
%% Choix FC1 (Foot-Contact du pied oscillant)
global haxes4 Sujet acq_courante h_marks_FC1 h_marks_V2
% hObject    handle to FC1 (see GCBO)

Manual_click = ginput(1);
Sujet.(acq_courante).tMarkers.FC1 = Manual_click(1);
ind = floor(Manual_click(1)*Sujet.(acq_courante).Fech);

efface_marqueur_test(h_marks_FC1);
efface_marqueur_test(h_marks_V2);

h_marks_FC1=affiche_marqueurs(Manual_click(1),'-m');
h_marks_V2 = plot(haxes4,Sujet.(acq_courante).t(ind),Sujet.(acq_courante).V_CG_Z(ind),'x','Markersize',11);

%Réactualisation de V2 et recalcul des largeur/longueur du pas
Sujet.(acq_courante).primResultats.V2 = [ind Sujet.(acq_courante).V_CG_Z(ind)];
Sujet.(acq_courante).primResultats.Largeur_pas = range(Sujet.(acq_courante).CP_ML(1:ind));
Sujet.(acq_courante).primResultats.Longueur_pas = range(Sujet.(acq_courante).CP_AP(ind:Sujet.(acq_courante).tMarkers.FO2*Sujet.(acq_courante).Fech));

% --- Executes on button press in FO2.
function FO2_Callback(hObject, eventdata, handles)
%% Choix FO2 (Foot-Off du pied d'appui)
global Sujet acq_courante h_marks_FO2
% hObject    handle to FO2 (see GCBO)

Manual_click = ginput(1);
Sujet.(acq_courante).tMarkers.FO2 = Manual_click(1);
ind = floor(Manual_click(1)*Sujet.(acq_courante).Fech);

efface_marqueur_test(h_marks_FO2);
h_marks_FO2=affiche_marqueurs(Manual_click(1),'-g');

%Actualisation de la longueur du pas
Sujet.(acq_courante).primResultats.Longueur_pas = range(Sujet.(acq_courante).CP_AP(Sujet.(acq_courante).tMarkers.FC1*Sujet.(acq_courante).Fech:ind));

% --- Executes on button press in FC2.
function FC2_Callback(hObject, eventdata, handles)
%% Choix FC2 (Foot-Contact du pied d'appui)
global Sujet acq_courante h_marks_FC2
% hObject    handle to FC2 (see GCBO)

Manual_click = ginput(1);
Sujet.(acq_courante).tMarkers.FC2 = Manual_click(1);

efface_marqueur_test(h_marks_FC2);
h_marks_FC2=affiche_marqueurs(Manual_click(1),'-m');

% --- Executes on button press in yAPA_AP.
function yAPA_AP_Callback(hObject, eventdata, handles)
%% Detection manuelle du déplacement postérieur max du CP lors des APA
global haxes1 Sujet acq_courante h_marks_APAy1
% hObject    handle to yAPA_AP (see GCBO)

Manual_click = ginput(1);
ind = floor(Manual_click(1)*Sujet.(acq_courante).Fech);

efface_marqueur_test(h_marks_APAy1);

set(haxes1,'NextPlot','add');
h_marks_APAy1 = plot(haxes1,Sujet.(acq_courante).t(ind),Sujet.(acq_courante).CP_AP(ind),'x','Markersize',11);
set(haxes1,'NextPlot','new');

%Stockage du résultats
Sujet.(acq_courante).primResultats.minAPAy_AP = [ind mean(Sujet.(acq_courante).CP_AP(1:Sujet.(acq_courante).T0))-Sujet.(acq_courante).CP_AP(ind)];

% --- Executes on button press in yAPA_ML.
function yAPA_ML_Callback(hObject, eventdata, handles)
global haxes2 Sujet acq_courante h_marks_APAy2
% Detection valeur minimale/maximale du déplacement médiolatéral du CP lors des APA
% hObject    handle to yAPA_ML (see GCBO)

Manual_click = ginput(1);
ind = floor(Manual_click(1)*Sujet.(acq_courante).Fech);

efface_marqueur_test(h_marks_APAy2);

set(haxes2,'NextPlot','add');
Extrema = Sujet.(acq_courante).CP_ML(ind);
h_marks_APAy2 = plot(haxes2,Sujet.(acq_courante).t(ind),Extrema,'x','Markersize',11);
set(haxes2,'NextPlot','new');

%Stockage du résultats
Sujet.(acq_courante).primResultats.APAy_ML = [ind abs(mean(Sujet.(acq_courante).CP_ML(1:Sujet.(acq_courante).T0)) - Extrema)];

% --- Executes on button press in Vy_FO1.
function Vy_FO1_Callback(hObject, eventdata, handles)
%% Détection manuelle de la Vitesse AP du CG lors de FO1
% hObject    handle to Vy_FO1 (see GCBO)
...dépend de FO1 donc non réglable

% --- Executes on button press in Vm.
function Vm_Callback(hObject, eventdata, handles)
%% Détection manuelle Vitesse max AP du CG
% hObject    handle to Vm (see GCBO)
global haxes3 Sujet acq_courante h_marks_Vm

Manual_click = ginput(1);
ind = floor(Manual_click(1)*Sujet.(acq_courante).Fech);
efface_marqueur_test(h_marks_Vm);

set(haxes3,'NextPlot','add');
h_marks_Vm = plot(haxes3,Sujet.(acq_courante).t(ind),Sujet.(acq_courante).V_CG_AP(ind),'x','Markersize',11);
set(haxes3,'NextPlot','new');

% Stockage du résultats
Sujet.(acq_courante).primResultats.Vm = [ind Sujet.(acq_courante).V_CG_AP(ind)];

% --- Executes on button press in Vmin_APA.
function Vmin_APA_Callback(hObject, eventdata, handles)
%% Détection manuelle Vitesse min verticale du CG lors des APA
global haxes4 Sujet acq_courante h_marks_Vmin_APA
% hObject    handle to Vmin_APA (see GCBO)

Manual_click = ginput(1);
ind = floor(Manual_click(1)*Sujet.(acq_courante).Fech);
efface_marqueur_test(h_marks_Vmin_APA);

set(haxes4,'NextPlot','add');
h_marks_Vmin_APA = plot(haxes4,Sujet.(acq_courante).t(ind),Sujet.(acq_courante).V_CG_Z(ind),'x','Markersize',11);
set(haxes4,'NextPlot','new');

% Stockage du résultats
Sujet.(acq_courante).primResultats.VZmin_APA = [ind Sujet.(acq_courante).V_CG_Z(ind)];

% --- Executes on button press in V1.
function V1_Callback(hObject, eventdata, handles)
%% Détection manuelle du 1er min de la Vitesse vertciale du CG lors de l'éxecution du pas
global haxes4 Sujet acq_courante h_marks_V1
% hObject    handle to V1 (see GCBO)

Manual_click = ginput(1);
ind = floor(Manual_click(1)*Sujet.(acq_courante).Fech);
efface_marqueur_test(h_marks_V1);

set(haxes4,'NextPlot','add');
h_marks_V1 = plot(haxes4,Sujet.(acq_courante).t(ind),Sujet.(acq_courante).V_CG_Z(ind),'x','Markersize',11);
set(haxes4,'NextPlot','new');

% Stockage du résultats
Sujet.(acq_courante).primResultats.V1 = [ind Sujet.(acq_courante).V_CG_Z(ind)];

% --- Executes on button press in V2.
function V2_Callback(hObject, eventdata, handles)
%% Détection manuelle de la Vitesse vertciale du CG lors du FC1
% global haxes4 Sujet acq_courante h_marks_V2
% hObject    handle to V2 (see GCBO)
...dépend de FC1 donc non réglable

% --- Executes on button press in Markers.
function Markers_Callback(hObject, eventdata, handles)
%% Affichage des marqueurs de l'acquisition courante/sélectionnée
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
h_marks_HO = affiche_marqueurs(Sujet.(acq_courante).tMarkers.HO,'-g');
h_marks_TO = affiche_marqueurs(Sujet.(acq_courante).tMarkers.TO,'-b');
h_marks_FC1 = affiche_marqueurs(Sujet.(acq_courante).tMarkers.FC1,'-m');
h_marks_FO2 = affiche_marqueurs(Sujet.(acq_courante).tMarkers.FO2,'-g');
h_marks_FC2 = affiche_marqueurs(Sujet.(acq_courante).tMarkers.FC2,'-m');

%Affichage des APA pré-traités
ind_1 = Sujet.(acq_courante).primResultats.minAPAy_AP(1);
h_marks_APAy1 = plot(haxes1,Sujet.(acq_courante).t(ind_1),Sujet.(acq_courante).CP_AP(ind_1),'x','Markersize',11);

ind_2 = Sujet.(acq_courante).primResultats.APAy_ML(1);
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
%% Affichage des pics de Vitesse déjà calculés
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
ind_Vy = Sujet.(acq_courante).primResultats.Vy_FO1(1);
h_marks_Vy_FO1 = plot(haxes3,Sujet.(acq_courante).t(ind_Vy),Sujet.(acq_courante).V_CG_AP(ind_Vy),'x','Markersize',11);

ind_Vm = Sujet.(acq_courante).primResultats.Vm(1);
h_marks_Vm = plot(haxes3,Sujet.(acq_courante).t(ind_Vm),Sujet.(acq_courante).V_CG_AP(ind_Vm),'x','Markersize',11);

ind_Vmin = Sujet.(acq_courante).primResultats.VZmin_APA(1);
h_marks_VZ_min = plot(haxes4,Sujet.(acq_courante).t(ind_Vmin),Sujet.(acq_courante).V_CG_Z(ind_Vmin),'x','Markersize',11);

ind_V1 = Sujet.(acq_courante).primResultats.V1(1);
h_marks_V1 = plot(haxes4,Sujet.(acq_courante).t(ind_V1),Sujet.(acq_courante).V_CG_Z(ind_V1),'x','Markersize',11);

ind_V2 = Sujet.(acq_courante).primResultats.V2(1);
h_marks_V2 = plot(haxes4,Sujet.(acq_courante).t(ind_V2),Sujet.(acq_courante).V_CG_Z(ind_V2),'x','Markersize',11);

%Activation des bouton de modification manuelle des vitesses
set(findobj('tag','Vy_FO1'),'Visible','On');
set(findobj('tag','Vm'),'Visible','On');
set(findobj('tag','Vmin_APA'),'Visible','On');
set(findobj('tag','V1'),'Visible','On');
set(findobj('tag','V2'),'Visible','On');
set(findobj('tag','pushbutton20'),'Visible','On');

set(findobj('tag','V_der'),'Visible','On');
set(findobj('tag','V_intgr'),'Visible','On');

% --- Executes on button press in Calc_current.
function Calc_current_Callback(hObject, eventdata, handles)
%% Calculs des APA sur l'acquisition selectionnée
% hObject    handle to Calc_current (see GCBO)
global Sujet acq_courante Resultats

% Calculs
Resultats.(acq_courante) = calculs_parametres_initiationPas_v1(Sujet.(acq_courante));
    
% Export Excel
button = questdlg('Exporter sur Excel??','Sauvegarde résultats','Oui','Non','Non');
if strcmp(button,'Oui')
    fichier = cell2mat(inputdlg('Entrez le nom du fichier/sujet','Ecriture .xls'));
    if exist([fichier '.xls'],'file')
        sheet = cell2mat(inputdlg('Entrez le nom de la feuille/sujet','Fichier existant! Ecraser?'));
    else
        sheet = fichier;
    end
    ecrireQR_xls(Resultats.(acq_courante),[fichier '.xls'],sheet);
else
    warndlg('Attention données non exportées!');
end
%Affichage
% Current_Res=zeros(26,1);
Current_Res={};
param = fieldnames(Resultats.(acq_courante));
for i=1:length(param)
    Current_Res{i,1} = param{i};
    Current_Res{i,2} = getfield(Resultats.(acq_courante),param{i});
end
set(findobj('tag','Results'),'Data',Current_Res);
% --- Executes on button press in Calc_batch.
function Calc_batch_Callback(hObject, eventdata, handles)
%% Calculs des APA sur toutes les acquisitions
% hObject    handle to Calc_batch (see GCBO)
global Sujet Resultats

% Calculs
liste = fieldnames(Sujet);
wb = waitbar(0);
set(wb,'Name','Please wait... Calculating data');

for i=1:length(liste)
    waitbar(i/length(liste)-1,wb,['Calcul acquisition: ' liste{i}]);
    Resultats.(liste{i}) = calculs_parametres_initiationPas_v1(Sujet.(liste{i}));
end

% Export Excel
button = questdlg('Exporter sur Excel??','Sauvegarde résultats','Oui','Non','Non');
if strcmp(button,'Oui')
    fichier = cell2mat(inputdlg('Entrez le nom du fichier/sujet','Ecriture .xls'));
    if exist([fichier '.xls'],'file')
        sheet = cell2mat(inputdlg('Entrez le nom de la feuille/sujet','Fichier existant! Ecraser?'));
    else
        sheet = fichier;
    end
    waitbar(i/length(liste),wb,['Calcul acquisition: ' liste{i}]);
    ecrireQR_xls(Resultats,[fichier '.xls'],sheet);
else
    warndlg('Attention données non exportées!');
end
close(wb);    
% --- Executes on button press in Group_APA.
function Group_APA_Callback(hObject, eventdata, handles)
%% Moyennage des acquisitions sélectionnées et stockage dans une variable acquisition (groupe)
% hObject    handle to Group_APA (see GCBO)
global Sujet Resultats
inputdlg('Entrez le nom du groupe','Calcul corridor Moyen');

% --- Executes on button press in V_der.
function V_der_Callback(hObject, eventdata, handles)
%% Etat d'affichage de la vitesse obtenue par dérivation
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
%% Etat d'affichage de la vitesse obtenue par intégration
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
%% Nettoyage des données en éliminant manuellement les mauvaises acquisitions
% hObject    handle to Clean_data (see GCBO)


% --- Executes on button press in Automatik_display.
function Automatik_display_Callback(hObject, eventdata, handles)
% hObject    handle to Automatik_display (see GCBO)

% Hint: get(hObject,'Value') returns toggle state of Automatik_display
