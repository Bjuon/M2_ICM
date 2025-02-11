% filtrer la puissance des freq pour ne prendre que les oscillation lentes
% filter EMG entre 1 et 90 Hz
% lire Mike X cohen : https://mikexcohen.com/lectures.html

% papier Be
% https://www.researchgate.net/profile/Jose-Naranjo-Muradas/publication/24442352_Beta-Range_EEG-EMG_Coherence_With_Isometric_Compensation_for_Increasing_Modulated_Low-Level_Forces/links/0fcfd50dd8874779ca000000/Beta-Range-EEG-EMG-Coherence-With-Isometric-Compensation-for-Increasing-Modulated-Low-Level-Forces.pdf?origin=publication_detail

% how to write a lot : Paul Silvia

%%%% esssayer correlation entre puissance TF et enveloppe EMG
% %%%% calcluer LAG entre
% clear all
% RectEMG = 1;
% CO_meth = {'JNcoh'}; %{'coh', 'wcoh', 'corr', 'xcorr'}; %'FTcoh',
% ft_defaults
% addpath('D:\01_IR-ICM\donnees\git_for_github\fieldtrip\utilities')
% %%

function LFP_EMG_coherence_stats(OutputFileName, dataCO, dataCO_BSL, seg_EMG, FigDir)
Col = get(0,'DefaultAxesColorOrder');

thresh = {'tstat', 'p05', 'p001'};

[~, filename] = fileparts(OutputFileName);

% keep only seg with APA
T0      = cell2mat(linq(seg_EMG).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'T0_EMG')).tStart).toList)';
seg_EMG = seg_EMG(~isnan(T0));
% keep only seg starting with right foot
isR     = cell2mat(linq(seg_EMG).select(@(x) x.info('trial').side == 'R').toList)';
seg_EMG = seg_EMG(isR);


% prepare EMG
seg_EMG.sync('func',@(x) strcmp(x.name.name, 'T0_EMG'), 'window', [-1 2]);
EMG_all = [seg_EMG.sampledProcess];
idx_EMG_OFF = strcmp(arrayfun(@(x) x.info('trial').medication, seg_EMG, 'uni', 0), 'OFF');
idx_EMG_ON  = strcmp(arrayfun(@(x) x.info('trial').medication, seg_EMG, 'uni', 0), 'ON');
makeTimeCompatible(EMG_all);
[s, l1] = extract(EMG_all);
s1_emg = squeeze(cat(4,s.values)); %times * Ch * trials
t1_EMG = EMG_all(1).times{1};
% fs = EMG_all(1).Fs;
% s1_OFF_med = median(s1(:,:,idx_EMG_OFF), 3); %times * Ch
% s1_ON_med  = median(s1(:,:,idx_EMG_ON), 3); %times * Ch

% extract event timings
TO  = cell2mat(linq(seg_EMG).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'T0_EMG')).tStart).toList)';
FO1 = cell2mat(linq(seg_EMG).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'FO1')).tStart).toList)';
FC1 = cell2mat(linq(seg_EMG).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'FC1')).tStart).toList)';


% Extract data
CO     = [dataCO.dataCO.spectralProcess];
CO_BSL = [dataCO_BSL.dataCO.spectralProcess];
trials = arrayfun(@(x) x.info('trial').nTrial, dataCO.dataCO);

% Bsl.ntrial     = arrayfun(@(x) x.info('trial').nTrial, dataCO_BSL.dataCO, 'uni', 0)';
% Bsl.med        = arrayfun(@(x) x.info('trial').medication, dataCO_BSL.dataCO, 'uni', 0)';
% 
% 
% for t = 1:numel(trials)
%     med    = dataCO.dataCO(t).info('trial').medication;
%     nTrial = dataCO.dataCO(t).info('trial').nTrial;
%     idx_t  = find((strcmp(Bsl.med, med) & [Bsl.ntrial{:}]' == nTrial) == 1);
%     if isempty(idx_t)
%         error ('idx_t is empty')
%     end
%     bslTFadd(t) = CO_BSL(idx_t);
% end

% CO 
[s_co, l1] = extract(CO);
s1_co = squeeze(cat(4,s_co.values)); %time x freq x ch x seg
t1_co = CO(1).times{1};
fs_co = CO(1).Fs;
freq1_co = CO(1).f;

% CO_BSL
[s_co_bsl, l1] = extract(CO_BSL);
s1_co_bsl = squeeze(cat(4,s_co_bsl.values)); %time x freq x ch x seg
s1_co_bsl = repmat(nanmedian(s1_co_bsl,1), [size(s1_co,1),1,1,1] );
t1_co_bsl = CO_BSL(1).times{1};
fs_co_bsl = CO_BSL(1).Fs;
freq1_co_bsl = CO_BSL(1).f;

% labels
lab_name = arrayfun(@(x) strsplit(x.name, '_'), CO(1).labels, 'UniformOutput', false)';
lab_name = cat(1,lab_name{:});
lfp_channels   = unique(lab_name(:,1));
emg_channels   = unique(lab_name(:,2));

% medication
clear idx_med
idx_med.OFF = strcmp(arrayfun(@(x) x.info('trial').medication, dataCO.dataCO, 'uni', 0), 'OFF');
idx_med.ON  = strcmp(arrayfun(@(x) x.info('trial').medication, dataCO.dataCO, 'uni', 0), 'ON');


clear v_EMG_ch
for EMG_ch = 1 : numel(emg_channels)
    EMG_FigName   = [filename '_' emg_channels{EMG_ch}];
    for th = 1 : numel(thresh)
        EMG_fig.(thresh{th}) = figure('Name', [EMG_FigName '_' thresh{th}] ,'NumberTitle','off', 'units', 'centimeters', 'position', [5 5 29.7 21]);
    end
     
    % get emg ch idx
    idx_ch_emg = strcmp({EMG_all(1).labels.name}, emg_channels{EMG_ch});
    v_EMG_ch = squeeze(s1_emg(:,idx_ch_emg,:)); % time x seg
    clear v_EMG_ch_env
    for t = 1 : size(v_EMG_ch,2)
        
        if contains(filename, 'SOd')
            idx_nonan = find(~isnan(v_EMG_ch(:,t)), 1, 'first');
            %         emg.trial{n}(:,1:idx_nonan-1) = repmat(emg.trial{n}(:,idx_nonan), [1,idx_nonan-1]);
            v_EMG_ch(1:idx_nonan-1, t) = v_EMG_ch(idx_nonan,t).*rand(idx_nonan-1,1);
        end
        v_EMG_ch(isnan(v_EMG_ch(:,t)),t) = 0;
        %v_EMG_ch_env(:,t) = envelope(abs(v_EMG_ch(:,t)),10,'peak');
        v_EMG_ch_env(:,t) = envelope(abs(v_EMG_ch(:,t)),5,'peak');
    end
    
    % ON / OFF
    for med = {'OFF', 'ON'}
        % plot mean EMG
        
        idx_trial = idx_med.(med{:});
        if strcmp(med,'OFF')
            idx_plot  = 0;
            %                 idx_trial = idx_ON;
        elseif strcmp(med,'ON')
            idx_plot = 2;
            %                 idx_trial = idx_OFF;
        end
        idx_plot_emg = idx_plot;
        for side = {'L', 'R'}
            idx_plot_emg = idx_plot_emg + 1;
            for th = 1 : numel(thresh)
                figure(EMG_fig.(thresh{th}))
                % plot EMG
                subplot(numel(lfp_channels)/2+1, 4, idx_plot_emg)
                plot(t1_EMG, median(v_EMG_ch_env(:,idx_trial),2), 'linewidth',2), hold on
                title([med{:} ' ' emg_channels{EMG_ch}])
                xlim([-0.7 1])
                %ajouter T0 + FO1 + FC1
                yl = ylim;
                % TO
                plot([median(TO(idx_trial)) median(TO(idx_trial))], yl, 'k')
                % FO1
                plot([median(FO1(idx_trial)) median(FO1(idx_trial))], yl, 'k')
                % FC1
                plot([median(FC1(idx_trial)) median(FC1(idx_trial))], yl, 'k')
            end
        end
                
        idx_plot_L = idx_plot+1 + [(numel(lfp_channels)/2)*4:-4:4];
        idx_plot_R = idx_plot+2 + [(numel(lfp_channels)/2)*4:-4:4];
        idx_L_count = 0;
        idx_R_count = 0;
        for lfp_ch = 1 : numel(lfp_channels)
            idx_coh = strcmp(lab_name(:,2), emg_channels{EMG_ch}) & strcmp(lab_name(:,1), lfp_channels{lfp_ch});
            % stats
            [~,CO_p,~,CO_stats] = ttest(squeeze(s1_co(:,:,idx_coh, idx_trial)), squeeze(s1_co_bsl(:,:,idx_coh, idx_trial)),'dim',3);
            CO_stats.p05  = CO_stats.tstat .* (CO_p < 0.05);
            CO_stats.p001 = CO_stats.tstat .* (CO_p < 0.001);
            if contains(lfp_channels{lfp_ch}, 'G')
                idx_L_count = idx_L_count + 1;
                idx_subplot = idx_plot_L(idx_L_count);
            elseif contains(lfp_channels{lfp_ch}, 'D')
                idx_R_count = idx_R_count + 1;
                idx_subplot = idx_plot_R(idx_R_count);
            end
            
            
            for th = 1 : numel(thresh)
                figure(EMG_fig.(thresh{th}))
                g =subplot(numel(lfp_channels)/2+1, 4, idx_subplot);
                                
                surf(t1_co, freq1_co, CO_stats.(thresh{th})', 'edgecolor', 'none', 'parent', g);
                view(g,0,90); hold on
                %contour(t1_co, freq1_co, CO_p'<0.05, 1,'k')
                %contour(t1_co, freq1_co, CO_p'<0.001, 1,'r')
                yl = ylim;
                xlim([-0.7 1])
                %ylim([0 40])
                caxis([-5 5])
                plot([0 0], yl, 'k')
                title(lfp_channels{lfp_ch})
                colormap('jet')
            end
        end
    end
    for th = 1 : numel(thresh)
        figure(EMG_fig.(thresh{th}))
        annotation('textbox', [0.22, 0.98, 0.9, 0], 'edgecolor', 'none', 'string', ...
        strrep([EMG_FigName  '_' thresh{th}], '_', '-'))
        saveas(EMG_fig.(thresh{th}), fullfile(FigDir, [EMG_FigName  '_' thresh{th} '.jpg']), 'jpg')
    end
end
close('all')


