
%% Parameters 
% Load
Projet = 'hQ_Spectrum' ;
Type_of_Spectrum = 'detail' ; % 'detail' or 'raw'
Normalisation = 'brut' ;  % 'brut' or 'AUC100'
ExportToR = false;
contact_to_use = 'HighestBeta' ; % 'HighestBeta' or 'ClinicalContact'

% Figure specific
colON  = [0.1412 0.7490 0.6471] ;
colOFF = [0.1412 0.6745 0.9490] ;
colON  = [.8     0      0     ] ;
colOFF = [0      0      .8    ] ;
colONalpha  = [colON    .05   ] ;
colOFFalpha = [colOFF   .05   ] ;
hsv = rgb2hsv(colON) ; hsv(:, 3) = hsv(:, 3) * 1.2;  colONpale  = hsv2rgb(hsv);
hsv = rgb2hsv(colOFF); hsv(:, 3) = hsv(:, 3) * 1.05; colOFFpale = hsv2rgb(hsv);


% Choose Beta
StartAlpha = 8    ;
StartBeta = 12    ;
MidBeta   = 20    ;
EndBeta   = 35    ;
StartGamma= 65    ;
EndGamma  = 85    ;

% Peak Parameters
PicOrBand = 'Pic' ;
PeakWidth = 3     ; % en Hz
PeakProminance = 5; % Parametre du choix des pics 
CategAndMore = '+'; % '+' for >= or 'only' for ==
PeakBand = 'LowB' ; % 'LowB' , 'HighB' , 'FTGamma' , 'Alpha' , 'HFO'
AutoManuel = 'Manuel' ;
SheetPeakXlsx = 'AllCh' ; % AllCh or HighestBetaCh
PeakTable = readtable('C:\LustreSync\hypoQAMPPE\PeakDetection.xlsx','Sheet',SheetPeakXlsx) ; % table contenant les valeurs manuelles
if strcmp(CategAndMore, '+') && PeakProminance == 4
    PeakTable(PeakTable > 4) = 4;
elseif strcmp(CategAndMore, '+') && PeakProminance == 1
    PeakTable(PeakTable < 1) = 1;
end


% Input data
PtFq = 1/100      ; % Point frequency of PSD 
plotsPt = '100'   ; % 100 or 10k or 10kfilt

% Comparaisons
VariableToCompare = 'OFF' ; % 'OFF', 'ON' or 'delta'
Timing_to_Use = 'pre' ; % 'pre', 'OffPreOnStim' 'OffPreBestOn' or 'WorseOffBestOn'
U3bilat = 'bilat' ; % 'bilat' if you want to use normal UPDRS-III (bilateral) instead of 'hemibody' for the Left / Right hemibody one
PlotSaveFolder = 'C:\LustreSync\hypoQAMPPE\Figures\Article' ;
Method = 'FDR' ;  % 'Holm' , 'FDR', 'Storey' or 'NoCorrection'
ClinicalFileToUse = 'Fusion' ; % 'New' (MY from Evinaa) or 'Old' (Brian) or Fusion
PlotPage = false ;

suffix = [Type_of_Spectrum '_Norm=' Normalisation '_' contact_to_use '_MultComp=' Method '_Resolution=' plotsPt '_ClinVar=' VariableToCompare '+' Timing_to_Use '+' U3bilat '_Peak=' num2str(PeakWidth) 'Hz-Thresh' num2str(PeakProminance) CategAndMore] ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Preprocessing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% View detail in hqSpectrum
[ClinicalData, OFF_list, ON_list] = hypoQAMPPE.load.LoadList(Projet) ;
[NameAndNum] = hypoQAMPPE.functions.MatchingTable(OFF_list,ON_list,ClinicalData,contact_to_use, ClinicalFileToUse, U3bilat,StartBeta,EndBeta,PicOrBand,Type_of_Spectrum, Timing_to_Use) ;
OFF_list = hypoQAMPPE.functions.SpectrumNormalisation(Normalisation,OFF_list) ;
ON_list  = hypoQAMPPE.functions.SpectrumNormalisation(Normalisation,ON_list ) ;
[BestChanTableOFF, BestChanTableON, BestChanTableDlt, MeanChanTableOFF, MeanChanTableON, MeanChanTableDlt, patOFF, patON, LeftRightOFF, LeftRightON] = hypoQAMPPE.functions.ExtractPSDofInterest(NameAndNum,ExportToR,Type_of_Spectrum,PtFq,OFF_list, ON_list, PlotSaveFolder, Normalisation) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIGURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Figure 1 : Localisations
% Ok

%% Figure 2a : Procedés
% To do for raw-brut + detail-brut + bsl + detail-AUC
for freq = 1:round(100/PtFq)
    meanOFF(freq) = mean(cell2mat(BestChanTableOFF(freq,:))) ;
    meanON(freq)  = mean(cell2mat(BestChanTableON(freq,:)))  ;
    sdOFF(freq)   = std(cell2mat(BestChanTableOFF(freq,:)))  ;
    sdON(freq)    = std(cell2mat(BestChanTableON(freq,:)))   ;
end
freqList      = 0:PtFq:(100-PtFq) ;
figure  ;
hold on ;
for el = 1:size(BestChanTableOFF,2)
   % plot(freqList, cell2mat(BestChanTableOFF(1:round(100/PtFq),el)), 'DisplayName','no legend', LineWidth=0.05, Color=colOFFalpha)
end
for el = 1:size(BestChanTableON,2)
   % plot(freqList, cell2mat(BestChanTableON( 1:round(100/PtFq),el)), 'DisplayName','no legend', LineWidth=0.05, Color=colONalpha)
end
rectangle('Position',[0,0,100,1.5*max(meanOFF(10/PtFq:35/PtFq))],'FaceColor',[1 1 1 0.33],'EdgeColor','none');
d1 = designfilt('lowpassiir','FilterOrder',12, 'HalfPowerFrequency',0.02,'DesignMethod','butter');
plot(    freqList, meanOFF,             'DisplayName','no legend', LineWidth=0.5, Color=colOFF)
plot(    freqList, meanON ,             'DisplayName','no legend', LineWidth=0.5, Color=colON)
if ~strcmp('base', Type_of_Spectrum)
    plot(freqList, filtfilt(d1, meanOFF), 'DisplayName','OFF-DOPA' , LineWidth=1.5, Color=colOFF)
    plot(freqList, filtfilt(d1, meanON ), 'DisplayName','ON-DOPA'  , LineWidth=1.5, Color=colON)
else
    plot(freqList, meanOFF,             'DisplayName','OFF-DOPA', LineWidth=1.5, Color=colOFF)
    plot(freqList, meanON ,             'DisplayName','ON-DOPA',  LineWidth=1.5, Color=colON)
end
% plot(freqList, filtfilt(d1, meanOFF-meanON), 'DisplayName','OFF-DOPA' , LineWidth=1.5, Color='g')
%fill([freqList, fliplr(freqList)], [ meanOFF-sdOFF , fliplr(meanOFF+sdOFF) ] , 'r' )
axis([7 40 0 1.5*max(meanOFF(10/PtFq:35/PtFq))])
set_leg_off = findobj('DisplayName','no legend');
for k = 1:numel(set_leg_off)
    set_leg_off(k).Annotation.LegendInformation.IconDisplayStyle = 'off';
end
title('Best Channel')
legend show
xlim([3 100])
saveas(gcf, fullfile(PlotSaveFolder, ['2A_' suffix '.svg']), 'svg')
saveas(gcf, fullfile(PlotSaveFolder, ['2A_' suffix '.png']), 'png')
saveas(gcf, fullfile(PlotSaveFolder, ['2A_' suffix '.fig']), 'fig')


figure  ;
hold on ;
d1 = designfilt('lowpassiir','FilterOrder',12, 'HalfPowerFrequency',0.02,'DesignMethod','butter');
plot(    freqList, sdOFF,             'DisplayName','no legend', LineWidth=0.5, Color=colOFF)
plot(    freqList, sdON ,             'DisplayName','no legend', LineWidth=0.5, Color=colON)
if ~strcmp('base', Type_of_Spectrum)
    plot(freqList, filtfilt(d1, sdOFF), 'DisplayName','OFF-DOPA' , LineWidth=1.5, Color=colOFF)
    plot(freqList, filtfilt(d1, sdON ), 'DisplayName','ON-DOPA'  , LineWidth=1.5, Color=colON)
else
    plot(freqList, sdOFF,             'DisplayName','OFF-DOPA', LineWidth=1.5, Color=colOFF)
    plot(freqList, sdON ,             'DisplayName','ON-DOPA',  LineWidth=1.5, Color=colON)
end
axis([7 40 0 1.5*max(meanOFF(10/PtFq:35/PtFq))])
set_leg_off = findobj('DisplayName','no legend');
for k = 1:numel(set_leg_off) ; set_leg_off(k).Annotation.LegendInformation.IconDisplayStyle = 'off'; end
title('SD')
legend show
xlim([3 100])
saveas(gcf, fullfile(PlotSaveFolder, ['2A_SD_' suffix '.svg']), 'svg')
saveas(gcf, fullfile(PlotSaveFolder, ['2A_SD_' suffix '.png']), 'png')
saveas(gcf, fullfile(PlotSaveFolder, ['2A_SD_' suffix '.fig']), 'fig')

%% Figure 2b : Meilleur patient

%% Figure 2c : relation entre highest beta et clinical contact
% Visualize data : Voir "Donnees Patients Parkinsoniens.xlsx" sheet correl e- ~ HB 
% Stankey diagram : https://fr.mathworks.com/matlabcentral/fileexchange/128679-sankey-plot
addpath('C:\Users\mathieu.yeche\Documents\Toolbox\sankey plot\sankey plot')
linksLeft ={'01','1',3;'01','2',8;'01','2-3',1;'01','3',4; 
            '12','1',7;'12','2',7;'12','2-3',2;'12','3',4;
            '23','1',3;'23','2',6;'23','2-3',2;'23','3',2;};
linksLeft = flipud(linksLeft);
            
linksDroit={'23','3',2;'23','2-3',0; '23','2',6;'23','1-2',0;'23','1',1;
            '12','3',5;'12','2',13;'12','1-2',1;'12','1',2;
            '01','3',4;'01','2-3',1;'01','2',15;'01','1',1;};

% Right
figure('Name','RightContact','Units','normalized','Position',[.05,.2,.5,.56])
SK=SSankey(linksDroit(:,1),linksDroit(:,2),linksDroit(:,3));
SK.RenderingMethod='interp';  
SK.Align='center';
SK.LabelLocation='left';
SK.Sep=0;
SK.ColorList=[254, 95, 85 ; 254, 163, 82 ; 254, 194, 82 ;
    133, 131, 201 ; 131, 158, 201 ; 129, 173, 200 ; 131, 191, 201 ; 131, 201, 152 ]./255;
SK.draw()
saveas(gcf, fullfile(PlotSaveFolder, ['2C_Droit_' suffix '.svg']), 'svg')
saveas(gcf, fullfile(PlotSaveFolder, ['2C_Droit_' suffix '.png']), 'png')
saveas(gcf, fullfile(PlotSaveFolder, ['2C_Droit_' suffix '.fig']), 'fig')

% Left
figure('Name','LeftContact','Units','normalized','Position',[.05,.2,.5,.56])
SK=SSankey(linksLeft(:,1),linksLeft(:,2),linksLeft(:,3));
SK.RenderingMethod='interp';  
SK.Align='center';
SK.LabelLocation='left';
SK.Sep=0;
SK.ColorList=[254, 95, 85 ; 254, 163, 82 ; 254, 194, 82 ;
    133, 131, 201 ; 129, 173, 200 ; 131, 191, 201 ; 131, 201, 152 ]./255;
SK.draw()
saveas(gcf, fullfile(PlotSaveFolder, ['2C_Left_' suffix '.svg']), 'svg')
saveas(gcf, fullfile(PlotSaveFolder, ['2C_Left_' suffix '.png']), 'png')
saveas(gcf, fullfile(PlotSaveFolder, ['2C_Left_' suffix '.fig']), 'fig')
close all

%% Figure 2d : Clinique en fct de la concordance physio-clinique
dU3concord = [] ;
dU3con1hem = [] ;
dU3discord = [] ;
[~, localHighestBetaId] = hypoQAMPPE.functions.HighBetaContact(OFF_list,StartBeta,EndBeta,PicOrBand,Type_of_Spectrum) ;
CCmatrix = hypoQAMPPE.load.ClinicalContacts(ClinicalData.Old); 
for ipat = 1:length(OFF_list)
    localClinicId(ipat,1) = table2cell(CCmatrix(strcmp(CCmatrix{:,1},OFF_list{1, ipat}.input(1:5)),2)) ;
    localClinicId(ipat,2) = table2cell(CCmatrix(strcmp(CCmatrix{:,1},OFF_list{1, ipat}.input(1:5)),3)) ;
    localClinicId(ipat,2) = {localClinicId{ipat,2} + 3} ;
end

for ipat = 1:length(localClinicId)
    conc = 0 ;
    if ceil(round(localClinicId{ipat,1}, 2)) == localHighestBetaId{ipat,1} || floor(round(localClinicId{ipat,1}, 2)) == localHighestBetaId{ipat,1}
        conc = conc + 1 ;
    end
    if ceil(round(localClinicId{ipat,2}, 2)) == localHighestBetaId{ipat,2} || floor(round(localClinicId{ipat,2}, 2)) == localHighestBetaId{ipat,2}
        conc = conc + 1 ;
    end
    if conc == 2
        dU3concord(end+1) = NameAndNum{ipat,8} - NameAndNum{ipat,9} ;
    elseif conc == 0 
        dU3discord(end+1) = NameAndNum{ipat,8} - NameAndNum{ipat,9} ;
    elseif conc == 1
        dU3con1hem(end+1) = NameAndNum{ipat,8} - NameAndNum{ipat,9} ;
    end
end
% Boxplot
figure  ;
hold on ;
dU3concord = padarray(dU3concord, [0 length(dU3con1hem)-length(dU3concord)], NaN, 'post') ;
dU3discord = padarray(dU3discord, [0 length(dU3con1hem)-length(dU3discord)], NaN, 'post') ;
boxplot([dU3concord' dU3con1hem' dU3discord'], 'Labels', {'Concordant', '1 Hemisphere', 'Discordant'})
ylabel('Delta UPDRS-III')
saveas(gcf, fullfile(PlotSaveFolder, ['2D_' suffix '.png']), 'png')
anova1([dU3concord' dU3con1hem' dU3discord'])


%% Figure 3a : Correlation globale raw brut (cf b avec ≠ parametres)
%% Figure 3b : Correlation globale detail AUC
rho = [] ;
pval = [] ;
UPDRSdeltaList = [] ;
freq_listPval = [] ;
freq_listRho= [];
advance = true ;
IClow = [] ; 
IChigh = [] ;
% Clinical Data
for pat = 1:length(patON)
    UPDRSdeltaList(pat) = NameAndNum{strcmp(patON(pat), NameAndNum(:, 1)),8+LeftRightON(pat)} - NameAndNum{strcmp(patON(pat), NameAndNum(:, 1)),9+LeftRightON(pat)} ;
end
goodlist = ~isnan(UPDRSdeltaList) ;
UPDRSdeltaList = UPDRSdeltaList(goodlist) ;
% Ephy data
for freq = 1:100
    PSDValueList = mean(cell2mat(BestChanTableDlt( (freq/PtFq-0.5/PtFq):(freq/PtFq+0.5/PtFq) , :)),1) ;
    PSDValueList = PSDValueList(goodlist) ;
    [rho(freq) , pval(freq)] = corr(PSDValueList', UPDRSdeltaList', 'Type', 'Spearman') ;
    freq_listRho(freq) = freq;
    if freq == 20 || freq == 74
        figure  ;
        corrplot([PSDValueList', UPDRSdeltaList'],'var',{'Power', 'UPDRS'})
        saveas(gcf, fullfile(PlotSaveFolder, ['3AB_freq=' num2str(freq) '_' suffix '.svg']), 'svg')
        saveas(gcf, fullfile(PlotSaveFolder, ['3AB_freq=' num2str(freq) '_' suffix '.png']), 'png')
        saveas(gcf, fullfile(PlotSaveFolder, ['3AB_freq=' num2str(freq) '_' suffix '.fig']), 'fig')
    end
    if advance
        inipv = pval(freq) ;
        pval(freq) = hypoQAMPPE.functions.MonteCarloPermTest(PSDValueList,UPDRSdeltaList,10000) ;
        if abs(inipv - pval(freq)) > 0.03 ; disp(['freq ' num2str(freq) ' : ' num2str(inipv) ' -> ' num2str(pval(freq))]) ; end
        [IClow(freq), IChigh(freq)] = hypoQAMPPE.functions.Bootstrap(PSDValueList,UPDRSdeltaList,5000,0.95) ;
    end
end
%Pval correction
pvalBeta = pval(12:30);
pvalGamm = pval(65:85);
pvalBeta = hypoQAMPPE.functions.correction_pval(pvalBeta,Method,plotsPt);
pvalGamm = hypoQAMPPE.functions.correction_pval(pvalGamm,Method,plotsPt);
pvalGlob = hypoQAMPPE.functions.correction_pval(pval    ,Method,plotsPt);
%Smoothing
todo_oversampling = false;
if todo_oversampling
    samplingRateIncrease = 100;
    newfreq_listRho = linspace(min(freq_listRho), max(freq_listRho), length(freq_listRho) * samplingRateIncrease);
    freq_pb = linspace(12, 30, length(12:30) * samplingRateIncrease);
    freq_pg = linspace(65, 85, length(65:85) * samplingRateIncrease);
    smoothedrho = spline(freq_listRho, rho, newfreq_listRho);
    pvalBeta = spline(12:30, pvalBeta, freq_pb);
    pvalGamm = spline(65:85, pvalGamm, freq_pg);
    pvalGlob = spline(freq_listRho, pvalGlob, newfreq_listRho);
    localsuffix = ["-smoothed_" suffix] ;
else
    smoothedrho = rho ;
    samplingRateIncrease = 1;
    freq_pg = 65:85 ;
    freq_pb = 12:30 ;
    newfreq_listRho = freq_listRho ;
    localsuffix = suffix ;
end
% Plot
figure  ; hold on ;
surf([freq_listRho; freq_listRho], [IClow; IChigh], [zeros(1,length(IClow)); zeros(1,length(IClow))], 'FaceColor', [0.6 0.6 1], 'EdgeColor', 'none')
plot(newfreq_listRho,  smoothedrho , 'DisplayName','Rho', LineWidth=1.5, Color=colOFF)
plot(newfreq_listRho, pvalGlob, 'DisplayName','p-value', LineWidth=1.5, Color=colONpale)
legend show
legend ('AutoUpdate', 'off')
plot([1 100], [0.05 0.05] , 'DisplayName','significatif', LineWidth=1.5, Color='r', LineStyle=':')
plot([1 100], [0 0] , 'DisplayName','0', LineWidth=1.5, Color='#888888')
xlim([0 100])
ylim([min(rho) max(rho)])
saveas(gcf, fullfile(PlotSaveFolder, ['3AB_' localsuffix '.svg']), 'svg')
saveas(gcf, fullfile(PlotSaveFolder, ['3AB_' localsuffix '.png']), 'png')
saveas(gcf, fullfile(PlotSaveFolder, ['3AB_' localsuffix '.fig']), 'fig')
figure  ; hold on ;
plot(newfreq_listRho,  smoothedrho , 'DisplayName','Rho', LineWidth=1.5, Color=colOFF)
plot(freq_pb, pvalBeta, 'DisplayName','p-value', LineWidth=1.5, Color=colON)
plot([1 100], [0.05 0.05] , 'DisplayName','significatif', LineWidth=1.5, Color='r', LineStyle=':')
plot([1 100], [0 0] , 'DisplayName','0', LineWidth=1.5, Color='#888888')
xlim([12 30])
legend show
ylim([min(min(smoothedrho(12*samplingRateIncrease:30*samplingRateIncrease)), 0) max(smoothedrho(12*samplingRateIncrease:30*samplingRateIncrease))])
saveas(gcf, fullfile(PlotSaveFolder, ['3AB_beta_' localsuffix '.svg']), 'svg')
saveas(gcf, fullfile(PlotSaveFolder, ['3AB_beta_' localsuffix '.png']), 'png')
saveas(gcf, fullfile(PlotSaveFolder, ['3AB_beta_' localsuffix '.fig']), 'fig')
figure  ; hold on ;
plot(newfreq_listRho,  smoothedrho , 'DisplayName','Rho', LineWidth=1.5, Color=colOFF)
plot(freq_pg, pvalGamm, 'DisplayName','p-value', LineWidth=1.5, Color=colON)
plot([1 100], [0.05 0.05] , 'DisplayName','significatif', LineWidth=1.5, Color='r', LineStyle=':')
plot([1 100], [0 0] , 'DisplayName','0', LineWidth=1.5, Color='#888888')
xlim([65 85])
legend show
ylim([min(smoothedrho(65*samplingRateIncrease:85*samplingRateIncrease)) max(max(max(pvalGamm),0.05) ,max(smoothedrho(65*samplingRateIncrease:85*samplingRateIncrease)))])
saveas(gcf, fullfile(PlotSaveFolder, ['3AB_gamma_' localsuffix '.svg']), 'svg')
saveas(gcf, fullfile(PlotSaveFolder, ['3AB_gamma_' localsuffix '.png']), 'png')
saveas(gcf, fullfile(PlotSaveFolder, ['3AB_gamma_' localsuffix '.fig']), 'fig')
close all

%% Figure 3c : GAM


%% Fig 4a : Pics detectés dans le delta PSD BETA (cf b avec ≠ parametres)
%% Fig 4b : Pics detectés dans le delta PSD GAMMA
% Detect peak
visualizeIndiv = false ;

[HighestBetaChD, HighestBetaIdD] = hypoQAMPPE.functions.HighBetaContact(OFF_list,StartBeta,EndBeta,PicOrBand,'detail') ;
Peak_ch = 'All' ;  
AroundBPeak = zeros([length(patON)  9*2/PtFq+1]) ;
AroundGPeak = zeros([length(patON)  9*2/PtFq+1]) ;
if visualizeIndiv
    VisualInspectionPeak = zeros([length(patON)  3]) ;
end

for pat = 1:length(patON)
    idx = find(strcmp(patON(pat), NameAndNum(:,1)));
    for idON = 1:length(patON) + 1
        if strcmp(patON(pat), ON_list{1, idON}.input(1:5))
            break
        end
    end
    valeursRAW = squeeze(OFF_list{1, idx}.detail.values{1, 1}  ) ; 
    valeursRAWon = squeeze(ON_list{1, idON}.detail.values{1, 1}  ) ; 
    Hbeta = 999 ;
    [IdChB, FreqB, ~] = hypoQAMPPE.functions.PeakFinder('AllCh1Pat', Peak_ch, Hbeta, valeursRAW, StartBeta,  EndBeta,   PtFq, LeftRightON(pat)) ;
    [IdChG, FreqG, ~] = hypoQAMPPE.functions.PeakFinder('AllCh1Pat', Peak_ch, Hbeta, valeursRAWon, StartGamma, EndGamma,  PtFq, LeftRightON(pat)) ;
    AroundBPeak(pat, :) = valeursRAW  (round(FreqB/PtFq)-9/PtFq:round(FreqB/PtFq)+9/PtFq, IdChB) ;
    AroundGPeak(pat, :) = valeursRAWon(round(FreqG/PtFq)-9/PtFq:round(FreqG/PtFq)+9/PtFq, IdChG) ;
    if visualizeIndiv
        hypoQAMPPE.functions.PeakVisualisation(patON,LeftRightON, pat, AroundBPeak,  IdChB, FreqB, PtFq, AroundGPeak,  IdChG, FreqG, VisualInspectionPeak)
    end
end

if visualizeIndiv
    writematrix(VisualInspectionPeak, fullfile(PlotSaveFolder, '4AB_VisualInspectionPeak.csv'))
else
    VisualInspectionPeak = readtable(fullfile(PlotSaveFolder, '4AB_VisualInspectionPeak.csv')) ; 
end

% Plot Peak per patient
freqList       = 0:PtFq:(100-PtFq) ;
fqAutourPicB   = -9:PtFq:9;
fqAutourPicG   = -9:PtFq:9;
figure ;
hold on ;
for el = 1:length(patON)
    plot(fqAutourPicB, AroundBPeak(el,:), 'DisplayName','no legend', LineWidth=0.2, Color=colOFF)
end
yaxebckp = ylim ;
rectangle('Position',[-99,0,199,1],'FaceColor',[1 1 1 0.67],'EdgeColor','none');
ylim(yaxebckp)
xlim([-9 9])
plot(fqAutourPicB, mean(AroundBPeak,1), LineWidth=3, Color=colOFF)
saveas(gcf, fullfile(PlotSaveFolder, ['4AB Beta AllPeaks' suffix '.svg']), 'svg')
saveas(gcf, fullfile(PlotSaveFolder, ['4AB Beta AllPeaks' suffix '.png']), 'png')
saveas(gcf, fullfile(PlotSaveFolder, ['4AB Beta AllPeaks' suffix '.fig']), 'fig')

%Peak of quality
AroundBPeakSave = AroundBPeak ;
AroundGPeakSave = AroundGPeak ;
figure ;
hold on ;
for el = 1:length(patON)
    if VisualInspectionPeak(el,2) == 0
        AroundBPeak(el,:) = NaN ;
    end
    plot(fqAutourPicB, AroundBPeak(el,:), 'DisplayName','no legend', LineWidth=0.2, Color=colOFF)
end
yaxebckp = ylim ;
rectangle('Position',[-99,0,199,1],'FaceColor',[1 1 1 0.67],'EdgeColor','none');
ylim(yaxebckp)
xlim([-3 3])
plot(fqAutourPicB, mean(AroundBPeak,1,"omitnan"), LineWidth=3, Color=colOFF)
saveas(gcf, fullfile(PlotSaveFolder, ['4AB Beta GoodPeaks' suffix '.svg']), 'svg')
saveas(gcf, fullfile(PlotSaveFolder, ['4AB Beta GoodPeaks' suffix '.png']), 'png')
saveas(gcf, fullfile(PlotSaveFolder, ['4AB Beta GoodPeaks' suffix '.fig']), 'fig')

% Gamma
figure ;
hold on ;
for el = 1:length(patON)
    plot(fqAutourPicG, AroundGPeak(el,:), 'DisplayName','no legend', LineWidth=0.2, Color=colON)
end
yaxebckp = ylim ;
rectangle('Position',[-99,0,199,1],'FaceColor',[1 1 1 0.67],'EdgeColor','none');
ylim(yaxebckp)
xlim([-9 9])
plot(fqAutourPicG, mean(AroundGPeak,1), LineWidth=3, Color=colON)
saveas(gcf, fullfile(PlotSaveFolder, ['4AB Gamma AllPeaks' suffix '.svg']), 'svg')
saveas(gcf, fullfile(PlotSaveFolder, ['4AB Gamma AllPeaks' suffix '.png']), 'png')
saveas(gcf, fullfile(PlotSaveFolder, ['4AB Gamma AllPeaks' suffix '.fig']), 'fig')

%Peak of quality Gamma
figure ;
hold on ;
for el = 1:length(patON)
    if VisualInspectionPeak(el,3) == 0
        AroundGPeak(el,:) = NaN ;
    end
    plot(fqAutourPicG, AroundGPeak(el,:), 'DisplayName','no legend', LineWidth=0.2, Color=colON)
end
yaxebckp = ylim ;
rectangle('Position',[-99,0,199,1],'FaceColor',[1 1 1 0.67],'EdgeColor','none');
ylim(yaxebckp)
xlim([-9 9])
plot(fqAutourPicG, mean(AroundGPeak,1, "omitnan"), LineWidth=3, Color=colON)
saveas(gcf, fullfile(PlotSaveFolder, ['4AB Gamma GoodPeaks' suffix '.svg']), 'svg')
saveas(gcf, fullfile(PlotSaveFolder, ['4AB Gamma GoodPeaks' suffix '.png']), 'png')
saveas(gcf, fullfile(PlotSaveFolder, ['4AB Gamma GoodPeaks' suffix '.fig']), 'fig')

close all
AroundBPeak = AroundBPeakSave ;
AroundGPeak = AroundGPeakSave ;

disp('faire de meme avec ancienne detection visuelle')

%% Fig 4c : Patient avec 2 pics vs. Pat without peak (demography)
% visualisation
figure() ; histogram([VisualInspectionPeak(:,2) + VisualInspectionPeak(:,3)] ,"BinWidth",0.4) ; 
figure() ; histogram([VisualInspectionPeak(VisualInspectionPeak(:,2)==0,3)] ,"BinWidth",0.4) ; 

% SK figure DETECTION DELTA
linksIci={'β','γ',20; 'β','ẋ',52; 'x','γ',1; 'x','ẋ',10;};
figure('Name','Peaks','Units','normalized','Position',[.05,.2,.5,.56])
SK=SSankey(linksDelta(:,1),linksDelta(:,2),linksDelta(:,3));
SK.RenderingMethod='interp';  
SK.Align='center';
SK.LabelLocation='center';
SK.Sep=0;
SK.ColorList=[254, 95, 85 ; 254, 194, 82 ; 129, 173, 200 ; 131, 201, 152 ]./255;
SK.draw()
saveas(gcf, fullfile(PlotSaveFolder, ['4C_opt1_' suffix '.svg']), 'svg')
saveas(gcf, fullfile(PlotSaveFolder, ['4C_opt1_' suffix '.png']), 'png')
saveas(gcf, fullfile(PlotSaveFolder, ['4C_opt1_' suffix '.fig']), 'fig')

PeakTable = readtable('C:\LustreSync\hypoQAMPPE\PeakDetection.xlsx') ;
PeakTable.det_B_G(PeakTable.det_B_G < 4) = 0;
PeakTable.det_B_G(PeakTable.det_B_G > 0) = 1;
PeakTable.det_B_D(PeakTable.det_B_D < 4) = 0;
PeakTable.det_B_D(PeakTable.det_B_D > 0) = 1;
PeakTable.det_G_G(PeakTable.det_G_G < 4) = 0;
PeakTable.det_G_G(PeakTable.det_G_G > 0) = 1;
PeakTable.det_G_D(PeakTable.det_G_D < 4) = 0;
PeakTable.det_G_D(PeakTable.det_G_D > 0) = 1;
% Nombre de patients avec 2 pics
sum(PeakTable.det_B_G + PeakTable.det_G_G == 2)
sum(PeakTable.det_B_D + PeakTable.det_G_D == 2)
% Nombre de patients avec 1 pic gamma sans pic beta
sum(PeakTable.det_G_G(PeakTable.det_B_G==0) == 1)
sum(PeakTable.det_G_D(PeakTable.det_B_D==0) == 1)
% Nombre de patients avec 1 pic beta sans pic gamma
sum(PeakTable.det_B_G(PeakTable.det_G_G==0) == 1)
sum(PeakTable.det_B_D(PeakTable.det_G_D==0) == 1)
% Nombre de patients avec 0 pic
sum(PeakTable.det_B_G + PeakTable.det_G_G == 0)
sum(PeakTable.det_B_D + PeakTable.det_G_D == 0)
% Same for raw data
PeakTable.raw_B_G(PeakTable.raw_B_G < 4) = 0;PeakTable.raw_B_G(PeakTable.raw_B_G > 0) = 1;PeakTable.raw_B_D(PeakTable.raw_B_D < 4) = 0;PeakTable.raw_B_D(PeakTable.raw_B_D > 0) = 1;PeakTable.raw_G_G(PeakTable.raw_G_G < 4) = 0;PeakTable.raw_G_G(PeakTable.raw_G_G > 0) = 1;PeakTable.raw_G_D(PeakTable.raw_G_D < 4) = 0;PeakTable.raw_G_D(PeakTable.raw_G_D > 0) = 1;
% Nombre de patients avec 2 pics
sum(PeakTable.raw_B_G + PeakTable.raw_G_G == 2)
sum(PeakTable.raw_B_D + PeakTable.raw_G_D == 2)
% Nombre de patients avec 1 pic gamma sans pic beta
sum(PeakTable.raw_G_G(PeakTable.raw_B_G==0) == 1)
sum(PeakTable.raw_G_D(PeakTable.raw_B_D==0) == 1)
% Nombre de patients avec 1 pic beta sans pic gamma
sum(PeakTable.raw_B_G(PeakTable.raw_G_G==0) == 1)
sum(PeakTable.raw_B_D(PeakTable.raw_G_D==0) == 1)
% Nombre de patients avec 0 pic
sum(PeakTable.raw_B_G + PeakTable.raw_G_G == 0)
sum(PeakTable.raw_B_D + PeakTable.raw_G_D == 0)

linksDETExcelSur18Pages={'β','γ',18; 'β','ẋ',71; 'x','γ',2; 'x','ẋ',12;};
linksRAWExcelSur18Pages={'β','γ',16; 'β','ẋ',69; 'x','γ',2; 'x','ẋ',16;};

figure('Name','Peaks','Units','normalized','Position',[.05,.2,.5,.56])
SK=SSankey(linksDETExcelSur18Pages(:,1),linksDETExcelSur18Pages(:,2),linksDETExcelSur18Pages(:,3));
SK.RenderingMethod='interp';  
SK.Align='center';
SK.LabelLocation='center';
SK.Sep=0;
SK.ColorList=[254, 95, 85 ; 254, 194, 82 ; 129, 173, 200 ; 131, 201, 152 ]./255;
SK.draw()
saveas(gcf, fullfile(PlotSaveFolder, ['4C_opt2_' suffix '.svg']), 'svg')
saveas(gcf, fullfile(PlotSaveFolder, ['4C_opt2_' suffix '.png']), 'png')
saveas(gcf, fullfile(PlotSaveFolder, ['4C_opt2_' suffix '.fig']), 'fig')

figure('Name','Peaks','Units','normalized','Position',[.05,.2,.5,.56])
SK=SSankey(linksRAWExcelSur18Pages(:,1),linksRAWExcelSur18Pages(:,2),linksRAWExcelSur18Pages(:,3));
SK.RenderingMethod='interp';  
SK.Align='center';
SK.LabelLocation='center';
SK.Sep=0;
SK.ColorList=[254, 95, 85 ; 254, 194, 82 ; 129, 173, 200 ; 131, 201, 152 ]./255;
SK.draw()
saveas(gcf, fullfile(PlotSaveFolder, ['4C_opt3_' suffix '.svg']), 'svg')
saveas(gcf, fullfile(PlotSaveFolder, ['4C_opt3_' suffix '.png']), 'png')
saveas(gcf, fullfile(PlotSaveFolder, ['4C_opt3_' suffix '.fig']), 'fig')

close all

%% Fig 4d : Correl avec score
GammaValues = mean(cell2mat(BestChanTableDlt(7000:8000,:)),1) ;
BetaValues  = mean(AroundBPeak(:,:),2) ;
ScoreDiv    = BetaValues./GammaValues ;
GammaValues = normalize(GammaValues,"range");
BetaValues  = normalize(BetaValues,"range");
ScoreDif    = BetaValues-GammaValues ;

for pat = 1:length(patON)
    UPDRSdeltaList(pat) = NameAndNum{strcmp(patON(pat), NameAndNum(:, 1)),8+LeftRightON(pat)} - NameAndNum{strcmp(patON(pat), NameAndNum(:, 1)),9+LeftRightON(pat)} ;
end
UPDRSdeltaList = UPDRSdeltaList(VisualInspectionPeak(:,3)==1) ;
ScoreDif = ScoreDif(VisualInspectionPeak(:,3)==1) ;
ScoreDiv = ScoreDiv(VisualInspectionPeak(:,3)==1) ;
goodlist = ~isnan(UPDRSdeltaList) ;
UPDRSdeltaList = UPDRSdeltaList(goodlist) ;
ScoreDiv = ScoreDiv(goodlist) ;
ScoreDif = ScoreDif(goodlist) ;

figure('Name','Correl','Units','normalized','Position',[.05,.2,.9,.7])
subplot(1,2,1)
scatter(UPDRSdeltaList, ScoreDiv)
xlabel('UPDRS delta')
ylabel('Score div')
subplot(1,2,2)
scatter(UPDRSdeltaList, ScoreDif)
xlabel('UPDRS delta')
ylabel('Score dif')
saveas(gcf, fullfile(PlotSaveFolder, ['4D_' suffix '.svg']), 'svg')
saveas(gcf, fullfile(PlotSaveFolder, ['4D_' suffix '.png']), 'png')
saveas(gcf, fullfile(PlotSaveFolder, ['4D_' suffix '.fig']), 'fig')


corrplot([UPDRSdeltaList', ScoreDiv], 'varNames', {'UPDRS delta', 'Score div'})
corrplot([UPDRSdeltaList', ScoreDif], 'varNames', {'UPDRS delta', 'Score dif'})


%% Fig 5a : Exemple de patients outliers dans le score

%% Fig 6 : Enreg ON/OFF apportent que peu de plus p/r à ON seul


%% Export spectrum with all spectrum
% Prepare table 
% columns : PatientCode, ON/OFF, BaseOrDetailed, Left/Right, ChanelLabel, Freq, PSD
SpectrumTable = table() ;

for pat = 1:length(ON_list)
    patname = extractBefore(ON_list{1, pat}.input ,'_') ;
    for ch = 1:length(ON_list{1, pat}.labels_)
        list_f        = ON_list{1, pat}.raw.f;
        raw_values    = squeeze(ON_list{1, pat}.raw.values{1, 1}(1, :, ch));
        detail_values = squeeze(ON_list{1, pat}.detail.values{1, 1}(1, :, ch));
        
        num_freqs = length(list_f);
        side      = repmat({ON_list{1, pat}.labels_(1, ch).side}, num_freqs, 1);
        name      = repmat( ON_list{1, pat}.labels_(1, ch).name , num_freqs, 1);
        pat_id    = repmat(patON{pat}, num_freqs, 1);
        
        BaseTable   = table(pat_id, repmat({'ON'}, num_freqs, 1), repmat({'base'},   num_freqs, 1), side, name, list_f', raw_values');
        DetailTable = table(pat_id, repmat({'ON'}, num_freqs, 1), repmat({'detail'}, num_freqs, 1), side, name, list_f', detail_values');
        SpectrumTable = [SpectrumTable; BaseTable; DetailTable];   %#ok<AGROW> 
                    %         for freq = 1:(min(maxfreq, max( ON_list{1, pat}.detail.f ) ) * 100)
                    %             SpectrumTable(end+1,:) = {patON{pat}, 'ON', 'Base',   ON_list{1, pat}.labels_(1, ch).side, ON_list{1, pat}.labels_(1, ch).name, ON_list{1, pat}.raw.f(freq),    ON_list{1, pat}.raw.values{1, 1}(1, freq, ch)} ;
                    %             SpectrumTable(end+1,:) = {patON{pat}, 'ON', 'Detail', ON_list{1, pat}.labels_(1, ch).side, ON_list{1, pat}.labels_(1, ch).name, ON_list{1, pat}.detail.f(freq), ON_list{1, pat}.detail.values{1, 1}(1, freq, ch)} ;
                    %         end
    end
end
for pat = 1:length(OFF_list)
    patname = extractBefore(OFF_list{1, pat}.input ,'_') ;
    for ch = 1:length(OFF_list{1, pat}.labels_)
        list_f        = OFF_list{1, pat}.raw.f;
        raw_values    = squeeze(OFF_list{1, pat}.raw.values{1, 1}(1, :, ch));
        detail_values = squeeze(OFF_list{1, pat}.detail.values{1, 1}(1, :, ch));

        num_freqs = length(list_f);
        side      = repmat({OFF_list{1, pat}.labels_(1, ch).side}, num_freqs, 1);
        name      = repmat( OFF_list{1, pat}.labels_(1, ch).name , num_freqs, 1);
        pat_id    = repmat(patOFF{pat}, num_freqs, 1);

        BaseTable   = table(pat_id, repmat({'OFF'}, num_freqs, 1), repmat({'base'},   num_freqs, 1), side, name, list_f', raw_values');
        DetailTable = table(pat_id, repmat({'OFF'}, num_freqs, 1), repmat({'detail'}, num_freqs, 1), side, name, list_f', detail_values');
        SpectrumTable = [SpectrumTable; BaseTable; DetailTable];   %#ok<AGROW>
                    %         for freq = 1:(min(maxfreq, max( OFF_list{1, pat}.detail.f ) ) * 100)
                    %             SpectrumTable(end+1,:) = {patname, 'OFF', 'Base',   OFF_list{1, pat}.labels_(1, ch).side, OFF_list{1, pat}.labels_(1, ch).name, OFF_list{1, pat}.raw.f(freq),    OFF_list{1, pat}.raw.values{1, 1}(1, freq, ch)} ;
                    %             SpectrumTable(end+1,:) = {patname, 'OFF', 'Detail', OFF_list{1, pat}.labels_(1, ch).side, OFF_list{1, pat}.labels_(1, ch).name, OFF_list{1, pat}.detail.f(freq), OFF_list{1, pat}.detail.values{1, 1}(1, freq, ch)} ;
                    %         end
    end
end

SpectrumTable.Properties.VariableNames = {'Patient', 'Treatment', 'Preproccess', 'Side', 'ChanelLabel', 'Freq', 'PSD'} ;

csvFileAll = fullfile(PlotSaveFolder, ['SpectrumDatabase_AllPat_AllCond_' Normalisation '.csv'] );
writetable(SpectrumTable,csvFileAll)
csvFileAll = strrep(csvFileAll, '.csv', '.parquet');
parquetwrite(csvFileAll,  SpectrumTable);




