clear all; clc; close all;

%% 1) Choisir le protocole 

[~, Folder, CondMed, ~]  = MAGIC.Patients.All('PPN_LFP',0);

%% 2) Choisir le patient problematique et indiquer le patern à rechercher
Patients = {'SOUDA02'};
Bad_Subject = 'SOUDA02';  %Recherche du pattern non encore implementé
Replacement_Subject = ''; 

                                            
for condonofff = 1:length(CondMed)
    Patient = Patients{1};
    Cond = CondMed{condonofff};
    Session = 'POSTOP';

    [Date, Type, num_trial, num_trial_NoGo_OK, num_trial_NoGo_Bad, num_trial_omission] = MAGIC.Patients.TrialList(Patient,Session,Cond,1);


    for nt = 1:length(num_trial) % Boucle num_trial


        [filename,~] = MAGIC.Patients.TrialName(Type, Date, Session , Patient , Cond , num_trial{nt} ,0) ;
        h= btkReadAcquisition(fullfile([Folder Patient ],filename));
        Ev = btkGetEvents(h); % chargement des évènements temporels
        
        for i = 1:btkGetEventNumber(h)
            btkSetEventSubject(h, i, Replacement_Subject) ; 
        end
    btkWriteAcquisition(h, fullfile([Folder Patient],filename))
    disp(['Trial modified: ' filename ])
    end
end
disp(['END'])