% __________________________________________________________________________________
%
% function angle = calcul_angle_2_vecteurs(v1,v2) ;
% 
% Fonction de calcul de l'angle entre 2 vecteurs en radians 
% Les vecteurs sont entrés en ligne [xi,yi,zi]
%
%
% direction : [nx,ny,nz] 
%             si x choisit 
%             alors dot(x,cross(v1,v2)) donne le signe de sin
% ___________________________________________________________________________________
function angle = calcul_angle_2_vecteurs(v1,v2) ;
%
% 1. On doit voir la dimension de chacun des vecteurs ...
%
dim1 = size(v1,2) ; dim2 = size(v2,2) ;
%
% 2. Et ils doivent avoir la meme dimension
%
if dim1 ~= dim2 ;
    error(['Les vecteurs n''ont pas la meme dimension v1 : ',num2str(dim1),' v2 : ',num2str(dim2)]) ;
end
%
% 3. On norme les vecteurs
%
v1 = v1/norm(v1) ; v2 = v2/norm(v2) ;
%
% 4. Traitement des 2 cas : 2D ou 3D
% 
% 4.1. calcul du cos :
%
cos12 = dot(v1,v2) ;
%
if dim1 == 2 ; 
    %
    % 4.2. Calcul du signe du sinus
    %
    sin12 = v1(1)*v2(2) - v1(2)*v2(1) ;
    %
elseif dim1 == 3 ;
    %
    % 4.2. Calcul du signe du sinus
    %
    sin12 = norm(cross(v1,v2)) ;
else
    error('Le calcul est possible qu''en dimension 2 ou 3') ;
end
%
% 4.3. determination de l'angle :
%
if sign(sin12) ~= 0 ;
    angle = sign(sin12) * acos(cos12) ;
else
    angle = acos(cos12) ;
    warning('La convention de signe est mauvaise : signe = 0')
    warning('Valeur absolue de l''angle renvoyée')
end
%
%
% Fin de la fonction