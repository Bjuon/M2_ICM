function [list_emg list_anlg] = extraire_emgs_liste(list_anlg)
%% Extrait les noms des canaux EMG de la liste des canaux analogiques
% list_anlg = liste de noms
% list_emg = liste des noms des chaines EMG (théoriquement commençant par R ou L)

anlg_1={};

for c=1:length(list_anlg)
    channel = cell2mat(list_anlg(c));
    anlg_1{c} = channel(1); % On extrait la première lettre
    anlg_end{c} = channel(end); % On extrait la dernière lettre
end

isanlg = ~sum(compare_liste({'R' 'L'},anlg_1),1);

list_emg = list_anlg(~isanlg);
list_anlg = list_anlg(isanlg);

if isempty(list_emg) %% ON tente de lire de la fin
    isanlg = [];
    
    isanlg = ~sum(compare_liste({'D' 'G'},anlg_end),1);
    list_emg = list_anlg(~isanlg);
    list_anlg = list_anlg(isanlg);
end