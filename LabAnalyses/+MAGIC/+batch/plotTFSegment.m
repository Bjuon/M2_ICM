function plotTFSegment(dataTF, FigDir, trialName, plotType)
% plotType = 'Raw' ou 'Cleaned'
% trialName = ex. 'Trial_1'

    global segType

    t_axis = dataTF.spectralProcess.times{1} + dataTF.spectralProcess.tBlock/2;
    f_axis = dataTF.spectralProcess.f;
    nb_ch  = numel(dataTF.spectralProcess.labels);
    med    = dataTF.info('trial').medication;

    % Dossier de sauvegarde
    med = dataTF.info('trial').medication;
    outputDir = fullfile(FigDir, plotType, med, trialName);
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end

    for ch = 1:nb_ch
        label = dataTF.spectralProcess.labels(ch).name;

        % Valeurs TF
        v = dataTF.spectralProcess.values{1}(:,:,ch)';
        if contains(plotType, 'Raw') || contains(plotType, 'dNOR')
            v = 10*log10(v);
        end
        v = real(v);

        % Création figure
        fig = figure('Visible', 'off', 'Units', 'centimeters', 'Position', [5 5 20 15]);
        surf(t_axis, f_axis, v, 'EdgeColor', 'none');
        view(0, 90);
        title([plotType ' - ' label ' - ' trialName ' - ' med], 'Interpreter', 'none');
        xlabel('Time (s)');
        ylabel('Frequency (Hz)');
        colorbar;
        caxis([-10 10])
        set(gca, 'FontSize', 12);
        axis tight;

        % Sauvegarde
        saveas(fig, fullfile(outputDir, ['Channel_' label '.png']));
        saveas(fig, fullfile(outputDir, ['Channel_' label '.fig']));
        close(fig);
    end

    disp(['✅ TF segment saved: ' trialName ' (' plotType ')']);

end
