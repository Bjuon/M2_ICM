% [NRec,Transformation,Info] = recalage_quaternions(Ref,Rec) ;
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
% NRec : nouvelles coordonnées pour les points recalés
% Transformation : transformation de Rec vers Ref
%      .H : matrice homogène 
%      .T : translation des points de Rec vers Ref
%      .R : matrice de passage de Rec vers Ref
%      on tend vers : Transformation(Rec) = Ref
%                     R*Rec + T = Ref
% _____________________________________________________________________
%
function [NRec,Transformation] = recalage_quaternions(Ref,Rec) ;
%
% 0. Vérification de la compatibilité des données d'entrées
%
if size(Ref,1) ~= size(Rec,1) ;
    error('Les données d''entrées sont incompatible')
end
%
% 0. Initialisation
%
NRec = Rec ;
Transformation.T = [0,0,0] ;
Transformation.R = eye(3)  ;
Transformation.H = [eye(3),zeros(3,1);[0,0,0,1]] ;
%
% ---> Optimisation
%
while 1
    %
    % 1. Calcul des barycentres des nuages Ref et Rec
    %
    Barycentre_Ref = Barycentre(Ref) ;
    Barycentre_Rec = Barycentre(NRec) ;
    %
    % 2. Création des vecteurs points / barycentre
    %
    VRef = Ref - ones(size(Ref,1),1) * Barycentre_Ref ;
    VRec = NRec - ones(size(Rec,1),1) * Barycentre_Rec ;
    %
    % 3. Détermination de la transformation
    %
    % a) Changement de base :
    %
    Trans.R = changement_base_quaternion(VRef,VRec) ;
    %
    % b) Translation :
    %
    Trans.T = Barycentre_Ref - (Trans.R * Barycentre_Rec')' ;
    %
    % c) Matrice homogène
    %
    Trans.H = [Trans.R,Trans.T';zeros(1,3),1] ;
    %
    % 4. Calcul des nouveaux points
    %
    NRec = Trans.H * [NRec';ones(1,size(NRec,1))] ;
    NRec = NRec(1:3,:)' ;
    %
    % 5. Calcul de la transformation globale :
    %
    Transformation.T = Trans.T + (Trans.R * Transformation.T')' ;
    Transformation.R = Trans.R * Transformation.R ;
    %
    % 6. Sortie de boucle ;
    %
    if (abs(det(Trans.R)-1) < 1e-10) & (norm(Trans.T) < 1e-10) ;
        Transformation.H = [Transformation.R,Transformation.T';zeros(1,3),1] ;
        break
    end
end
%
% Fin de la fonction