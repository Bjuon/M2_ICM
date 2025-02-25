function [envelopeEMGn, envelopeEMGn_resampled] = envelopeNormalization(envelopeEMG, maxEMG, Fa)

emg_labels = fieldnames(maxEMG{1, 1});

% Extraction of the maximum in the single trials
for nt = 1:numel(maxEMG)
    for nemg = 1: length(emg_labels)
        maxTot(nt,nemg) = maxEMG{nt}.(emg_labels{nemg});
    end
end

% Find the maximum among all the maxima
if numel(envelopeEMG) > 1
    MVC = max(maxTot);
else
    MVC = maxTot     ;
end

% Normalize each EMG with respect of each MVC and then resample

% Resampling factors 
[p,q] = rat(33.333 / Fa);

for nt = 1:numel(envelopeEMG)
    for nemg = 1: length(emg_labels)
        envelopeEMGn{nt}.(emg_labels{nemg}) = envelopeEMG{nt}.(emg_labels{nemg})/MVC(nemg);
        envelopeEMGn_resampled{nt}.(emg_labels{nemg}) = resample(envelopeEMGn{nt}.(emg_labels{nemg}), p,q);
    end
end

