function [Change_pts cum_res] = change_point_analysis_cusum(Signal,n_iteration,flag)
% function [Change_pts cum_res] = change_point_analysis_cusum(Signal,n_iteration,flag)
%% Calcul du/des change-points d'un vecteur Signal (Taylor 2000)
% Signal : vecteur [N x n] contenant n signaux temporels par colonne
% n_iteration : nombre d'itération (découpage en sous-fenêtres temporelles) pour calcul itérative (optionnel)
% flag :affichage
% Sortie:
% cum_res : vecteur des résidus cumulés
% Change_pts: structure de taille n, avec les indices des change_pts

%% Initialisation
Change_pts={};
if nargin<2
    n_iteration = 0;
end

if n_iteration == 0
    n_windows = 1;
else
    n_windows = 2*n_iteration; %En fonction du nombre d'itération, à chaque itération on découpe chaque fenêtre en 2
end

taille = length(Signal);
n_signaux = size(Signal,2);
%Cas d'un vecteur ligne
if taille==n_signaux && size(Signal,1)==1
    n_signaux=1;
end

%Prétraitement
window_width = floor(taille/n_windows);
Signal_tmp = NaN*ones(window_width,n_signaux);
res = NaN*ones(window_width,n_signaux);
cum_res = NaN*ones(taille,n_signaux); %Signal des residus

for n=1:n_windows
    %Extraction de la fenêtre temporelle
    Signal_tmp = Signal((n-1)*window_width+1:(n)*window_width,:);
    %Calcul des residus
    res = Signal_tmp - repmat(mean(Signal_tmp,1),window_width,1);
    %Calcul des residus cumulés
    cum_res((n-1)*window_width+1:(n)*window_width,:) = cumsum(res);
end

%% Extraction des chanpe-points
for i=1:n_signaux
    X = cum_res(:,i);
    spline=csaps([1:length(X)]',double(X));
    fprime=fnder(spline);
    ind=fnzeros(fprime);
    signe=fnval(fprime,ind(1,:)+1);

    Max=floor(ind(1,find(signe<0)));
    Min=floor(ind(1,find(signe>0)));
    Change_pts(i).derive_negative = Max;
    Change_pts(i).derive_positive = Min;
    if exist('flag','var')
        %Affichange
        figure
        plot(Signal(:,i));
        hold on
        plot(cum_res(:,i),'g');
    end
end
