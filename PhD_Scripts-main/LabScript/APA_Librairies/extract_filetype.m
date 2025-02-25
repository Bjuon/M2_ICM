function type = extract_filetype(s)
%% Extraction de l'extension d'un nom de fichier
% s = string du nom complet de fichier (sachant que le nom ne contient pas de '.' avant l'extension
% type = string du file type

indice_stop = regexp(s,'\.');

type = s(indice_stop+1:end);
end
