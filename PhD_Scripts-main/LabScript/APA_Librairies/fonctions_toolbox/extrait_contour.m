% function C2 = extrait_contour(C1,N) ;
%
% Fonction permettant d'extraire le Ni�me contour d'un ensemble de contours
%
function C2 = extrait_contour(C1,N) ;
%
% 1. R�cup�ration des N� de noeuds du contour d'int�ret :
%
liste = C1.tri{N} ;
%
% 2. R�cup�ration des champs de la variable C1
%
champs = fields(C1) ;
%
% 3. R�cup�ration du nombre de noeuds dans C1
%
NN = size(C1.coord,1) ;
%
% 4. Extraction du contour et de ces sp�cifications
%
C2.coord = [] ; % Permet l'initialisation de la variable de sortie
C2.tri = {[1:length(liste)]} ; % Pour le tri donn�
for t = 1:length(champs) ;
    % ---> Est-ce un champ � modifier ?
    Temp = getfield(C1,champs{t}) ;
    if size(Temp,1) == NN ;
        % ---> si oui : sauvegarde des infos dans C2
        C2 = setfield(C2,champs{t},Temp(liste,:)) ;
    end
end
%
% Fin de la fonction