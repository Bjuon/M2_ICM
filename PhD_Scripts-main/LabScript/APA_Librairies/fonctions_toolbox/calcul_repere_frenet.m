%
% Cette fonction permet de calculer le repère de frenet associé à des contours
%
function C1 = Calcul_repere_frenet(C1) ;
%
% 0. Gestion des données d'entr*ée (traitement du cas d'un nuage de points seul)
%
if ~isfield(C1,'tri') ;
    % ---> On a affaire à un un nuage de point seul
    if min(C1(1,:) == C1(end,:)) == 1
        % ---> courbe fermée
        C1_temp.tri = {[1:size(C1,1)-1,1]} ;
        C1_temp.coord = C1(1:end-1,:) ;
    else
        % ---> courbe ouverte
        C1_temp.tri = {[1:size(C1,1)]} ;
        C1_temp.coord = C1 ;
    end
    
    % --- copie de la courbe
    C1 = C1_temp ;
end
%
% 1. Il faut traiter chacun des contours les uns à la suite des autres
%
for t = 1:length(C1.tri) ;
    %
    % ---> Extraction des points d'intérets :
    %
    A = C1.coord(C1.tri{t},:) ;
    %
    % ---> Création de la matrice de calcul des vecteurs tangeant
    %
    [N,Dim] = size(A) ; % Nombre de points et dimension de l'espace :
    %
    % ---> 2 cas à traiter : courbe fermée , courbe ouverte
    %
    C = spdiags([ones(N,1),-ones(N,1)],[1,-1],N,N) ; % ---> Sparse matrice de base
    % ---> Traitement des cas
    if C1.tri{t}(1) == C1.tri{t}(end) ;
        % ---> Cas de la courbe fermée
        C(1,N) = -1 ; C(N,1) = 1 ;
    else
        % ---> Cas de la courbe ouverte
        C(1,1) = -1 ; C(N,N) = 1 ;
    end
    %
    % ---> Utilisation de la matrice :
    %
    Tang = C * A ; % ---> Attention matrice non-normé
    %
    % ---> Norme des vecteurs calculés
    %
    NTang = norm2(Tang) ;
    %
    % ---> Création des vecteurs tangeants normés
    %
    for y = 1:Dim ;
        C1.tangent(C1.tri{t},y) = Tang(:,y)./NTang ;
    end
    %
    % ---> Calcul du vecteur normal (dérivé de tangent par rapport à l'abscisse curviligne)
    %      et de la binormale dans le cas de la dimension 3
    %
    % 2 CAS : 2D ou 3D
    %
    if Dim == 2 ;
        % ---> Cas 2D
        C1.normal(C1.tri{t},:) = ([0,-1;1,0] * C1.tangent(C1.tri{t},:)')' ;
        %
        % ---> Calcul des rayons de courbure ...
        %
        % a) Création des sparces matrices suivant le type de courbe (fermée ou ouverte)
        %
        Mat1 = spdiags([ones(N,1),-ones(N,1)],[1,-1],N,N) ; 
        Mat2 = spdiags([ones(N,1),ones(N,1)],[1,-1],N,N) ; 
        %
        % ---> Traitement des cas
        %
        if C1.tri{t}(1) == C1.tri{t}(end) ;
            % ---> Cas de la courbe fermée
            Mat1(1,N) = -1 ; Mat1(N,1) = 1 ;
            Mat2(1,N) =  1 ; Mat2(N,1) = 1 ;
        else
            % ---> Cas de la courbe ouverte
            Mat1(1,1) = -1 ; Mat1(N,N) = 1 ;
            Mat2(1,1) =  1 ; Mat2(N,N) = 1 ;
        end
        %
        % b) Calcul des normes de produits vectoriel
        %
        AA = C1.normal(C1.tri{t},:) ; 
        BB = [-AA(:,2),AA(:,1)]' ;
        MPV = AA*BB ;
        %
        % ---> Extraction de la sur-diagonale n°2
        %
        SDMPV = diag(MPV,2) ;
        %
        % ---> Traitement des types de courbes
        %
        if C1.tri{t}(1) == C1.tri{t}(end) ;
            % ---> Cas de la courbe fermée
            delta = [MPV(N,2);SDMPV;MPV(N-1,1)] ;
        else
            % ---> Cas de la courbe ouverte
            delta = [MPV(1,2);SDMPV;MPV(N-1,N)] ;
        end
        %
        % c) Cacul des rayon de courbure
        %
        warning off
        nn = Mat2*AA ; % Pour les vecteurs différences des vecteurs normaux
        mm = Mat1*A  ; % Pour les vecteurs entre les points
        %
        % ---> Calcul des rayons
        %
        C1.Rayon_C(C1.tri{t},:) = 0.5 * ( nn(:,1).*mm(:,2) - nn(:,2).*mm(:,1) ) ./ delta ;
        %
        % ---> Calcul de la courbure
        %
        C1.Courbure(C1.tri{t},:) = 1./C1.Rayon_C(C1.tri{t},:) ;
        %
        % ---> Calcul du centre de courbure
        %
        C1.Centre_C(C1.tri{t},:) = C1.coord(C1.tri{t},:) + ...
            [C1.Rayon_C(C1.tri{t},:),C1.Rayon_C(C1.tri{t},:)].*C1.normal(C1.tri{t},:) ;
        warning on 
    else
        % ---> Cas 3D
        % Pas encore traité
    end
end
%
% Fin de la fonction