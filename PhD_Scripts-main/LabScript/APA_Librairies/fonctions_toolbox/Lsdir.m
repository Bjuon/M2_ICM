function listedir = lsdir(chemin) ;
%
% Récupération du contenu de chemin
%
Contenu_chemin = dir(chemin) ;
%
% Taille de chemin
%
Taille = size(Contenu_chemin,1) ;
%
% Recherche des directories
%
n_dir = 1 ; % compteur de dir
%
for ttt = 1:Taille ;
   if Contenu_chemin(ttt).isdir
      listedir{n_dir} = Contenu_chemin(ttt).name ;
      n_dir = n_dir + 1 ;
   end
end
%
% Fin de la fonction
