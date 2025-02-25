function [V_new VCoM V_CG Acc PreTraitementAPA]= calcul_vitesse_CG_v6(Fres,Fech,Data,Fin,P,flag)
% function [V_new VCoM V_CG Acc PreTraitementAPA]= calcul_vitesse_CG_v5(Fres,Fech,Data,Fin,P,flag)
%% Calcul des vitesses du CG par intégration numérique des données PF et dérivation des positions des marqueurs du bassin (si données cinématiques)
% Fres = Composantes X,Y,Z de la GRF (Vecteur réaction de la PF)
% Fech = fréquence d'échantillonage des données (analogiques)
% Data = structure contenant les données d'acquisition (optionnelle pour le calcul par dérivation)
% P = poids du sujet en N (optionnel)
% Fin = index du dernier échantillon
% flag = flag d'affichage (== 0 par défaut)
% SOrties
% V_new = vecteur vitesse du CG [Nx3] obtenu par intégration des données PF
% VCoM = vecteur vitesse du CG [Nx3] obtenu par dérivation des marqueurs du bassin (%%% version 5: on interpole la vitesse dérivée afin que le vecteur ait la même taille que la vitesse intégrée)
% V_CG = vecteur vitesse du CG [Nx3] obtenu par dérivation de la position CG obtenue par le protocole Plug-In-Gait(n = N*Fech_vid/Fech_anlg)
% Acc = accéleration du CG [Nx3] obtenu par la normalisation des données PF par rapport au Poids
% PreTraitementAPA  = structure contenant les valeurs des pic/points d'intérêt dans le calcul des APA sous la forme [indice valeur] [1x2]
%               .Vy_FO1 = vitesse AP du CG lors du FO1
%               .Vm = vitesse maximale AP du CG (qnd Acc == 0)
%               .VZmin_APA = vitesse minimale verticale du CG lors des APA
%               .V1 = vitesse minimale verticale du CG lors de l'éxecution du pas
%               .V2 = vitesse verticale du CG lors du FC1 (Foot-Contact du pied oscillant)
%               .VML_abs = valeur absolue de la vitesse moyenne ML

%% Initialisation
VCoM =[];
V_CG = [];

%% Extraction du poids
if ~exist('P','var')
    P = mean(Fres(20:Fech/2,:),1); % on prend la moyenne de la composante Z sur la 1ère demi-seconde de l'acquisition
end
if ~exist('Fin','var')
    Fin = round(find(Fres(:,3)<10,1,'first')); % Dernière frame sur la PF
    if isempty(Fin)
        Fin = length(Fres);
    end
end

F0 = repmat(P,length(Fres),1);
% F0 = repmat([0 0 P(3)],length(Fres),1);
gravite = 9.80928; % observatoire gravimétrique de strasbourg
M = P/gravite;
Acc = (Fres-repmat(P,length(Fres),1))./repmat(M,length(Fres),1); % Accéleration = GRF/m

%Préconditionnement du vecteur réaction sur la bonne durée (pour l'intégration)
Fin_pf = find(Fres(:,3)<15,1,'first');
if Fin_pf<length(Fres)/3
    Fin_pf = length(Fres);
end
Fres = (Fres - F0).*1/(P(3)/gravite); % Vecteur (GRF - P) à integré

%% Intégration
V_new=[];
t_PF=(0:Fin-1).*1/Fech; % on ajoute la variable temporelle
for ii=1:3
    y=Fres(:,ii); 
    try % via la toolbox 'Curve Fitting'
        y_t = csaps(t_PF,y);  % on créé une spline
        intgrf = fnint(y_t); % on intègre
        V_new(:,ii)= fnval(intgrf,t_PF);
    catch ERR % sinon par intégration numérique par la méthode des trapèzes
        V_new(:,ii) = cumtrapz(t_PF,y); %Intégration grossière par la méthode des trapèzes
    end
end

% Pour la visu, on remplace toutes les valeurs suivant la PF par la dernière valeure
V0 = V_new(Fin_pf,:);
dim_end = length(V_new)-Fin_pf;
V_new(Fin_pf+1:end,:) = repmat(V0,dim_end,1);
PreTraitementAPA ={};

%% Dérivation
if exist('Data','var')
    % Calcul du Centre de Gravité du sujet
    try
        CG_Vic = squeeze(extraire_coordonnees_v2(Data,{'CentreOfMass'}))'; % Calculé par Plug-In-Gait
        CoM = squeeze(barycentre_v2(extraire_coordonnees_v2(Data,{'RASI','LASI','RPSI','LPSI'})))'; % Calculé comme barycentre des épines iliaques du bassin
        Fech_vid = round(Fech * length(Data.coord)/length(Data.actmec)); % On réestime la fréquence d'échantillonage vidéo
        
        Fin_vid = round(Fin * Fech_vid/Fech); % On réestime la dernière 'frame' vidéo
        t_vid=(0:Fin_vid-1).*1/Fech_vid; % on ajoute la variable temporelle
        VCoM_pre=zeros(length(t_vid),3);
        V_CG=zeros(length(t_vid),3);
        
        %On retire les NaN avant dérivation et filtrage
        l = sum(isnan(CoM(1:Fin_vid,:)),2)>1;
        ll = sum(isnan(CG_Vic(1:Fin_vid,:)),2)>1;
        
        for ii=1:3
            y=CoM(~l,ii);
            %Dérivation barycentre marqueurs bassin
            try % via la toolbox 'Curve Fitting'                
                y_t_vid = csaps(t_vid(~l),y);  % on créé une spline
                derCoM = fnder(y_t_vid); % on dérive
                VCoM_pre= fnval(derCoM,t_vid(~l))./1000;
            catch ERRR % sinon par dérivation numérique d'ordre 4
                VCoM_pre = derive_MH_VAH(y,Fech_vid)./1000;
            end
            
            %Verification des écarts entre les méthodes (intégration vs. dérivation) (car parfois la fonction 'fnder' déconne)
            if abs(nanmean(VCoM_pre(:,ii))-nanmean(V_new(:,ii)))>1
                VCoM_pre = derive_MH_VAH(y,Fech_vid)./1000;
            end
            
            VCoM(~l,ii) = filtrage(VCoM_pre,'b',3,5,Fech_vid); %Lissage (filtre passe-bas de ButterWorth à 5Hz)
            
            %Dérivation CG Plug-In-Gait
            if ~isnan(CG_Vic)
                yy = CG_Vic(ll,ii);
                try
                    yy_t = csaps(t_vid(~l),yy);
                    derCG = fnder(yy_t);
                    V_CG((~l),ii) = fnval(derCG,t_vid(~l))/1000;
                catch ERRRR
                    V_CG((~l),ii) = derive_MH_VAH(yy,Fech_vid)/1000;
                end
            end
        end
        
        %% Interpolation du vecteur dérivé (sur-échantillonnage à Fech)
        if Fech_vid<Fech
            try
                VCoM = interp1(t_vid,VCoM,t_PF);
                V_CG = interp1(t_vid,V_CG,t_PF);
            catch
                disp('Pas d''interpolation à la vitesse derivée');
            end
        end
    catch ERRR
        disp('PAs de données vidéos pour le calcul du CG');
%         VCoM = NaN*ones(length(V_new),3);
%         V_CG = NaN*ones(length(V_new),3);
    end
    
%     %Verification des écarts entre les méthodes
%     V_CoM_moy = mean(VCoM(1:length(Fres),:)); %Dérivation Barycentre des épines
%     V_new_moy = mean(V_new(1:length(Fres),:)); %Intégration PF
%     V_CG_moy = mean(V_CG(1:length(Fres),:)); %Dérivation PIG
%     ecart=std([V_CoM_moy(2) V_new_moy(2) V_CG_moy(2)]); %Ecart-type entre les 3 valeurs moyennes calculés en AP

    %% Détection des pics de vitesses
    evts = sort(Data.events.temps); %Extraction de la zone d'étude
    
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
        %V2 (Vitesse verticale à FC1)
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
    if exist('flag','var');
        figure; hold on;
        subplot(3,1,1);
        plot(t_vid,CoM(:,3),'og'); hold on
        plot(t_vid,CG_Vic(:,3),'-b');
        legend('CG Dérivation','PIG');
        ylabel('mm');
        
        subplot(3,1,2);
        plot(t_vid,VCoM(:,2),'-b'); hold on;
        plot(t_vid,V_CG(:,2),'.-b');
        plot(t_PF,V_new(:,2),'.-r');
        ylabel('AP m/s');
        legend('Dérivation','PIG','IntégrationPF');
        plot(t_PF(PreTraitementAPA.Vm(1,1)),V_new(PreTraitementAPA.Vm(1,1),2),'x','Markersize',11);
        
        subplot(3,1,3);
        plot(t_vid,VCoM(:,3),'-b'); hold on;
        plot(t_vid,V_CG(:,3),'.-b');
        plot(t_PF,V_new(:,3),'.-r');
        ylabel('Vertical m/s');
        xlabel('sec');
        legend('Dérivation','PIG','IntégrationPF');
        plot(t_PF(PreTraitementAPA.VZmin_APA(1,1)),V_new(PreTraitementAPA.VZmin_APA(1,1),3),'x','Markersize',11);
        plot(t_PF(PreTraitementAPA.V1(1,1)),V_new(PreTraitementAPA.V1(1,1),3),'x','Markersize',11);
        plot(t_PF(PreTraitementAPA.V2(1,1)),V_new(PreTraitementAPA.V2(1,1),3),'x','Markersize',11);      
    end
end

end