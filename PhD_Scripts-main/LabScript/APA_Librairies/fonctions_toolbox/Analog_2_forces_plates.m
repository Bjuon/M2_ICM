function RES=Analog_2_forces_plates(analog_RPLATEFORME,corners_VICON,origin_RPLATEFORME)


[COP_RPLATEFORME,Mz]=COP_PFF(analog_RPLATEFORME,origin_RPLATEFORME,0);

R_VICON_RPLATEFORME=pf_frame(corners_VICON,origin_RPLATEFORME);
MH_RPLATEFORME_VICON=repmat(R_VICON_RPLATEFORME,[1,1,size(analog_RPLATEFORME,1)]);
R_VICON_SURFACE = repmat([eye(3),mean(corners_VICON)';0 0 0 1],[1,1,size(analog_RPLATEFORME,1)]);
MH_SURFACE_VICON=R_VICON_SURFACE;

CH_COP_RPLATEFORME = Mat2D_2_MH(COP_RPLATEFORME,'position',1); %Coordonnées Homogènes du COP dans R_PFF_Virtuelle
%     MH_R0  = Mat2D_2_MH(ones(size(Actions_Meca_S,1),1)*[[1,0,0],[0,1,0],[0,0,1],[0,0,0]],'repere',1);
CH_COP_VICON = changement_repere_Legnani(CH_COP_RPLATEFORME, MH_RPLATEFORME_VICON, repmat(eye(4),[1,1,size(analog_RPLATEFORME,1)]),'vecteur');
COP_VICON = Mat2D_2_MH(CH_COP_VICON,'position',-1);

MH_Torseur_RPLATEFORME=Mat2D_2_MH(analog_RPLATEFORME,'dynamique',1);
MH_Torseur_RSURFACE = changement_repere_Legnani(MH_Torseur_RPLATEFORME,MH_RPLATEFORME_VICON,MH_SURFACE_VICON,'dynamique');

analog_SURFACE = Mat2D_2_MH(MH_Torseur_RSURFACE,'dynamique',-1);


centre_VICON = repmat(R_VICON_SURFACE(1:3,4)',[size(analog_RPLATEFORME,1),1]);
RES=[COP_VICON,centre_VICON,analog_SURFACE];
