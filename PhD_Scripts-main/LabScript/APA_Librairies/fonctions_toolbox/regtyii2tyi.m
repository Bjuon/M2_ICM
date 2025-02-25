function A = RegtyII2tyI(B,option) ;

% ---> Fonction permettant de transformer une définition de région de type II
%      en définition de type I

% 
% a) Quel est la sous-structure à utiliser ?
% ---> Liste des régions :
liste_regions = fields(B) ;
% ---> Liste des sous structures à disposition
liste = fields(getfield(B,liste_regions{1})) ; 
if nargin == 1 ;
    % ---> Par défaut si elle n'est pas précisée l'option est la premiere sous structure
    option = liste{1} ;
end
if isempty(find(strcmp(liste,option))) ;
    % ---> L'option choisie n'existe pas : par défaut nous prendrons la première sous structure
    warning('Option choisie inconnue : Sélection par défaut') ;
end
% ---> Affichage de l'option
disp(['Option retenue : ',option]) ;
%
% b) Mise en forme Type I
%
for t = 1:length(liste_regions) ;
    % ---> Nom de la région :
    Temp(t).nom = liste_regions{t} ;
    % ---> Tag de la région :
    U = getfield(B,liste_regions{t}) ; 
    U = getfield(U,option) ; % ---> liste numérique
    for k = 1:length(U) ;
        Temp(t).tag{k,1} = num2str(U(k)) ;
    end
end
A = Temp ;
%
% ---> Fin de la fonction