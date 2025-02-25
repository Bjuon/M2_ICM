function LFPs = extract_lfps_from_struct(LFPs_in)
%% Extraction des signaux lfp d'une structure
% Structure avec pour champs le nom du signal
    channels = fieldnames(LFPs_in);
    c=1;
    n_channels = length(channels);
    for i =1:n_channels
        try
            LFPs(c,:) = LFPs_in.(channels{i}); % Toutes les channels ont la même taille!
            c=c+1;
        catch Err
        end
    end
    
    if n_channels>6 %Théoriquement 6 contacts uniquement, donc les 1ère chaines ne sont pas des LFP
        LFPs = LFPs(n_channels-6+1:end,:);
    end