function [strings Full_string]= extract_tags(s,sep)
% function [strings Full_string]= extract_tags(s,sep)
%% Extraction des strings entre les '_' d'un string
% s = string contenant plusieurs _'tag'_
% strings = cell des strings extraits
% Full_string = string entier sans les '_'

if nargin<2
    sep='_';
end

indices = regexp(s,sep);
Full_string = [];
ind = [0 indices length(s)+1];

for i=1:length(indices)+1
    strings{i,:} = s(ind(i)+1:ind(i+1)-1);
    Full_string = [Full_string s(ind(i)+1:ind(i+1)-1)];
end
