function [V_new VCoM V_CG Acc PreTraitementAPA]= calcul_vitesse_CG_v3(Fres,Fech,Data,flag,P)
%% Calcul des vitesses du CG par int�gration num�rique
% Fres = Composants de la GRF
% Fech = fr�quence d'�chantillonage des donn�es (vid�o)
% P = poids du sujet en N (optionnel)
% Data = structure contenant les donn�es d'acquisition (optionnelle)
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

%% Extraction du poids
if ~exist('P','var')
    P = mean(Fres(20:Fech/2,:),1); % on prend la moyenne de la composante Z sur la 1�re demi-seconde de l'acquisition
end

F0 = repmat(P,length(Fres),1);
% F0 = repmat([0 0 P(3)],length(Fres),1);
gravite = 9.80928; % observatoire gravim�trique de strasbourg
Acc = Fres.*1/(P(3)/gravite); % Acc�leration = GRF/m

%Pr�conditionnement du vecteur r�action � la dur�e sur la PF
Last = round(find(Fres==0,1,'first')); % Derni�re frame sur la PF        
Fres = (Fres - F0).*1/(P(3)/gravite); % Vecteur (GRF - P) � integr�

%% Int�gration
V_new=[];y=[];t=[];
ordre = 4;
for ii=1:3
 y=Fres(:,ii);
            t=[1:length(y)]*1/Fech; % on ajoute la variable temporelle
%             y_t = csaps(t,y);  % on cr�� une spline
%          intgrf = fnint(y_t); % on int�gre
%        V_new(:,ii)= fnval(intgrf,t);
        p = polyfit(t',y,ordre);
        p_int = polyint(p);
        V_new(:,ii) = polyval(p_int,t);
end

PreTraitementAPA ={};
%% On s'assure de l'ordre de grandeur
if exist('Data','var')
    %% Calcul des Centre de Gravit� du sujet
    CG_Vic = squeeze(extraire_coordonnees_v2(Data,{'CenterOfMass'}))'; % Celui calcul� par Plug-In-Gait
    CoM = squeeze(barycentre(extraire_coordonnees_v2(Data,{'RASI','LASI','RPSI','LPSI'})))'; %Celui calcul� comme barycentre des �pines iliaques du bassin
    
    %% Calcul directe (par d�rivation) des vitesses du CG
    VCoM=zeros(length(CoM),3);
    V_CG=zeros(length(CG_Vic),3);
    for ii=1:3
        y=CoM(:,ii);        
        t=[1:length(y)]*1/Fech; % on ajoute la variable temporelle
%         y_t = csaps(t,y);  % on cr�� une spline         
%         derCoM = fnder(y_t); % on d�rive         
%         VCoM(:,ii)= fnval(derCoM,t)/1000;       
%         VCoM = filtrage(VCoM,'s',Fech/5); %Filtrage de 'Stavitsky-Golay'
        p = polyfit(t',y,ordre);
        p_der = polyder(p);
        VCoM(:,ii) = polyval(p_der,t);
        
        if ~isnan(CG_Vic)
            yy = CG_Vic(:,ii);
%             yy_t = csaps(t,yy);
%             derCG = fnder(yy_t);
%             V_CG(:,ii) = fvnal(derCG,t)/1000; %D�rivation Plug-In-Gait
            p = polyfit(t',yy,ordre);
            p_der = polyder(p);
            V_CG(:,ii) = polyval(p_der,t);
        end
    end
    
%     V_CoM_moy = mean(VCoM(1:length(Fres),:)); %D�rivation Barycentre des �pines
%     V_new_moy = mean(V_new(1:length(Fres),:)); %Int�gration PF
%     V_CG_moy = mean(V_CG(1:length(Fres),:)); %D�rivation PIG
%     ecart=std([V_CoM_moy(2) V_new_moy(2) V_CG_moy(2)]); %Ecart-type entre les 3 valeurs moyennes calcul�s en AP
    %% D�tection des pics de vitesses
    evts = sort(Data.events.temps) %Extraction de la zone d'�tude
    ind_HO = floor(evts(1)*Fech);
    ind_TO = floor(evts(2)*Fech);
    ind_FC1 = floor(evts(4)*Fech);
    ind_FC2 = floor(evts(5)*Fech);
    
    %Vy_FO1 (Vitesse AP du CG au foot-off (FO1)
    PreTraitementAPA.Vy_FO1(1,1) = ind_HO;
    PreTraitementAPA.Vy_FO1(1,2) = V_new(ind_HO,2);
    
    %Vm (Pic max avant FC2)
%     ind = find(Acc(ind_HO:ind_FC2,2)<0.3,1,'first')-1; % ou find(Acc(ind_HO:ind_FC2,2)==0,1,'first');
%     PreTraitementAPA.Vm(1,:) = [ind_HO+ind V_new(ind,2)];
    [PreTraitementAPA.Vm(1,2) ind] = max(V_new(ind_HO:ind_FC2-10,2));
    PreTraitementAPA.Vm(1,1) = ind_HO + ind;
    
    %VZmin_APA (1er minima avant TO)
    [PreTraitementAPA.VZmin_APA(1,2) PreTraitementAPA.VZmin_APA(1,1)] = min(V_new(1:ind_TO,3));
    
    %V1 (Minima entre HO et FC1)
    [PreTraitementAPA.V1(1,2) ind] = min(V_new(ind_HO:ind_FC1,3));
    PreTraitementAPA.V1(1,1) = ind_HO + ind;
    
    %V2 (Vitesse verticale � FC1)
    PreTraitementAPA.V2(1,1) = ind_FC1;
    PreTraitementAPA.V2(1,2) = V_new(ind_FC1,3);
    
    %VML_abs (valeur absolue de la vitesse moyenne ML lors de la marche sur PF)
    PreTraitementAPA.VML_abs = abs(mean(V_new(ind_TO:Last-5,1)));
    
    %% Affichage
    if exist('flag','var')
        Fres = Fres(1:Last-5,:);
        t=t(1:length(Fres));
        figure; hold on;
        subplot(3,1,1);
        plot(t,CoM(1:length(Fres),3),'og'); hold on
        fastplot(t,CG_Vic(1:length(Fres),3),'-b');
        legend('CG D�rivation','PIG');
        ylabel('mm');
        
        subplot(3,1,2);
        plot(t,VCoM(1:length(Fres),2),'-b'); hold on;
        plot(t,V_CG(1:length(Fres),2),'.-b');
        plot(t,V_new(1:length(Fres),2),'-r');
        ylabel('AP m/s');
        legend('D�rivation','PIG','Int�grationPF');
        plot(t(PreTraitementAPA.Vm(1,1)),V_new(PreTraitementAPA.Vm(1,1),2),'x','Markersize',11);
        
        subplot(3,1,3);
        plot(t,VCoM(1:length(Fres),3),'-b'); hold on;
        plot(t,V_CG(1:length(Fres),3),'.-b');
        plot(t,V_new(1:length(Fres),3),'-r');
        ylabel('Vertical m/s');
        xlabel('sec');
        legend('D�rivation','PIG','Int�grationPF');
        plot(t(PreTraitementAPA.VZmin_APA(1,1)),V_new(PreTraitementAPA.VZmin_APA(1,1),3),'x','Markersize',11);
        plot(t(PreTraitementAPA.V1(1,1)),V_new(PreTraitementAPA.V1(1,1),3),'x','Markersize',11);
        plot(t(PreTraitementAPA.V2(1,1)),V_new(PreTraitementAPA.V2(1,1),3),'x','Markersize',11);      
    end
end

end