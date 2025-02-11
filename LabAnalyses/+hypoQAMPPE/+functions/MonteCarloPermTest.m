function [pValues] = MonteCarloPermTest(PSDValueList,UPDRSoffList,numPermutations)
    %MONTECARLOPERMTEST Summary of this function goes here

    PSDValueList = PSDValueList';
    UPDRSoffList = UPDRSoffList';
    rng('default');  % Sets the seed to the default state for reproducibility

    % Compute Spearman correlation coefficients
    rho_observed =  corr(PSDValueList, UPDRSoffList, 'Type', 'Spearman') ;
    
    % Perform Monte Carlo permutation test
    permutedCorrelations = zeros(numPermutations, size(rho_observed, 2));

    %% Marche pas mais Work in Progress
%     % Permute one of the variables and compute Spearman correlation coefficients
%     permutedPSDValueLists = PSDValueList(randperm(length(PSDValueList), numPermutations));
%     permutedCorrelations = corr(permutedPSDValueLists, UPDRSoffList, 'Type', 'Spearman');
   
    for i = 1:numPermutations
        % Permute one of the variables
        permutedPSDValueList = PSDValueList(randperm(length(PSDValueList)));
    
        % Recompute Spearman correlation coefficients
        permutedCorrelations(i, :) = corr(permutedPSDValueList, UPDRSoffList, 'Type', 'Spearman');
    end
    
    % Calculate p-values
    pValues = sum(abs(permutedCorrelations) >= abs(rho_observed)) / numPermutations;

end

