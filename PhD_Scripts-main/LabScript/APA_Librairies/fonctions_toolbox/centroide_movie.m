function [Ct,V] = centroide_movie(N,P,Info) ;
%
% ---> Fonction de calcul du barycentre d'un volume représenté
%      par une surface fermée
%
if nargin == 2 ;
  % ---> Calcul des informations pour les facettes
  Info = analyse_geometrie_polygones(P,N) ;
end
%
% ---> Calcul du volume pour l'objet
%
V = volume_movie(Info) ;
%
% ---> Boucle sur la dimension de l'espace
%
for t = 1:3 ;
  % ---> Récupération des informations pour l'orientation actuelle
  % Terme comprenant la surface du polygone
  Ts = Info.Surface .* Info.Normale(:,t) / 12 ;
  % Mise en forme des coordonnées
  xa = N(P(:,1),t) ; xb = N(P(:,2),t) ; xc = N(P(:,3),t) ;
  % ---> Calcul de la coordonnée du barycentre
  Ct(1,t) = sum(Ts .* (xa.^2 + xb.^2 + xc.^2 + xa.*xb + xa.*xc + xb.*xc)) / V ;
end
%
% ---> Fin de la fonction