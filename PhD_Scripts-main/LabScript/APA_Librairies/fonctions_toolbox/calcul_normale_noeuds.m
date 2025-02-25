% function [Info_Noeuds,Info_Polygones,Polygones] = Calcul_normale_noeuds(Noeuds,Polygones,Info_Polygones) ;
% 
% Fonction permettant de calculer les normales aux noeuds pour chacun des noeuds et
% rattachant un noeuds à tous les polygones dont il est sommet
%
function [InfoN,Info,P] = Calcul_normale_noeuds(N,P,Info,test) ;
%
% 1. Gestion des différentes variables d'entrée
% ---> Dans le cas où les info sur les surfaces ne sont pas spécifiées
%
if nargin == 2 ;
    % ---> Calcul des infos pour les polygones & triangularisation
    [Info,P] = analyse_geometrie_polygones(P,N) ;
end
%
% 2. Recherche l'appartenance d'un noeud à un triangle
%
Liste_poly = reshape(([1:size(P,1)]' * [1,1,1])',3*size(P,1),1) ; % Liste des triangles
Liste_Noeuds = reshape(P',3*size(P,1),1) ;                        %    Liste des noeuds
[Liste_Noeuds,ordre] = sortrows(Liste_Noeuds) ; %       Classement des noeuds par ordre
Liste_poly = Liste_poly(ordre) ;                %  Réarrangement des polygones associés
% ---> Recherche des noeuds appartenenant réellement à la surface 
[InfoN.Liste_surface,qui] = intersect(Liste_Noeuds,[1:size(N,1)]) ;
Poly_depart = [1;qui(1:end-1)'+1] ;      % Numéro de départ dans la liste des polygones
N_Polys = qui' - Poly_depart ;                % Nombres de polygones associés par noeud
InfoN.Appartient = cell(size(N,1),1) ; % Initialisation de la matrice des appartenances
InfoN.Normale = zeros(size(N,1),3) ;        % Initialisation de la matrice des normales
% ---> Remplissage de cette matrice :
for t = min(N_Polys):max(N_Polys) ;
    liste1 = find(N_Polys == t) ; % Recherche des noeuds s'appuyant sur t + 1 polygones
    if ~isempty(liste1) ;
        % U = Poly_depart(InfoN.Liste_surface(liste1)) ;   % Récupération du premier polygone
        U = Poly_depart(liste1) ;   % Récupération du premier polygone
        % ---> Construction des listes de polygones pour les noeuds donnés :
        Mat = U ;
        for y =1:t ;
            Mat = [Mat,U+y] ;
        end
        C = Liste_poly(reshape(Mat',1,(t+1)*length(liste1))) ;
        Mat = reshape(C',t+1,length(liste1))' ;
        % ---> Sauvegarde au format de liste
        InfoN.Appartient(InfoN.Liste_surface(liste1),1) = num2cell(Mat,2) ; % n° des polygones adjacents
        InfoN.Nb_Polygones(InfoN.Liste_surface(liste1),1) = t + 1 ;         % nombre de polygones adjacent
        % ---> Calcul de la normale en chacun des noeuds
        D = reshape(((Info.Surface(C)*[1,1,1]).*Info.Normale(C,:))',3,t+1,length(liste1)) ;              %  ---> Mise en forme
        D = sum(D,2) / (t+1) ;                                              % Calcul des moyennes
        InfoN.Normale(InfoN.Liste_surface(liste1),:) = ...
            reshape(D,3,length(liste1))' ;                                  % Variables de sortie
    end
end
% ---> Nous normons les vecteurs
warning off ;
InfoN.Normale = InfoN.Normale ./ (norm2(InfoN.Normale) * [1,1,1]) ;
warning on ;
%
% ___ Fin de la fonction ___