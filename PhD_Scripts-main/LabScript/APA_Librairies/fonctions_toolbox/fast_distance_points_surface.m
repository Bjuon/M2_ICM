function dist = fast_distance_points_surface(Pts,N,P) ;
%
% Fonction de calcul rapide de la distance d'un ensemble de points à une
% surface triangulée
%

% ---> Analyse des triangles
InfoP = analyse_geometrie_polygones(P,N) ; 
% ---> Distance des points aux triangles
% a) recherche du triangle le plus proche :
I = recherche_points_proche(InfoP.Barycentre,Pts) ;
% b) distances points triangles
[dist1.valeurs,dist1.points] = fast_distance_pt_tri(N(P(I,1),:),...
  N(P(I,2),:),N(P(I,3),:),Pts) ;
% ---> Distance points points pour les cas particuliers :
[I,d] = recherche_points_proche(N,Pts) ;
dist2.valeurs = d ; dist2.points = N(I,:) ;
% ---> Choix de la plus petite valeur
[dist.valeurs,qui] = min([dist1.valeurs;dist2.valeurs],[],1) ;
% ---> Relatif aux triangles :
I = find(qui == 1) ; 
dist.points(I,:) = dist1.points(I,:) ; 
% ---> Relatif aux noeuds :
I = find(qui == 2) ; 
dist.points(I,:) = dist2.points(I,:) ; 
% Fin de la fonction