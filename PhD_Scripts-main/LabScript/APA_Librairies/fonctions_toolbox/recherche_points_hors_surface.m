%
% Cette fonction permet de rechercher les Noeuds qui sont effectivement sur la surface du movie
% i.e. qui appartiennent à la définition de la surface
%
function [liste,surface] = recherche_points_hors_surface(Obj) ;
%
% A. Extraction des noeuds de la surface
%
surf_liste = liste_valeurs(Obj.Polygones) ;
surf_liste = surf_liste(find(surf_liste)) ;
%
% B. Recherche des points n'apparaissant pas dans 
%
cmpt = 0 ;            % compteur de points hors surface
cmpt_surf = 0 ;       % compteur des points de la surface
liste = [] ;          % initialisation de la liste
surface = [] ;        % initialisation des points appartenant à la surface
for t = 1:Obj.N_Pts ;
    if isempty(find(surf_liste == t)) ;
        %
        % Le point n'appartient pas à la surface
        %
        cmpt = cmpt + 1 ;
        liste(cmpt) = t ;
    else
        %
        % Le point appartient à la surface
        %
        cmpt_surf = cmpt_surf + 1 ;
        surface(cmpt_surf) = t ;
    end
end
%
% fin de la fonction