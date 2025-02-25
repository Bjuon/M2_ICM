function varargout = Traitement_EMG_v3(varargin)
% TRAITEMENT_EMG_V3 MATLAB code for Traitement_EMG_v3.fig
%      TRAITEMENT_EMG_V3, by itself, creates a new TRAITEMENT_EMG_V3 or raises the existing
%      singleton*.
%
%      H = TRAITEMENT_EMG_V3 returns the handle to a new TRAITEMENT_EMG_V3 or the handle to
%      the existing singleton*.
%
%      TRAITEMENT_EMG_V3('CALLBACK',hObject,eventdata,handles,...) calls the local
%      function named CALLBACK in TRAITEMENT_EMG_V3.M with the given input arguments.
%
%      TRAITEMENT_EMG_V3('Property','Value',...) creates a new TRAITEMENT_EMG_V3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Traitement_EMG_v3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Traitement_EMG_v3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Traitement_EMG_v3

% Last Modified by GUIDE v2.5 08-Nov-2016 12:32:53
% Modifications apportées sur la v3 :
% Affichage des évènements placés dans le c3d

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name', mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Traitement_EMG_v3_OpeningFcn, ...
    'gui_OutputFcn',  @Traitement_EMG_v3_OutputFcn, ...
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


% --- Executes just before Traitement_EMG_v3 is made visible.
function Traitement_EMG_v3_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)
% varargin   command line arguments to Traitement_EMG_v3 (see VARARGIN)
global haxes1 haxes2

% Choose default command line output for Traitement_EMG_v3
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Test_APA_v3e wait for user response (see UIRESUME)
% uiwait(handles.Test_APA_v3e);
scrsz = get(0,'ScreenSize');
set(hObject,'Position',[scrsz(3)/30 scrsz(4)/10 scrsz(3)*7/10 scrsz(4)*7/10]);

set(gcf,'Name','Traitement des EMG v3');

ylabel(haxes1,'EMG Brut','FontName','Times New Roman','FontSize',10);
set(haxes1,'Visible','Off');

ylabel(haxes2,'TKEO','FontName','Times New Roman','FontSize',10);
set(haxes2,'Visible','Off');

set(findobj('Tag','listbox1'), 'Visible','Off');
set(findobj('Tag','text1'), 'Visible','Off');

set(findobj('Tag','listbox2'), 'Visible','Off');
set(findobj('Tag','text2'), 'Visible','Off');

set(findobj('Tag','save'), 'Enable','Off');
set(findobj('Tag','calculer'), 'Enable','Off');
set(findobj('Tag','bouffees'), 'Enable','Off');
set(findobj('Tag','Calc_EMG_0toAPA'), 'Visible','off');
set(findobj('Tag','Calc_EMG_EXE'), 'Visible','off');
set(findobj('Tag','Disp_proc_data'),'Visible','off');
set(findobj('Tag','Recalc_for_only_one_EMG'),'Visible','off');
set(findobj('Tag','Recalc_for_only_one_trial'),'Visible','off');

set(findobj('Tag','TKEO'), 'Value',1);
set(findobj('Tag','SampEn'), 'Value',0);
set(findobj('Tag','uipanel_TKEO'), 'Visible','On');
set(findobj('Tag','uipanel_SampEn'), 'Visible','Off');
set(findobj('Tag','uipanel_bouffees'), 'Visible','On');
clearvars -global -except haxes1 haxes2 list_EMG

% UIWAIT makes Traitement_EMG_v3 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = Traitement_EMG_v3_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in listbox1.
% cette liste correspond à la liste des acquisitions
function listbox1_Callback(~, ~, ~)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
draw_emg

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, ~, ~)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox2.
% cette liste correspond à la liste des channels EMG
function listbox2_Callback(~, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2
draw_emg

% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global haxes1
% hObject    handle to axes1 (see GCBO)
haxes1 = hObject;
% Hint: place code in OpeningFcn to populate axes1


% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global haxes2
% hObject    handle to axes1 (see GCBO)
haxes2 = hObject;
% Hint: place code in OpeningFcn to populate axes2

% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles)
% hObject    handle to clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)
global EMG list_EMG
EMG = [];
list_EMG = [];

% --- Executes on button press in pushbutton10.
function Infos(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)
global EMG nom_fich

if ~isfield(EMG,'Infos')
    
    Tag_items = {'Protocole','Session','Code_Sujet','Traitement','Vitesse'};
    items = {'GBMOV','Preop/LFP/M3','XXXXx00','ON/OFF','S/R'};
    items = inputdlg(Tag_items,'Infos',1,items);
    if ~isempty(items)
        nom_fich = [items{1} '_' items{2} '_' items{3} '_' items{4} '_' items{5}];
        EMG.Infos.Protocole = items{1};
        EMG.Infos.Session = items{2};
        EMG.Infos.Subject = items{3};
        EMG.Infos.MedCondition = items{4};
        EMG.Infos.SpeedCondition = items{5};
        EMG.Infos.FileName = nom_fich;
    end
    
else
    Tag_items = {'Protocole','Session','Code_Sujet','Traitement','Vitesse'};
    items = {EMG.Infos.Protocole,EMG.Infos.Session,EMG.Infos.Subject,EMG.Infos.MedCondition,EMG.Infos.SpeedCondition};
    items = inputdlg(Tag_items,'Infos',1,items);
    
    if ~isempty(items)
        nom_fich = [items{1} '_' items{2} '_' items{3} '_' items{4} '_' items{5}];
        EMG.Infos.Protocole = items{1};
        EMG.Infos.Session = items{2};
        EMG.Infos.Subject = items{3};
        EMG.Infos.MedCondition = items{4};
        EMG.Infos.SpeedCondition = items{5};
        EMG.Infos.FileName = nom_fich;
    end
end

%% Chargement des données EMG
% --- Executes on button press in pushbutton1.
function charger_c3d(varargin)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)
global EMG list_EMG dossier nom_fich haxes2

if isempty(varargin)
    %Choix manuel des fichiers
    [files1 dossier] = uigetfile('*.c3d; *.xls','Choix du/des fichier(s) c3d ','Multiselect','on');
else
    files1 = varargin{1};
    dossier = varargin{2};
end
files = setdiff(files1,{'zero_EMG.c3d'});
%Initialisation
EMG = [];
set(findobj('Tag','Disp_proc_data'), 'Visible','off');
set(findobj('Tag','Disp_proc_data'), 'Value',0)

Tag_items = {'Protocole','Session','Code_Sujet','Traitement','Vitesse'};

% on récupère le nom du protocole
prot = strfind(files{1},'_');
Protocole = files{1}(1:prot-1);

if ~isempty(strfind(upper(fullfile(dossier,files{1})),'_PREOP_'))
    Session = 'PREOP';
elseif ~isempty(strfind(upper(fullfile(dossier,files{1})),'_POSTOP_'))
    Session = 'POSTOP';
elseif ~isempty(strfind(upper(fullfile(dossier,files{1})),'_M3STIM1_'))
    Session = 'M3STIM1';
elseif ~isempty(strfind(upper(fullfile(dossier,files{1})),'_M3STIM2_'))
    Session = 'M3STIM2';
elseif ~isempty(strfind(upper(fullfile(dossier,files{1})),'_SESSION1'))
    Session = 'SESSION1';
elseif ~isempty(strfind(upper(fullfile(dossier,files{1})),'_STIMOFF_'))
    Session = 'STIMOFF';
elseif ~isempty(strfind(upper(fullfile(dossier,files{1})),'_SAIN_'))
    Session = 'SAIN';
elseif ~isempty(strfind(upper(fullfile(dossier,files{1})),'_GAIT_')) % Angèle : déf d'une session GAIT pour PSPMARCHE et PARKGAME
    Session = 'GAIT';
else
    Session = '';
end

if ~isempty(strfind(fullfile(dossier,files{1}),'_OFF_'))
    traitement = 'OFF';
elseif ~isempty(strfind(fullfile(dossier,files{1}),'_ON_'))
    traitement = 'ON';
elseif ~isempty(strfind(fullfile(dossier,files{1}),'_NA_'))
    traitement = 'NA';
else
    traitement = '';
end

if ~isempty(strfind(fullfile(dossier,files{1}),'_MN_')) || ~isempty(strfind(fullfile(dossier,files{1}),'_S_'))
    vitesse = 'S';
elseif ~isempty(strfind(fullfile(dossier,files{1}),'_MR_')) || ~isempty(strfind(fullfile(dossier,files{1}),'_R_'))
    vitesse = 'R';
elseif ~isempty(strfind(fullfile(dossier,files{1}),'_AI_'))
    vitesse = 'AI';
else
    vitesse = '';
end

% on récupère tag sujet : ok si nomenclature : PROTOCOLE_SESSION_SUJET_  % Ajout Angèle
idx = (strfind(files{1},'_'));
try
    Tag_sujet = files{1}(idx(2)+1:idx(3)-1);
catch
    Tag_sujet = 'XXXXx00';
end

if strcmp(vitesse,'') % a compléter avec session empty
    items = inputdlg({'Protocole','Session','Sujet','Traitement','Vitesse'},'Inputs',1,...
        {Protocole,'',Tag_sujet,traitement,''});
else
    items = {Protocole,Session,Tag_sujet,traitement,vitesse};
end

items = inputdlg(Tag_items,'Infos',1,items);


if ~isempty(items)
    nom_fich = [items{1} '_' items{2} '_' items{3} '_' items{4} '_' items{5}];
    EMG.Infos.Protocole = items{1};
    EMG.Infos.Session = items{2};
    EMG.Infos.Subject = items{3};
    EMG.Infos.MedCondition = items{4};
    EMG.Infos.SpeedCondition = items{5};
    EMG.Infos.FileName = nom_fich;
else
    nom_fich = '';
end
set(findobj('Tag','nom_sujet'),'String',['Subject : ' char(nom_fich)])

if ischar(files)
    files = {files};
end

%Extraction des données d'intérêts
i_fich = 1;

clear acq analogs list_ana ind_EMG
acq = btkReadAcquisition(fullfile(dossier,files{i_fich}));
if isempty(list_EMG) || strcmp(Protocole,'CERESTIM')
    analogs = btkGetAnalogs(acq);
    list_ana = fieldnames(analogs);
    ind_EMG = listdlg('ListString',list_ana,'SelectionMode','multiple','PromptString','Selectionner les voies EMG');
    list_EMG = list_ana(ind_EMG);
end
clear list_ana ind_EMG

for i_fich = 1 : length(files)
    nom_acq = strrep(files{i_fich}(1:end-4),' ','_');
    clear acq analogs
    acq = btkReadAcquisition(fullfile(dossier,files{i_fich}));
    analogs = btkGetAnalogs(acq);
    Fech = btkGetAnalogFrequency(acq);
    Ev = btkGetEvents(acq);
    list_evts = fields(Ev);
    name_evts(strcmp(list_evts,{'General_Event'}))  = {'Gnl_Ev'};
    name_evts(strcmp(list_evts,{'Right_Foot_Off'}))  = {'R_FO'};
    name_evts(strcmp(list_evts,{'Right_Foot_Strike'}))  = {'R_FC'};
    name_evts(strcmp(list_evts,{'Left_Foot_Off'}))  = {'L_FO'};
    name_evts(strcmp(list_evts,{'Left_Foot_Strike'}))  = {'L_FC'};
    
    i_m = 1;
    
    % Si Lau ToolBox
    %     for i_ev = 1:numel(list_evts)
    %         eval(['nb_rep = numel(Ev.' list_evts{i_ev} ');']);
    %         for i_nb_ev = 1:nb_rep
    %             eval(['e(' num2str(i_m) ') = metadata.event.Stimulus(''tStart'',Ev.' list_evts{i_ev} '(' num2str(i_nb_ev)...
    %                 '),''tEnd'',Ev.' list_evts{i_ev} '(' num2str(i_nb_ev) '),','''name'',''', list_evts{i_ev} num2str(i_nb_ev) ''');']);
    %             i_m = i_m+1;
    %         end
    %     end
    %     EMG.Trial(i_fich).Events = EventProcess('events',e,'tStart',0);
    
    i_evtot = 1;
    for i_ev1=1:numel(list_evts)
        eval(['max_ev = numel(Ev.' list_evts{i_ev1} ');']);
        for i_ev2 = 1:max_ev
            eval(['Evtot(' num2str(i_evtot) ') = Ev.' list_evts{i_ev1} '(' num2str(i_ev2) ');']);
            if max_ev == 1 % si un seul evt pas la peine de mettre indice 1 et 2
                Evtotname{i_evtot} = name_evts{i_ev1};
            else
                Evtotname{i_evtot} = [name_evts{i_ev1}  num2str(i_ev2)];
            end
            i_evtot = i_evtot+1;
        end
    end
    
    EMG.Trial(i_fich).Ev = {Evtot,Evtotname};
    
    for j_EMG = 1 : length(list_EMG)
        temp(j_EMG,:) = (analogs.(list_EMG{j_EMG})- mean(analogs.(list_EMG{j_EMG})))';
    end
    EMG.Trial(i_fich).RAW = Signal_EMG(temp,Fech,'tag',list_EMG,'units',repmat({'V'},1,length(list_EMG)));
    EMG.Trial(i_fich).RAW.TrialName = upper(files{i_fich}(1:strfind(files{i_fich},'.')-1));
    EMG.Trial(i_fich).RAW.TrialNum = str2double(files{i_fich}(strfind(files{i_fich},'.')-2:strfind(files{i_fich},'.')-1));
    EMG.Trial(i_fich).RAW.Description = 'Enregistrements EMG brutes';
    
    clear acq analogs temp;
end

eval('EMG.history =[];');

% Mise à jour de la liste des acquisitions
set(findobj('Tag','text1'), 'Visible','On');
set(findobj('Tag','listbox1'), 'Visible','On');
set(findobj('Tag','listbox1'), 'Value',1);
liste_acq = arrayfun(@(i) EMG.Trial(i).RAW.TrialName, 1:length(EMG.Trial),'uni',0);
set(findobj('Tag','listbox1'),'String',liste_acq);

set(findobj('Tag','text2'), 'Visible','On');
set(findobj('Tag','listbox2'), 'Visible','On');
set(findobj('Tag','listbox2'), 'Value',1);
set(findobj('Tag','listbox2'),'String',list_EMG);

% Activation des axes
axess = findobj('Type','axes');
for i=1:length(axess)
    set(axess(i),'Visible','On');
end

draw_emg
set(findobj('Tag','save'), 'Enable','On');
set(findobj('Tag','calculer'), 'Enable','On');
cla(haxes2,'reset');

%% Chargement des données EMG en batch
% --- Executes on button press in pushbutton1.
function charger_c3d_batch(varargin)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)
global EMG list_EMG dossier nom_fich

if isempty(varargin)
    %Choix manuel des fichiers
    [files1 dossier] = uigetfile('*.c3d; *.xls','Choix du/des fichier(s) c3d ','Multiselect','on');
else
    files1 = varargin{1};
    dossier = varargin{2};
end

files = setdiff(files1,{'zero_EMG.c3d'});
%Initialisation
EMG = [];

% on récupère le nom du protocole
prot = strfind(files{1},'_');
Protocole = files{1}(1:prot-1);

if ~isempty(strfind(lower(fullfile(dossier,files{1})),'preop'))
    Session = 'PREOP';
elseif ~isempty(strfind(lower(fullfile(dossier,files{1})),'postop'))
    Session = 'POSTOP';
elseif ~isempty(strfind(lower(fullfile(dossier,files{1})),'m3stim1'))
    Session = 'M3STIM1';
elseif ~isempty(strfind(lower(fullfile(dossier,files{1})),'m3stim2'))
    Session = 'M3STIM2';
end

if ~isempty(strfind(lower(fullfile(dossier,files{1})),'_off'))
    traitement = 'OFF';
elseif ~isempty(strfind(lower(fullfile(dossier,files{1})),'_on'))
    traitement = 'ON';
else
    traitement = '';
end

if ~isempty(strfind(lower(fullfile(dossier,files{1})),'_mn')) || ~isempty(strfind(lower(fullfile(dossier,files{1})),'_s_'))
    vitesse = 'S';
elseif ~isempty(strfind(lower(fullfile(dossier,files{1})),'_mr')) || ~isempty(strfind(lower(fullfile(dossier,files{1})),'_r_'))
    vitesse = 'R';
elseif ~isempty(strfind(lower(fullfile(dossier,files{1})),'_ai'))
    vitesse = 'AI';
else
    vitesse = '';
end

% on récupère tag sujet : ok si nomenclature : PROTOCOLE_SESSION_SUJET_  % Ajout Angèle
idx = (strfind(files{1},'_'));
try
    Tag_sujet = files{1}(idx(2)+1:idx(3)-1);
catch
    Tag_sujet = 'XXXXx00';
end

items = {Protocole,Session,Tag_sujet,traitement,vitesse};

if ~isempty(items)
    nom_fich = [items{1} '_' items{2} '_' items{3} '_' items{4} '_' items{5}];
    EMG.Infos.Protocole = items{1};
    EMG.Infos.Session = items{2};
    EMG.Infos.Subject = items{3};
    EMG.Infos.MedCondition = items{4};
    EMG.Infos.SpeedCondition = items{5};
    EMG.Infos.FileName = nom_fich;
else
    nom_fich = '';
end
set(findobj('Tag','nom_sujet'),'String',['Sujet : ' nom_fich])

if ischar(files)
    files = {files};
end

for i_fich = 1 : length(files)
    clear acq analogs
    acq = btkReadAcquisition(fullfile(dossier,files{i_fich}));
    analogs = btkGetAnalogs(acq);
    Fech = btkGetAnalogFrequency(acq);
    for j_EMG = 1 : length(list_EMG)
        temp(j_EMG,:) = (analogs.(list_EMG{j_EMG})- mean(analogs.(list_EMG{j_EMG})))';
    end
    EMG.Trial(i_fich).RAW = Signal_EMG(temp,Fech,'tag',list_EMG,'units',repmat({'V'},1,size(list_EMG,1)));
    EMG.Trial(i_fich).RAW.TrialName = upper(files{i_fich}(1:strfind(files{i_fich},'.')-1));
    EMG.Trial(i_fich).RAW.TrialNum = str2double(files{i_fich}(strfind(files{i_fich},'.')-2:strfind(files{i_fich},'.')-1));
    EMG.Trial(i_fich).RAW.Description = 'Enregistrements EMG brutes pour GBMOV';
    clear acq analogs temp
    
end

EMG.history =[];
EMG.removedTrials =[];

% Mise à jour de la liste des acquisitions
set(findobj('Tag','text1'), 'Visible','On');
set(findobj('Tag','listbox1'), 'Visible','On');
set(findobj('Tag','listbox1'), 'Value',1);
liste_acq = arrayfun(@(i) EMG.Trial(i).RAW.TrialName, 1:length(EMG.Trial),'uni',0);
set(findobj('Tag','listbox1'),'String',liste_acq);

set(findobj('Tag','text2'), 'Visible','On');
set(findobj('Tag','listbox2'), 'Visible','On');
set(findobj('Tag','listbox2'), 'Value',1);
set(findobj('Tag','listbox2'),'String',list_EMG);

%Activation des axes
axess = findobj('Type','axes');
for i=1:length(axess)
    set(axess(i),'Visible','On');
end

draw_emg
set(findobj('Tag','save'), 'Enable','On');
set(findobj('Tag','calculer'), 'Enable','On');

%% charger .mat
% --- Executes on button press in pushbutton7.
function charger_mat(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)
global EMG list_EMG dossier nom_fich

[file dossier] = uigetfile('*_EMG.mat','Choix du fichier mat');
load(fullfile(dossier,file));
eval(['EMG = '  file(1:end-4) ';']);
if ~isfield(EMG,'Infos') || isempty(EMG.Infos.FileName)
    
    Tag_items = {'Protocole','Session','Code_Sujet','Traitement','Vitesse'};
    
    
    % on récupère le nom du protocole
    prot = strfind(files{1},'_');
    Protocole = files{1}(1:prot-1);
    
    if ~isempty(strfind(fullfile(dossier,file),'Preop'))
        Session = 'Preop';
    elseif ~isempty(strfind(fullfile(dossier,file),'LFP'))
        Session = 'LFP';
    elseif ~isempty(strfind(fullfile(dossier,file),'M3Stim1'))
        Session = 'M3Stim1';
    elseif ~isempty(strfind(fullfile(dossier,file),'M3Stim2'))
        Session = 'M3Stim2';
    end
    
    if ~isempty(strfind(fullfile(dossier,file),'OFF'))
        traitement = 'OFF';
    elseif ~isempty(strfind(fullfile(dossier,file),'ON'))
        traitement = 'ON';
    else
        traitement = '';
    end
    
    if ~isempty(strfind(fullfile(dossier,file),'MN')) || ~isempty(strfind(fullfile(dossier,file),'S'))
        vitesse = 'S';
    elseif ~isempty(strfind(fullfile(dossier,file),'MR')) || ~isempty(strfind(fullfile(dossier,file),'R'))
        vitesse = 'R';
    elseif ~isempty(strfind(fullfile(dossier,files{1}),'AI'))
        vitesse = 'AI';
    else
        vitesse = '';
    end
    
    % on récupère tag sujet : ok si nomenclature : PROTOCOLE_SESSION_SUJET_  % Ajout Angèle
    idx = (strfind(files{1},'_'));
    try
        Tag_sujet = files{1}(idx(2)+1:idx(3)-1);
    catch
        Tag_sujet = 'XXXXx00';
    end
    
    items = {Protocole,Session,Tag_sujet,traitement,vitesse};
    %     items = inputdlg(Tag_items,'Infos',1,items);
    
    nom_fich = upper([items{1} '_' items{2} '_' items{3} '_' items{4} '_' items{5}]);
else
    nom_fich = EMG.Infos.FileName;
end

set(findobj('Tag','nom_sujet'),'String',['Sujet : ' nom_fich])

% Mise à jour de la liste des acquisitions
set(findobj('Tag','text1'), 'Visible','On');
set(findobj('Tag','listbox1'), 'Visible','On');
set(findobj('Tag','listbox1'), 'Value',1);
files = arrayfun(@(i) EMG.Trial(i).RAW.TrialName, 1:length(EMG.Trial),'uni',0);
set(findobj('Tag','listbox1'),'String',files);

champ = fieldnames(EMG);
list_EMG = EMG.Trial(1).RAW.Tag;
set(findobj('Tag','text2'), 'Visible','On');
set(findobj('Tag','listbox2'), 'Visible','On');
set(findobj('Tag','listbox2'), 'Value',1);
set(findobj('Tag','listbox2'),'String',list_EMG);

%Activation des axes
axess = findobj('Type','axes');
for i=1:length(axess)
    set(axess(i),'Visible','On');
end

% on rend dispo les boutons comme après calculs des bouffees
set(findobj('Tag','Calc_EMG_0toAPA'), 'Visible','On');
set(findobj('Tag','Calc_EMG_EXE'), 'Visible','On');
set(findobj('Tag','Disp_proc_data'),'Visible','on');
set(findobj('Tag','Disp_proc_data'),'Value',1);
set(findobj('Tag','Recalc_for_only_one_EMG'),'Visible','on');
set(findobj('Tag','Recalc_for_only_one_trial'),'Visible','on');

draw_emg
set(findobj('Tag','save'), 'Enable','On');
if isfield(EMG.Trial(1),'RAW')
    set(findobj('Tag','calculer'), 'Enable','On');
end
if isfield(EMG.Trial(1),'SampEn')
    set(findobj('Tag','bouffees'), 'Enable','On');
    SampEn_Callback;
end
if isfield(EMG.Trial(1),'TKEO')
    set(findobj('Tag','bouffees'), 'Enable','On');
    
    TKEO_Callback;
end

%% Draw_EMG
% On trace les EMG
function draw_emg
global EMG haxes1 haxes2

lbls_EMG_1stright={'TA Swing','SOL Swing','TA Stance','SOL Stance'};
lbls_EMG_1stleft={'TA Stance','SOL Stance','TA Swing','SOL Swing'};

try
    val1 = get(findobj('Tag','listbox1'),'Value');
catch
    val1 = 1;
    set(findobj('Tag','listbox1'),'Value',val1);
end
list1 = get(findobj('Tag','listbox1'),'String');
nom_acq = list1(val1);

set(findobj('Tag','nom_essai'),'String',['Trial : ' char(nom_acq)])

try
    val2 = get(findobj('Tag','listbox2'),'Value');
catch
    val2 = 1;
    set(findobj('Tag','listbox2'),'Value',val1);
end
list2 = get(findobj('Tag','listbox2'),'String');
nom_emg = list2(val2);

set(haxes1,'Nextplot','replacechildren')
% Trace par défaut le RAW
% temp = EMG.Trial(val1).RAW.subset(val2);
% plot(temp,'handle',haxes1);
% EMG.Trial(val1).RAW.reset;
plot(haxes1,EMG.Trial(val1).RAW.Time,EMG.Trial(val1).RAW.Data(val2,:))

% Tracés des events temporels (si existent)
try
    set(haxes1,'Nextplot','add'); axes(haxes1);
    yBornes = get(haxes1,'YLim');
    switch EMG.Trial(val1).Ev{2}{3}(1) % correspond au FO du 1er pied
        case 'L'
            set(findobj('Tag','first_foot'),'String','First foot : Left','ForegroundColor',[0.75 0 0]);
        case 'R'
            set(findobj('Tag','first_foot'),'String','First foot : Right','ForegroundColor',[0 0.75 0]);
    end
    for i_ev = 1:numel(EMG.Trial(val1).Ev{1})
        % General Event -> Noir // Si Left Foot : Rouge // Si Right Foot : Vert
        switch EMG.Trial(val1).Ev{2}{i_ev}(1)
            case 'G'
                col = [0 0 0];
            case 'L'
                col = [0.55 0 0];
            case 'R'
                col = [0 0.55 0];
        end
        plot(haxes1,[EMG.Trial(val1).Ev{1}(i_ev) EMG.Trial(val1).Ev{1}(i_ev)],0.7*yBornes,'Color',col,'LineStyle','--');
        text(EMG.Trial(val1).Ev{1}(i_ev),0.7*yBornes(1),str_rep(EMG.Trial(val1).Ev{2}{i_ev}),'Rotation',-25);
    end
catch
    disp('Info : Events not available');
end
set(haxes1,'Nextplot','replace')
% Si "Bouffee" sélectionné : trace les bouffées
if isfield(EMG.Trial(val1),'Bouffee') && isfield(EMG.Trial(val1),'Bouffee')
    set(haxes1,'Nextplot','add')
    plot(haxes1,EMG.Trial(val1).Bouffee.Time,EMG.Trial(val1).Bouffee.Data(val2,:),'Color',[1 0 0]);
end

% set(haxes1,'ylim',[-1.5 1.5]);
set(haxes1,'xlim',[0 str2num(get(findobj('Tag','XLimMax'),'string'))]);

% Si TKEO calculé
if  get(findobj('Tag','TKEO'), 'Value') && isfield(EMG.Trial(val1),'TKEO')
    set(haxes2,'Nextplot','replace')
    plot(haxes2,EMG.Trial(val1).TKEO.Time,EMG.Trial(val1).TKEO.Data(val2,:));
    if isfield(EMG.Trial(val1),'Bouffee') && ~isempty(EMG.Trial(val1).Bouffee.Data)
        set(haxes2,'Nextplot','add')
        clear temp
        temp = EMG.Trial(val1).TKEO.Data(val2,:);
        temp(isnan(EMG.Trial(val1).Bouffee.Data(val2,:))) = NaN;
        plot(haxes2,EMG.Trial(val1).TKEO.Time,temp,'Color',[1 0 0]);
        plot(haxes2,[min(EMG.Trial(val1).TKEO.Time) max(EMG.Trial(val1).TKEO.Time)],[EMG.Infos.seuilTKEO(val2) EMG.Infos.seuilTKEO(val2)],'k--');
        clear temp
    end
end
if isfield(EMG.Trial(val1),'SampEn') && get(findobj('Tag','SampEn'), 'Value');
    set(haxes2,'Nextplot','replace')
    plot(haxes2,EMG.Trial(val1).SampEn.Time,EMG.Trial(val1).SampEn.Data(val2,:))
    if isfield(EMG.Trial(val1),'Bouffee') && ~isempty(EMG.Trial(val1).Bouffee.Data)
        set(haxes2,'Nextplot','add')
        clear temp
        temp = EMG.Trial(val1).SampEn.Data(val2,:);
        temp(isnan(EMG.Trial(val1).Bouffee.Data(val2,:))) = NaN;
        plot(haxes2,EMG.Trial(val1).SampEn.Time,temp,'Color',[1 0 0]);
        clear temp
    end
end
set(haxes2,'xlim',[0 str2num(get(findobj('Tag','XLimMax'),'string'))]);
% Si Processed data coché
if  get(findobj('Tag','Disp_proc_data'), 'Value')
    set(haxes2,'Nextplot','replace')
    plot(haxes2,EMG.Trial(val1).Processed.Time,EMG.Trial(val1).Processed.Data(val2,:),'color',[0.4 0 0.7]);
    % on trace en plus gros les parties sans bouffées
    set(haxes2,'Nextplot','add');
    temp = EMG.Trial(val1).Processed.Data(val2,:);
    temp(temp~=0) = NaN;
    plot(haxes2,EMG.Trial(val1).Processed.Time,temp,'color','k','LineWidth',2);
end
% Tracés des events temporels (si existent)
try
    set(haxes2,'Nextplot','add');  axes(haxes1);
    yBornes = get(haxes2,'YLim');
    switch EMG.Trial(val1).Ev{2}{3}(1) % correspond au FO du 1er pied
        case 'L'
            set(findobj('Tag','first_foot'),'String','First foot : Left','ForegroundColor',[0.75 0 0]);
            set(findobj('Tag','current_EMG'),'String',['Current EMG : ' lbls_EMG_1stleft{val2}]);
        case 'R'
            set(findobj('Tag','first_foot'),'String','First foot : Right','ForegroundColor',[0 0.75 0]);
            set(findobj('Tag','current_EMG'),'String',['Current EMG : ' lbls_EMG_1stright{val2}]);
    end
    for i_ev = 1:numel(EMG.Trial(val1).Ev{1})
        % General Event -> Noir // Si Left Foot : Rouge // Si Right Foot : Vert
        switch EMG.Trial(val1).Ev{2}{i_ev}(1)
            case 'G'
                col = [0 0 0];
            case 'L'
                col = [0.55 0 0];
            case 'R'
                col = [0 0.55 0];
        end
        plot(haxes2,[EMG.Trial(val1).Ev{1}(i_ev) EMG.Trial(val1).Ev{1}(i_ev)],0.7*yBornes,'Color',col,'LineStyle','--');
        %         text(EMG.Trial(val1).Ev{1}(i_ev),0.7*yBornes(1),str_rep(EMG.Trial(val1).Ev{2}{i_ev}),'Rotation',-25);
    end
catch
    disp('Info : Events not available');
end
set(haxes2,'xlim',[0 str2num(get(findobj('Tag','XLimMax'),'string'))]);

%% sauvegarde
% --- Executes on button press in save.
function sauvegarder(varargin)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)
global EMG nom_fich

if isempty(varargin)
    [~, dossier] = uiputfile([nom_fich '.mat']);
    nom_fich_EMG = upper([nom_fich '_EMG']);
    eval([nom_fich_EMG ' = EMG;']);
else
    nom_fich_EMG = upper([nom_fich '_EMG']);
    eval([nom_fich_EMG ' = EMG;']);
    dossier = varargin{1};
end

eval(['save(fullfile(dossier,[nom_fich_EMG ''.mat'']),''' nom_fich_EMG ''');']);
eval(['clear ''' nom_fich_EMG '''']);
set(findobj('Tag','nom_sujet'),'String',['Sujet : ' nom_fich ])

%% batch
% --- Executes on button press in pushbutton6.
function Batch()
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)
global list_EMG
% choix des patients
chemin = uigetdir([],'Choix des repertoires contenant les acquisitions c3d');
liste=dir(chemin);
liste_patients = cell(1,size(liste,1));
[liste_patients{1:size(liste,1)}] = deal(liste.name);
[s,~] = listdlg('PromptString',{'choisir les patients'},...
    'ListSize',[300 300],...
    'ListString',liste_patients);
cd(chemin);
liste_choix=liste_patients(s)';

session = {'PREOP','POSTOP','M3STIM1','M3STIM2'};
[s,~] = listdlg('PromptString',{'choisir les sessions'},...
    'ListSize',[300 300],...
    'ListString',session);
liste_session=session(s)';

condition = {'ON_S','ON_R','OFF_S','OFF_R'};
[s,~] = listdlg('PromptString',{'choisir les sessions'},...
    'ListSize',[300 300],...
    'ListString',condition);
liste_condition=condition(s)';

chemin_res = uigetdir([],'Choix du répertoire de destination des .mat de résultats');

for i_choix = 1 : length(liste_choix)
    for j_session = 1 : length(liste_session)
        path = fullfile(chemin,liste_choix{i_choix},liste_session{j_session});
        if exist(path,'dir')==7
            for k_condition = 1 : length(liste_condition)
                try
                    cd(path)
                    A = dir(['*' liste_condition{k_condition} '*.c3d']);
                    clear files
                    files = {A(:).name};
                    
                    %Extraction des données d'intérêts
                    clear acq analogs list_ana ind_EMG
                    acq = btkReadAcquisition(fullfile(path,files{1}));
                    if i_choix == 1 && j_session == 1 && k_condition == 1
                        analogs = btkGetAnalogs(acq);
                        list_ana = fieldnames(analogs);
                        ind_EMG = listdlg('ListString',list_ana,'SelectionMode','multiple','PromptString','Selectionner les voies EMG');
                        list_EMG = list_ana(ind_EMG);
                    end
                    clear acq analogs list_ana ind_EMG
                    
                    charger_c3d_batch(files,path);
                    calculer_Callback;
                    bouffees;
                    sauvegarder(chemin_res);
                    
                    cd('..')
                    cd(chemin)
                catch Err_batchEMG
                    warning([fullfile(path,files{1}) ' / Annulation chargement / ' Err_batchEMG.message]);
                end
            end
        else
            warning(['Le repertoire d''acquisition n''existe pas : ', path])
        end
    end
end

%% export des figures
function export_figure()

global EMG

list1 = get(findobj('Tag','listbox1'),'String');
list2 = get(findobj('Tag','listbox2'),'String');

for i_list1 = 1 : length(list1)
    nom_acq = list1{i_list1};
    for j_list2 = 1 : length(list2)
        nom_emg = list2{j_list2};
        nom_fig = [nom_acq '_' nom_emg];
        f1 = figure('Color',[1 1 1],'units','Normalized','Position', [0.1 0.1 0.8 0.8]);
        f1_axes1 = subplot(2,1,1);
        f1_axes2 = subplot(2,1,2);
        set(f1_axes1,'Nextplot','replace')
        plot(f1_axes1,EMG.Trial(i_list1).RAW.Time,EMG.Trial(i_list1).RAW.Data(j_list2,:))
        if isfield(EMG.Trial(i_list1),'Bouffee') && ~isempty(EMG.Trial(i_list1).Bouffee.Data)
            set(f1_axes1,'Nextplot','add')
            plot(f1_axes1,EMG.Trial(i_list1).Bouffee.Time,EMG.Trial(i_list1).Bouffee.Data(j_list2,:),'Color',[1 0 0]);
        end
        
        if isfield(EMG.Trial(i_list1),'TKEO') && get(findobj('Tag','TKEO'), 'Value')
            set(f1_axes2,'Nextplot','replace')
            plot(f1_axes2,EMG.Trial(i_list1).TKEO.temps,EMG.Trial(i_list1).TKEO.Data(j_list2,:))
            if isfield(EMG.Trial(i_list1),'Bouffee') && ~isempty(EMG.Trial(i_list1).Bouffee.Data)
                set(f1_axes2,'Nextplot','add')
                clear temp
                temp = EMG.Trial(i_list1).TKEO.Data(j_list2,:);
                temp(isnan(EMG.Trial(i_list1).Bouffee.Data(j_list2,:))) = NaN;
                plot(f1_axes2,EMG.Trial(i_list1).TKEO.temps,temp,'Color',[1 0 0]);
                clear temp
            end
        end
        if isfield(EMG.Trial(i_list1),'SampEn') && get(findobj('Tag','SampEn'), 'Value');
            set(f1_axes2,'Nextplot','replace')
            plot(f1_axes2,EMG.Trial(i_list1).SampEn.temps,EMG.Trial(i_list1).SampEn.Data(j_list2,:))
            if isfield(EMG.Trial(i_list1),'Bouffee') && ~isempty(EMG.Trial(i_list1).Bouffee.Data)
                set(f1_axes2,'Nextplot','add')
                clear temp
                temp = EMG.Trial(i_list1).SampEn.Data(j_list2,:);
                temp(isnan(EMG.Trial(i_list1).Bouffee.Data(j_list2,:))) = NaN;
                plot(f1_axes2,EMG.Trial(i_list1).SampEn.temps,temp,'Color',[1 0 0]);
                clear temp
            end
        end
        set(gcf,'Name',nom_fig)
        saveas(f1,[nom_fig '.tif']);
        close
    end
end

%% bouton radio pour choisir le critère calculé
% --- Executes on button press in TKEO.
function TKEO_Callback
% hObject    handle to TKEO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)
global EMG

% Hint: get(hObject,'Value') returns toggle state of TKEO
set(findobj('Tag','TKEO'), 'Value',1);
set(findobj('Tag','SampEn'), 'Value',0);
set(findobj('Tag','uipanel_TKEO'), 'Visible','On');
set(findobj('Tag','uipanel_SampEn'), 'Visible','Off');

try
    val1 = get(findobj('Tag','listbox1'),'Value');
catch
    val1 = 1;
    set(findobj('Tag','listbox1'),'Value',val1);
end
list1 = get(findobj('Tag','listbox1'),'String');

if strncmp(get(findobj('Tag','listbox1'), 'Visible'),'on',2) && isfield(EMG.Trial(val1),'TKEO') ;
    draw_emg
end

% --- Executes on button press in SampEn.
function SampEn_Callback
% hObject    handle to SampEn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)
global EMG

% Hint: get(hObject,'Value') returns toggle state of SampEn
set(findobj('Tag','TKEO'), 'Value',0);
set(findobj('Tag','SampEn'), 'Value',1);
set(findobj('Tag','uipanel_TKEO'), 'Visible','Off');
set(findobj('Tag','uipanel_SampEn'), 'Visible','On');

try
    val1 = get(findobj('Tag','listbox1'),'Value');
catch
    val1 = 1;
    set(findobj('Tag','listbox1'),'Value',val1);
end
list1 = get(findobj('Tag','listbox1'),'String');

if strncmp(get(findobj('Tag','listbox1'), 'Visible'),'on',2) && isfield(EMG.Trial(val1),'SampEn')
    draw_emg
end

%% calculer le critère choisi
% --- Executes on button press in calculer.
function  calculer_Callback();
% hObject    handle to calculer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)
global EMG list_EMG

files = arrayfun(@(i) EMG.Trial(i).RAW.TrialName, 1:length(EMG.Trial),'uni',0);
list_EMG = get(findobj('Tag','listbox2'),'String');
ind_TKEO = get(findobj('Tag','TKEO'),'Value');
ind_SampEn = get(findobj('Tag','SampEn'),'Value');

for i_fich = 1 : length(files)
    nom_acq = files{i_fich};
    Fech = EMG.Trial(i_fich).RAW.Fech;
    disp(['Traitement de : ' nom_acq ]);
    if ind_TKEO == 1
        EMG.Trial(i_fich).TKEO = EMG.Trial(i_fich).RAW.TKEOprocess;
    end
    if ind_SampEn == 1
        EMG.Trial(i_fich).SampEn = Signal;
    end
    for j_EMG = 1 : length(list_EMG)
        if ind_SampEn == 1
            disp('Calcul SampEn');
            % Nonlinear sample Entropy (Zhang2012)
            
            x = EMG.Trial(i_fich).RAW.Data(j_EMG,:);
            r=0.25*std(x(:));
            t=1;
            duree = str2double(get(findobj('Tag','duree_window'),'String'))/1000*Fech;
            increment = str2double(get(findobj('Tag','incr_window'),'String'))/1000*Fech;
            while (t-1)*increment+duree<length(x)
                window(t,:) = x((t-1)*increment+1:(t-1)*increment+duree);
                t=t+1;
            end
            for i_windo = 1 : size(window,1)
                SamEn(i_windo) = SampEn(2,r,window(i_windo,:));
            end
            EMG.Trial(i_fich).SampEn.Data(j_EMG,:) = SamEn;
        end
    end
    
    if ind_SampEn == 1
        EMG.Trial(i_fich).SampEn.Fech = Fech/(length(EMG.Trial(i_fich).RAW.Data(1,:))/length(EMG.Trial(i_fich).SampEn.Data(1,:)));
        EMG.Trial(i_fich).SampEn.Tag = list_EMG;
        EMG.Trial(i_fich).SampEn.Time = (1:length(EMG.Trial(i_fich).RAW.Data(1,:))/length(EMG.Trial(i_fich).SampEn.Data(1,:)):length(EMG.Trial(i_fich).RAW.Data(1,:)))/Fech;
        EMG.Trial(i_fich).SampEn.TrialName = upper(nom_acq);
        EMG.Trial(i_fich).SampEn.TrialNum = str2double(nom_acq(end-1:end));
        EMG.Trial(i_fich).SampEn.Description = 'Traitement par SampEn (Zhang et al 2012) sur le signal brut EMG';
        
    end
    disp('Fin')
end

draw_emg
set(findobj('Tag','uipanel_bouffees'), 'Visible','On');
set(findobj('Tag','bouffees'), 'Enable','On');

%% détection des bouffées
% --- Executes on button press in bouffees.
function bouffees();
% hObject    handle to bouffees (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)
global EMG list_EMG dossier

if get(findobj('Tag','acq_zero_emg'), 'Value')
    try
        acq_zero = btkReadAcquisition(fullfile(dossier,'zero_EMG.c3d'));
    catch
        try % si données CERESMARCHE, EMG_zero enregistré dans le .mat
            acq_zero = EMG.zero_EMG.RAW;
        catch
            [myFile_Zero, myPath_Zero] = uigetfile('*.c3d','emplacement de l''acq. zero_EMG');
            acq_zero = btkReadAcquisition(fullfile(myPath_Zero,myFile_Zero));
        end
    end
end

% on check les boutons num EMG et num trials pour savoir si on lance sur
% tous les essais ou si on fait des sous-cas

if get(findobj('Tag','Recalc_for_only_one_EMG'),'Value') == 0
    val2 = 1:4;
else
    val2 = get(findobj('Tag','listbox2'),'Value');
end

if get(findobj('Tag','Recalc_for_only_one_trial'),'Value') == 0
    files = arrayfun(@(i) EMG.Trial(i).RAW.TrialName, 1:length(EMG.Trial),'uni',0);
    val1 = 1:length(files);
else
    val1 = get(findobj('Tag','listbox1'),'Value');
    files = arrayfun(@(i) EMG.Trial(i).RAW.TrialName, 1:length(EMG.Trial),'uni',0);
end

for i_fich = val1
    nom_acq = files{i_fich};
    Fech = EMG.Trial(i_fich).RAW.Fech;
    disp(['Détection des bouffées pour : ' nom_acq ]);
    % On crée les objets EMG.Trial.Bouffee et EMG.Trial.Activite = RAW dans un premier temps
    % on crée pour tous les canaux EMG si 1ère fois, sinon, on passe cette étape
    try EMG.Trial(i_fich).Bouffee.Fech > 0;
    catch
    EMG.Trial(i_fich).Bouffee = Signal_EMG(EMG.Trial(i_fich).RAW.Data,EMG.Trial(i_fich).RAW.Fech,...
        'tag',list_EMG,...
        'units',repmat({'V'},1,length(list_EMG)),...
        'trialname',nom_acq,...
        'trialnum',str2double(nom_acq(end-1:end)),...
        'description','Bouffees d activite des EMGs');
    EMG.Trial(i_fich).Activite = Signal_EMG(EMG.Trial(i_fich).RAW.Data,EMG.Trial(i_fich).RAW.Fech,...
        'tag',list_EMG,...
        'units',repmat({'V'},1,length(list_EMG)),...
        'trialname',nom_acq,...
        'trialnum',str2double(nom_acq(end-1:end)),...
        'description','Activite des EMGs');
    set(findobj('Tag','Recalc_for_only_one_EMG'),'Visible','on');
    set(findobj('Tag','Recalc_for_only_one_trial'),'Visible','on');
    end
    
    for j_emg = val2
        if get(findobj('Tag','TKEO'), 'Value')
            
            clear temp duree_bruit seuil_TKEO temp periode ind
            if get(findobj('Tag','debut_bruit'), 'Value'); % si "Début acq" sélectionné
                duree_bruit = str2double(get(findobj('Tag','duree_bruit_ini'),'String'))*Fech;
                seuil_TKEO = str2double(get(findobj('Tag','seuil_TKEO'),'String')) * std(EMG.Trial(i_fich).TKEO.Data(j_emg,1:duree_bruit));
            elseif get(findobj('Tag','fenetre_bruit'), 'Value') % si "fenêtre manuelle" sélectionnée
                [~,b]=matchcells({nom_acq},get(findobj('Tag','listbox1'),'String')); % fait le lien entre le num d'essai et la position dans la liste
                set(findobj('Tag','listbox1'),'Value',find(b==1));
                [~,b]=matchcells(list_EMG(j_emg),get(findobj('Tag','listbox2'),'String'));
                set(findobj('Tag','listbox2'),'Value',find(b==1));
                draw_emg;
                P = ginput(2);
                P = floor(P*Fech);
                seuil_TKEO = str2double(get(findobj('Tag','seuil_TKEO'),'String')) * std(EMG.Trial(i_fich).TKEO.Data(j_emg,(P(1,1):P(2,1))));
            elseif get(findobj('Tag','acq_zero_emg'), 'Value') % si "Acq. zero_EMG" sélectionnée
                try % si données dispos à partir du c3d
                    EMG_zero = btkGetAnalog(acq_zero,list_EMG{j_emg});
                catch % si données dispos à partir du .mat (données CERESMARCHE)
                    eval(['EMG_zero = acq_zero.' list_EMG{j_emg} ';']);
                end
                clear a b r c temp temp2
                x = EMG_zero;
                [b,a] = butter(6,([30 300]/(Fech/2)),'bandpass');
                x(isnan(x))=0;
                temp =  filtfilt (b,a,x);
                temp2 = temp(2:end-1).^2 - temp(1:end-2).*temp(3:end);
                temp2 = abs(temp2);
                [b,a] = butter(6,(50/(Fech/2)),'low');
                x = temp2;
                x(isnan(x))=0;
                seuil_TKEO = str2double(get(findobj('Tag','seuil_TKEO'),'String')) * std(filtfilt (b,a,x));
            end
            
            % on remplace par NaN les données inf au seuil TKEO
            EMG.Trial(i_fich).Bouffee.Data(j_emg,:)=EMG.Trial(i_fich).RAW.Data(j_emg,:); % on reprend les valeurs initiales de RAW pour cette EMG : Sinon, identifié une fois comme NaN et non regénéré ensuite
            EMG.Trial(i_fich).Bouffee.Data(j_emg,EMG.Trial(i_fich).TKEO.Data(j_emg,:)<=seuil_TKEO)=NaN;
            
            % on prend en compte la durée minimale de bouffee : 1) Bouffee OFF ne peut pas être inf à la période 2) Bouffee ON ne peut pas être inf à la période
            periode = str2double(get(findobj('Tag','duree_bouffees'),'String'))/1000*Fech; % pour exprimer la periode en nb de frames
            ind_inf = isnan(EMG.Trial(i_fich).Bouffee.Data(j_emg,:)); % 1 si NaN
            k = 1;
            while ~isempty(k)
                deb = find(ind_inf(k:end)==1,1,'first');
                fin = find(ind_inf(k+deb-1:end)==0,1,'first');
                if fin < periode % 2000/1000*periode : Modif Angèle pcq sinon période *2 et je ne comprends pas pourquoi !
                    EMG.Trial(i_fich).Bouffee.Data(j_emg,k+deb-1:k+deb+fin-2)=EMG.Trial(i_fich).RAW.Data(j_emg,k+deb-1:k+deb+fin-2);
                end
                if isempty(deb) || isempty(fin)
                    k=[];
                else
                    k=k+deb+fin-1;
                end
                clear deb fin
            end
            
            ind_sup = ~isnan(EMG.Trial(i_fich).Bouffee.Data(j_emg,:));
            k = 1;
            while ~isempty(k)
                deb = find(ind_sup(k:end)==1,1,'first');
                fin = find(ind_sup(k+deb-1:end)==0,1,'first');
                if fin < periode % 2000/1000*periode
                    EMG.Trial(i_fich).Bouffee.Data(j_emg,k+deb-1:k+deb+fin-2)=NaN;
                end
                if isempty(deb) || isempty(fin)
                    k=[];
                else
                    k=k+deb+fin-1;
                end
                clear deb fin
            end
            
            EMG.Trial(i_fich).Activite.Data(j_emg,:) = ~isnan(EMG.Trial(i_fich).Bouffee.Data(j_emg,:));
            
            % on stocke l'info du seuil_TKEO comme la 1ère valeur de EMG.Trial(i_fich).TKEO
            EMG.Infos.seuilTKEO(j_emg) = seuil_TKEO;
        end
    end
end

preprocessing;

set(findobj('Tag','Calc_EMG_0toAPA'), 'Visible','On');
set(findobj('Tag','Calc_EMG_EXE'), 'Visible','On');
set(findobj('Tag','Disp_proc_data'),'Visible','on');
draw_emg


%% Calcul des EMG processed (rectifiés et filtrés)
% on calcule les EMG filtré/rectifié sur l'ensemble des voies et tout l'enregistrement
function preprocessing

global EMG

% on check les boutons num EMG et num trials pour savoir si on lance sur
% tous les essais ou si on fait des sous-cas

if get(findobj('Tag','Recalc_for_only_one_EMG'),'Value') == 0
    val2 = 1:4;
else
    val2 = get(findobj('Tag','listbox2'),'Value');
end

if get(findobj('Tag','Recalc_for_only_one_trial'),'Value') == 0
    files = arrayfun(@(i) EMG.Trial(i).RAW.TrialName, 1:length(EMG.Trial),'uni',0);
else
    val1 = get(findobj('Tag','listbox1'),'Value');
    files = arrayfun(@(i) EMG.Trial(i).RAW.TrialName, 1:length(EMG.Trial),'uni',0);
    files = files(val1);
end

for i_fich = 1 : length(files)
    clear temp_filt temp_lowpass temp_ok
    temp_filt = EMG.Trial(i_fich).RAW.BandPassFilter(30,300,6);
    temp_filt.Data = abs(temp_filt.Data);
    temp_lowpass = temp_filt.LowPassFilter(50,2);
    % on vérifie que Processed existe (doit avoir été exécuté au moins une fois sur l'ensb des canaux
    try EMG.Trial(i_fich).Processed.Fech > 0;
    catch
        EMG.Trial(i_fich).Processed = EMG.Trial(i_fich).Activite;
    end
    EMG.Trial(i_fich).Processed.Description = 'EMG proccessed : filtrés 30-300Hz / rectifiés et filtre bas 50Hz';
    for i_EMG = val2
        EMG.Trial(i_fich).Processed.Data(i_EMG,:) = temp_lowpass.Data(i_EMG,:).*EMG.Trial(i_fich).Activite.Data(i_EMG,:);
    end
    clear temp_filt temp_lowpass;
end

%% tri des bouffees
% --- Executes on button press in pushbutton8.
function tri_bouffees
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)
global EMG haxes1 haxes2
try
    val1 = get(findobj('Tag','listbox1'),'Value');
catch
    val1 = 1;
    set(findobj('Tag','listbox1'),'Value',val1);
end
list1 = get(findobj('Tag','listbox1'),'String');
nom_acq = list1(val1);

try
    val2 = get(findobj('Tag','listbox2'),'Value');
catch
    val2 = 1;
    set(findobj('Tag','listbox2'),'Value',val1);
end
list2 = get(findobj('Tag','listbox2'),'String');
nom_emg = list2(val2);
champs = fieldnames(EMG);
% t=0;
P=ones(2,2);
%while ~isempty(P)
P = ginput(2);
lim = get(haxes1,'XLim');
if size(P,1)==2
    if P(1,1)>P(2,1)
        P = flipud(P);
    end
    if P(1,1) < lim(2) && P(2,1) < lim(2) && P(1,1) > lim(1) && P(2,1) > lim(1) % on vérifie qu'on clique dans un des axes
        if get(findobj('Tag','tri_bouffees_off'),'Value')
            EMG.Trial(val1).Bouffee.Data(val2,floor(P(1,1)*EMG.Trial(val1).Bouffee.Fech):floor(P(2,1)*EMG.Trial(val1).Bouffee.Fech))=NaN;
            EMG.Trial(val1).Activite.Data(val2,:) = ~isnan(EMG.Trial(val1).Bouffee.Data(val2,:));
            preprocessing;
            draw_emg;
        elseif get(findobj('Tag','tri_bouffees_on'),'Value')
            EMG.Trial(val1).Bouffee.Data(val2,floor(P(1,1)*EMG.Trial(val1).Bouffee.Fech):floor(P(2,1)*EMG.Trial(val1).Bouffee.Fech))=EMG.Trial(val1).RAW.Data(val2,floor(P(1,1)*EMG.Trial(val1).Bouffee.Fech):floor(P(2,1)*EMG.Trial(val1).Bouffee.Fech));
            EMG.Trial(val1).Activite.Data(val2,:) = ~isnan(EMG.Trial(val1).Bouffee.Data(val2,:));
            preprocessing;
            draw_emg;
        end
    else
        try
            val1 = get(findobj('Tag','listbox1'),'Value');
        catch
            val1 = 1;
            set(findobj('Tag','listbox1'),'Value',val1);
        end
        list1 = get(findobj('Tag','listbox1'),'String');
        nom_acq = list1(val1);
        
        try
            val2 = get(findobj('Tag','listbox2'),'Value');
        catch
            val2 = 1;
            set(findobj('Tag','listbox2'),'Value',val1);
        end
        list2 = get(findobj('Tag','listbox2'),'String');
        nom_emg = list2(val2);
    end
elseif size(P,1)==1
    P=[];
end
%end

% --- Executes on button press in tri_bouffees_on.
function tri_bouffees_on_Callback(hObject, eventdata, handles)
% hObject    handle to tri_bouffees_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tri_bouffees_on
set(findobj('Tag','tri_bouffees_on'),'Value',1)
set(findobj('Tag','tri_bouffees_off'),'Value',0)


% --- Executes on button press in tri_bouffees_off.
function tri_bouffees_off_Callback(hObject, eventdata, handles)
% hObject    handle to tri_bouffees_off (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tri_bouffees_off
set(findobj('Tag','tri_bouffees_on'),'Value',0)
set(findobj('Tag','tri_bouffees_off'),'Value',1)


% --- Executes when selected object is changed in uipanel_bouffees.
function uipanel_bouffees_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_bouffees
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user Data (see GUIDATA)
if get(findobj('Tag','fenetre_bruit'), 'Value')
    set(findobj('Tag','debut_bruit'), 'Value',0);
    set(findobj('Tag','acq_zero_emg'), 'Value',0);
elseif get(findobj('Tag','debut_bruit'), 'Value');
    set(findobj('Tag','fenetre_bruit'), 'Value',0)
    set(findobj('Tag','acq_zero_emg'), 'Value',0);
elseif get(findobj('Tag','acq_zero_emg'), 'Value');
    set(findobj('Tag','fenetre_bruit'), 'Value',0)
    set(findobj('Tag','debut_bruit'), 'Value',0);
end

% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
charger_mat_batch;
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function charger_mat_batch(varargin)
global EMG
if isempty(varargin)
    %Choix manuel des fichiers
    [files1 dossier] = uigetfile('*org.mat','Choix du/des fichier(s) mat ','Multiselect','on');
else
    files1 = varargin{1};
    dossier = varargin{2};
end

for i=1:length(files1);
    file_curr = files1{i};
    
    load(fullfile(dossier,file_curr));
    eval(['EMG = '  file_curr(1:end-4) ';']);
    if ~isfield(EMG,'Infos') || isempty(EMG.Infos.FileName)
        Tag_items = {'Protocole','Session','Code_Sujet','Traitement','Vitesse'};
        
        % on récupère le nom du protocole
        prot = strfind(file_curr,'_');
        Protocole = file_curr(1:prot-1);
        
        if ~isempty(strfind(fullfile(dossier,file),'Preop'))
            Session = 'Preop';
        elseif ~isempty(strfind(fullfile(dossier,file),'LFP'))
            Session = 'LFP';
        elseif ~isempty(strfind(fullfile(dossier,file),'M3Stim1'))
            Session = 'M3Stim1';
        elseif ~isempty(strfind(fullfile(dossier,file),'M3Stim2'))
            Session = 'M3Stim2';
        end
        
        if ~isempty(strfind(fullfile(dossier,file),'OFF'))
            traitement = 'OFF';
        elseif ~isempty(strfind(fullfile(dossier,file),'ON'))
            traitement = 'ON';
        else
            traitement = '';
        end
        
        if ~isempty(strfind(fullfile(dossier,file),'MN')) || ~isempty(strfind(fullfile(dossier,file),'S'))
            vitesse = 'S';
        elseif ~isempty(strfind(fullfile(dossier,file),'MR')) || ~isempty(strfind(fullfile(dossier,file),'R'))
            vitesse = 'R';
        elseif ~isempty(strfind(fullfile(dossier,files{1}),'AI'))
            vitesse = 'AI';
        else
            vitesse = '';
        end
        
        % on récupère tag sujet : ok si nomenclature : PROTOCOLE_SESSION_SUJET_  % Ajout Angèle
        idx = (strfind(files{1},'_'));
        try
            Tag_sujet = files{1}(idx(2)+1:idx(3)-1);
        catch
            Tag_sujet = 'XXXXx00';
        end
        
        items = {Protocole,Session,Tag_sujet,traitement,vitesse};
        %     items = inputdlg(Tag_items,'Infos',1,items);
        
        nom_fich = upper([items{1} '_' items{2} '_' items{3} '_' items{4} '_' items{5}]);
    else
        nom_fich = EMG.Infos.FileName;
    end
    
    set(findobj('Tag','nom_sujet'),'String',['Sujet : ' nom_fich])
    
    % Mise à jour de la liste des acquisitions
    set(findobj('Tag','text1'), 'Visible','On');
    set(findobj('Tag','listbox1'), 'Visible','On');
    set(findobj('Tag','listbox1'), 'Value',1);
    files = arrayfun(@(i) EMG.Trial(i).RAW.TrialName, 1:length(EMG.Trial),'uni',0);
    set(findobj('Tag','listbox1'),'String',files);
    
    champ = fieldnames(EMG);
    list_EMG = EMG.Trial(1).RAW.Tag;
    set(findobj('Tag','text2'), 'Visible','On');
    set(findobj('Tag','listbox2'), 'Visible','On');
    set(findobj('Tag','listbox2'), 'Value',1);
    set(findobj('Tag','listbox2'),'String',list_EMG);
    
    %Activation des axes
    axess = findobj('Type','axes');
    for i=1:length(axess)
        set(axess(i),'Visible','On');
    end
    
    draw_emg; % Visu des tracés
    
    % Exécution de Calculer - Bouffées - Sauvegarder - Clear
    
    calculer_Callback;
    bouffees;
    
    % sauvegarde
    nom_fich_EMG = upper([nom_fich '_YF_EMG']);
    warning('modif temporaire : save file avec ''YF'' ');
    eval([nom_fich_EMG ' = EMG;']);
    
    eval(['save(fullfile(dossier,[nom_fich_EMG ''.mat'']),''' nom_fich_EMG ''');']);
    eval(['clear ''' nom_fich_EMG '''']);
    set(findobj('Tag','nom_sujet'),'String',['Sujet : ' nom_fich ])
    
    % On efface les dernières données
    clear_Callback;
    
    
    %     set(findobj('Tag','save'), 'Enable','On');
    %     if isfield(EMG.Trial(1),'RAW')
    %         set(findobj('Tag','calculer'), 'Enable','On');
    %     end
    %     if isfield(EMG.Trial(1),'SampEn')
    %         set(findobj('Tag','bouffees'), 'Enable','On');
    %         SampEn_Callback;
    %     end
    %     if isfield(EMG.Trial(1),'TKEO')
    %         set(findobj('Tag','bouffees'), 'Enable','On');
    %         TKEO_Callback;
    %     end
end

% --- Executes on button press in Calc_EMG_0toAPA.
function Calc_EMG_0toAPA_Callback(hObject, eventdata, handles)
global EMG
disp('Calcul des var');
Fs = EMG.Trial(1).RAW.Fech;

switch strcmp([EMG.Trial(1).RAW.Tag{:}],'RTARSOLLTALSOL')
    case 0
        error('Ordre des tags EMG ne correspond pas à RTA/RSOL/LTA/SOL');
end

for i_trial = 1:numel(EMG.Trial)
    
    clear timing_evts_frame
    timing_evts_frame = floor(Fs*EMG.Trial(i_trial).Ev{1}); % pour travailler en frames et non en s
    
    switch EMG.Trial(i_trial).Ev{2}{3}
        case 'L_FO'
            EMGorder = [4 3 2 1];
        case 'R_FO'
            EMGorder = [2 1 4 3];
    end
    
    % si on ne prend que certaines variables
    % NB EMGorder(i_EMG) : ordre d'enrg des EMG dans EMG / i_EMG : EMG dans l'ordre SOLswing TAswing SOLstance TAstance
    % Avant T0 : RMS pour les 4 muscles
    for i_EMG = 1:4
        EMG.Trial(i_trial).ExploitVar2.beforeT0.RMS(i_EMG) =  rms(EMG.Trial(i_trial).Processed.Data(EMGorder(i_EMG),1:timing_evts_frame(1)));
    end
    % Pendant APA
    for i_EMG = 1:4
        EMG.Trial(i_trial).ExploitVar2.APA.RMS(i_EMG) =  rms(EMG.Trial(i_trial).Processed.Data(EMGorder(i_EMG),timing_evts_frame(1):timing_evts_frame(3)));
    end
    
    % Calcul de TA1_BF_FO1 : TA Swing pendant APA : instant start avant FO1
    i_EMG = 2; % TA Swing
    disp('TA Swing processing...');
    EOI = [1,timing_evts_frame(3)]; % période temporelle d'intérêt : entre 0 et FO1
    data_curr = EMG.Trial(i_trial).Activite.Data(EMGorder(i_EMG),EOI(1):EOI(2)); % on ne prend que la partie de t=0 à FO1;
    EMG.Trial(i_trial).ExploitVar2.TA1_BF_FO1 = find_start_burst_before_event_APA(data_curr,EOI,Fs);
    clear data_curr EOI;
    
    % Calcul de TA2_BF_FO1_start et TA2_BF_FO1_stop : TA stance pendant APA : instant start et stop avant FO1
    i_EMG = 4;
    disp('TA Stance processing...');
    EOI = [1,timing_evts_frame(3)]; % période temporelle d'intérêt : entre 0 et FO1
    data_curr = EMG.Trial(i_trial).Activite.Data(EMGorder(i_EMG),EOI(1):EOI(2)); % on ne prend que la partie de t=0 à FO1;
    EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_start = find_start_burst_before_event_APA(data_curr,EOI,Fs);
    EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_stop = find_stop_burst_before_event(data_curr,EOI,Fs);
        
    % on considère le cas où tStart postérieur à tstop pcq 2 bouffées différentes identifiées
    if EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_start < EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_stop
        % on vérifie que le temps d'activation de la 2ème bouffée est inférieur au temps de pause entre les 2 bouffées
        if EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_start < (EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_stop-EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_start)
            data_curr(EOI(2)-round(EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_start*Fs):end) = 0; clear EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_start;
            EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_start = find_start_burst_before_event_APA(data_curr,EOI,Fs);
        else
            warning('TA Stance BF FO1 : Situation non rencontrée jusqu''à mtn : TO DO');
        end
    end
         
    try
        EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_RMS = rms(EMG.Trial(i_trial).Processed.Data(EMGorder(i_EMG),EOI(2)-round(EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_start*Fs):EOI(2)-round(EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_stop*Fs)));
    catch
        if ~isnan(EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_start) && isnan(EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_stop) % si on a bien un début, mais pas de fin, car tjs actif à FO1, on calcule quand même la rms
        EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_RMS = rms(EMG.Trial(i_trial).Processed.Data(EMGorder(i_EMG),EOI(2)-round(EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_start*Fs):EOI(2)));
        else
        EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_RMS = NaN;
        end
    end
    clear data_curr EOI;
    disp(['Calc 0 to APA OK for Trial ' num2str(EMG.Trial(i_trial).RAW.TrialNum)]);
end

% tracé du début d'activation pour TA Swing
figure, hold on,
for i_trial = 1:numel(EMG.Trial)
    plot(EMG.Trial(i_trial).RAW.TrialNum,EMG.Trial(i_trial).ExploitVar2.TA1_BF_FO1,'g*');
    axis([-Inf Inf 0 Inf]);
    xlabel('Trial Num'); ylabel('Time (s)');
end
title('Activation TA Swing before FO1');
% tracés du début et de la fin d'activation pour TA Stance
figure, hold on,
subplot(1,2,1), hold on,
for i_trial = 1:numel(EMG.Trial)
    pl(1) = plot(EMG.Trial(i_trial).RAW.TrialNum,EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_start,'g*');
    pl(2) = plot(EMG.Trial(i_trial).RAW.TrialNum,EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_stop,'r*');
end
axis([-Inf Inf 0 Inf]);
legend(pl,'start','stop'); xlabel('Trial Num'); ylabel('Time (s)');
title('Activation TA Stance before FO1');
subplot(1,2,2), hold on,
for i_trial = 1:numel(EMG.Trial)
    plot(EMG.Trial(i_trial).RAW.TrialNum,EMG.Trial(i_trial).ExploitVar2.TA2_BF_FO1_RMS,'b*');
end
axis([-Inf Inf 0 Inf]); xlabel('Trial Num'); ylabel('RMS');
title('RMS TA Stance before FO1');

%---------------------------------------------
% --- Executes on button press in Calc_EMG_EXE
%---------------------------------------------
function Calc_EMG_EXE_Callback(hObject, eventdata, handles)
global EMG
disp('Calcul des var');
Fs = EMG.Trial(1).RAW.Fech;

switch strcmp([EMG.Trial(1).RAW.Tag{:}],'RTARSOLLTALSOL')
    case 0
        error('Ordre des tags EMG ne correspond pas à RTA/RSOL/LTA/SOL');
end

for i_trial = 1:numel(EMG.Trial)
    clear timing_evts_frame
    timing_evts_frame = floor(Fs*EMG.Trial(i_trial).Ev{1}); % pour travailler en frames et non en s
    
    switch EMG.Trial(i_trial).Ev{2}{3}
        case 'L_FO'
            EMGorder = [4 3 2 1];
        case 'R_FO'
            EMGorder = [2 1 4 3];
    end
    
    % Calcul de SOL2_BF_FC1 : SOL stance avant FC1 : début de bouffée
    i_EMG = 3; % SOL Stance
    disp('SOL Stance before FC1 processing...');
    EOI = [timing_evts_frame(1),timing_evts_frame(4)]; % période temporelle d'intérêt : entre T0 et FC1
    data_curr = EMG.Trial(i_trial).Activite.Data(EMGorder(i_EMG),EOI(1):EOI(2)); % on ne prend que la partie de t=0 à FC1;
    EMG.Trial(i_trial).ExploitVar2.SOL2_BF_FC1 = find_start_burst_before_event_EXE(data_curr,EOI,Fs);
    clear data_curr EOI;
    
    % Calcul de SOL2_AF_FC1 : SOL stance après FC1 : fin de bouffée
    i_EMG = 3; % SOL Stance
    disp('SOL Stance after FC1 processing...');
    EOI = [timing_evts_frame(4),timing_evts_frame(6)]; % période temporelle d'intérêt : entre 0 et FO1
    data_curr = EMG.Trial(i_trial).Activite.Data(EMGorder(i_EMG),EOI(1):EOI(2)); % on ne prend que la partie de FC1 à FC2;
    EMG.Trial(i_trial).ExploitVar2.SOL2_AF_FC1 = find_stop_burst_after_event(data_curr,Fs);
    clear data_curr EOI;
    
    % calcul de la RMS de cette bouffée autour de FC1
    i_EMG = 3;
    EOI = [1,timing_evts_frame(6),timing_evts_frame(4)]; % période temporelle d'intérêt : entre 0 et FC2 / et on ajoute le FO1
    if ~isnan(EMG.Trial(i_trial).ExploitVar2.SOL2_BF_FC1) && ~isnan(EMG.Trial(i_trial).ExploitVar2.SOL2_AF_FC1)
        EMG.Trial(i_trial).ExploitVar2.SOL2_FC1_RMS = rms(EMG.Trial(i_trial).Processed.Data(EMGorder(i_EMG),EOI(3)-round(EMG.Trial(i_trial).ExploitVar2.SOL2_BF_FC1*Fs):EOI(3)+round(EMG.Trial(i_trial).ExploitVar2.SOL2_AF_FC1*Fs)));
    else
        EMG.Trial(i_trial).ExploitVar2.SOL2_FC1_RMS = NaN;
    end
    clear data_curr EOI;
    
    % Calcul de SOL1_AF_FC1 : SOL Swing après FC1 : début de bouffée
    i_EMG = 1; % SOL Swing
    disp('SOL Swing after FC1 processing...');
    EOI = [timing_evts_frame(4),timing_evts_frame(6)]; % période temporelle d'intérêt : entre FC1 et FC2
    data_curr = EMG.Trial(i_trial).Activite.Data(EMGorder(i_EMG),EOI(1):EOI(2)); % on ne prend que la partie de FC1 à FC2;
    EMG.Trial(i_trial).ExploitVar2.SOL1_AF_FC1 = find_start_burst_after_event(data_curr,Fs);
    clear data_curr EOI;
    
    disp(['Calc EXE OK for Trial ' num2str(EMG.Trial(i_trial).RAW.TrialNum)]);
end

figure, hold on,
subplot(1,2,1), hold on,
for i_trial = 1:numel(EMG.Trial)
    pl(1) = plot(EMG.Trial(i_trial).RAW.TrialNum,-EMG.Trial(i_trial).ExploitVar2.SOL2_BF_FC1,'g*');
    pl(2) = plot(EMG.Trial(i_trial).RAW.TrialNum,EMG.Trial(i_trial).ExploitVar2.SOL2_AF_FC1,'r*');
end
legend(pl,'start','stop');
title('Activation SOL Stance around FC1'); xlabel('Trial Num'); ylabel('Time (s)');
subplot(1,2,2), hold on,
for i_trial = 1:numel(EMG.Trial)
    plot(EMG.Trial(i_trial).RAW.TrialNum,EMG.Trial(i_trial).ExploitVar2.SOL2_FC1_RMS,'b*');
    axis([-Inf Inf 0 Inf]); xlabel('Trial Num'); ylabel('RMS');
end
title('RMS SOL Stance around FC1');

figure, hold on,
for i_trial = 1:numel(EMG.Trial)
    plot(EMG.Trial(i_trial).RAW.TrialNum,EMG.Trial(i_trial).ExploitVar2.SOL1_AF_FC1,'g*');
    axis([-Inf Inf 0 Inf]); xlabel('Trial Num'); ylabel('Time (s)');
end
title('Activation SOL Swing after FC1');

% --- Executes on button press in Disp_proc_data.
% fonction disponible uniquement si les bouffées ont été calculées
function Disp_proc_data_Callback(hObject, eventdata, handles)
draw_emg;

% -----------------------------------------------------------------------------------------------
% --- Fonctions de détections de début et fin de bouffée (utilisée dans Calc_EMG)
% -----------------------------------------------------------------------------------------------
% fonction pour calculer le début de la boufée avant un event (ex : TA swing before FO1)
function idx = find_start_burst_before_event_APA(data_curr,EOI,Fs) % data_curr : 1 voie EMG sur la durée EOI, Fs
% si aucune bouffée sur la période temporelle -> NaN
if nnz(data_curr) == 0
    idx = NaN;
else
    switch data_curr(end)
        case 1 % muscle activé à la dernière frame
            chgt_signe = data_curr(1:end-1)-data_curr(2:end);
            if nnz(chgt_signe == -1) == 1 % une seule bouffée au total
                idx_temp = find(chgt_signe,1,'last')+1; % en frames, par rapport au début de l'enregistrement
                idx = (EOI(2)-EOI(1) - idx_temp)/Fs;
            elseif nnz(chgt_signe == -1) > 1 % plus d'une bouffée au total
                % on distingue la situation de si muscle activé au début de la période temporelle ou non
                if data_curr(1) == 0
                    chgt_signe = chgt_signe*-1;
                end
                    idx_temp = find(chgt_signe,1,'last')+1; % début de la bouffée juste avant EOI(2) / en frames, par rapport au début de l'enregistrement
                % si autre bouffée plus courte que celle d'intérêt, on ne la considère pas :
                if nnz(data_curr(1:idx_temp-1) == 1) < EOI(2)-EOI(1) - idx_temp
                    idx = (EOI(2)-EOI(1) - idx_temp)/Fs;
                    % si pas d'activité EMG sur un temps plus long que la bouffée d'intéret, on ignore les autres bouffées (celles antérieures) :
                elseif  (find(chgt_signe==-1,1,'last') - find(chgt_signe==1,1,'last')) > (EOI(2)-EOI(1) - idx_temp)  % correspond à la durée du signal égale à 0
                    idx = (EOI(2)-EOI(1) - idx_temp)/Fs;
                    % si bouffée précédente plus longue que celle d''intéret et temps d'arrêt trop court
                    % on garde la bouffée précédente et on considère ce début comme début de bouffée
                elseif ((find(chgt_signe==1,1,'last') - (find(chgt_signe(1:idx_temp-2)==-1,1,'last'))) > (EOI(2)-EOI(1) - idx_temp)) && ((idx_temp-find(chgt_signe==1,1,'last')) < (EOI(2)-EOI(1) - idx_temp))
                    idx = (EOI(2)-EOI(1) - find(chgt_signe(1:idx_temp-2),1,'first'))/Fs;
                else
                    warning(['SOL2 BF FC1 ou TA start BF FO1 : Situation non rencontrée jusqu''à mtn : TO DO']);
                    idx = NaN;
                end
            else
                disp(['Trial ' num2str(i_trial) 'nnz(chgt_signe == -1) ~= 1 : TO DO']);
                idx = NaN;
            end
        case 0 % muscle non activé à la dernière frame
            if nnz(data_curr) == 0  % 1ere option : aucune activation du muscle avant EO2
                idx = NaN; % timing -> NaN
            else
                % si activation après T0 et bouffée s'arrête juste avant FO1 : on la considère quand même
                chgt_signe = data_curr(1:end-1)-data_curr(2:end);
                idx_temp = find(chgt_signe==-1,1,'last')+1; % début de la bouffée précédente
                if (nnz(chgt_signe == -1) == 1)
                    idx = (EOI(2) - idx_temp)/Fs;
                elseif (nnz(chgt_signe == -1) == 2) && (nnz(chgt_signe == 1) == 2) % 2 bouffées qui s'allument et s'éteignent entre EOI(1) et EOI(2)
                    % on vérifie que la 1ère bouffée est plus courte que la 2ème et on retient le début de la 2ème bouffée
                    if (find(chgt_signe==1,1,'first') - find(chgt_signe==-1,1,'first')) < (find(chgt_signe==1,1,'last') - find(chgt_signe==-1,1,'last'))
                        idx = (EOI(2) - idx_temp)/Fs;
                    % autre possibilité : on vérifie que la pause entre les 2 bouffées est plus longue que la 2ème bouffée : 1ère bouffée est plus courte que la 2ème et on retient le début de la 2ème bouffée
                    elseif  (find(chgt_signe==1,1,'last') - find(chgt_signe==-1,1,'last')) < (find(chgt_signe==-1,1,'last') - find(chgt_signe==1,1,'first'))
                        idx = (EOI(2) - idx_temp)/Fs;
                    else
                        warning(['SOL2 BF FC1 ou TA start BF FO1 : Situation non rencontrée jusqu''à mtn no: TO DO']);
                        idx = NaN;
                    end
                else
                    warning(['SOL2 BF FC1 ou TA start BF FO1 : Situation non rencontrée jusqu''à mtn no: TO DO']);
                    idx = NaN;
                end
            end
    end
end

% -----------------------------------------------------------------------------------------------
% --- Fonctions de détections de début et fin de bouffée (utilisée dans Calc_EMG)
% -----------------------------------------------------------------------------------------------
% fonction pour calculer le début de la boufée avant un event (ex : TA swing before FO1)
function idx = find_start_burst_before_event_EXE(data_curr,EOI,Fs) % data_curr : 1 voie EMG sur la durée EOI, Fs
% si aucune bouffée sur la période temporelle -> NaN
if nnz(data_curr) == 0
    idx = NaN;
else
    switch data_curr(end)
        case 1 % muscle activé à la dernière frame
            chgt_signe = data_curr(1:end-1)-data_curr(2:end);
            if nnz(chgt_signe == -1) == 1 % une seule bouffée au total
                idx_temp = find(chgt_signe,1,'last')+1; % en frames, par rapport au début de l'enregistrement
                idx = (EOI(2)-EOI(1) - idx_temp)/Fs;
            elseif nnz(chgt_signe == -1) > 1 % plus d'une bouffée au total
                % on distingue la situation de si muscle activé au début de la période temporelle ou non
                if data_curr(1) == 0
                    chgt_signe = chgt_signe*-1;
                end

                    idx_temp = find(chgt_signe,1,'last')+1; % début de la bouffée juste avant EOI(2) / en frames, par rapport au début de l'enregistrement

                % si autre bouffée plus courte que celle d'intérêt, on ne la considère pas :
                if nnz(data_curr(1:idx_temp-1) == 1) < EOI(2)-EOI(1) - idx_temp
                    idx = (EOI(2)-EOI(1) - idx_temp)/Fs;
                    % si pas d'activité EMG sur un temps plus long que la bouffée d'intéret, on ignore les autres bouffées (celles antérieures) :
                elseif  (find(chgt_signe==-1,1,'last') - find(chgt_signe==1,1,'last')) > (EOI(2)-EOI(1) - idx_temp)  % correspond à la durée du signal égale à 0
                    idx = (EOI(2)-EOI(1) - idx_temp)/Fs;
                    % si bouffée précédente plus longue que celle d''intéret et temps d'arrêt trop court
                    % on garde la bouffée précédente et on considère ce début comme début de bouffée
                elseif ((find(chgt_signe==1,1,'last') - (find(chgt_signe(1:idx_temp-2)==-1,1,'last'))) > (EOI(2)-EOI(1) - idx_temp)) && ((idx_temp-find(chgt_signe==1,1,'last')) < (EOI(2)-EOI(1) - idx_temp))
                    idx = (EOI(2)-EOI(1) - find(chgt_signe(1:idx_temp-2)==-1,1,'last'))/Fs;
                else
                    warning(['SOL2 BF FC1 ou TA start BF FO1 : Situation non rencontrée jusqu''à mtn : TO DO']);
                    idx = NaN;
                end
            else
                warning('nnz(chgt_signe == -1) ~= 1 : TO DO');
                idx = NaN;
            end
        case 0 % muscle non activé à la dernière frame
            if nnz(data_curr) == 0  % 1ere option : aucune activation du muscle avant EO2
                idx = NaN; % timing -> NaN
            else
                % si activation après T0 et bouffée s'arrête juste avant FO1 : on la considère quand même
                chgt_signe = data_curr(1:end-1)-data_curr(2:end);
                idx_temp = find(chgt_signe==-1,1,'last')+1; % début de la bouffée précédente
                if (nnz(chgt_signe == -1) == 1)
                    idx = (EOI(2)-EOI(1) - idx_temp)/Fs;
                elseif (nnz(chgt_signe == -1) == 2) && (nnz(chgt_signe == 1) == 2) % 2 bouffées qui s'allument et s'éteignent entre EOI(1) et EOI(2)
                    % on vérifie que la 1ère bouffée est plus courte que la 2ème et on retient le début de la 2ème bouffée
                    if (find(chgt_signe==1,1,'first') - find(chgt_signe==-1,1,'first')) < (find(chgt_signe==1,1,'last') - find(chgt_signe==-1,1,'last'))
                        idx = (EOI(2)-EOI(1) - idx_temp)/Fs;
                    % autre possibilité : on vérifie que la pause entre les 2 bouffées est plus longue que la 2ème bouffée : 1ère bouffée est plus courte que la 2ème et on retient le début de la 2ème bouffée
                    elseif  (find(chgt_signe==1,1,'last') - find(chgt_signe==-1,1,'last')) < (find(chgt_signe==-1,1,'last') - find(chgt_signe==1,1,'first'))
                        idx = (EOI(2)-EOI(1) - idx_temp)/Fs;
                    else
                        warning(['SOL2 BF FC1 ou TA start BF FO1 : Situation non rencontrée jusqu''à mtn no: TO DO']);
                        idx = NaN;
                    end
                else
                    warning(['SOL2 BF FC1 ou TA start BF FO1 : Situation non rencontrée jusqu''à mtn no: TO DO']);
                    idx = NaN;
                end
            end
    end
end


% fonction pour calculer la fin de la boufée avant un event (ex : TA stance before FO1)
function idx = find_stop_burst_before_event(data_curr,EOI,Fs) % data_curr : 1 voie EMG sur la durée EOI, Fs

% si aucune bouffée sur la période temporelle -> NaN
if nnz(data_curr) == 0
    idx = NaN;
else
    chgt_signe = data_curr(1:end-1)-data_curr(2:end);
    idx_temp = find(chgt_signe==1,1,'last')+1; % en frames, par rapport au début de l'enregistrement
    if nnz(chgt_signe == 1) == 1 % une seule bouffée qui s'éteint
        idx = (EOI(2) - idx_temp)/Fs;
        clear idx_temp;
    elseif (nnz(chgt_signe == -1) == 2) && (nnz(chgt_signe == 1) == 2) % 2 bouffées qui s'allument et s'éteignent entre EOI(1) et EOI(2)
        % on vérifie que la 1ère bouffée est plus courte que la 2ème et on retient le début de la 2ème bouffée
        if (find(chgt_signe==1,1,'first') - find(chgt_signe==-1,1,'first')) < (find(chgt_signe==1,1,'last') - find(chgt_signe==-1,1,'last'))
            idx = (EOI(2) - idx_temp)/Fs;
        elseif  (find(chgt_signe==1,1,'last') - find(chgt_signe==-1,1,'last')) < (find(chgt_signe==-1,1,'last') - find(chgt_signe==1,1,'first'))
                        idx = (EOI(2) - idx_temp)/Fs;
        else
            warning('Situation non rencontrée jusqu''à mtn no: TO DO');
            idx = NaN;
        end
    elseif  nnz(chgt_signe == -1) == 1 && nnz(chgt_signe == 1) == 0 % une seule bouffée qui s'allume mais ne s'éteint pas avant EO2
        idx = NaN;
    else
        warning('Situation non rencontrée jusqu''à mtn no: TO DO');
        idx = NaN;
    end
end
    
% fonction pour calculer la fin de la boufée après un event (utilisé uniquement pour SOL stance after FC1)
function idx = find_stop_burst_after_event(data_curr,Fs) % data_curr : 1 voie EMG sur la durée EOI, Fs

% si aucune bouffée sur la période temporelle -> NaN
if nnz(data_curr) == 0
    idx = NaN;
elseif data_curr(1) == 1 % on s'assure que le muscle est activé à l'évènement d'intérêt
    chgt_signe = data_curr(1:end-1)-data_curr(2:end);
    if nnz(chgt_signe == 1) == 1 % une seule bouffée qui s'éteint
        idx_temp = find(chgt_signe==1,1,'first')+1;
        idx = idx_temp/Fs;
    elseif nnz(chgt_signe == -1) == 1 % une bouffée qui s'éteint et une autre qui se rallume -> on vérifie que le temps de pause entre les 2 est grand
        time_off = find(chgt_signe==-1,1,'first') - find(chgt_signe==1,1,'first'); % temps de off entre les 2
        if time_off > find(chgt_signe==1,1,'first')
            idx_temp = find(chgt_signe==1,1,'first')+1;
            idx = idx_temp/Fs;
        else
            warning('SOL stance AF FC1 : Non traité jusqu''à mtn : TO DO');
        end
    elseif nnz(chgt_signe == -1) == 2 && data_curr(end) == 1 % une bouffée qui s'éteint et une autre qui se rallume puis s'éteint et une troisième qui est tjs active à la dernière image -> on vérifie que le temps de pause entre les 2 première bouffée est supérieure à la longueur de la 2ème bouffée
        time_off = find(chgt_signe==-1,1,'first') - find(chgt_signe==1,1,'first'); % temps de off entre les 2
        time_2nd_burst = find(chgt_signe==1,1,'last') - find(chgt_signe==-1,1,'first');
        if time_off > time_2nd_burst
            idx_temp = find(chgt_signe==1,1,'first')+1;
            idx = idx_temp/Fs;
        else
            warning('SOL stance AF FC1 : Non traité jusqu''à mtn : TO DO');
        end
    else
        warning('SOL stance AF FC1 : TO DO');
        
    end
else
    warning('TO DO');
end

% % fonction pour calculer le début de la bouffée après un event (ex : SOL swing after FC1)
function idx = find_start_burst_after_event(data_curr,Fs) % data_curr : 1 voie EMG sur la durée EOI, Fs

% si aucune bouffée sur la période temporelle -> NaN
if nnz(data_curr) == 0
    idx = NaN;
elseif nnz(data_curr~=1) == 0 % activité reste à 1 sur toute la durée
    idx = NaN;
    warning('SOL Swing after FC1 : pas de début de bouffée car tjs en ON');
else
    chgt_signe = data_curr(1:end-1)-data_curr(2:end);
    switch data_curr(1)
        case 0 % si muscle non actif au début, on prend le début de la bouffée suivante
            
            if nnz(chgt_signe == -1) == 1 % une seule bouffée au total
                idx = find(chgt_signe,1,'first') / Fs;
            elseif nnz(chgt_signe == -1) == 2 % 2 bouffées 
                if (find(chgt_signe,1,'last') - find(chgt_signe,1,'first')) > (find(chgt_signe==1,1,'first') - find(chgt_signe,1,'first')) % si temps d'arrêt supérieur à durée de la bouffée initiale : on considère ce début de bouffée
                    idx = find(chgt_signe,1,'first') / Fs;
                else
                warning(' Situation non rencontrée jusqu''à mtn : TO DO');
                idx = NaN;
                end
            else
                   warning(' Situation non rencontrée jusqu''à mtn : TO DO');
                idx = NaN;
            end
            %     case 0
            %         % 1ere option : aucune activation du muscle avant EO2
            %         if nnz(data_curr) == 0
            %             idx = NaN; % timing -> NaN
            %         else
            %             % si activation après T0 et bouffée s'arrête juste avant FO1 : on la considère quand même
            %             chgt_signe = data_curr(1:end-1)-data_curr(2:end);
            %             idx_temp = find(chgt_signe==-1,1,'last')+1; % début de la boufée précédente
            %             if (nnz(chgt_signe == -1) == 1)
            %                 idx = (EOI(2) - idx_temp)/Fs;
            %             else
            %                 warning(['Situation non rencontrée jusqu''à mtn no: TO DO']);
            %                 idx = NaN;
            %             end
            %         end
        case 1    % si muscle actif au début, on attend que la bouffée s'éteigne, puis on prend le début de la bouffée suivante
            if nnz(chgt_signe == -1) == 1 % si on a une seule bouffée qui se rallume
                idx = find(chgt_signe==-1,1,'first') / Fs;
            else
                warning('SOL Swing after FC1 : Situation non rencontrée jusqu''à mtn : TO DO');
            end
    end
end


%% fonctions annexes


%% Calcul de SampEn
function saen = SampEn( dim, r, Data, tau )
% SAMPEN Sample Entropy
%   calculates the sample entropy of a given Time series Data

%   SampEn is conceptually similar to approximate entropy (ApEn), but has
%   following differences:
%       1) SampEn does not count self-matching. The possible trouble of
%       having log(0) is avoided by taking logarithm at the latest step.
%       2) SampEn does not depend on the Datasize as much as ApEn does. The
%       comparison is shown in the graph that is uploaded.

%   dim     : embedded dimension
%   r       : tolerance (typically 0.2 * std)
%   Data    : Time-series Data
%   tau     : delay Time for downsampling (user can omit this, in which case
%             the default value is 1)
%
%---------------------------------------------------------------------
% coded by Kijoon Lee,  kjlee@ntu.edu.sg
% Mar 21, 2012
%---------------------------------------------------------------------

if nargin < 4, tau = 1; end
if tau > 1, Data = downsample(Data, tau); end

N = length(Data);
correl = zeros(1,2);
DataMat = zeros(dim+1,N-dim);
for i = 1:dim+1
    DataMat(i,:) = Data(i:N-dim+i-1);
end

for m = dim:dim+1
    count = zeros(1,N-dim);
    tempMat = DataMat(1:m,:);
    
    for i = 1:N-m
        % calculate Chebyshev distance, excluding self-matching case
        dist = max(abs(tempMat(:,i+1:N-dim) - repmat(tempMat(:,i),1,N-dim-i)));
        
        % calculate Heaviside function of the distance
        % User can change it to any other function
        % for modified sample entropy (mSampEn) calculation
        D = (dist < r);
        
        count(i) = sum(D)/(N-dim);
    end
    
    correl(m-dim+1) = sum(count)/(N-dim);
end

saen = log(correl(1)/correl(2));


%% fonctions non utilisées


function seuil_TKEO_Callback(hObject, eventdata, handles)
% hObject    handle to seuil_TKEO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of seuil_TKEO as text
%        str2double(get(hObject,'String')) returns contents of seuil_TKEO as a double


% --- Executes during object creation, after setting all properties.
function seuil_TKEO_CreateFcn(hObject, eventdata, handles)
% hObject    handle to seuil_TKEO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function duree_window_Callback(hObject, eventdata, handles)
% hObject    handle to duree_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of duree_window as text
%        str2double(get(hObject,'String')) returns contents of duree_window as a double


% --- Executes during object creation, after setting all properties.
function duree_window_CreateFcn(hObject, eventdata, handles)
% hObject    handle to duree_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function incr_window_Callback(hObject, eventdata, handles)
% hObject    handle to incr_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of incr_window as text
%        str2double(get(hObject,'String')) returns contents of incr_window as a double


% --- Executes during object creation, after setting all properties.
function incr_window_CreateFcn(hObject, eventdata, handles)
% hObject    handle to incr_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function duree_bouffees_Callback(hObject, eventdata, handles)
% hObject    handle to duree_bouffees (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of duree_bouffees as text
%        str2double(get(hObject,'String')) returns contents of duree_bouffees as a double


% --- Executes during object creation, after setting all properties.
function duree_bouffees_CreateFcn(hObject, eventdata, handles)
% hObject    handle to duree_bouffees (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function duree_bruit_ini_Callback(hObject, eventdata, handles)
% hObject    handle to duree_bruit_ini (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of duree_bruit_ini as text
%        str2double(get(hObject,'String')) returns contents of duree_bruit_ini as a double


% --- Executes during object creation, after setting all properties.
function duree_bruit_ini_CreateFcn(hObject, eventdata, handles)
% hObject    handle to duree_bruit_ini (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in acq_zero_emg.
function acq_zero_emg_Callback(hObject, eventdata, handles)
% hObject    handle to acq_zero_emg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user Data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of acq_zero_emg

function XLimMax_Callback(hObject, eventdata, handles)
draw_emg;


% --- Executes during object creation, after setting all properties.
function XLimMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XLimMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Recalc_for_only_one_EMG.
function Recalc_for_only_one_EMG_Callback(hObject, eventdata, handles)
% hObject    handle to Recalc_for_only_one_EMG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Recalc_for_only_one_EMG


% --- Executes on button press in Recalc_for_only_one_trial.
function Recalc_for_only_one_trial_Callback(hObject, eventdata, handles)
% hObject    handle to Recalc_for_only_one_trial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Recalc_for_only_one_trial
