function valfield = extract_field(S,field) ;
%
% Pour une structure multipage, extraction des valeurs pour chacune des pages
%
% 1) Il faut absolument que S soit une structure ...
%
if ~isstruct(S)
   error(['La variable d''entrée ',inputname(1),' n''est pas une structure ...']) ;
   valfield = [] ; return ;
end
%
% 2) Vérivication que field appartient bien aux champs de S
%
if ~max(matchcell(fieldnames(S),field)) ;
   error(['Le champ ',field,' n''appartient pas à la variable']) ;
   valfied = [] ; return ;
end
%
% 3) Taille de la structure et recherche de l'information
% ---> taille de la structure S
[n,m] = size(S) ;
% ---> récupération de la valeur des champs
for t = 1:n ;
   for y = 1:m ;
      valfield{t,y} = getfield(S,{t,y},field) ;
   end
end
%
% fin de la fonction
