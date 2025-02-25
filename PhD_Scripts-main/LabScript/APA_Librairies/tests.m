Data = lire_donnees_c3d('MR_YO 1.c3d');
h = btkReadAcquisition('MR_YO 1.c3d');
% srv = btkEmulateC3Dserver();
% srv.Open('Marche_normale 1_trimmed.c3d',3);
%% Extraction des evts
evts_times = sort(btkGetEventsValues(h));

SwHO_index = evts_times(1)*Fech;
SwTO_index = evts_times(2)*Fech;
SwHS_index = evts_times(3)*Fech;
StTO_index = evts_times(4)*Fech;

%% Extraction des données analogiques
Fech = btkGetAnalogFrequency(h);
GRW = btkGetGroundReactionWrenches(h);
Gain_EMG = 10000;
EMgs_noms = Data.EMG.nom;
EMGs = extraire_emgs(Data,EMgs_noms')*Gain_EMG;
% EMGs_traite = TraitementEMG(EMGs,Fech);

channels = length(EMgs_noms);
for i=1:channels
    subplot(channels,2,2*i-1);
    plot(abs(EMGs(:,i)));
    subplot(channels,2,2*i);
    plot(EMGs_traite(:,i));
end
    

COP_ML = GRW.P(1:SwTO_index,1);
COP_AP = GRW.P(:,2);

t_analog = 0:1/Fech:length(COP_ML)/Fech-1/Fech;

%% Extraction des données cinématiques
Freq_vid = btkGetPointFrequency(h);
CG = btkGetPoint(h,'CentreOfMass');
Talon_D = btkGetPoint(h,'RHEE');
Talon_G = btkGetPoint(h,'LHEE');
Orteil_D = btkGetPoint(h,'RTOE');
Orteil_G = btkGetPoint(h,'LTOE');

%% TRaitement EMG
TA_D = EMGs(:,1);
Sol_D = EMGs(:,4);
TA_G = EMGs(:,2);
Sol_G = EMGs(:,3);

col = [TA_D Sol_D TA_G Sol_G];

figure
Offset =  20;
for i=1:4
    plot(col(:,i) - (i-1)*Offset);
    hold on
end

figure
for i=1:4
    x = col(:,i);        
    x = x - nanmean(x);
    x(isnan(x))=0;
%     y = filtrage(x,'b',2,50,Fech);
    y = TraitementEMG(x,Fech);
    fcol(:,i)=y;
    plot(fcol(:,i) - (i-1)*Offset);
    hold on
end

filterd_data = fcol;

% Redressement
data_redressee=abs(filterd_data);

% Detection automatique des pics des Soléaires

% Calcul CG
V_CG = calcul_vitesse_CG_v2(Data.actmec(:,7:9),Freq_vid,Data,1);

% Calcul T0
CP=Data.actmec(:,1:2);
CP_filt = filtrage(CP(1:evts_times(1)*100,:),'fir',30,8,100);
t = [1/100:1/100:evts_times(1)];
calcul_APA_T0(CP_filt)
% T0=calcul_APA_T0_v1(CP_filt,t)
% T0=calcul_APA_T0_v2(CP_filt,t)
[T0 indT0]=calcul_APA_T0_v3(CP_filt,t)

%
Donnes=pretraitement_dataAPA('Marche_normale 1_trimmed.c3d')
COP_ML_filt = filtrage(COP_ML,'fir',30,8,Fech);
[K KK] = trouve_APAy(COP_ML_filt)


%Extraction .mat NOTOCORD
[files dossier] = uigetfile('*.mat','Choix du/des fichier(s) mat','Multiselect','on');
[Sujet Resultats] = extraction_dataAPA_Notocord_v3(files,dossier(1:end-1));
ecrireAPA_xls_Claire(Resultats,'test.xls',cd);