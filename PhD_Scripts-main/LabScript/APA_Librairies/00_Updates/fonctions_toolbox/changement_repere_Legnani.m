function Torseur_R2 = changement_repere_Legnani(Torseur_R1,MH_R1_R0,MH_R2_R0,TypeTorseur)

%%
% Fonctionne avec le formalisme des matrices homogènes
% TOUTES les matrices doivent avoir les mêmes DIMENSIONS

% Cette fonction peut être utilisée pour changer de référentiel
% - Coordonnées d'un point avec TypeTorseur='position'
% - Torseur cinématique avec TypeTorseur = 'cinematique'
% - Torseur d'actions mécaniques avec TypeTorseur = 'dynamique'
% - Torseur cinétique = 'cinetique'
% - Matrice de Pseudo_inertie avec TypeTorseur = 'pseudo-inertie'

% Variable(s) Entree(s)
% - Torseur_R1 : Matrice homogène du torseur dans R1
% - MH_R1_R0 : Matrice Homogène de position de R1 dans R0
% - MH_R2_R0 : Matrice Homogène de position de R2 dans R0
%
% Variable(s) Sortie(s)
% - Torseur_R2 : Torseur exprimé dans R2

%% Auteur(s)
%
% Auteurs : C. Sauret
% Date de création : 25-10-2011
% Créé dans le cadre de : Projet APSIC

%% Modif(s) :
%
% Auteurs : 
% Date :
% Notes :

%% Traitement

Torseur_R2=zeros(size(Torseur_R1));

switch TypeTorseur
    case 'vecteur'
        for k=1:size(Torseur_R1,3)
           MH_R1_R2 = inv(MH_R2_R0(:,:,k))*MH_R1_R0(:,:,k);
           Torseur_R2(:,1,k) = MH_R1_R2 * Torseur_R1(:,1,k);
        end
        
    case 'cinematique'
        for k=1:size(Torseur_R1,3)
            MH_R1_R2 = inv(MH_R2_R0(:,:,k))*MH_R1_R0(:,:,k);
            Torseur_R2(:,:,k) = MH_R1_R2 * Torseur_R1(:,:,k) * inv(MH_R1_R2);
        end
        
    case 'cinetique'
        for k=1:size(Torseur_R1,3)
            MH_R1_R2 = inv(MH_R2_R0(:,:,k))*MH_R1_R0(:,:,k);
            Torseur_R2(:,:,k) = MH_R1_R2 * Torseur_R1(:,:,k) * MH_R1_R2';
        end
        
    case 'dynamique'
        for k=1:size(Torseur_R1,3)
            MH_R1_R2 = inv(MH_R2_R0(:,:,k))*MH_R1_R0(:,:,k);
            Torseur_R2(:,:,k) = MH_R1_R2 * Torseur_R1(:,:,k) * MH_R1_R2';
        end
        
    case 'pseudo-inertie'
        for k=1:size(Torseur_R1,3)
            MH_R1_R2 = inv(MH_R2_R0(:,:,k))*MH_R1_R0(:,:,k);
            Torseur_R2(:,:,k) = MH_R1_R2 * Torseur_R1(:,:,k) * MH_R1_R2';
        end
        
    otherwise
        disp('TypeTorseur est inconnu')
end

