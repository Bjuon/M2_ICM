function varargout = Test_APA_v0(varargin)
% TEST_APA_V0 MATLAB code for Test_APA_v0.fig
%      TEST_APA_V0, by itself, creates a new TEST_APA_V0 or raises the existing
%      singleton*.
%
%      H = TEST_APA_V0 returns the handle to a new TEST_APA_V0 or the handle to
%      the existing singleton*.
%
%      TEST_APA_V0('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST_APA_V0.M with the given input arguments.
%
%      TEST_APA_V0('Property','Value',...) creates a new TEST_APA_V0 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Test_APA_v0_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Test_APA_v0_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Test_APA_v0

% Last Modified by GUIDE v2.5 27-Mar-2012 18:19:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Test_APA_v0_OpeningFcn, ...
                   'gui_OutputFcn',  @Test_APA_v0_OutputFcn, ...
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


% --- Executes just before Test_APA_v0 is made visible.
function Test_APA_v0_OpeningFcn(hObject, eventdata, handles, varargin)
global haxes1 hF_AP haxes2 hF_ML h_marks_T0
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Test_APA_v0 (see VARARGIN)

% Choose default command line output for Test_APA_v0
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Test_APA_v0 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

scrsz = get(0,'ScreenSize');
set(hObject,'Position',[scrsz(3)/20 scrsz(4)/20 scrsz(3)*9/10 scrsz(4)*9/10]);

hF_AP = plot(haxes1,0,0,'b-');
ylabel(haxes1,'Axe antéro-postérieur (mm)','FontName','Times New Roman','FontSize',10);
set(haxes1,'Visible','Off');

hF_ML = plot(haxes2,0,0,'b-');
ylabel(haxes2,'Axe médio-latéral(mm)','FontName','Times New Roman','FontSize',10);
set(haxes2,'Visible','Off');

set(gcf,'Name','Calcul des APA v.0');

h_marks_T0 = [];


% --- Outputs from this function are returned to the command line.
function varargout = Test_APA_v0_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
global haxes1 haxes2 Donnes hF_AP hF_ML acq_courante h_marks_T0
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

efface_marqueur_test(h_marks_T0);

contents = cellstr(get(hObject,'String'));
acq_courante = contents{get(hObject,'Value')};

axess = findobj('Type','axes');
for i=1:length(axess)
    if get(findobj('tag','Multiplot'),'Value')
        set(axess(i),'NextPlot','add');
    else
        set(axess(i),'NextPlot','replace');
    end
end
    
% set(hF_AP,'Xdata',Donnes.(acq_courante).t,'Ydata',Donnes.(acq_courante).CP_AP);hold on
% set(hF_ML,'Xdata',Donnes.(acq_courante).t,'Ydata',Donnes.(acq_courante).CP_ML);
plot(haxes1,Donnes.(acq_courante).t,Donnes.(acq_courante).CP_AP);
plot(haxes2,Donnes.(acq_courante).t,Donnes.(acq_courante).CP_ML);

set(haxes1,'XTick',NaN);
% set(haxes3,'XTick',NaN);
set(findobj('tag','text_cp'),'Visible','On');
set(findobj('tag','Markers'), 'Visible','On');

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
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global haxes1 haxes2 Freq_vid fin Donnes dossier Multiplot

%Choix manuel des fichiers
[files dossier] = uigetfile('*.c3d','Choix du/des fichier(s) c3d','Multiselect','on');

%Initialisation
clear Donnes
Multiplot =0;

Donnes = pretraitement_dataAPA(files,dossier);
%Mise à jour interface et activation des boutons
set(findobj('tag','listbox1'), 'Visible','On');
set(findobj('tag','listbox1'), 'String',fieldnames(Donnes));
set(findobj('tag','togglebutton1'),'Visible','On');
set(findobj('tag','AutoScale'),'Visible','On');

set(haxes1,'Visible','On');
set(haxes2,'Visible','On');

% --------------------------------------------------------------------
function uipushtool2_ClickedCallback(hObject, eventdata, handles)
%% Choix dossier (directory)
% hObject    handle to uipushtool2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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

%Mise à jour interface et activation des boutons
set(findobj('tag','listbox1'), 'Visible','On');
set(findobj('tag','listbox1'), 'String',fieldnames(Donnes));
set(findobj('tag','togglebutton1'),'Visible','On');
set(findobj('tag','AutoScale'),'Visible','On');

set(haxes1,'Visible','On');
set(haxes2,'Visible','On');


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
global haxes1
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
haxes1 = hObject;
% Hint: place code in OpeningFcn to populate axes1


% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
global haxes2
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
haxes2 = hObject;

% Hint: place code in OpeningFcn to populate axes2

% --- Executes during object creation, after setting all properties.
function axes3_CreateFcn(hObject, eventdata, handles)
global haxes3
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
haxes3 = hObject;

% Hint: place code in OpeningFcn to populate axes3


% --- Executes during object creation, after setting all properties.
function axes4_CreateFcn(hObject, eventdata, handles)
global haxes4
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
haxes4 = hObject;

% Hint: place code in OpeningFcn to populate axes4


% --------------------------------------------------------------------
function uipushtool4_ClickedCallback(hObject, eventdata, handles)
% Chargement d'un fichier deja traité
% hObject    handle to uipushtool4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function uipushtool3_ClickedCallback(hObject, eventdata, handles)
% Sauvegarde sujet courant
global Donnes
% hObject    handle to uipushtool3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in AutoScale.
function AutoScale_Callback(hObject, eventdata, handles)
% Remise à l'échelle
% hObject    handle to AutoScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axis tight

% --- Executes on button press in T0.
function T0_Callback(hObject, eventdata, handles)
global Donnes acq_courante h_marks_T0
% hObject    handle to T0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
% hObject    handle to TO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in FC1.
function FC1_Callback(hObject, eventdata, handles)
% hObject    handle to FC1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in FO2.
function FO2_Callback(hObject, eventdata, handles)
% hObject    handle to FO2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in FC2.
function FC2_Callback(hObject, eventdata, handles)
% hObject    handle to FC2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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
global Donnes acq_courante h_marks_T0
% hObject    handle to Markers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

efface_marqueur_test(h_marks_T0);
h_marks_T0 = affiche_marqueurs(Donnes.(acq_courante).T0,'-r');

set(findobj('tag','T0'),'Visible','On');
set(findobj('tag','HO'),'Visible','On');
set(findobj('tag','TO'),'Visible','On');
set(findobj('tag','FC1'),'Visible','On');
set(findobj('tag','FO2'),'Visible','On');
set(findobj('tag','FC2'),'Visible','On');


% --- Executes on button press in Multiplot.
function Multiplot_Callback(hObject, eventdata, handles)
% hObject    handle to Multiplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

MultiPlot = get(hObject,'Value'); % Hint:  returns toggle state of Multiplot
