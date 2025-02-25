function MH_VICON_PF=pf_frame(C_vicon,origin_RPLATEFORME)

% calcul du repere plateforme à partir des 4 coins dans le repere vicon
% creation du repere plateau surface
O = mean(C_vicon);
X = (C_vicon(1,:)-C_vicon(2,:))/norm(C_vicon(1,:)-C_vicon(2,:));
Y = (C_vicon(1,:)-C_vicon(4,:))/norm(C_vicon(1,:)-C_vicon(4,:));
Z = cross(X,Y);
Z=Z/norm(Z);
MH_VICON_PSURFACE = [X',Y',Z',O';0 0 0 1];
% calcul du centre du repere plateforme a partir de l'origine dans le
% repère plateforme
O_PF_VICON = MH_VICON_PSURFACE*[origin_RPLATEFORME,1]';

MH_VICON_PF=MH_VICON_PSURFACE;
MH_VICON_PF(:,4)=O_PF_VICON;