%
% fonction d'affichage d'un objet suivant son type ...
%
function [h,haxe,tag] = Affiche_objet(Obj,haxe,tag,color);
%
% 1. Gestion des données d'entrées 
% a) pour l'axe d'affichage
if nargin < 2 ;
    % création d'un axe pour l'affichage de l'objet
    haxe = axes ; 
end
% b) pour le tag de l'objet
if nargin < 3 ;
    % définition d'un tag pour l'objet
    tag = 'objet' ;
end
% c) pour la couleur de l'objet
if nargin < 4
    color = [0,1,1] ; % cyan par défaut
end
%
% 2. Recherche du type d'objet 
%    On traite seulement 2 type d'objets :
%        - les objets contenant seulement des points (mes, ort, o3)
%        - les objets contenant aussi une définition de surface (wrml, mov)
%        - les objets mov et wrml avec Polygones vide
%
% Traitement des cas
%
if isfield(Obj,'Polygones') ;
    if ~isempty(Obj.Polygones) ;
        %
        % C'est le cas des objets de type movie ...
        %
        h = creer_objet_movie(Obj,'tag',{tag},'axe',haxe,'color',color) ;
        %
    else
        %
        % C'est un fichier de type movie mais sans définition de polygone (formta mes dans comp2001)
        %
        etat_axe = get(haxe,'visible') ; hold on ;
        axes(haxe) ; % on se place dans l'axe demandé
        h = plot3(Obj.Noeuds(:,1),Obj.Noeuds(:,2),Obj.Noeuds(:,3),'.','tag',tag,'color',color) ;
        set(haxe,'visible',etat_axe) ; hold off ;
    end
else
    %
    % C'est le cas des objets de type mesure
    %
    etat_axe = get(haxe,'visible') ; hold on ;
    axes(haxe) ; % on se place dans l'axe demandé
    h = plot3(Obj.coord(:,1),Obj.coord(:,2),Obj.coord(:,3),'.','tag',tag,'color',color) ;
    set(haxe,'visible',etat_axe) ; hold on ;
end
%
% Mise à l'échelle de l'axe :
%
axis equal ;
%
% fin de la fonction