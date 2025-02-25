

[Patients, Folder, CondMed, ~ ]  = MAGIC.Patients.All('MAGIC_LFP',0);
cnt = 0;
cpt=0;
disp(['Nombre de patients : '  num2str(length(Patients))])

TABLENUM.Patient = 'Patient';
TABLENUM.Session = 'Session';
TABLENUM.Cond = 'Condition'; 
TABLENUM.GOc_essai = 'GOc_essai' ;
TABLENUM.GOc_event = 'GOc_event' ;
TABLENUM.GOi_essai = 'GOi_essai' ;
TABLENUM.GOi_event = 'GOi_event' ;
TABLENUM.NoGO_OK_essai = 'NoGO_OK_essai' ;
TABLENUM.NoGO_OK_event = 'NoGO_OK_event' ;
TABLENUM.NoGO_Bad_essai = 'NoGO_Bad_essai' ;
TABLENUM.GOi_Bad_essai = 'num_trial_omission' ;
TABLENUM.GOc_Bad_essai = 'num_trial_omission' ;
TABLENUM.Nbr_FOG_essai = 'num_trial_FOG' ;
cpt = cpt+1;
TabFin.TABLENUM(cpt) = TABLENUM ;


for p = 1:length(Patients)
for condonofff = 1:2 
    Patient = Patients{p};   
    Cond = CondMed{condonofff};          
    Session = 'POSTOP';


cpt2=0;
disp([Patients{p} '  n°' num2str(p) ' ' Cond ])

[Date, Type, num_trial, num_trial_NoGo_OK, num_trial_NoGo_Bad, num_trial_omission] = MAGIC.Patients.TrialList(Patient,Session,Cond,1);
    
% Dossier ou se trouve l'essai

if ~strcmp(Patient, 'REa') || strcmp(Cond, 'OFF')
APA = readtable([Folder 'ResAPA_extension_LINKERS_v3.xlsx'],'Format','auto'); %HereChange    
listFOG={};


EventCertSUM = 0 ;
EventIncrSUM = 0 ;
NumCertSUM   = 0 ;
NumIncrSUM   = 0 ;
NumErrGoi    = 0 ;
NumErrGoc    = 0 ;

if ~isempty(num_trial_omission)
    for nt = 1:length(num_trial_omission) % Boucle num_trial
        if str2num(num_trial_omission{nt}) <= 10 || (str2num(num_trial_omission{nt}) > 50 && str2num(num_trial_omission{nt}) < 100)
            NumErrGoc = NumErrGoc + 1 ;
        else 
            NumErrGoi = NumErrGoi + 1 ;
        end
    end
end

for nt = 1:length(num_trial) % Boucle num_trial


%%
% ___Chargement fichier___________________________________________________________

% Nom de l'essai à charger
if strcmp(Type,'GOGAIT') | strcmp(Type,'GAITPARK')
    filename = [ Type '_'  Session '_'  Patient  '_'  Cond '_GNG_' num_trial{nt}(end-1:end) '.c3d'];
else
    if strcmp(Patient,'GUG') | strcmp(Patient,'FRJ') | strcmp(Patient,'FRa')
        filename = ['ParkRouen_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' num_trial{nt} '.c3d'];
    else
        filename = ['ParkPitie_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' num_trial{nt} '.c3d'];
    end
end
% Lecture de l'essai (fichier c3d)
h = btkReadAcquisition([Folder Patient '\' filename] );
Fs = btkGetPointFrequency(h); % fréquence d'acquisition des caméras
Ev = btkGetEvents(h); % chargement des évènements temporels
Times  = (0:btkGetLastFrame(h)-btkGetFirstFrame(h))/btkGetPointFrequency(h); % timeline de l'enregistrement
n  = length(Times);

LocalEvent = 2 ;

% APA
apa_i=1;
while ~strcmp(APA.TrialName{apa_i}, filename(1:end-4))   %tant qu'il ne trouve pas, il les passe un a la suite
apa_i = apa_i+1;
end
    if strcmp(APA.TrialName{apa_i}, filename(1:end-4))   %herepbm   ajout
        LocalEvent = LocalEvent + 5 ;
    end

LocalEvent = LocalEvent + length(Ev.Left_Foot_Off(2:end)) + length(Ev.Right_Foot_Strike(2:end)) + length(Ev.Right_Foot_Off(2:end)) + length(Ev.Left_Foot_Strike(2:end)) ;

if isfield(Ev,'Left_t0_EMG')                
    LocalEvent = LocalEvent + 1 ; end
if isfield(Ev,'Right_t0_EMG')                
    LocalEvent = LocalEvent + 1 ; end

if isfield(Ev,'General_start_turn')                                     %herepbm   ajout
    Ev = setfield(Ev,'General_Start_Turn',Ev.General_start_turn);
end
if isfield(Ev,'General_end_turn')
    Ev = setfield(Ev,'General_End_Turn',Ev.General_end_turn);
end


if isfield(Ev,'General_Start_turn')                
LocalEvent = LocalEvent + 1 ;
elseif isfield(Ev,'General_Start_Turn')
LocalEvent = LocalEvent + 1 ;
end
    if isfield(Ev,'General_End_turn') 
    LocalEvent = LocalEvent + 1 ;
    elseif isfield(Ev,'General_End_Turn') 
    LocalEvent = LocalEvent + 1 ;
    end

% FOG
if isfield(Ev,'General_Start_FOG')                          %herepbm    savoir quels essais on des fogs et verifier qu'ils sortent bien
LocalEvent = LocalEvent + 1 ;
listFOG{end+1} = num_trial{nt} ;
end
    if isfield(Ev,'General_End_FOG')
    LocalEvent = LocalEvent + 1 ;
    end


% Concatenation des informations de tous les essais
 TrialNum = str2num(num_trial{nt}) ;

if TrialNum <= 10 || TrialNum > 50
   CERTITUDE = 1 ; else ; CERTITUDE = 0 ; end 
    if     strcmp(filename,'ParkPitie_2019_11_28_LOp_GBMOV_POSTOP_OFF_GNG_GAIT_050.c3d'); CERTITUDE = 1 ;
    elseif strcmp(filename,'ParkPitie_2019_11_28_LOp_GBMOV_POSTOP_ON_GNG_GAIT_010.c3d') ; CERTITUDE = 0 ;
    elseif strcmp(filename,'ParkPitie_2019_11_28_LOp_GBMOV_POSTOP_ON_GNG_GAIT_049.c3d') ; CERTITUDE = 1 ;
    elseif strcmp(filename,'ParkPitie_2019_11_28_LOp_GBMOV_POSTOP_ON_GNG_GAIT_050.c3d') ; CERTITUDE = 1 ;
    elseif TrialNum >= 110 ; CERTITUDE = 0 ; end
    
if CERTITUDE
    EventCertSUM = EventCertSUM + LocalEvent ;
    NumCertSUM = NumCertSUM + 1 ;
else
    EventIncrSUM = EventIncrSUM + LocalEvent ;
    NumIncrSUM = NumIncrSUM + 1 ;
end

%% CLEAR
clearvars -except NumErrGoc NumErrGoi Folder TABLENUM TabFin NumCertSUM NumIncrSUM EventCertSUM EventIncrSUM Patients p condonofff CondMed cnt cpt cpt2 APA Patient Session num_trial_omission num_trial_NoGo_OK num_trial_NoGo_Bad num_trial nt MARCHE Cond Type Date listFOG

end


TABLENUM.Patient = Patient;
TABLENUM.Session = Session;
TABLENUM.Cond = Cond; 
TABLENUM.GOc_essai = NumCertSUM ;
TABLENUM.GOc_event = EventCertSUM ;
TABLENUM.GOi_essai = NumIncrSUM ;
TABLENUM.GOi_event = EventIncrSUM ;
TABLENUM.NoGO_OK_essai = length(num_trial_NoGo_OK) ;
TABLENUM.NoGO_OK_event = 2 * length(num_trial_NoGo_OK) ;
TABLENUM.NoGO_Bad_essai = length(num_trial_NoGo_Bad) ;
TABLENUM.GOi_Bad_essai = NumErrGoi ;
TABLENUM.GOc_Bad_essai = NumErrGoc ;
TABLENUM.Nbr_FOG_essai = length(listFOG) ;

cpt = cpt+1;

TabFin.TABLENUM(cpt) = TABLENUM ;


end
end
end

disp('Maintenant copier TabFin.TABLENUM dans un excel')

clearvars -except TabFin 