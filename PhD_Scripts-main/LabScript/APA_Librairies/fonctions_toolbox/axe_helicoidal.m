% .... = axe_helicoidal(...) ;
% ____________________________________________________________________________________
%
% fonction de calcul d'un axe h�licoidal : Plusieurs cas d'entr�es/sorties � traiter
% ____________________________________________________________________________________
%
% ___ En entr�e ___
%
% ###################
% ### Premier Cas ###
% ###################
% 
% Ah = axe_helicoidal(B,P) 
% Ah = axe_helicoidal(S)
% Ah = axe_helicoidal(H)
% Ah = axe_helicoidal(S,nom_champ)
%
% N rep�res caract�ris�s chacun par une matrice de passage et un point, tous d�fins dans
% un meme rep�re de r�f�rence Ro. 
% Sont alors calcul�s les axes h�licoidaux entre Ri et Ro soient N axes
%
% ---> Type n�1
% B est un tableau (3x3xN) : chaque R(:,:,i) repr�sente la matrice de passage de Ri vers Ro
% P est un tableau (Nx3)   : chaque Pts(i,:) repr�sente le centre du rep�re Ri exprim� dans Ro
% ---> Type n�2
% H est un tableau (4x4xN) : Chaque H(:,:,i) repr�sente la matrice homog�ne de transformation du
%                            rep�re Ro vers le rep�re Ri
% ---> Type n�3 
% S est une structure contenant N pages et deux champs par pages de dimensions (3x3) et (1x3)
% repr�sentant la matrice de changement de base et le centre du rep�re. 
% Noms des champs :  "nom_champ" est une tableau de cells contenant 
% le nom du champ pour la matrice et le nom pour le point : {'base','pts'} : la valeur par 
% d�faut est alors {'Base','Origine'}
%
%
% ##################
% ### Second Cas ###
% ##################
%
% Ah = axe_helicoidal(B1,P1,B2,P2)
% Ah = axe_helicoidal(S1,S2)
% Ah = axe_helicoidal(H1,H2)
% Ah = axe_helicoidal(S1,S2,nom_champ)
%
% (N,N) rep�res caract�ris�s chacun par une matrice de passage et un point, tous d�finis
% dans un seul et meme rep�re de r�f�rence.
% Sont alors calcul�s les axes helicoidaux entre R1i et R2i, soient N axes
%
% ---> Les type d'entr�es sont les memes que precedemment, cependant pour le champ 
% "nom_champ" le tableau de cells contient 2 lignes
%
% ___ En Sortie ___
%
% ###################
% ### Premier Cas ###
% ###################
%
% Ah = ... 
%
% Ah est une structure contenant 4 champs d�finissant l'axe h�licoidal :
%      Ah.Vecteur = [nx3]     : vecteur directeur de l'axe
%      Ah.Point = [nx3]       : point de l'axe 
%      Ah.Angle = [nx1]       : angle re rotation autour de l'axe
%      Ah.Translation = [nx1] : valeur de la translation le long de l'axe
%      o� n est le nombre d'axes calcul�s
%
% ##################
% ### Second Cas ###
% ##################
%
% [Vecteur,Point,Angle,Translation] = ...
%
% Renvoie les memes inconnues mais sous forme de vecteurs
% __________________________________________________________________________________
%
function [V,P,A,T] = axe_helicoidal(A1,A2,A3,A4) ;
%
% ####################################################################
% ### 1. Gestion des donn�es d'entr�e pour mise en forme du calcul ###
% ####################################################################
%
% La mise en forme utilis�e sera la suivante : 
% ---> Base pour les rep�res de d�part B1 : tableau [3,3,n]
% ---> Base pour les rep�res d'arriv�e B2 : tableau [3,3,n]
% ---> Origine des rep�res O1 et O2 : tableaux [n,3]
%
try 
    switch nargin ; % ---> Gestion des cas suivant le nombre de param�tres d'entr�
    case 1
        % ---> Il n'y a qu'un param�tre d'entr�e : il n'existe que 2 cas possibles :
        % Un ensemble de structures ou de matrices homog�nes
        if isstruct(A1) ; % ---> C'est un ensemble de structure de d�finition de rep�res
            % ---> Extraction des donn�es pour cette mise en forme
            B2 = cat(3,A1(:).Base) ;
            O2 = cat(2,A1(:).Origine) ;
        elseif (size(A1,1) == 4) & (size(A1,2) == 4) % ---> c'est un ensemble de matrices homog�nes
            % ---> Extraction et mise en forme des informations
            B2 = A1(1:3,1:3,:) ;
            O2 = (- (B2') * squeeze(A1(1:3,4,:)))' ;
        end
    case 2
        % ---> Il y a 2 param�tres d'entr�e : Plusieurs cas possibles
        if (size(A1,1) == 3) & (size(A1,2) == 3) & ...
                (size(A2,2) == 3) & (size(A1,3) == size(A2,1)) ;
            % ---> A1 et A2 sont directement au bon format
            B2 = A1 ; 
            O2 = A2 ;
        elseif isstruct(A1) & iscell(A2) ;
            % ---> Nous avons affaire � une structure et aux noms des champs � utiliser
            Temp = extract_field(A1,A2{1}) ;
            [Temp2(1:length(Temp)).Base] = deal(Temp{:}) ;
            B2 = cat(3,Temp2(:).Base) ;
            clear Temp Temp2
            %
            Temp = extract_field(A1,A2{2}) ;
            [Temp2(1:length(Temp)).Origine] = deal(Temp{:}) ;
            O2 =  cat(2,Temp2(:).Origine) ;
            clear Temp Temp2
        elseif isstruct(A1) & isstruct(A2) ;
            % ---> Nous avons ici affaire � deux structures avec .Origine et .Base
            B1 = cat(3,A1(:).Base) ;
            O1 = cat(2,A1(:).Origine) ;
            B2 = cat(3,A2(:).Base) ;
            O2 = cat(2,A2(:).Origine) ;
        elseif (size(A1,1) == 4) & (size(A1,2) == 4) & ...
                (size(A2,1) == 4) & (size(A2,2) == 4) & ...
                (size(A1,3) == size(A2,3)) ;
            % ---> Nous avons affaire � deux ensembles de matrices homog�nes
            B1 = A1(1:3,1:3,:) ;
            O1 = (- (B1') * squeeze(A1(1:3,4,:)))' ;
            B2 = A2(1:3,1:3,:) ;
            O2 = (- (B2') * squeeze(A2(1:3,4,:)))' ;
        end
    case 3
        % ---> Il y a 3 param�tres d'entr�e : 1 seule solution 
        % 2 structures et les noms des champs associ�s
        Temp = extract_field(A1,A3{1,1}) ;
        [Temp2(1:length(Temp)).Base] = deal(Temp{:}) ;
        B1 = cat(3,Temp2(:).Base) ;
        clear Temp Temp2
        %
        Temp = extract_field(A1,A3{1,2}) ;
        [Temp2(1:length(Temp)).Origine] = deal(Temp{:}) ;
        O1 =  cat(2,Temp2(:).Origine) ;
        clear Temp Temp2
        %
        Temp = extract_field(A2,A3{2,1}) ;
        [Temp2(1:length(Temp)).Base] = deal(Temp{:}) ;
        B2 = cat(3,Temp2(:).Base) ;
        clear Temp Temp2
        %
        Temp = extract_field(A2,A3{2,2}) ;
        [Temp2(1:length(Temp)).Origine] = deal(Temp{:}) ;
        O2 =  cat(2,Temp2(:).Origine) ;
        clear Temp Temp2
    case 4
        % ---> Un seul cas possible : les entr�es ont le bon format
        B1 = A1 ; B2 = A3 ;
        O1 = A2 ; O2 = A4 ;
    end
    %
    % Il faut g�n�rer O1 et B1 si elles n'existent pas
    %
    if ~exist('O1') ;
        % ---> Il faut d�finir le rep�re de r�f�rence
        B1 = repmat(eye(3,3),[1,1,size(O2,2)]) ;
        O1 = zeros(size(O2)) ;
    end
catch
    error('Incompatibilit� des donn�es d''entr�e ...') ;
end
%
% ######################################
% ### 2. Calcul des axes helicoidaux ###
% ######################################
%
% 2.0. Mise en forme de transformation d'un rep�re R1 vers un rep�re R2
%
R = ProdMD(transMD(B2),B1) ;
Temp(1:3,1,:) = O1' ;
T = O2 - squeeze(prodMD(R,Temp))' ;
%
% 2.1. D�termination de l'axe et de l'angle de rotation 
%
[V,A] = Rot2Vang(R) ;
%
% 2.2. Calcul de la translation le long de l'axe helicoidal
%
T = dot(T,V,2) ;
%
% 2.3. Calcul du point de l'axe h�licoidal
%
P = .5 * (O1 + O2 - T.* V + ...
    (1/tan(A/2)) * cross(V,O2 - O1)) ;
%
% ########################################
% ### 3. Gestion des donn�es de sortie ###
% ########################################
%
if nargout == 1 ;
    % ---> Les axes sont demand�s au format structure
    Ah.Vecteur = V ;
    Ah.Point = P ;
    Ah.Angle = A ;
    Ah.Translation = T ;
    V = Ah ;
end
%
if (nargout > 1)&(nargout <4) ;
    warning('Toutes les informations ne seront pas accessible')
end
%
% Fin de la fonction