filename = 'C:\Users\mathieu.yeche\Desktop\PERCEPT\P05\LFP\Report_Json_Session_Report_20231213T122826.json'   ;
Visual_inspection = true ;
recording = 0 ;

fprintf(2, "Mauvaise pratique ci dessous, remplacer par un excel \n")
if strcmp(filename, '\\l2export\iss02.pf-marche\01_rawdata\01_RawData\02_Donnees_LFP_Brutes\PERCEPT\P04_Percept\Report_Json_Session_Report_20231213T122659.json')   
    deltaTemporel_t0LFPentempsVICON = 24.37 ;
elseif strcmp(filename, '\\l2export\iss02.pf-marche\01_rawdata\01_RawData\02_Donnees_LFP_Brutes\PERCEPT\P04_Percept\Report_Json_Session_Report_20231213T122757.json')   
    deltaTemporel_t0LFPentempsVICON = 20.706 ;
elseif strcmp(filename, 'C:\Users\mathieu.yeche\Desktop\PERCEPT\P05\LFP\Report_Json_Session_Report_20231213T122826.json')   
    deltaTemporel_t0LFPentempsVICON = 30.47 ;
    fprintf(2, "Mauvais enregistrement \n")
end

[lfp,Peaks, CondStim] = PERCEPT.load.read_json(filename, recording, Visual_inspection) ;

fprintf(2, "todo \n")
%  Step_list{:,5} = selon le timing passerelle ou toit
%  puis calcul temps passerelle / toit moyenne glissante sur 10 essais
%  puis calcul distance en prenant la moyenne de tous les pts

% Chop LFP arround gait cycle events


%%% Simple event based analysis
tBlock = 0.5 ;
lfp_spec  = tfr(lfp,'method','chronux','tBlock',tBlock,'tStep',0.03,'f',[1 100],'tapers',[3 5],'pad',1);
tf_values = mean(lfp_spec.values{1,1}, 3) ;
Time_stamp = lfp_spec.times{1} - tBlock/2 + deltaTemporel_t0LFPentempsVICON - 0.015 ;  % 0.015 = temps LFP STN
Fs = lfp_spec.Fs ;

TF = lfp_spec.values{1, 1} ;
TF = mean(TF,3) ;
TF = TF(:,1:100)  ;
ExportFile = strrep(filename, '.json', '_LFP_transformed.parquet');
parquetwrite(ExportFile,  array2table(TF));
TimeName   = strrep(filename, '.json', '_LFP_timing.csv');
csvwrite(TimeName, Time_stamp);
