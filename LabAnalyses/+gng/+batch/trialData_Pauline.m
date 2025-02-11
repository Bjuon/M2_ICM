clear all
close all

todo.createMatfile  = 1;
todo.figures        = 1;

patientID = {'SALJe'}; %{'MERPh' 'ARDSy' 'LAUTh' 'RAYTh' 'NGUPh' 'ETIAl' 'SALJe' 'RIMLa' 'WARJe' ' DISPi' 'HUSXa' 'MAJAf'}; %list of patients to analyze
DataDir = 'C:\Users\marion.albares\Desktop\Marion_tâche GoNoGo\datas patients\Park_DBS'; %path where patienstr' data are stored
PerOpDir = '2_PerOp'; %Directory name for MUA data
xlsFname = 'Plexon_global_results_MARION_'; %global excel file name
% 
% addpath(genpath('F:\IR-IHU-ICM\Donnees\git_for_github\LabAnalyses'))
% addpath(genpath('F:\IR-IHU-ICM\Donnees\Scripts\DBS\OmniPlex and MAP Offline SDK Bundle\Plexon Offline SDKs\Matlab Offline Files SDK'))

import spk.*
import fig.*

%define colors:
Col = get(0,'DefaultAxesColorOrder');

for p = 1:numel(patientID)
    patientDir = dir(fullfile(DataDir, ['*' patientID{p}]));
    fullPath = fullfile(DataDir, patientDir.name, PerOpDir);
    cd(fullPath) 
    
    fname = [xlsFname patientID{p} '.xlsx'];
    
    %read xls file
    [N,~,T] = xlsread(fname,1);
    n = size(T,1);
    for j = 2:n
        if ~any(isnan(T{j,2})) && ~any(isnan(T{j,5})) && strncmp(T{j,5},'GBMOV',5)
            plxName = T{j,2};
            xlsName = T{j,5};
            count = 1;
            ind = 13;
            while 1
                try
                    if isnan(T{j,ind});
                        break;
                    end
                catch
                    break;
                end
                spkName{count} = T{j,ind};
                start_t(count) = T{j,ind + 2};
                end_t(count) = T{j,ind + 3};
                count = count + 1;
                ind = ind + 5;
            end
            
             % LFP name
            [n,names] = plx_adchan_names(plxName);
            for i=1:n
                names_conc{i}= names(i,:);
            end
            
            indLfp= strfind(names_conc, 'Lfp');
            ind = find(~cellfun(@isempty,indLfp));
            LfpName = names_conc(ind);
            
            clear ind indLfp;
            
            %generate outputFile name
            plxName_parts = strsplit(plxName,'_');
            BrainStruct = plxName_parts{2};
            if ~isempty(strfind(BrainStruct, 'Left'))
                BrainStruct = [strtok(BrainStruct), '_L'];
            elseif ~isempty(strfind(BrainStruct, 'Right'))
                BrainStruct = [strtok(BrainStruct), '_R'];
            end
            Section = strrep(plxName_parts{end-1}(strfind(plxName_parts{end-1}, 'sec'): end), ' ', '');
            Depth = plxName_parts{end}(1:end-7);
            
            OutputFileName = [patientID{p} '_' BrainStruct '_' Section '_' Depth];
            
            if todo.createMatfile
                [data,valid] = gng.load.trialData(xlsName,plxName,spkName,LfpName,start_t,end_t);
                save([OutputFileName '.mat'],'data','valid');
                clear spkName start_t end_t;
            end
            
            % create figures
            if todo.figures
                if todo.createMatfile == 0
                    %load Matfile
                    load([OutputFileName '.mat'])
                end
                
                if ~exist('figures', 'dir')
                    mkdir figures
                end
                
                
                %add plot of mean spiking rate per trial accross all
                %conditions, sync sur ITI?
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
                end
                
                
                % create spike rate plot accross all segments per cell
                clear r t labels times nbTrial IdxCell;
                count = 1;
                nbTrial = zeros(1, numel(AllCellNames));
                for i = 1:numel(temp)
                    if ~iscell(temp(i).pointProcess)
                        labels{count,:} = {temp(i).pointProcess.labels.name};
                        for l = 1:size(labels{count,:},2)
                            IdxCell = find(cellfun('isempty', strfind(AllCellNames, labels{count}{l})) == 0);
                            times(i,IdxCell) = temp(i).pointProcess.times(l);
                            nbTrial(IdxCell) = nbTrial(IdxCell) + 1;
                        end
                        count = count + 1;
                    end
                end
                
                NbSpike = cellfun(@length, times); 
                TrialDur = cell2mat(arrayfun(@(x) x.window, [temp.pointProcess], 'uni',0)');
                SpikeRate = NbSpike ./repmat(TrialDur(:,2)-TrialDur(:,1), [1 size(NbSpike,2)]);
                %faire le raster plot et l'associï¿½ au spike rate par essai
                                              
                % create psth and rater plot by event type
                key = 'Trial';
                eventValue = {'CueOnSet', 'Reaction'}; % 'ITI'; 'PFix'; 'CueOnSet'; 'Reaction'
                TimeWindows = {[-2.5 1.5], [-3 1]};
                conditions = {'GoControl', 'GoMixte', 'NoGoMixte'};
               
                for eV = 1:numel(eventValue)
                    FigName = [OutputFileName '_' eventValue{eV}];
                    figure('Name', FigName,'NumberTitle','off');

                    for c = 1:numel(conditions)
                        conditionName = conditions{c};
                        clear q temp
                        q = linq(data);
                        temp = q.where(@(x) isKey(x.info,key)); 
                        switch conditionName
                            case 'GoControl'
                                temp = q.where(@(x) strcmp(x.info(key).('trial'),'Go'));
                                if temp.count == 0
                                    display ('No segment with GoControl')
                                    continue
                                else
                                    temp = q.where(@(x) x.info(key).isControl)...
                                        .where(@(x) x.info(key).isCorrect)...
                                        .toArray();
                                end
                            case 'GoMixte'
                                temp = q.where(@(x) strcmp(x.info(key).('trial'),'Go'));
                                if temp.count == 0
                                    display ('No segment with GoMixte')
                                    continue
                                else
                                    temp = q.where(@(x) x.info(key).isControl == 0)...
                                        .where(@(x) x.info(key).isCorrect)...
                                        .toArray();
                                end
                            case 'NoGoMixte'
                                temp = q.where(@(x) strcmp(x.info(key).('trial'),'NoGo'));
                                if temp.count == 0
                                    display ('No segment with NoGoMixte')
                                    continue
                                else
                                    temp = q.where(@(x) x.info(key).isCorrect)...
                                        .toArray();
                                end
                        end
                        
                        temp.sync('eventProp','name','eventVal',eventValue{eV},'window',[-3 3]);
                        q = linq(temp);
                        
                        %keep only valid sync
                        temp = q.where(@(x) strcmp(x.validSync.name,'NULL') == 0).toArray();
                        q = linq(temp);
                        
                        if ~isempty(temp)
                            %get names of all neurones recorded
                            temp2 = q.where(@(x) ~iscell(x.pointProcess)==1).toArray();
                            CellNames = arrayfun(@(x) {x.labels.name}, [temp2.pointProcess], 'uni',0);
                            CellNames = unique(cat(2,CellNames{:})); clear temp2                      
                                                        
                            clear r t labels times nbTrial IdxCell;
                            count = 1;
                            nbTrial = zeros(1, numel(CellNames));
                            for i = 1:numel(temp)
                                if ~iscell(temp(i).pointProcess)
                                    labels{count,:} = {temp(i).pointProcess.labels.name};
                                    for l = 1:size(labels{count,:},2)
                                        IdxCell = find(cellfun('isempty', strfind(CellNames, labels{count}{l})) == 0);
                                        times(i,IdxCell) = temp(i).pointProcess.times(l);
                                        nbTrial(IdxCell) = nbTrial(IdxCell) + 1;
                                    end
                                    count = count + 1;
                                end
                            end
       
                            %create and save figure
                            %get color of active cells during event
                            IdxCell = 1; clear Tmp_col IdxCell
                            for i = 1:numel(CellNames)
                                IdxCell = find(cellfun('isempty', strfind(AllCellNames, CellNames{i})) == 0);
                                Tmp_col{i} = CellColors{IdxCell};
                            end
                            
                            %raster plot
                            h = subplot(2,3,c);
                            plotRaster(times,'window',TimeWindows{eV}, 'grpColor',Tmp_col, 'handle',h);% 
                            %add linee at 0
                            plot([0 0], get(gca,'ylim'), 'k')
                            if c == 2, title(strrep(FigName, '_', ' ')), end
                            
                            %PSTH
                            [r,t,~,~] = getPsth(times,0.05);
                            nbTrial = repmat(nbTrial, [size(r,1) 1]);
                            subplot(2,3,c+3)                           
                            %plot(t,r./nbTrial); xlim(TimeWindows{eV}), hold on
                            rtest = r./repmat(max(r), [size(r,1) 1]) + repmat(0:(size(r,2)-1), [size(r,1) 1]); 
                            for i = 1:size(rtest,2)
                                plot(t,rtest(:,i),'color', Tmp_col{i}); xlim(TimeWindows{eV}), hold on
                            end
                            plot([0 0], get(gca,'ylim'), 'k'), hold off
                            title(conditions{c})
                            ylabel('spiking rate')
                        else
                            display('No Valid Sync')
                        end
                    end
                    legend(AllCellNames, 'position', [0  0.1 0.03 0.05])
                    saveas(gcf, ['figures/' FigName '.fig'], 'fig')
                    saveas(gcf, ['figures/' FigName '.jpg'], 'jpg')
                    close all
                end
            end
        end
    end   
end
