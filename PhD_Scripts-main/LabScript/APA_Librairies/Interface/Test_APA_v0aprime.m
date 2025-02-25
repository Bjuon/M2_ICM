function varargout = Test_APA_v0a(varargin)
% TEST_APA_V0A MATLAB code for Test_APA_v0a.fig
%      TEST_APA_V0A, by itself, creates a new TEST_APA_V0A or raises the existing
%      singleton*.
%
%      H = TEST_APA_V0A returns the handle to a new TEST_APA_V0A or the handle to
%      the existing singleton*.
%
%      TEST_APA_V0A('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST_APA_V0A.M with the given input arguments.
%
%      TEST_APA_V0A('Property','Value',...) creates a new TEST_APA_V0A or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Test_APA_v0a_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Test_APA_v0a_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Test_APA_v0a

% Last Modified by GUIDE v2.5 27-Mar-2012 19:28:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Test_APA_v0a_OpeningFcn, ...
                   'gui_OutputFcn',  @Test_APA_v0a_OutputFcn, ...
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


% --- Executes just before Test_APA_v0a is made visible.
function Test_APA_v0a_OpeningFcn(hObject, ~, handles, varargin)
global haxes1 haxes2 haxes3 haxes4 h_marks_T0 h_marks_HO h_marks_TO h_marks_FC1 h_marks_FO2 h_marks_FC2
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Test_APA_v0a (see VARARGIN)

% Choose default command line output for Test_APA_v0a
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Test_APA_v0a wait for user response (see UIRESUME)
% uiwait(handles.figure1);

scrsz = get(0,'ScreenSize');
set(hObject,'Position',[scrsz(3)/20 scrsz(4)/20 scrsz(3)*9/10 scrsz(4)*9/10]);

ylabel(haxes1,'Axe antéro-postérieur (mm)','FontName','Times New Roman','FontSize',10);
set(haxes1,'Visible','Off');

ylabel(haxes2,'Axe médio-latéral(mm)','FontName','Times New Roman','FontSize',10);
set(haxes2,'Visible','Off');

% ylabel(haxes3,'Axe antéro-postérieur (mm/s)','FontName','Times New Roman','FontSize',10);
% set(haxes3,'Visible','Off');
% 
% ylabel(haxes2,'Axe vertical(mm/s)','FontName','Times New Roman','FontSize',10);
% set(haxes4,'Visible','Off');

set(gcf,'Name','Calcul des APA v.0a');

h_marks_T0 = [];
h_marks_HO = [];
h_marks_TO = [];
h_marks_FC1 = [];
h_marks_FO2 = [];
h_marks_FC2= [];

% --- Outputs from this function are returned to the command line.
function varargout = Test_APA_v0a_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
global haxes1 haxes2 haxes3 haxes4 Donnes acq_courante h_marks_T0 h_marks_HO h_marks_TO h_marks_FC1 h_marks_FO2 h_marks_FC2
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

contents = cellstr(get(hObject,'String'));
acq_courante = contents{get(hObject,'Value')};

axess = findobj('Type','axes');
for i=1:length(axess)
    if get(findobj('tag','Multiplot'),'Value')
        set(axess(i),'NextPlot','add');
        efface_marqueur_test(h_marks_T0);
        efface_marqueur_test(h_marks_HO);
        efface_marqueur_test(h_marks_TO);
        efface_marqueur_test(h_marks_FC1);
        efface_marqueur_test(h_marks_FO2);
        efface_marqueur_test(h_marks_FC2);
    else
        set(axess(i),'NextPlot','replace');
    end
end
    
plot(haxes1,Donnes.(acq_courante).t,Donnes.(acq_courante).CP_AP);
plot(haxes2,Donnes.(acq_courante).t,Donnes.(acq_courante).CP_ML);

set(haxes1,'XTick',NaN);
% set(haxes3,'XTick',NaN);

set(findobj('tag','text_cp'),'Visible','On');
ylabel(haxes1,'Axe antéro-postérieur (mm)','FontName','Times New Roman','FontSize',10);
ylabel(haxes2,'Axe médio-latéral(mm)','FontName','Times New Roman','FontSize',10);
% ylabel(haxes3,'Axe antéro-postérieur (mm/s)','FontName','Times New Roman','FontSize',10);
% ylabel(haxes2,'Axe vertical(mm/s)','FontName','Times New Roman','FontSize',10);

set(findobj('tag','Markers'), 'Visible','On');
set(findobj('tag','text_cg'),'Visible','On');


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
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
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
%% Choix fichier (simple/multiple)
% hObject    handle to uipushtool1 (see GCBO)
global haxes1 haxes2 Freq_vid fin Donnes dossier Multiplot

%Choix manuel des fichiers
[files dossier] = uigetfile('*.c3d','Choix du/des fichier(s) c3d','Multiselect','on');

%Initialisation
clear Donnes
Multiplot =0;

Donnes = pretraitement_dataAPA(files,dossier);
%% Mise à jour interface et activation des boutons
set(findobj('tag','listbox1'), 'Visible','On');
set(findobj('tag','listbox1'), 'String',fieldnames(Donnes));
set(findobj('tag','togglebutton1'),'Visible','On');
set(findobj('tag','AutoScale'),'Visible','On');
set(findobj('tag','Multiplot'),'Visible','On');
set(findobj('tag','yAPA_AP'),'Visible','On');
set(findobj('tag','yAPA_ML'),'Visible','On');

set(haxes1,'Visible','On');
set(haxes2,'Visible','On');

% --------------------------------------------------------------------
function uipushtool2_ClickedCallback(hObject, eventdata, handles)
%% Choix dossier (directory)
% hObject    handle to uipushtool2 (see GCBO)
global haxes1 haxes2 Freq_vid fin Donnes dossier Multiplot
dossier = uigetdir(pwd,'Repertoire de stockage des acquisitions du sujet') ;
list_rep= dir(dossier) ;
list_rep(1) = [];
list_rep(1) = [];

%Initialisation
Multiplot = 0;
clear Donnes

%%Extraction des fichiers
files = extrait_liste_acquisitions(list_rep,'c3d');

%%Extraction des donnéers utiles
Donnes = pretraitement_dataAPA(files,[dossier '\']);

%% Mise à jour interface et activation des boutons
set(findobj('tag','listbox1'), 'Visible','On');
set(findobj('tag','listbox1'), 'String',fieldnames(Donnes));
set(findobj('tag','togglebutton1'),'Visible','On');
set(findobj('tag','AutoScale'),'Visible','On');
set(findobj('tag','Multiplot'),'Visible','On');

set(haxes1,'Visible','On');
set(haxes2,'Visible','On');


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
global haxes1
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
haxes1 = hObject;

% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
global haxes2
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
haxes2 = hObject;

% --- Executes during object creation, after setting all properties.
function axes3_CreateFcn(hObject, eventdata, handles)
global haxes3
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
haxes3 = hObject;

% --- Executes during object creation, after setting all properties.
function axes4_CreateFcn(hObject, eventdata, handles)
global haxes4
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
haxes4 = hObject;

% --------------------------------------------------------------------
function uipushtool4_ClickedCallback(hObject, eventdata, handles)
%% Chargement d'un fichier deja traité
% hObject    handle to uipushtool4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function uipushtool3_ClickedCallback(hObject, eventdata, handles)
% Sauvegarde sujet courant
global Donnes
%% Sauvegarde d'un fichier en cours
% hObject    handle to uipushtool3 (see GCBO)

% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in AutoScale.
function AutoScale_Callback(hObject, eventdata, handles)
% Remise à l'échelle
% hObject    handle to AutoScale (see GCBO)
axis tight

% --- Executes on button press in T0.
function T0_Callback(hObject, eventdata, handles)
global Donnes acq_courante h_marks_T0
% hObject    handle to T0 (see GCBO)

Manual_click = ginput(1);
Donnes.(acq_courante).T0 = Manual_click(1);

efface_marqueur_test(h_marks_T0);
h_marks_T0=affiche_marqueurs(Manual_click(1),'-r');

% --- Executes on button press in HO.
function HO_Callback(hObject, eventdata, handles)
global Donnes acq_courante h_marks_HO
% hObject    handle to HO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Manual_click = ginput(1);
Donnes.(acq_courante).HO = Manual_click(1);

efface_marqueur_test(h_marks_HO);
h_marks_HO=affiche_marqueurs(Manual_click(1),'-g');

% --- Executes on button press in TO.
function TO_Callback(hObject, eventdata, handles)
global Donnes acq_courante h_marks_TO
% hObject    handle to TO (see GCBO)

Manual_click = ginput(1);
Donnes.(acq_courante).TO = Manual_click(1);

efface_marqueur_test(h_marks_TO);
h_marks_TO=affiche_marqueurs(Manual_click(1),'-b');

% --- Executes on button press in FC1.
function FC1_Callback(hObject, eventdata, handles)
global Donnes acq_courante h_marks_FC1
% hObject    handle to FC1 (see GCBO)

Manual_click = ginput(1);
Donnes.(acq_courante).FC1 = Manual_click(1);

efface_marqueur_test(h_marks_FC1);
h_marks_FC1=affiche_marqueurs(Manual_click(1),'-m');

% --- Executes on button press in FO2.
function FO2_Callback(hObject, eventdata, handles)
global Donnes acq_courante h_marks_FO2
% hObject    handle to FO2 (see GCBO)

Manual_click = ginput(1);
Donnes.(acq_courante).FO2 = Manual_click(1);

efface_marqueur_test(h_marks_FO2);
h_marks_FO2=affiche_marqueurs(Manual_click(1),'-g');

% --- Executes on button press in FC2.
function FC2_Callback(hObject, eventdata, handles)
global Donnes acq_courante h_marks_FC2
% hObject    handle to FC2 (see GCBO)

Manual_click = ginput(1);
Donnes.(acq_courante).FC2 = Manual_click(1);

efface_marqueur_test(h_marks_FC2);
h_marks_FC2=affiche_marqueurs(Manual_click(1),'-m');

% --- Executes on button press in Vm.
function Vm_Callback(hObject, eventdata, handles)
% hObject    handle to Vm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in V1.
function V1_Callback(hObject, eventdata, handles)
% hObject    handle to V1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in V2.
function V2_Callback(hObject, eventdata, handles)
% hObject    handle to V2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in Markers.
function Markers_Callback(hObject, eventdata, handles)
global Donnes acq_courante h_marks_T0 h_marks_HO h_marks_TO h_marks_FC1 h_marks_FO2 h_marks_FC2
% hObject    handle to Markers (see GCBO)

efface_marqueur_test(h_marks_T0);
efface_marqueur_test(h_marks_HO);
efface_marqueur_test(h_marks_TO);
efface_marqueur_test(h_marks_FC1);
efface_marqueur_test(h_marks_FO2);
efface_marqueur_test(h_marks_FC2);

h_marks_T0 = affiche_marqueurs(Donnes.(acq_courante).T0,'-r');
h_marks_HO = affiche_marqueurs(Donnes.(acq_courante).HO,'-g');
h_marks_TO = affiche_marqueurs(Donnes.(acq_courante).TO,'-b');
h_marks_FC1 = affiche_marqueurs(Donnes.(acq_courante).FC1,'-m');
h_marks_FO2 = affiche_marqueurs(Donnes.(acq_courante).FO2,'-g');
h_marks_FC2 = affiche_marqueurs(Donnes.(acq_courante).FO2,'-m');

set(findobj('tag','T0'),'Visible','On');
set(findobj('tag','HO'),'Visible','On');
set(findobj('tag','TO'),'Visible','On');
set(findobj('tag','FC1'),'Visible','On');
set(findobj('tag','FO2'),'Visible','On');
set(findobj('tag','FC2'),'Visible','On');

% --- Executes on button press in yAPA_AP.
function yAPA_AP_Callback(hObject, eventdata, handles)
global haxes1 Donnes acq_courante h_marks_APAy1
% Detection du max du déplacement postérieur du CP lors des APA
% hObject    handle to yAPA_AP (see GCBO)

[minAPAy_AP ind] = min(Donnes.(acq_courante).CP_AP); %Pas nécessaire à recalculer
set(haxes1,'NextPlot','add');
h_marks_APAy1 = plot(haxes1,Donnes.(acq_courante).t(ind),minAPAy_AP,'x','Markersize',11);
set(haxes1,'NextPlot','new');
%Stockage du résultats
Donnes.(acq_courante).minAPAy_AP = minAPAy_AP;

% --- Executes on button press in yAPA_ML.
function yAPA_ML_Callback(hObject, eventdata, handles)
global haxes2 Donnes acq_courante h_marks_APAy2
% Detection valeur minimale/maximale du déplacement médiolatéral du CP lors des APA
% hObject    handle to yAPA_ML (see GCBO)

[ind APAy]=trouve_APAy(Acquisition);

set(haxes2,'NextPlot','add');
h_marks_APAy2 = plot(haxes2,Donnes.(acq_courante).t(ind),APAy,'x','Markersize',11);
set(haxes2,'NextPlot','new');
%Stockage du résultats
Donnes.(acq_courante).APAy_ML = abs(APAy);
