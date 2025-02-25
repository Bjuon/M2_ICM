function dataFrameEMG = dataFrameCreation(powerspectraEMG,envelopeEMGn_resampled,ntOK,PatientName,ConditionState)

timevec = round(-0.98:1/(1/3*100):1.52, 2); % created to match the time vecor of the LFP data
timevec_string = string(timevec);
timevec_string = strcat(timevec_string, "0") ;
timevec_string(67) = "1.0" ;

emg_labels = fieldnames(envelopeEMGn_resampled{1});
neworder = [6 4 5 3 1 2];

muscle_names = {'Vastus','Tibialis','Soleus','Vastus','Tibialis','Soleus'};
muscle_sides = {'L','L','L','R','R','R'};

% Inizialization of the table
Patient = '';   Condition = []; 
GoNogo  = '';   TrialNum  = [];
Muscle  = '';   EMG_Side =  '';
AlphaEMG = [];  BetaEMG = [];   EMG = [];


for nt = 1:length(envelopeEMGn_resampled)
    for nemg = 1:length(emg_labels)
        
        Patient = [Patient; {PatientName}];         Condition = [Condition; ConditionState(nt)];
        TrialNum = [TrialNum; ntOK(nt)];
        Muscle = [Muscle; {muscle_names{nemg}}];      EMG_Side = [EMG_Side; {muscle_sides{nemg}}];
        
        AlphaEMG = [AlphaEMG; powerspectraEMG{nt}.alphaPower.(emg_labels{neworder(nemg)})];  
        BetaEMG = [BetaEMG; powerspectraEMG{nt}.betaPower.(emg_labels{neworder(nemg)})];

        EMG = [EMG; envelopeEMGn_resampled{nt}.(emg_labels{neworder(nemg)})'];

    end

end

tableTD = array2table(EMG, "VariableNames",timevec_string);
tableFD = table(Patient, Condition, TrialNum, Muscle, EMG_Side, AlphaEMG, BetaEMG);

dataFrameEMG = [tableFD, tableTD];


