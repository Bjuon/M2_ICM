function P = cone(Xo,Yo,Zo,Vx,Vy,Vz,R,H,N)
%
% Fonction de création de cone à base circulaire de Rayon R de hauteur H
% ---> 
%
if nargin < 9 ;
    N = 20 ; % 20 points sur le cercle générateur
end
if nargin < 8 ;
    H = 1 ; % hauteur unitaire
end
if nargin < 7 ;
    R = 0.5 ; % Pour un diamètre unitaire
end
if nargin < 6
    error('Il faut quand meme donner quelques entrées ...') ;
end
%
% 1. Création du patch cone
% a) normons le vecteur directeur du cone
V = norme_vecteur([Vx,Vy,Vz]) ;
% b) créons un cercle 3d
[X,Y,Z] = circle3(Xo,Yo,Zo,Vx,Vy,Vz,R,N) ;
P.vertices = [X,Y,Z] ;
% c) Auxquels il faut ajouter le sommet du cone
P.vertices = [P.vertices;[Xo+H*V(1),Yo+H*V(2),Zo+H*V(3)]] ;
P.vertices = [P.vertices;Xo,Yo,Zo] ;
% d) Gestion des faces
P.faces = [[1:N-1]',[2:N]',(N+1)*ones(N-1,1)] ;
P.faces = [P.faces;N,1,N+1] ;
Temp = P.faces ; Temp = [Temp(:,2),Temp(:,1),(N+2)*ones(N,1)] ;
P.faces = [P.faces;Temp] ;
% e) coleur par défaut : rouge pour les faces et pas de couleur pour les arretes
P.facecolor = 'r' ;
P.edgecolor = 'none' ;
%
% Fin de la fonction