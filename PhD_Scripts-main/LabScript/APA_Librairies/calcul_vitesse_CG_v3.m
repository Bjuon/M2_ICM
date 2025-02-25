function [V_new VCoM V_CG Acc PreTraitementAPA]= calcul_vitesse_CG_v3(Fres,Fech,Data,P,flag)
%% Calcul des vitesses du CG par int�gration num�rique des donn�es PF et d�rivation des positions des marqueurs du bassin (si donn�es cin�matiques)
% Fres = Composantes X,Y,Z de la GRF (Vecteur r�action de la PF)
% Fech = fr�quence d'�chantillonage des donn�es (vid�o)
% Data = structure contenant les donn�es d'acquisition (optionnelle pour le calcul par d�rivation)
% P = poids du sujet en N (optionnel)
% flag = flag d'affichage (== 0 par d�faut)
% SOrties
% V_new = vecteur vitesse du CG [Nx3] obtenu par int�gration des donn�es PF
% VCoM = vecteur vitesse du CG [Nx3] obtenu par d�rivation des marqueurs du bassin
% V_CG = vecteur vitesse du CG [Nx3] obtenu par d�rivation de la position CG obtenue par le protocole Plug-In-Gait
% Acc = acc�leration du CG [Nx3] obtenu par la normalisation des donn�es PF par rapport au Poids
% PreTraitementAPA  = structure contenant les valeurs des pic/points d'int�r�t dans le calcul des APA sous la forme [indice valeur] [1x2]
%               .Vy_FO1 = vitesse AP du CG lors du FO1
%               .Vm = vitesse maximale AP du CG (qnd Acc == 0)
%               .VZmin_APA = vitesse minimale verticale du CG lors des APA
%               .V1 = vitesse minimale verticale du CG lors de l'�xecution du pas
%               .V2 = vitesse verticale du CG lors du FC1 (Foot-Contact du pied oscillant)
%               .VML_abs = valeur absolue de la vitesse moyenne ML

%% Initialisation
VCoM =[];
V_CG = [];

%% Extraction du poids
if ~exist('P','var')
    P = mean(Fres(20:Fech/2,:),1); % on prend la moyenne de la composante Z sur la 1�re demi-seconde de l'acquisition
end

F0 = repmat(P,length(Fres),1);
% F0 = repmat([0 0 P(3)],length(Fres),1);
gravite = 9.80928; % observatoire gravim�trique de strasbourg
M = P/gravite;
Acc = (Fres-repmat(P,length(Fres),1))./repmat(M,length(Fres),1); % Acc�leration = GRF/m

%Pr�conditionnement du vecteur r�action � la dur�e sur la PF
Last = round(find(Fres==0,1,'first')); % Derni�re frame sur la PF        
Fres = (Fres - F0).*1/(P(3)/gravite); % Vecteur (GRF - P) � integr�

%% Int�gration
V_new=[];y=[];t=[];
for ii=1:3
    y=Fres(:,ii);
    t=(1:length(y)).*1/Fech; % on ajoute la variable temporelle
    try % via la toolbox 'Curve Fitting'
        y_t = csaps(t,y);  % on cr�� une spline
        intgrf = fnint(y_t); % on int�gre
        V_new(:,ii)= fnval(intgrf,t);
    catch ERR % sinon par int�gration num�rique par la m�thode des trap�zes
        V_new(:,ii) = cumtrapz(t,y); %Int�gration grossi�re par la m�thode des trap�zes
    end
end

PreTraitementAPA ={};

%% D�rivation
if exist('Data','var')
    % Calcul du Centre de Gravit� du sujet
    try
        CG_Vic = squeeze(extraire_coordonnees_v2(Data,{'CentreOfMass'}))'; % Calcul� par Plug-In-Gait
        CoM = squeeze(barycentre(extraire_coordonnees_v2(Data,{'RASI','LASI','RPSI','LPSI'})))'; % Calcul� comme barycentre des �pines iliaques du bassin
    
        VCoM=zeros(length(CoM),3);
        V_CG=zeros(length(CG_Vic),3);
        
        for ii=1:3
            y=CoM(:,ii);
            t=(1:length(y))*.1/Fech; % on ajoute la variable temporelle
            %D�rivation barycentre marqueurs bassin
            try % via la toolbox 'Curve Fitting'                
                y_t = csaps(t,y);  % on cr�� une spline
                derCoM = fnder(y_t); % on d�rive
                VCoM(:,ii)= fnval(derCoM,t)/1000;
            catch ERRR % sinon par d�rivation num�rique d'ordre 4
                VCoM(:,ii) = derive_MH_VAH(y,Fech)/1000;
            end
            VCoM = filtrage(VCoM,'s',3,Fech/5,Fech); %Filtrage de 'Stavitsky-Golay'
            
            %D�rivation CG Plug-In-Gait
            if ~isnan(CG_Vic)
                yy = CG_Vic(:,ii);
                try
                    yy_t = csaps(t,yy);
                    derCG = fnder(yy_t);
                    V_CG(:,ii) = fnval(derCG,t)/1000;
                catch ERRRR
                    V_CG(:,ii) = derive_MH_VAH(yy,Fech)/1000;
                end
            end
        end
    catch ERRR
        disp('PAs de donn�es vid�os pour le calcul du CG');
%         VCoM = NaN*ones(length(V_new),3);
%         V_CG = NaN*ones(length(V_new),3);
    end
    
%     %Verification des �carts entre les m�thodes
%     V_CoM_moy = mean(VCoM(1:length(Fres),:)); %D�rivation Barycentre des �pines
%     V_new_moy = mean(V_new(1:length(Fres),:)); %Int�gration PF
%     V_CG_moy = mean(V_CG(1:length(Fres),:)); %D�rivation PIG
%     ecart=std([V_CoM_moy(2) V_new_moy(2) V_CG_moy(2)]); %Ecart-type entre les 3 valeurs moyennes calcul�s en AP

    %% D�tection des pics de vitesses
    evts = sort(Data.events.temps); %Extraction de la zone d'�tude
    
    ind_HO = round(evts(1)*Fech);
    ind_TO = round(evts(2)*Fech);
    try
        ind_FC1 = round(evts(3)*Fech);
    catch NO_FC1
        ind_FC2 = length(V_CG)-100;
    end
    try
        ind_FC2 = round(evts(5)*Fech);
    catch No_FC2
        ind_FC2 = length(V_CG)-10;
    end
    
    
    try
        %Vy_FO1 (Vitesse AP du CG au foot-off (FO1)
        PreTraitementAPA.Vy_FO1(1,1) = ind_TO+1; %%
        PreTraitementAPA.Vy_FO1(1,2) = V_new(ind_TO+1,2);
        %VZmin_APA (1er minima avant TO)
        [PreTraitementAPA.VZmin_APA(1,2) PreTraitementAPA.VZmin_APA(1,1)] = min(V_new(1:ind_TO,3));
    catch Err_ind_TO
        PreTraitementAPA.Vy_FO1(1:2) = NaN;
        PreTraitementAPA.VZmin_APA(1:2) = NaN;
    end

    
    %Vm (Pic max avant FC2)
%     ind = find(Acc(ind_HO:ind_FC2,2)<0.3,1,'first')-1; % ou find(Acc(ind_HO:ind_FC2,2)==0,1,'first');
%     PreTraitementAPA.Vm(1,:) = [ind_HO+ind V_new(ind,2)];
    try
        [PreTraitementAPA.Vm(1,2) ind] = max(V_new(ind_HO:ind_FC2-10,2));
        PreTraitementAPA.Vm(1,1) = ind_HO + ind;
    catch ERR_FC2
        PreTraitementAPA.Vm(1:2) = NaN;
    end
    
    try
        %V1 (Minima entre HO et FC1)
        [PreTraitementAPA.V1(1,2) ind] = min(V_new(ind_HO:ind_FC1,3));
        PreTraitementAPA.V1(1,1) = ind_HO + ind; %%
        %V2 (Vitesse verticale � FC1)
        PreTraitementAPA.V2(1,1) = ind_FC1+1;
        PreTraitementAPA.V2(1,2) = V_new(ind_FC1+1,3);%%
    catch Err_FC1
        [PreTraitementAPA.V1(2)  PreTraitementAPA.V1(1)]= min(V_new(:,3));
        PreTraitementAPA.V2(1:2) = NaN;
    end
    
    %VML_abs (valeur absolue de la vitesse moyenne ML lors de la marche sur PF)
    try
        PreTraitementAPA.VML_abs = abs(mean(V_new(ind_TO:Last-5,1)));
    catch ERR
        PreTraitementAPA.VML_abs = NaN;
    end
    
    %% Affichage (si flag existe)
    if exist('flag','var')
        Fres = Fres(1:Last-5,:);
        t=t(1:length(Fres));
        figure; hold on;
        subplot(3,1,1);
        plot(t,CoM(1:length(Fres),3),'og'); hold on
        plot(t,CG_Vic(1:length(Fres),3),'-b');
        legend('CG D�rivation','PIG');
        ylabel('mm');
        
        subplot(3,1,2);
        plot(t,VCoM(1:length(Fres),2),'-b'); hold on;
        plot(t,V_CG(1:length(Fres),2),'.-b');
        plot(t,V_new(1:length(Fres),2),'.-r');
        ylabel('AP m/s');
        legend('D�rivation','PIG','Int�grationPF');
        plot(t(PreTraitementAPA.Vm(1,1)),V_new(PreTraitementAPA.Vm(1,1),2),'x','Markersize',11);
        
        subplot(3,1,3);
        plot(t,VCoM(1:length(Fres),3),'-b'); hold on;
        plot(t,V_CG(1:length(Fres),3),'.-b');
        plot(t,V_new(1:length(Fres),3),'.-r');
        ylabel('Vertical m/s');
        xlabel('sec');
        legend('D�rivation','PIG','Int�grationPF');
        plot(t(PreTraitementAPA.VZmin_APA(1,1)),V_new(PreTraitementAPA.VZmin_APA(1,1),3),'x','Markersize',11);
        plot(t(PreTraitementAPA.V1(1,1)),V_new(PreTraitementAPA.V1(1,1),3),'x','Markersize',11);
        plot(t(PreTraitementAPA.V2(1,1)),V_new(PreTraitementAPA.V2(1,1),3),'x','Markersize',11);      
    end
end

end