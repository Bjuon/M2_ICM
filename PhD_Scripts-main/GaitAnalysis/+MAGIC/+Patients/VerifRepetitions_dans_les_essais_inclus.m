
clear all; clc; close all;
%Verification essais nombre trigger enregistrés par vicon
Patients = {'GAl','FEp','DEp','FRa','ALb','FRJ','SOh','VIj','GUG','BARGU14','COm','BEm','DROCA16','GIs','LOp','DESJO20','REa',};
% Patients = {'FRa','BARGU14','COm','BEm','DROCA16','DESJO20','REa',};
% Patients = {'GAl','FEp','DEp','ALb','FRJ','SOh','VIj','GUG','GIs','LOp','DESJO20',};
Patients = {'AUGAL37',};
CondMed = {'OFF','ON'};
[Patients, Folder, CondMed, ~ ]  = MAGIC.Patients.All('MAGIC_LFP',0);

todo.filename = 1 ;
                                            cnt = 0;
                                            disp(['Nombre de patients : '  num2str(length(Patients))])
%    
for p = 1:length(Patients)
for condonofff = 1:length(CondMed) 
    Patient = Patients{p};   
    Cond = CondMed{condonofff};          
    Session = 'POSTOP';
    
% Essais
    
[Date, Type, num_trial, num_trial_NoGo_OK, num_trial_NoGo_Bad, num_trial_omission] = MAGIC.Patients.TrialList(Patient,Session,Cond,1);

if todo.filename
    if strcmp(Type,'GOGAIT') | strcmp(Type,'GAITPARK')
        filename = [ Type '_'  Session '_'  Patient  '_'  Cond '_GNG' ];
    else
        if strcmp(Patient,'GUG') | strcmp(Patient,'FRJ') | strcmp(Patient,'FRa')
            filename = ['ParkRouen_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' ];
        else
            filename = ['ParkPitie_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' ];
        end
    end
    disp (filename)
end

cnt = cnt + length(num_trial) ;

ng = length(num_trial_NoGo_OK) + length(num_trial_NoGo_Bad);
gng= ng + length(num_trial);
num_trial(length(num_trial)+1:(length(num_trial)+length(num_trial_NoGo_Bad))) =  num_trial_NoGo_Bad ;
num_trial(length(num_trial)+1:length(num_trial)+length(num_trial_NoGo_OK)) =  num_trial_NoGo_OK ;
if exist('num_trial_omission','var') ; num_trial(length(num_trial)+1:length(num_trial)+length(num_trial_omission)) =  num_trial_omission ; end
tt = length(num_trial) ;
for i = 1:length(num_trial)
    num_trial{i}=num_trial{i}(end-1:end); end
%U=unique(num_trial);
U={'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48','49','50','51','52','53','54','55','56','57','58','59','60'}; 
a=cell2mat(num_trial);
b=cellfun(@(x) sum(ismember(num_trial,x)),U,'un',0);
pbmtrop={};
pbmmanq={};
for i = 1:length(U)
    if b{i}==1
        continue
    elseif b{i}==0
        pbmmanq{end+1}=U{i};
    else
        pbmtrop{end+1}=U{i};
    end ; end
        
disp(['Patient = ' Patients{p} '  n°' num2str(p) ' ' Cond ' : ' num2str(ng) ' Nogo parmi ' num2str(tt) ' essais'])
if ~isempty(pbmtrop) ; disp(['Essais Répétés : ' pbmtrop ]) ; end
if ~isempty(pbmmanq) ; disp(['Essais manqués : ' pbmmanq ]) ; end
end
end
    