function s = extract_spaces(s)
%% Extraction des espaces d'un string
% s = string contenant un ou des espaces
% string = s sans les espaces

ind = regexp(s,'[\s]');

s(ind)=[];
end
