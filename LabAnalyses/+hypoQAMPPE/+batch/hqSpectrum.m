
%% Parameters 
% Load
Projet = 'hQ_Spectrum' ;
Type_of_Spectrum = 'detail' ; % 'detail' or 'raw'
Normalisation = 'brut' ;  % 'brut' or 'AUC100'
ExportToR = false;
contact_to_use = 'HighestBeta' ; % 'HighestBeta' or 'ClinicalContact'

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
PlotSaveFolder = 'C:\LustreSync\hypoQAMPPE\Figures\AllPatPeaks' ;
Method = 'FDR' ;  % 'Holm' , 'FDR', 'Storey' or 'NoCorrection'
ClinicalFileToUse = 'Old' ; % 'New' (MY from Evinaa) or 'Old' (Brian)
PlotPage = false ;

suffix = [Type_of_Spectrum '_Norm=' Normalisation '_' contact_to_use '_MultComp=' Method '_Resolution=' plotsPt '_ClinVar=' VariableToCompare '+' Timing_to_Use '+' U3bilat '_Peak=' num2str(PeakWidth) 'Hz-Thresh' num2str(PeakProminance) CategAndMore] ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Preprocessing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load data
[ClinicalData, OFF_list, ON_list] = hypoQAMPPE.load.LoadList(Projet) ;

%% Artifacts rejection
% Fait !

%% ON-OFF matching + Choose electrode of interest
[NameAndNum] = hypoQAMPPE.functions.MatchingTable(OFF_list,ON_list,ClinicalData,contact_to_use, ClinicalFileToUse, U3bilat,StartBeta,EndBeta,PicOrBand,Type_of_Spectrum, Timing_to_Use) ;

%% Normalisation
OFF_list = hypoQAMPPE.functions.SpectrumNormalisation(Normalisation,OFF_list) ;
ON_list  = hypoQAMPPE.functions.SpectrumNormalisation(Normalisation,ON_list ) ;

%% Extract PSD of interest
[BestChanTableOFF, BestChanTableON, BestChanTableDlt, MeanChanTableOFF, MeanChanTableON, MeanChanTableDlt, patOFF, patON, LeftRightOFF, LeftRightON] = hypoQAMPPE.functions.ExtractPSDofInterest(NameAndNum,ExportToR,Type_of_Spectrum,PtFq,OFF_list, ON_list, PlotSaveFolder, Normalisation) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Reproduce figs from Lofredi 2023

% Fig 1-A Best Channel
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
    plot(freqList, cell2mat(BestChanTableOFF(1:round(100/PtFq),el)), 'DisplayName','no legend', LineWidth=0.2, Color='#ccccff')
end
for el = 1:size(BestChanTableON,2)
    plot(freqList, cell2mat(BestChanTableON( 1:round(100/PtFq),el)), 'DisplayName','no legend', LineWidth=0.2, Color='#ccffcc')
end
d1 = designfilt('lowpassiir','FilterOrder',12, 'HalfPowerFrequency',0.02,'DesignMethod','butter');
plot(freqList, meanOFF,               'DisplayName','no legend', LineWidth=0.5, Color='#2b7dff')
plot(freqList, meanON ,               'DisplayName','no legend', LineWidth=0.5, Color='#0f9d58')
plot(freqList, filtfilt(d1, meanOFF), 'DisplayName','OFF-DOPA' , LineWidth=1.5, Color='#2b7dff')
plot(freqList, filtfilt(d1, meanON ), 'DisplayName','ON-DOPA'  , LineWidth=1.5, Color='#0f9d58')
%fill([freqList, fliplr(freqList)], [ meanOFF-sdOFF , fliplr(meanOFF+sdOFF) ] , 'r' )
axis([7 40 0 1.5*max(meanOFF(10/PtFq:35/PtFq))])
set_leg_off = findobj('DisplayName','no legend');
for k = 1:numel(set_leg_off)
    set_leg_off(k).Annotation.LegendInformation.IconDisplayStyle = 'off';
end
title('Best Channel')
legend show
xlim([0 100])
saveas(gcf, fullfile(PlotSaveFolder, ['1A Best Channel ' 'AllFq' '_' suffix '.pdf']), 'pdf')
saveas(gcf, fullfile(PlotSaveFolder, ['1A Best Channel ' 'AllFq' '_' suffix '.png']), 'png')
xlim([AlphaStart EndBeta+3])
saveas(gcf, fullfile(PlotSaveFolder, ['1A Best Channel ' 'Beta' '_' suffix '.png']), 'png')
saveas(gcf, fullfile(PlotSaveFolder, ['1A Best Channel ' 'Beta' '_' suffix '.pdf']), 'pdf')


% Fig 1-B Up PSD OFF versus UPDRS OFF
advance = true ;
rho = [] ;
pval = [] ;
UPDRSoffList = [] ;
freq_list = [] ;
IClow = [] ; 
IChigh = [] ;
% Clinical Data
for pat = 1:length(patOFF)
    UPDRSoffList(pat) = NameAndNum{strcmp(patOFF(pat), NameAndNum(:, 1)),8+LeftRightOFF(pat)} ;
end
goodlist = ~isnan(UPDRSoffList) ;
UPDRSoffList = UPDRSoffList(goodlist) ;
% Ephy data
if strcmp(plotsPt, '100')
    for freq = 1:100
        PSDValueList = mean(cell2mat(BestChanTableOFF( (freq/PtFq-0.5/PtFq):(freq/PtFq+0.5/PtFq) , :)),1) ;
        PSDValueList = PSDValueList(goodlist) ;
        [rho(freq), pval(freq)] = corr(PSDValueList', UPDRSoffList', 'Type', 'Spearman') ;
        freq_list(freq) = freq ;
        if advance
            inipv = pval(freq) ;
            pval(freq) = hypoQAMPPE.functions.MonteCarloPermTest(PSDValueList,UPDRSoffList,10000) ;
            if inipv < pval(freq) + 0.001 ; disp(['freq ' num2str(freq) ' : ' num2str(inipv) ' -> ' num2str(pval(freq))]) ; end
            [IClow(freq), IChigh(freq)] = hypoQAMPPE.functions.Bootstrap(PSDValueList,UPDRSoffList,5000,0.95) ;
        end
    end
elseif strcmp(plotsPt, '10k')
    for freq = 1:round(100/PtFq)
        PSDValueList = cell2mat(BestChanTableOFF( freq, :)) ;
        PSDValueList = PSDValueList(goodlist) ;
        [rho(freq), pval(freq)] = corr(PSDValueList', UPDRSoffList', 'Type', 'Spearman') ;
        freq_list(freq) = freq*PtFq-PtFq ;
        if advance
            inipv = pval(freq) ;
            pval(freq) = hypoQAMPPE.functions.MonteCarloPermTest(PSDValueList,UPDRSoffList,10000) ;
            if inipv < pval(freq) + 0.05 ; disp(['freq ' num2str(freq) ' : ' num2str(inipv) ' -> ' num2str(pval(freq))]) ; end
            [IClow(freq), IChigh(freq)] = hypoQAMPPE.functions.Bootstrap(PSDValueList,UPDRSoffList,5000,0.95) ;
        end
    end
elseif strcmp(plotsPt, '10kfilt')
    for freq = 1:round(100/PtFq)
        if freq <= 0.5/PtFq
            PSDValueList = mean(cell2mat(BestChanTableOFF( (freq         ):(freq+0.5/PtFq) , :)),1) ;
        else
            PSDValueList = mean(cell2mat(BestChanTableOFF( (freq-0.5/PtFq):(freq+0.5/PtFq) , :)),1) ;
        end
        PSDValueList = PSDValueList(goodlist) ;
        [rho(freq), pval(freq)] = corr(PSDValueList', UPDRSoffList', 'Type', 'Spearman') ;
        freq_list(freq) = freq*PtFq-PtFq ;
        if advance
            inipv = pval(freq) ;
            pval(freq) = hypoQAMPPE.functions.MonteCarloPermTest(PSDValueList,UPDRSoffList,10000) ;
            if inipv < pval(freq) + 0.001 ; disp(['freq ' num2str(freq) ' : ' num2str(inipv) ' -> ' num2str(pval(freq))]) ; end
            [IClow(freq), IChigh(freq)] = hypoQAMPPE.functions.Bootstrap(PSDValueList,UPDRSoffList,5000,0.95) ;
        end
    end
end
pval = hypoQAMPPE.functions.correction_pval(pval,Method,plotsPt);
% Plot
figure  ;
hold on ;
plot(freq_list, rho , 'DisplayName','Rho', LineWidth=1.5, Color='#a8a6ff')
plot(freq_list, pval, 'DisplayName','p-value', LineWidth=1.5, Color='#18ffad')
legend show
legend ('AutoUpdate', 'off')
freq_list(pval > 0.05) = NaN ;
plot(freq_list, rho , 'DisplayName','Rho', LineWidth=1.5, Color='red')
plot(freq_list, pval, 'DisplayName','p-value', LineWidth=1.5, Color='#0f9d58')
if advance
    fill([freq_list, fliplr(freq_list)], [IClow, fliplr(IChigh)], '#18ffad'); alpha(.1)
end
plot([1 100], [0.05 0.05] , 'DisplayName','significatif', LineWidth=0.5, Color='r', LineStyle=':')
plot([1 100], [0 0] , 'DisplayName','0', LineWidth=0.5, Color='#888888')
xlim([0 100])
ylim([min(min(rho),min(pval)) max(max(rho),mean(pval))])
saveas(gcf, fullfile(PlotSaveFolder, ['1-B Up PSD OFF versus UPDRS OFF ' 'AllFq' '_' suffix  '.pdf']), 'pdf')
saveas(gcf, fullfile(PlotSaveFolder, ['1-B Up PSD OFF versus UPDRS OFF ' 'AllFq' '_' suffix  '.png']), 'png')
xlim([AlphaStart EndBeta+3])
saveas(gcf, fullfile(PlotSaveFolder, ['1-B Up PSD OFF versus UPDRS OFF ' 'Beta' '_' suffix  '.png']), 'png')
saveas(gcf, fullfile(PlotSaveFolder, ['1-B Up PSD OFF versus UPDRS OFF ' 'Beta' '_' suffix  '.pdf']), 'pdf')



% Fig 1-B Down PSD OFF-ON versus UPDRS OFF-ON
rho = [] ;
pval = [] ;
UPDRSdeltaList = [] ;
freq_list = [] ;
% Clinical Data
for pat = 1:length(patON)
    UPDRSdeltaList(pat) = NameAndNum{strcmp(patON(pat), NameAndNum(:, 1)),8+LeftRightON(pat)} - NameAndNum{strcmp(patON(pat), NameAndNum(:, 1)),9+LeftRightON(pat)} ;
end
goodlist = ~isnan(UPDRSdeltaList) ;
UPDRSdeltaList = UPDRSdeltaList(goodlist) ;
% Ephy data
if strcmp(plotsPt, '100')
    for freq = 1:100
        PSDValueList = mean(cell2mat(BestChanTableDlt( (freq/PtFq-0.5/PtFq):(freq/PtFq+0.5/PtFq) , :)),1) ;
        PSDValueList = PSDValueList(goodlist) ;
        [rho(freq), pval(freq)] = corr(PSDValueList', UPDRSdeltaList', 'Type', 'Spearman') ;
        freq_list(freq) = freq ;
    end
elseif strcmp(plotsPt, '10k')
    for freq = 1:round(100/PtFq)
        PSDValueList = cell2mat(BestChanTableDlt( freq, :)) ;
        PSDValueList = PSDValueList(goodlist) ;
        [rho(freq), pval(freq)] = corr(PSDValueList', UPDRSdeltaList', 'Type', 'Spearman') ;
        freq_list(freq) = freq*PtFq-PtFq ;
    end
elseif strcmp(plotsPt, '10kfilt')
    for freq = 1:round(100/PtFq)
        if freq <= 0.5/PtFq
            PSDValueList = mean(cell2mat(BestChanTableDlt( (freq         ):(freq+0.5/PtFq) , :)),1) ;
        else
            PSDValueList = mean(cell2mat(BestChanTableDlt( (freq-0.5/PtFq):(freq+0.5/PtFq) , :)),1) ;
        end
        PSDValueList = PSDValueList(goodlist) ;
        [rho(freq), pval(freq)] = corr(PSDValueList', UPDRSdeltaList', 'Type', 'Spearman') ;
        freq_list(freq) = freq*PtFq-PtFq ;
    end
end
pval = hypoQAMPPE.functions.correction_pval(pval,Method,plotsPt);
% Plot
figure  ;
hold on ;
plot(freq_list, rho , 'DisplayName','Rho', LineWidth=1.5, Color='#a8a6ff')
plot(freq_list, pval, 'DisplayName','p-value', LineWidth=1.5, Color='#18ffad')
legend show
legend ('AutoUpdate', 'off')
freq_list(pval > 0.05) = NaN ;
plot(freq_list, rho , 'DisplayName','Rho', LineWidth=1.5, Color='red')
plot(freq_list, pval, 'DisplayName','p-value', LineWidth=1.5, Color='#0f9d58')
plot([1 100], [0.05 0.05] , 'DisplayName','significatif', LineWidth=0.5, Color='r', LineStyle=':')
plot([1 100], [0 0] , 'DisplayName','0', LineWidth=0.5, Color='#888888')
xlim([0 100])
ylim([min(rho) max(rho)])
saveas(gcf, fullfile(PlotSaveFolder, ['1-B Up PSD OFF-ON versus UPDRS OFF-ON ' 'AllFq' '_' suffix '.pdf']), 'pdf')
saveas(gcf, fullfile(PlotSaveFolder, ['1-B Up PSD OFF-ON versus UPDRS OFF-ON ' 'AllFq' '_' suffix '.png']), 'png')
xlim([AlphaStart EndBeta+3])
saveas(gcf, fullfile(PlotSaveFolder, ['1-B Up PSD OFF-ON versus UPDRS OFF-ON ' 'Beta' '_' suffix '.png']), 'png')
saveas(gcf, fullfile(PlotSaveFolder, ['1-B Up PSD OFF-ON versus UPDRS OFF-ON ' 'Beta' '_' suffix '.pdf']), 'pdf')
freq_list = [] ;



% Fig 1-C OFF / Low Î² peak power correlation to UPDRS
rho = [] ;
pval = [] ;
UPDRSoffList = [] ;
plotData = [] ;
% Clinical Data
for pat = 1:length(patOFF)
    UPDRSoffList(pat) = NameAndNum{strcmp(patOFF(pat), NameAndNum(:, 1)),8+LeftRightOFF(pat)} ;
end
goodlist = ~isnan(UPDRSoffList) ;
UPDRSoffList = UPDRSoffList(goodlist) ;
% Detect peak
MaxPerPat = max(cell2mat(BestChanTableOFF(StartBeta/PtFq:MidBeta/PtFq, :)),[],1) ;
FrqPerPat = zeros(size(MaxPerPat));
psdPerPat = zeros(size(MaxPerPat));
for i = 1:length(MaxPerPat)
    Patient = patOFF(i) ;
    if i ~= 1 && strcmp(patOFF(i), patOFF(i-1))
        Side = 'G' ;
    else
        Side = 'D' ;
    end
    [ShouldBeIncluded] = hypoQAMPPE.load.PatientsWithPeaks(Patient, Side, PeakProminance, CategAndMore, PeakBand, PeakTable , AutoManuel) ;
    if ShouldBeIncluded
        [~, idx] = min(abs(cell2mat(BestChanTableOFF(1:MidBeta/PtFq, i)) - MaxPerPat(i)));
        FrqPerPat(i) = idx*PtFq ;
        psdPerPat(i) = mean(cell2mat(BestChanTableOFF( (idx-PeakWidth/PtFq):(idx+PeakWidth/PtFq), i))) ;
    else
        FrqPerPat(i) = NaN;
        psdPerPat(i) = NaN;
    end
end
% Calculate correlation
goodlisttmp = ~isnan(psdPerPat) ;
psdPerPat = psdPerPat(goodlist) ;
goodlist2 = ~isnan(psdPerPat) ;
UPDRSoffList = UPDRSoffList(goodlist2) ;
psdPerPat = psdPerPat(goodlist2) ;

[rho, pval] = corr(psdPerPat', UPDRSoffList', 'Type', 'Spearman') ;
% Plot Peak per patient
freqList      = 0:PtFq:(100-PtFq) ;
fqAutourPic   = -PeakWidth*1.5:PtFq:PeakWidth*1.5;
figure ;
hold on ;
tempmean = [] ;
for el = 1:length(MaxPerPat)
    if goodlist(el) && goodlisttmp(el)
        plot(fqAutourPic, ...
        cell2mat(BestChanTableOFF(round(FrqPerPat(el)/PtFq - PeakWidth*1.5/PtFq):round(FrqPerPat(el)/PtFq + PeakWidth*1.5/PtFq),el)),...
        'DisplayName','no legend', LineWidth=0.2, Color='#cccccc')
        tempmean(:,end+1) = cell2mat(BestChanTableOFF(round(FrqPerPat(el)/PtFq - PeakWidth*1.5/PtFq):round(FrqPerPat(el)/PtFq + PeakWidth*1.5/PtFq),el)) ;
    end
end
plot(fqAutourPic, mean(tempmean,2), LineWidth=3)
saveas(gcf, fullfile(PlotSaveFolder, ['1-C OFF AllPeaks' '_' suffix '.png']), 'png')
% Plot Correlation 
plotData(1,:) = psdPerPat ;
plotData(2,:) = UPDRSoffList ;
corrplot(plotData')



% Fig 1-C DELTA / Low beta peak power correlation to UPDRS
rho = [] ;
pval = [] ;
UPDRSdeltaList = [] ;
plotData = [] ;
% Clinical Data
for pat = 1:length(patON)
    UPDRSdeltaList(pat) = NameAndNum{strcmp(patON(pat), NameAndNum(:, 1)),8+LeftRightON(pat)} - NameAndNum{strcmp(patON(pat), NameAndNum(:, 1)),9+LeftRightON(pat)} ;
end
goodlist = ~isnan(UPDRSdeltaList) ;
UPDRSdeltaList = UPDRSdeltaList(goodlist) ;
% Detect peak
MaxPerPat = max(cell2mat(BestChanTableDlt(StartBeta/PtFq:MidBeta/PtFq, :)),[],1) ;
FrqPerPat = zeros(size(MaxPerPat));
psdPerPat = zeros(size(MaxPerPat));
for i = 1:length(MaxPerPat)
    Patient = patON(i) ;
    if i ~= 1 && strcmp(patON(i), patON(i-1))
        Side = 'G' ;
    else
        Side = 'D' ;
    end
    [ShouldBeIncluded] = hypoQAMPPE.load.PatientsWithPeaks(Patient, Side, PeakProminance, CategAndMore, PeakBand, PeakTable , AutoManuel) ;
    if ShouldBeIncluded
        [~, idx] = min(abs(cell2mat(BestChanTableDlt(1:MidBeta/PtFq, i)) - MaxPerPat(i)));
        FrqPerPat(i) = idx*PtFq ;
        psdPerPat(i) = mean(cell2mat(BestChanTableDlt( (idx-PeakWidth/PtFq):(idx+PeakWidth/PtFq), i))) ;
    else
        FrqPerPat(i) = NaN;
        psdPerPat(i) = NaN;
    end
end
% Calculate correlation
goodlisttmp = ~isnan(psdPerPat) ;
psdPerPat = psdPerPat(goodlist) ;
goodlist2 = ~isnan(psdPerPat) ;
UPDRSdeltaList = UPDRSdeltaList(goodlist2) ;
psdPerPat = psdPerPat(goodlist2) ;

[rho, pval] = corr(psdPerPat', UPDRSdeltaList', 'Type', 'Spearman') ;

% Plot Peak per patient
freqList      = 0:PtFq:(100-PtFq) ;
fqAutourPic   = -PeakWidth*1.5:PtFq:PeakWidth*1.5;
figure ;
hold on ;
tempmean = [] ;
for el = 1:length(MaxPerPat)
    if goodlist(el) && goodlisttmp(el)
        plot(fqAutourPic, ...
            cell2mat(BestChanTableDlt(round(FrqPerPat(el)/PtFq - PeakWidth*1.5/PtFq):round(FrqPerPat(el)/PtFq + PeakWidth*1.5/PtFq),el)),...
            'DisplayName','no legend', LineWidth=0.2, Color='#cccccc')
        tempmean(:,end+1) = cell2mat(BestChanTableDlt(round(FrqPerPat(el)/PtFq - PeakWidth*1.5/PtFq):round(FrqPerPat(el)/PtFq + PeakWidth*1.5/PtFq),el)) ;
    end
end
plot(fqAutourPic, mean(tempmean,2), LineWidth=3)
saveas(gcf, fullfile(PlotSaveFolder, ['1-C Delta AllPeaks' '_' suffix '.png']), 'png')
% Plot Correlation 
plotData(1,:) = psdPerPat ;
plotData(2,:) = UPDRSdeltaList ;
corrplot(plotData')



%% Beta Gamma Composite score

% Compute score
rho = [] ;
pval = [] ;
UPDRSdeltaList = [] ;
plotData = [] ;
% Clinical Data
for pat = 1:length(patON)
    UPDRSdeltaList(pat) = NameAndNum{strcmp(patON(pat), NameAndNum(:, 1)),8+LeftRightON(pat)} - NameAndNum{strcmp(patON(pat), NameAndNum(:, 1)),9+LeftRightON(pat)} ;
end
goodlist = ~isnan(UPDRSdeltaList) ;
UPDRSdeltaList = UPDRSdeltaList(goodlist) ;
scoreBG = zeros(size(patON));
scoreBGn  = zeros(size(patON));
scoreBGd  = zeros(size(patON));
scoreBGnm  = zeros(size(patON));
scoreBGnf  = zeros(size(patON));
scoreBGdm  = zeros(size(patON));
scoreBGdf  = zeros(size(patON));
for i = 1:length(patON)
    gamma = mean(cell2mat(BestChanTableDlt(round(75/PtFq):round(80/PtFq), i))) ;
    beta  = mean(cell2mat(BestChanTableDlt(round(15/PtFq):round(25/PtFq), i))) ;
    scoreBGn(i) = beta/gamma ;
    scoreBGd(i) = beta-gamma ;
    scoreBGnm(i) = beta/(0.3*gamma) ;
    scoreBGnf(i) = beta/(3*gamma) ;
    scoreBGdm(i) = beta-(6.1*gamma) ;
    scoreBGdf(i) = beta-(6.0*gamma) ;
end
% Calculate correlation
scoreBGn   = scoreBGn(goodlist);
scoreBGd   = scoreBGd(goodlist);
scoreBGnm  = scoreBGnm(goodlist);
scoreBGnf  = scoreBGnf(goodlist);
scoreBGdm  = scoreBGdm(goodlist);
scoreBGdf  = scoreBGdf(goodlist);

[rho, pval] = corr(scoreBGn', UPDRSdeltaList', 'Type', 'Spearman') 
[rho, pval] = corr(scoreBGd', UPDRSdeltaList', 'Type', 'Spearman') 
[rho, pval] = corr(scoreBGnm', UPDRSdeltaList', 'Type', 'Spearman') 
[rho, pval] = corr(scoreBGnf', UPDRSdeltaList', 'Type', 'Spearman') 
[rho0, pval0] = corr(scoreBGdm', UPDRSdeltaList', 'Type', 'Spearman') 
[rho, pval] = corr(scoreBGdf', UPDRSdeltaList', 'Type', 'Spearman') 

plotData(1,:) = scoreBGdm ;
plotData(2,:) = UPDRSdeltaList ;
corrplot(plotData')

% Manual corr plot
figure
hold on
scatter(scoreBGdm, UPDRSdeltaList);
plot([min(scoreBGdm) max(scoreBGdm)], [mean(UPDRSdeltaList)-(rho0*(max(scoreBGdm)-min(scoreBGdm))/2)   mean(UPDRSdeltaList)+(rho0*(max(scoreBGdm)-min(scoreBGdm))/2)] , "Color" , "red")
xlabel('score Beta Gamma');
ylabel('UPDRSdeltaList');
title([num2str(rho0)  ', p=' num2str(pval0)]);




%% HFO
HFOlistOFF = [] ;
for psd_num = 1:size(BestChanTableOFF,2)
    if ~isnan(BestChanTableOFF{30000,psd_num}) == 1
        HFOlistOFF(psd_num) = 1 ;
        else
        HFOlistOFF(psd_num) = 0 ;
    end
end
HFOlistON = [] ;
for psd_num = 1:size(BestChanTableON,2)
    if ~isnan(BestChanTableON{30000,psd_num}) == 1
        HFOlistON(psd_num) = 1 ;
        else
        HFOlistON(psd_num) = 0 ;
    end
end

BestChanTableOFF_HFO = BestChanTableOFF(round(100/PtFq):round(300/PtFq), HFOlistOFF==1) ;
BestChanTableON_HFO  = BestChanTableON (round(100/PtFq):round(300/PtFq), HFOlistON ==1) ;
BestChanTableDlt_HFO = BestChanTableDlt(round(100/PtFq):round(300/PtFq), HFOlistON ==1) ;

for freq = 1:(round(200/PtFq)+1)
    meanOFF(freq) = mean(cell2mat(BestChanTableOFF_HFO(freq,:))) ;
    meanON(freq)  = mean(cell2mat(BestChanTableON_HFO(freq,:)))  ;
    sdOFF(freq)   = std(cell2mat(BestChanTableOFF_HFO(freq,:)))  ;
    sdON(freq)    = std(cell2mat(BestChanTableON_HFO(freq,:)))   ;
end
freqList      = 100:PtFq:300 ;
figure  ;
hold on ;
for el = 1:size(BestChanTableOFF_HFO,2)
    plot(freqList, cell2mat(BestChanTableOFF_HFO(:,el)), 'DisplayName','no legend', LineWidth=0.2, Color='#ccccff')
end
for el = 1:size(BestChanTableON_HFO,2)
    plot(freqList, cell2mat(BestChanTableON_HFO( :,el)), 'DisplayName','no legend', LineWidth=0.2, Color='#ccffcc')
end
d1 = designfilt('lowpassiir','FilterOrder',12, 'HalfPowerFrequency',0.02,'DesignMethod','butter');
plot(freqList, meanOFF,               'DisplayName','no legend', LineWidth=0.5, Color='#2b7dff')
plot(freqList, meanON ,               'DisplayName','no legend', LineWidth=0.5, Color='#0f9d58')
plot(freqList, filtfilt(d1, meanOFF), 'DisplayName','OFF-DOPA' , LineWidth=1.5, Color='#2b7dff')
plot(freqList, filtfilt(d1, meanON ), 'DisplayName','ON-DOPA'  , LineWidth=1.5, Color='#0f9d58')
set_leg_off = findobj('DisplayName','no legend');
for k = 1:numel(set_leg_off)
    set_leg_off(k).Annotation.LegendInformation.IconDisplayStyle = 'off';
end
title('HFO')
legend show
saveas(gcf, fullfile(PlotSaveFolder, ['HFO traces ' 'AllFq' '_' suffix '.pdf']), 'pdf')
saveas(gcf, fullfile(PlotSaveFolder, ['HFO traces ' 'AllFq' '_' suffix '.png']), 'png')


%% HFO Correlation  -  PSD OFF-ON versus UPDRS OFF-ON
rho = [] ;
pval = [] ;
UPDRSdeltaList = [] ;
freq_list = [] ;
% Clinical Data
for pat = 1:length(patON)
    UPDRSdeltaList(pat) = NameAndNum{strcmp(patON(pat), NameAndNum(:, 1)),8+LeftRightON(pat)} - NameAndNum{strcmp(patON(pat), NameAndNum(:, 1)),9+LeftRightON(pat)} ;
end
UPDRSdeltaList = UPDRSdeltaList(HFOlistON==1) ;
goodlist = ~isnan(UPDRSdeltaList) ;
UPDRSdeltaList = UPDRSdeltaList(goodlist) ;
% Ephy data
if strcmp(plotsPt, '100')
    for freq = 1:199
        PSDValueList = mean(cell2mat(BestChanTableDlt_HFO( (freq/PtFq-0.5/PtFq):(freq/PtFq+0.5/PtFq) , :)),1) ;
        PSDValueList = PSDValueList(goodlist) ;
        [rho(freq), pval(freq)] = corr(PSDValueList', UPDRSdeltaList', 'Type', 'Spearman') ;
        freq_list(freq) = freq+100 ;
    end
elseif strcmp(plotsPt, '10k')
    for freq = 1:round(200/PtFq)
        PSDValueList = cell2mat(BestChanTableDlt_HFO( freq, :)) ;
        PSDValueList = PSDValueList(goodlist) ;
        [rho(freq), pval(freq)] = corr(PSDValueList', UPDRSdeltaList', 'Type', 'Spearman') ;
        freq_list(freq) = freq*PtFq-PtFq+100 ;
    end
elseif strcmp(plotsPt, '10kfilt')
    for freq = 1:round(200/PtFq)
        if freq <= 0.5/PtFq
            PSDValueList = mean(cell2mat(BestChanTableDlt_HFO( (freq         ):(freq+0.5/PtFq) , :)),1) ;
        else
            PSDValueList = mean(cell2mat(BestChanTableDlt_HFO( (freq-0.5/PtFq):(freq+0.5/PtFq) , :)),1) ;
        end
        PSDValueList = PSDValueList(goodlist) ;
        [rho(freq), pval(freq)] = corr(PSDValueList', UPDRSdeltaList', 'Type', 'Spearman') ;
        freq_list(freq) = freq*PtFq-PtFq+100 ;
    end
end
pval = hypoQAMPPE.functions.correction_pval(pval,Method,plotsPt);
% Plot
figure  ;
hold on ;
plot(freq_list, rho , 'DisplayName','Rho', LineWidth=1.5, Color='#a8a6ff')
plot(freq_list, pval, 'DisplayName','p-value', LineWidth=1.5, Color='#18ffad')
legend show
legend ('AutoUpdate', 'off')
freq_list(pval > 0.05) = NaN ;
plot(freq_list, rho , 'DisplayName','Rho', LineWidth=1.5, Color='red')
plot(freq_list, pval, 'DisplayName','p-value', LineWidth=1.5, Color='#0f9d58')
plot([100 300], [0.05 0.05] , 'DisplayName','significatif', LineWidth=0.5, Color='r', LineStyle=':')
plot([100 300], [0 0] , 'DisplayName','0', LineWidth=0.5, Color='#888888')
xlim([100 300])
ylim([min(rho) max(rho)])
saveas(gcf, fullfile(PlotSaveFolder, ['HFO PSD OFF-ON versus UPDRS OFF-ON ' 'AllFq' '_' suffix '.pdf']), 'pdf')
saveas(gcf, fullfile(PlotSaveFolder, ['HFO PSD OFF-ON versus UPDRS OFF-ON ' 'AllFq' '_' suffix '.png']), 'png')
freq_list = [] ;





%% Plot page
if PlotPage

[HighestBetaChR, HighestBetaIdR] = hypoQAMPPE.functions.HighBetaContact(OFF_list,StartBeta,EndBeta,PicOrBand,'raw') ;
[HighestBetaChD, HighestBetaIdD] = hypoQAMPPE.functions.HighBetaContact(OFF_list,StartBeta,EndBeta,PicOrBand,'detail') ;
VerticalNumberOfPat = 3 ;
Peak_ch = 'All' ; % or 'Best' 

element = 0 ;
freqmax = 100;
colors = {'#CAFF33' , '#B5E42E' ,'#9DC529' , '#39FFBB', '#30DFA3', '#29C58F'} ;
warning('off','MATLAB:print:FigureTooLargeForPage')

ChTable = struct('name',{},'HighestBetaRawRight',{},'HighestBetaRawLeft',{},'HighestBetaDetRight',{},'HighestBetaDetLeft',{}, ...
    'RawChAlphaRight',{}, 'RawChLowBetaRight',{}, 'RawChBetaRight',{}, 'RawChGammaRight',{}, ...
    'RawFreqAlphaRight',{}, 'RawFreqLowBetaRight',{},'RawFreqBetaRight',{}, 'RawFreqGammaRight',{},  ...
    'RawChAlphaLeft',{}, 'RawChLowBetaLeft',{}, 'RawChBetaLeft',{}, 'RawChGammaLeft',{},  ...
    'RawFreqAlphaLeft',{}, 'RawFreqLowBetaLeft',{}, 'RawFreqBetaLeft',{}, 'RawFreqGammaLeft',{},  ...
    'DetailChAlphaRight',{}, 'DetailChLowBetaRight',{},'DetailChBetaRight',{}, 'DetailChGammaRight',{},  ...
    'DetailFreqAlphaRight',{}, 'DetailFreqLowBetaRight',{},'DetailFreqBetaRight',{},'DetailFreqGammaRight',{},   ...
    'DetailChAlphaLeft',{}, 'DetailChLowBetaLeft',{},'DetailChBetaLeft',{}, 'DetailChGammaLeft',{},   ...
    'DetailFreqAlphaLeft',{}, 'DetailFreqLowBetaLeft',{}, 'DetailFreqBetaLeft',{}, 'DetailFreqGammaLeft',{}) ;


for el1 = 1:ceil(length(OFF_list)/VerticalNumberOfPat)
    fig = figure('Name', ['PerPat_lot' num2str(el1)],'NumberTitle','off' , 'unit', 'centimeter', 'position', [24.00*4 15.60*2 21 29.7]);
    for el2 = 1:VerticalNumberOfPat 
    if element+1 <= length(OFF_list)
        element = element + 1 ;
        
        ChTable(element).name = OFF_list{1, element}.input(1:5) ;
        ChTable(element).HighestBetaRawRight = HighestBetaIdR{element,1} ;
        ChTable(element).HighestBetaRawLeft  = HighestBetaIdR{element,2} ;
        ChTable(element).HighestBetaDetRight = HighestBetaIdD{element,1} ;
        ChTable(element).HighestBetaDetLeft  = HighestBetaIdD{element,2} ;

        % Raw
        % plot all ch
        g = subplot(VerticalNumberOfPat, 2, 2*el2 - 1) ;
        hold on ;
        valeursRAW = squeeze(OFF_list{1, element}.raw.values{1, 1}  ) ;
        MaxValRAW  = max(max(valeursRAW(500:end,:))) ;
        xlim([2 freqmax]) ;
        ylim([0 0.5*MaxValRAW*(size(valeursRAW, 2)-1)])
        
        % plot all channels
        for ch = 1 : size(valeursRAW, 2) 
            plot(OFF_list{1, element}.raw.f, valeursRAW(:,ch) + 0.2*MaxValRAW*(ch-1), 'color', colors{ch}, 'DisplayName',OFF_list{1, element}.raw.labels(1, ch).name , 'LineWidth', 0.2  ) 
            text(freqmax - 5, 0.2*MaxValRAW*(ch-1)+0.05*MaxValRAW, OFF_list{1, element}.raw.labels(1, ch).name   ,'FontSize',14,'FontWeight','bold', 'Color',colors{ch})
        end

        % select peaks
        for LeftRight = 1:2  % show selected peak
                IdChA = NaN ;
                IdChL = NaN ;
                IdChB = NaN ;
                IdChG = NaN ;
                FreqA = NaN ;
                FreqL = NaN ;
                FreqB = NaN ;
                FreqG = NaN ;
            if ~isnan(HighestBetaIdR{element,LeftRight})
                Hbeta = HighestBetaIdR{element,LeftRight} ;
                [IdChA, FreqA, Autoscore] = hypoQAMPPE.functions.PeakFinder('AllCh1Pat', Peak_ch, Hbeta, valeursRAW, StartAlpha, StartBeta, PtFq, LeftRight) ;
                [IdChB, FreqB, Autoscore] = hypoQAMPPE.functions.PeakFinder('AllCh1Pat', Peak_ch, Hbeta, valeursRAW, StartBeta,  EndBeta,   PtFq, LeftRight) ;
                [IdChG, FreqG, Autoscore] = hypoQAMPPE.functions.PeakFinder('AllCh1Pat', Peak_ch, Hbeta, valeursRAW, StartGamma, EndGamma,  PtFq, LeftRight) ;
                plot([FreqA FreqA],[0.2*MaxValRAW*(IdChA-1) (valeursRAW(round(FreqA/PtFq),IdChA))+0.2*MaxValRAW*(IdChA-1)],'color','#0016a3')
                plot([FreqB FreqB],[0.2*MaxValRAW*(IdChB-1) (valeursRAW(round(FreqB/PtFq),IdChB))+0.2*MaxValRAW*(IdChB-1)],'color','#0016a3')
                plot([FreqG FreqG],[0.2*MaxValRAW*(IdChG-1) (valeursRAW(round(FreqG/PtFq),IdChG))+0.2*MaxValRAW*(IdChG-1)],'color','#0016a3')
                if FreqB > MidBeta
                    [IdChL, FreqL, Autoscore] = hypoQAMPPE.functions.PeakFinder('AllCh1Pat', Peak_ch, Hbeta, valeursRAW, StartBeta,  MidBeta,   PtFq, LeftRight) ;
                    plot([FreqL FreqL],[0.2*MaxValRAW*(IdChL-1) (valeursRAW(round(FreqL/PtFq),IdChL))+0.2*MaxValRAW*(IdChL-1)],'color','red')
                    text(10, (0.35+0.05*LeftRight)*MaxValRAW*(size(valeursRAW, 2)-1), ['Î± ' OFF_list{1, element}.raw.labels(1, IdChA).name ' '  num2str(round(FreqA,1)) 'Hz - Î² '  OFF_list{1, element}.raw.labels(1, IdChB).name ' '  num2str(round(FreqB,1)) 'Hz - LowÎ² ' OFF_list{1, element}.raw.labels(1, IdChL).name ' ' num2str(round(FreqL,1)) 'Hz - Î³ ' OFF_list{1, element}.raw.labels(1, IdChG).name ' '  num2str(round(FreqG,1)) 'Hz' ]  ,'FontSize',7)
                else
                    IdChL = IdChB ;
                    FreqL = FreqB ;
                    text(10, (0.35+0.05*LeftRight)*MaxValRAW*(size(valeursRAW, 2)-1), ['Î± ' OFF_list{1, element}.raw.labels(1, IdChA).name ' '  num2str(round(FreqA,1)) 'Hz - Î²+LÎ² '  OFF_list{1, element}.raw.labels(1, IdChB).name ' '  num2str(round(FreqB,1)) 'Hz - Î³ ' OFF_list{1, element}.raw.labels(1, IdChG).name ' '  num2str(round(FreqG,1)) 'Hz' ]  ,'FontSize',7)
                end
            end
            if LeftRight == 1
                ChTable(element).RawChAlphaRight = IdChA ;
                ChTable(element).RawChLowBetaRight = IdChL ;
                ChTable(element).RawChBetaRight  = IdChB ;
                ChTable(element).RawChGammaRight = IdChG ;
                ChTable(element).RawFreqAlphaRight = FreqA ;
                ChTable(element).RawFreqLowBetaRight = FreqL ;
                ChTable(element).RawFreqBetaRight  = FreqB ;
                ChTable(element).RawFreqGammaRight = FreqG ;
            else
                ChTable(element).RawChAlphaLeft = IdChA ;
                ChTable(element).RawChLowBetaLeft  = IdChL ;
                ChTable(element).RawChBetaLeft = IdChB ;
                ChTable(element).RawChGammaLeft = IdChG ;
                ChTable(element).RawFreqAlphaLeft = FreqA ;
                ChTable(element).RawFreqLowBetaLeft  = FreqL ;
                ChTable(element).RawFreqBetaLeft = FreqB ;
                ChTable(element).RawFreqGammaLeft = FreqG ;
            end
        end 
        
        % Highest beta
        for LeftRight = 1:2 ; if ~isnan(HighestBetaIdR{element,LeftRight}) 
            text(freqmax - 7, 0.2*MaxValRAW*(HighestBetaIdR{element,LeftRight}-1)+0.05*MaxValRAW, 'Î²'  ,'FontSize',14,'FontWeight','bold', 'Color','red')
            plot(OFF_list{1, element}.raw.f, valeursRAW(:,HighestBetaIdR{element,LeftRight}) + 0.2*MaxValRAW*(HighestBetaIdR{element,LeftRight}-1), 'color','red', 'DisplayName', HighestBetaChR{element,LeftRight} , 'LineWidth', 0.4, LineStyle='--'  ) 
        end ;  end
        title (g, [num2str(element) '/' num2str(length(OFF_list)) ' : RAW - ' OFF_list{1, element}.input(1:5) ])
        
        % Detailed : DIFFERENCES WITH RAW COMMENTED
        g = subplot(VerticalNumberOfPat, 2, 2*el2 ) ;  % +1
        hold on ;
        valeursRAW = squeeze(OFF_list{1, element}.detail.values{1, 1}  ) ; % ON GARDE QD MEME VAR NOMMEES RAW
        MaxValRAW  = max(max(valeursRAW(500:end,:))) ;
        xlim([2 freqmax]) ;
        ylim([0 0.3*MaxValRAW*(size(valeursRAW, 2)-1)]) % MOINS GRANDE VARIABILITE
        
        % plot all channels = CHANGE RAW TO DETAIL
        for ch = 1 : size(valeursRAW, 2)
            plot(OFF_list{1, element}.detail.f, valeursRAW(:,ch) + 0.2*MaxValRAW*(ch-1), 'color', colors{ch}, 'DisplayName',OFF_list{1, element}.detail.labels(1, ch).name , 'LineWidth', 0.2  ) 
            text(freqmax - 5, 0.2*MaxValRAW*(ch-1)+0.05*MaxValRAW, OFF_list{1, element}.detail.labels(1, ch).name   ,'FontSize',14,'FontWeight','bold', 'Color',colors{ch})
        end
        
        % select peaks = ONLY CHANGE TEXT PLOT LOCATION + HighestBetaIdR to D
        for LeftRight = 1:2 
                IdChA = NaN ;
                IdChL = NaN ;
                IdChB = NaN ;
                IdChG = NaN ;
                FreqA = NaN ;
                FreqL = NaN ;
                FreqB = NaN ;
                FreqG = NaN ;
            if ~isnan(HighestBetaIdD{element,LeftRight}) % show selected peak
                Hbeta = HighestBetaIdD{element,LeftRight} ;
                [IdChA, FreqA, Autoscore] = hypoQAMPPE.functions.PeakFinder('AllCh1Pat', Peak_ch, Hbeta, valeursRAW, StartAlpha, StartBeta, PtFq, LeftRight) ;
                [IdChB, FreqB, Autoscore] = hypoQAMPPE.functions.PeakFinder('AllCh1Pat', Peak_ch, Hbeta, valeursRAW, StartBeta, EndBeta,    PtFq, LeftRight) ;
                if FreqB > MidBeta
                    [IdChL, FreqL, Autoscore] = hypoQAMPPE.functions.PeakFinder('AllCh1Pat', Peak_ch, Hbeta, valeursRAW, StartBeta, MidBeta,    PtFq, LeftRight) ;
                end
                [IdChG, FreqG, Autoscore] = hypoQAMPPE.functions.PeakFinder('AllCh1Pat', Peak_ch, Hbeta, valeursRAW, StartGamma, EndGamma,  PtFq, LeftRight) ;
                plot([FreqA FreqA],[0.2*MaxValRAW*(IdChA-1) (valeursRAW(round(FreqA/PtFq),IdChA))+0.2*MaxValRAW*(IdChA-1)],'color','#0016a3')
                plot([FreqB FreqB],[0.2*MaxValRAW*(IdChB-1) (valeursRAW(round(FreqB/PtFq),IdChB))+0.2*MaxValRAW*(IdChB-1)],'color','#0016a3')
                plot([FreqG FreqG],[0.2*MaxValRAW*(IdChG-1) (valeursRAW(round(FreqG/PtFq),IdChG))+0.2*MaxValRAW*(IdChG-1)],'color','#0016a3')
                if FreqB > MidBeta
                    [IdChL, FreqL, Autoscore] = hypoQAMPPE.functions.PeakFinder('AllCh1Pat', Peak_ch, Hbeta, valeursRAW, StartBeta, MidBeta,    PtFq, LeftRight) ;
                    plot([FreqL FreqL],[0.2*MaxValRAW*(IdChL-1) (valeursRAW(round(FreqL/PtFq),IdChL))+0.2*MaxValRAW*(IdChL-1)],'color','red')
                    text(10, (0.70+0.1*LeftRight)*0.3*MaxValRAW*(size(valeursRAW, 2)-1), ['Î± ' OFF_list{1, element}.raw.labels(1, IdChA).name ' '  num2str(round(FreqA,1)) 'Hz - Î² '  OFF_list{1, element}.raw.labels(1, IdChB).name ' '  num2str(round(FreqB,1)) 'Hz - LowÎ² ' OFF_list{1, element}.raw.labels(1, IdChL).name ' ' num2str(round(FreqL,1)) 'Hz - Î³ ' OFF_list{1, element}.raw.labels(1, IdChG).name ' '  num2str(round(FreqG,1)) 'Hz' ]  ,'FontSize',7)
                else
                    IdChL = IdChB ;
                    FreqL = FreqB ;
                    text(10, (0.70+0.1*LeftRight)*0.3*MaxValRAW*(size(valeursRAW, 2)-1), ['Î± ' OFF_list{1, element}.raw.labels(1, IdChA).name ' '  num2str(round(FreqA,1)) 'Hz - Î²+LÎ² '  OFF_list{1, element}.raw.labels(1, IdChB).name ' '  num2str(round(FreqB,1)) 'Hz - Î³ ' OFF_list{1, element}.raw.labels(1, IdChG).name ' '  num2str(round(FreqG,1)) 'Hz' ]  ,'FontSize',7)
                end
            end
            if LeftRight == 1
                ChTable(element).DetailChAlphaRight = IdChA ;
                ChTable(element).DetailChLowBetaRight  = IdChL ;
                ChTable(element).DetailChBetaRight = IdChB ;
                ChTable(element).DetailChGammaRight = IdChG ;
                ChTable(element).DetailFreqAlphaRight = FreqA ;
                ChTable(element).DetailFreqLowBetaRight  = FreqL ;
                ChTable(element).DetailFreqBetaRight = FreqB ;
                ChTable(element).DetailFreqGammaRight = FreqG ;
            else
                ChTable(element).DetailChAlphaLeft = IdChA ;
                ChTable(element).DetailChLowBetaLeft  = IdChL ;
                ChTable(element).DetailChBetaLeft = IdChB ;
                ChTable(element).DetailChGammaLeft = IdChG ;
                ChTable(element).DetailFreqAlphaLeft = FreqA ;
                ChTable(element).DetailFreqLowBetaLeft  = FreqL ;
                ChTable(element).DetailFreqBetaLeft = FreqB ;
                ChTable(element).DetailFreqGammaLeft = FreqG ;
            end
        end 
        
        % Highest beta = CHANGE RAW TO DETAIL
        for LeftRight = 1:2 ; if ~isnan(HighestBetaIdD{element,LeftRight})
            text(freqmax - 7, 0.2*MaxValRAW*(HighestBetaIdD{element,LeftRight}-1)+0.05*MaxValRAW, 'Î²'  ,'FontSize',14,'FontWeight','bold', 'Color','red')
            plot(OFF_list{1, element}.detail.f, valeursRAW(:,HighestBetaIdD{element,LeftRight}) + 0.2*MaxValRAW*(HighestBetaIdD{element,LeftRight}-1), 'color','red', 'DisplayName', HighestBetaChD{element,LeftRight} , 'LineWidth', 0.4, LineStyle='--'  ) 
        end ;  end
        title (g, [num2str(element) '/' num2str(length(OFF_list)) ' : Detailed - ' OFF_list{1, element}.input(1:5) ])
        
    end
    end
    saveas(fig, fullfile(PlotSaveFolder, ['PerPat_lot' num2str(el1) '_' suffix '.pdf']), 'pdf')
    close(fig)
end

ChTable           = struct2table(ChTable) ;
ContactsCliniques = hypoQAMPPE.load.ClinicalContacts(ClinicalData.Old) ;
ChTable           = join(ChTable, ContactsCliniques, 'Keys', 'name') ;
writetable(ChTable, fullfile(PlotSaveFolder, ['ChTable_' suffix '.csv']))

warning('on','MATLAB:print:FigureTooLargeForPage')
fprintf(2, ['\n \n      ATTENTION !!! \n Bien enregistrer et renommer selon parametres d''entrÃ©e \n'])

% Plot stats of ChTable
% Voir PPT hQ nÂ°4 du 6 juin 2023
end

%% Peaks : Populations
PeakRanking = categorical(            {'Plat','?Plat?','Flou','AutrePic','?Pic?','Pic'});
PeakRanking = reordercats(PeakRanking,{'Plat','?Plat?','Flou','AutrePic','?Pic?','Pic'});
% alpha
bar(PeakRanking, [histcounts(PeakTable.raw_A_D, [-1 0.5 1.5 2.5 3.5 4.5 6]) ; histcounts(PeakTable.raw_A_G, [-1 0.5 1.5 2.5 3.5 4.5 6]) ; histcounts(PeakTable.det_A_D, [-1 0.5 1.5 2.5 3.5 4.5 6]) ; histcounts(PeakTable.det_A_G, [-1 0.5 1.5 2.5 3.5 4.5 6]) ]'  ) ; legend({'raw_D', 'raw_G', 'det_D', 'det_G'}, "Interpreter", "none", "Location", "best"); title('Alpha')
% Low beta
bar(PeakRanking, [histcounts(PeakTable.raw_LB_D, [-1 0.5 1.5 2.5 3.5 4.5 6]) ; histcounts(PeakTable.raw_LB_G, [-1 0.5 1.5 2.5 3.5 4.5 6]) ; histcounts(PeakTable.det_LB_D, [-1 0.5 1.5 2.5 3.5 4.5 6]) ; histcounts(PeakTable.det_LB_G, [-1 0.5 1.5 2.5 3.5 4.5 6]) ]'  ) ; legend({'raw_D', 'raw_G', 'det_D', 'det_G'}, "Interpreter", "none", "Location", "best"); title('Beta')
% beta
bar(PeakRanking, [histcounts(PeakTable.raw_B_D, [-1 0.5 1.5 2.5 3.5 4.5 6]) ; histcounts(PeakTable.raw_B_G, [-1 0.5 1.5 2.5 3.5 4.5 6]) ; histcounts(PeakTable.det_B_D, [-1 0.5 1.5 2.5 3.5 4.5 6]) ; histcounts(PeakTable.det_B_G, [-1 0.5 1.5 2.5 3.5 4.5 6]) ]'  ) ; legend({'raw_D', 'raw_G', 'det_D', 'det_G'}, "Interpreter", "none", "Location", "best"); title('Beta')
% gamma
bar(PeakRanking, [histcounts(PeakTable.raw_G_D, [-1 0.5 1.5 2.5 3.5 4.5 6]) ; histcounts(PeakTable.raw_G_G, [-1 0.5 1.5 2.5 3.5 4.5 6]) ; histcounts(PeakTable.det_G_D, [-1 0.5 1.5 2.5 3.5 4.5 6]) ; histcounts(PeakTable.det_G_G, [-1 0.5 1.5 2.5 3.5 4.5 6]) ]'  ) ; legend({'raw_D', 'raw_G', 'det_D', 'det_G'}, "Interpreter", "none", "Location", "best"); title('Gamma')


%% Peaks : Patients
HasGamma = zeros(length(PeakTable.raw_G_D), 1) ;
HasGamma(PeakTable.raw_G_D == PeakProminance | PeakTable.raw_G_G == PeakProminance  | PeakTable.det_G_D == PeakProminance  | PeakTable.det_G_G == PeakProminance ) = 1 ;
HasBeta = zeros(length(PeakTable.raw_B_D), 1) ;
HasBeta(PeakTable.raw_B_D == PeakProminance | PeakTable.raw_B_G == PeakProminance  | PeakTable.det_B_D == PeakProminance  | PeakTable.det_B_G == PeakProminance ) = 1 ;
HasAlpha = zeros(length(PeakTable.raw_A_D), 1) ;
HasAlpha(PeakTable.raw_A_D == PeakProminance | PeakTable.raw_A_G == PeakProminance  | PeakTable.det_A_D == PeakProminance  | PeakTable.det_A_G == PeakProminance ) = 1 ;

SumPat = HasAlpha + HasBeta + HasGamma ;
SumPatBG = HasBeta + HasGamma ;
histogram(SumPat, -0.5:1:3.5)
histogram(SumPatBG, -1.:2.5:4.5)
disp(num2str(sum(HasAlpha + HasGamma == 2)))

HasGamma = zeros(length(PeakTable.raw_G_D), 1) ;
HasBeta = zeros(length(PeakTable.raw_B_D), 1) ;
HasAlpha = zeros(length(PeakTable.raw_A_D), 1) ;
HasGamma(PeakTable.raw_G_D > 3 | PeakTable.raw_G_G > 3  | PeakTable.det_G_D > 3  | PeakTable.det_G_G > 3 ) = 1 ;
HasBeta( PeakTable.raw_B_D > 3 | PeakTable.raw_B_G > 3  | PeakTable.det_B_D > 3  | PeakTable.det_B_G > 3 ) = 1 ;
HasAlpha(PeakTable.raw_A_D > 3 | PeakTable.raw_A_G > 3  | PeakTable.det_A_D > 3  | PeakTable.det_A_G > 3 ) = 1 ;

SumPat = HasAlpha + HasBeta + HasGamma ;
SumPatBG = HasBeta + HasGamma ;
histogram(SumPat, -0.5:1:3.5)
histogram(SumPatBG, -1.:2.5:4.5)
disp(num2str(sum(HasAlpha + HasGamma == 2)))

%% Peaks : Localisation

ChTableQual = ChTable ;
ChTableQual.RawChGammaRight(PeakTable.raw_G_D ~= PeakProminance) = NaN ;
ChTableQual.RawChGammaLeft(PeakTable.raw_G_G ~= PeakProminance) = NaN ;
ChTableQual.DetailChGammaRight(PeakTable.det_G_D ~= PeakProminance) = NaN ;
ChTableQual.DetailChGammaLeft(PeakTable.det_G_G ~= PeakProminance) = NaN ;
ChTableQual.RawChBetaRight(PeakTable.raw_B_D ~= PeakProminance) = NaN ;
ChTableQual.RawChBetaLeft(PeakTable.raw_B_G ~= PeakProminance) = NaN ;
ChTableQual.DetailChBetaRight(PeakTable.det_B_D ~= PeakProminance) = NaN ;
ChTableQual.DetailChBetaLeft(PeakTable.det_B_G ~= PeakProminance) = NaN ;
ChTableQual.RawChAlphaRight(PeakTable.raw_A_D ~= PeakProminance) = NaN ;
ChTableQual.RawChAlphaLeft(PeakTable.raw_A_G ~= PeakProminance) = NaN ;
ChTableQual.DetailChAlphaRight(PeakTable.det_A_D ~= PeakProminance) = NaN ;
ChTableQual.DetailChAlphaLeft(PeakTable.det_A_G ~= PeakProminance) = NaN ;
ChTableQual.RawChLowBetaRight(PeakTable.raw_LB_D ~= PeakProminance) = NaN ;
ChTableQual.RawChLowBetaLeft(PeakTable.raw_LB_G ~= PeakProminance) = NaN ;
ChTableQual.DetailChLowBetaRight(PeakTable.det_LB_D ~= PeakProminance) = NaN ;
ChTableQual.DetailChLowBetaLeft(PeakTable.det_LB_G ~= PeakProminance) = NaN ;

ChTableQual.RawFreqGammaRight(PeakTable.raw_G_D ~= PeakProminance) = NaN ;
ChTableQual.RawFreqGammaLeft(PeakTable.raw_G_G ~= PeakProminance) = NaN ;
ChTableQual.DetailFreqGammaRight(PeakTable.det_G_D ~= PeakProminance) = NaN ;
ChTableQual.DetailFreqGammaLeft(PeakTable.det_G_G ~= PeakProminance) = NaN ;
ChTableQual.RawFreqBetaRight(PeakTable.raw_B_D ~= PeakProminance) = NaN ;
ChTableQual.RawFreqBetaLeft(PeakTable.raw_B_G ~= PeakProminance) = NaN ;
ChTableQual.DetailFreqBetaRight(PeakTable.det_B_D ~= PeakProminance) = NaN ;
ChTableQual.DetailFreqBetaLeft(PeakTable.det_B_G ~= PeakProminance) = NaN ;
ChTableQual.RawFreqAlphaRight(PeakTable.raw_A_D ~= PeakProminance) = NaN ;
ChTableQual.RawFreqAlphaLeft(PeakTable.raw_A_G ~= PeakProminance) = NaN ;
ChTableQual.DetailFreqAlphaRight(PeakTable.det_A_D ~= PeakProminance) = NaN ;
ChTableQual.DetailFreqAlphaLeft(PeakTable.det_A_G ~= PeakProminance) = NaN ;
ChTableQual.RawFreqLowBetaRight(PeakTable.raw_LB_D ~= PeakProminance) = NaN ;
ChTableQual.RawFreqLowBetaLeft(PeakTable.raw_LB_G ~= PeakProminance) = NaN ;
ChTableQual.DetailFreqLowBetaRight(PeakTable.det_LB_D ~= PeakProminance) = NaN ;
ChTableQual.DetailFreqLowBetaLeft(PeakTable.det_LB_G ~= PeakProminance) = NaN ;

figure() ; hold on ; for row = 1:size(ChTableQual,1) ; plot(table2array(ChTableQual(row, [6:9   22:25]))+(0.3*rand()-0.15), "LineWidth", 0.1) ; end ; xlim([0.5,8.5]) ; grid on
figure() ; hold on ; for row = 1:size(ChTableQual,1) ; plot(table2array(ChTableQual(row, [14:17 30:33]))+(0.3*rand()-0.15), "LineWidth", 0.1) ; end ; xlim([0.5,8.5]) ; grid on

figure('unit', 'centimeter', 'position', [5 5 20 8]) ; subplot(1,2,1) ; hold on ; histogram([ChTableQual.RawFreqGammaLeft , ChTableQual.RawFreqGammaRight],"BinWidth",0.5); title("Frequences : Gamma Raw") ; subplot(1,2,2) ; histogram([ChTableQual.DetailFreqGammaLeft , ChTableQual.DetailFreqGammaRight],"BinWidth",0.5); title("Frequences : Gamma det")  
figure('unit', 'centimeter', 'position', [5 5 20 8]) ; subplot(1,2,1) ; hold on ; histogram([ChTableQual.RawFreqBetaLeft , ChTableQual.RawFreqBetaRight],"BinWidth",0.5); title("Frequences : Beta Raw") ; subplot(1,2,2) ; histogram([ChTableQual.DetailFreqBetaLeft , ChTableQual.DetailFreqBetaRight],"BinWidth",0.5); title("Frequences : Beta det")
figure('unit', 'centimeter', 'position', [5 5 20 8]) ; subplot(1,2,1) ; hold on ; histogram([ChTableQual.RawFreqAlphaLeft , ChTableQual.RawFreqAlphaRight],"BinWidth",0.5); title("Frequences : Alpha Raw") ; subplot(1,2,2) ; histogram([ChTableQual.DetailFreqAlphaLeft , ChTableQual.DetailFreqAlphaRight],"BinWidth",0.5); title("Frequences : Alpha det")
figure('unit', 'centimeter', 'position', [5 5 20 8]) ; subplot(1,2,1) ; hold on ; histogram([ChTableQual.RawFreqLowBetaLeft , ChTableQual.RawFreqLowBetaRight],"BinWidth",0.5); title("Frequences : Low Beta Raw") ; subplot(1,2,2) ; histogram([ChTableQual.DetailFreqLowBetaLeft , ChTableQual.DetailFreqLowBetaRight],"BinWidth",0.5); title("Frequences : Low Beta det")

figure() ; histogram([ChTable2.RightClinicalContact-ChTable2.DetailChLowBetaRight , ChTable2.LeftClinicalContact+3-ChTable2.DetailChLowBetaLeft] ,"BinWidth",0.4) ; title("Pic vs ContactTherap : Low Beta") ; grid on
figure() ; histogram([ChTable2.RightClinicalContact-ChTable2.DetailChBetaRight    , ChTable2.LeftClinicalContact+3-ChTable2.DetailChBetaLeft]    ,"BinWidth",0.4) ; title("Pic vs ContactTherap : Beta") ; grid on
figure() ; histogram([ChTable2.RightClinicalContact-ChTable2.DetailChAlphaRight   , ChTable2.LeftClinicalContact+3-ChTable2.DetailChAlphaLeft]   ,"BinWidth",0.4) ; title("Pic vs ContactTherap : Alpha") ; grid on
figure() ; histogram([ChTable2.RightClinicalContact-ChTable2.DetailChGammaRight   , ChTable2.LeftClinicalContact+3-ChTable2.DetailChGammaLeft]   ,"BinWidth",0.4) ; title("Pic vs ContactTherap : Gamma") ; grid on



%% Beta Gamma Score Correlation 
%% Formula finder
% Parameters

% clc
for PicOrBand_for_scoringCell = {'2pic' '2band' 'BpicGband-HB' 'BpicGband-BpicContact' 'BpicGband-ClinContact' }
    PicOrBand_for_scoring = cell2mat(PicOrBand_for_scoringCell) ;
    disp(' ')   ; disp(' ')   
    disp('######################################################')   
    disp(PicOrBand_for_scoring)
    disp('######################################################') ; disp(' ')   

for Width = [0 3]
for iTbi = 1:12
    iT = mod(iTbi,6)+1 ;
    if iT == 1
ClinicalFileToUse = 'New' ;
    else
ClinicalFileToUse = 'Old' ;
    end
    if iT == 2
        U3bilat = 'hemibody' ; % 'bilat' if you want to use normal UPDRS-III (bilateral) instead of 'hemibody' for the Left / Right hemibody one
    else
        U3bilat = 'bilat' ; % 'bilat' if you want to use normal UPDRS-III (bilateral) instead of 'hemibody' for the Left / Right hemibody one
    end
    if iT < 4
Timing_to_Use = 'pre' ; % 'pre', 'OffPreOnStim' 'OffPreBestOn' or 'WorseOffBestOn'
    elseif iT == 4
Timing_to_Use = 'OffPreOnStim' ; % 'pre', 'OffPreOnStim' 'OffPreBestOn' or 'WorseOffBestOn'
    elseif iT == 5
Timing_to_Use = 'OffPreBestOn' ; % 'pre', 'OffPreOnStim' 'OffPreBestOn' or 'WorseOffBestOn'
    elseif iT == 6
Timing_to_Use = 'WorseOffBestOn' ; % 'pre', 'OffPreOnStim' 'OffPreBestOn' or 'WorseOffBestOn'
    end
    if iTbi < 7
        Operation = 'diff' ; % 'diff' or 'ratio', 'PolynomBeta' and 'PolynomGamma', or 'ExpBeta' and 'ExpGamma'
    elseif iTbi > 6
        Operation = 'ratio' ; % 'diff' or 'ratio', 'PolynomBeta' and 'PolynomGamma', or 'ExpBeta' and 'ExpGamma'
    end
    [NameAndNum] = hypoQAMPPE.functions.MatchingTable(OFF_list,ON_list,ClinicalData,contact_to_use, ClinicalFileToUse, U3bilat,StartBeta,EndBeta,PicOrBand,Type_of_Spectrum, Timing_to_Use) ;
if strcmp(Operation,'diff')
    ListCoeff = [-1000:10:-500 -500:10:-100 -100:0.1:-10 -10:0.01:-1 -1:0.001:1 1:0.01:10 10:0.1:100 100:10:500 500:10:1000] ;
elseif strcmp(Operation,'ratio')
    ListCoeff = 1 ;
else
    ListCoeff = [0:50000000000000:1000000000000000 0.0000000000000001 -2 0.01:0.01:1 0.0001:0.0001:0.01 1:1:10 10:10:1000 10000:10000:1000000] ;
end
%+Start/End gamma, ...
% Compute score
ChCell = table2cell(ChTable) ;
BESTrho = 0 ;
BESTpval = 1 ;
UPDRSdeltaList = [] ;
scoreBG = zeros(size(patON));
plist=[];
rholist=[];
warn2raise = '' ;
% Clinical Data
for pat = 1:length(patON)
    UPDRSdeltaList(pat) = NameAndNum{strcmp(patON(pat), NameAndNum(:, 1)),8+LeftRightON(pat)} - NameAndNum{strcmp(patON(pat), NameAndNum(:, 1)),9+LeftRightON(pat)} ;
end
goodlist = ~isnan(UPDRSdeltaList) ;
UPDRSdeltaList = UPDRSdeltaList(goodlist) ;
if strcmp(PicOrBand_for_scoring, '2pic')
    for idx = 1:length(patON)
        row_idx = find(strcmp(ChTable.name, patON{idx}));
        for i2 = 1:length(ON_list)
            if strcmp(extractBefore(ON_list{1, i2}.input ,'_'), patON{idx})
                on_idx = i2 ;
                break
            end
        end
        lenON = min(length(squeeze(ON_list{1, on_idx}.(Type_of_Spectrum).values{1, 1}(1,:,ChCell{row_idx,25}))' ), length(squeeze(OFF_list{1, row_idx}.(Type_of_Spectrum).values{1, 1}(1,:,ChCell{row_idx,24}))' )) ;
        if LeftRightON(idx) == 2 % Left
            values = num2cell(squeeze(OFF_list{1, row_idx}.(Type_of_Spectrum).values{1, 1}(1,1:lenON,ChCell{row_idx,33}))' - squeeze(ON_list{1, on_idx}.(Type_of_Spectrum).values{1, 1}(1,1:lenON,ChCell{row_idx,33}))' ) ;
            gammaVAL(idx) = mean(cell2mat(values(round(ChCell{row_idx,37}/PtFq-Width/PtFq):round(ChCell{row_idx,37}/PtFq+Width/PtFq))));
            values = num2cell(squeeze(OFF_list{1, row_idx}.(Type_of_Spectrum).values{1, 1}(1,1:lenON,ChCell{row_idx,32}))' - squeeze(ON_list{1, on_idx}.(Type_of_Spectrum).values{1, 1}(1,1:lenON,ChCell{row_idx,32}))' ) ;
            betaVAL(idx)  = mean(cell2mat(values(round(ChCell{row_idx,36}/PtFq-Width/PtFq):round(ChCell{row_idx,36}/PtFq+Width/PtFq)))) ;
        else
            values = num2cell(squeeze(OFF_list{1, row_idx}.(Type_of_Spectrum).values{1, 1}(1,1:lenON,ChCell{row_idx,25}))' - squeeze(ON_list{1, on_idx}.(Type_of_Spectrum).values{1, 1}(1,1:lenON,ChCell{row_idx,25}))' ) ;
            gammaVAL(idx) = mean(cell2mat(values(round(ChCell{row_idx,29}/PtFq-Width/PtFq):round(ChCell{row_idx,29}/PtFq+Width/PtFq)))) ;
            values = num2cell(squeeze(OFF_list{1, row_idx}.(Type_of_Spectrum).values{1, 1}(1,1:lenON,ChCell{row_idx,24}))' - squeeze(ON_list{1, on_idx}.(Type_of_Spectrum).values{1, 1}(1,1:lenON,ChCell{row_idx,24}))' ) ;
            betaVAL(idx)  = mean(cell2mat(values(round(ChCell{row_idx,28}/PtFq-Width/PtFq):round(ChCell{row_idx,28}/PtFq+Width/PtFq)))) ;
        end
        if ~strcmp(patON{idx}, extractBefore(ON_list{1, on_idx}.input ,'_'))
            error()
        end
    end
elseif strcmp(PicOrBand_for_scoring, 'BpicGband-HB')
    warn2raise = 'Make sure that HighestBeta is selected and ExtractPSD... has been run' ;
elseif strcmp(PicOrBand_for_scoring, 'BpicGband-ClinContact')
    warn2raise = 'Make sure that ClinContact is selected and ExtractPSD... has been run' ;
elseif strcmp(PicOrBand_for_scoring, 'BpicGband-BpicContact')
    for idx = 1:length(patON)
        row_idx = find(strcmp(ChTable.name, patON{idx}));
        for i2 = 1:length(ON_list)
            if strcmp(extractBefore(ON_list{1, i2}.input ,'_'), patON{idx})
                on_idx = i2 ;
                break
            end
        end
        lenON = min(length(squeeze(ON_list{1, on_idx}.(Type_of_Spectrum).values{1, 1}(1,:,ChCell{row_idx,25}))' ), length(squeeze(OFF_list{1, row_idx}.(Type_of_Spectrum).values{1, 1}(1,:,ChCell{row_idx,24}))' )) ;
        if LeftRightON(idx) == 2 % Left
            values = num2cell(squeeze(OFF_list{1, row_idx}.(Type_of_Spectrum).values{1, 1}(1,1:lenON,ChCell{row_idx,32}))' - squeeze(ON_list{1, on_idx}.(Type_of_Spectrum).values{1, 1}(1,1:lenON,ChCell{row_idx,32}))' ) ;
            betaVAL(idx)  = mean(cell2mat(values(round(ChCell{row_idx,36}/PtFq - Width/PtFq):round(ChCell{row_idx,36}/PtFq + Width/PtFq)))) ;
            gammaVAL(idx) = mean(cell2mat(values(round(StartGamma/PtFq):round(EndGamma/PtFq))) );
        else
            values = num2cell(squeeze(OFF_list{1, row_idx}.(Type_of_Spectrum).values{1, 1}(1,1:lenON,ChCell{row_idx,24}))' - squeeze(ON_list{1, on_idx}.(Type_of_Spectrum).values{1, 1}(1,1:lenON,ChCell{row_idx,24}))' ) ;
            betaVAL(idx)  = mean(cell2mat(values(round(ChCell{row_idx,28}/PtFq - Width/PtFq):round(ChCell{row_idx,28}/PtFq + Width/PtFq)))) ;
            gammaVAL(idx) = mean(cell2mat(values(round(StartGamma/PtFq):round(EndGamma/PtFq))) ) ;
        end
        if ~strcmp(patON{idx}, extractBefore(ON_list{1, on_idx}.input ,'_')) ; error() ;   end
    end
elseif strcmp(PicOrBand_for_scoring, '2band')
            gammaVAL(idx) = mean(cell2mat(BestChanTableDlt(round(StartGamma/PtFq):round(EndGamma/PtFq), idx))) ;
            betaVAL(idx)  = mean(cell2mat(BestChanTableDlt(round(StartBeta/PtFq):round(EndBeta/PtFq), idx))) ;
end 
if ~strcmp(warn2raise,'')
    for idx = 1:length(patON)
        row_idx = find(strcmp(ChTable.name, patON{idx}));
        gammaVAL(idx) = mean(cell2mat(BestChanTableDlt(round(StartGamma/PtFq):round(EndGamma/PtFq), idx))) ;
        if LeftRightON(idx) == 0 % Left
            betaVAL(idx)  = mean(cell2mat(BestChanTableDlt(round(ChCell{row_idx,28}/PtFq - Width/PtFq):round(ChCell{row_idx,28}/PtFq + Width/PtFq), idx))) ;
        elseif LeftRightON(idx) == 2
            betaVAL(idx)  = mean(cell2mat(BestChanTableDlt(round(ChCell{row_idx,36}/PtFq - Width/PtFq):round(ChCell{row_idx,36}/PtFq + Width/PtFq), idx))) ;
        else ; error() ; end
    end
end

for Coefficient = ListCoeff
    for idx = 1:length(patON)
        gamma = gammaVAL(idx);
        beta  = betaVAL(idx) ;
        if strcmp(Operation, 'diff')
            scoreBG(idx) = beta-(Coefficient*gamma) ;
        elseif strcmp(Operation, 'ratio')
            scoreBG(idx) = Coefficient*beta/(gamma) ;
        elseif strcmp(Operation, 'PolynomBeta')
            scoreBG(idx) = (beta^Coefficient)/(gamma) ;
        elseif strcmp(Operation, 'PolynomGamma')
            scoreBG(idx) = (beta)/(gamma^Coefficient) ;
        elseif strcmp(Operation, 'ExpBeta')
            scoreBG(idx) = (Coefficient^beta)/(gamma) ;
        elseif strcmp(Operation, 'ExpGamma')
            scoreBG(idx) = (beta)/(Coefficient^gamma) ;
        end
        
    end
    % Calculate correlation
    scoreBG   = scoreBG(goodlist);
    [rho, pval] = corr(scoreBG', UPDRSdeltaList', 'Type', 'Spearman') ;
    
    if pval < BESTpval
        BESTpval = pval ;
        Coefficient_of_bestpval = Coefficient ;
        rho_of_bestpval = rho ;
    end
    if abs(rho) > abs(BESTrho)
        BESTrho = rho ;
        Coefficient_of_bestrho = Coefficient ;
        pval_of_bestrho = pval ;
    end
    plist = [plist, pval] ;
    rholist = [rholist, rho] ;
end

disp([' '])
disp([ Type_of_Spectrum ' & ' Normalisation ' - ' Timing_to_Use  ' -> ' U3bilat  ' Operation = ' Operation ' file=' ClinicalFileToUse ' PicBand=' PicOrBand_for_scoring ' Width=' num2str(Width)])
disp(['BESTpval= ', num2str(BESTpval), ' Coeff= ', num2str(Coefficient_of_bestpval), ' for rho= ', num2str(rho_of_bestpval)])
if BESTpval < 0.001
    disp('!!!!!!!!!!')
elseif  BESTpval < 0.05
    disp('******')
end

end
fprintf(2,warn2raise) ; fprintf(2,['  contact_to_use = ' contact_to_use '\n' ])
end
end

% Plot detected Peak for each patient for each frequency band
figure() ;
hold on ;
% set 4 subplots
for Pat = 1:length(patON) 
    subplot(2,2,1)
    hold on ;
    values = num2cell(squeeze(OFF_list{1, row_idx}.(Type_of_Spectrum).values{1, 1}(1,1:lenON,ChCell{row_idx,33}))' - squeeze(ON_list{1, on_idx}.(Type_of_Spectrum).values{1, 1}(1,1:lenON,ChCell{row_idx,33}))' ) ;      
    plot(fqAutourPic, values(round(ChCell{row_idx,28}/PtFq-Width/PtFq):round(ChCell{row_idx,28}/PtFq+Width/PtFq)), ...
        cell2mat(BestChanTableDlt(round(FrqStart/PtFq):round(FrqEnd/PtFq), Pat)), 'Color', [0.5 0.5 0.5])

end






























freqList      = 0:PtFq:(100-PtFq) ;
fqAutourPic   = -PeakWidth*1.5:PtFq:PeakWidth*1.5;
figure ;
hold on ;
tempmean = [] ;
for el = 1:length(MaxPerPat)
    if goodlist(el) && goodlisttmp(el)
        num2cell(squeeze(OFF_list{1, row_idx}.(Type_of_Spectrum).values{1, 1}(1,1:lenON,ChCell{row_idx,32}))' - squeeze(ON_list{1, on_idx}.(Type_of_Spectrum).values{1, 1}(1,1:lenON,ChCell{row_idx,32}))' ) ;
        plot(fqAutourPic, values(round(ChCell{row_idx,36}/PtFq-Width/PtFq):round(ChCell{row_idx,36}/PtFq+Width/PtFq)), ...
            cell2mat(BestChanTableDlt(round(FrqPerPat(el)/PtFq - PeakWidth*1.5/PtFq):round(FrqPerPat(el)/PtFq + PeakWidth*1.5/PtFq),el)),...
            'DisplayName','no legend', LineWidth=0.2, Color='#cccccc')
        tempmean(:,end+1) = cell2mat(BestChanTableDlt(round(FrqPerPat(el)/PtFq - PeakWidth*1.5/PtFq):round(FrqPerPat(el)/PtFq + PeakWidth*1.5/PtFq),el)) ;
    end
end
plot(fqAutourPic, mean(tempmean,2), LineWidth=3)
saveas(gcf, fullfile(PlotSaveFolder, ['1-C Delta AllPeaks' '_' suffix '.png']), 'png')
% Plot Correlation 
plotData(1,:) = psdPerPat ;
plotData(2,:) = UPDRSdeltaList ;
corrplot(plotData')

% Export to R




close all









%% Exploratory figure for explaining GAM : plot the extreme patients

% Plot the 5 patients with the highest and lowest deltaUPDRS score

UPDRSdeltaList = [] ;
% Clinical Data
for pat = 1:length(patON)
    UPDRSdeltaList(pat) = NameAndNum{strcmp(patON(pat), NameAndNum(:, 1)),8+LeftRightON(pat)} - NameAndNum{strcmp(patON(pat), NameAndNum(:, 1)),9+LeftRightON(pat)} ;
end
PSDbad  = mean(cell2mat(BestChanTableDlt(1:10000,UPDRSdeltaList < 13.5)),2) ;
PSDgood = mean(cell2mat(BestChanTableDlt(1:10000,UPDRSdeltaList > 38.5)),2) ;
PSDmid  = mean(cell2mat(BestChanTableDlt(1:10000,UPDRSdeltaList > 22.5 & UPDRSdeltaList < 27.5)),2) ;
PSDother= mean(cell2mat(BestChanTableDlt(1:10000,((~(UPDRSdeltaList > 13.5 & UPDRSdeltaList < 38.5))|(UPDRSdeltaList > 13.5 & UPDRSdeltaList < 22.5 )|(UPDRSdeltaList > 27.5 & UPDRSdeltaList < 38.5 )))),2) ;
figure() ; hold on ; plot(PSDgood, 'g') ; plot(PSDmid, 'b') ; plot(PSDbad, 'r') ; plot(PSDother, 'k') ; legend('good', 'mid', 'bad', 'other') ; title('Mean PSD') ; grid on

PSDbad  = median(cell2mat(BestChanTableDlt(1:10000,UPDRSdeltaList < 13.5)),2) ;
PSDgood = median(cell2mat(BestChanTableDlt(1:10000,UPDRSdeltaList > 38.5)),2) ;
PSDmid  = median(cell2mat(BestChanTableDlt(1:10000,UPDRSdeltaList > 22.5 & UPDRSdeltaList < 27.5)),2) ;
PSDother= median(cell2mat(BestChanTableDlt(1:10000,((~(UPDRSdeltaList > 13.5 & UPDRSdeltaList < 38.5))|(UPDRSdeltaList > 13.5 & UPDRSdeltaList < 22.5 )|(UPDRSdeltaList > 27.5 & UPDRSdeltaList < 38.5 )))),2) ;
figure() ; hold on ; plot(PSDgood, 'g') ; plot(PSDmid, 'b') ; plot(PSDbad, 'r') ; plot(PSDother, 'k') ; legend('good', 'mid', 'bad', 'other') ; title('Median PSD') ; grid on

% plot a subplot per psd in the UPDRS order
[~,Index] = sort(UPDRSdeltaList) ;
figure() ; hold on ;
for i = 1:length(Index)
    subplot_tight(14,6,i) ; hold on ; plot(cell2mat(BestChanTableDlt(1:10000,Index(i)))) ; title(num2str(UPDRSdeltaList(Index(i)))) ; grid on
end

figure() ; hold on ; grid on 
spacing = 15E-4 ;
for i = 1:length(Index)
    plot([0.01:0.01:100], cell2mat(BestChanTableDlt(1:10000,Index(i)))+i*spacing) ; 
end

figure() ; hold on ; grid on 
for i = 1:length(Index)
    plot([0.01:0.01:100], normalize(cell2mat(BestChanTableDlt(1:10000,Index(i))), 'range', [0,1])+i) ; 
end

 
% Left vs Right
figure() ; hold on ; grid on
LeftPSDmoy = mean(cell2mat(BestChanTableDlt(1:10000, LeftRightON == 2 )),2) ;
RightPSDmoy = mean(cell2mat(BestChanTableDlt(1:10000, LeftRightON == 0 )),2) ;
plot(LeftPSDmoy, 'r') ; plot(RightPSDmoy, 'b') ; legend('Left', 'Right') ; title('Mean PSD') ; grid on

figure() ; hold on ; grid on
LeftPSDmed = median(cell2mat(BestChanTableDlt(1:10000, LeftRightON == 2 )),2) ;
RightPSDmed = median(cell2mat(BestChanTableDlt(1:10000, LeftRightON == 0 )),2) ;
plot(LeftPSDmed, 'r') ; plot(RightPSDmed, 'b') ; legend('Left', 'Right') ; title('Median PSD') ; grid on


% Normaliser frequence par frequence et regarder en fct du profil des patients
PSDweird = [] ;
for i = 1:10000 ; PSDweird(i,:) = normalize(cell2mat(BestChanTableDlt(i,:)), 'range', [0,1]) ; end
PSDbad = mean(PSDweird(:,UPDRSdeltaList < 13.5),2) ; PSDgood = mean(PSDweird(:,UPDRSdeltaList > 38.5),2) ; PSDmid = mean(PSDweird(:,UPDRSdeltaList > 22.5 & UPDRSdeltaList < 27.5),2) ; PSDother = mean(PSDweird(:,((~(UPDRSdeltaList > 13.5 & UPDRSdeltaList < 38.5))|(UPDRSdeltaList > 13.5 & UPDRSdeltaList < 22.5 )|(UPDRSdeltaList > 27.5 & UPDRSdeltaList < 38.5 ))),2) ;
figure() ; hold on ; plot(PSDbad, 'r') ; plot(PSDgood, 'g') ; plot(PSDmid, 'b') ; plot(PSDother, 'k') ; legend('bad', 'good', 'mid', 'other') ; title('Mean PSD') ; grid on
PSDbad = median(PSDweird(:,UPDRSdeltaList < 13.5),2) ; PSDgood = median(PSDweird(:,UPDRSdeltaList > 38.5),2) ; PSDmid = median(PSDweird(:,UPDRSdeltaList > 22.5 & UPDRSdeltaList < 27.5),2) ; PSDother = median(PSDweird(:,((~(UPDRSdeltaList > 13.5 & UPDRSdeltaList < 38.5))|(UPDRSdeltaList > 13.5 & UPDRSdeltaList < 22.5 )|(UPDRSdeltaList > 27.5 & UPDRSdeltaList < 38.5 ))),2) ;
figure() ; hold on ; plot(PSDbad, 'r') ; plot(PSDgood, 'g') ; plot(PSDmid, 'b') ; plot(PSDother, 'k') ; legend('bad', 'good', 'mid', 'other') ; title('Median PSD') ; grid on

PSDweird = [] ;
for i = 1:10000 ; PSDweird(i,:) = normalize(cell2mat(BestChanTableDlt(i,:)), 'zscore') ; end
PSDbad = mean(PSDweird(:,UPDRSdeltaList < 13.5),2) ; PSDgood = mean(PSDweird(:,UPDRSdeltaList > 38.5),2) ; PSDmid = mean(PSDweird(:,UPDRSdeltaList > 22.5 & UPDRSdeltaList < 27.5),2) ; PSDother = mean(PSDweird(:,((~(UPDRSdeltaList > 13.5 & UPDRSdeltaList < 38.5))|(UPDRSdeltaList > 13.5 & UPDRSdeltaList < 22.5 )|(UPDRSdeltaList > 27.5 & UPDRSdeltaList < 38.5 ))),2) ;
figure() ; hold on ; plot(PSDbad, 'r') ; plot(PSDgood, 'g') ; plot(PSDmid, 'b') ; plot(PSDother, 'k') ; legend('bad', 'good', 'mid', 'other') ; title('Mean PSD') ; grid on
PSDbad = median(PSDweird(:,UPDRSdeltaList < 13.5),2) ; PSDgood = median(PSDweird(:,UPDRSdeltaList > 38.5),2) ; PSDmid = median(PSDweird(:,UPDRSdeltaList > 22.5 & UPDRSdeltaList < 27.5),2) ; PSDother = median(PSDweird(:,((~(UPDRSdeltaList > 13.5 & UPDRSdeltaList < 38.5))|(UPDRSdeltaList > 13.5 & UPDRSdeltaList < 22.5 )|(UPDRSdeltaList > 27.5 & UPDRSdeltaList < 38.5 ))),2) ;
figure() ; hold on ; plot(PSDbad, 'r') ; plot(PSDgood, 'g') ; plot(PSDmid, 'b') ; plot(PSDother, 'k') ; legend('bad', 'good', 'mid', 'other') ; title('Median PSD') ; grid on




%% Special sankey plot
% Get HB raw, HB all norm, Clin contact, UPDRS quartile and deltaUPDRS quartile

% Create the table
[~, rawOFF_list, ~] = hypoQAMPPE.load.LoadList(Projet) ;
norOFF_list = hypoQAMPPE.functions.SpectrumNormalisation('AUCg',rawOFF_list) ;
[RawHB, ~] = hypoQAMPPE.functions.HighBetaContact(rawOFF_list,StartBeta,EndBeta,PicOrBand,'raw') ;
[NorHB, ~] = hypoQAMPPE.functions.HighBetaContact(norOFF_list,StartBeta,EndBeta,PicOrBand,'detail') ;
RawHBlin = reshape(RawHB', [], 1);
NorHBlin = reshape(NorHB', [], 1);
RawHBlin = RawHBlin(~cell2mat(cellfun(@(x) any(isnan(x)), RawHBlin, 'UniformOutput', false))) ;
NorHBlin = NorHBlin(~cell2mat(cellfun(@(x) any(isnan(x)), NorHBlin, 'UniformOutput', false))) ;
ContactsCliniques = hypoQAMPPE.load.ClinicalContacts(ClinicalData.Old) ;

locallistUPDRSdelta = [] ;
locallistUPDRS = [] ;
DataFrame = struct('Patient',{},'qUPDRSdelta',{},'qUPDRS',{},'HBraw',{},'HBallnorm',{},'ClinContact',{}) ;
for pat = 1:length(patOFF)
    DataFrame(pat).Patient = patOFF(pat) ;
    locallistUPDRSdelta(pat) = NameAndNum{strcmp(patOFF(pat), NameAndNum(:, 1)),8+LeftRightOFF(pat)} - NameAndNum{strcmp(patOFF(pat), NameAndNum(:, 1)),9+LeftRightOFF(pat)} ;
    locallistUPDRS(pat) = NameAndNum{strcmp(patOFF(pat), NameAndNum(:, 1)),8+LeftRightOFF(pat)} ;
    DataFrame(pat).qUPDRSdelta = NaN ;
    DataFrame(pat).qUPDRS = NaN ;
    DataFrame(pat).HBraw = RawHBlin{pat} ;
    DataFrame(pat).HBallnorm = NorHBlin{pat} ;
    DataFrame(pat).ClinContact = ContactsCliniques{strcmp(patOFF{pat}, ContactsCliniques{:, 1}),LeftRightOFF(pat)/2+2} -0.5 ;
end
qUPDRSdelta = quantile(locallistUPDRSdelta, [0.25 0.5 0.75]) ;
qUPDRS      = quantile(locallistUPDRS,      [0.25 0.5 0.75]) ;
for pat = 1:length(patOFF)
    DataFrame(pat).qUPDRSdelta = sum(locallistUPDRSdelta(pat) >= qUPDRSdelta) ;
    DataFrame(pat).qUPDRS = sum(locallistUPDRS(pat) >= qUPDRS) ;
end

DFlight = squeeze(struct2cell(DataFrame))' ;
DFlight = DFlight(:,2:6) ;
for i = 1:size(DFlight,1)
    DFlight(i,1) = {['qD' num2str(DFlight{i,1})]} ;
    DFlight(i,2) = {['q'  num2str(DFlight{i,2})]} ;
    DFlight(i,3) = {['r'  DFlight{i,3}]} ;
    DFlight(i,5) = {num2str(DFlight{i,5})} ;
    if length(DFlight{i,5}) == 1
        DFlight(i,5) = {['Ch' DFlight{i,5}]} ;
    end
end

Renderer = 'R' ; % 'R' or 'Matlab' or 'visual'
switch Renderer
    case 'visual'
        % For visual inspection
        [~,idx]=unique(cell2mat(DFlight(:,1:2)),'rows');
        linksForVisualInspection =  DFlight(idx,:) ;
        for i = 1:size(links,1) ; linksForVisualInspection(i,6) = {sum(strcmp(linksForVisualInspection{i,1}, DFlight(:,1)) & strcmp(linksForVisualInspection{i,2}, DFlight(:,2)) & strcmp(linksForVisualInspection{i,3}, DFlight(:,3)) & strcmp(linksForVisualInspection{i,4}, DFlight(:,4)) & strcmp(linksForVisualInspection{i,5}, DFlight(:,5)))} ; end

    case 'Matlab'
        % For sankey plot
        DFall = DFlight ;
        DFall(:,3) = strrep(DFall(:,3), 'G', ''); DFall(:,3) = strrep(DFall(:,3), 'D', '');
        DFall(:,4) = strrep(DFall(:,4), 'G', ''); DFall(:,4) = strrep(DFall(:,4), 'D', '');
        linksAll = {} ;
        for col = 1:(length(DFall(1,:))-1)
            [~,idx]=unique(cell2mat(DFall(:,col:col+1)),'rows');
            LnkTemp =  DFall(idx,col:col+1);
            for i = 1:size(LnkTemp,1)
                LnkTemp(i,3) = {sum(strcmp(LnkTemp{i,1}, DFall(:,col)) & strcmp(LnkTemp{i,2}, DFall(:,col+1)))} ; 
            end
            linksAll = [linksAll ; LnkTemp] ;
        end 

        DfLeft  = DFlight(cellfun(@(x) ~isempty(strfind(x, 'G')), DFlight(:,3)),:) ;
        DfRight = DFlight(cellfun(@(x) ~isempty(strfind(x, 'D')), DFlight(:,3)),:) ;
        linksLeft = {} ;
        linksRight = {} ;
        for col = 1:(length(DfLeft(1,:))-1)
            [~,idx]=unique(cell2mat(DfLeft(:,col:col+1)),'rows');
            LnkTemp =  DfLeft(idx,col:col+1);
            for i = 1:size(LnkTemp,1)
                LnkTemp(i,3) = {sum(strcmp(LnkTemp{i,1}, DfLeft(:,col)) & strcmp(LnkTemp{i,2}, DfLeft(:,col+1)))} ; 
            end
            linksLeft = [linksLeft ; LnkTemp] ;

            [~,idx]=unique(cell2mat(DfRight(:,col:col+1)),'rows');
            LnkTemp =  DfRight(idx,col:col+1);
            for i = 1:size(LnkTemp,1)
                LnkTemp(i,3) = {sum(strcmp(LnkTemp{i,1}, DfRight(:,col)) & strcmp(LnkTemp{i,2}, DfRight(:,col+1)))} ; 
            end
            linksRight = [linksRight ; LnkTemp] ;
        end

        % Sankey plot 
        addpath('C:\Users\mathieu.yeche\Documents\Toolbox\sankey plot\sankey plot')
        figure('Name','AllContacts','Units','normalized','Position',[.05,.2,.5,.56])
        SK=SSankey(linksAll(:,1),linksAll(:,2),linksAll(:,3));
        SK.RenderingMethod='interp'; SK.Align='center'; SK.LabelLocation='center'; SK.Sep=0;
        SK.draw()

        figure('Name','LeftContacts','Units','normalized','Position',[.05,.2,.5,.56])
        SK=SSankey(linksLeft(:,1),linksLeft(:,2),linksLeft(:,3));
        SK.RenderingMethod='interp'; SK.Align='center'; SK.LabelLocation='center'; SK.Sep=0;
        SK.draw()

        figure('Name','RightContacts','Units','normalized','Position',[.05,.2,.5,.56])
        SK=SSankey(linksRight(:,1),linksRight(:,2),linksRight(:,3));
        SK.RenderingMethod='interp'; SK.Align='center'; SK.LabelLocation='center'; SK.Sep=0;
        SK.draw()

    case 'R'
        DFforExport = squeeze(struct2cell(DataFrame))' ;
        DFforExport(:,7) = regexprep(DFforExport(:,4), '[^a-zA-Z]', '') ;
        DFforExport(:,4) = regexprep(DFforExport(:,4), '[^0-9]', '') ;
        DFforExport(:,5) = regexprep(DFforExport(:,5), '[^0-9]', '') ;
        DFforExport = DFforExport(:,[3 2 4 5 6 7 1]) ;
        var = {'qUPDRS', 'qUPDRSdelta', 'HBraw', 'HBallnorm', 'ClinContact', 'Side', 'Patient','filename'} ;

        DFforExport(1,8) = {[ strrep(PlotSaveFolder, '\', '/') '/Alluvial_UpdrsCentric_All' '_' suffix]} ;
        writetable(cell2table(DFforExport, "VariableNames", var), 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\tempMatlab2R.csv')
        system('"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" "C:\Users\mathieu.yeche\Desktop\Github\LabAnalyses\+hypoQAMPPE\stats\AlluvialPlot.R"') ;

        DFforExportL = DFforExport(cellfun(@(x) ~isempty(strfind(x, 'G')), DFforExport(:,6)),:) ;
        DFforExportL(1,8) = {[ strrep(PlotSaveFolder, '\', '/') '/Alluvial_UpdrsCentric_Left' '_' suffix]} ;
        writetable(cell2table(DFforExportL, "VariableNames", var), 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\tempMatlab2R.csv')
        system('"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" "C:\Users\mathieu.yeche\Desktop\Github\LabAnalyses\+hypoQAMPPE\stats\AlluvialPlot.R"') ;

        DFforExportR = DFforExport(cellfun(@(x) ~isempty(strfind(x, 'D')), DFforExport(:,6)),:) ;
        DFforExportR(1,8) = {[ strrep(PlotSaveFolder, '\', '/') '/Alluvial_UpdrsCentric_Right' '_' suffix]} ;
        writetable(cell2table(DFforExportR, "VariableNames", var), 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\tempMatlab2R.csv')
        system('"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" "C:\Users\mathieu.yeche\Desktop\Github\LabAnalyses\+hypoQAMPPE\stats\AlluvialPlot.R"') ;

        DFforExport(1,8) = {[ strrep(PlotSaveFolder, '\', '/') '/Alluvial_ClinContCentric_All' '_' suffix]} ;
        reordered = [5 2 4 3 6 7 8 ] ;
        writetable(cell2table(DFforExport(:,reordered), "VariableNames", var(reordered)), 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\tempMatlab2R.csv')
        system('"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" "C:\Users\mathieu.yeche\Desktop\Github\LabAnalyses\+hypoQAMPPE\stats\AlluvialPlot.R"') ;

        DFforExport(1,8) = {[ strrep(PlotSaveFolder, '\', '/') '/Alluvial_HighestBetaCentric_All' '_' suffix]} ;
        reordered = [4 3 2 1 5 6 7 8 ] ;
        writetable(cell2table(DFforExport(:,reordered), "VariableNames", var(reordered)), 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\tempMatlab2R.csv')
        system('"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" "C:\Users\mathieu.yeche\Desktop\Github\LabAnalyses\+hypoQAMPPE\stats\AlluvialPlot.R"') ;
                
        DFforExport(1,8) = {[ strrep(PlotSaveFolder, '\', '/') '/Alluvial_FigPourPtAvancees7_All' '_' suffix]} ;
        reordered = [2 5 4 6 7 8 ] ;
        writetable(cell2table(DFforExport(:,reordered), "VariableNames", var(reordered)), 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\tempMatlab2R.csv')
        system('"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" "C:\Users\mathieu.yeche\Desktop\Github\LabAnalyses\+hypoQAMPPE\stats\AlluvialPlot.R"') ;
        
        DFforExport(1,8) = {[ strrep(PlotSaveFolder, '\', '/') '/Pres_fig2_All' '_' suffix]} ;
        reordered = [5 3 4 2 7 8 ] ;
        writetable(cell2table(DFforExport(:,reordered), "VariableNames", var(reordered)), 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\tempMatlab2R.csv')
        system('"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" "C:\Users\mathieu.yeche\Desktop\Github\LabAnalyses\+hypoQAMPPE\stats\AlluvialPlot.R"') ;
end


%% Sankey plot for the UPDRS PostOp
[~, rawOFF_list, ~] = hypoQAMPPE.load.LoadList(Projet) ;
norOFF_list = hypoQAMPPE.functions.SpectrumNormalisation('AUCg',rawOFF_list) ;
[RawHB, HB_id]  = hypoQAMPPE.functions.HighBetaContact(rawOFF_list,StartBeta,EndBeta,PicOrBand,'raw') ;
[NorHB, ~]      = hypoQAMPPE.functions.HighBetaContact(norOFF_list,StartBeta,EndBeta,PicOrBand,'detail') ;
[BetaMetric, ~] = hypoQAMPPE.functions.HighBetaContact(rawOFF_list,StartBeta,EndBeta,'AllPic','detail') ;

RawHBlin = reshape(RawHB', [], 1);
NorHBlin = reshape(NorHB', [], 1);
HB_idLin = reshape(HB_id', [], 1);
RawHBlin = RawHBlin(~cell2mat(cellfun(@(x) any(isnan(x)), RawHBlin, 'UniformOutput', false))) ;
NorHBlin = NorHBlin(~cell2mat(cellfun(@(x) any(isnan(x)), NorHBlin, 'UniformOutput', false))) ;
HB_idLin = HB_idLin(~cell2mat(cellfun(@(x) any(isnan(x)), HB_idLin, 'UniformOutput', false))) ;
ContactsCliniques = hypoQAMPPE.load.ClinicalContacts(ClinicalData.Old) ;

locallistUPDRSBestONOFF = [] ;
locallistUPDRSdbsONOFF = [] ;
locallistBetaMetricHB = [] ;
locallistBetaMetricMean = [] ;
DataFrame = struct('Patient',{},'UPDRS_BestOFFON',{},'UPDRS_DBS',{},'HBraw',{},'HBallnorm',{},'ClinContact',{},'BetaMetricHB',{},'BetaMetricMean',{}) ;
for pat = 1:length(patOFF)
    DataFrame(pat).Patient = patOFF(pat) ;
    locallistUPDRSBestONOFF(pat) = ClinicalData.Fusion.UPDRSIII_STIM_ON(strcmp(patOFF(pat), ClinicalData.Fusion.PATIENTID(:)))        - ClinicalData.Fusion.UPDRSIII_STIM_OFF(strcmp(patOFF(pat), ClinicalData.Fusion.PATIENTID(:))) ; ;
    locallistUPDRSdbsONOFF(pat)  = ClinicalData.Fusion.UPDRSIII_STIMON_DOPAOFF(strcmp(patOFF(pat), ClinicalData.Fusion.PATIENTID(:))) - ClinicalData.Fusion.UPDRSIII_STIM_OFF(strcmp(patOFF(pat), ClinicalData.Fusion.PATIENTID(:)))  ;
    DataFrame(pat).UPDRS_BestOFFON = NaN ;
    DataFrame(pat).UPDRS_DBS = NaN ;
    DataFrame(pat).HBraw = RawHBlin{pat} ;
    DataFrame(pat).HBallnorm = NorHBlin{pat} ;
    DataFrame(pat).ClinContact = ContactsCliniques{strcmp(patOFF{pat}, ContactsCliniques{:, 1}),LeftRightOFF(pat)/2+2} -0.5 ;
    DataFrame(pat).BetaMetricHB = NaN ;
    DataFrame(pat).BetaMetricMean = NaN ;
    locallistBetaMetricHB(pat)   = BetaMetric{strcmp(patOFF(pat), NameAndNum(:,1)),HB_idLin{pat,1}} ;
    locallistBetaMetricMean(pat) = mean(cell2mat(BetaMetric(strcmp(patOFF(pat), NameAndNum(:,1)),(1+1.5*LeftRightOFF(pat)):(3+1.5*LeftRightOFF(pat))))) ;
end
UPDRS_BestOFFON = quantile(locallistUPDRSBestONOFF, [0.25 0.5 0.75]) ;
UPDRS_DBS       = quantile(locallistUPDRSdbsONOFF , [0.25 0.5 0.75]) ;
BetaMetricHB    = quantile(locallistBetaMetricHB  , [0.25 0.5 0.75]) ;
BetaMetricMean  = quantile(locallistBetaMetricMean, [0.25 0.5 0.75]) ;
for pat = 1:length(patOFF)
    if ~isnan(locallistUPDRSBestONOFF(pat))
        DataFrame(pat).UPDRS_BestOFFON = sum(locallistUPDRSBestONOFF(pat) >= UPDRS_BestOFFON) + 1 ;
    end
    if ~isnan(locallistUPDRSdbsONOFF(pat))
        DataFrame(pat).UPDRS_DBS = sum(locallistUPDRSdbsONOFF(pat) >= UPDRS_DBS) + 1 ;
    end
    DataFrame(pat).BetaMetricHB = sum(locallistBetaMetricHB(pat) >= BetaMetricHB) + 1 ;
    DataFrame(pat).BetaMetricMean = sum(locallistBetaMetricMean(pat) >= BetaMetricMean) + 1 ;
end

DFforExport = squeeze(struct2cell(DataFrame))' ;
DFforExport(:,9) = regexprep(DFforExport(:,4), '[^a-zA-Z]', '') ;
DFforExport(:,4) = regexprep(DFforExport(:,4), '[^0-9]', '') ;
DFforExport(:,5) = regexprep(DFforExport(:,5), '[^0-9]', '') ;
DFforExport = DFforExport(:,[3 2 4 5 6 7 8 9 1]) ;
var = {'U_DBS', 'U_BestD', 'HBraw', 'HBnorm', 'ClinContact', 'BA_HB', 'BA_Moy', 'Side', 'Patient','filename'} ; % BA = Beta Amplitude metric ; U = UPDRS

DFforExport(1,10) = {[ strrep(PlotSaveFolder, '\', '/') '/Alluvial_UpdrsDBSCentric_All' '_' suffix]} ;
writetable(cell2table(DFforExport, "VariableNames", var), 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\tempMatlab2R.csv')
system('"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" "C:\Users\mathieu.yeche\Desktop\Github\LabAnalyses\+hypoQAMPPE\stats\AlluvialPlot.R"') ;

DFforExport(1,10) = {[ strrep(PlotSaveFolder, '\', '/') '/Alluvial_UpdrsBestCentric_All' '_' suffix]} ;
reordered = [2 1 3 4 5 6 7 8 9 10 ] ;
writetable(cell2table(DFforExport(:,reordered), "VariableNames", var(reordered)), 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\tempMatlab2R.csv')
system('"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" "C:\Users\mathieu.yeche\Desktop\Github\LabAnalyses\+hypoQAMPPE\stats\AlluvialPlot.R"') ;

DFforExport(1,10) = {[ strrep(PlotSaveFolder, '\', '/') '/Alluvial_UpdrsBestCentric_BetaMet' '_' suffix]} ;
reordered = [2 1 6 7 3 4 5 8 9 10 ] ;
writetable(cell2table(DFforExport(:,reordered), "VariableNames", var(reordered)), 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\tempMatlab2R.csv')
system('"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" "C:\Users\mathieu.yeche\Desktop\Github\LabAnalyses\+hypoQAMPPE\stats\AlluvialPlot.R"') ; 

DFforExport(1,10) = {[ strrep(PlotSaveFolder, '\', '/') '/Alluvial_BetaHBCentric_All' '_' suffix]} ;
reordered = [ 6 7 3 4 5 2 1 8 9 10 ] ;
writetable(cell2table(DFforExport(:,reordered), "VariableNames", var(reordered)), 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\tempMatlab2R.csv')
system('"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" "C:\Users\mathieu.yeche\Desktop\Github\LabAnalyses\+hypoQAMPPE\stats\AlluvialPlot.R"') ;
     
DFforExport(1,10) = {[ strrep(PlotSaveFolder, '\', '/') '/Pres_fig1_All' '_' suffix]} ;
reordered = [ 5 3 4 9 10 ] ;
writetable(cell2table(DFforExport(:,reordered), "VariableNames", var(reordered)), 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\tempMatlab2R.csv')
system('"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" "C:\Users\mathieu.yeche\Desktop\Github\LabAnalyses\+hypoQAMPPE\stats\AlluvialPlot.R"') ;
     
DFforExport(1,10) = {[ strrep(PlotSaveFolder, '\', '/') '/Pres_fig3_All' '_' suffix]} ;
reordered = [ 5 3 1 2 9 10 ] ;
writetable(cell2table(DFforExport(:,reordered), "VariableNames", var(reordered)), 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\tempMatlab2R.csv')
system('"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" "C:\Users\mathieu.yeche\Desktop\Github\LabAnalyses\+hypoQAMPPE\stats\AlluvialPlot.R"') ;
      
DFforExport(1,10) = {[ strrep(PlotSaveFolder, '\', '/') '/Pres_fig4_All' '_' suffix]} ;
reordered = [ 2 5 3 1 9 10 ] ;
writetable(cell2table(DFforExport(:,reordered), "VariableNames", var(reordered)), 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\tempMatlab2R.csv')
system('"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" "C:\Users\mathieu.yeche\Desktop\Github\LabAnalyses\+hypoQAMPPE\stats\AlluvialPlot.R"') ;
         
DFforExport(1,10) = {[ strrep(PlotSaveFolder, '\', '/') '/Pres_fig5_All' '_' suffix]} ;
reordered = [ 2 5 3 6 7 9 10 ] ;
writetable(cell2table(DFforExport(:,reordered), "VariableNames", var(reordered)), 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\tempMatlab2R.csv')
system('"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" "C:\Users\mathieu.yeche\Desktop\Github\LabAnalyses\+hypoQAMPPE\stats\AlluvialPlot.R"') ;
       

%% Beta power level for each dipole OFF
% Get the beta power for each dipole
[~, rawOFF_list, ~] = hypoQAMPPE.load.LoadList(Projet) ;
[BetaMetric, HB_id] = hypoQAMPPE.functions.HighBetaContact(rawOFF_list,StartBeta,EndBeta,'AllPic','detail') ;

MetricsDiffL = [] ;
MetricsDiffR = [] ;

for pat = 1:length(rawOFF_list)
    for ch = 1:3
        Metric
        sDiffR(end+1,1) = ch - HB_id{pat,1} + rand(1)*0.25 ;
        MetricsDiffR(end,2) = BetaMetric{pat,ch} ;
        if ~isnan(HB_id{pat,2})
            MetricsDiffL(end+1,1) = ch+3 - HB_id{pat,2} - rand(1)*0.25 ;
            MetricsDiffL(end,2) = BetaMetric{pat,ch+3} ;
        end
    end
end

figure() ; hold on ; grid on
plot(MetricsDiffL(:,1), MetricsDiffL(:,2), 'r*')
plot(MetricsDiffR(:,1), MetricsDiffR(:,2), 'b*')
% add lines for each indiv


legend('Left', 'Right')
title('Beta power for each dipole, relatively to its distance to the highest beta dipole')
xlabel('Distance to the Highest Beta dipole')
ylabel('Peak Beta power')

% Boxplot for each dipole Right side
oneR = ones(length(BetaMetric(:,1)),1) ;
RndR = rand(length(BetaMetric(:,1)),1)*0.3 - 0.15 ;
figure() ; hold on
plot(oneR + RndR,   cell2mat(BetaMetric(:,1)), 'k*')
plot(oneR*2 + RndR, cell2mat(BetaMetric(:,2)), 'k*')
plot(oneR*3 + RndR, cell2mat(BetaMetric(:,3)), 'k*')
boxplot(cell2mat(BetaMetric(:,1:3)), 'Labels', {'01', '12', '23'})
title('Beta power for each dipole, Right side')
xlabel('Dipole')
ylabel('Peak Beta power')

% Boxplot for each dipole Left side
BetaMetricL = BetaMetric([1:5 7:end],:) ;
oneL = ones(length(BetaMetricL(:,4)),1) ;
RndL = rand(length(BetaMetricL(:,4)),1)*0.3 - 0.15 ;
figure() ; hold on
plot(oneL + RndL,   cell2mat(BetaMetricL(:,4)), 'k*')
plot(oneL*2 + RndL, cell2mat(BetaMetricL(:,5)), 'k*')
plot(oneL*3 + RndL, cell2mat(BetaMetricL(:,6)), 'k*')
boxplot(cell2mat(BetaMetricL(:,4:6)), 'Labels', {'01', '12', '23'})
title('Beta power for each dipole, Left side')
xlabel('Dipole')
ylabel('Peak Beta power')


        


%% Gamma color per UPDRS
% Get the gamma power for each dipole
LocalNormalisation = 'brut' % 'brut' or 'AUC100'
[~, localOFF_list, localON_list] = hypoQAMPPE.load.LoadList(Projet) ;
[NameAndNum] = hypoQAMPPE.functions.MatchingTable(localOFF_list,localON_list,ClinicalData,contact_to_use, ClinicalFileToUse, U3bilat,StartBeta,EndBeta,PicOrBand,Type_of_Spectrum, Timing_to_Use) ;
localOFF_list = hypoQAMPPE.functions.SpectrumNormalisation(LocalNormalisation,localOFF_list) ;
localON_list  = hypoQAMPPE.functions.SpectrumNormalisation(LocalNormalisation,localON_list ) ;
dU3val = [] ;
locType_of_Spectrum = 'detail' ;
for pat = 1:length(NameAndNum)
    if ~isnan(NameAndNum{pat,7})
        dU3val(end+1) = NameAndNum{pat,8} - NameAndNum{pat,9} ;
    end
end

figure() ; hold on ; grid on
% colormap(jet);
map = [ .8  .2  0
        .75 .25 0
        .7  .3  0
        .65 .35 0
        .6  .4  0
        .55 .45 0
        .5  .5  0
        .5  .5  0
        .5  .5  0
        .45 .55 0
        .4  .6  0
        .35 .65 0
        .3  .7  0
        .25 .75 0
        .2  .8  0];
colormap(map);
cmap = colormap;
colorList = interp1(linspace(min(dU3val), max(dU3val), size(cmap, 1)), cmap, dU3val);
colorList(isnan(colorList)) = 0 ;
colorList(:,4) = 0.5 ;
plotnum = 0 ;
StartGamma = 35 ;
EndGamma = 100 ;
for pat = 1:length(NameAndNum)
    if ~isnan(NameAndNum{pat,7})   
        plotnum = plotnum + 1 ;
        for ch = 1:size(localOFF_list{1,pat}.(locType_of_Spectrum).values{1, 1}, 3)
            plot(localOFF_list{1, pat}.(locType_of_Spectrum).f((100*StartGamma):(100*EndGamma)),localOFF_list{1, pat}.(locType_of_Spectrum).values{1, 1}(1,(100*StartGamma):(100*EndGamma),ch)' - localON_list{1,NameAndNum{pat,7}}.(locType_of_Spectrum).values{1, 1}(1,(100*StartGamma):(100*EndGamma),ch)' , 'Color', colorList(plotnum,:))
        end
    end
end
title('delta OFF-ON Gamma PSD for each dipole, colored by deltaUPDRS') ; xlabel('Frequency') ; ylabel('Power') ; colorbar

figure() ; hold on ; grid on
StartGamma = 65 ;
EndGamma = 80 ;
plotnum = 0 ;
for pat = 1:length(NameAndNum)
    if ~isnan(NameAndNum{pat,7})   
        plotnum = plotnum + 1 ;
        for ch = 1:size(localOFF_list{1,pat}.(locType_of_Spectrum).values{1, 1}, 3)
            plot(localOFF_list{1, pat}.(locType_of_Spectrum).f((100*StartGamma):(100*EndGamma)),localOFF_list{1, pat}.(locType_of_Spectrum).values{1, 1}(1,(100*StartGamma):(100*EndGamma),ch)' - localON_list{1,NameAndNum{pat,7}}.(locType_of_Spectrum).values{1, 1}(1,(100*StartGamma):(100*EndGamma),ch)' , 'Color', colorList(plotnum,:))
        end
    end
end
title('delta OFF-ON Gamma PSD for each dipole, colored by deltaUPDRS') ; xlabel('Frequency') ; ylabel('Power') ; colorbar

% Only Highest beta contact
figure() ; hold on ; grid on
colorList(:,4) = 1 ;
plotnum = 0 ;
StartGamma = 35 ;
EndGamma = 100 ;
for pat = 1:length(NameAndNum)
    if ~isnan(NameAndNum{pat,7})   
        plotnum = plotnum + 1 ;
        plot(localOFF_list{1, pat}.(locType_of_Spectrum).f((100*StartGamma):(100*EndGamma)),localOFF_list{1, pat}.(locType_of_Spectrum).values{1, 1}(1,(100*StartGamma):(100*EndGamma),NameAndNum{pat,3})' - localON_list{1,NameAndNum{pat,7}}.(locType_of_Spectrum).values{1, 1}(1,(100*StartGamma):(100*EndGamma),NameAndNum{pat,3})' , 'Color', colorList(plotnum,:))
        if ~isnan(NameAndNum{pat,5})
            plot(localOFF_list{1, pat}.(locType_of_Spectrum).f((100*StartGamma):(100*EndGamma)),localOFF_list{1, pat}.(locType_of_Spectrum).values{1, 1}(1,(100*StartGamma):(100*EndGamma),NameAndNum{pat,5})' - localON_list{1,NameAndNum{pat,7}}.(locType_of_Spectrum).values{1, 1}(1,(100*StartGamma):(100*EndGamma),NameAndNum{pat,5})' , 'Color', colorList(plotnum,:))
        end
    end
end
title('delta OFF-ON Gamma PSD for Highest Beta dipole, colored by deltaUPDRS') ; xlabel('Frequency') ; ylabel('Power') ; colorbar

figure() ; hold on ; grid on
StartGamma = 65 ;
EndGamma = 85 ;
plotnum = 0 ;
for pat = 1:length(NameAndNum)
    if ~isnan(NameAndNum{pat,7})   
        plotnum = plotnum + 1 ;
        plot(localOFF_list{1, pat}.(locType_of_Spectrum).f((100*StartGamma):(100*EndGamma)),localOFF_list{1, pat}.(locType_of_Spectrum).values{1, 1}(1,(100*StartGamma):(100*EndGamma),NameAndNum{pat,3})' - localON_list{1,NameAndNum{pat,7}}.(locType_of_Spectrum).values{1, 1}(1,(100*StartGamma):(100*EndGamma),NameAndNum{pat,3})' , 'Color', colorList(plotnum,:))
        if ~isnan(NameAndNum{pat,5})
            plot(localOFF_list{1, pat}.(locType_of_Spectrum).f((100*StartGamma):(100*EndGamma)),localOFF_list{1, pat}.(locType_of_Spectrum).values{1, 1}(1,(100*StartGamma):(100*EndGamma),NameAndNum{pat,5})' - localON_list{1,NameAndNum{pat,7}}.(locType_of_Spectrum).values{1, 1}(1,(100*StartGamma):(100*EndGamma),NameAndNum{pat,5})' , 'Color', colorList(plotnum,:))
        end
    end
end
title('delta OFF-ON Gamma PSD for Highest Beta dipole, colored by deltaUPDRS') ; xlabel('Frequency') ; ylabel('Power') ; colorbar




%% LMER Beta vs. Gamma

% Prepare the table

LocalNormalisation = 'AUC100' % 'brut' or 'AUC100'
Type_of_Spectrum = 'detail' ;
[~, localOFF_list, localON_list] = hypoQAMPPE.load.LoadList(Projet) ;
localOFF_list = hypoQAMPPE.functions.SpectrumNormalisation(LocalNormalisation,localOFF_list) ;
localON_list  = hypoQAMPPE.functions.SpectrumNormalisation(LocalNormalisation,localON_list ) ;
[LocalNameAndNum] = hypoQAMPPE.functions.MatchingTable(localOFF_list,localON_list,ClinicalData,contact_to_use, ClinicalFileToUse, U3bilat,StartBeta,EndBeta,PicOrBand,Type_of_Spectrum, Timing_to_Use) ;
[BestChanTableOFF, BestChanTableON, BestChanTableDlt, MeanChanTableOFF, MeanChanTableON, MeanChanTableDlt, patOFF, patON, LeftRightOFF, LeftRightON] = hypoQAMPPE.functions.ExtractPSDofInterest(LocalNameAndNum,ExportToR,Type_of_Spectrum,PtFq,localOFF_list, localON_list, PlotSaveFolder, LocalNormalisation) ;

PSD = BestChanTableDlt(1:10000,:) ;
DataFrame = struct('Patient',{},'Side',{},'LB_pic',{},'HB_pic',{},'LB_band',{},'HB_band',{},'LG_band',{},'HG_band',{},'U3OFFpre',{},'U3deltaPre',{},'U3DBS',{},'U3bestdelta',{}) ;
for pat = 1:length(patON)
    DataFrame(pat).Patient = patON(pat) ;
    DataFrame(pat).Side    = LeftRightOFF(pat)/2 ;
    DataFrame(pat).LB_pic  = max( cell2mat(PSD(1200:2000,pat))) ;
    DataFrame(pat).HB_pic  = max( cell2mat(PSD(2000:3500,pat))) ;
    DataFrame(pat).LB_band = mean(cell2mat(PSD(1200:2000,pat))) ;
    DataFrame(pat).HB_band = mean(cell2mat(PSD(2000:3500,pat))) ;
    DataFrame(pat).LG_band = mean(cell2mat(PSD(3500:6000,pat))) ;
    DataFrame(pat).HG_band = mean(cell2mat(PSD(6500:8500,pat))) ;
    DataFrame(pat).U3OFFpre    = ClinicalData.Fusion.UPDRSIII_OFF(strcmp(patON(pat), ClinicalData.Fusion.PATIENTID(:)))      ;
    DataFrame(pat).U3deltaPre  = ClinicalData.Fusion.UPDRSIII_OFF(strcmp(patON(pat), ClinicalData.Fusion.PATIENTID(:)))            - ClinicalData.Fusion.UPDRSIII_ON(strcmp(patON(pat), ClinicalData.Fusion.PATIENTID(:)))  ;
    DataFrame(pat).U3bestdelta = ClinicalData.Fusion.UPDRSIII_STIM_ON(strcmp(patON(pat), ClinicalData.Fusion.PATIENTID(:)))        - ClinicalData.Fusion.UPDRSIII_STIM_OFF(strcmp(patON(pat), ClinicalData.Fusion.PATIENTID(:)))  ;
    DataFrame(pat).U3DBS       = ClinicalData.Fusion.UPDRSIII_STIMON_DOPAOFF(strcmp(patON(pat), ClinicalData.Fusion.PATIENTID(:))) - ClinicalData.Fusion.UPDRSIII_STIM_OFF(strcmp(patON(pat), ClinicalData.Fusion.PATIENTID(:)))  ;
end

DFforExport = squeeze(struct2cell(DataFrame))' ;
varname = {'Patient', 'Side','filename', 'LG', 'HG', 'LB', 'HB', 'value'} ;
% Reminder : '1Patient','2Side',3LB_pic',4HB_pic',5LB_band',6HB_band',7LG_band',8HG_band',
%             '9U3OFFpre',10U3deltaPre',11U3DBS',12U3bestdelta',13filename

formula = 'u3offpreop-pic_x_band' ;
reordered = [1 2 13 7 8 3 4 9] ;
DFforExport(1,13) = {[ strrep(PlotSaveFolder, '\', '/') '/LMER_' formula '_PSDdelta_detail+' LocalNormalisation]} ;
writetable(cell2table(DFforExport(:,reordered), "VariableNames", varname), 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\tempMatlab2R.csv')
system('"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" "C:\Users\mathieu.yeche\Desktop\Github\LabAnalyses\+hypoQAMPPE\stats\Lmer.R"') ;
  
formula = 'u3deltaPre-pic_x_band' ;
reordered = [1 2 13 7 8 3 4 10] ;
DFforExport(1,13) = {[ strrep(PlotSaveFolder, '\', '/') '/LMER_' formula '_PSDdelta_detail+' LocalNormalisation]} ;
writetable(cell2table(DFforExport(:,reordered), "VariableNames", varname), 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\tempMatlab2R.csv')
system('"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" "C:\Users\mathieu.yeche\Desktop\Github\LabAnalyses\+hypoQAMPPE\stats\Lmer.R"') ;

formula = 'u3bestdelta-pic_x_band' ;
reordered = [1 2 13 7 8 3 4 12] ;
DFforExport(1,13) = {[ strrep(PlotSaveFolder, '\', '/') '/LMER_' formula '_PSDdelta_detail+' LocalNormalisation]} ;
writetable(cell2table(DFforExport(:,reordered), "VariableNames", varname), 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\tempMatlab2R.csv')
system('"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" "C:\Users\mathieu.yeche\Desktop\Github\LabAnalyses\+hypoQAMPPE\stats\Lmer.R"') ;
  
formula = 'u3dbs-pic_x_band' ;
reordered = [1 2 13 7 8 3 4 11] ;
DFforExport(1,13) = {[ strrep(PlotSaveFolder, '\', '/') '/LMER_' formula '_PSDdelta_detail+' LocalNormalisation]} ;
writetable(cell2table(DFforExport(:,reordered), "VariableNames", varname), 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\tempMatlab2R.csv')
system('"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" "C:\Users\mathieu.yeche\Desktop\Github\LabAnalyses\+hypoQAMPPE\stats\Lmer.R"') ;
  
formula = 'u3offpreop-band_x_band' ;
reordered = [1 2 13 7 8 5 6 9] ;
DFforExport(1,13) = {[ strrep(PlotSaveFolder, '\', '/') '/LMER_' formula '_PSDdelta_detail+' LocalNormalisation]} ;
writetable(cell2table(DFforExport(:,reordered), "VariableNames", varname), 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\tempMatlab2R.csv')
system('"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" "C:\Users\mathieu.yeche\Desktop\Github\LabAnalyses\+hypoQAMPPE\stats\Lmer.R"') ;

formula = 'u3deltaPre-band_x_band' ;
reordered = [1 2 13 7 8 5 6 10] ;
DFforExport(1,13) = {[ strrep(PlotSaveFolder, '\', '/') '/LMER_' formula '_PSDdelta_detail+' LocalNormalisation]} ;
writetable(cell2table(DFforExport(:,reordered), "VariableNames", varname), 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\tempMatlab2R.csv')
system('"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" "C:\Users\mathieu.yeche\Desktop\Github\LabAnalyses\+hypoQAMPPE\stats\Lmer.R"') ;

formula = 'u3bestdelta-band_x_band' ;
reordered = [1 2 13 7 8 5 6 12] ;
DFforExport(1,13) = {[ strrep(PlotSaveFolder, '\', '/') '/LMER_' formula '_PSDdelta_detail+' LocalNormalisation]} ;
writetable(cell2table(DFforExport(:,reordered), "VariableNames", varname), 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\tempMatlab2R.csv')
system('"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" "C:\Users\mathieu.yeche\Desktop\Github\LabAnalyses\+hypoQAMPPE\stats\Lmer.R"') ;
  
formula = 'u3dbs-band_x_band' ;
reordered = [1 2 13 7 8 5 6 11] ;
DFforExport(1,13) = {[ strrep(PlotSaveFolder, '\', '/') '/LMER_' formula '_PSDdelta_detail+' LocalNormalisation]} ;
writetable(cell2table(DFforExport(:,reordered), "VariableNames", varname), 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\tempMatlab2R.csv')
system('"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" "C:\Users\mathieu.yeche\Desktop\Github\LabAnalyses\+hypoQAMPPE\stats\Lmer.R"') ;
  



