function fpol = recherche_ref_pol(type) ;
%
% Ouverture du fichier .cfg
%
fid = fopen('Polygone.cfg','r') ;
%
% passage des 3 premières lignes :
%
for ttt = 1:4 ; ligne = fgetl(fid); end;
trouve = 0 ; % variable de recherche du type d'objet
%
while (~trouve)&(~feof(fid))
    %
    % Recherche dans la ligne du type d'objet
    %
    if ~isempty(findstr(ligne,[type,' '])) ; % type trouvé 
        %
        % Remplacement du type par un caractère vide dans ligne
        %
        ligne = strrep(ligne,[type,' '],' ') ; 
        %
        % Récupération du nom du fichier polygone
        %
        fpol = sscanf(ligne,'%s',1) ;
        %
        trouve = 1 ; % pour sortir de la recherche
        %
    end
    %
    % ligne suivante 
    %
    ligne = fgetl(fid) ; 
    %
end
%
% Dans le cas où l'objet n'apparait pas dans la liste des objets référencés 
% fpol est renvoyé vide ...
%
if trouve == 0 ;
    fpol = [] ;
end
%
% fermeture du fichier cfg
%
fclose(fid) ;
%
% fin de la sous fonction