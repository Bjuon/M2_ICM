%
% Calcul d'un contour 3D associ� � un objet de type movie dans un environnement donn�
%
function [Contours,Mov] = Contour3DP(Mov,E) ;
%
% ###################################################################
% 0. On v�rifie que l'objet Movie contient bien un champ .Normale 
% ###################################################################
%
if ~isfield(Mov,'Normale') ;
    %
    % On doit cr�er le champ normale
    %
    Mov = extraction_normales_movie(Mov) ;
end
%
% ####################################################################################
% 1. Calcul des produits vectoriels entre la normale en chaque point de l'objet et
%    la direction du rayon x en ce point
% ####################################################################################
%
% 1.1. Association d'une source pour chacun des Noeuds de l'objet
%
Mat_S = Association_source_Rcal(Mov.Noeuds,E) ;
% 
% 1.2. Cr�ation du vecteur unitaire de direction Source X Noeuds de l'objet
%
V_x = norme_vecteur(Mov.Noeuds - Mat_S) ; 
%
% 1.3. Calcul des produits scalaires entre les 2 vecteurs normaux
%
Scalaire = dot(Mov.Normale,V_x,2) ;
%
% ####################################################################################
% 2. Traitement de chaque �l�ment pour la recherche des tangence
% ####################################################################################
%
% 2.1. Initialisation de Variables
%
cmpt_u = 1 ; % Compteur de points sur le contour 3D
%
% 2.2. Scan de chacun des �l�ments
%
for yyy = 1:Mov.N_Pol
    %
    % 2.2.1. R�cup�ration des valeurs des produits scalaires en chacun des noeuds de l'�l�ment
    %       
    % a) D�finition num�rique du polygone
    %
    quels = find(Mov.Polygones(yyy,:)) ; % Noeuds appartenants r�ellement � l'�l�ment
    def_num = Mov.Polygones(yyy,quels);  % definition num�rique du Polygone
    %
    % b) R�cup�ration des valeurs du produit scalaire en chacun des points du polygone
    %
    val_scal = Scalaire(def_num) ; 
    %
    % 2.2.2. Recherche de changement de signe pour ce produit scalaire sur l'�l�ment
    %
    [msi,quels] = issamesign(val_scal) ;
    %
    % 2.2.3. Surface tangente si produits scalaires de signes diff�rents ...
    %
    if msi == 0 ; % Si les signes sont diff�rents ---> TRAITEMENTS
        %
        % a) Recherche de la dimension du polygone (3: triangle, 4: quadrangle)
        %
        nnoeuds = length(def_num) ; % nombre de noeuds d�finissants le polygone
        %
        % b) Traitements de 2 cas : triangle ou quadrangle
        %
        if nnoeuds == 3 ;
            groupes = [1,2;2,3;3,1] ;     % arr�tes pour le triangle
        elseif nnoeuds == 4 ;
            groupes = [1,2;2,3;3,4;4,1] ; % arr�tes pour le quadrangle
        end
        %      
        % c) Calcul des 2 points du contour 3D
        %
        for ttt = 1:size(groupes,1) ;
            %
            % Vecteur des num�ros de noeuds de la ttti�me arr�te
            %
            v = [groupes(ttt,1),groupes(ttt,2)] ;
            %
            % Il faut r�p�rer les deux bonnes arr�tes
            %
            if val_scal(v(1))*val_scal(v(2)) <= 0 ;
                %
                % Calcul du point et sauvegarde du polygone
                %
                C3D.Noeuds(cmpt_u,:) = Barycentre(Mov.Noeuds(def_num(v),:),(1./abs(val_scal(v)))) ;
                quel(cmpt_u,1) = yyy ;
                cmpt_u = cmpt_u + 1 ;
            end
        end
    end
end
%
% ######################################################################
% 3. Cr�ation des contours Tri des points pr�c�dants calcul�s
% ######################################################################
%
% a) Recherche des points doubles (Memes coordonn�es ...)
%
Mq = distance_points(C3D.Noeuds) + eye(length(C3D.Noeuds)) ;
[J,I] = find(Mq == 0) ; % sauvegarde des doublons
%
% b) Initialisation de variables
%
N = cmpt_u - 1 ;         % ---> nombre de points calcul�s
liste = [1:N] ;          % ---> liste contenant les num�ros possibles de chaque point
Contours.coord = [] ;    % ---> initialisation de la variable de sortie
Contours.elem = [] ;     % ---> pour la sauvegarde des �l�ments d'appartenace
pt_actuel = 1 ;          % ---> on se place au point 1 pour commencer
cmpt_ct = 1;             % ---> Compteur de contours
%
% c) Cr�ation des contours 3D
%
while 1 ; % tant qu'il y a des points ....
    %
    % c.1. D�finition du point de d�part du nouveau contour � partir du contour 2
    %
    if cmpt_ct > 1 ; 
        x = find(liste) ;             % ---> Recherche les points non encore trait�s
        if ~ isempty(x)
            pt_actuel = liste(x(1)) ; % ---> Choisit celui de tag num�rique le plus petit
        else
            break                     % ---> si il n'y a plus de point on a fini de reconstruire les contours
        end
    end
    %
    % c.2. Initialisation des variables pour le contours en cours de traitement
    %
    Post = [] ; % ---> Coordonn�es des points situ�s en avant du point initial
    Pre = [] ;  % ---> Coordonn�es des points situ�s en arri�re du point initial
    Post_Elem = [] ; Pre_Elem = [] ; % ---> Elements d'appartenance
    pt_init = pt_actuel ; % ---> point initial de notre recherche de contours
    %
    % c.3. Traitement des points en avant du point initial
    %
    cmpt = 1 ;  % ---> Compteur de point dans Post
    %
    % ---> Le point actuel
    %
    Post(cmpt,:) = C3D.Noeuds(pt_actuel,:) ; % ---> Sauvegarde des coordonn�es
    Post_Elem(cmpt,1) = quel(pt_actuel,1)  ; % ---> Sauvegarde de l'�l�ment associ�
    liste(pt_actuel) = 0 ;                   % ---> Notification d'utilisation du point
    cmpt = cmpt + 1 ;  
    %
    % ---> Tant qu'il existe des points en avant du point initial
    %
    while 1 ;   
        %
        % ---> Recherche du point appartenant au meme �lement
        %
        pt_temp = find(quel == quel(pt_actuel,1)) ;       % ---> Recherche les points pour l'�l�ment
        pt_actuel = pt_temp(find(pt_temp ~= pt_actuel)) ; % ---> Extrait celui qui n'est pas l'actuel
        %
        % ---> Traitement de ce point
        %
        Post(cmpt,:) = C3D.Noeuds(pt_actuel,:) ; % ---> Sauvegarde des coordonn�es
        Post_Elem(cmpt,1) = quel(pt_actuel,1)  ; % ---> Sauvegarde de l'�l�ment associ�
        liste(pt_actuel) = 0 ;                   % ---> Notification d'utilisation du point
        cmpt = cmpt + 1 ;  
        %
        % ---> Recherche du point de meme coordonnees n'appartenant pas au meme �lement
        %
        if ~isempty(find(I == pt_actuel)) ;        % ---> Recherche de l'existance d'un doublon
            pt_actuel = J(find(I == pt_actuel)) ;  % ---> R�cup�ration des informations li�es � ce doublon
            pt_actuel = pt_actuel(1) ;
            if isempty(find(liste == pt_actuel)) ; % ---> V�rification que ce doublon n'a pas �t� trait�
                break ;                            %
            end                                    % ---> Sinon sortie
            liste(pt_actuel) = 0 ;                 % ---> Notification d'utilisation du point
        else                                       %
            break ;                                %
        end
    end
    %
    % c.4. Recherche d'un point de memes coordonnees que le point initial ---> Recherche arri�re ...
    %
    if ~isempty(find(I == pt_init)) ;          % ---> Recherche de l'existance d'un doublon
        pt_actuel = J(find(I == pt_init)) ;    % ---> R�cup�ration des informations li�es � ce doublon
        arr_rech = 1 ;                         %
        pt_actuel = pt_actuel(1) ;
        if isempty(find(liste == pt_actuel)) ; % ---> V�rification que ce doublon n'a pas �t� trait�
            arr_rech = 0 ;                     %
        end                                    % ---> Sinon pas de recherche en arri�re
        liste(pt_actuel) = 0 ;                 % ---> Notification d'utilisation du point
    else                                       %
        arr_rech = 0 ;                         %
    end
    %
    % c.5. Traitement des points en arri�re du point initial
    %
    cmpt = 1 ;  % ---> Compteur de point dans Pre
    Pre = [] ;
    %
    % ---> Recherche jusqu'� la fin du contour en avant
    %
    while arr_rech ;
        %
        % ---> Recherche du point appartenant au meme �lement
        %
        pt_temp = find(quel == quel(pt_actuel,1)) ;       % ---> Recherche les points pour l'�l�ment
        pt_actuel = pt_temp(find(pt_temp ~= pt_actuel)) ; % ---> Extrait celui qui n'est pas l'actuel
        %
        % ---> Traitement de ce point
        %
        Pre(cmpt,:) = C3D.Noeuds(pt_actuel,:) ; % ---> Sauvegarde des coordonn�es
        Pre_Elem(cmpt,1) = quel(pt_actuel,1)  ; % ---> Sauvegarde de l'�l�ment associ�
        liste(pt_actuel) = 0 ;                  % ---> Notification d'utilisation du point
        cmpt = cmpt + 1 ;  
        %
        % ---> Recherche du point de meme coordonnees n'appartenant pas au meme �lement
        %
        if ~isempty(find(I == pt_actuel)) ;        % ---> Recherche de l'existance d'un doublon
            pt_actuel = J(find(I == pt_actuel)) ;  % ---> R�cup�ration des informations li�es � ce doublon
            pt_actuel = pt_actuel(1) ;
            if isempty(find(liste == pt_actuel)) ; % ---> V�rification que ce doublon n'a pas �t� trait�
                break ;                            %
            end                                    % ---> Sinon sortie
            liste(pt_actuel) = 0 ;                 % ---> Notification d'utilisation du point
        else                                       %
            break ;                                %
        end
    end
    %
    % ---> Inversion de l'ordre des points pour Pre
    %
    Pre = Pre([cmpt-1:-1:1],:) ; Pre_Elem = Pre_Elem([cmpt-1:-1:1],:) ;
    %
    % d) Ecriture de la variable contour
    %
    % d.1. Contour cmpt_ct : du point au point :
    %
    Contours.tri{cmpt_ct} = [size(Contours.coord,1)+1:...
            size(Contours.coord,1)+size(Pre,1)+size(Post,1)] ;
    %
    % d.2. Sauvegarde des coordonn�es
    %
    Contours.coord = [Contours.coord;Pre;Post] ;
    Contours.elem = [Contours.elem;Pre_Elem;Post_Elem] ;
    %
    cmpt_ct = cmpt_ct + 1 ; % ---> Pour le nouveau contour
end
%
% FIN DE LA FONCTION