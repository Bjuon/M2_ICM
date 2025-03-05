function [Artefacts_Detected_per_Sample, Cleaned_Data] = Artefact_detection_mathys_emd(data)
% Artefact_detection_mathys_emd - Detect and remove artefacts using Empirical Mode Decomposition (EMD)
% and extract beta-band (20-50 Hz) components.
%
% Inputs:
%   data - Structure with fields:
%          - values: cell array containing the LFP data matrix.
%          - Fs: sampling frequency.
%
% Outputs:
%   Artefacts_Detected_per_Sample - Binary matrix indicating artefact locations.
%   Cleaned_Data - Data after artefact removal, filtered in the beta-band.
%
% This function decomposes the signal into IMFs and selects only those
% that fall within the 0-70 frequency range before reconstruction.

% Set detection threshold multiplier
k = 2;

% Initialize output matrices based on original data dimensions
Cleaned_Data = data.values{1,1};
Artefacts_Detected_per_Sample = zeros(size(Cleaned_Data));

% Loop over each channel in the data
for iChannel = 1:size(data.values{1,1},2)
    local_values = data.values{1,1}(:, iChannel);
    
    % Perform Empirical Mode Decomposition on the channel signal
    [imfs, residual] = emd(local_values); % imfs: matrix of intrinsic mode functions
    [nSamples, nIMFs] = size(imfs);
    corrected_imfs = zeros(nSamples, nIMFs);
    
    % Initialize an artefact mask for this channel
    artifact_mask = false(nSamples,1);
    
    % Store beta-band IMFs for later reconstruction
    beta_imfs = [];
    
    % Process each IMF
    for iImf = 1:nIMFs
        current_imf = imfs(:, iImf);
     
        % Compute the dominant frequency of the IMF using the helper function.
        % You can switch between the two methods
        f_dom = dominant_frequency_PSD(current_imf, data.Fs);  
        f_dom = dominant_frequency_hilbert(current_imf, data.Fs);
        
        % Select only IMFs within the  range (0-70 Hz)
        if f_dom >= 0 && f_dom <= 70
            beta_imfs = [beta_imfs, current_imf]; %#ok<AGROW>
        end
        
        % Compute median absolute deviation for current IMF
        mad_val = mad(current_imf);
        
%         % Identify artefact samples in the IMF with k * MAD
%         imf_artifacts = abs(current_imf) > k * mad_val;
%         artifact_mask = artifact_mask | imf_artifacts;
%         
        % Identify artefacts with Energy-Based IMF Thresholding
        energy_imf(iImf) = sum(imfs(:, iImf).^2);
        threshold = median(energy_imf) + k * mad(energy_imf); % Adaptive threshold
        imf_artifacts = energy_imf > threshold;
       
        
        % Replace artefact samples using linear interpolation if necessary
        if any(imf_artifacts)
            good_idx = find(~imf_artifacts);
            current_imf(imf_artifacts) = interp1(good_idx, current_imf(good_idx), find(imf_artifacts), 'linear', 'extrap');
        end
        corrected_imfs(:, iImf) = current_imf;
    end
    
    % Reconstruct beta-filtered signal by summing selected beta IMFs
    if ~isempty(beta_imfs)
        Cleaned_Data(:, iChannel) = sum(beta_imfs, 2);
    else
        Cleaned_Data(:, iChannel) = zeros(nSamples, 1); % If no beta-band IMF is found
    end
    
    Artefacts_Detected_per_Sample(:, iChannel) = artifact_mask;
end

% Store sampling frequency for reference in first element
Artefacts_Detected_per_Sample(1,1) = data.Fs;
end
%% Helper Functions

function f_dom = dominant_frequency_PSD(signal, fs)
% dominant_frequency - Computes the dominant frequency of a signal using the Power Spectral Density.
%
% Inputs:
%   signal - Input time-series (e.g., one IMF vector).
%   fs     - Sampling frequency (Hz).
%
% Output:
%   f_dom  - Dominant frequency (Hz), defined as the frequency corresponding to 
%            the highest peak in the power spectral density (PSD).
%
% To tweak:
% - Adjust the method for computing the PSD if needed.
% - Modify the frequency resolution by changing the FFT parameters.

n = length(signal);
frequencies = (0:floor(n/2)-1) * (fs / n);  % Frequency vector up to the Nyquist limit
fft_signal = fft(signal);
psd = abs(fft_signal(1:floor(n/2))).^2;       % Compute PSD for positive frequencies
[~, idx_max] = max(psd);                      % Find index of maximum power
f_dom = frequencies(idx_max);                 % Return the corresponding frequency

end

function f_dom = dominant_frequency_hilbert(signal, fs)
% dominant_frequency_hilbert - Computes the mean instantaneous frequency using the Hilbert Transform.
%
% Inputs:
%   signal - Input time-series (e.g., one IMF vector).
%   fs     - Sampling frequency (Hz).
%
% Output:
%   f_dom  - Mean instantaneous frequency (Hz) calculated from the derivative
%            of the unwrapped phase of the analytic signal.
%
% To tweak:
% - Consider applying a smoothing filter to the instantaneous frequency if needed.
% - Adjust how outliers (e.g., non-positive frequencies) are handled.

% Obtain the analytic signal using the Hilbert transform
analytic_signal = hilbert(signal);
instantaneous_phase = unwrap(angle(analytic_signal));
% Compute instantaneous frequency (difference of phase) scaled by sampling frequency
instantaneous_freq = diff(instantaneous_phase) / (2*pi) * fs;
% Calculate the mean of the positive instantaneous frequencies
f_dom = mean(instantaneous_freq(instantaneous_freq > 0));

end