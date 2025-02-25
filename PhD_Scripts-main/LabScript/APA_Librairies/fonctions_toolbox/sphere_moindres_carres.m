% function Sphere = sphere_moindres_carres(M) ;
% _______________________________________________________
%
% Fonction de calcul d'une sphère au moindres carrés
%
% M: liste des points appartenant à une sphère (n,3)
% Sphere : Sphere.Centre: centre de la sphere (1,3)
%          Sphere.Rayon : rayon de la sphere
% _______________________________________________________
%
function Sphere = sphere_moindres_carres(M) ;
%
% 1. Calcul de la solution initiale par une méthode de moindres carrés 
%    sur la fonction implicite de la sphère :
%
% a) Matrice de Calcul et vecteur de calcul :
%
N = size(M,1) ;         % Nombre de points dans la liste
Mat = [2*M,ones(N,1)] ; % Matrice de calcul 
Vec = norm2(M).^2 ;        % Vecteur cible
%
% b) Calcul de la solution initiale et mise en forme
%
Soluce = inv(Mat'*Mat)*Mat'*Vec ;
Sphere.Centre = Soluce(1:3)' ; % Centre initial
Sphere.Rayon = sqrt(Soluce(4)+norm(Sphere.Centre)^2) ; % Rayon initial
%
% 2. Optimisation de la solution par moindres carrés linéarisés 
%    (sur la distance points // sphere)
% return
Soluce = 1 ; % Entree de boucle
while norm(Soluce) > 1e-10 ;
    % a) mise en forme des variables de calcul
    OMi = M - ones(N,1) * Sphere.Centre ; % Points centrés
    nOMi = norm2(OMi) ;                   % Distance points centre calculé
    Ui = 1 - Sphere.Rayon ./ nOMi ;       % Différence relative Rayon calculé nOMi
    % b) Préparation et calculs des matrices de calcul 
    % ---> Matrice de calcul
    L = sum( OMi ./ (nOMi * [1,1,1])) ;
    Mat = [N,L;L',N*eye(3)] ;
    % ---> Vecteur de calcul
    Vec = [sum(Ui.*nOMi),sum((Ui * [1,1,1]) .* OMi)]' ;
    % c) Calcul de la solution :
    Soluce = inv(Mat)*Vec ;
    % d) Calcul du nouveau centre et du nouveau rayon :
    Sphere.Rayon = Sphere.Rayon + Soluce(1) ;
    Sphere.Centre = Sphere.Centre + Soluce(2:4)' ;
end
%
% Fin de la fonction