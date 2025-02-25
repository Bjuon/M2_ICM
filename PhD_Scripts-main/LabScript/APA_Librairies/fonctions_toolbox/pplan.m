% function h = pplan(Plan,axe,option) ;
%
% Fonction d'affichage d'un plan dans un axe ...
%
function h = pplan(Plan,ca,varargin) ;
%
% 1. Gestion des données d'entrée
% ---> Pour l'axe d'affichage
if nargin < 2 ;
    % ---> l'axe sera l'axe courant 
    ca = gca ;
end
% ---> Pour la modéfisation du plan
[nl,nc] = size(Plan) ;
if (nl == 1)&(nc == 4) ;
    % ---> On met en forme [2,3] ;
    Temp(2,1:3) = Plan(1:3)  ;                                     % Pour la normale
    Temp(1,1:3) = - (Plan(4) / (norm(Plan(1:3).^2))) * Plan(1:3) ; % Pour le point
    % ---> On écrase la variable précédante
    Plan = Temp ;
end
Plan(2,1:3) = Plan(2,1:3) / norm(Plan(2,1:3)) ;                    % Normale normée
%
% 2. Calcul des variables d'affichage du plan
%
axes(ca) ; % --> Nous nous plaçons dans l'axe courant ;
D = axis ; % ---> Dimension de l'axe courante ;
% ---> Coordonnée
x1 = D(1) ; x2 = D(2) ;
y1 = D(3) ; y2 = D(4) ;
z1 = D(5) ; z2 = D(6) ;
%
% 2.1. Création des huits sommets
%
S = [x1,y1,z1;x1,y1,z2;x1,y2,z1;x1,y2,z2;x2,y1,z1;x2,y1,z2;x2,y2,z1;x2,y2,z2] ;
%
% 2.2. Matrice des arretes du cube axe et des faces
%
C = [1,2;1,3;2,4;3,4;5,6;5,7;6,8;7,8;1,5;2,6;4,8;3,7] ;
F = [1,2;1,5;1,6;1,4;2,3;5,3;6,3;3,4;2,5;2,6;6,4;5,4] ;
%
% 2.3. Matrice des GM.n
%
Delta = dot(S - ones(8,1) * Plan(1,:),ones(8,1) * Plan(2,:),2) ;
%
% 2.4. liste des arretes intersectées
% 
larr = find(0 >= Delta(C(:,1)) .* Delta(C(:,2))) ;
%
% 2.5. Calcul des points d'intersection
% ---> Paramètres de calcul
L = Delta(C(larr,2)) - Delta(C(larr,1)) ;
L1 = (Delta(C(larr,2)) ./ L) * [1,1,1];
L2 = - (Delta(C(larr,1)) ./ L) * [1,1,1];
% ---> Calcul des points
P3D = L1 .* S(C(larr,1),:) + L2 .* S(C(larr,2),:) ;
%
% ---> Mise en ordre des points calculés
%
F = F(larr,:) ;
Ori = F(1,1) ;
Cour = F(1,2) ;
l = 1 ;
for t = 1:length(larr)-1 ;
    % ---> Recherche du point
    [I,J] = find(F == Cour) ;
    I = setdiff(I,l) ;
    % ---> Nouvelle face courante
    Cour = F(I,find(F(I,:) ~= Cour)) ;
    l = [l,I] ;
end
%
% 2.7. Affichage du plan
%
g = patch('vertices',P3D,'faces',l) ;
%
% 2.8. Option du plan
%
if nargin > 2 ;
    set(g,varargin{:}) ;
else
    set(g,'facecolor',[0.2275,0.5608,0.8941],'facealpha',0.5,'edgecolor','k') ;
end
%
% 3. Variable de sortie
%
if nargout == 1 ;
    h = g ;
end
%
% FIN de la fonction