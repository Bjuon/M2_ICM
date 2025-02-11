function plot_psd(data, file, OutputPath)

%get step rate
if contains(file.name, 'GI_SPON')
    GI_trials =  GI.load.read_log(fullfile(file.folder, [file.name(1:end-9) 'LOG.csv']), '');
    clear step_rate
    for t = 1 : size(GI_trials,1)
        step_rate(t,1) = 1/median(diff([GI_trials.step_FO{t,:}]));
    end
    step_rate = median(step_rate);
else   
    step_rate = NaN;
end


% psd until 5, no log transform
data_psd = data.psd('method','welch','f',0:.01:5);
fig = figure('Name', [file.name(1:end-6) '_psd_5.jpg'],'NumberTitle','off', 'units', 'centimeters', 'position', [5 5 29.7 21]);
plot(data_psd, 'handle', fig, 'title', 1, 'log', 0)
annotation('textbox', [0.3, 0.97, 0.9, 0], 'edgecolor', 'none', 'string', ...
    strrep([file.name(1:end-6) ' step rate = ' num2str(round(step_rate, 2)) ' Hz'], '_', '-'))
saveas(fig, fullfile(OutputPath, [file.name(1:end-6) '_psd_5.jpg']), 'jpg')

% psd until 100,  log transform
data_psd = data.psd('method','welch','f',0:.05:100);
fig = figure('Name', [file.name(1:end-6) '_psd_100log.jpg'],'NumberTitle','off', 'units', 'centimeters', 'position', [5 5 29.7 21]);
plot(data_psd, 'handle', fig, 'title', 1, 'log', 1)
annotation('textbox', [0.3, 0.97, 0.9, 0], 'edgecolor', 'none', 'string', strrep([file.name(1:end-6) ' step rate = ' num2str(round(step_rate, 2)) ' Hz'], '_', '-'))
saveas(fig, fullfile(OutputPath, [file.name(1:end-6) '_psd_100log.jpg']), 'jpg')

% psd until 5,  log transform
data_psd = data.psd('method','welch','f',0:.01:5);
fig = figure('Name', [file.name(1:end-6) '_psd_5log.jpg'],'NumberTitle','off', 'units', 'centimeters', 'position', [5 5 29.7 21]);
plot(data_psd, 'handle', fig, 'title', 1, 'log', 1)
annotation('textbox', [0.3, 0.97, 0.9, 0], 'edgecolor', 'none', 'string', strrep([file.name(1:end-6) ' step rate = ' num2str(round(step_rate, 2)) ' Hz'], '_', '-'))
saveas(fig, fullfile(OutputPath, [file.name(1:end-6) '_psd_5log.jpg']), 'jpg')


close all




