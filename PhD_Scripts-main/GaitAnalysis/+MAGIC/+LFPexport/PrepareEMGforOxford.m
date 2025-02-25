
clear all; clc; close all                    %#ok<CLALL> 
cpt = 0 ; 

fprintf(2, 'WARNING: This script does NOT account for the 15ms lag in EMG\n')
ExitFolder = 'C:\Users\mathieu.yeche\Downloads' ;
Todo_NoGO = 0 ; % 0 = GO, 1 = NoGO

[Patients, Folder, CondMed, ~]  = MAGIC.Patients.All('MAGIC_LFP',0);

disp(['Nombre de patients : '  num2str(length(Patients))])
  
names    = {} ;
out_RTA  = [] ;
out_RSOL = [] ;
out_RVAS = [] ;
out_LTA  = [] ;
out_LSOL = [] ;
out_LVAS = [] ;

for p = 1:length(Patients)
    Patient = Patients{p};   
    if strcmp(Patient, 'FRa') 
        continue
    end
    Cond = "OFF";          
    Session = 'POSTOP';
    
    [Date, Type, num_trial, num_trial_NoGo_OK, num_trial_NoGo_Bad, num_trial_omission] = MAGIC.Patients.TrialList(Patient,Session,Cond,1);
    disp([Patients{p} '  n°' num2str(p) ' ' Cond ])

    if Todo_NoGO == 1 ;  num_trial = num_trial_NoGo_OK ;  end
    for nt = 1:length(num_trial) % Boucle num_trial

        [filename,~] = MAGIC.Patients.TrialName(Type, Date, Session , Patient , Cond , num_trial{nt} , 0);
        h = btkReadAcquisition([Folder Patient filesep filename]);

        Fa  = btkGetAnalogFrequency(h)   ;
        if Fa ~= 1000; error([Patient 'Frequence d''acquisition non conforme : ' num2str(Fa)]) ; end
        
        if strcmp(Patient, 'GUG')
            RTA  = btkGetAnalog(h, 'Voltage.EMG 1');
            RSOL = btkGetAnalog(h, 'Voltage.EMG 2');
            RVAS = btkGetAnalog(h, 'Voltage.EMG 3');
            LTA  = btkGetAnalog(h, 'Voltage.EMG 4');
            LSOL = btkGetAnalog(h, 'Voltage.EMG 5');
            LVAS = btkGetAnalog(h, 'Voltage.EMG 6');
        else
            RTA  = btkGetAnalog(h, 'Voltage.RTA');
            RSOL = btkGetAnalog(h, 'Voltage.RSOL');
            RVAS = btkGetAnalog(h, 'Voltage.RVAS');
            LTA  = btkGetAnalog(h, 'Voltage.LTA');
            LSOL = btkGetAnalog(h, 'Voltage.LSOL');
            LVAS = btkGetAnalog(h, 'Voltage.LVAS');
        end

        names{end+1} = filename ;                       %#ok<*SAGROW> 
        out_RTA(1, end+1) = string(filename) ;
        out_RTA(2:(length(RTA)+1), end) = RTA ;
        out_RSOL(1, end+1) = string(filename) ;
        out_RSOL(2:(length(RSOL)+1), end) = RSOL ;
        out_RVAS(1, end+1) = string(filename) ;
        out_RVAS(2:(length(RVAS)+1), end) = RVAS ;
        out_LTA(1, end+1) = string(filename) ;
        out_LTA(2:(length(LTA)+1), end) = LTA ;
        out_LSOL(1, end+1) = string(filename) ;
        out_LSOL(2:(length(LSOL)+1), end) = LSOL ;
        out_LVAS(1, end+1) = string(filename) ;
        out_LVAS(2:(length(LVAS)+1), end) = LVAS ;

        btkDeleteAcquisition(h);
    end
end


% ___Save_____________________________________________________________________
namestart = [ExitFolder filesep 'MAGIC_EMG_'];
if Todo_NoGO == 1; namestart = [namestart 'No'];end
save([namestart 'GO_RTA.mat'],'out_RTA')
save([namestart 'GO_RSOL.mat'],'out_RSOL')
save([namestart 'GO_RVAS.mat'],'out_RVAS')
save([namestart 'GO_LTA.mat'],'out_LTA')
save([namestart 'GO_LSOL.mat'],'out_LSOL')
save([namestart 'GO_LVAS.mat'],'out_LVAS')

writematrix(out_RTA, [namestart 'GO_RTA.csv'])
writematrix(out_RSOL, [namestart 'GO_RSOL.csv'])
writematrix(out_RVAS, [namestart 'GO_RVAS.csv'])
writematrix(out_LTA, [namestart 'GO_LTA.csv'])
writematrix(out_LSOL, [namestart 'GO_LSOL.csv'])
writematrix(out_LVAS, [namestart 'GO_LVAS.csv'])

save([namestart 'GO_trialnames.mat'],'names')
writecell(names, [namestart 'GO_trialnames.csv'])

namestring = char(names{1}) ;
for i = 2:length(names);  namestring = [namestring ',' char(names{i}) ] ;end                      %#ok<*AGROW> 
clipboard("copy", namestring)
disp('Noms des fichiers copiés dans le presse-papier')

namedRTA = fileread([namestart 'GO_RTA.csv']);
namedRTA = [namestring newline namedRTA];
fid = fopen([namestart 'GO_RTA.csv'], 'w');
fprintf(fid, '%s', namedRTA); fclose(fid);

namedRSOL = fileread([namestart 'GO_RSOL.csv']);
namedRSOL = [namestring newline namedRSOL];
fid = fopen([namestart 'GO_RSOL.csv'], 'w');
fprintf(fid, '%s', namedRSOL); fclose(fid);

namedRVAS = fileread([namestart 'GO_RVAS.csv']);
namedRVAS = [namestring newline namedRVAS];
fid = fopen([namestart 'GO_RVAS.csv'], 'w');
fprintf(fid, '%s', namedRVAS); fclose(fid);

namedLTA = fileread([namestart 'GO_LTA.csv']);
namedLTA = [namestring newline namedLTA];
fid = fopen([namestart 'GO_LTA.csv'], 'w');
fprintf(fid, '%s', namedLTA); fclose(fid);

namedLSOL = fileread([namestart 'GO_LSOL.csv']);
namedLSOL = [namestring newline namedLSOL];
fid = fopen([namestart 'GO_LSOL.csv'], 'w');
fprintf(fid, '%s', namedLSOL); fclose(fid);

namedLVAS = fileread([namestart 'GO_LVAS.csv']);
namedLVAS = [namestring newline namedLVAS];
fid = fopen([namestart 'GO_LVAS.csv'], 'w');
fprintf(fid, '%s', namedLVAS); fclose(fid);
