% IAB = Creer_point_bezier_normales(A,B,nA,nB) ;
%
% 1. Fonction de création d'un point de type Bézier à partir de 2 points finaux A et B et
%    des normales à la surface nA et nB en ces points
%
function IAB = Creer_point_bezier_normales(A,B,na,nb) ;
%
% Le calcul est réalisé en 4 points :
%
% 1. Calcul des vecteurs directeurs pour les droites contenant IAB
%
na = norme_vecteur(na) ; nb = norme_vecteur(nb) ; % Simplifie les écritures
n = cross(na,nb) ;
% ---> Recherche des vecteurs n dont la norme est très petite
l1 = find(norm2(n) < 1e-3) ;   % Liste numérique de ces vecteurs
l2 = setdiff([1:size(A,1)],l1) ; % Liste des autres vecteurs
%
% 2. Calcul de Q la projection des points A sur la droite contenant les IAB
%
if ~isempty(l2) ;
    c1 = dot(A(l2,:),na(l2,:),2) - (dot(nb(l2,:),na(l2,:),2)).*(dot(B(l2,:),nb(l2,:),2)) ;
    c2 = dot(B(l2,:),nb(l2,:),2) - (dot(nb(l2,:),na(l2,:),2)).*(dot(A(l2,:),na(l2,:),2)) ;
    Q = ((c1 * [1,1,1]) .* na  + (c2 * [1,1,1]) .* nb) ./ ((1-dot(nb(l2,:),na(l2,:),2).^2) * [1,1,1]) ;
    %
    % 3. Calcul de la coordonnée nu de IAB sur la droite 
    %
    warning off
    nu = ((norm2(B(l2,:)-A(l2,:)).^2).* dot(Q(l2,:)-A(l2,:),n(l2,:),2) - ...
        dot(B(l2,:)-A(l2,:),n(l2,:),2).*dot(Q(l2,:)-A(l2,:),B(l2,:)-A(l2,:),2)) ./ ...
        (dot(B(l2,:)-A(l2,:),n(l2,:),2).^2 - (norm2(B(l2,:)-A(l2,:)).^2) .* (norm2(n(l2,:)).^2)) ;
    warning on
    %
    % 4. Calcul des IAB
    %
    IAB(l2,:) = Q + (nu * [1,1,1]) .* n(l2,:) ;
end
IAB(l1,:) = 0.5 * (A(l1,:) + B(l1,:)) ;
% ---> Correction pour les noeuds NaN
l1 = find(isnan(IAB(:,1)) == 1) ;
if ~isempty(l1) ;
    IAB(l1,:) = 0.5 * (A(l1,:) + B(l1,:)) ;
end
%
% Fin de la fonction