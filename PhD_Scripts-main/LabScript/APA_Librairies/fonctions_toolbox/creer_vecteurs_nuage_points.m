% Fonction : [V_points,Origines] = creer_vecteurs_nuage_points(Points)
% ________________________________________________________________
%
% Cette fonction crée toius les vecteurs possible entre les points
% d'un nuage de points
% ________________________________________________________________
%
function [V_points,Origines] = creer_vecteurs_nuage_points(Points) ;
%
% 1. Récupération du nombre de Points du nuage
%
N = size(Points,1) ;
%
% 2. Création de sparses matrices pour le calcul :
%
SP_vecteurs = sparse([]) ;                 % Initialisation de la matrice vecteurs
SP_origines = sparse([]) ; % et de la matrice des origines
for t = 1:N-1 ;
    %
    % Définition de la sous matrice pour les vecteurs et les origines
    %
    Temp_S = spdiags(-ones(N,1),t,N-t,N) ;
    Temp_S(:,t) = 1 ;
    %
    Temp_O = sparse(N-t,N) ; 
    Temp_O(:,t) = 1 ;
    % 
    % Montage de SP_vecteurs
    %
    SP_vecteurs = [SP_vecteurs ; Temp_S] ;
    %
    % Montage de SP_origines :
    %
    SP_origines = [SP_origines;Temp_O] ;
end
%
% 3. Calcul de V_points et Origines :
%
V_points = SP_vecteurs * Points ;
Origines = SP_origines * Points ;
%
% Fin de la fonction ;