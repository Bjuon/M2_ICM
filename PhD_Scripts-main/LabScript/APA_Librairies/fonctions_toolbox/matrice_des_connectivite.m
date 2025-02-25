function MatConnect = Matrice_des_connectivite(Objet)
%
% Construction de la matrice des connectivit� pour une surface triangul�e
% consid�r�e comme un graphe non-orient� !!!
%

% ---> Def des variables :
N = Objet.Noeuds ;
P = Objet.Polygones ;
Arr = analyse_arretes(P) ;
% ---> Supression des variables inutiles
clear Objet
% ---> Initialisation de la variable de sortie
MatConnect = sparse(size(N,1),size(N,1)) ;
% ---> Premier remplissage
MatConnect(sub2ind(size(MatConnect),Arr.Definition(:,1),Arr.Definition(:,2))) = 1 ;
% ---> Le graphe n'est pas orient� et non boucl�
MatConnect = MatConnect + MatConnect' ;                    
MatConnect(sub2ind(size(MatConnect),[1:size(MatConnect,1)],[1:size(MatConnect,1)])) = 1 ;
%
% Fin de la fonction