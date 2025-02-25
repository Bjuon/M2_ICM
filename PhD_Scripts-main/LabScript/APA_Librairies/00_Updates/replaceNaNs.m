function M_out = replaceNaNs(M_in,dim)
% function M_out = replaceNaNs(M_in,dim)
%% Fonction qui dans une matrice 'M_in', va extrapoler les tranches de NaN suivant la dimension 2 par défaut
% M_in = vecteur ligne /matrice2D avec NaNs
% dim = dimension à regarder (1 ou 2) (defaut = 2)
% M_out = matrice sans NaNs

%% Initialisation
if nargin<2
    dim=2;
end

transpose=0;
if dim==1 || iscolumn(M_in)
    transpose=1;
    M_in = M_in';
end

M_out = M_in;

%% Interpolation des NaNs
method = 'cubic';
extrap = {'extrap'};

for i=1:size(M_in,1)
    X = M_in(i,:);
    try
        if isnan(X(1)) || isnan(X(end))% Gestion du 1er et dernier élément
            X(1) = X(find(~isnan(X),1,'first'));
            X(end) = X(find(~isnan(X),1,'last'));
        end
    
        T = reshape(1:length(X),size(X));
        inan = isnan(X);
        X(inan) = interp1(T(~inan),X(~inan),T(inan),method,extrap{:});
        M_out(i,:) = X;
    catch all_NaNs
        disp('Pas assez d''éléments - Vecteur/Ligne de NaNs uniquement!');
    end
end

if transpose
    M_out = M_out';
end
