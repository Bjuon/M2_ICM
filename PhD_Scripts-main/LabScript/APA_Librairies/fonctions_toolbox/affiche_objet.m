%
% fonction d'affichage d'un objet suivant son type ...
%
function [h,haxe,tag] = Affiche_objet(Obj,haxe,tag,color);
%
% 1. Gestion des donn�es d'entr�es 
% a) pour l'axe d'affichage
if nargin < 2 ;
    % cr�ation d'un axe pour l'affichage de l'objet
    haxe = axes ; 
end
% b) pour le tag de l'objet
if nargin < 3 ;
    % d�finition d'un tag pour l'objet
    tag = 'objet' ;
end
% c) pour la couleur de l'objet
if nargin < 4
    color = [0,1,1] ; % cyan par d�faut
end
%
% 2. Recherche du type d'objet 
%    On traite seulement 2 type d'objets :
%        - les objets contenant seulement des points (mes, ort, o3)
%        - les objets contenant aussi une d�finition de surface (wrml, mov)
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
        % C'est un fichier de type movie mais sans d�finition de polygone (formta mes dans comp2001)
        %
        etat_axe = get(haxe,'visible') ; hold on ;
        axes(haxe) ; % on se place dans l'axe demand�
        h = plot3(Obj.Noeuds(:,1),Obj.Noeuds(:,2),Obj.Noeuds(:,3),'.','tag',tag,'color',color) ;
        set(haxe,'visible',etat_axe) ; hold off ;
    end
else
    %
    % C'est le cas des objets de type mesure
    %
    etat_axe = get(haxe,'visible') ; hold on ;
    axes(haxe) ; % on se place dans l'axe demand�
    h = plot3(Obj.coord(:,1),Obj.coord(:,2),Obj.coord(:,3),'.','tag',tag,'color',color) ;
    set(haxe,'visible',etat_axe) ; hold on ;
end
%
% Mise � l'�chelle de l'axe :
%
axis equal ;
%
% fin de la fonction