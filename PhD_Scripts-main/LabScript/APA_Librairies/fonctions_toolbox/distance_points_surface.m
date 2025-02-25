%
% Fonction de calcul point surface
%
function dist = distance_points_surface(M1,Info,M2,ordre) ;
%
% 1. Recherche des points M1 proches de ceux de M2
%
I = recherche_points_proche(Info.Barycentre,M2) ;
%
% 2. Distance points triangles ---> surface d'ordre 0
%
[dist1.valeurs,dist1.points] = fast_distance_pt_tri(M1(Info.Polygones(I,1),:),...
  M1(Info.Polygones(I,2),:),...
  M1(Info.Polygones(I,3),:),M2) ;
dist1.signe = sign(dot(Info.Normale(I,:),M2 - Info.Barycentre(I,:),2)) ;
%
% 3. Distances points points ---> Pour les points particuliers
%
[I,d] = recherche_points_proche(M1,M2) ;
dist2.valeurs = d ; dist2.points = M1(I,:) ;
dist2.signe = sign(dot(Info.Noeuds.Normale(I,:),M2 - M1(I,:),2)) ;
%
% 4. Choix de la plus petite valeur
%
[dist.valeurs,qui] = min([dist1.valeurs;dist2.valeurs],[],1) ;
% ---> Relatif aux triangles :
I = find(qui == 1) ; 
dist.points(I,:) = dist1.points(I,:) ; 
dist.signe(I) = dist1.signe(I) ;
% ---> Relatif aux noeuds :
I = find(qui == 2) ; 
dist.points(I,:) = dist2.points(I,:) ; 
dist.signe(I) = dist2.signe(I) ;
%
% Fin de la fonction