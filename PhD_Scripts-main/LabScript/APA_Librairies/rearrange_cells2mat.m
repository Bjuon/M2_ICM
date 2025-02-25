function [S_out Tags_out] = rearrange_cells2mat(S_in,Tags_in)
% function [S_out Ind_out]= rearrange_cells2mat(S_in,Tags_in)
%% Fonction qui à va transformer une cellule de matrices/valeur(S_in) (et tags correspondants (Tags_in) si existent) en une matrice colonne (S_out) (et cellule colonne de tags)
% !! S_in et Tags_in ont le même nombre de lignes!

if nargin<1
    Tags_in = NaN*ones(length(S_in),1);
end

if length(S_in)~=length(Tags_in)
    error('Tailles des cellules non égales!');
    return
end

%% Initialisation
S_out = [];
Tags_out = {};

r = 0;
for t=1:length(S_in)
    curr_vals = cell2mat(S_in(t))';
    
    if ~isnan(nanmean(curr_vals))
        reps = length(curr_vals);
        r = r + reps;
        S_out = [S_out;curr_vals];
        
        curr_tags = repmat(Tags_in(t),reps,1);
        Tags_out = [Tags_out; curr_tags];
    end
end

% On ordonne les valeurs par ordre croissant
[S_out ind_out] = sort(S_out);
Tags_out = Tags_out(ind_out);