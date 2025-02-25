function [S_out S_out_t] = export_activation(S_in,S_in_t,T0,C,Muscle)
%% Remodifie la forme de la structure contenant les % des débuts/fins d'activations EMG
% [S_out S_out_t] = export_activation(S_in,S_in_t,T0,C,Muscle)
% S_in   = matrice des % ayant la forme [2xN] ( ==Activation_EMG_percycle.(acq).(muscle))
% S_in_t = matrice des temps ayant la forme [2xN] ( ==Activation_EMG.(acq).(muscle))
% T0     = temps du T0 (en sec)
% C      = 'string' côté G/D
% M      = 'string' nom du muscle
% S_out / S_out_t  = structure de sortie ayant les champs: .Start_i .DUration_i (i=1..N)

for i=1:size(S_in,2)
    if exist('Muscle','var')
        champ_start_per = [Muscle '_Start_Per' num2str(i)];
        champ_length_per = [Muscle '_Duration_Per' num2str(i)];
    else
        champ_start_per = ['Start_Per' num2str(i)];
        champ_length_per = ['Duration_Per' num2str(i)];
    end
    try
        S_out.Cote = C;
    catch No_cote
        S_out.Cote = NaN;
    end
    
    S_out.(champ_start_per) = S_in(1,i);
    S_out.(champ_length_per) = S_in(2,i) - S_in(1,i); %durée en % de cycle
    
    if nargin>1
        try
            S_out_t.Cote = C;
        catch No_cote
            S_out_t.Cote = NaN;
        end
        if exist('Muscle','var')
            champ_start = [Muscle '_Start_T' num2str(i)];
            champ_length = [Muscle '_Duration_T' num2str(i)];
        else
            champ_start = ['Start_T' num2str(i)];
            champ_length = ['Duration_T' num2str(i)];
        end
        
        S_out.(champ_start) = (S_in_t(1,i) - T0)*1e3;
        S_out.(champ_length) = (S_in_t(2,i) - S_in_t(1,i))*1e3; %durée en ms
        
        S_out_t.(champ_start) = (S_in_t(1,i) - T0)*1e3;
        S_out_t.(champ_length) = (S_in_t(2,i) - S_in_t(1,i))*1e3; %durée en ms
    end
end