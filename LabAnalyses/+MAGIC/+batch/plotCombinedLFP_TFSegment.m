function plotCombinedLFP_TFSegment(segment, LFP_data, dataTF, outputDir, timeWindow, plotType, trialName, eventName)

    global segType

    % === Infos générales ===
    Fs     = segment.process{1}.Fs;
    med    = segment.info('trial').medication;
    cond   = segment.info('trial').condition;

    % Nettoyage noms
    plotTypeClean = upper(plotType);  % 'Raw' → 'RAW'
    medClean      = upper(med);       % 'on' → 'ON'
    trialName     = strrep(trialName, ' ', '_');  % on évite les espaces

    % Axe temporel LFP
    t_axis = linspace(timeWindow(1), timeWindow(2), size(LFP_data, 1));
    
    % Axe TF
    t_TF   = dataTF.spectralProcess.times{1} + dataTF.spectralProcess.tBlock / 2;
    f_axis = dataTF.spectralProcess.f;

    % 📁 Dossier de sauvegarde
    segmentDir = fullfile('Segments', plotTypeClean, medClean, trialName);
    targetDir  = fullfile(outputDir, segmentDir);
    if ~exist(targetDir, 'dir')
        mkdir(targetDir);
    end

    % 📉 Plot pour chaque canal
    nb_ch = size(LFP_data, 2);
    for ch = 1:nb_ch
        % LFP
        signal = LFP_data(:, ch);
        label  = segment.process{1}.labels(ch).name;

        % TF
        tf_vals = dataTF.spectralProcess.values{1}(:,:,ch)';
        if contains(plotType, 'Raw') || contains(plotType, 'dNOR')
            tf_vals = 10 * log10(tf_vals);
        end
        tf_vals = real(tf_vals);

        % 💡 Création de la figure (plus haute que large)
        fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [5 5 20 25]);

        % Subplot LFP
        ax1 = subplot(2,1,1);
        plot(ax1, t_axis, signal, 'b', 'LineWidth', 1.5);
        MAGIC.batch.plot_for_MAGIC(dataTF.eventProcess, 'handle', ax1, 'all', 999);
        xlabel(ax1, 'Time (s)');
        ylabel(ax1, 'Amplitude (AU)');
        title(ax1, ['LFP - ' label], 'Interpreter', 'none');
        xlim(ax1, [t_axis(1), t_axis(end)]);
        ylim(ax1, [-40 40]);
        grid(ax1, 'on');
        set(ax1, 'FontSize', 12);

        % Subplot TF
        ax2 = subplot(2,1,2);
        surf(ax2, t_TF, f_axis, tf_vals, 'EdgeColor', 'none');
        view(ax2, 0, 90);
        MAGIC.batch.plot_for_MAGIC(dataTF.eventProcess, 'handle', ax2, 'all', 999);
        xlabel(ax2, 'Time (s)');
        ylabel(ax2, 'Frequency (Hz)');
        title(ax2, ['TF - ' label], 'Interpreter', 'none');
        caxis(ax2, [-10 10]);
        set(ax2, 'FontSize', 12);
        axis(ax2, 'tight');

        % Ajouter un colorbar "propre"
        cb = colorbar(ax2);
        cb.Position = cb.Position + [0.03 0 0 0];  % Décalé légèrement à droite

        % Synchronisation des axes X
        linkaxes([ax1, ax2], 'x');

        % 🔽 Sauvegarde
        % Nettoyage nom du canal
        cleanLabel = regexprep(label, '[^\w\-]', '_');
        
        % Ajout du numéro de step si on est en mode 'step'
        if strcmp(segType, 'step')
            nStep = segment.info('trial').nStep;
            stepStr = ['_step_' num2str(nStep)];
        else
            stepStr = '';
        end
        
        % Numéro du trial
        trial_num = segment.info('trial').nTrial;
        trialStr  = ['_' sprintf('%02i', trial_num)];
        
        % Nom final
        figBaseName = ['TF_' eventName '_' plotTypeClean '_' medClean trialStr stepStr '_' cleanLabel];
        
        % Chemins finaux
        figFileName = fullfile(targetDir, [figBaseName '.png']);
        figFileNameFIG = strrep(figFileName, '.png', '.fig');
        
        % Sauvegarde
        saveas(fig, figFileName);
        saveas(fig, figFileNameFIG);
        close(fig);
    end

    disp(['✅ Combined LFP + TF segment saved: ' trialName ' (' plotType ')']);
end
