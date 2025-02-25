% NRec = recalage_elastique_3D(Ref,Rec) ;
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
function [NRec,Transformation] = recalage_elastique_3D(Ref,Rec) ;
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
    % A) Construction de la matrice de calcul de la déformation :
    % 
    % ---> Pré-calcul
    RecS = sum(NRec,1) ; % Somme des xi, yi et des zi Matrice 1x3 pour Rec
    Rec2 = NRec' * NRec ; % Matrice des sommes des produits des coordonnées de Rec
    Z33 = zeros(3,3) ; Z13 = zeros(1,3) ; I3 = eye(3) ;
    % ---> Montage de la matrice M
    % 1. Matrice U
    U = [[RecS;Z13;Z13],[Z13;RecS;Z13],[Z13;Z13;RecS]] ;
    % 2. Matrice V
    V = [[Rec2;Z33;Z33],[Z33;Rec2;Z33],[Z33;Z33;Rec2]] ;
    % 3. Matrice M
    M = [[V,U'];[U,I3]] ;
    % ---> Vecteur cible
    RefS = sum(Ref,1)' ; % Somme des xio, yio et zio
    RecRef = NRec'*Ref ; % Matrice des produits xixio ...
    B = [reshape(RecRef,[9,1]);RefS] ;
    %
    % B) Calcul de la transformation 
    %
    Soluce = inv(M)*B ;
    % ---> Mise en forme de la transformation
    Trans.T = Soluce(10:12)' ;
    Trans.R = reshape(Soluce(1:9),[3,3])' ;
    %
    % C) Calcul des nouveaux points et de la transformation géométrique
    %
    NRec = ones(size(NRec,1),1)*Trans.T + (Trans.R * NRec')' ; % Pour les nouveaux points
    Transformation.T = Trans.T + (Trans.R * Transformation.T')' ;
    Transformation.R = Trans.R * Transformation.R ;
    %
    % D) Pour la sortie de la boucle on recherche des modifications
    %    des termes inférieures à 1e-2
    %
    if (max(max(Trans.R - eye(3))) < 1.0e-2) ;
        break
    end    
end
%
% Fin de la fonction