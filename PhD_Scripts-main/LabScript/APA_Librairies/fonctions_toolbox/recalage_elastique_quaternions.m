% NRec = recalage_elastique_quaternions(Ref,Rec) ;
% _____________________________________________________________________
%
% Fonction de recalage de 2 nuages d'au moins 3 points par l'algèbre
% des quaternions ...
%
% Entrées : 
% Ref : nuage de points de référence
% Rec : nuage de points à recaler
%
% Sorties :
% NRec : nouvelles coordonnées pour les points transformés
% Transformation : transformation de Rec vers Ref
%      .T : translation des points de Rec vers Ref
%      .R : matrice de passage de Rec vers Ref
% _____________________________________________________________________
%
function [NRec,Transformation] = recalage_elastique_quaternions(Ref,Rec) ;
%
% 1. C'est un recalage en 2 temps :
%   
%    - le recalage de type quaternions translation + changement de base orthonormée
%    - calcul d'un coefficient homotétique pour modifier la taille global de Rec
%
% ----> Initialisation des variables
%
NRec = Rec ; % Pour la boucle d'optimisation 
cmpt = 1  ; % Compteur de boucle
Transformation.T = [0,0,0] ;  % Initialisation de la translation
Transformation.R = eye(3)  ;  % Initialisation du changement de base
kp = 1 ;                      % Coefficient d'homothétie
%
% ----> Boucles d'optimisation
%
while 1
    %
    % ---> Affichage des pas de calcul
    %
    % disp(['Pas n° : ',num2str(cmpt)]) ;
    % cmpt = cmpt + 1 ;
    %
    % A) Calcul de la transformation rigide :
    %
    [NRec,Trans] = recalage_quaternions(Ref,NRec) ;
    %
    % B) Calcul du coefficient homotétique
    %
    k = Calcul_rapport_homotetique(Ref,NRec) ;
    %
    % C) Calcul des nouveaux points et de la transformation géométrique
    %
    BNRec = ones(length(NRec),1) * barycentre(NRec) ;
    N2Rec = BNRec + k*(NRec - BNRec) ;             % Pour les nouveaux points
    % ---> Calcul de la transformation globale équivalente
    Trans.T = k * Trans.T + (1 - k) * barycentre(NRec) ; % pour la translation
    Trans.R = k * Trans.R ;                              % pour la rotation
    NRec = N2Rec ;
    % ---> Calcul de la transformation globale ...
    Transformation.T = Trans.T + (Trans.R * Transformation.T')' ;
    Transformation.R = Trans.R * Transformation.R ;
    %
    % D) Pour la sortie de la boucle on recherche des modifications
    %    des termes inférieures à 1e-10 (limite du calcul de matlab)
    %
    if (k - 1 < 1.0e-10) & ...
            (max(max(Trans.R - eye(3))) < 1.0e-10) & ...
            (norm(Trans.T) < 1.0e-10) ;
        break
    end  
end
%
% Fin de la fonction