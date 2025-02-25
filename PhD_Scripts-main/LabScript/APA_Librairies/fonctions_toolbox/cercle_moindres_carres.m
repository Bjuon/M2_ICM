% function Cercle = cercle_moindres_carres(M) ;
% _______________________________________________________
%
% Fonction de calcul d'une Cercle au moindres carrés
%
% M: liste des points appartenant à un Cercle (n,2)
% Cercle : Cercle.Centre: centre du Cercle (1,2)
%          Cercle.Rayon : rayon du Cercle
% _______________________________________________________
%
function Cercle = cercle_moindres_carres(M) ;
%
% 1. Calcul de la solution initiale par une méthode de moindres carrés 
%    sur la fonction implicite de la sphère :
%
% a) Matrice de Calcul et vecteur de calcul :
%
N = size(M,1) ;         % Nombre de points dans la liste
Mat = [2*M,ones(N,1)] ; % Matrice de calcul 
Vec = norm2(M).^2 ;     % Vecteur cible
%
% b) Calcul de la solution initiale et mise en forme
%
Soluce = inv(Mat'*Mat)*Mat'*Vec ;
Cercle.Centre = Soluce(1:2)' ; % Centre initial
Cercle.Rayon = sqrt(Soluce(3)+norm(Cercle.Centre)^2) ; % Rayon initial
%
% 2. Optimisation de la solution par moindres carrés linéarisés 
%    (sur la distance points // cercle)
% return
Soluce = 1 ; % Entree de boucle
while norm(Soluce) > 1e-10 ;
    % a) mise en forme des variables de calcul
    OMi = M - ones(N,1) * Cercle.Centre ; % Points centrés
    nOMi = norm2(OMi) ;                   % Distance points centre calculé
    Ui = 1 - Cercle.Rayon ./ nOMi ;       % Différence relative Rayon calculé nOMi
    % b) Préparation et calculs des matrices de calcul 
    % ---> Matrice de calcul
    L = sum( OMi ./ (nOMi * [1,1])) ;
    Mat = [N,L;L',N*eye(2)] ;
    % ---> Vecteur de calcul
    Vec = [sum(Ui.*nOMi),sum((Ui * [1,1]) .* OMi)]' ;
    % c) Calcul de la solution :
    Soluce = inv(Mat)*Vec ;
    % d) Calcul du nouveau centre et du nouveau rayon :
    Cercle.Rayon = Cercle.Rayon + Soluce(1) ;
    Cercle.Centre = Cercle.Centre + Soluce(2:3)' ;
end
%
% Fin de la fonction