% function [C3D,Info_N,Info_P,Arr] = contour3D(P,N,Src,Info_N,Info_P,Arr) ;
%
% Fonction de calcul d'un contour 3D pour un objet donné
%
function [C3D,Info_N,Info_P,Arr] = contour3D(P,N,Src,Info_N,Info_P,Arr) ;
% 
% 1. Gestion des données d'entrée
%
if nargin < 5 ;
    % ---> L'analyse des polygones n'a pas été réalisée
    [Info_P,P] = analyse_geometrie_polygones(P,N) ;
end
if nargin < 6 ;
    % ---> La définition des arretes n'a pas été entrée :
    Arr = analyse_arretes(P) ;
end
if nargin < 4 ;
    % ---> La définition des normales n'est pas donnée
    Info_N = calcul_normale_noeuds(N,P,Info_P) ;
end
%
% 2. Mise en place du calcul
%
NN = size(N,1) ; % Nombre de noeuds
NP = size(P,1) ; % Nombre de polygones
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
%
% c) Calcul des produits scalaires uiMi
%
VuN = sum(Vu.*Info_N.Normale,2) ; clear Vu ;
%
% 3. Calcul des points du contour 3D
%
% a) Arretes candidates
%
deltA = VuN(Arr.Definition(:,1)) ; deltB = VuN(Arr.Definition(:,2)) ;
Possibles = deltA .* deltB ;
C3D.Arr_ok = find(Possibles <= 0) ; clear Possibles ;
%
% b) Calcul des points du contours 3D 
%
warning off
C3D.Pts = ((deltB(C3D.Arr_ok) * [1,1,1]) .* N(Arr.Definition(C3D.Arr_ok,1),:) - ...
    (deltA(C3D.Arr_ok) * [1,1,1]) .* N(Arr.Definition(C3D.Arr_ok,2),:)) ...
    ./ ((deltB(C3D.Arr_ok) - deltA(C3D.Arr_ok)) * [1,1,1]) ;
warning on
%
% fin de la fonction