function string = extract_condition(s)
%% Extraction du nom entre les '' d'un string
% s = string contenant un _'tag'_
% string = 'tag' extrait

ind = regexp(s,'[\W]');
string = s(ind(1)+1:ind(2)-1);
end
