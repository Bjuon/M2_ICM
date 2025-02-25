function Mat_S=Mat2D_2_MH(Mat_E,TypeMH,Sens)

%%
% Permet de passrr d'une matrice 2D avec par exemple [Fx,Fy,Fz,Mx,My,Mz] à
% une matrice homogène (1) et inversement (-1)

% Cette fonction peut être utilisée pour
% - Coordonnées d'un point avec TypeMH = 'position'
% - Position et orientation d'un référentiel avec TypeMH = 'repere'
% - Torseur cinématique avec TypeMH = 'vitesse'
% - Torseur d'actions mécaniques avec TypeMH = 'dynamique'


% Variable(s) Entree(s)
% - Mat_E : Matrice à reconditionner
% - TypeMH : Type de matrice homogène
% - Sens : choix du reconditionnement : Mat2D=>MH (1) ou MH=>Mat2D (-1)
%
% Variable(s) Sortie(s)
% - Mat_S : Matrice reconditionnée

%% Auteur(s)
%
% Auteurs : C. Sauret
% Date de création : 28-10-2011
% Créé dans le cadre de : Projet APSIC

%% Modif(s) :
%
% Auteurs : 
% Date :
% Notes :

%% Traitement Mat2D => MH (Sens=1)

if Sens==1 %Mat2D => MH
    
    
    switch TypeMH
         case 'position'
          %Mat_E doit être [x,y,z]
          Mat_S=ones(4,1,size(Mat_E,1));
          Mat_S(1:3,1,:)=permute(Mat_E(:,1:3)',[1,3,2]);
         
        case 'repere'
         %Mat_E doit être [X',Y',Z',O] soit (Xx,Xy,Xz,Yx,Yy,Yz,Zx,Zy,Zz,Ox,Oy,Oz]
         Mat_S=zeros(4,4,size(Mat_E,1));
         Mat_S(1:3,1,:)=permute(Mat_E(:,1:3)',[1,3,2]); %X
         Mat_S(1:3,2,:)=permute(Mat_E(:,4:6)',[1,3,2]); %Y
         Mat_S(1:3,3,:)=permute(Mat_E(:,7:9)',[1,3,2]); %Z
         Mat_S(1:3,4,:)=permute(Mat_E(:,10:12)',[1,3,2]); %O
         Mat_S(4,4,:)=1;
         
        case 'vitesse'
         %Mat_E doit être [Vx,Vy,Vz,Wx,Wy,Wz]
         Mat_S=zeros(4,4,size(Mat_E,1));
           %Vitesse de translation
            Mat_S(4,1:3,:)=permute(Mat_E(:,1:3)',[1,3,2]);
           %Vitesse de rotation
            Mat_S(2,1,:)=permute(Mat_E(:,6),[3,2,1]); Mat_S(1,2,:)=-Mat_S(2,1,:);
            Mat_S(1,3,:)=permute(Mat_E(:,5),[3,2,1]); Mat_S(3,1,:)=-Mat_S(1,3,:);
            Mat_S(3,2,:)=permute(Mat_E(:,4),[3,2,1]); Mat_S(2,3,:)=-Mat_S(3,2,:);
           
        case 'dynamique'
         %Mat_E doit être [Fx,Fy,Fz,Mx,My,Mz]
           Mat_S=zeros(4,4,size(Mat_E,1));
           %Forces
            Mat_S(1:3,4,:)=permute(Mat_E(:,1:3)',[1,3,2]);
            Mat_S(4,1:3,:)=permute(-Mat_E(:,1:3),[3,2,1]);
           %Moments
            Mat_S(2,1,:)=permute(Mat_E(:,6),[3,2,1]); Mat_S(1,2,:)=-Mat_S(2,1,:);
            Mat_S(1,3,:)=permute(Mat_E(:,5),[3,2,1]); Mat_S(3,1,:)=-Mat_S(1,3,:);
            Mat_S(3,2,:)=permute(Mat_E(:,4),[3,2,1]); Mat_S(2,3,:)=-Mat_S(3,2,:);
    
        otherwise
        
    end
    
%% Traitement MH => Mat2D (Sens = -1) 
elseif Sens==-1 %MH => Mat2D
    
    switch TypeMH
        case 'position'
           Mat_S=permute(Mat_E(1:3,1,:),[3,1,2]);
        
        case 'repere'
            Mat_S=[permute(Mat_E(1:3,1,:),[3,1,2]),...
                   permute(Mat_E(1:3,2,:),[3,1,2]),...
                   permute(Mat_E(1:3,3,:),[3,1,2]),...
                   permute(Mat_E(1:3,4,:),[3,1,2])];
               
        case 'vitesse'
            Mat_S=[permute(Mat_E(1:3,4,:),[3,1,2]),...
                   permute(Mat_E(3,2,:),[3,1,2]),...
                   permute(Mat_E(1,3,:),[3,1,2]),...
                   permute(Mat_E(2,1,:),[3,1,2])];
        case 'dynamique'
            Mat_S=[permute(Mat_E(1:3,4,:),[3,1,2]),...
                   permute(Mat_E(3,2,:),[3,1,2]),...
                   permute(Mat_E(1,3,:),[3,1,2]),...
                   permute(Mat_E(2,1,:),[3,1,2])];

        otherwise
    end
    
end