function droite = creer_droite(P1,P2) ;
%
% nous choisissons comme point origine des droites les points P1
%
droite.pts = P1 ;
%
% Pour chacune des droites nous calculons les vecteurs directeurs
%
dim = size(P1,2) ; % dimension de l'espace
%
% Normes des vecteurs P2 P1
%
Normes = norm2(P2-P1) ;
%
for t = 1:dim ;
   %
   % le vecteur directeur est normé
   %
   droite.V_dir(:,t) = (P2(:,t)-P1(:,t))./Normes;
   %
end
%
% fin de la fonction