%
% Cette fonction permet permet de lister les valeurs apparaissant dans un tableau ou une matrice
% exemple M = [1 2 2
%              3 2 -1]
% renvoie [-1,1,2,3]
%
function Liste = liste_valeurs(Matrice) ;
%
% a) passage en format colonne
%
X = reshape(Matrice,size(Matrice,1)*size(Matrice,2),1) ;
%
% b) classement par ordre croissant des numéros de points & extraction des n° seuls
%
X = sortrows(X) ;    % classement par ordre croissant
cmpt = 1 ;           % compteur de n° de point
Liste(cmpt) = X(1) ; % pour le premier point
for t = 2:length(X) ;% On garde un numéro si et seulement si celui-ci n'apparait pas déjà ...
    if Liste(cmpt)~=X(t) ;
        cmpt = cmpt + 1 ;
        Liste(cmpt) = X(t) ;
    end
end
%
% fin de la fonction
