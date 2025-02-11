% compare triggers in logfile and trigger channel

function triggers_check(RecID, files, OutputPath, ProjectPath, trig) %protocol,subject)

f = 1;

if strcmp(trig.labels.name, 'triggerMUA')
    % detect triggers from trigger channel
    trig_LFP = sig.detectEvents(trig.values{1}(:,1), 1/trig.Fs, ((max(trig.values{1}(:,1))-min(trig.values{1}(:,1)))/2) + min(trig.values{1}(:,1)),2, 0.01);
    %read log file
    [ ~, trig_log] = divine.load.read_log(fullfile(files(f).folder, files(f).name), RecID);
    FigName = files(f).name(1:end-8);
else
    thresh = 4;
    if strcmp(files(f).name, 'ParkPitie_2020_02_20_FEp_DIVINE_POSTOP_OFF_RGRASP_SIT_001_LFP.Poly5') || ...
            strcmp(files(f).name, 'ParkPitie_2020_02_20_FEp_DIVINE_POSTOP_OFF_VGRASP_SIT_001_LFP.Poly5') || ...
            strcmp(files(f).name, 'ParkPitie_2020_02_20_FEp_DIVINE_POSTOP_ON_VGRASP_SIT_001_LFP.Poly5')
        thresh = 68;
    elseif strcmp(files(f).name, 'TOCPitie_2019_12_19_MAs_DIVINE_POSTOP_OFF_RGRASP_SIT_001_LFP.Poly5') || ...
            strcmp(files(f).name, 'TOCPitie_2019_12_19_MAs_DIVINE_POSTOP_OFF_VGRASP_SIT_001_LFP.Poly5')
        thresh = 2;
    end
    % detect triggers from trigger channel
    trig_LFP = sig.detectEvents(trig.values{1}(:,1), 1/trig.Fs, thresh, 2, 1/trig.Fs); %max_dur = 2 au lieu de 1 pour LEn et SOd
    %read log file
    [ ~, trig_log] = divine.load.read_log(fullfile(files(f).folder, [files(f).name(1:end-9) 'LOG.csv']), RecID);
    FigName = strtok(files(f).name, '.');
end

% add exception if any to trig_LFP
[trig_LFP, maxDiffLim]  = divine.batch.triggers_exceptions(trig_LFP, trig_log, FigName); %strtok(files(f).name, '.'));

%check if number of triggers in logfiles and trigger channel is the
%same
fig = figure('Name', [FigName '_Trig'],'NumberTitle','off', 'units', 'centimeters', 'position', [5 5 29.7 21]);
subplot(2,2,1:2)
plot([trig_LFP(:,1) - trig_LFP(1,1)  trig_LFP(:,1) - trig_LFP(1,1)]', [zeros(size(trig_LFP,1),1) ones(size(trig_LFP,1),1)]', 'k')
hold on, plot([trig_log - trig_log(1)  trig_log - trig_log(1)]', [zeros(size(trig_log,1),1) ones(size(trig_log,1),1)]', 'r')
title([strrep(FigName, '_', '-') ' ' num2str(numel(trig_LFP(:,1))) ' ' num2str(numel(trig_log))])
xlabel('time (sec)')


if numel(trig_LFP(:,1)) ~= numel(trig_log) %triggers = trigger channel, t_trig = logfile
    warning('the number of triggers in the Poly5 differs from the number of triggers in the logfile')
    
    h = subplot(2,2,3:4);
    trig.plot('handle',h)
    title([strrep(FigName, '_', '-') ' trig.plot'])
    xlabel('time (sec)')

    saveas(fig, fullfile(ProjectPath, 'Triggers', ['BADnbTrig_' FigName '.fig']), 'fig')
    saveas(fig, fullfile(ProjectPath, 'Triggers', ['BADnbTrig_' FigName '.jpg']), 'jpg')
    close all
    return
    
else
    TrigDiff = (trig_LFP(:,1) - trig_LFP(1,1)) - ((trig_log - trig_log(1))); %trig channel - logfile
    maxDiff  = max(abs(diff(TrigDiff)));
    subplot(2,2,3)
%     plot(trig_LFP(:,1) - trig_LFP(1,1))
%     hold on, plot((trig_log - trig_log(1))/1000)
    plot(TrigDiff)
    title(['maxDiff = ' num2str(maxDiff)])
    xlabel('push buttons')
    ylabel('duration (sec)')
    
    subplot(2,2,4)
    hist(diff(TrigDiff),100)
    title('diff(trig channel - logfile)')
    xlabel('duration (sec)')
    ylabel('nb PB')
    
    
    %check time difference between triggers logfiles and trigger channel
    if maxDiff > maxDiffLim
        if ~isempty(strfind(files(f).name, 'RGRASP')) && isempty(strfind(files(f).name, 'TOCPitie_2019_12_19_MAs'))
            h = subplot(2,2,3:4);
            trig.plot('handle',h)
            title([strrep(FigName, '_', '-') ' trig.plot'])
            xlabel('time (sec)')
        else
            warning('timing of triggers in the Poly5 differs from the timing of triggers in the logfile')
            saveas(fig, fullfile(ProjectPath, 'Triggers', ['BADmaxDiff_' FigName '.fig']), 'fig')
            saveas(fig, fullfile(ProjectPath, 'Triggers', ['BADmaxDiff_' FigName '.jpg']), 'jpg')
        end
    end
    
end

%in any case, save fig in patient dir
saveas(fig, fullfile(OutputPath, [FigName '_Trig.jpg']), 'jpg')
saveas(fig, fullfile(ProjectPath, 'Triggers', [FigName '_Trig.jpg']), 'jpg')
close all



end
