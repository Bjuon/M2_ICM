function [COP,Moment_libre]=COP_PFF(Mat_E,centre_old,z)

%%
% Calcul la position du centre de pression dans le cas d'une plateforme de
% force



% Variable(s) Entree(s)
% - Mat_E : Torseur dynamique sous la forme[Fx,Fy,Fz,Mx,My,Mz]
% - z : hauteur du plateau de la plateforme par rapport à l'origine
%
% Variable(s) Sortie(s)
% - COP : Coordonnées du centre de pression

%% Auteur(s)
%
% Auteurs : C. Sauret modifie par H Pillet
% Date de création : 28-10-2011
% Créé dans le cadre de : Projet APSIC

%% Modif(s) :
%
% Auteurs : 
% Date :
% Notes :

%%
%Mat_E doit être [Fx,Fy,Fz,Mx,My,Mz]
Fx=Mat_E(:,1);
Fy=Mat_E(:,2);
Fz=Mat_E(:,3);
Mxo=Mat_E(:,4);
Myo=Mat_E(:,5);
Mzo=Mat_E(:,6);
xo=centre_old(1,1);
yo=centre_old(1,2);
zo=centre_old(1,3);
% z=centre_new(1,3);
% 
xc= xo+(-Myo + (z-zo) * Fx)./Fz;
yc= yo+(Mxo + (z-zo) * Fy)./Fz;
zc=ones(size(Mat_E,1),1)*(z-zo);

COP=[xc, yc, zc];
 COP(find(abs(Fz)<10),:)=NaN;

Moment_libre = Mzo + (xo-xc) .* Fy - (yo-yc) .* Fx;


