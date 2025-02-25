function files=extrait_liste_acquisitions(list_rep,filetype)
%% Extrait les fichier de type .'filetype' d'une liste extrait d'un répertoire

k=length(list_rep);
c=1;
files={};
for i=1:k
    try
        if sum(strcmp(extract_filetype(list_rep(i).name),filetype))
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
