function A = RegtyI2tyII(B,Champ) ;

% ---> Fonction permettant de transformer une définition de région de type I
%      en définition de type II


%
% 1. Gestion des entrées
%
if nargin == 1 ;
    % ---> Champ est imposé égale à Noeuds :
    Champ = 'Noeuds' ;
end
%
% 2. Compatibilité du type I
% ---> Soit les tags sont déjà numérique, soit ils sont de la forme Point_xyz
%
if isempty(str2num(B(1).tag{1})) & ~strncmp(B(1).tag{1},'Point_',6) ;
    % ---> La définition de régions n'est pas compatible
    error('Définition de régions incompatible')
end
%
% 3. Noms des régions
%
liste_regions = extract_field(B,'nom') ;
%
% 4. Boucle d'écriture de la nouvelle variable
%
A = struct([]) ; 
for t = 1:length(liste_regions) ;
    % ---> Création des listes de noeuds :
    Temp = struct([]) ; % ---> Initialise la structure Temp
    for u = 1:length(B(t).tag) ;
        Temp = setfield(Temp,{1,1},Champ,{u,1},...
            str2num(strrep(B(t).tag{u},'Point_',''))) ;
    end
    % ---> Ecriture du champ
    A = setfield(A,{1,1},liste_regions{t},Temp) ;
end
%
% ---> Fin de la fonction
    