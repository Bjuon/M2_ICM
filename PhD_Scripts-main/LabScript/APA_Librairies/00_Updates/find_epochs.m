function [T_out epochs] = find_epochs(T)
% function [T_out epochs] = find_epochs(T)
%% Fonction interne pour écriture des évènements au format .lena découpé

try
    T_out = cell2mat(T);
    epochs = find(~isnan(T_out))';
catch multi_evts_per_trial
    r = 0;
    epochs = [];
    T_out = [];
    for t=1:length(T)
        Ts = cell2mat(T(t))';
        
        if ~isnan(nanmean(Ts))
            reps = length(Ts);
            r = r + reps;
            T_out = [T_out;Ts];
            
            epochs = [epochs repmat(t,1,reps)];
        end
    end
end

epochs = epochs - 1;