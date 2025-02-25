

% 1 Position intermediaire
filename = 'C:\Users\mathieu.yeche\Desktop\test_05_06_2024\test_10_06_202402_Emg_trigger_IR01.c3d';
h = btkReadAcquisition(filename);
EMG = btkGetAnalog(h, 'Voltage.RVAS') ;
Trg = btkGetAnalog(h, 'Voltage.GO') ;
LED = btkGetMarkersValues(h) ;
LED = LED(:,1) ;

tC = 0:length(LED)-1;
tC = tC / btkGetPointFrequency(h) ;
tE = 0:length(EMG)-1;
tE = tE / btkGetAnalogFrequency(h) ;

EMG = normalize(EMG, "range");
Trg = normalize(Trg, "range");
LED = normalize(LED, "range");

figure
plot(tC,LED)
hold on
plot(tE,EMG)
plot(tE,Trg)
legend('LED','EMG','Trigger')
xlabel('Time (s)')
ylabel('Voltage (V)')
title('EMG synchro check')
hold off


% 2 Position lointaine
filename = 'C:\Users\mathieu.yeche\Desktop\test_05_06_2024\test_10_06_202402_Emg_trigger_IR02.c3d';
h = btkReadAcquisition(filename);
length(btkGetMarkers(h)) == 1 % check 
EMG = btkGetAnalog(h, 'Voltage.RVAS') ;
Trg = btkGetAnalog(h, 'Voltage.GO') ;
LED = btkGetMarkersValues(h) ;
LED = LED(:,1) ;

tC = 0:length(LED)-1;
tC = tC / btkGetPointFrequency(h) ;
tE = 0:length(EMG)-1;
tE = tE / btkGetAnalogFrequency(h) ;

EMG = normalize(EMG, "range");
Trg = normalize(Trg, "range");
LED = normalize(LED, "range");

figure
plot(tC,LED)
hold on
plot(tE,EMG)
plot(tE,Trg)
legend('LED','EMG','Trigger')
xlabel('Time (s)')
ylabel('Voltage (V)')
title('EMG synchro check')
hold off

% 3 Sur la table
filename = 'C:\Users\mathieu.yeche\Desktop\test_05_06_2024\test_10_06_202402_Emg_trigger_IR03.c3d';
h = btkReadAcquisition(filename);
length(btkGetMarkers(h)) == 1 % check 
EMG = btkGetAnalog(h, 'Voltage.RVAS') ;
Trg = btkGetAnalog(h, 'Voltage.GO') ;

tE = 0:length(EMG)-1;
tE = tE / btkGetAnalogFrequency(h) ;

EMG = normalize(EMG, "range");
Trg = normalize(Trg, "range");

figure
hold on
plot(tE,EMG)
plot(tE,Trg)
legend('EMG','Trigger')
xlabel('Time (s)')
ylabel('Voltage (V)')
title('EMG synchro check')
hold off

% Export en CSV
filename = 'C:\Users\mathieu.yeche\Desktop\test_05_06_2024\test_10_06_202402_Emg_trigger_IR02.c3d';
h = btkReadAcquisition(filename);
EMG = btkGetAnalog(h, 'Voltage.RVAS') ;
Trg = btkGetAnalog(h, 'Voltage.GO') ;
LED = btkGetMarkersValues(h) ;
LED = LED(:,1) ;
tC = 0:length(LED)-1;
tC = tC / btkGetPointFrequency(h) ;
tE = 0:length(EMG)-1;
tE = tE / btkGetAnalogFrequency(h) ;
Export = [tE' EMG Trg ]; 
Exportbis = [tC' LED];