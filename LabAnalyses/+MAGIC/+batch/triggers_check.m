% compare triggers in logfile and trigger channel

function triggers_check(RecID, files, OutputPath, ProjectPath, trig, MatPfOutput, LogDir) %protocol,subject)

global max_dur

f = 1;

%% detect triggers from trigger channel
if strcmp(files.name, 'ParkPitie_2020_02_20_FEp_MAGIC_POSTOP_ON_GNG_GAIT_001_LFP.Poly5')
    trig_LFP = sig.detectEvents(trig.values{1}(:,1), 1/trig.Fs, 67, max_dur, 1/trig.Fs); % ou 69
    %trig_LFP = trig_LFP(trig.values{1}(trig_LFP(:,2)*trig.Fs) < 20,:);
elseif strcmp(RecID, 'ParkRouen_2021_10_04_FRa')
    trig_LFP = sig.detectEvents(trig.values{1}(:,1), 1/trig.Fs, 0.5, max_dur, 1/trig.Fs);
else
    trig_LFP = sig.detectEvents(trig.values{1}(:,1), 1/trig.Fs, 4, max_dur, 1/trig.Fs); %max_dur = 2 au lieu de 1 pour LEn et SOd
    trig_LFP = trig_LFP(trig.values{1}(trig_LFP(:,2)*trig.Fs) < 20,:);
end
%read log file
[ ~, trig_log] = MAGIC.load.read_log(files(f).name, LogDir, RecID);

FigName = strtok(files(f).name, '.');

%% Get theorical triggers

SubjectName = RecID(end-2:end)           ;
CondMed     = files.name(end-24:end-23)  ;
StartTime   = [];
        if CondMed == 'FF' ; CondMed = 'OFF' ; end
for i = 1:length(MatPfOutput.Sujet)
    if ~any([~strcmp(SubjectName, MatPfOutput.Sujet(i)) , ~strcmp(CondMed, MatPfOutput.Condition(i))])
        StartTime(end+1) = MatPfOutput.StartTime(i);
    end
end
if isempty(StartTime)
    Patient_included_in_output_file = false ;
else
    StartTime = (StartTime - StartTime(1))/1000;
    Patient_included_in_output_file = true ;
end

           

% add exception if any to trig_LFP
[trig_LFP, maxDiffLim]  = MAGIC.load.triggers_exceptions(trig_LFP, trig_log, FigName); %strtok(files(f).name, '.'));

%% Add colors to count tens rapidly
StartTime10 = [] ; 
trig_LFP10  = [] ;
for i = 1:5
    if 10*i < numel(trig_LFP(:,1))
        trig_LFP10(end+1) = trig_LFP(i*10,1) - trig_LFP(1,1);
    end
    if Patient_included_in_output_file && 10*i < numel(StartTime)
        StartTime10(end+1) = StartTime(i*10);
    end
end

%% Colorize only if different
StartTimeDiff = [] ; 
trig_LFPDiff  = [] ;
if Patient_included_in_output_file
    for i = 1:length(StartTime)
        pass = false ; 
        for j = 1:numel(trig_LFP(:,1))
            if abs(trig_LFP(j,1)-trig_LFP(1,1)-StartTime(i)) < 2
                pass = true ;
            end
        end
        if ~pass
            StartTimeDiff(end+1) = StartTime(i);
        end
    end
    
    for i = 1:numel(trig_LFP(:,1))
        pass = false ; 
        for j = 1:length(StartTime)
            if abs(trig_LFP(i,1)-trig_LFP(1,1)-StartTime(j)) < 2
                pass = true ;
            end
        end
        if ~pass
            trig_LFPDiff(end+1) = trig_LFP(i) - trig_LFP(1,1);
        end
    end
end


%% Plotting


fig = figure('Name', [FigName '_Trig'],'NumberTitle','off', 'units', 'centimeters', 'position', [5 5 29.7 21]);
subplot(3,2,1:2)
         plot([trig_LFP(:,1) - trig_LFP(1,1)  trig_LFP(:,1) - trig_LFP(1,1)]', [zeros(size(trig_LFP,1),1)+1      ones(size(trig_LFP,1),1)+1]'        , 'color', [0.2 0 0  ])
if Patient_included_in_output_file
hold on, plot([StartTime(:)  StartTime(:)]',                                   [zeros(length(StartTime),1)       ones(length(StartTime),1)]'         , 'color', [0   0 0.2])
hold on, plot([StartTimeDiff(:)  StartTimeDiff(:)]',                           [zeros(length(StartTimeDiff),1)   ones(length(StartTimeDiff),1)]'     , 'b')
hold on, plot([StartTime10(:)  StartTime10(:)]',                               [zeros(length(StartTime10),1)     ones(length(StartTime10),1)*.5]'    , 'm')
hold on, plot([trig_LFPDiff(:)   trig_LFPDiff(:)]' ,                           [ones(length(trig_LFPDiff),1)     ones(length(trig_LFPDiff),1)+1]'    , 'r')
end
hold on, plot([trig_LFP10(:)  trig_LFP10(:)]',                                 [zeros(length(trig_LFP10),1)+1.5  ones(length(trig_LFP10),1)*.5+1.5]' , 'g')
title([strrep(FigName, '_', '-') '// Detected : ' num2str(numel(trig_LFP(:,1))) ' in LFP out of ' num2str(numel(trig_log)) ' in Vicon (' num2str(numel(StartTime)) ' in output.mat)' ])
if Patient_included_in_output_file
    axis([-30 max(trig_LFP(end,1),StartTime(end))+30 0 2])
else
    axis([-30 max(trig_LFP(end,1)               )+30 0 2])
end
xlabel('time (sec)')

if Patient_included_in_output_file
    subplot(3,2,3:4)
    histogram(StartTime, 120 ,'FaceColor','c')
    title([strrep(FigName, '_', '-') ' Theorical trigger repartition & Doublon identifier'])
    axis([-30 max(trig_LFP(end,1),StartTime(end))+30 0 inf])
    xlabel('time (sec)')
end

if numel(trig_LFP(:,1)) ~= numel(trig_log) %triggers = trigger channel, t_trig = logfile
    if strcmp(CondMed,'ON') ; CondMed2 = 'ON ' ; else CondMed2 = CondMed ; end
    fprintf(2,[SubjectName ' ' CondMed2 ': the number of triggers in the Poly5 differs from the number of triggers in the logfile \n'])
    
    h = subplot(3,2,5:6);
    trig.plot('handle',h)
    title([strrep(FigName, '_', '-') ' trig.plot'])
    xlabel('time (sec)')

    saveas(fig, fullfile(ProjectPath, [ FigName '_BADnbTrig.fig']), 'fig')
    saveas(fig, fullfile(ProjectPath, [ FigName '_BADnbTrig.jpg']), 'jpg')

    uicontrol('String','OK','Callback','close all');
    uiwait(fig)
    close all
    return
    
else
    
    if Patient_included_in_output_file && length(trig_LFP) == length(StartTime)
    
        TrigDiff = (trig_LFP(:,1) - trig_LFP(1,1)) - (StartTime(:)); %trig channel - logfile
        maxDiff  = max(abs(diff(TrigDiff)));
        subplot(3,2,5)
    %     plot(trig_LFP(:,1) - trig_LFP(1,1))
    %     hold on, plot((trig_log - trig_log(1))/1000)
        plot(TrigDiff)
        title(['maxDiff = ' num2str(maxDiff)])
        xlabel('push buttons')
        ylabel('duration (sec)')
        
        subplot(3,2,6)
        hist(diff(TrigDiff),100)
        title('diff(trig channel - logfile)')
        xlabel('duration (sec)')
        ylabel('nb PB')
        
        
        %check time difference between triggers logfiles and trigger channel
        if maxDiff > maxDiffLim
            if strcmp(CondMed,'ON') ; CondMed2 = 'ON ' ; else CondMed2 = CondMed ; end
            fprintf(2,[SubjectName ' ' CondMed2 ': timing of triggers in the Poly5 differs from the timing of triggers in the output file \n'])
            
            saveas(fig, fullfile(ProjectPath, [ FigName '_HighTimeShift.fig']), 'fig')
            saveas(fig, fullfile(ProjectPath, [ FigName '_HighTimeShift.jpg']), 'jpg')
        end
    else
        disp("Number in output.mat different, so no histogram")
    end
end

%in any case, save fig in patient dir
saveas(fig, fullfile(OutputPath , [FigName '_Trig.jpg']), 'jpg')
saveas(fig, fullfile(ProjectPath, [FigName '_Trig.jpg']), 'jpg')

uicontrol('String','OK','Callback','close all');
uiwait(fig)

close all



end
