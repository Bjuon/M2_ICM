function S = colle_labels(Cel,sep,flag_lfp)
% function S = colle_labels(Cel,sep,flag_lfp)
%% Concatene les strings d'une cellule de strings
S = '';
N = length(Cel);

if nargin<2
    sep = ' -- ';
end

for i = 0:N-1
    if exist('flag_lfp','var')
        St = Cel{N-i};
        St = St(end-2:end);
    else
        [t St] = extract_tags(Cel{N-i});
    end
    S = [S sep St];
end