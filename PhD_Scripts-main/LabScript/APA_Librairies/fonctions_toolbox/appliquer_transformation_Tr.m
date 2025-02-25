function C3D = appliquer_transformation_Tr(C2D,Tr) ;
%
% Fonction de transformation de données dans le plan
% en données 3D à partir d'une transformation Tr
%  Tr.M2D3D : matrice à appliquer pour les vecteurs 2D
%  Tr.C_ok  : relation coordonnées plans 3D
%

%
% 1. Calcul de la dimension manquante
%
Zm = [C2D,ones(size(C2D,1),1)] * Tr.rXYZp ;
%
% 2. Remplissage de la ligne manquante
%
cmpt = 1 ;
for t = 1:3 ;
    if max(Tr.C_ok == t) == 1 ;
        % ---> Cette coordonnée est à conserver
        C3D(:,t) = C2D(:,cmpt) ;
        cmpt = cmpt + 1 ; % Incrémentation du compteur de coord de C2D ;
    else
        % ---> Cette coordonnée est nulle
        C3D(:,t) = Zm ;
    end
end
%
% 3. Utilisation de la matrice de changement de base
%
C3D = (Tr.M2D3D * C3D')' ;
%
% Fin de la fonction