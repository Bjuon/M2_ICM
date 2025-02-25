clear all; clc; close all
cpt = 0 ; 

ExitFolder = 'C:\Users\mathieu.yeche\Downloads' ;
PlotAndSave = false ;   % time consuming

[Patients, Folder, CondMed, ~]  = MAGIC.Patients.All('MAGIC_LFP',0);

                                            cnt = 0;
                                            disp(['Nombre de patients : '  num2str(length(Patients))])

AllPatAP_GOi_Fix = [];
AllPatML_GOi_Fix = [];
AllPatAP_NGO_Fix = [];
AllPatML_NGO_Fix = [];

AllPatAP_GOi_Cue = [];
AllPatML_GOi_Cue = [];
AllPatAP_NGO_Cue = [];
AllPatML_NGO_Cue = [];

AllTrialsAP_GOi_Fix = [];
AllTrialsML_GOi_Fix = [];
AllTrialsAP_NGO_Fix = [];
AllTrialsML_NGO_Fix = [];

AllTrialsAP_GOi_Cue = [];
AllTrialsML_GOi_Cue = [];
AllTrialsAP_NGO_Cue = [];
AllTrialsML_NGO_Cue = [];
                                                                                        
for p = 1:length(Patients)
    Patient = Patients{p};   
    if strcmp(Patient, 'FRa') 
        continue
    end
    Cond = "OFF";          
    Session = 'POSTOP';
    
    [Date, Type, num_trial, num_trial_NoGo_OK, num_trial_NoGo_Bad, num_trial_omission] = MAGIC.Patients.TrialList(Patient,Session,Cond,1);
    disp([Patients{p} '  n°' num2str(p) ' ' Cond ])

    PatAP_GOi_Fix = [];
    PatML_GOi_Fix = [];
    PatAP_NGO_Fix = [];
    PatML_NGO_Fix = [];

    PatAP_GOi_Cue = [];
    PatML_GOi_Cue = [];
    PatAP_NGO_Cue = [];
    PatML_NGO_Cue = [];

    cpt_goC_pat   = 1;
    cpt_nogoC_pat = 1;
    cpt_goF_pat   = 1;
    cpt_nogoF_pat = 1;

    for nt = 1:length(num_trial) % Boucle num_trial

        if str2num(num_trial{nt}) > 10 && str2num(num_trial{nt}) < 51
            
            [filename,~] = MAGIC.Patients.TrialName(Type, Date, Session , Patient , Cond , num_trial{nt} , 0);
            h = btkReadAcquisition([Folder Patient filesep filename]);

            [~, FixTime, CueTime] = MAGIC.GaitData.GetCueFixTime(h) ;
            if isnan(FixTime) || isnan(CueTime) ; continue  ; end
            Fa  = btkGetAnalogFrequency(h)   ;
            Jitter  = 1*Fa                   ;
            if Fa ~= 1000
                error([Patient 'Frequence d''acquisition non conforme'])
            end
            if round(CueTime*Fa-Jitter) < 0 
                disp([Patient ' - ' num2str(str2num(num_trial{nt})) ' GOi : pas de CUE !!!'])
                continue
            end

            CoP = btkGetForcePlatforms(h).channels ;
            if round(FixTime*Fa-Jitter) > 0
                PatAP_GOi_Fix(:,cpt_goF_pat) = CoP.Moment_Mx1(round(FixTime*Fa-Jitter):round(FixTime*Fa+Jitter)) - CoP.Moment_Mx1(round(FixTime*Fa-Jitter));
                PatML_GOi_Fix(:,cpt_goF_pat) = CoP.Moment_My1(round(FixTime*Fa-Jitter):round(FixTime*Fa+Jitter)) - CoP.Moment_My1(round(FixTime*Fa-Jitter));
                cpt_goF_pat = cpt_goF_pat + 1 ;
            else
                disp([Patient ' - ' num2str(str2num(num_trial{nt})) ' GOi : pas de fixation'])
            end

            Ev = btkGetEvents(h) ;
            Side = 0 ;
            if ~isfield(Ev, "Left_Foot_Off") || ~isfield(Ev, "Right_Foot_Off")
                fprintf(2, [Patient ' - ' num2str(str2num(num_trial{nt})) ' GOi : pas de marqueurs de pieds'])
                continue
            end
            if Ev.Left_Foot_Off(1) < Ev.Right_Foot_Off(1)
                Side = +1 ;
            else
                Side = -1 ;
            end
            PatAP_GOi_Cue(:,cpt_goC_pat) = Side * (CoP.Moment_Mx1(round(CueTime*Fa-Jitter):round(CueTime*Fa+Jitter)) - CoP.Moment_Mx1(round(CueTime*Fa-Jitter)));
            PatML_GOi_Cue(:,cpt_goC_pat) = Side * (CoP.Moment_My1(round(CueTime*Fa-Jitter):round(CueTime*Fa+Jitter)) - CoP.Moment_My1(round(CueTime*Fa-Jitter)));
            cpt_goC_pat = cpt_goC_pat + 1 ;
        end
    end

    for ntng = 1:length(num_trial_NoGo_OK) 
        
        [filename,~] = MAGIC.Patients.TrialName(Type, Date, Session , Patient , Cond , num_trial_NoGo_OK{ntng} , 0);
        h = btkReadAcquisition([Folder Patient filesep filename]);

        Fa  = btkGetAnalogFrequency(h)   ;
        [~, FixTime, CueTime] = MAGIC.GaitData.GetCueFixTime(h) ;
        if isnan(FixTime) || isnan(CueTime) ; continue  ; end
        Jitter  = 1*Fa                   ;
        if Fa ~= 1000
            error([Patient 'Frequence d''acquisition non conforme'])
        end
        if round(CueTime*Fa-Jitter) < 0 
            disp([Patient ' - ' num2str(str2num(num_trial_NoGo_OK{ntng})) ' NoGO : pas de CUE !!!'])
            continue
        end

        CoP = btkGetForcePlatforms(h).channels ;
        if round(FixTime*Fa-Jitter) > 0
            PatAP_NGO_Fix(:,cpt_nogoF_pat) = CoP.Moment_Mx1(round(FixTime*Fa-Jitter):round(FixTime*Fa+Jitter)) - CoP.Moment_Mx1(round(FixTime*Fa-Jitter));
            PatML_NGO_Fix(:,cpt_nogoF_pat) = CoP.Moment_My1(round(FixTime*Fa-Jitter):round(FixTime*Fa+Jitter)) - CoP.Moment_My1(round(FixTime*Fa-Jitter));
            cpt_nogoF_pat = cpt_nogoF_pat + 1 ; 
        else
            disp([Patient ' - ' num2str(str2num(num_trial_NoGo_OK{ntng})) ' NoGO : pas de fixation'])
        end
        PatAP_NGO_Cue(:,cpt_nogoC_pat) = CoP.Moment_Mx1(round(CueTime*Fa-Jitter):round(CueTime*Fa+Jitter)) - CoP.Moment_Mx1(round(CueTime*Fa-Jitter));
        PatML_NGO_Cue(:,cpt_nogoC_pat) = CoP.Moment_My1(round(CueTime*Fa-Jitter):round(CueTime*Fa+Jitter)) - CoP.Moment_My1(round(CueTime*Fa-Jitter));
        cpt_nogoC_pat = cpt_nogoC_pat + 1 ;
    end

    if isempty(PatAP_GOi_Fix) 
        fprintf(2, [Patient ' - Pas de fixation GO \n'])
    else
        AllPatAP_GOi_Fix(:,end+1) = mean(PatAP_GOi_Fix,2) ;
        AllPatML_GOi_Fix(:,end+1) = mean(PatML_GOi_Fix,2) ;
        AllTrialsAP_GOi_Fix(:,(end+1):(end+cpt_goF_pat-1)) = PatAP_GOi_Fix ;
        AllTrialsML_GOi_Fix(:,(end+1):(end+cpt_goF_pat-1)) = PatML_GOi_Fix ;
    end
    
    if isempty(PatAP_NGO_Fix) 
        fprintf(2, [Patient ' - Pas de fixation NoGO \n'])
    else
        AllPatAP_NGO_Fix(:,end+1) = mean(PatAP_NGO_Fix,2) ;
        AllPatML_NGO_Fix(:,end+1) = mean(PatML_NGO_Fix,2) ;
        AllTrialsAP_NGO_Fix(:,(end+1):(end+cpt_nogoF_pat-1)) = PatAP_NGO_Fix ;
        AllTrialsML_NGO_Fix(:,(end+1):(end+cpt_nogoF_pat-1)) = PatML_NGO_Fix ;
    end

    
    AllPatAP_GOi_Cue(:,end+1) = mean(PatAP_GOi_Cue,2) ;
    AllPatML_GOi_Cue(:,end+1) = mean(PatML_GOi_Cue,2) ;
    AllPatAP_NGO_Cue(:,end+1) = mean(PatAP_NGO_Cue,2) ;
    AllPatML_NGO_Cue(:,end+1) = mean(PatML_NGO_Cue,2) ;

    AllTrialsAP_GOi_Cue(:,(end+1):(end+cpt_goC_pat-1)) = PatAP_GOi_Cue ;
    AllTrialsML_GOi_Cue(:,(end+1):(end+cpt_goC_pat-1)) = PatML_GOi_Cue ;
    AllTrialsAP_NGO_Cue(:,(end+1):(end+cpt_nogoC_pat-1)) = PatAP_NGO_Cue ;
    AllTrialsML_NGO_Cue(:,(end+1):(end+cpt_nogoC_pat-1)) = PatML_NGO_Cue ;

end

% ___Plot_____________________________________________________________________

disp("normaliser par side 1er pas la cue")
EssaiDeFig = false ;
if EssaiDeFig
figure 
subplot(2,2,1) ; hold on
plot(mean(AllPatAP_GOi_Fix,2))
plot(mean(AllPatAP_GOi_Fix,2)+std(AllPatAP_GOi_Fix,0,2),'r')
plot(mean(AllPatAP_GOi_Fix,2)-std(AllPatAP_GOi_Fix,0,2),'r')
title('AP GOi Fix')

subplot(2,2,2) ; hold on
plot(mean(AllPatML_GOi_Fix,2))
plot(mean(AllPatML_GOi_Fix,2)+std(AllPatML_GOi_Fix,0,2),'r')
plot(mean(AllPatML_GOi_Fix,2)-std(AllPatML_GOi_Fix,0,2),'r')
title('ML GOi Fix')

subplot(2,2,3)
plot(mean(AllPatAP_NGO_Fix,2))
title('AP NGO Fix')
subplot(2,2,4)
plot(mean(AllPatML_NGO_Fix,2))
title('ML NGO Fix')

linkaxes([subplot(2,2,1),subplot(2,2,2),subplot(2,2,3),subplot(2,2,4)],'xy')

figure
subplot(2,2,1)
plot(mean(AllPatAP_GOi_Cue,2))
title('AP GOi Cue')
subplot(2,2,2)
plot(mean(AllPatML_GOi_Cue,2))
title('ML GOi Cue')
subplot(2,2,3)
plot(mean(AllPatAP_NGO_Cue,2))
title('AP NGO Cue')
subplot(2,2,4)
plot(mean(AllPatML_NGO_Cue,2))
title('ML NGO Cue')
linkaxes([subplot(2,2,1),subplot(2,2,2),subplot(2,2,3),subplot(2,2,4)],'xy')


figure 
subplot(2,2,1) ; hold on
for i = 1:size(AllTrialsAP_GOi_Fix,2)
    plot(AllTrialsAP_GOi_Fix(:,i))
end
title('AP GOi Fix')

subplot(2,2,2) ; hold on
for i = 1:size(AllTrialsML_GOi_Fix,2)
    plot(AllTrialsML_GOi_Fix(:,i))
end
title('ML GOi Fix')

subplot(2,2,3) ; hold on
for i = 1:size(AllTrialsAP_NGO_Fix,2)
    plot(AllTrialsAP_NGO_Fix(:,i))
end
title('AP NGO Fix')

subplot(2,2,4) ; hold on
for i = 1:size(AllTrialsML_NGO_Fix,2)
    plot(AllTrialsML_NGO_Fix(:,i))
end
title('ML NGO Fix')
end

NiceFig = false ;
if NiceFig
    addpath("C:\Users\mathieu.yeche\Documents\Toolbox\") % plot_darkmode.m
    %% FIX
figure
subplot(2,4,1) ; hold on
for i = 1:size(AllTrialsAP_GOi_Fix,2)
    plot(AllTrialsAP_GOi_Fix(:,i), "Color", [0.3 0.3 0.3, 0.08])
end
plot(mean(AllPatAP_GOi_Fix,2),'b','LineWidth',4)
title('AP GOi Fix')

subplot(2,4,2) ; hold on
for i = 1:size(AllTrialsML_GOi_Fix,2)
    plot(AllTrialsML_GOi_Fix(:,i), "Color", [0.3 0.3 0.3, 0.08])
end
plot(mean(AllPatML_GOi_Fix,2),'b','LineWidth',4)
title('ML GOi Fix')

subplot(2,4,5) ; hold on
for i = 1:size(AllTrialsAP_NGO_Fix,2)
    plot(AllTrialsAP_NGO_Fix(:,i), "Color", [0.3 0.3 0.3, 0.08])
end
plot(mean(AllPatAP_NGO_Fix,2),'b','LineWidth',4)
title('AP NGO Fix')

subplot(2,4,6) ; hold on
for i = 1:size(AllTrialsML_NGO_Fix,2)
    plot(AllTrialsML_NGO_Fix(:,i), "Color", [0.3 0.3 0.3, 0.08])
end
plot(mean(AllPatML_NGO_Fix,2),'b','LineWidth',4)
title('ML NGO Fix')

subplot(2,4,3) ; hold on
for i = 1:size(AllTrialsAP_GOi_Cue,2)
    plot(AllTrialsAP_GOi_Cue(:,i), "Color", [0.3 0.3 0.3, 0.08])
end
plot(mean(AllPatAP_GOi_Cue,2),'b','LineWidth',4)
title('AP GOi Cue')

subplot(2,4,4) ; hold on
for i = 1:size(AllTrialsML_GOi_Cue,2)
    plot(AllTrialsML_GOi_Cue(:,i), "Color", [0.3 0.3 0.3, 0.08])
end
plot(mean(AllPatML_GOi_Cue,2),'b','LineWidth',4)
title('ML GOi Cue')

subplot(2,4,7) ; hold on
for i = 1:size(AllTrialsAP_NGO_Cue,2)
    plot(AllTrialsAP_NGO_Cue(:,i), "Color", [0.3 0.3 0.3, 0.08])
end
plot(mean(AllPatAP_NGO_Cue,2),'b','LineWidth',4)
title('AP NGO Cue')

subplot(2,4,8) ; hold on
for i = 1:size(AllTrialsML_NGO_Cue,2)
    plot(AllTrialsML_NGO_Cue(:,i), "Color", [0.3 0.3 0.3, 0.08])
end
plot(mean(AllPatML_NGO_Cue,2),'b','LineWidth',4)
title('ML NGO Cue')

linkaxes([subplot(2,4,1),subplot(2,4,3),subplot(2,4,5),subplot(2,4,7)],'xy')
linkaxes([subplot(2,4,2),subplot(2,4,4),subplot(2,4,6),subplot(2,4,8)],'xy')
plot_darkmode([1,1,1],1.5,ones(1,3)*0)


end





% ___Save_____________________________________________________________________
todo_Save = false ;
if todo_Save
save([ExitFolder filesep 'AllPatAP_GOi_Fix.mat'],'AllPatAP_GOi_Fix')
save([ExitFolder filesep 'AllPatML_GOi_Fix.mat'],'AllPatML_GOi_Fix')
save([ExitFolder filesep 'AllPatAP_NGO_Fix.mat'],'AllPatAP_NGO_Fix')
save([ExitFolder filesep 'AllPatML_NGO_Fix.mat'],'AllPatML_NGO_Fix')

save([ExitFolder filesep 'AllPatAP_GOi_Cue.mat'],'AllPatAP_GOi_Cue')
save([ExitFolder filesep 'AllPatML_GOi_Cue.mat'],'AllPatML_GOi_Cue')
save([ExitFolder filesep 'AllPatAP_NGO_Cue.mat'],'AllPatAP_NGO_Cue')
save([ExitFolder filesep 'AllPatML_NGO_Cue.mat'],'AllPatML_NGO_Cue')
end

