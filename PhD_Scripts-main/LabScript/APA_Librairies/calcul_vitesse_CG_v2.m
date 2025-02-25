function [V_new VCoM V_CG]= calcul_vitesse_CG_v2(Fres,Fech,Data,flag,P,V0)
%% Calcul des vitesses du CG par intégration numérique
% Fres = Composants de la GRF
% Fech = fréquence d'échantillonage des données (vidéo)
% V0 = vecteure vitesse initiale utilisée comme constante l'intégration(optionnel)
% P = poids du sujet en N (optionnel)
% Data = structure contenant les données d'acquisition (optionnelle)
% flag = flag d'affichage (== 0 par défaut)
% SOrties
% V_new = vecteur vitesse du CG [Nx3] obtenu par intégration des données PF
% VCoM = vecteur vitesse du CG [Nx3] obtenu par dérivation des marqueurs du bassin
% V_CG = vecteur vitesse du CG [Nx3] obtenu par dérivation de la position CG obtenue par le protocole Plug-In-Gait

%% Extraction du poids
if ~exist('P','var')
    P = mean(Fres(20:Fech/2,:),1); % on prend la moyenne de la composante Z sur la 1ère demi-seconde de l'acquisition
end

F0 = repmat(P,length(Fres),1);
% F0 = repmat([0 0 P(3)],length(Fres),1);
gravite = 9.80928; % observatoire gravimétrique de strasbourg

%Préconditionnement du vecteur réaction à la durée sur la PF
Last = round(find(Fres==0,1,'first')); % Dernière frame sur la PF        

Fres = (Fres - F0).*1/(P(3)/gravite); % On normalise à la masse

%% Intégration
V_new=[];y=[];t=[];
for ii=1:3
 y=Fres(:,ii);
            t=[1:length(y)]*1/Fech; % on ajoute la variable temporelle
            y_t = csaps(t,y);  % on créé une spline
         intgrf = fnint(y_t); % on intègre
       V_new(:,ii)= fnval(intgrf,t);
end

%Filtrage numérique
% V_new = filtrage(V_new,'s',Fech/5); %Filtrage de 'Stavitsky-Golay'

% % ajout de la bonne composante d'intégration
% if isscalar(V0)
%     Constante_INT = [0 V0 0];
% else
%     Constante_INT = [0 V0(2) 0];
% end
% 
% ecart = mean(V) + Constante_INT;
% V_new = (V-repmat(ecart,length(V),1))/1000;

%% On s'assure de l'ordre de grandeur
if exist('Data','var')
    %Calcul des Centre de Gravité du sujet
    CG_Vic = squeeze(extraire_coordonnees_v2(Data,{'CenterOfMass'}))'; % Celui calculé par Plug-In-Gait
    CoM = squeeze(barycentre(extraire_coordonnees_v2(Data,{'RASI','LASI','RPSI','LPSI'})))'; %Celui calculé comme barycentre des épines iliaques du bassin
    
    %Calcul directe (par dérivation) des vitesses du CG
    VCoM=zeros(length(CoM),3);
    V_CG=zeros(length(CG_Vic),3);
    for ii=1:3
        y=CoM(:,ii);        
        t=[1:length(y)]*1/Fech; % on ajoute la variable temporelle
        y_t = csaps(t,y);  % on créé une spline         
        derCoM = fnder(y_t); % on dérive         
        VCoM(:,ii)= fnval(derCoM,t)/1000;       
%         VCoM = filtrage(VCoM,'s',Fech/5); %Filtrage de 'Stavitsky-Golay'
        if ~isnan(CG_Vic)
            yy = CG_Vic(:,ii);
            yy_t = csaps(t,yy);
            derCG = fnder(yy_t);
            V_CG(:,ii) = fvnal(derCG,t)/1000; %Dérivation Plug-In-Gait
        end
    end
    
%     V_CoM_moy = mean(VCoM(1:length(Fres),:)); %Dérivation Barycentre des épines
%     V_new_moy = mean(V_new(1:length(Fres),:)); %Intégration PF
%     V_CG_moy = mean(V_CG(1:length(Fres),:)); %Dérivation PIG

%     ecart=std([V_CoM_moy(2) V_new_moy(2) V_CG_moy(2)]); %Ecart-type entre les 3 valeurs moyennes calculés en AP

    % Affichage
    if exist('flag','var')
        Fres = Fres(1:Last-5,:);
        t=t(1:length(Fres));
        figure; hold on;
        subplot(3,1,1);
        plot(t,CoM(1:length(Fres),3),'og'); hold on
        fastplot(t,CG_Vic(1:length(Fres),3),'-b');
        legend('CG Dérivation','PIG');
        ylabel('mm');
        subplot(3,1,2);
        plot(t,VCoM(1:length(Fres),2),'-b'); hold on;
        plot(t,V_CG(1:length(Fres),2),'.-b');
        plot(t,V_new(1:length(Fres),2),'-r');
        ylabel('AP m/s');
        legend('Dérivation','PIG','IntégrationPF');
        subplot(3,1,3);
        plot(t,VCoM(1:length(Fres),3),'-b'); hold on;
        plot(t,V_CG(1:length(Fres),3),'.-b');
        plot(t,V_new(1:length(Fres),3),'-r');
        ylabel('Vertical m/s');
        xlabel('sec');
        legend('Dérivation','PIG','IntégrationPF');
    end
end

end