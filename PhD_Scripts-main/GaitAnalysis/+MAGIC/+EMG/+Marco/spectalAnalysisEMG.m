function powerspectraEMG = spectalAnalysisEMG(rawEMG, Fa, trialname, MinTP, MaxTP, todo_plot)

emg_labels = fieldnames(rawEMG);

if todo_plot 
    figure 
    sgtitle(['Processed EMG data', trialname])
end

for n = 1:numel(fieldnames(rawEMG))

    % Detrendening
    detrended = detrend(rawEMG.(emg_labels{n}));
    
    % Notch filter to remove 50Hz freq (Pwer line noise)
    ord = 2;    cutoff = [49 51];
    wn = cutoff/(Fa/2);
    [b,a]=butter(ord,wn,'stop');
    filtered1 = filtfilt(b,a,detrended);
    
    % High pass butterworth filter design
    ord = 2;    cutoff = [10 450];
    wn = cutoff/(Fa/2);
    [b,a]=butter(ord,wn,'bandpass');  
    filtered = filtfilt(b,a,filtered1);
    
    % Cut the EMG signal in the zone of interest
    emg = filtered(MinTP:MaxTP,:);
    
    % Compute the power spectral density
    N = length(emg);
    xdft = fft(emg);
    xdft = xdft(1:floor(N/2+1));
    psdx = (1/(N)) * abs(xdft).^2;
    psdx(2:end-1) = 2*psdx(2:end-1);
    powerspectraEMG.psdx.(emg_labels{n}) = psdx;
    powerspectraEMG.freq = 0:Fa/length(emg):Fa/2;

    % Plot power spectra
    if todo_plot
        subplot(3, 2, n)
        plot(powerspectraEMG.freq,powerspectraEMG.psdx.(emg_labels{n}),'k:')
        title((emg_labels{n}))
        xlabel("Frequency (Hz)")
        ylabel("Power spectrum")
    end
    
    % Calculate the alpha power
    [roi, ~] = MAGIC.EMG.Marco.findBandDelimiters(powerspectraEMG.freq',[8 12]);
    powerspectraEMG.alphaPower.(emg_labels{n}) = sum(powerspectraEMG.psdx.(emg_labels{n})(roi(1):roi(2),:));

    % Calculate the beta power
    [roi, ~] = MAGIC.EMG.Marco.findBandDelimiters(powerspectraEMG.freq',[13 30]);
    powerspectraEMG.betaPower.(emg_labels{n}) = sum(powerspectraEMG.psdx.(emg_labels{n})(roi(1):roi(2),:));

end

