function [filename_listOfFOG, Folder] = FOG_List(protocole)
%Count Number of FOG and return freezing trials
filename_listOfFOG = {};

[Patients, Folder, CondMed, ~] = MAGIC.Patients.All(protocole,0);
                                            
for p = 1:length(Patients)
    for condonofff = 1:length(CondMed) 
        Patient = Patients{p};   
        Cond = CondMed{condonofff};          
        Session = 'POSTOP';
    
        [Date, Type, num_trial, ~, ~, ~] = MAGIC.Patients.TrialList(Patient,Session,Cond,protocole);
        cd([Folder Patient]);
        if ~strcmp(Patient, 'REa') || strcmp(Cond, 'OFF')
            for nt = 1:length(num_trial) % Boucle num_trial
                filename = MAGIC.Patients.TrialName(Type, Date, Session , Patient , Cond , num_trial{nt} ,0) ;                
                h = btkReadAcquisition(filename);
                Ev = btkGetEvents(h);
                if isfield(Ev,'General_Start_FOG')                          
                    filename_listOfFOG{end+1} = filename ; %#ok<AGROW> 
                end
                if isfield(Ev, 'General_start_FOG') | isfield(Ev, 'General_start_Fog') | isfield(Ev, 'General_start_fog') | isfield(Ev, 'General_start_FoG') | isfield(Ev, 'General_Start_Fog') | isfield(Ev, 'General_Start_fog')| isfield(Ev, 'General_Start_FoG') | isfield(Ev, 'General_strat_FOG') | isfield(Ev, 'General_Strat_FOG') %#ok<OR2> 
                    fprintf(2, [filename 'has wrongly labelled FOG epochs'])
                end
            end
        end
    end
end


