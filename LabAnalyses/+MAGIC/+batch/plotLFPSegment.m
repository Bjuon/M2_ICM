function plotLFPSegment(segment, LFP_data, file, outputDir, timeWindow, plotType, trialName)

    global med run
    med = file.med;

    % ✅ Données déjà synchronisées
    data = segment.process{1}; % Le SampledProcess
    Fs = data.Fs;
    med = segment.info('trial').medication;
    cond = segment.info('trial').condition;

    % 🔍 Détection de l’événement principal
    main_event = 'UnknownEvent';
    events = [];
    try
        if numel(segment.process) >= 3
            events = segment.process{3}.events;
            ev_names = arrayfun(@(e) e.name.name, events, 'UniformOutput', false);
            priority = {'FO1', 'FC1', 'FO', 'FC', 'CUE', 'FIX'};
            for ev = priority
                if any(strcmp(ev_names, ev{1}))
                    main_event = ev{1};
                    break;
                end
            end
        end
    end

    % Axe temporel synchronisé
    total_duration = size(LFP_data, 1) / Fs;
    t_axis = linspace(timeWindow(1), timeWindow(2), size(LFP_data, 1));

    % 📁 Dossier de sortie
    targetDir = fullfile(outputDir, plotType, cond, main_event, med, trialName);
    if ~exist(targetDir, 'dir')
        mkdir(targetDir);
    end

    % 📉 Tracer les canaux synchronisés
    num_channels = size(LFP_data, 2);
    for ch = 1:num_channels
        fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [5 5 20 15]);
        hold on;
        title([plotType, ' LFP (synchro TF) - ', data.labels(ch).name, ' - ', trialName, ' - ', med, ' - ' cond], 'Interpreter', 'none');
        xlabel('Temps (s)');
        ylabel('Amplitude LFP (AU)');
        plot(t_axis, LFP_data(:, ch), 'b', 'LineWidth', 1.5);
        ylim([-20 20]);
        xlim([t_axis(1), t_axis(end)]);
        grid on;
        set(gca, 'FontSize', 12);

        cleanLabel = regexprep(data.labels(ch).name, '[^\w\-]', '_');
        figFileName = fullfile(targetDir, [cleanLabel '.png']);
        saveas(fig, figFileName);
        saveas(fig, strrep(figFileName, '.png', '.fig'));
        close(fig);
    end

    disp(['✅ Segment LFP (synchro TF: ' main_event ') enregistré : ', trialName, ' (', plotType, ')']);
end
