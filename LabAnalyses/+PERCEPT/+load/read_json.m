function [lfp,Peaks, CondStim] = read_json(filename, recording, Visual_inspection)
% Read JSON files and extracts them to LabMaster format 

% filename = '\\l2export\iss02.pf-marche\01_rawdata\01_RawData\02_Donnees_LFP_Brutes\PERCEPT\P04_Percept\Report_Json_Session_Report_20221028T043726.json'   ;
% filename = '\\l2export\iss02.pf-marche\01_rawdata\01_RawData\02_Donnees_LFP_Brutes\PERCEPT\P05_Percept\Report_Json_Session_Report_20231213T122659.json'   ;
% filename = '\\l2export\iss02.pf-marche\01_rawdata\01_RawData\02_Donnees_LFP_Brutes\PERCEPT\P05_Percept\Report_Json_Session_Report_20231213T122757.json'   ;
% Visual_inspection = true ;
% recording = 0 ;
% PERCEPT.load.read_json(filename,recording, Visual_inspection)


PERCEPT_data = jsondecode(fileread(filename));

todo_rapidTF = true ;
% Parametres : 
Fs = PERCEPT_data.BrainSenseTimeDomain(1).SampleRateInHz;

%Passthrought 
if ~exist ("recording","var") || recording == 0
    duration = 0 ;
    for irec = 1:size(PERCEPT_data.BrainSenseLfp,1)
        if duration < size(PERCEPT_data.BrainSenseLfp(irec).LfpData,1 )
            recording = irec ;
            duration = size(PERCEPT_data.BrainSenseLfp(irec).LfpData,1 ) ; 
        end
    end
end

GlobalPacketSizes = str2num(PERCEPT_data.BrainSenseTimeDomain(2*recording-1).GlobalPacketSizes);


if isfield(PERCEPT_data, 'BrainSenseTimeDomain') 
    % Renommer les contacts
    labels = {PERCEPT_data.BrainSenseTimeDomain(2*recording-1).Channel PERCEPT_data.BrainSenseTimeDomain(2*recording).Channel};
    for i=1:2
        labels{i} = strrep(labels{i}, 'ZERO_' , '1') ;
        labels{i} = strrep(labels{i}, 'ONE_'  , '2') ;
        labels{i} = strrep(labels{i}, 'TWO_'  , '3') ;
        labels{i} = strrep(labels{i}, 'THREE_', '4') ;
        labels{i} = strrep(labels{i}, 'LEFT'  , 'L') ;
        labels{i} = strrep(labels{i}, 'RIGHT' , 'R') ;
    end
    lfp = SampledProcess([PERCEPT_data.BrainSenseTimeDomain(2*recording-1).TimeDomainData, PERCEPT_data.BrainSenseTimeDomain(2*recording).TimeDomainData], 'Fs',Fs,'labels',labels);
end

%% Identification des artefacts de synchronisation

ArtId = PERCEPT_data.BrainSenseTimeDomain(2*recording-1).TimeDomainData ;
Time_stamp = (1:length(PERCEPT_data.BrainSenseTimeDomain(2*recording-1).TimeDomainData))/Fs ;
Peaks = [] ;

% Peak 1 :  
LocalMax = max(ArtId(1:length(ArtId)/2)) ; 
Peaks(1) = Time_stamp(find(ArtId == LocalMax)) ;

% Peak 2 :  
LocalMin = min(ArtId(1:length(ArtId)/2)) ; 
Peaks(2) = Time_stamp(find(ArtId == LocalMin)) ;

% Peak 3 :  
LocalMax = max(ArtId(length(ArtId)/2:end)) ; 
Peaks(3) = Time_stamp(find(ArtId == LocalMax)) ;

% Peak 4 :  
LocalMin = min(ArtId(length(ArtId)/2:end)) ; 
Peaks(4) = Time_stamp(find(ArtId == LocalMin)) ;

Peaks = sort(Peaks) ;


%% Verification

% Nombre de paquets correspondant aux nombres de données
if sum(GlobalPacketSizes) ~= size(ArtId, 1) 
   error(['Le nombres de données (' num2str(size(ArtId, 1)) ' valeurs) ne correspond pas au nombre de paquets (' num2str(sum(GlobalPacketSizes)) ' paquets)'])
end

% Autres fields
if isfield(PERCEPT_data, 'IndefiniteStreaming') % "Survey Indefinite Streaming" : multicontact, temps illimité, off stim, pas de recalage temporel
    fprintf(2, 'IndefiniteStreaming a implementer dans une future update \n')
elseif isfield(PERCEPT_data, 'SenseChannelTests') 
    fprintf(2, 'SenseChannelTests a implementer dans une future update \n')
elseif isfield(PERCEPT_data, 'CalibrationTests')
    fprintf(2, 'CalibrationTests a implementer dans une future update \n')
elseif isfield(PERCEPT_data, 'LFPMontage') % Mode "Survey"
    fprintf(2, 'LFPMontage a implementer dans une future update \n')
elseif isfield(PERCEPT_data, 'DiagnosticData') && isfield(PERCEPT_data.DiagnosticData, 'LFPTrendLogs') 
    fprintf(2, 'DiagnosticData a implementer dans une future update \n')
end

% If Visual_inspection, plot the data

if Visual_inspection
    Inspection = figure();
    iplot = 0;
    for LR = (2*recording-1):(2*recording)
        iplot = iplot+1;
        ax(iplot) = subplot(2, 1, iplot);
                 plot(Time_stamp, PERCEPT_data.BrainSenseTimeDomain(LR).TimeDomainData(:))
        hold on, plot([Peaks(:)  Peaks(:)]',   [ones(length(Peaks),1)*min(PERCEPT_data.BrainSenseTimeDomain(LR).TimeDomainData)     ones(length(Peaks),1)*max(PERCEPT_data.BrainSenseTimeDomain(LR).TimeDomainData)  ]' , 'color', 'r')
        title(labels{iplot})
        ylabel('µV')
        xlim([0 Time_stamp(end)])
        ylim([min(PERCEPT_data.BrainSenseTimeDomain(LR).TimeDomainData)  max(PERCEPT_data.BrainSenseTimeDomain(LR).TimeDomainData) ])
        grid on
    end
    xlabel('sec')
    linkaxes(ax, 'x')
    uicontrol('String','OK','Callback','close all');
    uiwait(Inspection)
end

todo_bsl_forplot = false ;
if todo_rapidTF
    if todo_bsl_forplot
        lfp2 = lfp.normalize(0,'method','divide')
        lfp_spec  = tfr(lfp2,'method','chronux','tBlock',0.5,'tStep',0.03,'f',[1 100],'tapers',[2 3],'pad',1);
        fig = lfp_spec.plot('colormap', 'jet','title', true) ;
    else
        lfp_spec  = tfr(lfp,'method','chronux','tBlock',0.5,'tStep',0.03,'f',[1 100],'tapers',[2 3],'pad',1);
        fig = lfp_spec.plot('colormap', 'jet','title', true, 'caxis',[-15 15]) ;
    end
    linkaxes(fig.Children, 'x')
    fig.Children(2).YLabel.String = 'Frequency (Hz)' ;
    fig.Children(2).XLabel.String = 'Time (s)' ;
    uicontrol('String','OK','Callback','close all');
end

if strcmp(PERCEPT_data.Stimulation.FinalStimStatus, PERCEPT_data.Stimulation.InitialStimStatus)
    A = split(PERCEPT_data.Stimulation.FinalStimStatus,'.') ;
    CondStim = [A{2} 'stim' ];
else
    fprinf(2,'stim changed during the recording')
    CondStim = ['undefined_stim' ];
end

artLFPcheck = [] ;
fprintf(2, "ToDO artifact check")
% for i_length = 1:length(PERCEPT_data.BrainSenseLfp.LfpData)
%     artLFPcheck(end+1) = PERCEPT_data.BrainSenseLfp.LfpData(i_length).Right.mA ; 
% end