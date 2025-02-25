%
% Fonction de cr�ation de connections entre des arretes pour cr�er des contours
%
function B = creer_connections(A) ;
%
% 1) Initialisation des variables
% ---> Variable de sortie B :
B.coord = A.coord(1,:) ;
B.tri{1} = [ 1 ] ;
B.elem = [1] ;
B.Normale = A.Normale(1,:) ;
% ---> liste des arretes trait�es
liste = 1 ;
% ---> arrete courante
arrC = 1 ;
% ---> arrete finale
arrF = NaN ;
% ---> Num�ro du contour courant
Ncont = 1 ;
% ---> Num�ro du point courant
Npts = 1 ;
% ---> Liste des noeuds non utilis�
Tok = [1:length(A.Pol)] ;
npris = 1 ;
%
% 2) Recherche des connections
%
while 1 ;
    % disp([num2str(Npts),' / ',num2str(size(A.coord,1))]) ;
    % ---> recherche des polygones s'appuyant sur l'arrette
    PolyR = A.Pol(arrC,find(A.Pol(arrC,:) ~= 0)) ;
    % ---> recherche des arrettes limites des polygones trouv�s
    Garr = [] ;
    for t = 1:length(PolyR) ;
        [Temp,J] = find(A.Pol == PolyR(t)) ;
        Garr = [Garr;Temp] ;
    end
    clear J Temp ;
    Garr = unique(Garr) ;        % ---> Valeurs des arrettes trouv�es
    Garr = setdiff(Garr,liste) ; % ---> Recherche les arrettes non-trait�es
    % ---> Il faut traiter plusieurs cas 
    switch length(Garr) ;
    case 0 ; % ---> pas d'arretes : fin d'un contour
        % deux cas : fin d'un contour ou extr�mit� d'un contour
        if isnan(arrF)|(arrC == arrF) ;
            if arrC == arrF % cas d'un contour ferm�
                B.tri{Ncont} = [B.tri{Ncont},B.tri{Ncont}(1)] ; % bouclage du contour
            end
            Ncont = Ncont + 1 ;                   % nouveau num�ro de contour
            % ---> nouveau point de d�part
            Tok = setdiff([1:size(A.coord,1)],liste) ;
            if isempty(Tok)
                break % le contourage est termin�
            end            
            arrC = Tok(1) ;
            % ---> mise � jour de B
            arrF = NaN ;                          % nouvelle arrete de fin de contour
            B.tri{Ncont} = [] ;                   % point de d�part
        else
            % ---> Nous arrivons � une extr�mit� du contour ouvert : 
            %      mais il faut cheminier dans l'autre sens maintenant
            B.coord(B.tri{Ncont},:) = B.coord(B.tri{Ncont}(end:-1:1),:) ; % inversion du sens du contour
            B.Normale(B.tri{Ncont},:) = B.Normale(B.tri{Ncont}(end:-1:1),:) ; % inversion du sens du contour
            B.elem(B.tri{Ncont}) = B.elem(B.tri{Ncont}(end:-1:1)) ;       % inversion du sens du contour
            arrC = arrF ;                         % nouvelle arrete courante
            arrF = NaN ;                          % nouvelle arrete de fin de contour
        end    
    case 1 ; % ---> une seule arrete : cas normal de recherche 
        arrC = Garr ;                         % Nouvelle arrete courante
        npris = 1 ;                           % pour les cas particuliers
    case 2 ; % ---> deux arretes : Cas particuli� ou premier point d'un contour
        % d�termination du cas :
        if length(B.tri{Ncont}) == 1 ;
            % ---> Nous v�rifions que ce n'est pas le meme point
            if norm(A.coord(Garr(1),:) - A.coord(Garr(2),:)) < 1e-10 ;
                % nous recherchons alors un autre point de d�part
                npris = npris + 1 ;                   % recherche en avant d'une arrete correcte
                % ---> Si npris est plus grand que le nombre de points il n'existe qu'un point
                if npris > size(A.coord,1) ;
                    if norm(mean(A.coord) - A.coord(1,:)) < 1e-10 ;
                        B.coord = mean(A.coord) ;
                        B.Normale = mean(B.Normale) ;
                        B.elem = Garr(1) ;
                        B.tri{1} = [1] ;
                        return
                    else
                        error('Maillage mal d�fini : erreur 3') ;
                    end
                end
                arrC = Tok(npris) ;                   % pour d�finir une nouvelle arrete courante
                B.tri{Ncont} = [] ;                   % point de d�part
                B.coord = B.coord(1:end-1,:) ;        % nous retirons le point 
                B.Normale = B.Normale(1:end-1,:) ;
                B.elem = B.elem(1:end-1) ;
                Npts = Npts - 1 ;                     % ainsi que son n�
                liste = liste(1:end-1) ;              % et de la liste des points trait�s
            else  
                % ---> D�but d'un nouveau contour
                arrC = Garr(1) ;                      % Nouvelle arrete courante
                arrF = Garr(2) ;                      % arrete de fin du contour
            end
        else
            % ---> cas particulier : un sommet est ok
            if norm(A.coord(Garr(1),:) - A.coord(Garr(2),:)) < 1e-10 ;
                % coordonn�es du sommet d'int�ret
                L = A.coord(Garr(1),:) ; 
                % liste des arretes ayant ce noeuds comme point calcul�
                I = find(norm2(A.coord - ones(size(A.coord,1),1)*L) < 1e-10) ;
                % Recherche des polygones s'appuyant sur ces arretes
                J = unique(A.Pol(I,:)) ;
                [J,V] = find2(A.Pol,J,'==') ;
                J = unique(J) ;
                % arrete de sortie de l'ensemble des triangles
                J = setdiff(J,[I;arrC]) ;
                % Ajout des points et mise � jour du maillage
                % a) pour le sommet 
                liste = [liste,I'] ;                 % mise � jour de la liste
                Npts = Npts + 1 ;                    % nouveau num�ro de point
                B.coord = [B.coord;L] ;              % ajout du point � la liste des noeuds
                B.Normale = [B.Normale;A.Normale(Garr(1),:)] ;
                B.elem = [B.elem,Garr(1)] ;
                B.tri{Ncont} = [B.tri{Ncont},Npts] ; % cr�ation du contour
                % b) pour la nouvelle arrete
                arrC = J ;                            % nouvelle arrete courante
            else
                error('Maillage mal d�fini : erreur 1')
            end
        end
    case 3
        % ---> un triangle cas particulier a �t� choisi en premier triangle
        % choix d'un autre triangle ...
        if length(B.tri{Ncont}) ~= 1 ;
            error('Maillage mal d�fini : erreur 2') ;
        end
        npris = npris + 1 ;                   % recherche en avant d'une arrete correcte
        % ---> Si npris est plus grans que le nombre de points il n'existe qu'un point
        if npris > size(A.coord,1) ;
            if norm(mean(A.coord) - A.coord(1,:)) < 1e-10 ;
                B.coord = mean(A.coord) ;
                B.Normale = mean(A.Normale) ;
                B.elem = Garr(1) ;
                B.tri{1} = [1] ;
                return
            else
                error('Maillage mal d�fini : erreur 3') ;
            end
        end
        arrC = Tok(npris) ;                   % pour d�finir une nouvelle arrete courante
        B.tri{Ncont} = [] ;                   % point de d�part
        B.coord = B.coord(1:end-1,:) ;        % nous retirons le point 
        B.Normale = B.Normale(1:end-1,:) ;
        B.elem = B.elem(1:end-1) ;
        Npts = Npts - 1 ;                     % ainsi que son n�
        liste = liste(1:end-1) ;              % et de la liste des points trait�s
    otherwise
        error('Cas impossible : trop de triangles associ�s') ;
    end
    Npts = Npts + 1 ;                     % nouveau num�ro de point
    liste = [liste,arrC] ;                % mise � jour de la liste
    B.coord = [B.coord;A.coord(arrC,:)] ; % ajout du point � la liste des noeuds
    B.Normale = [B.Normale;A.Normale(arrC,:)] ;
    B.tri{Ncont} = [B.tri{Ncont},Npts] ;  % cr�ation du contour         
    B.elem = [B.elem,arrC] ;              % appartient � l'arrete courante.
end
%
% Fin de la fonction