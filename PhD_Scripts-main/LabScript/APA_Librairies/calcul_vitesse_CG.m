function V_new = calcul_vitesse_CG(Fres,Fech,Data,V0,P)
%% Calcul des vitesses du CG par intégration numérique
% Fres = Composants de la GRF
% Fech = fréquence d'échantillonage des données (vidéo)
% V0 = vecteure vitesse initiale utilisée comme constante l'intégration(optionnelle)
% P = poids du sujet (en N)
% Data = structure contenant les données d'acquisition (optionnelle)

%% Extraction du poids et de la vitesse moyenne du 1er pas
if nargin <4
    P = mean(Fres(20:Fech/2,:),1); % on prend la moyenne de la composante Z sur la 1ère demi-seconde de l'acquisition
    %Calcul de la vitesse moyenne du sacrum sur le 1er pas
    Sacr = barycentre(extraire_coordonnees_v2(Data,{'RPSI','LPSI'}));
    TO = round(Data.events.temps(1)*Fech); 
%     Last = round(Data.events.temps(7)*Fech); %On suppose que le 7ème evenement correspond à la fin du dernier pas sur la PF
    Last = round(find(Fres==0,1,'first')); % Dernière frame sur la PF
    V0 = nanmean(squeeze(derive_MH_NAN(Sacr(:,:,TO-5:Last+5),Fech))');
%     CG_Vic = extraire_coordonnees_v2(Data,{'CenterOfMass'});
%     V0_Vic = nanmean(squeeze(derive_MH_NAN(CG_Vic(:,:,TO-5:FC+5),Fech))');
    
    %Préconditionnement du vecteur réaction à la durée sur la PF
    Fres = Fres(1:Last,:);
end

% F0 = repmat(P,length(Fres),1);
F0 = repmat([0 0 P(3)],length(Fres),1);
gravite = 9.80928; % observatoire gravimétrique de strasbourg

Fres = (Fres - F0).*1/(P(3)/gravite); % On normalise à la masse

%% Intégration
V_new=[];y=[];t=[];
for ii=1:3
 y=Fres(:,ii);
            t=[1:length(y)]*1/Fech; % on ajoute la variable temporelle
            y_t = csaps(t,y,1);  % on créé une spline
         intgrf = fnint(y_t); % on intègre
       V_new(:,ii)= fnval(intgrf,t);
end

% % ajout de la bonne composante d'intégration
% if isscalar(V0)
%     Constante_INT = [0 V0 0]; %% a revoir
% else
%     Constante_INT = [0 V0(2) 0];
% end
% 
% ecart = mean(V) + Constante_INT;
% V_new = (V-repmat(ecart,length(V),1))/1000;
% 
%% On s'assure de l'ordre de grandeur
if exist('Data','var')
    %Calcul des Centre de Gravité du sujet
    CG_Vic = squeeze(extraire_coordonnees_v2(Data,{'CenterOfMass'}))'; % Celui calculé par Plug-In-Gait
    CoM=squeeze(barycentre(extraire_coordonnees_v2(Data,{'RASI','LASI','RPSI','LPSI'})))'; %Celui calculé comme barycentre des épines iliaques du bassin
    
    %Calucul directe (par dérivation) des vitesses du CG
    VCoM=zeros(length(CoM),3);
    V_CG=zeros(length(CG_Vic),3);
    for ii=1:3
        y=CoM(:,ii);
%         yy = CG_Vic(:,ii);
        t=[1:length(y)]*1/Fech; % on ajoute la variable temporelle
        y_t = csaps(t,y);  % on créé une spline
%         yy_t = csaps(t,yy);
        derCoM = fnder(y_t); % on dérive
%         derCG = fnder(yy_t);
        VCoM(:,ii)= fnval(derCoM,t)/1000;
%         V_CG(:,ii) = fvnal(derCG,t)/1000;
        VCoM_filtre = filtrage(VCoM,'s',Fech/4); %Filtrage de 'Stavitsky-Golay'
    end
    
    V_CG = mean(V_CG(1:length(Fres))); %Dérivation Plug-In-Gait
    V_CoM = mean(VCoM_filtre(1:length(Fres),:)); %Dérivation Barycentre des épines
    V_new_moy = mean(V_new(1:length(Fres),:)); %Intégration PF

    ecart=abs(V_CoM(1)-V_new_moy(1)); %Ecart-type entre les 3 valeurs moyennes calculés en AP

    if ecart>0.1
        Constante_INT=[-V_CoM(1) 0 0]; %% a revoir
        ecart=mean(V)+Constante_INT;
        V_new=(V-repmat(ecart,length(V),1))/1000;
    end

    figure; hold on;
    subplot(3,1,1);
    fastplot(CoM(1:length(Fres),:),'og');
%     fastplot(CG_Vic(1:length(Fres),:),'-b');
    legend('CG Dérivation');%,'PIG');
    ylabel('mm');
    subplot(3,1,2);
    plot(VCoM_filtre(1:length(Fres),2),'-b'); hold on;
%     plot(V_CG(1:length(Fres),1),'.-b');
    plot(V_new(1:length(Fres),2),'-r');
    ylabel('AP m/s');
    legend('Dérivation','IntégrationPF');
    subplot(3,1,3);
    plot(VCoM_filtre(1:length(Fres),3),'-b'); hold on;
    plot(V_new(1:length(Fres),3),'-r');
    ylabel('Vertical m/s');
    legend('Dérivation','IntégrationPF');
end

end

