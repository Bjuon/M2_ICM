%
% Cette fonction permet de calculer le rep�re de frenet associ� � des contours
%
function C1 = Calcul_repere_frenet(C1) ;
%
% 0. Gestion des donn�es d'entr*�e (traitement du cas d'un nuage de points seul)
%
if ~isfield(C1,'tri') ;
    % ---> On a affaire � un un nuage de point seul
    if min(C1(1,:) == C1(end,:)) == 1
        % ---> courbe ferm�e
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
% 1. Il faut traiter chacun des contours les uns � la suite des autres
%
for t = 1:length(C1.tri) ;
    %
    % ---> Extraction des points d'int�rets :
    %
    A = C1.coord(C1.tri{t},:) ;
    %
    % ---> Cr�ation de la matrice de calcul des vecteurs tangeant
    %
    [N,Dim] = size(A) ; % Nombre de points et dimension de l'espace :
    %
    % ---> 2 cas � traiter : courbe ferm�e , courbe ouverte
    %
    C = spdiags([ones(N,1),-ones(N,1)],[1,-1],N,N) ; % ---> Sparse matrice de base
    % ---> Traitement des cas
    if C1.tri{t}(1) == C1.tri{t}(end) ;
        % ---> Cas de la courbe ferm�e
        C(1,N) = -1 ; C(N,1) = 1 ;
    else
        % ---> Cas de la courbe ouverte
        C(1,1) = -1 ; C(N,N) = 1 ;
    end
    %
    % ---> Utilisation de la matrice :
    %
    Tang = C * A ; % ---> Attention matrice non-norm�
    %
    % ---> Norme des vecteurs calcul�s
    %
    NTang = norm2(Tang) ;
    %
    % ---> Cr�ation des vecteurs tangeants norm�s
    %
    for y = 1:Dim ;
        C1.tangent(C1.tri{t},y) = Tang(:,y)./NTang ;
    end
    %
    % ---> Calcul du vecteur normal (d�riv� de tangent par rapport � l'abscisse curviligne)
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
        % a) Cr�ation des sparces matrices suivant le type de courbe (ferm�e ou ouverte)
        %
        Mat1 = spdiags([ones(N,1),-ones(N,1)],[1,-1],N,N) ; 
        Mat2 = spdiags([ones(N,1),ones(N,1)],[1,-1],N,N) ; 
        %
        % ---> Traitement des cas
        %
        if C1.tri{t}(1) == C1.tri{t}(end) ;
            % ---> Cas de la courbe ferm�e
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
        % ---> Extraction de la sur-diagonale n�2
        %
        SDMPV = diag(MPV,2) ;
        %
        % ---> Traitement des types de courbes
        %
        if C1.tri{t}(1) == C1.tri{t}(end) ;
            % ---> Cas de la courbe ferm�e
            delta = [MPV(N,2);SDMPV;MPV(N-1,1)] ;
        else
            % ---> Cas de la courbe ouverte
            delta = [MPV(1,2);SDMPV;MPV(N-1,N)] ;
        end
        %
        % c) Cacul des rayon de courbure
        %
        warning off
        nn = Mat2*AA ; % Pour les vecteurs diff�rences des vecteurs normaux
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
        % Pas encore trait�
    end
end
%
% Fin de la fonction