function [ci_low, ci_high] = Bootstrap(PSDValueList, UPDRSoffList, numResamples, alpha)
    
    if nargin < 4
        alpha = 0.05;
    end
    rng('default');
    
    PSDValueList = PSDValueList';
    UPDRSoffList = UPDRSoffList';

    %% Marche pas mais Work in Progress
%     % Vectorized bootstrap resampling
%     resampledIndices = randi(length(PSDValueList), [length(PSDValueList), numResamples]);
%     resampledData1 = PSDValueList(resampledIndices);
%     resampledData2 = UPDRSoffList(resampledIndices);
% 
%     % Compute Spearman correlation coefficient for resampled data
%     resampledCorrelations = corr(resampledData1, resampledData2, 'Type', 'Spearman','rows','all');
% 
%     % Calculate confidence interval
%     ci = prctile(resampledCorrelations, [100 * alpha / 2, 100 * (1 - alpha / 2)]);

    % Perform bootstrap resampling
    resampledCorrelations = zeros(numResamples, 1);

    for i = 1:numResamples
        % Generate resampled data with replacement
        resampledIndices = randi(length(PSDValueList), [length(PSDValueList), 1]);
        resampledData1 = PSDValueList(resampledIndices);
        resampledData2 = UPDRSoffList(resampledIndices);

        % Compute Spearman correlation coefficient for resampled data
        resampledCorrelations(i) = corr(resampledData1, resampledData2, 'Type', 'Spearman');
    end

    % Calculate confidence interval
    ci = prctile(resampledCorrelations, [100 * alpha / 2, 100 * (1 - alpha / 2)]);
    ci_low = ci(1);
    ci_high = ci(2);
end
