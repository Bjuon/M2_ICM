% MERPh
% ARDSy
% LAUTh
% RAYTh
% NGUPh % weird 40 millisecond difference between trial durations?
% ETIAl % weird 40 millisecond difference between trial durations?
% SALJe

clear all
close all
fclose all

todo.createMatfile      = 0; %create pointProcess
todo.DetectTRoutliers   = 0; %add Troutlier in MatFile;
todo.Stats              = 2; %1: do descriptive stats, create a .mat file for further statistics, 2: do just additional stats, like TR and mWin, or Z
todo.BigFig             = 0; %1: create 1 fig per filewith spikeRate, table, and all events of interest (max= 2 events, 5 cond)and copy fig in one directory
todo.CompCond           = 0; %compare between conditions
todo.AllPatMat          = 0; %create matrice with all patients : 2 = load exsiting matrix and append data.
%%% following todo should not be processed with the prvious ones but can be
%%% processed together
todo.SaveCsv            = 0; %just saveCsv, if 1, the other todo won't work
todo.StatNoGovsGoMix    = 0; %add stats Nogo vs GoMixte in AllPatMat cell by cell
todo.StatCtl1vsCtl2     = 0; %add block order in AllPatMat trial by trial and cell by cell
todo.addBkOrder         = 0; %add block order in AllPatMat trial by trial and cell by cell

WhichPC     = 'katia'; %'marion'
patientID   = {'MERPH' 'LAUTH' 'RAYTH' 'NGUPH' 'ETIAL' 'SALJE' 'RIMLA' 'WARJe' 'DISPi' 'HUSXa' 'FISOl' 'GONFi'} %list of patients to analyze 'MAJAf' 'ARDSY' 
PerOpDir    = '2_perOp'; %Directory name for MUA data
RawDir      = '1_brut';
OutputDir   = '2_preProcessed';
xlsFname    = 'Plexon_global_results_MARION_'; %global excel file name
NbInDir     = '3';
NbOutDir    = '4';
StatsDirIn  = ['statsOut_' NbInDir]; 
StatsDirOut = ['statsOut_' NbOutDir]; %'statsOut';
FigDir      = ['figures_' NbOutDir]; %'figures';
AllFigDir   = ['AllFigures_' NbOutDir];

% define data of interest to be analyzed
key                 = 'Trial';
eventValue          = {'CueOnSet', 'Reaction', 'ITI', 'PtFixOnSet'}; % 'ITI'; 'Fix'; 'Cue'; 'Button'
TimeWindows         = {[-1.5 1.5], [-2.3 0.7], [0 3], [-0.5 2.5]}; %{[-1.8 1.5], [-2.3 1]}; %time windows relative to eventValues
eventOfInterest     = {'CueOnSet', 'Reaction', 'ITI', 'PtFixOnSet'}; % events of interest
StatsWin.event      = {{'CueOnSet', 'CueOnSet', 'CueOnSet', 'ITI', 'PtFixOnSet'}, {'Reaction', 'Reaction'}, {'ITI'}, {'PtFixOnSet'}};
StatsWin.times      = {{[-1 0], [0 0.5], [0.1 0.9], [0 0.7], [0 1] }, {[-0.25 0.25], [-0.3 0.3]}, {[0 0.7]}, {[0 1]}}; %time windows relative to eventOfInterest
conditions          = {'GoControl', 'GoMixte', 'NoGoMixte'};
CondCompare         = {[1 2; 3 2], [1 2]}; %conditions to compare per eventOfInterest {[c1 c2]}: c1-c2
%%% define baselines to do a loop on different baselines
Baselines.name      = {'Bsl_fix', 'Bsl_cue','Bsl_trial'};
Baselines.eventRef  = {'PtFixOnSet', 'CueOnSet', 'ITI'};
Baselines.times     = {[-0.8 0], [-1 0], [0 3.4]};
nRand               = 10000; %number of resamplings for bootstraop test
% oscillation parameters
SamplingFrequency   = 1000; % SamplingFrequency - sampling frequency of the time stamps in Hz
FMin                = 5;    % low boundary of the frequency band of interest in Hz
FMax                = 50;   % high boundary of the frequency band of interest in Hz

%define path
switch WhichPC
    case 'katia'
        addpath(genpath('F:\IR-IHU-ICM\Donnees\git_for_github\LabAnalyses'))
        addpath(genpath('F:\IR-IHU-ICM\Donnees\Scripts\DBS\OmniPlex and MAP Offline SDK Bundle\Plexon Offline SDKs\Matlab Offline Files SDK'))
        DataDir = 'N:\PF-Marche\02_Protocoles_Data\GBMOV\Marion\Marion_tache_GoNoGo\1_data_patients\Park_DBS'; %path where patienstr' data are stored
    case 'marion'
        DataDir = 'C:\Users\marion.albares\Desktop\Marion_tache_GoNoGo\1_data_patients\Park_DBS\STN'; %path where patienstr' data are stored
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
import spk.*
import fig.*
import stat.*

%% colors
%define plot colors:
Col = get(0,'DefaultAxesColorOrder');
%create BlueWhiteRed colormap
bwr = gng.batch.BWRcolormap(2);
%define baseline styles
ValueArray = {'--',':','-.'}';
nbBsl = numel(Baselines.name); %number of baselines
ValueArray = ValueArray(1:nbBsl);
nbComp = cell2mat(cellfun(@size, CondCompare, 'UniformOutput', 0)');

% load AllPatMat to add new patients
if todo.AllPatMat == 2 || todo.SaveCsv || todo.StatNoGovsGoMix || todo.addBkOrder || todo.StatCtl1vsCtl2
    load(fullfile(DataDir , 'AllPatMat.mat'))
elseif todo.AllPatMat == 1
    AllPatMat = [];
end


%%

if todo.StatNoGovsGoMix || todo.addBkOrder || todo.StatCtl1vsCtl2
    AllPatMat = gng.batch.AddInfoInAllPatMat(AllPatMat, todo);
    save(fullfile(DataDir, 'AllPatMat.mat'), 'AllPatMat')
end


%% id event of interest
for eV = 3:4%1:numel(eventOfInterest)

    
    if todo.SaveCsv
        Csv = cell2dataset(AllPatMat(eV).EvMat);
        export(Csv,'file',fullfile(DataDir,['AllPat_' eventOfInterest{eV} '.csv']),'delimiter',';')
    end
    
    idEOI(eV) = find(strcmp(eventValue, eventOfInterest{eV})==1); %eventValue id of event of interest for analyses
    if todo.AllPatMat %== 1
        AllPatMat(eV).EvName     = eventOfInterest{eV};
        AllPatMat(eV).EvMat      = ['PatNb', 'PatName', 'Region', 'Hemi', 'Sec', 'Depth', 'CellName', 'Single/Multi', 'Condition', 'Ipsi/Contra', 'nbTrialReal', ...
            'nbTrial', 'nTrial', 'mTrial', 'sdTrial', 'TR', 'TRoutlier', 'TRnorm', Baselines.name{:}, arrayfun(@(x) ['mWin' x{:}], StatsWin.event{eV}, 'uni', 0)];
        AllPatMat(eV).BsltStE    = [repmat({'tsart', 'tend'}, [1 nbBsl]); num2cell([Baselines.times{:}])];
        AllPatMat(eV).StatsWin = [{'name', 'tsart', 'tend'}; [StatsWin.event{eV}(:) num2cell(cell2mat([StatsWin.times{eV}(:)]))]];
        for bsl_count = 1:nbBsl
            AllPatMat(eV).Bsl(bsl_count).BslName          = Baselines.name(bsl_count); %nbCell * nbTimes
        end
        for c = 1:numel(conditions)
            AllPatMat(eV).cond(c).name = conditions{c};
            AllPatMat(eV).cond(c).infos = ['PatNb', 'PatName', 'Region', 'Hemi', 'Sec', 'Depth', 'Condition', 'CellName', 'Single/Multi', 'nbTrial', ...
                cellfun(@(x,y) [x '_' y],repmat({'nbTrialZ'}, [numel(Baselines.name) 1]),Baselines(:).name', 'uni',0)', 'mTR', 'sdTR', 'mTRnorm', 'Ipsi/Contra',...
                'FR', 'meanISI', 'mFR_Go1', 'mFR_GoNoGo', 'mFRGo2', 'nGo1', 'nGoNoGo', 'nGo2', 'cv', 'cv2', 'lv', 'lvr', 'ir', 'burstS', 'NBspk/busrt', 'burstFreq', 'mBurstDur', 'mIntraBurstFreq', 'mInterBurstInt',...
                'p2p2', 'rms1', 'rms2', 'mFR', Baselines.name{:}, arrayfun(@(x) ['mWin' x{:}], StatsWin.event{eV}, 'uni', 0), ...
                cellfun(@(x,y) [x '_' y],repmat({'sig'}, [numel(Baselines.name) 1]),Baselines(:).name', 'uni',0)', 'sig_r', ...
                cellfun(@(x,y) [x '_' y],repmat({'sigFDR'}, [numel(Baselines.name) 1]),Baselines(:).name', 'uni',0)', 'sig_rcorr'];
                %'OS, 'CS', 'OFq')
        end
        
        
    end
end, clear eV
for eV = 1:numel(Baselines.eventRef)
    Baselines.idEOI(eV) = find(strcmp(eventValue, Baselines.eventRef{eV})==1); %eventValue id of event of interest for baseline
end, clear eV

if todo.BigFig && ~exist(fullfile(DataDir,AllFigDir), 'dir')
    mkdir(DataDir,AllFigDir)
end

if todo.SaveCsv == 0 && todo.StatNoGovsGoMix == 0 && todo.addBkOrder == 0
    %reaction Time
    idCue  = find(strcmp(eventValue, 'CueOnSet')==1);
    idReac = find(strcmp(eventValue, 'Reaction')==1);
    
    %% loop on patients
    for p = 1:numel(patientID)
        patientDir = dir(fullfile(DataDir, ['*' patientID{p}]));
        fullPath = fullfile(DataDir, patientDir.name, PerOpDir);
        %cd(fullPath)
        
        % create output directories if necessary
        if ~exist(fullfile(fullPath,OutputDir,FigDir), 'dir')
            mkdir (fullfile(fullPath,OutputDir),FigDir)
        end
        if ~exist(fullfile(fullPath,OutputDir,StatsDirOut), 'dir')
            mkdir (fullfile(fullPath,OutputDir),StatsDirOut)
        end
        
        %read xls file
        fname = [xlsFname patientID{p} '.xlsx'];
        [N,~,T] = xlsread(fullfile(fullPath,RawDir,fname),1);
        n = size(T,1);
        
        %% loop on plx files
        for j = 2:n
            if ~any(isnan(T{j,2})) && ~any(isnan(T{j,5})) && strncmp(T{j,5},'GBMOV',5)
                clear spkName spkWF
                plxName = T{j,2};
                xlsName = T{j,5};
                count   = 1;
                ind     = 13;
                while 1
                    try
                        if isnan(T{j,ind});
                            break;
                        end
                    catch
                        break;
                    end
                    spkName{count}  = [T{j,ind} '-' T{j,ind+1}];
                    start_t(count)  = T{j,ind + 2};
                    end_t(count)    = T{j,ind + 3};
                    count           = count + 1;
                    ind             = ind + 5;
                end
                
                % LFP name
                [n,names] = plx_adchan_names(fullfile(fullPath,RawDir,plxName));
                for i=1:n
                    names_conc{i}= names(i,:);
                end
                
                indLfp  = strfind(names_conc, 'Lfp');
                ind     = find(~cellfun(@isempty,indLfp));
                LfpName = names_conc(ind);
                
                clear ind indLfp names_conc;
                
                % generate outputFile name
                plxName_parts   = strsplit(plxName,'_');
                BrainStruct     = plxName_parts{2};
                if ~isempty(strfind(BrainStruct, 'Left'))
                    BrainStruct = [strtok(BrainStruct), '_L'];
                elseif ~isempty(strfind(BrainStruct, 'Right'))
                    BrainStruct = [strtok(BrainStruct), '_R'];
                end
                Section     = strrep(plxName_parts{end-1}(strfind(plxName_parts{end-1}, 'sec'): end), ' ', '');
                Depth       = plxName_parts{end}(1:end-7);
                
                %OutputFileName = [patientID{p} '_' BrainStruct '_' Section '_' Depth];
                OutputFileName = [patientID{p} '_' BrainStruct '_' Section '_' Depth '_' NbOutDir];
                InputFileName  = [patientID{p} '_' BrainStruct '_' Section '_' Depth '_' NbInDir];
                
                if todo.createMatfile
                    [data, valid, spkWF, CellStats] = gng.load.trialData(fullfile(fullPath,RawDir,xlsName),fullfile(fullPath,RawDir,plxName),spkName,LfpName,start_t,end_t);
                    if todo.DetectTRoutliers == 0
                        save(fullfile(fullPath,OutputDir,[OutputFileName '.mat']),'data','valid', 'spkName', 'spkWF', ', CellStats');
                    end
                    %                 elseif todo.createMatfile == 0 && todo.Stats == 2; %tmp stats==2
                    %                     spkdat = hd.load.plexon2(fullfile(fullPath,RawDir,plxName),spkName,start_t,end_t);
                    %                     spkWF  = spkdat.spkwf; clear  spkdat
                end
                clear xlsName plxName LfpName start_t end_t;
                
                
                if todo.DetectTRoutliers
                    if todo.createMatfile == 0
                        load(fullfile(fullPath,OutputDir,[InputFileName '.mat']))
                    end
                    data = gng.batch.DetectTRoutliers(data);
                    save(fullfile(fullPath,OutputDir,[OutputFileName '.mat']),'data','valid', 'spkName', 'spkWF', 'CellStats');
                end
                
                if todo.BigFig
                    BigFig = figure('Name', OutputFileName,'NumberTitle','off', 'units', 'centimeters', 'position', [5 5 29.7 21]);
                end
                
                % do stats condition comparisons and create figures
                if todo.BigFig || todo.Stats || todo.CompCond
                    %load Matfile
                    if todo.createMatfile == 0 && todo.DetectTRoutliers == 0
                        load(fullfile(fullPath,OutputDir,[InputFileName '.mat']))
                    end
                    
                    if todo.Stats == 2 || (todo.Stats == 0 && (todo.CompCond || todo.BigFig))
                        load(fullfile(fullPath,OutputDir,StatsDirIn, [InputFileName '_stats.mat']))
                        %                         if todo.Stats == 2
                        %                             save(fullfile(fullPath,OutputDir,[OutputFileName '.mat']),'data', 'valid', 'spkName', 'spkWF');
                        %                         end
                    end
                    
                    %add plot of mean spiking rate per trial accross all conditions, sync sur ITI?
                    clear q temp AllCellNames CellColors
                    q = linq(data);
                    temp = q.where(@(x) ~iscell(x.pointProcess)==1).toArray();
                    AllCellNames = arrayfun(@(x) {x.labels.name}, [temp.pointProcess], 'uni',0);
                    AllCellNames = unique(cat(2,AllCellNames{:}));
                    %define color by cell accross all segments in case there
                    %are more than size(CellColors) names
                    count = 1;
                    for i = 1:numel(AllCellNames)
                        CellColors{i} = Col(count,:);
                        count = mod(count,size(Col,1));
                        count = count + 1;
                    end, clear count
                    
                    %% create spike rate plot accross all segments per cell
                    if todo.Stats == 1
                        % create spike rate plot accross all segments per cell
                        clear r t labels times nbTrial IdxCell NbSpike TrialDur SpikeRate
                        
                        count = 1;
                        for i = 1:numel(temp)
                            if ~iscell(temp(i).pointProcess)
                                labels{count,:} = {temp(i).pointProcess.labels.name};
                                for l = 1:size(labels{count,:},2)
                                    IdxCell             = find(strcmp(AllCellNames, labels{count}{l}),1);
                                    times(i,IdxCell)    = temp(i).pointProcess.times(l);
                                end
                                count = count + 1;
                            end
                        end, clear count IdxCell
                        
                        NbSpike     = cellfun(@length, times);
                        TrialDur    = cell2mat(arrayfun(@(x) x.window, [temp.pointProcess], 'uni',0)');
                        SpikeRate   = NbSpike ./repmat(TrialDur(:,2)-TrialDur(:,1), [1 size(NbSpike,2)]);
                        SpikeRate(cellfun(@isempty, times)) = NaN;clear times
                        
                        %compute FR GoControl1, GoNoGo, GoControl2
                        
                        %%% a refaire)
                        idxCond  = find(cell2mat(arrayfun(@(x) x.info('Trial').isControl, temp, 'uni',0)) .* cell2mat(arrayfun(@(x) x.info('Trial').isCorrect, temp, 'uni',0))==1);
                        numTrial = arrayfun(@(x) x.info('Trial').nTrial, temp);
                        numTrial = numTrial(idxCond);
                        idxGo1   = idxCond(numTrial <= 10);
                        idxGo2   = idxCond(numTrial >= 51);
                        if sum(strfind(upper(OutputFileName), upper('ETIAl_STN_R_sec4_0.3')))>0
                            idxGo2 = idxCond(numTrial >= 11);
                        elseif sum(strfind(upper(OutputFileName), upper('FISOl_STN_L_sec12_0.77')))>0
                            idxGo1 = idxCond(numTrial <= 20);
                            idxGo2 = idxCond(numTrial >= 61);
                        end
                        idxGoNoGo = find(double(cell2mat(arrayfun(@(x) x.info('Trial').isControl, temp, 'uni',0))==0) .* cell2mat(arrayfun(@(x) x.info('Trial').isCorrect, temp, 'uni',0))==1);
                        
                        
                        if todo.Stats
                            if todo.Stats == 1
                                clear psth_stats
                                psth_stats.FileName     = OutputFileName;
                                psth_stats.AllCellNames = AllCellNames;
                                psth_stats.SpikeRate = SpikeRate;
                                %end
                                %calculate SNR
                                clear WFlabel IdxCell
                                for i = 1:numel(AllCellNames)
                                    IdxCell(i) = find(strcmp(spkName, AllCellNames{i}),1);
                                    WFlabel{i} = repmat(IdxCell(i), [1 size(spkWF{IdxCell(i)},2)]);
                                end
                                WF      = cat(2,spkWF{IdxCell});
                                
                                psth_stats.CellStats = CellStats(IdxCell); clear IdxCell
                                
                                %if todo.Stats == 1
                                WFlabel = (cat(2,WFlabel{:}));
                                results = snr(WF, 'labels',WFlabel);
                                uLabels = spkName(unique(WFlabel));
                                for i = 1:numel(AllCellNames)
                                    IdxCell(i) = find(strcmp(uLabels, AllCellNames{i}),1);
                                end
                                psth_stats.SNR = results(IdxCell);
                            end
                            
                            %add CellStats
                            psth_stats.mFR_Go1 = nanmean(SpikeRate(idxCond(idxGo1),:),1);
                            psth_stats.mFR_Go2 = nanmean(SpikeRate(idxCond(idxGo2),:),1);
                            psth_stats.mFR_GoNoGo = nanmean(SpikeRate(idxGoNoGo,:),1);
                            psth_stats.nGo1 = sum(isnan(SpikeRate(idxCond(idxGo1),:))==0,1);
                            psth_stats.nGo2 = sum(isnan(SpikeRate(idxCond(idxGo2),:))==0,1);
                            psth_stats.nGoNoGo = sum(isnan(SpikeRate(idxGoNoGo,:))==0,1);
                            
                        end
                    end
                    
                    if todo.BigFig
                        %plot Spike Rate
                        figure(BigFig)
                        subplot(3,5,1:2)
                        spkR = plot((psth_stats.SpikeRate - repmat(min(psth_stats.SpikeRate), [size(psth_stats.SpikeRate,1) 1]))./repmat((max(psth_stats.SpikeRate) - min(psth_stats.SpikeRate)), [size(psth_stats.SpikeRate,1) 1]) + repmat((0:1:size(psth_stats.SpikeRate,2)-1)+0.5, [size(psth_stats.SpikeRate,1) 1])); hold on
                        plot(repmat([1; size(psth_stats.SpikeRate,1)], [1 size(psth_stats.SpikeRate,2)]), repmat((0:size(psth_stats.SpikeRate,2)-1)+0.5, [2 1]),'k')
                        xlabel('trials'), ylabel('spike rate (min-max norm)'), title(strrep([OutputFileName '_SpikeRate'], '_', ' '))
                        xlim([1 size(psth_stats.SpikeRate,1)]); ylim([0.5 size(psth_stats.SpikeRate,2)+0.5]); set(gca, 'ytick',(1:size(psth_stats.SpikeRate,2))),set(gca, 'yticklabel',AllCellNames)
                        legend(flipud(spkR), flipud(AllCellNames'), 'position', [0  0.1 0.03 0.05])
                    end
                    
                    
                    if todo.CompCond
                        %prepare figure for between condition comparison
                        figStats = figure('Name', [OutputFileName ' Between condition comparison'], 'NumberTitle','off');
                        textGrid = linspace((1/numel(eventOfInterest))/2, 1-(1/numel(eventOfInterest))/2 , numel(eventOfInterest));
                    end
                    
                    %% create psth and raster plot by event type
                    % loop on events
                    for eV = 3:4%1:numel(eventOfInterest)
                        
                        if todo.Stats || todo.BigFig
                            
                            psth_stats.event(eV).eventName = eventValue{eV};
                                                        
                            clear pi
                            % loop on conditions
                            for c = 1:numel(conditions)
                                conditionName = conditions{c};
                                psth_stats.event(eV).cond(c).name = conditionName;
                                                                
                                clear q temp
                                q = linq(data);
                                temp = q.where(@(x) isKey(x.info,key));
                                switch conditionName
                                    case 'GoControl'
                                        temp = q.where(@(x) strcmp(x.info(key).('trial'),'Go'));
                                        if temp.count == 0, display ('No segment with Go'), continue
                                        else temp = q.where(@(x) x.info(key).isControl);
                                            if temp.count == 0, display ('No segment with GoControl'), continue
                                            else temp = q.where(@(x) x.info(key).isCorrect);
                                                if temp.count == 0, display ('No segment with GoControl correct'), continue
                                                else temp = q.toArray();
                                                end
                                            end
                                        end
                                    case 'GoMixte'
                                        temp = q.where(@(x) strcmp(x.info(key).('trial'),'Go'));
                                        if temp.count == 0, display ('No segment with Go'), continue
                                        else temp = q.where(@(x) x.info(key).isControl == 0);
                                            if temp.count == 0, display ('No segment with GoMixte'), continue
                                            else temp = q.where(@(x) x.info(key).isCorrect);
                                                if temp.count == 0, display ('No segment with GoMixte correct'), continue
                                                else temp = q.toArray();
                                                end
                                            end
                                        end
                                    case 'NoGoMixte'
                                        temp = q.where(@(x) strcmp(x.info(key).('trial'),'NoGo'));
                                        if temp.count == 0, display ('No segment with NoGoMixte'), continue
                                        else temp = q.where(@(x) x.info(key).isCorrect);
                                            if temp.count == 0, display ('No segment with NoGoMixte correct'), continue
                                            else temp = q.toArray();
                                            end
                                        end
                                end
                                
                                %synchronize data on event of interest
                                temp.sync('eventProp','name','eventVal',eventValue{eV},'window',[-5 5]);
                                q = linq(temp);
                                
                                %keep only valid sync
                                temp    = q.where(@(x) strcmp(x.validSync.name,'NULL') == 0).toArray();
                                q       = linq(temp);
                                
                                if isempty(temp)
                                    display('No Valid Sync')
                                else
                                    %keep only TRoutlier = 0
                                    temp    = q.where(@(x) x.info('TRoutlier') == 0).toArray();
                                    q       = linq(temp);
                                    if isempty(temp)
                                        display('No segment without outlier')
                                    else
                                        %clear temp2
                                        temp = q.where(@(x) ~iscell(x.pointProcess)==1).toArray(); %temp2
                                        if isempty(temp) %temp2
                                            display('empty segment')
                                        else
                                            
                                            clear CellNames nbCells
                                            %get names of all neurones recorded
                                            CellNames = arrayfun(@(x) {x.labels.name}, [temp.pointProcess], 'uni',0); %temp2
                                            CellNames = unique(cat(2,CellNames{:}));
                                            nbCells = numel(CellNames);
                                            
                                            clear labels times nbTrial IdxCell Tevents;
                                            for ev2=1:numel(eventValue)
                                                Tevents(ev2).name = eventValue{ev2};
                                            end
                                            count = 1; times = num2cell(nan(numel(temp),numel(CellNames))); %temp2
                                            for i = 1:numel(temp) %temp2
                                                if ~iscell(temp(i).pointProcess) %temp2
                                                    labels{count,:} = {temp(i).pointProcess.labels.name}; %temp2
                                                    for l = 1:size(labels{count,:},2)
                                                        IdxCell             = find(strcmp(CellNames, labels{count}{l}),1);
                                                        times(i,IdxCell)    = temp(i).pointProcess.times(l); %temp2
                                                    end
                                                    count = count + 1;
                                                end
                                                %get timing of all eventValue
                                                for ev2=1:numel(eventValue)
                                                    idEvent = find(strcmp({temp(i).eventProcess.values{1, 1}.name}, eventValue{ev2}),1); %temp2
                                                    if ~isempty(idEvent)
                                                        Tevents(ev2).time(i,1) = [temp(i).eventProcess.values{1, 1}(idEvent).tStart]; %temp2
                                                    end
                                                end
                                            end
                                            
                                            %% run psth and stats
                                            %standard psth
                                            %[r,t,~,~] = getPsth(times,0.05);
                                            %psth smoothed using a Gaussian kernel density estimator with optimal bandwidth
                                            
                                            % oscillation score
                                            if todo.Stats == 2;
                                                TrialLength = diff(TimeWindows{eV}) * SamplingFrequency; %duration of trial in sample units
                                                
                                                for cell_count  = 1:nbCells
                                                    TrialList   = cellfun(@(x) (TimeWindows{eV}(1) + x(x>=TimeWindows{eV}(1) & x<=TimeWindows{eV}(2)))*1000, times(:,cell_count)', 'uni', 0); % array of cells of size (1 x Trial_Count)
                                                    TrialNumber = numel(TrialList);               % Suppose we have 20 trials;
                                                    
                                                    [OS, CS, OFq, AC, ACWP, S] = gng.batch.oscore_matlab.OScoreSpikes(TrialList, TrialLength, FMin, FMax, SamplingFrequency); % Muresan et al 2008
                                                    psth_stats.event(eV).cond(c).OS(cell_count,1)  = OS;  % Oscillation Score, depends on frequency, cf paper
                                                    psth_stats.event(eV).cond(c).CS(cell_count,1)  = CS;  % the oscillation score's confidence
                                                    psth_stats.event(eV).cond(c).OFq(cell_count,1) = OFq; % the oscillation frequency
                                                end
                                            end
                                            
                                            if todo.Stats || todo.BigFig
                                                
                                                if todo.Stats  || todo.BigFig
                                                    clear r t r_sem count reps
                                                    [r,t,r_sem,count,reps] = getPsth(times,0.05, 'method','kde', 'window', [-5 5]);
                                                    
                                                    %if todo.Stats == 1 || todo.BigFig
                                                    %keep only window of interest
                                                    r_win       = r(find(t>=TimeWindows{eV}(1),1):find(t<=TimeWindows{eV}(2),1,'last'),:); %nbTime * nbCells
                                                    r_sem_win   = r_sem(find(t>=TimeWindows{eV}(1),1):find(t<=TimeWindows{eV}(2),1,'last'),:);
                                                    reps_win    = reps(find(t>=TimeWindows{eV}(1),1):find(t<=TimeWindows{eV}(2),1,'last'),:,:);%nbTime * nbTrial * nbCells
                                                    t_win       = t(find(t>=TimeWindows{eV}(1),1):find(t<=TimeWindows{eV}(2),1,'last'));
                                                    count_win   = count(find(t>=TimeWindows{eV}(1),1):find(t<=TimeWindows{eV}(2),1,'last'),:);
                                                    %end
                                                    
                                                %if todo.Stats == 1
                                                    %reaction time
                                                    if ~isempty(Tevents(idReac).time)
                                                        psth_stats.event(eV).cond(c).TR = Tevents(idReac).time - Tevents(idCue).time;
                                                    else
                                                        psth_stats.event(eV).cond(c).TR = nan(size(Tevents(idCue).time));
                                                    end
                                                    %outlier
                                                    %psth_stats.event(eV).cond(c).TRoutlier = cellfun(@(x) x{:},(arrayfun(@(x) {x.info('TRoutlier')}, temp, 'uni',0)))'; %temp2
                                                    psth_stats.event(eV).cond(c).TRoutlier = arrayfun(@(x) x.info('TRoutlier'), temp)'; %temp2
                                                  
                                                    psth_stats.event(eV).cond(c).CellNames  = CellNames;
                                                    psth_stats.event(eV).cond(c).t          = t_win;
                                                    psth_stats.event(eV).cond(c).r          = r_win;
                                                    psth_stats.event(eV).cond(c).r_sem      = r_sem_win;
                                                    psth_stats.event(eV).cond(c).nbTrial    = count_win;
                                                    psth_stats.event(eV).cond(c).reps       = reps_win;
                                                    
                                                    
                                                    %left-right
                                                    %psth_stats.event(eV).cond(c).LeftRight = cellfun(@(x) x(:),(arrayfun(@(x) {x.info('Left_Right')}, temp2, 'uni',0)))';
                                                    psth_stats.event(eV).cond(c).LeftRight = repmat({'r'}, [size(psth_stats.event(eV).cond(c).reps,2) 1]);
                                                end
                                                
                                                psth_stats.event(eV).cond(c).nbTrialReal = arrayfun(@(x) x.info('Trial').nTrial, temp)';
                                                
                                                %get baselines [BslTiming, Bsl] = getBaseline(EventTimes, tstart, tend, reps);
                                                %loop on beselines
                                                clear meanBsl
                                                for bsl_count = 1:nbBsl
                                                    if todo.Stats || todo.BigFig
                                                        [BslTiming, Bsl] = gng.batch.getBaseline(Tevents(Baselines.idEOI(bsl_count)).time, Baselines.times{bsl_count}(1), Baselines.times{bsl_count}(2), reps, t);
                                                        meanBsl(bsl_count,:) = squeeze(nanmean(nanmean(Bsl),2))'; %nbBsl * nbCell
                                                        
                                                        psth_stats.event(eV).cond(c).Bsl(bsl_count).BslName = Baselines.name(bsl_count);
                                                        psth_stats.event(eV).cond(c).Bsl(bsl_count).mBsl    = reshape(nanmean(Bsl), [size(Bsl,2) size(Bsl, 3)]); %nbTrials * nbCells
                                                        psth_stats.event(eV).cond(c).Bsl(bsl_count).sdBsl   = reshape(nanstd(Bsl), [size(Bsl,2) size(Bsl, 3)]); %nbTrials * nbCells
                                                        mBsl = psth_stats.event(eV).cond(c).Bsl(bsl_count).mBsl; mBsl(round(mBsl)==0) = NaN; %nbTrial * nbCells
                                                        sdBsl = psth_stats.event(eV).cond(c).Bsl(bsl_count).sdBsl; sdBsl(round(sdBsl)==0) = NaN;
                                                        psth_stats.event(eV).cond(c).Bsl(bsl_count).nbTrial_z = min([sum(isnan(mBsl)==0,1); sum(isnan(sdBsl)==0,1)], [], 1); %1 * nbCell
                                                        
                                                        if todo.Stats %== 1
                                                            psth_stats.event(eV).cond(c).Bsl(bsl_count).tStE    = Baselines.times{bsl_count};
                                                            
                                                            % wilcoxon rank sum stats and fdr correction
                                                            for cell_count = 1:nbCells %size(reps_win,3)
                                                                for t_count = 1:size(reps_win,1)
                                                                    reps_tmp            = squeeze(reps_win(t_count,isnan(reps_win(t_count,:,cell_count))==0,cell_count))';
                                                                    Bsl_tmp             = squeeze(nanmean(Bsl(:,:,cell_count),1))';
                                                                    [wp,wh,fdr_stats]   = ranksum(reps_tmp, Bsl_tmp(isnan(Bsl_tmp)==0));
                                                                    psth_stats.event(eV).cond(c).Bsl(bsl_count).p(t_count, cell_count) = wp;
                                                                    psth_stats.event(eV).cond(c).Bsl(bsl_count).h(t_count, cell_count) = wh;
                                                                    if isfield(fdr_stats,'zval')
                                                                        psth_stats.event(eV).cond(c).Bsl(bsl_count).z(t_count, cell_count) = fdr_stats.zval;
                                                                    end
                                                                end
                                                                [fdrh, crit_p, adj_p]=fdr_bh(psth_stats.event(eV).cond(c).Bsl(bsl_count).p(:,cell_count),0.05,'pdep','yes');
                                                                psth_stats.event(eV).cond(c).Bsl(bsl_count).fdrh(:, cell_count)     = fdrh';
                                                                psth_stats.event(eV).cond(c).Bsl(bsl_count).crit_p(cell_count)      = crit_p;
                                                                psth_stats.event(eV).cond(c).Bsl(bsl_count).adj_p(:, cell_count)    = adj_p';
                                                            end
                                                            
                                                            %z-score per baseline
                                                            mBsl  = repmat(reshape(mBsl, [1 size(mBsl)]), [size(psth_stats.event(eV).cond(c).reps,1) 1 1]); %nbTime * nbTrial * nbCells
                                                            sdBsl  = repmat(reshape(sdBsl, [1 size(sdBsl)]), [size(psth_stats.event(eV).cond(c).reps,1) 1 1]); %nbTime * nbTrial * nbCells
                                                            psth_stats.event(eV).cond(c).Bsl(bsl_count).psth_zscore = squeeze(nanmean((psth_stats.event(eV).cond(c).reps - mBsl)./sdBsl,2)); %nbTime * nbCells
                                                        end
                                                    end
                                                end
                                                
                                                %get mean activity on stats windows
                                                for statswin_count = 1:numel(StatsWin.event{eV})
                                                    psth_stats.event(eV).cond(c).StatsWin(statswin_count).event = StatsWin.event{eV}{statswin_count};
                                                    psth_stats.event(eV).cond(c).StatsWin(statswin_count).t     = StatsWin.times{eV}{statswin_count};
                                                    
                                                    %find event in Tevent
                                                    idEv = find(strcmp({Tevents.name}, StatsWin.event{eV}{statswin_count}));
                                                    [WinTiming, r_winStats] = gng.batch.getBaseline(Tevents(idEv).time, StatsWin.times{eV}{statswin_count}(1), StatsWin.times{eV}{statswin_count}(2), reps, t);
                                                    
                                                    %r_winStats = reps_win(find(t_win>=StatsWin.times{eV}(1),1):find(t_win<=StatsWin.times{eV}(2),1,'last'),:,:); %nbTime * nbTrial * nbCells
                                                    psth_stats.event(eV).cond(c).StatsWin(statswin_count).mean  = reshape(squeeze(nanmean(r_winStats)), [size(r_winStats,2) size(r_winStats,3)]); %nbTrial *nbCells
                                                    psth_stats.event(eV).cond(c).StatsWin(statswin_count).sd    = reshape(squeeze(nanstd(r_winStats)), [size(r_winStats,2) size(r_winStats,3)]); %nbTrial *nbCells
                                                end
                                                if todo.Stats %== 1
                                                    % resampling test
                                                    [rStats, rStats_bonf, rTime] = gng.batch.ResamplingTest(times,nRand,TimeWindows{eV}(1),TimeWindows{eV}(2));
                                                    psth_stats.event(eV).cond(c).resample.rstats = rStats; %nbTime * nbCells
                                                    psth_stats.event(eV).cond(c).resample.rstats_bonf = rStats_bonf; %nbTime * nbCells
                                                    psth_stats.event(eV).cond(c).resample.t = rTime; %nbTime * 1
                                                end
                                            end
                                            
                                            
                                            %% create and save figure
                                            if todo.BigFig
                                                figure(BigFig)
                                                %get color of active cells during event
                                                clear Tmp_col IdxCell
                                                EventTimes = repmat([Tevents(idEOI).time], [nbCells 1]); %(nbTrials * nbCell) * nbEvents
                                                EventTimes = EventTimes(isnan(squeeze(reps_win(1,:,:)))==0,:);
                                                for i = 1:nbCells %numel(CellNames)
                                                    IdxCell(i) = find(strcmp(AllCellNames, CellNames{i}),1);
                                                    Tmp_col{i} = CellColors{IdxCell(i)};
                                                end
                                                
                                                % raster plot
                                                h = subplot(3,5,5+(eV-1)*3+c);
                                                plotRaster(times,'window',TimeWindows{eV}, 'grpColor',Tmp_col, 'handle',h);
                                                %add lines at event times
                                                plot(EventTimes, repmat(1:size(EventTimes,1), [size(EventTimes,2), 1])', 'k')
                                                title(strrep(eventValue{eV}, '_', ' '))
                                                
                                                subplot(3,5,10+(eV-1)*3+c)
                                                % normalize r values between -1 and 1
                                                rMax        = max([meanBsl; r_win]); rMin = min([meanBsl; r_win]);
                                                r_norm      = (r_win - repmat(rMin, [size(r_win,1) 1]))./(repmat((rMax - rMin), [size(r_win,1) 1])) + repmat((0:(size(r_win,2))-1)+0.5, [size(r_win,1) 1]);
                                                rsem_norm   = r_sem_win./repmat((rMax - rMin), [size(r_win,1) 1]);
                                                %loop on baselines
                                                clear mBsl_norm
                                                for bsl_count = 1:nbBsl
                                                    mBsl_norm(bsl_count,:) = (meanBsl(bsl_count,:) - rMin)./(rMax - rMin) + (0:(size(r_win,2))-1)+0.5; %size : nb Bsl * nbNeurones
                                                end
                                                
                                                %add all baselines
                                                %sign of difference
                                                DiffSign    = sign(repmat(r_win,[1 1 nbBsl]) - permute(repmat(meanBsl, [1 1 size(r_win,1)]), [3 2 1]));%nbTime * nbCells * nbBsl
                                                BslMat      = cat(3,psth_stats.event(eV).cond(c).Bsl(:).fdrh).*DiffSign;
                                                BslMat      = reshape(permute(BslMat,[1 3 2]), [size(BslMat,1) size(BslMat,2) * size(BslMat,3)])';
                                                yBsl        = linspace(0.5+(1/nbBsl)/2, nbCells + 0.5-(1/nbBsl)/2 , nbCells * nbBsl); %replace size(r,2) by nbCells
                                                ygrid       = linspace(0.5, nbCells + 0.5 , size(r,2) * nbBsl+1);
                                                
                                                %add resampling test
                                                rTime = psth_stats.event(eV).cond(c).resample.t;
                                                rStats = psth_stats.event(eV).cond(c).resample.rstats_bonf;
                                                imagesc(rTime, 1:nbCells, abs(abs(rStats)-1)'), colormap('gray'), alpha(0.1), caxis([0 1]), hold on
                                                gng.batch.freezeColors
                                                
                                                %add fdrh stats
                                                imagesc(t_win, yBsl, BslMat), caxis([-1 1]), colormap(bwr), alpha(0.1)
                                                       
                                                % add lines between baselines
                                                plot(repmat(t_win([1 end]), [1 length(ygrid)-2]), repmat(ygrid(2:end-1), [2 1]), 'color', [0.9 0.9 0.9])
                                                % add lines between cells
                                                plot(repmat(t_win([1 end]), [1 nbCells-1]), repmat((1:nbCells-1)+0.5, [2 1]),'k')
                                                set(gca,'ytick',1:nbCells,'YDir','normal'), hold on

                                                % plot each neurone
                                                for i = 1:nbCells
                                                    %plot mean spiking rate
                                                    pp.r(IdxCell(i)) = plot(t_win,r_norm(:,i),'color', Tmp_col{i});
                                                    %add sem pos et neg
                                                    plot([t_win t_win],[r_norm(:,i)+rsem_norm(:,i) r_norm(:,i)-rsem_norm(:,i)],'LineStyle', ':','color', Tmp_col{i})
                                                    %plot mean baselines
                                                    pp.s = plot(repmat(t_win,[1 size(mBsl_norm,1)]),repmat(mBsl_norm(:,i)',[length(t_win) 1]),'color', Tmp_col{i});%[0.5 0.5 0.5]);
                                                    set(pp.s, {'LineStyle'}, ValueArray)
                                                end
                                                
                                                % plot the zero line
                                                plot([0 0], get(gca,'ylim'), 'k'),  xlim(TimeWindows{eV})
                                                title(conditions{c}), ylabel('spiking rate (min-max norm)')
                                            end
                                        end
                                    end
                                end
                            end
%                             if todo.Stats
%                                 save(fullfile(fullPath,OutputDir,StatsDirOut, [OutputFileName '_stats.mat']), 'psth_stats')
%                             end
                        end
                        
                        %% compare conditions : GoMixte - GoControl; NoGoMixte - GoMixte
                        if todo.CompCond
                            if todo.Stats == 0
                                load(fullfile(fullPath, OutputDir,StatsDirIn, [InputFileName '_stats.mat']))
                            end
                            figure(figStats)
                            
                            %check if cond exist
                            for comp = 1 : size(CondCompare{eV},1)
                                psth_stats.event(eV).comp(comp).name = [conditions{CondCompare{eV}(comp,1)} '-' conditions{CondCompare{eV}(comp,2)}];
                                subplot(numel(eventOfInterest), max(nbComp(:,1)), (eV - 1)*max(nbComp(:,1)) + comp)
                                hold on
                                if eV == 2 && comp==1, title(strrep(OutputFileName, '_', ' ')), end
                                if eV == 1, title([conditions{CondCompare{eV}(comp,1)} '-' conditions{CondCompare{eV}(comp,2)}]), end
                                
                                if isfield(psth_stats.event(eV).cond(CondCompare{eV}(comp,1)), 't') && isfield(psth_stats.event(eV).cond(CondCompare{eV}(comp,2)), 't') ...
                                        && ~isempty(psth_stats.event(eV).cond(CondCompare{eV}(comp,1)).t) && ~isempty(psth_stats.event(eV).cond(CondCompare{eV}(comp,2)).t)
                                    c1 = psth_stats.event(eV).cond(CondCompare{eV}(comp,1));
                                    c2 = psth_stats.event(eV).cond(CondCompare{eV}(comp,2));
                                    %ckeep only common time bin and cells
                                    %time bins
                                    reps1 = c1.reps(find(round(c1.t,3) == round(max(c1.t(1), c2.t(1)),3)) : find(round(c1.t,3) == round(min(c1.t(end), c2.t(end)),3)),:,:);
                                    reps2 = c2.reps(find(round(c2.t,3) == round(max(c1.t(1), c2.t(1)),3)) : find(round(c2.t,3) == round(min(c1.t(end), c2.t(end)),3)),:,:);
                                    psth_stats.event(eV).comp(comp).t = c1.t(find(round(c1.t,3) == round(max(c1.t(1), c2.t(1)),3)) : find(round(c1.t,3) == round(min(c1.t(end), c2.t(end)),3)));
                                    
                                    cell_comp = 0;
                                    
                                    psth_stats.event(eV).comp(comp).CellNames = cell(1, min(numel(c2.CellNames), numel(c1.CellNames)));
                                    for cell_count1 = 1:numel(c1.CellNames)
                                        %find same cell in c2
                                        cell_count2 = find(strcmp(c2.CellNames, c1.CellNames{cell_count1}));
                                        
                                        if ~isempty(cell_count2)
                                            cell_comp = cell_comp + 1;
                                            psth_stats.event(eV).comp(comp).CellNames{cell_comp} = c1.CellNames{cell_count1};
                                            for t_count = 1 : numel(psth_stats.event(eV).comp(comp).t)
                                                [wp,wh,fdr_stats] = ranksum(squeeze(reps1(t_count,:,cell_count1))', squeeze(reps2(t_count,:,cell_count2))); %meanBsl(:,cell_count));
                                                psth_stats.event(eV).comp(comp).p(t_count, cell_comp) = wp;
                                                psth_stats.event(eV).comp(comp).h(t_count, cell_comp) = wh;
                                                if isfield(fdr_stats,'zval')
                                                    psth_stats.event(eV).comp(comp).z(t_count, cell_comp) = fdr_stats.zval;
                                                end
                                            end
                                            [fdrh, crit_p, adj_p]=fdr_bh(psth_stats.event(eV).comp(comp).p(:,cell_comp),0.05,'pdep','yes');
                                            psth_stats.event(eV).comp(comp).fdrh(:, cell_comp)      = fdrh';
                                            psth_stats.event(eV).comp(comp).crit_p(cell_comp)       = crit_p;
                                            psth_stats.event(eV).comp(comp).adj_p(:, cell_comp)     = adj_p';
                                            
                                            %diff
                                            psth_stats.event(eV).comp(comp).rdiff(:, cell_comp) =  squeeze(nanmean(reps1(:,:,cell_count1),2)) -  squeeze(nanmean(reps2(:,:,cell_count2),2));
                                            
                                            %plot
                                            % add lines between cells
                                            plot(psth_stats.event(eV).comp(comp).t([1 end]), repmat(cell_comp + 0.5, [2 1]),'k')
                                            plot(psth_stats.event(eV).comp(comp).t([1 end]), repmat(cell_comp, [2 1]),'--', 'color', [0.5 0.5 0.5])
                                            %plot significant periods
                                            SigMat = permute(psth_stats.event(eV).comp(comp).fdrh(:,cell_comp).*sign(psth_stats.event(eV).comp(comp).rdiff(:, cell_comp)), [2 1]); %nbTime * nbCells
                                            imagesc(psth_stats.event(eV).comp(comp).t, cell_comp, SigMat), caxis([-1 1]), colormap(bwr), alpha(0.1)
                                            
                                            % plot rdiff
                                            Tmp_col     = CellColors{find(strcmp(AllCellNames,  c1.CellNames{cell_count1}),1)};
                                            rdiffMax    = max(abs(psth_stats.event(eV).comp(comp).rdiff(:, cell_comp)));
                                            plot(psth_stats.event(eV).comp(comp).t, psth_stats.event(eV).comp(comp).rdiff(:, cell_comp)./(2*rdiffMax) + cell_comp, 'color', Tmp_col)
                                        end
                                    end
                                    plot([0 0],[0.5 cell_comp+0.5],'k')
                                    xlim(psth_stats.event(eV).comp(comp).t([1 end]))
                                    ylim([0.5 cell_comp+0.5]), xlabel('Time'), ylabel('Spike rate diff')
                                else
                                    
                                    display('no condition to compare')
                                end
                            end
                        end
                    end
                    if todo.BigFig
                        figure(BigFig)
                        %add table
                        %Create data
                        clear TableData
                        TableData(:,1)    = [psth_stats.SNR(:).p2p]';
                        TableData(:,2)    = [psth_stats.SNR(:).rms1]';
                        TableData(:,3)    = [psth_stats.SNR(:).rms2]';
                        TableData(:,4)    = nanmean(psth_stats.SpikeRate);
                        TableData(:,5)    = nanstd(psth_stats.SpikeRate);
                        TableData(:,6:10) = nan;
                        for eV = 1:numel(eventOfInterest)
                            for c = 1:numel(conditions)
                                if isfield(psth_stats.event(eV).cond(c), 'CellNames') && ~isempty(psth_stats.event(eV).cond(c).CellNames)
                                    clear IdxCell mBsl
                                    for i = 1:numel(psth_stats.event(eV).cond(c).CellNames)
                                        IdxCell(i) = find(strcmp(AllCellNames, psth_stats.event(eV).cond(c).CellNames{i}),1);
                                    end
                                    mPsth = nanmean(psth_stats.event(eV).cond(c).r,1);
                                    TableData(IdxCell,(eV-1)*3 + 5 + c) = mPsth;
                                end
                            end
                        end
                        
                        % Create the column and row names in cell arrays
                        cnames = {'p2p2', 'rms1', 'rms2','mFR', 'sdFR', 'Cc','Cm','Cngm','Rc','Rm'};
                        rnames = AllCellNames';
                        
                        fun = @(x) sprintf('%0.2f', x);
                        D = cellfun(@(x) sprintf('%0.2f', x), num2cell(round(TableData,2)), 'UniformOutput',0);
                        
                        % Create the uitable
                        t = uitable(BigFig,'Data',flipud(D),...
                            'ColumnName',cnames,...
                            'RowName',flipud(rnames),...
                            'ColumnWidth',{45});
                        subplot(3,5,3:5)
                        tablePos = get(subplot(3,5,3:5),'position');
                        
                        delete(subplot(3,5,3:5))
                        set(t,'units','normalized')
                        set(t,'position',tablePos)
                        ax1 = axes('Position',[0 0 1 1],'Visible','off');
                        axes(ax1);
                        text(0.5, 0.94,  'SNR / Spike rate all trials / per condition (Hz)', 'fontweight','bold', 'fontsize', 12)
                        
                        %add legend for baseline
                        for bsl_count = 1:nbBsl
                            text(0.02, 1-bsl_count/20, [ValueArray{bsl_count} ' ' Baselines.name{bsl_count}(5:end)])
                        end
                        
                        saveas(BigFig, fullfile(fullPath, OutputDir,FigDir, [OutputFileName '.fig']), 'fig')
                        set(BigFig,'PaperUnits','centimeters','PaperPosition',[0 0 29.7 21])
                        print(fullfile(DataDir, AllFigDir, [OutputFileName '.png']), '-dpng')
                        close(BigFig)
                    end
                    
                    if todo.Stats
                        save(fullfile(fullPath, OutputDir,StatsDirOut, [OutputFileName '_stats.mat']), 'psth_stats')
                    end
                    
                    if todo.CompCond
                        figure(figStats)
                        ax1 = axes('Position',[0 0 1 1],'Visible','off');
                        axes(ax1);
                        for eV = 1:numel(eventOfInterest)
                            text(0.025, textGrid(numel(eventOfInterest) - eV +1), eventOfInterest{eV},'rotation',90,'verticalalignment', 'middle')
                        end
                        
                        saveas(figStats, fullfile(fullPath, OutputDir, FigDir, [OutputFileName 'CompCond.fig']), 'fig')
                        saveas(figStats, fullfile(fullPath, OutputDir, FigDir, [OutputFileName 'CompCond.jpg']), 'jpg')
                        close(figStats)
                    end
                end
                
                %% Create Global matrix with all patients and cells
                if todo.AllPatMat
                    if todo.Stats == 0
                        clear psth_stats
                        load(fullfile(fullPath, OutputDir, StatsDir, [InputFileName '_stats.mat']))
                    end
                    
                    for eV = 3:4%1:numel(eventOfInterest)
                        cGoControl  = find(strcmp(conditions, 'GoControl'));
                        TRgoControl = nanmean(psth_stats.event(eV).cond(cGoControl).TR);
                        for c = 1:numel(conditions)
                            if isfield(psth_stats.event(eV).cond(c), 'CellNames') && ~isempty(psth_stats.event(eV).cond(c).CellNames)
                                x   = size(AllPatMat(eV).EvMat,1) + 1;
                                x1  = size(AllPatMat(eV).cond(c).infos,1) + 1;
                                if x1>2
                                    %check min and max t, and reduce matrixes to the shortest
                                    tminAll = round(min(min(AllPatMat(eV).cond(c).psth_t)),3); tminPsth = round(min(min(psth_stats.event(eV).cond(c).t)),3);
                                    tmaxAll = round(max(max(AllPatMat(eV).cond(c).psth_t)),3); tmaxPsth = round(max(max(psth_stats.event(eV).cond(c).t)),3);
                                    if tminAll ~= tminPsth || tmaxAll ~= tmaxPsth
                                        %AllPat
                                        idMin = find(round(AllPatMat(eV).cond(c).psth_t(1,:),3) == max(tminAll, tminPsth));
                                        idMax = find(round(AllPatMat(eV).cond(c).psth_t(1,:),3) == min(tmaxAll, tmaxPsth));
                                        AllPatMat(eV).cond(c).psth_t         = AllPatMat(eV).cond(c).psth_t(:,idMin:idMax);
                                        AllPatMat(eV).cond(c).psth_r         = AllPatMat(eV).cond(c).psth_r(:,idMin:idMax); clear idMin idMax
                                        %psth
                                        idMin = find(round(psth_stats.event(eV).cond(c).t,3) == max(tminAll, tminPsth));
                                        idMax = find(round(psth_stats.event(eV).cond(c).t,3) == min(tmaxAll, tmaxPsth));
                                        psth_stats.event(eV).cond(c).t          = psth_stats.event(eV).cond(c).t(idMin:idMax);
                                        psth_stats.event(eV).cond(c).r          = psth_stats.event(eV).cond(c).r(idMin:idMax,:); clear idMin idMax
                                    end
                                end
                                %{'PatNb', 'PatName', 'Region', 'Hemi', 'Sec', 'Depth', 'CellName', 'Single/Multi', 'Condition', 'Ipsi/Contra', 'nbTrialReal', 'nbTrial', 'nTrial', 'mTrial', 'sdTrial', 'TR', 'TRoutlier', 'TRnorm', Baselines.name, 'mWin'};
                                %'p2p2', 'rms1', 'rms2', 'mFR', 'sdFR', 
                                clear IdxCell
                                for i = 1:numel(psth_stats.event(eV).cond(c).CellNames)
                                    IdxCell(i) = find(strcmp(psth_stats.AllCellNames, psth_stats.event(eV).cond(c).CellNames{i}),1);
                                end
                                
                                nbCells     = numel(psth_stats.event(eV).cond(c).CellNames);
                                TotNbTrials = sum(unique(psth_stats.event(eV).cond(c).nbTrial, 'rows'));
                                mTrial      = nanmean(psth_stats.event(eV).cond(c).reps); %nbTimes * nbTrial * nbCell
                                nbTrialMax  = size(mTrial,2);
                                PatCellName = strsplit(OutputFileName, '_'); if strcmp(PatCellName{4}, 'sec'), PatCellName{4}='sec0'; end
                                PatCellName = [strtok(patientDir.name, '_') '_' PatCellName{3} '_' PatCellName{4}];
                                PatCellName = reshape(repmat(cellfun(@(x,y) [x '_' y],repmat({PatCellName}, [1, nbCells]), psth_stats.event(eV).cond(c).CellNames,'uni',0), [nbTrialMax 1]), [nbTrialMax * nbCells, 1]); %nbTrial * nbCell
                                SUA_MUA     = cellfun(@(x) strsplit(x, '-'), psth_stats.event(eV).cond(c).CellNames,'uni',0);
                                SUA_MUA     = reshape(repmat(cellfun(@(x) x(2), SUA_MUA), [nbTrialMax 1]), [nbTrialMax * nbCells, 1]); %(nbTrial * nbCell) * 1
                                nbTrialReal = reshape(repmat(psth_stats.event(eV).cond(c).nbTrialReal, [1 nbCells]), [nbTrialMax * nbCells, 1]); %(nbTrial * nbCell) * 1
                                nbTrial     = reshape(repmat(unique(psth_stats.event(eV).cond(c).nbTrial, 'rows'), [nbTrialMax 1]), [nbTrialMax * nbCells, 1]); %(nbTrial * nbCell) * 1
                                nTrial      = reshape(repmat([1:nbTrialMax]', [1 nbCells]), [nbTrialMax * nbCells, 1]); %(nbTrial * nbCell) * 1
                                mTrial      = reshape(squeeze(mTrial), [nbTrialMax * nbCells, 1]); %(nbTrial * nbCell) * 1
                                sdTrial     = reshape(squeeze(nanstd(psth_stats.event(eV).cond(c).reps)), [nbTrialMax * nbCells, 1]);  %(nbTrial * nbCell) * 1
                                TR          = reshape(repmat(psth_stats.event(eV).cond(c).TR, [1 nbCells]), [nbTrialMax * nbCells, 1]); %(nbTrial * nbCell) * 1
                                TRoutlier   = reshape(repmat(psth_stats.event(eV).cond(c).TRoutlier, [1 nbCells]), [nbTrialMax * nbCells, 1]); %(nbTrial * nbCell) * 1
                                TRnorm      = TR./TRgoControl;
                                mBsl        = arrayfun(@(x) reshape(x.mBsl, [nbTrialMax * nbCells, 1]), psth_stats.event(eV).cond(c).Bsl, 'uni',0); % 1 * nbBsl (cells of (nbTrial * nbCell) * 1))
                                mWin        = arrayfun(@(x) reshape(x.mean, [nbTrialMax * nbCells, 1]), psth_stats.event(eV).cond(c).StatsWin, 'uni',0); % 1 * nbWin (cells of (nbTrial * nbCell) * 1))
                                LeftRight   = reshape(repmat(psth_stats.event(eV).cond(c).LeftRight, [1 nbCells]), [nbTrialMax * nbCells, 1]); %(nbTrial * nbCell) * 1
                                isValidTial = isnan(mTrial)==0; %nbTrial * nbCell
                                
                                AllPatMat(eV).EvMat(x:x+TotNbTrials-1,:) = [repmat({strtok(patientDir.name, '_')}, [TotNbTrials, 1]), ... %PatNb
                                    repmat(strsplit(OutputFileName(1:end-2),'_'), [TotNbTrials, 1]), ... %PatName Region Hemi Sec Depth %repmat(strsplit(OutputFileName,'_'), [TotNbTrials, 1]), ... %PatName Region Hemi Sec Depth
                                    PatCellName(isValidTial), ... %CellName
                                    num2cell(SUA_MUA(isValidTial)), ... % SUA_MUA
                                    repmat(conditions(c), [TotNbTrials, 1]), ... %Condition     %num2cell(Valid(isValidTial)), ... %valid
                                    num2cell(LeftRight(isValidTial)), ... % LeftRight
                                    num2cell(nbTrialReal(isValidTial)), ... % nbTrialReal, during task
                                    num2cell(nbTrial(isValidTial)), ... %nbTrial
                                    num2cell(nTrial(isValidTial)), ... %nTrial
                                    num2cell(mTrial(isValidTial)), ... %mTrial
                                    num2cell(sdTrial(isValidTial)), ... %sdTrial
                                    num2cell(TR(isValidTial)), ... %TR
                                    num2cell(TRoutlier(isValidTial)), ... %TRoutlier
                                    num2cell(TRnorm(isValidTial)), ... %TRnorm
                                    num2cell(cell2mat(cellfun(@(x) x(isValidTial), mBsl,'uni',0))), ... %BaselinesMean
                                    num2cell(cell2mat(cellfun(@(x) x(isValidTial), mWin,'uni',0)))]; %mWin
                                % ['PatNb', 'PatName', 'Region', 'Hemi', 'Sec', 'Depth', 'Condition', 'CellName', 'Single/Multi', 'nbTrial', 
                                % cellfun(@(x,y) [x '_' y],repmat({'nbTrialZ'}, [numel(Baselines.name) 1]),Baselines(:).name', 'uni',0)', 'mTR', 'sdTR', 'mTRnorm', 'Ipsi/Contra', 
                                %'FR', 'meanISI', 'mFR_Go1', 'mFR_GoNoGo', 'mFRGo2', 'nGo1', 'nGoNoGo', 'nGo2', 'cv', 'cv2', 'lv', 'lvr', 'ir', 'burstS', 'NBspk/busrt', 'burstFreq', 'mBurstDur', 'mIntraBurstFreq', 'mInterBurstInt', 
                                %'p2p2', 'rms1', 'rms2', 'mFR', Baselines.name{:}, arrayfun(@(x) ['mWin' x{:}], StatsWin.event{eV}, 'uni', 0),
                                % cellfun(@(x,y) [x '_' y],repmat({'sig'}, [numel(Baselines.name) 1]),Baselines(:).name', 'uni',0), 'sig_r', cellfun(@(x,y) [x '_' y],repmat({'sigFDR'}, [numel(Baselines.name) 1]),Baselines(:).name', 'uni',0)', 'sig_rcorr']
                                [uPatCellName, idu] = unique(PatCellName);
                                AllPatMat(eV).cond(c).infos(x1:x1+nbCells-1,:)              = [repmat([strtok(patientDir.name, '_') strsplit(OutputFileName(1:end-2),'_') psth_stats.event(eV).cond(c).name], [nbCells, 1]), ...
                                    uPatCellName SUA_MUA(idu) num2cell(nbTrial(idu)), num2cell(cat(1,psth_stats.event(eV).cond(c).Bsl(:).nbTrial_z)'),...
                                    repmat([nanmean(psth_stats.event(eV).cond(c).TR) nanstd(psth_stats.event(eV).cond(c).TR) nanmean(psth_stats.event(eV).cond(c).TR./TRgoControl),...
                                    unique(psth_stats.event(eV).cond(c).LeftRight)], [nbCells, 1]), ...
                                    {psth_stats.CellStats(IdxCell).SpikeRate}', {psth_stats.CellStats(IdxCell).meanISI}', ...
                                    num2cell(psth_stats.mFR_Go1(IdxCell)'), num2cell(psth_stats.mFR_GoNoGo(IdxCell)'), num2cell(psth_stats.mFR_Go2(IdxCell)'),...
                                    num2cell(psth_stats.nGo1(IdxCell)'), num2cell(psth_stats.nGoNoGo(IdxCell)'), num2cell(psth_stats.nGo2(IdxCell)'),...
                                    num2cell(arrayfun(@(x) x.reg.cv, psth_stats.CellStats(IdxCell))'), num2cell(arrayfun(@(x) x.reg.cv2, psth_stats.CellStats(IdxCell))'), ...
                                    num2cell(arrayfun(@(x) x.reg.lv, psth_stats.CellStats(IdxCell))'), num2cell(arrayfun(@(x) x.reg.lvr, psth_stats.CellStats(IdxCell))'), ...
                                    num2cell(arrayfun(@(x) x.reg.ir, psth_stats.CellStats(IdxCell))'), num2cell(arrayfun(@(x) x.burst.meanS, psth_stats.CellStats(IdxCell))'), ...
                                    num2cell(arrayfun(@(x) x.burst.meanNbSpikePerBurst, psth_stats.CellStats(IdxCell))'), num2cell(arrayfun(@(x) x.burst.BurstFreq, psth_stats.CellStats(IdxCell))'),...
                                    num2cell(arrayfun(@(x) x.burst.meanBurstDur, psth_stats.CellStats(IdxCell))'), num2cell(arrayfun(@(x) x.burst.meanIntraBurstFreq, psth_stats.CellStats(IdxCell))'),...
                                    num2cell(arrayfun(@(x) x.burst.meanInterBurstInt, psth_stats.CellStats(IdxCell))'),...
                                    {psth_stats.SNR(IdxCell).p2p}', {psth_stats.SNR(IdxCell).rms1}', {psth_stats.SNR(IdxCell).rms2}', ...
                                    num2cell(nanmean(psth_stats.SpikeRate(:,IdxCell))'), num2cell(cell2mat(arrayfun(@(x) nanmean(x.mBsl,1)', psth_stats.event(eV).cond(c).Bsl,'uni',0))), ...
                                    num2cell(cell2mat(arrayfun(@(x) nanmean(x.mean,1)', psth_stats.event(eV).cond(c).StatsWin,'uni',0))), ...
                                    num2cell(cell2mat(arrayfun(@(x) sum(abs(x.h))'>0, psth_stats.event(eV).cond(c).Bsl,'uni',0))),...
                                    num2cell(sum(abs(psth_stats.event(eV).cond(c).resample.rstats))>0)',...
                                    num2cell(cell2mat(arrayfun(@(x) sum(abs(x.fdrh))'>0, psth_stats.event(eV).cond(c).Bsl,'uni',0))), ...
                                    num2cell(sum(abs(psth_stats.event(eV).cond(c).resample.rstats_bonf))>0)']; % num2cell(Valid(idu))
                                    % num2cell(psth_stats.event(eV).cond(c).OS(IdxCell)'),...
                                    % num2cell(psth_stats.event(eV).cond(c).CS(IdxCell)'),...
                                    % num2cell(psth_stats.event(eV).cond(c).OFq(IdxCell)'),...
                                    
                                AllPatMat(eV).cond(c).psth_r(x1-1:x1+nbCells-2,:)           = psth_stats.event(eV).cond(c).r'; %nbCell * nbTimes
                                AllPatMat(eV).cond(c).psth_t(x1-1:x1+nbCells-2,:)           = repmat(psth_stats.event(eV).cond(c).t', [nbCells, 1]); %nbCell * nbTimes
                                if eV < 3
                                    AllPatMat(eV).cond(c).resample_t(x1-1:x1+nbCells-2,:)       = repmat(psth_stats.event(eV).cond(c).resample.t', [nbCells, 1]); %nbCell * nbTimes
                                    AllPatMat(eV).cond(c).resample_rstats(x1-1:x1+nbCells-2,:)  = psth_stats.event(eV).cond(c).resample.rstats'; %nbCell * nbTimes
                                    AllPatMat(eV).cond(c).resample_rstats_bonf(x1-1:x1+nbCells-2,:)  = psth_stats.event(eV).cond(c).resample.rstats_bonf'; %nbCell * nbTimes
                                    
                                    for bsl_count = 1:nbBsl
                                        AllPatMat(eV).cond(c).Bsl(bsl_count).psth_fdr(x1-1:x1+nbCells-2,:,:)    = psth_stats.event(eV).cond(c).Bsl(bsl_count).fdrh'; %nbCell * nbTimes
                                        AllPatMat(eV).cond(c).Bsl(bsl_count).adj_p(x1-1:x1+nbCells-2,:,:)       = psth_stats.event(eV).cond(c).Bsl(bsl_count).adj_p'; %nbCell * nbTimes
                                        %AllPatMat(eV).cond(c).Bsl(bsl_count).psth_zscore(x1-1:x1+nbCells-2,:)   = squeeze(nanmean(psth_stats.event(eV).cond(c).Bsl(bsl_count).psth_zscore,2))';%nbCell * nbTimes
                                        AllPatMat(eV).cond(c).Bsl(bsl_count).psth_zscore(x1-1:x1+nbCells-2,:)   = psth_stats.event(eV).cond(c).Bsl(bsl_count).psth_zscore';%nbCell * nbTimes
                                        
                                        %stats per mWin
                                        clear Win_p
                                        for win_count = 1:numel(psth_stats.event(eV).cond(c).StatsWin)
                                            for cell_count = 1:nbCells %size(reps_win,3)
                                                mBsl = psth_stats.event(eV).cond(c).Bsl(bsl_count).mBsl(:,cell_count);
                                                mWin = psth_stats.event(eV).cond(c).StatsWin(win_count).mean(:,cell_count);
                                                [wp,wh,fdr_stats] = ranksum(mWin(isnan(mWin)==0), mBsl(isnan(mBsl)==0));
                                                Win_p(cell_count, win_count) = wp; %nbCell * nbWin
                                            end
                                        end
                                        AllPatMat(eV).cond(c).Bsl(bsl_count).StatsWin(x1-1:x1+nbCells-2,:) = num2cell(Win_p);
                                    end
                                end
                                clear r mBsl sdBsl
                            end
                        end
                    end
                    save(fullfile(DataDir, 'AllPatMat.mat'), 'AllPatMat')
                end
            end
        end
    end
end

