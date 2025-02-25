function s = extract_spaces_v3(s,sep,nom)
%% Extraction des symboles (sep) d'un string
% s = string ou cell de strings, contenant(s) un ou des espaces
% string = s sans les symboles
% sep = type de symboles à retirer ('\s': espaces; '\W': non alphabetic ou numeric ...) (optionnel, defaut ='\s')
% nom = si une chaine est vide après traitement on peut la remplacer par (nom) (optionnel)

if nargin<2
    sep = '[\s]';
end

if isstr(s)
    s={s};
end

for i = 1:length(s)
    ind = regexp(s{i},sep);
    s{i}(ind)=[];
    if isempty(s{i}) && exist('nom','var')
        s{i} = [nom num2str(i)];
    end
end

if length(s)==1
    s = cell2mat(s);
end