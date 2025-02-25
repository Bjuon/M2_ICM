%% SCRIPT APA A EXCLURE

% Chargements

ResAPA_Load_file    = '\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MAGIC\04_Traitement\01_POSTOP_Gait_data_MAGIC-GOGAIT\DATA\ResAPA_extension_LINKERS_v3.xlsx';    
ResAPA_Export_file  = '\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MAGIC\04_Traitement\01_POSTOP_Gait_data_MAGIC-GOGAIT\DATA\ResAPA_extension_LINKERS_v3.xlsx';    
ExclusionListName   = '\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MAGIC\03_LOGS\APA_a_exclure.xlsx' ;  
protocole           = 'MAGIC_LFP' ;

Suppression_APA_des_Essais_Non_Valides                 = true ;
Validation_que_chaque_essai_est_bien_inclus_ou_exclus  = true ;
Essais_Particuliers                                    = true ; 



APA = readtable(ResAPA_Load_file,'Format','auto');    

%% SOh
for i = 1:length(APA.TrialName)
    for alpha = 1:9
        if strcmp(APA.TrialName(i),['ParkPitie_2020_10_08_SOh_MAGIC_POSTOP_OFF_GNG_GAIT_10' num2str(alpha)]) ; APA.TrialNum(i) = 100 + alpha ; end
    end
            if     strcmp(APA.TrialName(i),'ParkPitie_2020_10_08_SOh_MAGIC_POSTOP_OFF_GNG_GAIT_110')               ; APA.TrialNum(i) = 110 ;
            elseif strcmp(APA.TrialName(i),'ParkPitie_2020_10_08_SOh_MAGIC_POSTOP_OFF_GNG_GAIT_113')               ; APA.TrialNum(i) = 113 ;
            elseif strcmp(APA.TrialName(i),'ParkPitie_2020_10_08_SOh_MAGIC_POSTOP_OFF_GNG_GAIT_114')               ; APA.TrialNum(i) = 114 ;
            end
end


%% Suppr non OK
if Suppression_APA_des_Essais_Non_Valides

ExclusionList = readtable(ExclusionListName,'Format','auto');    
cntV=0;
cntrec=0;
cntVnotfound=0;
cntrecnotfound=0;
for ex_i = 1:length(ExclusionList.manuel)
    
    done = false ;
    if strcmp(ExclusionList.manuel(ex_i), 'v')
        
        
        apa_i=1;
        while any([ne(APA.TrialNum(apa_i),ExclusionList.Essai(ex_i)) , ~strcmp(APA.Subject(apa_i), ExclusionList.Sujet(ex_i)) , ~strcmp(APA.Condition(apa_i), ExclusionList.Condition(ex_i))])
        apa_i = apa_i+1;
                if apa_i == length (APA.TrialNum)
                    break
                end
        end
        
        if ~any([ne(APA.TrialNum(apa_i),ExclusionList.Essai(ex_i)) , ~strcmp(APA.Subject(apa_i), ExclusionList.Sujet(ex_i)) , ~strcmp(APA.Condition(apa_i), ExclusionList.Condition(ex_i))])
                APA.T0(apa_i)           = {NaN}  ;
                APA.t_Reaction(apa_i)   = {NaN}  ;
                APA.t_APA(apa_i)        = {NaN}  ;
                APA.APA_lateral(apa_i)  = {NaN}  ;
                APA.APA_antpost(apa_i)  = {NaN}  ;
                done                    = true   ;
                cntV = cntV + 1 ;
        end
        if ~done 
            cntVnotfound = cntVnotfound + 1 ;  
            disp(['Aucun APA : '   char(ExclusionList.Sujet(ex_i)) ' ' num2str(ExclusionList.Essai(ex_i)) ' ' char(ExclusionList.Condition(ex_i)) ])
        end

    elseif strcmp(ExclusionList.manuel(ex_i), 'rec')
        
        apa_i=1;
        while any([ne(APA.TrialNum(apa_i),ExclusionList.Essai(ex_i)) , ~strcmp(APA.Subject(apa_i), ExclusionList.Sujet(ex_i)) , ~strcmp(APA.Condition(apa_i), ExclusionList.Condition(ex_i))])
        apa_i = apa_i+1;
                if apa_i == length (APA.TrialNum)
                    break
                end
        end
        
        if ~any([ne(APA.TrialNum(apa_i),ExclusionList.Essai(ex_i)) , ~strcmp(APA.Subject(apa_i), ExclusionList.Sujet(ex_i)) , ~strcmp(APA.Condition(apa_i), ExclusionList.Condition(ex_i))])
                APA.T0(apa_i)           = {NaN}  ;
                APA.t_Reaction(apa_i)   = {NaN}  ;
                APA.t_APA(apa_i)        = {NaN}  ;
                APA.APA_lateral(apa_i)  = {NaN}  ;
                APA.APA_antpost(apa_i)  = {NaN}  ;
                done                    = true   ;
                cntrec = cntrec + 1 ;
                disp(['Found REC : '   char(ExclusionList.Sujet(ex_i)) ' ' num2str(ExclusionList.Essai(ex_i)) ' ' char(ExclusionList.Condition(ex_i)) ])
        end
        if ~done ; cntrecnotfound = cntrecnotfound + 1 ; end
    
    end       
end
end

%% Vérif des autres

if Validation_que_chaque_essai_est_bien_inclus_ou_exclus
    
    ValidationMatrix  = cell(length(APA.TrialNum),4) ;
    for i = 1 : length(APA.TrialNum)
        ValidationMatrix(i,1) = APA.Subject   (i)    ;
        ValidationMatrix(i,2) = APA.Condition (i)    ;
        ValidationMatrix(i,3) = num2cell(APA.TrialNum  (i))    ;
        ValidationMatrix(i,4) = num2cell(0)    ;
    end
    
% Patients = {'REa','GAl','FEp','DEp','FRa','ALb','FRJ','SOh','VIj','GUG','BARGU14','COm','BEm','DROCA16','GIs','LOp','DESJO20',};
% CondMed = {'OFF','ON'};
[Patients, Folder, CondMed, ~ ] = MAGIC.Patients.All(protocole,0);
cnt = 0;
for p = 1:length(Patients)
    for condonofff = 1:2
        Patient = Patients{p};
        Cond = CondMed{condonofff};
        Session = 'POSTOP';
        
        [Date, Type, num_trial, num_trial_NoGo_OK, num_trial_NoGo_Bad, num_trial_omission] = MAGIC.Patients.TrialList(Patient,Session,Cond,1);

        for nt = 1:length(num_trial)

            if strcmp(Type,'GOGAIT') || strcmp(Type,'GAITPARK')
                filename = [ Type '_'  Session '_'  Patient  '_'  Cond '_GNG_' num_trial{nt}(end-1:end) '.c3d'];
            else
                if strcmp(Patient,'GUG') || strcmp(Patient,'FRJ') || strcmp(Patient,'FRa')
                    filename = ['ParkRouen_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' num_trial{nt} '.c3d'];
                else
                    filename = ['ParkPitie_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' num_trial{nt} '.c3d'];
                end
            end

            apa_i=1;
            while ~strcmp(APA.TrialName(apa_i), filename(1:end-4))
                apa_i = apa_i+1;
                if apa_i == length (APA.TrialNum)
                    fprintf(2, ['Trial to keep not found : ' filename(1:end-4) '\n' ])
                    break
                end
            end

            for i = 1:length(ValidationMatrix)
                if all([strcmp(ValidationMatrix(i,1), Patient) , strcmp(ValidationMatrix(i,2), Cond) , ValidationMatrix{i,3} == str2num(num_trial{nt})])    %#ok<ST2NM> 
                    ValidationMatrix(i,4) = num2cell(1) ;
                end
            end
        end
    end
end

% ValidatedMatrix = sortrows(ValidationMatrix,4,'descend') ; 


for i = 1 : length(ValidationMatrix)
    if ValidationMatrix{i , 4} == 0
          idx_pat = find(strcmp(ValidationMatrix(i,1), APA.Subject)  ) ;
          idx_con = find(strcmp(ValidationMatrix(i,2), APA.Condition)) ;
          idx_num = find(ValidationMatrix{i,3} == APA.TrialNum       ) ;
          idx_tri = intersect(idx_pat, idx_con) ;
          idx_tri = intersect(idx_tri, idx_num) ;
          disp(['Non-Kept Trial : '  APA.TrialName{idx_tri}])
          APA(idx_tri, :) = [] ;
    end
end 
end


if Essais_Particuliers
    for i = 1:length(APA.TrialName)
        if     strcmp(APA.TrialName(i),'ParkPitie_2019_11_28_LOp_GBMOV_POSTOP_OFF_GNG_GAIT_050'); APA.GoNogo{i} = 'C' ;
        elseif strcmp(APA.TrialName(i),'ParkPitie_2019_11_28_LOp_GBMOV_POSTOP_ON_GNG_GAIT_010') ; APA.GoNogo{i} = 'I' ;
        elseif strcmp(APA.TrialName(i),'ParkPitie_2019_11_28_LOp_GBMOV_POSTOP_ON_GNG_GAIT_049') ; APA.GoNogo{i} = 'C' ;
        elseif strcmp(APA.TrialName(i),'ParkPitie_2019_11_28_LOp_GBMOV_POSTOP_ON_GNG_GAIT_050') ; APA.GoNogo{i} = 'C' ;
        elseif APA.TrialNum(i) >= 100 ;                                                           APA.GoNogo{i} = 'C' ;
        elseif APA.TrialNum(i) >= 110 ;                                                           APA.GoNogo{i} = 'I' ;
        end
    end
end

%% exclusion Bad NOGO et OMISSION

%% End
li2 = APA.Properties.VariableNames ;
APA = table2cell(APA) ;
APA = vertcat(li2,APA);
writecell(APA,ResAPA_Export_file, 'UseExcel', true) 
disp('Fichier Excel enregistré')

clear