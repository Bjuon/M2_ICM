function [normale,Point] = plan_moindres_carres_ancien(M) ;
%
% les noeuds doivent être écrit les uns sous les autres 
% afin que la fonction fonctionne correctement
% ---> Modif afin de prendre en compte toute les possibilités d'écriture d'un plan
% 
warning off
%
% Equations d'un plan : 1) aX + bY + cZ = 1 ;
%                       2) aX + bY + Z = 0  ; -|
%                       3) aX + Y + cZ = 0  ;  |----> Plan passant par l'origine
%                       4) X + bY + cZ = 0  ; -|
%
%
% 1. Mise en forme de la variable :
%
X = M(:,1) ; Mx = M(:,2:3) ; 
Y = M(:,2) ; My = M(:,[1,3]) ;
Z = M(:,3) ; Mz = M(:,1:2) ;
%
% 2. Calcul de la taille de M :
%
N = size(M,1) ;
%
% 3. Calcul de la normale dans les 4 cas de figure
% ---> Cas 1
normale = M \ ones(N,1) ; n1 = normale / norm(normale) ;
% ---> Cas 2
n2 = Mz \ Z ; n2 = [n2;1] ; n2 = n2 / norm(n2) ;
% ---> Cas 3
n3 = My \ Y ; n3 = [n3(1);1;n3(2)] ; n3 = n3 / norm(n3) ;
% ---> cas 4
n4 = Mx \ X ; n4 = [1;n4] ; n4 = n4 / norm(n4) ;
%
% 4. Calcul d'un point du plan dans le cas n°1
%
Point = Barycentre(M) ; % On part du Barycentre et on calcule le z pour le x et le y de G
G = Point ;
%
% Calcul d'un point du plan : coordonnées x et y = 0
%
try 
    Z = (1 - normale(1)*Point(1) - normale(2)*Point(2) ) / normale(3,1) ;
    Point(3) = Z ;
catch
    try 
        Y = (1 - normale(1)*Point(1) - normale(3)*Point(3) ) / normale(2,1) ;
        Point(2) = Y ;
    catch
        try 
            X = (1 - normale(2)*Point(2) - normale(3)*Point(3) ) / normale(1,1) ;
            Point(1) = X ;
        catch
            error('Calcul impossible !!!') ;
            Point = [] ;
        end
    end
    error('Calcul impossible !!!') ;
end
%
% 5. Calcul des résidus dans les 4 cas
%
cmpt = 1 ;
for t = 1:N-1 ;
    for y = t+1:N ;
        temp(1,cmpt) = abs(dot(n1,M(t,:)-M(y,:))/norm(M(t,:)-M(y,:))) ;
        temp(2,cmpt) = abs(dot(n2,M(t,:)-M(y,:))/norm(M(t,:)-M(y,:))) ;
        temp(3,cmpt) = abs(dot(n3,M(t,:)-M(y,:))/norm(M(t,:)-M(y,:))) ;
        temp(4,cmpt) = abs(dot(n4,M(t,:)-M(y,:))/norm(M(t,:)-M(y,:))) ;
        cmpt = cmpt + 1 ;
    end
end
residu(1) = mean(temp(1,:)) ;
residu(2) = mean(temp(2,:)) ;
residu(3) = mean(temp(3,:)) ;
residu(4) = mean(temp(4,:)) ;
%
% 6. Recherche du minima de résidus
%
[mini,qui] = min(residu) ;
%
% 7. Ecriture des variables de sortie par cas
%
switch qui
case 1 ; % Cas 1
    normale = n1 ; % Normale normalisée le point est déjà calculé
case 2
    normale = n2 ; 
    Point = G ;
case 3
    normale = n3 ; 
    Point = G ;
case 4
    normale = n4 ; 
    Point = G ;
end
%
% fin de la fonction
% 
warning on