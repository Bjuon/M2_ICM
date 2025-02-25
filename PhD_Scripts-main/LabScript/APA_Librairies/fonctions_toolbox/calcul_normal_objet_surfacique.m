% ############################################################################################
%
% Fonction de calcul des barycentres, des surfaces et des normales aux polygones et des 
% normales en chacun des noeuds ...
%
% Normales = Calcul_normal_objet_surfacique(Noeuds,Polygones,Information) ;
%
% Normales.Barycentre  % Barycentre des polygones
% Normales.Surface     % Surfaces des polygones
% Normales.N_surface   % Normales aux polygones en G
% Normales.N_noeuds    % Normales aux noeuds
%
% ############################################################################################
%
function Normales = Calcul_normal_objet_surfacique(Noeuds,Polygones) ;
%
% ___ Initialisation des variables de sortie ___
%
Normales.Barycentre = zeros(size(Polygones,1),3) ; % Barycentre du polygone
Normales.Surface = zeros(size(Polygones,1),1) ;    % Surface du polygone
Normales.N_surface = zeros(size(Polygones,1),3) ;  % Normale au polygone en G
Normales.N_noeuds = zeros(size(Noeuds,1),3) ;      % Normale au noeud
%
% ___ Traitement de chacun des polygones ___
%
warning off % Suprrime les warning dus à des vecteurs de normes nulles
for t = 1:size(Polygones,1) ;
    %
    % 1) Extraction des Noeuds sommets du polygone n°t
    %
    listeN = Polygones(t,find(Polygones(t,:))) ;
    %
    % 2) Calcul du barycentre pour la surface 
    %
    Normales.Barycentre(t,:) = Barycentre(Noeuds(listeN,:)) ;
    %
    % ___ Suivant si on a affaire à un quadrangle ou à un triangle ___ 
    %
    switch length(listeN) ;
        %
    case 3 ; % Cas du triangle
        %
        % Normales non normée
        % 
        N1 = cross(Noeuds(listeN(3),:)-Noeuds(listeN(1),:),...
            Noeuds(listeN(2),:)-Noeuds(listeN(1),:)) ;
        %
        % 3) Surface du triangle
        %
        Normales.Surface(t,1) = norm(N1) ;
        %
        % 4) Normale du triangle
        %
        Normales.N_surface(t,:) = N1/norm(N1) ;
        %
        % 5) Normales aux sommets
        %
        for u = 1:3 ;
            % ---> Normale : normale pré + normale new
            Normales.N_noeuds(listeN(u),:) = Normales.N_noeuds(listeN(u),:) + ...
                Normales.N_surface(t,:) ;
        end
        %
    case 4 ; % Cas du quadrangle
        %
        % Création des vecteurs de calcul
        %
        AB = Noeuds(listeN(2),:)-Noeuds(listeN(1),:) ;
        BC = Noeuds(listeN(3),:)-Noeuds(listeN(2),:) ;
        CD = Noeuds(listeN(4),:)-Noeuds(listeN(3),:) ;
        DA = Noeuds(listeN(1),:)-Noeuds(listeN(4),:) ;
        %
        % Normales non normée
        % 
        N1 = 0.25 * (cross(AB,-DA) - cross(-AB,BC) - cross(-CD,DA) + cross(CD,-BC)) ;
        %
        % 3) Surface du quadrangle
        %
        Normales.Surface(t,1) = norm(N1) ;
        %
        % 4) Normale du triangle
        %
        Normales.N_surface(t,:) = N1/norm(N1) ;
        %
        % 5) Normales aux sommets
        % ---> Normale : normale pré + normale new
        Normales.N_noeuds(listeN(1),:) = Normales.N_noeuds(listeN(1),:) + ...
            norme_vecteur(cross(AB,-DA)) ; % Noeud 1
        Normales.N_noeuds(listeN(2),:) = Normales.N_noeuds(listeN(2),:) + ...
            norme_vecteur(cross(BC,-AB)) ; % Noeud 2
        Normales.N_noeuds(listeN(3),:) = Normales.N_noeuds(listeN(3),:) + ...
            norme_vecteur(cross(CD,-BC)) ; % Noeud 3
        Normales.N_noeuds(listeN(4),:) = Normales.N_noeuds(listeN(4),:) + ...
            norme_vecteur(cross(DA,-CD)) ; % Noeud 4        
    end
end
%
% ___ Normalisation des normales aux noeuds ___
%
Normales.N_noeuds = norme_vecteur(Normales.N_noeuds) ;
warning on ; % ---> fin de suppression des warnings
%
% Fin de la fonction