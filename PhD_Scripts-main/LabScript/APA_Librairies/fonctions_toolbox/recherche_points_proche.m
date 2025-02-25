% [I,dist] = recherche_points_proche(Ref,Rec) ;
%
% Recherche pour chaque point de Rec le point le plus proche de Ref
%
function [I,d] = recherche_points_proche(A,B) ;
%
% 1. Définition d'une taille limite de calcul ---> Rapidité du calcul
%
limite = 1e5 ;
nA = size(A,1) ; % Dimension de la référence
nB = size(B,1) ; % Dimension de la reconstruction
%
% 2. Boucle de recherche des minima
%
%
if nA * nB <= limite ;
  % ---> Recherche du mini ;
  [d,I] = min((norm2(B).^2) * ones(1,nA) + ones(nB,1) * (norm2(A).^2)' - 2 * B * A',[],2) ;
else
  % ---> Calcul d'un pas de recherche :
  Pas = floor(limite / nA) ;
  % ---> Avancement de la recherche
  liste = 0 ; sortie = 1 ;
  while sortie
    % ---> nouvelle liste
    liste = liste(end) + [1:Pas] ;
    % ---> Gestion de la dernière liste
    if liste(end) > nB ;
      liste = [liste(1):nB] ;
      sortie = 0 ;
    end
    % ---> Calcul pour cette partie
    [d(liste),I(liste)] = min((norm2(B(liste,:)).^2) * ones(1,nA) + ...
      ones(length(liste),1) * (norm2(A).^2)' - 2 * B(liste,:) * A',[],2) ;
  end
end
if size(d,2) == 1 ;
    d = d' ;
end
%
% Fin de la fonction