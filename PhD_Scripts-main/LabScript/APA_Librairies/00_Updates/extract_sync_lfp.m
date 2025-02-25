function [list_lfp t_trigs]= extract_sync_lfp(file)
%% Function qui extrait la liste des noms des acquisitions ayant eut des enregistremebts lfps et les positionne celon l'ordre d'occurence des triggers
% file : fichier .xls contenant 2 colonne (N_triggers ou Temps_Triggers et nom de l'acquisition correspondante)
[NUMERIC,TXT,donnees]=xlsread(file);

list_lfp = TXT(2:end,2:end);
if length(list_lfp)==length(NUMERIC)
    t_trigs = NUMERIC;
elseif length(list_lfp)<length(NUMERIC) %% cas de lecture de fichier .xls 98
    t_trigs = NUMERIC(2:end);
end