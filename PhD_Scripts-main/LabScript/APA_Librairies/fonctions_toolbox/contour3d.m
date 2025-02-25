% function [C3D,Info_N,Info_P,Arr] = contour3D(P,N,Src,Info_N,Arr) ;
%
% Fonction de calcul d'un contour 3D pour un objet donné
%
function [C3D,Info_N,Info_P,Arr] = contour3D(P,N,Src,Info_N,Arr,Info_P) ;
% 
% 1. Gestion des données d'entrée
%
if nargin < 6
    % ---> L'analyse des polygones n'est pas réalisée
    [Info_P,P] = analyse_geometrie_polygones(P,N) ;
end
if nargin < 5 ;
    % ---> L'analyse des arretes n'a pas été réalisée
    Arr = analyse_arretes(P) ;
end
if nargin < 4 ;
    % ---> La définition des normales n'est pas donnée
    Info_N = calcul_normale_noeuds(N,P,Info_P) ;
end
%
% 2. Mise en place du calcul
%
NN = size(N,1) ;              % Nombre de noeuds
NP = size(P,1) ;              % Nombre de polygones
NA = size(Arr.Definition,1) ; % Nombre d'arretes
%
% a) Gestion des sources :
%
if size(Src,1) == 2 ; 
    % ---> Nous avons affaire à une droite de sources
    % première ligne : un point de la droite
    % deuxième ligne : vecteur directeur de la droite
    Src(2,:) = Src(2,:) / norm(Src(2,:)) ; % Nous normons le V_dir
    OP = ones(NN,1)*Src(1,:) ; nn = ones(NN,1)*Src(1,:) ;
    PMnn = sum((N-OP).*nn,2) ;
    Msources = OP + (PMnn*[1,1,1]).* nn ; % ---> Matrice des sources pour chacun des points
    clear OP nn PMnn ;
else
    % ---> Nous avons affaire à une source ponctuelle
    Msources = ones(NN,1) * Src ;
end
%
% b) Calcul des vecteurs ui (SiMi) normés
%
Vu = norme_vecteur(N-Msources) ;
% Vu = N - Msources ;
%
% c) Calcul des paramtères d'interpolation
%
% [U,Pok] = interp2v(Info_N.Normale(Arr.Definition(:,1),:),...
%   Info_N.Normale(Arr.Definition(:,2),:),...
%   Vu(Arr.Definition(:,1),:),...
%   Vu(Arr.Definition(:,2),:)) ;
warning off
U = dot(Info_N.Normale(Arr.Definition(:,2),:),Vu(Arr.Definition(:,2),:),2) ./ ...
    (dot(Info_N.Normale(Arr.Definition(:,2),:),Vu(Arr.Definition(:,2),:),2) - ...
    dot(Info_N.Normale(Arr.Definition(:,1),:),Vu(Arr.Definition(:,1),:),2)) ;
Pok = find((U >= 0) & (U <= 1)) ; U = U(Pok) ;
%
% 3. Calcul des points du contour 3D
% 
% Calcul du point : 
C3D.coord(:,1:3) = (U * [1,1,1]) .* N(Arr.Definition(Pok,1),:) + ...
    ((1 - U) * [1,1,1]) .* N(Arr.Definition(Pok,2),:)  ;
C3D.Normale(:,1:3) = (U * [1,1,1]) .* Info_N.Normale(Arr.Definition(Pok,1),:) + ...
    ((1 - U) * [1,1,1]) .* Info_N.Normale(Arr.Definition(Pok,2),:)  ;
% Polygones d'appartenance
C3D.Pol = Arr.Polygones(Pok,:) ;
warning on
%
% 4. génération des contours
%
C3D = creer_connections(C3D) ;
%
% fin de la fonction