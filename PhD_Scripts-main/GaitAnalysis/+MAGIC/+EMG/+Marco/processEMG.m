function [envelopeEMG, maxEMG] = processEMG(rawEMG, Fa, trialname, MinTP, MaxTP, todo_plot)

emg_labels = fieldnames(rawEMG);

if todo_plot ; figure ; end
sgtitle(['Processed EMG data', trialname])
for n = 1:numel(fieldnames(rawEMG))

    % Detrendening
    detrended = detrend(rawEMG.(emg_labels{n}));
    
    % Notch filter to remove 50Hz freq (Pwer line noise)
    ord = 2;    cutoff = [49 51];
    wn = cutoff/(Fa/2);
    [b,a]=butter(ord,wn,'stop');
    
    filtered1 = filtfilt(b,a,detrended);
    
    % High pass butterworth filter design
    ord = 2;    cutoff = [2 450];
    wn = cutoff/(Fa/2);
    [b,a]=butter(ord,wn,'bandpass');
    
    filtered = filtfilt(b,a,filtered1);
    
    % Signal rectification 
    
    rectified = abs(filtered);
    
    % Low pass butterworth filter design for envelope extraction
    ord = 2;    cutoff = 6;
    wn = cutoff/(Fa/2);
    [b,a]=butter(ord,wn,'low');
    
    envelopeEMG_all.(emg_labels{n}) = filtfilt(b,a,rectified);
    
    % Find the maximum in the entire signal (it can be changed maybe until before the start of the turn)
    maxEMG.(emg_labels{n}) = max(envelopeEMG_all.(emg_labels{n}));

    % Plot
    if todo_plot
        subplot(3, 2, n)
        plot(rawEMG.(emg_labels{n})(MinTP:MaxTP,:),'k:')
        hold on
        %plot(filtered(MinTP:MaxTP,:),'b:')
        plot(rectified(MinTP:MaxTP,:),'b:')
        plot(envelopeEMG_all.(emg_labels{n})(MinTP:MaxTP,:),'Color',[.7 .7 .7],'LineWidth',1.5)
    
        title(emg_labels{n})
        ylim([-1 1])
        xlim([0 length(rawEMG.(emg_labels{n})(MinTP:MaxTP,:))])
        xticks([0 length(rawEMG.(emg_labels{n})(MinTP:MaxTP,:))])
        xticklabels({'MinTP', 'MaxTP'})
    end

    % Cut the EMG signal in the zone of interest
    envelopeEMG.(emg_labels{n}) = envelopeEMG_all.(emg_labels{n})(MinTP:MaxTP,:);

end