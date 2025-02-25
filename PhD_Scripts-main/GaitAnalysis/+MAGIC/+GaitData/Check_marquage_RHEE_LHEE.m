%% Marquage check

% ___Initialisation___________________________________________________________
clear all; clc; close all; warning('off','MATLAB:print:FigureTooLargeForPage')
cpt = 0 ; DemiAExcl  = {}; DemiALabel = {};

todo_MarcheLancee = 0; % Or only LFP
ExitFolder = 'C:\Users\mathieu.yeche\OneDrive - ICM\Downloads' ;
PlotAndSave = false ;   % time consuming

[Patients, Folder, CondMed, ~]  = MAGIC.Patients.All('MAGIC_LFP',0);

% Patients = {'VIj','SOh','REa','GUG','BARGU14','COm','BEm','DROCA16','GIs','LOp','DESJO20','GAl','FEp','DEp','FRa','ALb','FRJ'};
% Patients = {'BARGU14','COm','BEm','DROCA16','REa','DESJO20','FRa'};
% Patients = {'BARGU14'};
% Patients = {'FRJ',};
% Patients = {'GAl','FEp','DEp','ALb','SOh','VIj'};
% Patients = {'FRa'};


                                            cnt = 0;
                                            disp(['Nombre de patients : '  num2str(length(Patients))])
%    
for p = 1:length(Patients)
for condonofff = 1:2 
    Patient = Patients{p};   
    Cond = CondMed{condonofff};          
    Session = 'POSTOP';
    
% Essais
    
 
[Date, Type, num_trial, num_trial_NoGo_OK, num_trial_NoGo_Bad, num_trial_omission] = MAGIC.Patients.TrialList(Patient,Session,Cond,1);
 
 

disp([Patients{p} '  n°' num2str(p) ' ' Cond ])

        
DATA_R = {};
DATA_L = {};
DATA_Event = {};
DATA_End_turn   = [] ;
DATA_Start_turn = [] ;  
DATA_Start_trial   = [] ;
        
        
for nt = 1:length(num_trial) % Boucle num_trial


%%
% ___Chargement fichier___________________________________________________________

% Nom de l'essai à charger
%filename = ['ParkRouen_' date '_' Patient{p}  '_MAGIC_'  Session{session_i} '_' Cond{cond_i} '_GNG_GAIT_' num_trial{nt} '.c3d'];
%HereChange
if strcmp(Type,'GOGAIT') || strcmp(Type,'GAITPARK')
    filename = [ Type '_'  Session '_'  Patient  '_'  Cond '_GNG_' num_trial{nt}(end-1:end) '.c3d'];
else
    if strcmp(Patient,'GUG') || strcmp(Patient,'FRJ') || strcmp(Patient,'FRa')
        filename = ['ParkRouen_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' num_trial{nt} '.c3d'];
    else
        filename = ['ParkPitie_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' num_trial{nt} '.c3d'];
    end
end

% Dossier ou se trouve l'essai


%HereChange

% Lecture de l'essai (fichier c3d)
h= btkReadAcquisition(fullfile([Folder Patient ],filename));

% Recuperation des parametres d'interet
All_mks = btkGetMarkers(h); % chargement des marqueurs
All_names = fields(All_mks); % noms des marqueurs 
Fs = btkGetPointFrequency(h); % fréquence d'acquisition des caméras
Ev = btkGetEvents(h); % chargement des évènements temporels
Times  = (0:btkGetLastFrame(h)-btkGetFirstFrame(h))/btkGetPointFrequency(h); % timeline de l'enregistrement
n  = length(Times);

if isfield (All_mks, 'RHEE')
    DATA_R{nt} = All_mks.RHEE(:, 2);
    DATA_L{nt} = All_mks.LHEE(:, 2);
else
    disp(['Pas de marquage : ' filename])
    DATA_R{nt} = NaN;
    DATA_L{nt} = NaN;
end

if isfield(Ev, 'General_Event')
    DATA_Start_trial(nt)  =  Ev.General_Event(1,end)*Fs ; 
else
    DATA_Start_trial(nt)  =  0 ;
end



%% FO et FC marques
listtmp = [];
if isfield(Ev, 'Right_Foot_Off')
    for idxfo = 1 : length(Ev.Right_Foot_Off)    ; listtmp(end+1) = Ev.Right_Foot_Off(idxfo)*Fs    ; end
    for idxfo = 1 : length(Ev.Right_Foot_Strike) ; listtmp(end+1) = Ev.Right_Foot_Strike(idxfo)*Fs ; end
    for idxfo = 1 : length(Ev.Left_Foot_Off)     ; listtmp(end+1) = Ev.Left_Foot_Off(idxfo)*Fs     ; end
    for idxfo = 1 : length(Ev.Left_Foot_Strike)  ; listtmp(end+1) = Ev.Left_Foot_Strike(idxfo)*Fs  ; end
    listtmp = sort(listtmp) ;
else
    listtmp(end+1) = NaN ;
end

    DATA_Event{nt} = listtmp;




%% start turn
                             
                                    if isfield(Ev,'General_end_turn')
                                        Ev = setfield(Ev,'General_End_Turn',Ev.General_end_turn);
                                    end
                                    if isfield(Ev,'General_End_turn')       && numel(Ev.General_End_turn) == 1 
                                        DATA_End_turn(nt)  = Ev.General_End_turn*Fs;
                                    elseif isfield(Ev,'General_End_Turn')   && numel(Ev.General_End_Turn) == 1 
                                        DATA_End_turn(nt)  = Ev.General_End_Turn*Fs;
                                    elseif isfield(Ev,'General_End_turn')   && numel(Ev.General_End_turn) ~= 1 
                                        DATA_End_turn(nt)  = Ev.General_End_turn(end)*Fs;
                                        disp(['Plusieurs end   turn : ' filename])
                                    elseif isfield(Ev,'General_End_Turn')   && numel(Ev.General_End_Turn) ~= 1 
                                        DATA_End_turn(nt)  = Ev.General_End_Turn(end)*Fs;
                                        disp(['Plusieurs end   turn : ' filename])
                                    else
                                        DATA_End_turn(nt)  = length(DATA_R{1,nt});
                                        disp(['Pas de end   turn : ' filename])
                                    end
                                    

                                    if isfield(Ev,'General_start_turn')                                     
                                        Ev = setfield(Ev,'General_Start_Turn',Ev.General_start_turn);
                                    end
                                    if isfield(Ev,'General_Start_turn')       && numel(Ev.General_Start_turn) == 1 
                                        DATA_Start_turn(nt)  = Ev.General_Start_turn*Fs;
                                    elseif isfield(Ev,'General_Start_Turn')   && numel(Ev.General_Start_Turn) == 1 
                                        DATA_Start_turn(nt)  = Ev.General_Start_Turn*Fs;
                                    elseif isfield(Ev,'General_Start_turn')   && numel(Ev.General_Start_turn) ~= 1 
                                        DATA_Start_turn(nt)  = Ev.General_Start_turn(end)*Fs;
                                        disp(['Plusieurs start turn : ' filename])
                                    elseif isfield(Ev,'General_Start_Turn')   && numel(Ev.General_Start_Turn) ~= 1 
                                        DATA_Start_turn(nt)  = Ev.General_Start_Turn(end)*Fs;
                                        disp(['Plusieurs start turn : ' filename])
                                    else
                                        DATA_Start_turn(nt)  = length(DATA_R{1,nt});
                                        disp(['Pas de start turn : ' filename])
                                    end



%Verifie que tous les events sont bien pris en compte malgre leur orthographe
fieldsEv = fieldnames(Ev) ;
for i_fields = 1:length(fieldsEv)
    if strcmp(fieldsEv{i_fields},'General_Event') || strcmp(fieldsEv{i_fields},'Left_Foot_Off') || strcmp(fieldsEv{i_fields},'Left_Foot_Strike') || ...
            strcmp(fieldsEv{i_fields},'Right_Foot_Off') || strcmp(fieldsEv{i_fields},'Right_Foot_Strike') || strcmp(fieldsEv{i_fields},'General_Start_turn') || ...
            strcmp(fieldsEv{i_fields},'General_End_turn') || strcmp(fieldsEv{i_fields},'General_Start_Turn') || strcmp(fieldsEv{i_fields},'General_End_Turn') || ...
            strcmp(fieldsEv{i_fields},'General_Start_FOG') || strcmp(fieldsEv{i_fields},'Left_MidFOG_Start') || strcmp(fieldsEv{i_fields},'Left_MidFOG_End') || ...
            strcmp(fieldsEv{i_fields},'Right_MidFOG_Start') || strcmp(fieldsEv{i_fields},'Right_MidFOG_End') || strcmp(fieldsEv{i_fields},'General_End_FOG') || ...
            strcmp(fieldsEv{i_fields},'Left_t0_EMG') || strcmp(fieldsEv{i_fields},'Right_t0_EMG') 
        if strcmp(fieldsEv{i_fields},'General_Event') && length(Ev.General_Event) > 2
            fprintf(2,['Trop de General_Event (' num2str(length(Ev.General_Event)) ' valeurs dans les APA) essai : ' filename  '\n'])
        end
    else
        fprintf(2,['Evenement mal nommé, non pris en compte : ' fieldsEv{i_fields} ' , essai : ' filename  '\n'])
    end
end

if isfield(Ev,'General_Start_FOG')
    if     numel(Ev.General_End_FOG) < numel(Ev.General_Start_FOG)
        disp(['Plus de start que de end FOG : ' filename])
    elseif numel(Ev.General_End_FOG) > numel(Ev.General_Start_FOG)
        disp(['Plus de end que de start FOG : ' filename])
    end
end

if isfield(Ev,'General_End_turn') || isfield(Ev,'General_End_Turn')                                  
    if ~(isfield(Ev,'General_Start_Turn') || isfield(Ev,'General_Start_turn'))
        disp(['Demi tour fini mais non débuté : ' filename])
    end
end

if isfield(Ev,'General_Start_Turn') || isfield(Ev,'General_Start_turn')                                   
    [alertgiven,TalonChecked,~] = MAGIC.GaitData.Check_exclusion_essais_verifies(filename,0) ;
    if ~(isfield(Ev,'General_End_turn') || isfield(Ev,'General_End_Turn'))
        disp(['Demi tour débuté mais non terminé : ' filename])
    end
else
    [alertgiven,TalonChecked,~] = MAGIC.GaitData.Check_exclusion_essais_verifies(filename,0) ;
    disp(['Pas de demi tour : ' filename])
    if alertgiven == false 
        disp(['Verifier l''inversion : ' filename])
    end
    alertgiven = true ;
end

if ~ todo_MarcheLancee
    alertgiven = true ;
end

if length(listtmp) > 3 && ~alertgiven
    for i = round(listtmp(4))-40 : round(DATA_Start_turn(nt))+20
        if sum(abs(All_mks.RHEE(i,:)-All_mks.RHEE(i-1,:))) > 40*200/Fs || sum(abs(All_mks.LHEE(i,:)-All_mks.LHEE(i-1,:))) > 40*200/Fs
            alertgiven = true ;
            fprintf(2, ['L/R Inversion (1): ' filename ' frame ' num2str(i) ' size ' num2str(round(sum(abs(All_mks.LHEE(i,:)-All_mks.LHEE(i-1,:))))) '/' num2str(round(sum(abs(All_mks.RHEE(i,:)-All_mks.RHEE(i-1,:))))) '\n'])
        end
        if All_mks.RHEE(i, 2) == 0 || All_mks.LHEE(i, 2) == 0
            fprintf(2, ['Pbm Marche lancée : ' filename ' frame ' num2str(i) '\n'])
            break
        end
        
        if All_mks.RHEE(i, 1) - All_mks.LHEE(i, 1)  < -40 && i < round(DATA_Start_turn(nt)) - 20 && ~alertgiven && ~TalonChecked
            fprintf(2, ['Talons Inverse: ' filename ' frame ' num2str(i) ' of ' num2str(abs(round(All_mks.RHEE(i, 1) - All_mks.LHEE(i, 1)))) 'mm \n'])
            alertgiven = true ;
            break
        end
    end
end

if isfield(All_mks,'RMALI') && isfield(All_mks,'RMALE') &&  length(listtmp) > 3 && ~alertgiven
    for i = round(listtmp(4))-40 : round(DATA_End_turn(nt))
        if All_mks.RMALI(i-1,2) ~= 0 && All_mks.RMALE(i-1,2) ~= 0 && All_mks.RHEE(i-1,2) ~= 0 && sum(abs(All_mks.RHEE(i,:)-All_mks.RMALI(i-1,:))) > 200*200/Fs && sum(abs(All_mks.RHEE(i,:)-All_mks.RMALE(i-1,:))) > 200*200/Fs
            fprintf(2, ['L/R Inversion (right): ' filename ' frame ' num2str(i) ' size ' num2str(round(sum(abs(All_mks.RHEE(i,:)-All_mks.RMALI(i-1,:))))) '/' num2str(round(sum(abs(All_mks.RHEE(i,:)-All_mks.RMALE(i-1,:))))) '\n'])
            alertgiven = true ;
            break
        end
    end
end

if isfield(All_mks,'LMALI') && isfield(All_mks,'LMALE') &&  length(listtmp) > 3 && ~alertgiven
    for i = round(listtmp(4))-40 : round(DATA_End_turn(nt))
        if All_mks.LMALI(i-1,2) ~= 0 && All_mks.LMALE(i-1,2) ~= 0 && All_mks.LHEE(i-1,2) ~= 0 && sum(abs(All_mks.LHEE(i,:)-All_mks.LMALI(i-1,:))) > 200*200/Fs && sum(abs(All_mks.LHEE(i,:)-All_mks.LMALE(i-1,:))) > 200*200/Fs
            fprintf(2, ['L/R Inversion (left): ' filename ' frame ' num2str(i) ' size ' num2str(round(sum(abs(All_mks.LHEE(i,:)-All_mks.LMALI(i-1,:))))) '/' num2str(round(sum(abs(All_mks.LHEE(i,:)-All_mks.LMALE(i-1,:))))) '\n'])
            alertgiven = true ;
            break
        end
    end
end

Reperes_gauche = sum([isfield(All_mks,'LHLX'), isfield(All_mks,'LMETA5'),isfield(All_mks,'LMETA1')]) ;
if Reperes_gauche == 3 &&  length(listtmp) > 3 && ~alertgiven
    for i = round(listtmp(4))-40 : round(DATA_End_turn(nt))
        if All_mks.LHEE(i-1,2) ~= 0 && All_mks.LMETA5(i-1,2) ~= 0 && All_mks.LMETA1(i-1,2) ~= 0 && All_mks.LHLX(i-1,2) ~= 0 
            calcul_distance_pied = sum([ sum(abs(All_mks.LHEE(i,:)-All_mks.LMETA5(i-1,:))) > 400*200/Fs , sum(abs(All_mks.LHEE(i,:)-All_mks.LHLX(i-1,:))) > 450*200/Fs ,  sum(abs(All_mks.LHEE(i,:)-All_mks.LMETA1(i-1,:))) > 400*200/Fs] ) ;
            if calcul_distance_pied >= 2
                fprintf(2, ['L/R Inversion (left, 3 markers): ' filename ' frame ' num2str(i) '\n'])
                alertgiven = true ;
                break
            end
        end
    end
end

if Reperes_gauche == 2 &&  length(listtmp) > 3 && ~alertgiven
    for i = round(listtmp(4))-40 : round(DATA_End_turn(nt))
        if isfield(All_mks,'LHLX') && isfield(All_mks,'LMETA5') 
            alpha = All_mks.LMETA5(i,:) ;
            beta  = All_mks.LHLX(i,:)   ;
        elseif isfield(All_mks,'LHLX') && isfield(All_mks,'LMETA1') 
            alpha = All_mks.LMETA1(i,:) ;
            beta  = All_mks.LHLX(i,:) ;
        elseif isfield(All_mks,'LMETA5') && isfield(All_mks,'LMETA1') 
            alpha = All_mks.LMETA5(i,:) ;
            beta  = All_mks.LMETA1(i,:) ;
        end
        if All_mks.LHEE(i,2) ~= 0 && alpha(2) ~= 0 && beta(2) ~= 0 
            if sum([ sum(abs(All_mks.LHEE(i,:)-alpha)) > 400*200/Fs , sum(abs(All_mks.LHEE(i,:)-beta)) > 450*200/Fs ] )  >= 2
                fprintf(2, ['L/R Inversion (left, 2 markers): ' filename ' frame ' num2str(i) '\n'])
                alertgiven = true ;
                break
            end
        end
    end
end

Reperes_droite = sum([isfield(All_mks,'RHLX'), isfield(All_mks,'RMETA5'),isfield(All_mks,'RMETA1')]) ;
if Reperes_droite == 3 &&  length(listtmp) > 3 && ~alertgiven
    for i = round(listtmp(4))-40 : round(DATA_End_turn(nt))
        if All_mks.RHEE(i-1,2) ~= 0 && All_mks.RMETA5(i-1,2) ~= 0 && All_mks.RMETA1(i-1,2) ~= 0 && All_mks.RHLX(i-1,2) ~= 0 
            calcul_distance_pied = sum([ sum(abs(All_mks.RHEE(i,:)-All_mks.RMETA5(i-1,:))) > 400*200/Fs , sum(abs(All_mks.RHEE(i,:)-All_mks.RHLX(i-1,:))) > 450*200/Fs ,  sum(abs(All_mks.RHEE(i,:)-All_mks.RMETA1(i-1,:))) > 400*200/Fs] ) ;
            if calcul_distance_pied >= 2
                fprintf(2, ['L/R Inversion (right, 3 markers): ' filename ' frame ' num2str(i) '\n'])
                alertgiven = true ;
                break
            end
        end
    end
end

if Reperes_gauche == 2 &&  length(listtmp) > 3 && ~alertgiven
    for i = round(listtmp(4))-40 : round(DATA_End_turn(nt))
        if isfield(All_mks,'RHLX') && isfield(All_mks,'RMETA5') 
            alpha = All_mks.RMETA5(i,:) ;
            beta  = All_mks.RHLX(i,:)   ;
        elseif isfield(All_mks,'RHLX') && isfield(All_mks,'RMETA1') 
            alpha = All_mks.RMETA1(i,:) ;
            beta  = All_mks.RHLX(i,:) ;
        elseif isfield(All_mks,'RMETA5') && isfield(All_mks,'RMETA1') 
            alpha = All_mks.RMETA5(i,:) ;
            beta  = All_mks.RMETA1(i,:) ;
        end
        if All_mks.RHEE(i,2) ~= 0 && alpha(2) ~= 0 && beta(2) ~= 0 
            if sum([ sum(abs(All_mks.RHEE(i,:)-alpha)) > 400*200/Fs , sum(abs(All_mks.RHEE(i,:)-beta)) > 450*200/Fs ] )  >= 2
                fprintf(2, ['L/R Inversion (right, 2 markers): ' filename ' frame ' num2str(i) '\n'])
                alertgiven = true ;
                break
            end
        end
    end
end
       
    cptBadLabel = 0;
    for i = round(DATA_Start_turn(nt)):round(DATA_End_turn(nt))
        if All_mks.RHEE(i, 2) == 0
            cptBadLabel = cptBadLabel+1;
        end
        if All_mks.LHEE(i, 2) == 0
            cptBadLabel = cptBadLabel+1;
        end
    end
    
    if cptBadLabel == 0
        continue
    elseif cptBadLabel <= 50
        DemiALabel{end+1,1} = filename;
    else
        DemiAExcl{end+1,1} = filename    ;
        DemiAExcl{end  ,2} = cptBadLabel ;
    end
    
    


end

if PlotAndSave
longertime = ceil(size(DATA_R,2)/3);
fig = figure('Name', [Patient Cond],'NumberTitle','off' , 'unit', 'centimeter', 'position', [24.00 15.60 21 29.7]);
for k = 1:size(DATA_R,2)
    hauteurordonees = 10 ;
    subplot(longertime,3,k)
    if ~isnan(DATA_R{1,k})
             plot(DATA_R{1,k}, 'color', [0.4660 0.6740 0.1880])
    hold on, plot(DATA_L{1,k}, 'color', [0.6350 0.0780 0.1840])
    hauteurordonees = max(max(DATA_L{1,k}),max(DATA_R{1,k}));
    end
    hold on, plot([DATA_End_turn(k)    DATA_End_turn(k)  ]', [hauteurordonees/5 hauteurordonees]', 'b', 'LineWidth' , 2.5)
    hold on, plot([DATA_Start_turn(k)  DATA_Start_turn(k)]', [hauteurordonees/5 hauteurordonees]', 'c', 'LineWidth' , 2.5)
    hold on, plot(cat(1,DATA_Event{k},DATA_Event{k}), [ones(size(DATA_Event{k},2),1)*hauteurordonees/5.5  ones(size(DATA_Event{k},2),1)*hauteurordonees]', 'y', 'LineWidth' , 1)
    axis([DATA_Start_trial(k) DATA_End_turn(k)+300 -20 hauteurordonees]);
    ax         = gca           ;
    ax.XColor  = [0.6 0.6 0.6] ;
    ax.YColor  = [0.6 0.6 0.6] ;
    ax.TickDir = 'out'         ;
    ax.Box     = 'off'         ;
    textfottitle = fullfile( Patient, Cond, num_trial(k)) ;
    title(textfottitle, 'interpreter', 'none')
end
% saveas(fig, [Patient '_' Cond '.svg'], 'svg')
saveas(fig, fullfile(ExitFolder, [Patient '_' Cond '.pdf']), 'pdf')
close(fig)

end
end
end

if todo_MarcheLancee
    disp('Demi tour à relabel : ')
    disp(DemiALabel)
    disp('Demi tour à exclure : ')
    disp(DemiAExcl)
end

warning('on','MATLAB:print:FigureTooLargeForPage')
