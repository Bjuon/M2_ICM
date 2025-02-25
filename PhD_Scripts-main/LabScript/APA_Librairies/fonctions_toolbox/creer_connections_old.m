function Cnt = creer_connections(C3D) ;
% ---> Initialisation des variables
N = size(C3D,1) ;
liste_pts = [[1:N]',[1:N]'] ;
% ---> Mise en forme
C3D = reshape(C3D',3,2*N)' ;
liste_pts = reshape(liste_pts',2*N,1) ;
% ---> Tri par ordre croissant des coordonnées X
[C3D,ordre] = sortrows(C3D) ;
liste_pts = liste_pts(ordre) ;
% ---> Recherche des "coordonnées" pour chacun des points uniques
[C3D2,I,J] = unique(C3D,'rows') ;
type = diff([0;find(diff(J));length(C3D)]) ;
% ---> Mise en forme des variables
for t = min(type):max(type) ;
    qui = find(type == t) ; % Recherche des points du type courant
    if ~isempty(qui) ;      % Traitement si et seulement si qui n'est pas vide
        % ---> mise en forme
        localisation = I(qui) ;
        for y = 1:t-1 ;
            localisation = [localisation;localisation-y] ;
        end
        localisation = sort(localisation) ;
        % ---> Tableau des coordonnées
        Coordinates(qui,1:t) = reshape(liste_pts(localisation),t,length(I(qui)/t))' ;
    end
end
clear C3D ;
% ---> Création des contours : Initialisation
N_cnt = 1 ;                     % Numéro du contour courant
cmpt =  1 ;                     % Numéro de point courant 
n_pt_cnt = 1 ;                  % Numéro du point dans le contour
Cnt.coord = C3D2(1,:) ;         % Premier point du contour
Cnt.tri{1} = [1] ;              % Pour la définition du contour
Debut.Num = Coordinates(1,1) ;  % Point de départ de la recherche
Debut.Loc = [1,1] ;             
Actu.Num = Coordinates(1,2) ;   % Point actuel de la recherche des contours
Actu.Loc = [1,2] ;              
Liste = 1 ;                     % Liste des points déjà traités
% ---> Création des contours : Boucle de création
while 1 ;
    % ---> Vérification : Actu différent de 0
    if Actu.Num ~= 0 ;
        % ---> Nous continuons la recherche
        [I,J] = find(Coordinates == Actu.Num) ; % Où trouve-t-on cette coordonnée 
        u = find(I ~= Actu.Loc(1)) ;            % et qui n'est pas le noeud courant
        I = I(u(1)) ; J = J(u(1)) ;             % ---> Devient le point actuel
        if I == Debut.Loc(1) ;
            % # Nous avons maintenant fait une boucle complète #
            % ---> Signalisons le bouclage du contour
            Cnt.tri{N_cnt} = [Cnt.tri{N_cnt},min(Cnt.tri{N_cnt})] ;
            if cmpt == size(C3D2,1) ; 
                % ---> Il n'y a plus de points
                break
            end
            % ---> Recherche d'un nouveau point
            qui = setdiff([1:size(C3D2,1)],Liste) ;
            qui = qui(1) ;
            % ---> Définition des nouvelles variables de travail
            cmpt = cmpt + 1 ;                     % Compteur de points traités
            N_cnt = N_cnt + 1 ;                   % Numéro du contour courant
            n_pt_cnt = n_pt_cnt + 1 ;             % Numéro du point dans le contour
            Cnt.coord = [Cnt.coord;C3D2(qui,:)] ; % Premier point du contour
            Cnt.tri{N_cnt} = [n_pt_cnt] ;         % Pour la définition du contour
            Debut.Num = Coordinates(qui,1) ;      % Point de départ de la recherche
            Debut.Loc = [qui,1] ;             
            Actu.Num = Coordinates(qui,2) ;       % Point actuel de la recherche des contours
            Actu.Loc = [qui,2] ;              
            Liste = [Liste;qui] ;                  % Liste des points déjà traités
        else
            % # Nous continuons à parcourir le contour #
            cmpt = cmpt + 1 ;                       % Nombre de points traités
            n_pt_cnt = n_pt_cnt + 1 ;               % Numéro du noeud dans le contour
            Cnt.coord = [Cnt.coord;C3D2(I,:)] ;     % ---> Ajout du point
            Cnt.tri{N_cnt} = [Cnt.tri{N_cnt},n_pt_cnt] ;
            Actu.Num = Coordinates(I,mod(J,2)+1) ;  % Nouveau noeud courant
            Actu.Loc = [I,mod(J,2)+1] ;             % Nouvelles coordonnées courantes
            Liste = [Liste;I] ;                     % liste des points traités
        end
    else
        % ---> Nous arrivons à une extrémité de contour ouvert
        if Debut.Num == 0 ;
            % ---> Nous sommes arrivé au bout d'un contour ouvert
            if cmpt == size(C3D2,1) ; 
                % ---> Il n'y a plus de points
                break
            end
            % ---> Recherche d'un nouveau point
            qui = setdiff([1:size(C3D2,1)],Liste) ;
            qui = qui(1) ;
            % ---> Définition des nouvelles variables de travail
            cmpt = cmpt + 1 ;                     % Compteur de points traités
            N_cnt = N_cnt + 1 ;                   % Numéro du contour courant
            n_pt_cnt = n_pt_cnt + 1 ;             % Numéro du point dans le contour
            Cnt.coord = [Cnt.coord;C3D2(qui,:)] ; % Premier point du contour
            Cnt.tri{N_cnt} = [n_pt_cnt] ;         % Pour la définition du contour
            Debut.Num = Coordinates(qui,1) ;      % Point de départ de la recherche
            Debut.Loc = [qui,1] ;             
            Actu.Num = Coordinates(qui,2) ;       % Point actuel de la recherche des contours
            Actu.Loc = [qui,2] ;              
            Liste = [Liste;qui] ;                  % Liste des points déjà traités            
        else
            % ---> Nous cherchons à terminer le contour :
            % 1) Inversons le contour courant :
            Cnt.coord(Cnt.tri{N_cnt},:) = Cnt.coord([Cnt.tri{N_cnt}(end):-1:Cnt.tri{N_cnt}(1)],:) ;
            % 2) Le point courant est le point début
            Actu.Num = Debut.Num ;
            Temp = Actu.Loc ;
            Actu.Loc = Debut.Loc ;
            % 3) Le dernier point est défini comme le point en I J
            Debut.Num = 0 ;
            Debut.Loc = Temp ;
            clear Temp ;
        end
    end
end
% 
% Fin de la fonction