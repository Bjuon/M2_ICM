function Polygone = creation_maillage(Polygone,Objet) ;
%
% ___ Création d'un champ tag dans polygone avec la liste des tags associés au maillage ___
%
% ---> Récupération des données relatives à l'objet
%
Polygone.Noeuds.tag = Objet.tag ;     % liste des tags pour les noeuds
Polygone.Noeuds.N_Pts = Objet.N_Pts ; % nombre de noeuds
Polygone.Type_Objet = Objet.type ;    % type de d'objet pour le maillage
%
% ___ Recherche des polygones auquels appartiennent chacun des noeuds ___
%
Polygone = mise_en_forme_num_polygone(Polygone) ;
%
% ___ Supression des surfaces ne contenant pas au moins 3 sommets ___
%
[Ou,Po] = find(Polygone.Polygones.pol_numerique' == 0) ;
Pol_ok = liste_valeurs(find2([1:size(Polygone.Polygones.pol_numerique,1)],Po(find(diff(Po)==0)),'~=')) ;
if ~isempty(Pol_ok) ;
    Polygone.Polygones.pol_numerique = Polygone.Polygones.pol_numerique(Pol_ok,:) ;
    Polygone.Polygones.pol_tag = Polygone.Polygones.pol_tag(Pol_ok,:) ;
    Polygone.Polygones.N_Pol = size(Polygone.Polygones.pol_numerique,1) ;
end
% Fin de la fonction