function s = extract_spaces_v2(s)
%% Extraction des espaces d'un string
% s = string ou cell de strings, contenant(s) un ou des espaces
% string = s sans les espaces

if isstr(s)
    s={s};
end

for i = 1:length(s)
    ind = regexp(s{i},'[\s]');
    s{i}(ind)=[];
end
