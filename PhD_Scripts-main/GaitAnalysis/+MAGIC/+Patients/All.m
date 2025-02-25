function [List_of_Patients, Folder, CondMed, outputArg4, outputArg5, outputArg6, outputArg7 ] = All(Protocole,SwitchForFutureUpgrade)
%Return full list of patients


if isunix ;    startpath = "/network/iss/pf-marche" ;  feature('DefaultCharacterSet', 'CP1252')
elseif ispc ;  startpath = "\\iss\pf-marche"      ;  end


if strcmp(Protocole, 'MAGIC_LFP')
    fprintf(2, "AUGAL37 exclu, PHIJE39 exclu \n")
    List_of_Patients = {'DEp','FEp','ALb','GAl','SOh','VIj','SAs', ...
                        'GUG','FRJ','FRa',...
                        'BARGU14','DROCA16','DESJO20','BEm','COm','LOp','REa','GIs'} ;  
    Folder = [ char(fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','MAGIC','04_Traitement','01_POSTOP_Gait_data_MAGIC-GOGAIT','DATA')) filesep ] ;
    CondMed = {'OFF','ON'};

elseif strcmp(Protocole, 'MAGIC')
    fprintf(2, "AUGAL37 inclu, PHIJE39 exclu \n")
    List_of_Patients = {'AUGAL37', ... %'PHIJE39',...
                        'DEp','FEp','ALb','GAl','SOh','VIj','SAs', ...
                        'GUG','FRJ','FRa',...
                        'BARGU14','DROCA16','DESJO20','BEm','COm','LOp','REa','GIs'} ;  
    Folder = [ char(fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','MAGIC','04_Traitement','01_POSTOP_Gait_data_MAGIC-GOGAIT','DATA')) filesep ] ;
    CondMed = {'OFF','ON'};

elseif strcmp(Protocole, 'PPN_LFP')
    List_of_Patients = {'CHADO01','SOUDA02',} ;  
    Folder = [ char(fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','GAITPARK','EMGt0_POSTOP_')) ] ;
    CondMed = {'OFF','ON'};

elseif strcmp(Protocole, 'PPN_spon')
    List_of_Patients = {'CHADO01','SOUDA02','LESNE03', 'AVALA08'} ;  
    Folder = [ char(fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','GAITPARK','EMGt0_POSTOP_')) ] ;
    CondMed = {'OFF','ON'};

end



outputArg4 = 'SwitchForFutureUpgrade';
outputArg5 = 'SwitchForFutureUpgrade';
outputArg6 = 'SwitchForFutureUpgrade';
outputArg7 =  SwitchForFutureUpgrade ;
end

