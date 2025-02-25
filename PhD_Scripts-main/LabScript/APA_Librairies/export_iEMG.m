function i_out = export_iEMG(EMG_in,S_in_t,C,Muscle)
%% Remodifie la forme de la structure contenant les % des débuts/fins d'activations EMG
% i_out  = export_activation(EMG_in,S_in_t,T0,C,Muscle)
% EMG_in   = matrice des EMG pour l'acquisition ayant la forme [nx4] ( ==EMG.(acq))
% S_in_t = matrice des temps ayant la forme [2xN] ( ==Activation_EMG.(acq).(muscle))
% C      = 'string' côté G/D
% M      = 'string' nom du muscle
% i_out  = structure de sortie ayant les champs: .Burst_i (i=1..N)

Fech = EMG_in.Fech;
m = find(compare_liste({Muscle},EMG_in.nom),1);

%Detournement au cas ou les canaux EMG n'ont pas les même nomenclature que d'habitude
if isempty(m)
    switch Muscle
        case 'RTA'
            m=1;
        case 'RSOL'
            m=2;
        case 'LTA'
            m=3;
        case 'LSOL'
            m=4;
        otherwise
            m=NaN;
    end
end

for i=1:size(S_in_t,1)
    if exist('Muscle','var')
        champ_i = ['i' Muscle '_T' num2str(i)];
    else
        champ_i = ['iEMG_T' num2str(i)];
    end
    try
        i_out.Cote = C;
    catch No_cote
        i_out.Cote = NaN;
    end
    
    if nargin>1
        start_i = floor(S_in_t(i,1)*Fech);
        end_i = round(S_in_t(i,2)*Fech);
        try
            EMG_i = EMG_in.val(start_i:end_i,m);
            i_out.(champ_i) = trapz(abs(EMG_i)); % Aire sous la courbe redressée
        catch muscle_not_found
            i_out.(champ_i) = NaN;
        end
    end
end