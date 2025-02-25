function [d,Pts] = distance_points_movie(N,P,M) ;
%
% Fonction de calcul de la distance entre des points et un objet movie
%

%
% ---> Distances avec les triangles
%
Info = analyse_geometrie_polygones(P,N) ;
qui = recherche_points_proche(Info.Barycentre,M) ;
[d1,P1] = fast_distance_pt_tri(N(P(qui,1),:),N(P(qui,2),:),N(P(qui,3),:),M) ;
%
% ---> Distances avec les points 
%
[liste,d2] = recherche_points_proche(N,M) ;
P2 = N(liste,:) ;
%
% ---> recherche des minimas
%
u1 = find(d1 <= d2) ; 
Pts(u1,:) = P1(u1,:) ;
d(u1) = d1(u1) ;
u2 = find(d2 < d1) ; 
Pts(u2,:) = P1(u2,:) ;
d(u2) = d2(u2) ;
%
% Fin de la fonction