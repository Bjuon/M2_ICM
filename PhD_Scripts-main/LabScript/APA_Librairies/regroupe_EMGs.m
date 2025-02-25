function [Moy Std] = regroupe_EMGs(Group_EMG)
%% Calcul des instants d'activations moyens d'un ensembles d'acquisitions stockées dans la structure Group_EMG
%Entrés: structure Group_EMG contenant les instants d'activation EMG par acquisition et muscle
%Sorties: Moy structure équivalente à l'acquisition moyenne
%         Std structure équivalente à l'écart-type des acquisitions

acquisitions = fieldnames(Group_EMG); %Extraction des noms des acqs choisies
SS_tmp=[];
Moy={};
Std={};

try
    muscles = fieldnames(Group_EMG.(acquisitions{1})); %Extraction des données stockées
catch Errt
    return
end

n_acq = length(acquisitions);
%% Calculs des debut/fin d'activité moyens et STD
for j = 1:length(muscles)
    N = [n_acq n_acq 0];
    S_summed = zeros(2,2); %% On suppose qu'il y'a 2 périodes d'activités par muscle (modulable jusqu'à 3)
    S_cumul = [];
    for i = 1:n_acq
        S = Group_EMG.(acquisitions{i}).(muscles{j});
        diff_p = size(S_summed,2) - size(S,2);
        if diff_p<0
            Add_zeros = zeros(2,abs(diff_p));
            S_summed = [S_summed Add_zeros];
            N(3) = N(3)+1;
        elseif diff_p>0
            Add_zeros = zeros(2,abs(diff_p));
            S = [S Add_zeros];
            N(2) = N(2)-1;
        end
        if diff_p==0 && size(S,2)==3
            N(3) = N(3)+1;
        end
        try
            S_cumul = [S_cumul;S];
        catch Errt
            S_cumul = [[S_cumul zeros(size(S_cumul,1),abs(diff_p))];S];
        end
        
        S_summed = S_summed + S;
        clear S
    end
    %Mean
    try
        Moy.(muscles{j}) = round(S_summed./repmat(N(1:size(S_summed,2)),size(S_summed,1),1));
    catch ERR_num_Activation
        Moy.(muscles{j}) = round(S_summed(:,1:size(N,2))./repmat(N,size(S_summed,1),1));
    end
    
    %STD
    S_ON  = S_cumul(1:2:end,:); %Debut
    S_OFF = S_cumul(2:2:end,:); %Fin
    
    S_ON(S_ON==0) = NaN;
    S_OFF(S_OFF==0) = NaN;
    
    Std.(muscles{j}) = [nanstd(S_ON);nanstd(S_OFF)];
end