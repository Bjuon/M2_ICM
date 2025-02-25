function [N,P] = lambdaNuSmoothing(N,P,varargin) ;
% __________________________________________________________
%
% Fonction de lissage d'objets surfaciques triangulés
% (D'après l'article de Taubin - EUROGRAPHICS'2000)
% __________________________________________________________
%

%
% #########################################
% ### 0. Gestion des données d'entrée : ###
% #########################################
% ----------------------------------
% a) Initialisation de variables :
% ----------------------------------
% ---> Paramètres du filtre lambda Nu et kpb
lambda = .6307 ; nu = - .6732 ; kpb = 1/lambda + 1/nu ;
% ---> Nombre d'itérations de lissage
iterations = 50 ;
% ---> liste des points immuables : i.e. non déplacé par l'algorithme
immuable = [] ; % Les points sont tous déplacés
NImmuabale = [] ;
% ---> Nombre de subdivisions
subdivision = 0 ; % Pas de subdivision dans le cas général
% ---> Poids pour les arretes
poids = 'unit' ;
% ---> Affichage des itérations en cours
vecho = 'off' ;
%
% b) gestion des options
% ---------------------------------------------------------------------
%
N_option = length(varargin)/2 ;
% ---> Si ce n'est pas un entier ---> erreur
if N_option - fix(N_option) ~= 0 ;
    error('Les options doivent etre entrées par ''nomoption'',''valueoption''') ;
end
% ---> Boucles sur les options
for t = 1:2:2*N_option-1 ;
    % ---> Suivant les cas :
    switch lower(varargin{t}) ;
        case 'lambda' ;
            % ---> Nouvelle valeur de lambda 
            lambda = varargin{t+1} ;
            kpb = 1/lambda + 1/nu ;
        case 'nu'
            % ---> Nouvelle valeur de nu
            nu = varargin{t+1} ;
            kpb = 1/lambda + 1/nu ;
        case 'immuable' ;
            % ---> Points immuables : plusieurs cas
            if isstr(varargin{t+1}) ;
                switch lower(varargin{t+1}) ;
                    case 'init' ;
                        % ---> les points initiazux de l'interpolation sont immuables
                        immuable = [1:size(N,1)] ;
                end
            else
                % ---> c'est une liste de nombre qui est entrée
                immuable = varargin{t+1} ;
            end
            NImmuabale = N(immuable,:) ;
        case 'subdivision' ;
            % ---> Nombre de subdivisions par triangles dans le cas d'interpolation
            subdivision = varargin{t+1} ;
        case 'iterations' ;
            % ---> Nombre d'itération de lissage
            iterations = varargin{t+1} ;
        case 'poids' ;
            % ---> Type des poids
            poids = varargin{t+1} ;
        case 'echo' ;
            % ---> Affichage des pas en cours
            vecho = varargin{t+1} ;
        otherwise
            % ---> il y a un warning
            error(['L''option ',varargin{t},' est inconnue : pas de prise en compte']) ;
    end
end
%
% ################################
% ### 1. Algorithme de lissage ###
% ################################
%
try 
    % _________________________________________________________________________________
    %
    % a0) triangularisation du maillage
    P = triangularise_maillage(P,N) ;
    % a) création des subdivisions :
    for t = 1:subdivision ;
        [N,P] = subdivise_movie(N,P) ;
    end
    % _________________________________________________________________________________
    %
    % b) analyse des arretes :
    Arr = analyse_arretes(P) ;
    % _________________________________________________________________________________
    %
    % c) préparation pour le calcul des poids desbrun
    if strcmp(lower(poids),'desbrun') ;
        % Nous devons rechercher les sommets supplémentaires des triangles contigus à l'arrete
        for t = 1:size(Arr.Definition,1) ;
            PDes(t,1) = setdiff(P(Arr.Polygones(t,1),:),Arr.Definition(t,:)) ;
            PDes(t,2) = setdiff(P(Arr.Polygones(t,2),:),Arr.Definition(t,:)) ;
        end
    end
    % _________________________________________________________________________________
    %
    % d) Boucle de lissage : plusieurs possibilités : création des poids, de l'opérateur
    %    laplacien, ...
    %
    for t = 1:iterations
        %
        if strcmp(lower(vecho),'on') ;
            disp(['Itération n° ',num2str(t),' / ',num2str(iterations)]) ;
        end
        %
        % d-1) Création des poids : 3 types : 'unit', 'fujiwara' ou 'desbrun'
        % ---> Matrice W : C modifié
        %
        if ~strcmp(lower(poids),'unit')|t==1 ;
            % ---> Initialisation de la matrice de connectivité
            C = sparse(size(N,1),size(N,1)) ;
            switch lower(poids)
                case 'unit' 
                    C(sub2ind(size(C),Arr.Definition(:,1),Arr.Definition(:,2))) = 1 ;
                case 'fujiwara' ;
                    % ---> Chaque arrete est pondérée par l'inverse de sa longueur
                    C(sub2ind(size(C),Arr.Definition(:,1),Arr.Definition(:,2))) = ... 
                        1 ./ norm2(N(Arr.Definition(:,1),:) - N(Arr.Definition(:,2),:)) ;
                case 'desbrun' ;
                    % ---> chaque arrete est pondéré par les cotangentes des angles des ...
                    %      triangles ayant l'arrete comme coté opposé
                    C(sub2ind(size(C),Arr.Definition(:,1),Arr.Definition(:,2))) = ...
                        dot(N(Arr.Definition(:,1),:)-N(PDes(:,1),:),...
                        N(Arr.Definition(:,2),:)-N(PDes(:,1),:),2) ./ ...
                        norm2(cross(N(Arr.Definition(:,1),:)-N(PDes(:,1),:),...
                        N(Arr.Definition(:,2),:)-N(PDes(:,1),:))) + ...
                        dot(N(Arr.Definition(:,1),:)-N(PDes(:,2),:),...
                        N(Arr.Definition(:,2),:)-N(PDes(:,2),:),2) ./ ...
                        norm2(cross(N(Arr.Definition(:,1),:)-N(PDes(:,2),:),...
                        N(Arr.Definition(:,2),:)-N(PDes(:,2),:))) ;
                otherwise 
                    error('Poids inconnus')
            end
            % ---> Le graphe n'est pas orienté et non bouclé
            C = C + C' ;                    
            C(sub2ind(size(C),[1:size(C,1)],[1:size(C,1)])) = 0 ;
            % Somme des couts pour un noeuds 
            NC = sum(C,1)' ;                   
            for y = 1:size(C,2) ;
                C(find(NC~=0),y) = C(find(NC~=0),y) ./ NC(find(NC~=0)) ;
            end
        end
        %__________________________________________________________________________________
        %
        % e) création de l'opérateur Laplacien K :
        K = sparse(size(N,1),size(N,1)) ;
        K = speye(size(C)) - C ; 
        %__________________________________________________________________________________
        %
        % g) création de l'opérateur de lissage f(K) : K modifié
        %
        if (t/2) - fix(t/2) ~= 0 ;
            % Utilisation de lambda :
            K = speye(size(K)) - lambda * K ;
        else
            % Utilisation de nu
            K = speye(size(K)) - nu * K ;
        end
        %
        % h) calcul des nouveaux points :  autant de fois que la puissance demandée
        N = K * N ;
        %
        % i) conservation des noeuds immuables
        if ((t/2) - fix(t/2) == 0)&(~isempty(immuable)) ;
            N(immuable,:) = NImmuabale ;
        end
    end
    %
catch
    % ---> En cas d'erreur
    error(lasterr) ;
end
%
% Fin de la fonction