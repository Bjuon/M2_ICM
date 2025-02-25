function files=extrait_liste_sessions(list_rep,filetype)
%% Extrait les fichier de type '_sessions.mat' d'une liste extrait d'un répertoire

k=length(list_rep);
c=1;
files={};
for i=1:k
    try
        if sum(strcmp(list_rep(i).name(end-12:end),'_sessions.mat'))
            files {c} = list_rep(i).name;
            c=c+1;
        end
    catch Err
        disp(['Pas un fichier supporté! ' filetype]);
    end
end

if length(files)==1 % Cas ou il n'y a qu'une seule acquisition, on stocke la chaine de caractère uniquement
    files = cellstr(files);
end
