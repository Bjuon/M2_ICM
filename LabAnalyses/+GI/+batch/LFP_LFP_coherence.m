%%%% esssayer correlation entre puissance TF et enveloppe EMG
%%%% calcluer LAG entre 
clear all 
CO_meth = {'coh', 'plv'}; %{'wcoh', 'corr', 'xcorr'}; %'ft_coh', 
ft_defaults
addpath('F:\IR-IHU-ICM\Donnees\git_for_github\fieldtrip\utilities')
%% 
%function LFP_EMG_coherence

%global RectEMG

filename = 'PPNPitie_2018_07_05_AVl_GAITPARK_POSTOP_GI_SPON';

% load LFP create ft structure
load('F:\IR-IHU-ICM\Donnees\Analyses\DBS\DBStmp_Matthieu\data\analyses\AVl_0444\PPNPitie_2018_07_05_AVl\POSTOP\PPNPitie_2018_07_05_AVl_GAITPARK_POSTOP_GI_SPON_LFP_trial.mat')

e = 'T0';
SyncWin = [-1 2];

% sync to event
seg.reset;
seg.sync('func',@(x) strcmp(x.name.name, e), 'window', SyncWin);

% create ft structure with all trials
clear lfp 
%lfp.sampleinfo = [];
lfp.label      = {seg(1).sampledProcess.labels.name}';
lfp.fsample    = seg(1).sampledProcess.Fs;

for n = 1:numel(seg)
    lfp.trial(n)    = {seg(n).sampledProcess.values{1}'}; % nb channels x nb times 
    lfp.time(n)     = {seg(n).sampledProcess.times{1}'}; % 1 x nb times
end

% reduce to -0.5 -  1 for ft_coh
cfg         = [];
cfg.latency = [-0.5 1];
lfp     = ft_selectdata(cfg,lfp);

% get events
EVTs  = [seg.eventProcess];

for meth = CO_meth
    clear dataCO
    % compute coherence
    if sum(strcmp(CO_meth, 'ft_coh'))>0
        
        %method 1
        cfg            = [];
        cfg.output     = 'fourier';
        cfg.method     = 'mtmfft';
        cfg.foilim     = [1 100];
        cfg.tapsmofrq  = 2;
        cfg.keeptrials = 'yes';
        %cfg.channel    = {'LFP*'};
        freqfourier    = ft_freqanalysis(cfg, lfp);
        
        % coherence
        cfg            = [];
        cfg.method     = meth{1};
        %cfg.channelcmb = {'LFP*' 'EMG'};
        fdfourier      = ft_connectivityanalysis(cfg, freqfourier);
    end
    
    
    for trial = 1:numel(seg)
        
        %% create coherence for LFP-EMG pairs
        label_count = 0;
        lab = {}; co_mat = []; clear co_sp C LAGS r wcoh period
        for ch_lfp = 1 : numel(lfp.label)
            for ch_emg = 1 : numel(emg.label)
                % create new label
                label_count                 = label_count + 1;
                lab = {lab{:},metadata.Label('name',[lfp.label{ch_lfp} '_' emg.label{ch_emg}])};
                
                switch meth{1}
                    case 'wcoh'
                        % matlab wavelet coherence (Uri E. Ramirez Pasos et al 2019)
                        [wcoh,~,period] = wcoherence(lfp.trial{trial}(ch_lfp,:),emg.trial{trial}(ch_emg,:), lfp.fsample); % nb freq x nb times
                        co_mat(:,:,label_count) = wcoh'; % nb times x nb freq x nb channels
                        
                    case {'coh'}
                        idx_ft = contains(fdfourier.labelcmb(:,1), lfp.label{ch_lfp}) & contains(fdfourier.labelcmb(:,2), emg.label{ch_emg});
                        co_mat(:,label_count) = fdfourier.cohspctrm(idx_ft, :);
                    case {'coh', 'plv'}
                        idx_ft = contains(fdfourier.labelcmb(:,1), lfp.label{ch_lfp}) & contains(fdfourier.labelcmb(:,2), emg.label{ch_emg});
                        co_mat(:,label_count) = fdfourier.plvspctrm(idx_ft, :);
                    case 'corr'
                        r = corr(squeeze(dataTF(trial).spectralProcess.values{1}(idx_test,:,ch_lfp)), emg_env.trial{trial}(ch_emg,idx_test)'); % nb freq
                        co_mat(:,label_count) = r';
                    case 'xcorr'
                        for fq = 1:size(dataTF(trial).spectralProcess.values{1},2)
                            [C,LAGS] = xcorr(detrend(squeeze(dataTF(trial).spectralProcess.values{1}(idx_test,fq,ch_lfp)),0), detrend(emg_env.trial{trial}(ch_emg,idx_test),0)','coeff'); % nb freq
                            co_mat(:,fq,label_count) = C;
                        end
                end
            end
        end
        % create spectral process
        switch meth{1}
            case 'wcoh'
                co_sp = SpectralProcess('values',co_mat,'f',period,'tStep',unique(diff(lfp.time{1})),'tBlock',0.001,'tStart', -1, 'tEnd',lfp.time{1}(end),'labels',lab); % nb times x nb freq x nb channels
                
            case {'coh', 'plv'}
                co_mat = permute(cat(3, co_mat, co_mat), [3,1,2]);  % nb times x nb freq x nb channels
                co_sp = SpectralProcess('values',co_mat,'f',fdfourier.freq,'tStep',0.1,'tBlock',0.1,'tStart', 0, 'tEnd',0.1,'labels',lab); % nb times x nb freq x nb channels
                
            case 'corr'
                co_mat = permute(cat(3, co_mat, co_mat), [3,1,2]);  % nb times x nb freq x nb channels
                co_sp = SpectralProcess('values',co_mat,'f',dataTF(1).spectralProcess.f,'tStep',0.1,'tBlock',0.1,'tStart', 0, 'tEnd',0.1,'labels',lab); % nb times x nb freq x nb channels
            case 'xcorr'
                co_sp = SpectralProcess('values',co_mat,'f',dataTF(1).spectralProcess.f,'tStep',tStep,'tBlock',0.0001,'tStart', LAGS(1)*tStep, 'tEnd',LAGS(end)*tStep,'labels',lab); % nb times x nb freq x nb channels
                
        end
               
        if ~exist('dataCO')
            dataCO(1) = Segment('process',{...
                co_sp,...
                EVTs(trial)},...
                'labels',{'CO' 'Evt'});
            dataCO(1).info('trial') = seg(trial).info('trial');
        else
            dataCO(end+1) = Segment('process',{...
                co_sp,...
                EVTs(trial)},...
                'labels',{'CO' 'Evt'});
            dataCO(end).info('trial') = seg(trial).info('trial');
        end
    end
       
    
    %% extract event timings
    
    TO  = cell2mat(linq(seg).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'T0')).tStart).toList)';
    FO1 = cell2mat(linq(seg).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'FO1')).tStart).toList)';
    FC1 = cell2mat(linq(seg).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'FC1')).tStart).toList)';
    
    %% Plot avg EMG and COH TODO, une figure par muscle et toutes les coh!!!!!!
    %trouver tous les ch_coh avec même muscle%
    lab_name = arrayfun(@(x) strsplit(x{1}.name, '_'), lab, 'UniformOutput', false)';
    lab_name = cat(1,lab_name{:});
    
    EMG_names = unique(lab_name(:,2));
    
    % medication
    idx_OFF = strcmp(arrayfun(@(x) x.info('trial').medication, seg_EMG, 'uni', 0), 'OFF');
    idx_ON  = strcmp(arrayfun(@(x) x.info('trial').medication, seg_EMG, 'uni', 0), 'ON');
    
    % get EMG CO
    EMG_CO = [dataCO.spectralProcess];
    [s, l1] = extract(EMG_CO);
    s1 = squeeze(cat(4,s.values)); %time x freq x ch x seg
    t1 = EMG_CO(1).times{1};
    fs = EMG_CO(1).Fs;
    freq1 = EMG_CO(1).f;
    
    
    
    clear v_EMG_ch
    for EMG_ch = 1 : numel(emg.label)
        if RectEMG
            EMG_FigName  = [filename '_' meth{1} '_rect_LFP_' emg.label{EMG_ch}];
        else           
            EMG_FigName  = [filename '_' meth{1} '_LFP_' emg.label{EMG_ch}];
        end
        EMG_fig      = figure('Name', EMG_FigName ,'NumberTitle','off', 'units', 'centimeters', 'position', [5 5 29.7 21]);
        
        v_EMG_ch = squeeze(v_EMG(EMG_ch,:,:)); % time x seg
        clear v_EMG_ch_env
        for t = 1 : size(v_EMG_ch,2)
            v_EMG_ch_env(:,t) = envelope(abs(v_EMG_ch(:,t)),10,'peak');
        end
        
        % ON / OFF
        for med = {'ON', 'OFF'}
            if strcmp(med,'ON')
                idx_plot  = 0;
                idx_trial = idx_ON;
            elseif strcmp(med,'OFF')
                idx_plot = 2;
                idx_trial = idx_OFF;
            end
            idx_plot_emg = idx_plot;
            for side = {'L', 'R'}
                % plot EMG
                idx_plot_emg = idx_plot_emg + 1;
                subplot(numel(lfp.label)/2+1, 4, idx_plot_emg)
                plot(emg.time{1}, median(v_EMG_ch_env(:,idx_trial),2), 'linewidth',2), hold on
                title([med ' ' emg.label{EMG_ch}])
                xlim([-0.5 1])
                %ajouter T0 + FO1 + FC1
                yl = ylim;
                % TO
                plot([median(TO(idx_trial)) median(TO(idx_trial))], yl, 'k')
                % FO1
                plot([median(FO1(idx_trial)) median(FO1(idx_trial))], yl, 'k')
                % FC1
                plot([median(FC1(idx_trial)) median(FC1(idx_trial))], yl, 'k')
            end
            
            idx_plot_L = idx_plot+1 + [(numel(lfp.label)/2)*4:-4:4];
            idx_plot_R = idx_plot+2 + [(numel(lfp.label)/2)*4:-4:4];
            idx_L_count = 0;
            idx_R_count = 0;
            for lfp_ch = 1 : numel(lfp.label)
                if contains(lfp.label{lfp_ch}, 'G')
                    idx_L_count = idx_L_count + 1;
                    g =subplot(numel(lfp.label)/2+1, 4, idx_plot_L(idx_L_count));
                elseif contains(lfp.label{lfp_ch}, 'D')
                    idx_R_count = idx_R_count + 1;
                    g = subplot(numel(lfp.label)/2+1, 4, idx_plot_R(idx_R_count));
                end
                
                idx_coh = strcmp(lab_name(:,2), emg.label{EMG_ch}) & strcmp(lab_name(:,1), lfp.label{lfp_ch});
                                
                % plot data
                switch meth{1}
                    case 'wcoh'
                        CO_EMG_ch = squeeze(median(s1(:,:,idx_coh, idx_trial), 4)); %time x freq x ch
                        surf(t1, freq1, CO_EMG_ch', 'edgecolor', 'none', 'parent', g);
                        view(g,0,90); hold on
                        yl = ylim;
                        plot([0 0], yl, 'k')
                        xlim([-0.7 1])
                        caxis([0 0.5])
                        ylim([0 100])
                        
                    case 'ft_coh'
                        CO_EMG_ch = squeeze(median(s1(:,idx_coh, idx_trial), 3)); %freq x ch
                        plot(freq1, CO_EMG_ch); hold on
                        if RectEMG
                            ylim([0 0.6])
                        else
                            ylim([0 0.1])
                        end
                        
                    case 'xcorr'
                        CO_EMG_ch = squeeze(median(s1(:,:,idx_coh, idx_trial), 4)); %time x freq x ch
                        surf(t1, freq1, CO_EMG_ch', 'edgecolor', 'none', 'parent', g);
                        view(g,0,90); hold on
                        caxis([-0.5 0.5])
                        xlim([-1.5 1.5])
                        
                    case 'corr' 
                        CO_EMG_ch = squeeze(median(s1(:,idx_coh, idx_trial), 3)); %freq x ch
                        plot(freq1, CO_EMG_ch); hold on
                        ylim([-0.5 0.5])
                end
                
                title(lfp.label{lfp_ch})
                
            end
        end
        saveas(EMG_fig, ['\\lexport\iss01.pf-marche\02_protocoles_data\02_Protocoles_Data\MarcheReelle\04_Traitement\03_CartesTF\PPN\LFP_EMG_CO\' EMG_FigName '.jpg'], 'jpg')
    end
    close('all')
end

