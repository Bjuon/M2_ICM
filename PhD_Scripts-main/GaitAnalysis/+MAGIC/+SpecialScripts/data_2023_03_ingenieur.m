
filename = 'Z:\DATA\FEp\ParkPitie_2020_02_20_FEp_MAGIC_POSTOP_OFF_GNG_GAIT_004.c3d'


h = btkReadAcquisition(filename);

Events = btkGetEvents(h)
EMG = btkGetAnalogs(h)
Fa = btkGetAnalogFrequency(h)


n = fieldnames(EMG)

Trial = struct()


Trial.EMG_RTA = EMG.Voltage_RTA ;
Trial.EMG_RSOL = EMG.Voltage_RSOL ;
Trial.EMG_RVAS = EMG.Voltage_RVAS ;
Trial.EMG_LTA = EMG.Voltage_LTA ;
Trial.EMG_LSOL = EMG.Voltage_LSOL ;
Trial.EMG_LVAS = EMG.Voltage_LVAS ;

Trial.LFP = LFPtrial4 ;

Trial.Events = Events ;




clearvars

Trialtxt = jsonencode(Trial,"PrettyPrint",true) ;
file = fopen(fullfile('C:\Users\mathieu.yeche\Downloads\Temp(a suppr)', 'FEP_OFF_4.json' ), 'w');
                fprintf(file, '%s', Trialtxt);
fclose(file);









