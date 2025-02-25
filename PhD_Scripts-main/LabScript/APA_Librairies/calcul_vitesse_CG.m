function V_new = calcul_vitesse_CG(Fres,Fech,Data,V0,P)
%% Calcul des vitesses du CG par int�gration num�rique
% Fres = Composants de la GRF
% Fech = fr�quence d'�chantillonage des donn�es (vid�o)
% V0 = vecteure vitesse initiale utilis�e comme constante l'int�gration(optionnelle)
% P = poids du sujet (en N)
% Data = structure contenant les donn�es d'acquisition (optionnelle)

%% Extraction du poids et de la vitesse moyenne du 1er pas
if nargin <4
    P = mean(Fres(20:Fech/2,:),1); % on prend la moyenne de la composante Z sur la 1�re demi-seconde de l'acquisition
    %Calcul de la vitesse moyenne du sacrum sur le 1er pas
    Sacr = barycentre(extraire_coordonnees_v2(Data,{'RPSI','LPSI'}));
    TO = round(Data.events.temps(1)*Fech); 
%     Last = round(Data.events.temps(7)*Fech); %On suppose que le 7�me evenement correspond � la fin du dernier pas sur la PF
    Last = round(find(Fres==0,1,'first')); % Derni�re frame sur la PF
    V0 = nanmean(squeeze(derive_MH_NAN(Sacr(:,:,TO-5:Last+5),Fech))');
%     CG_Vic = extraire_coordonnees_v2(Data,{'CenterOfMass'});
%     V0_Vic = nanmean(squeeze(derive_MH_NAN(CG_Vic(:,:,TO-5:FC+5),Fech))');
    
    %Pr�conditionnement du vecteur r�action � la dur�e sur la PF
    Fres = Fres(1:Last,:);
end

% F0 = repmat(P,length(Fres),1);
F0 = repmat([0 0 P(3)],length(Fres),1);
gravite = 9.80928; % observatoire gravim�trique de strasbourg

Fres = (Fres - F0).*1/(P(3)/gravite); % On normalise � la masse

%% Int�gration
V_new=[];y=[];t=[];
for ii=1:3
 y=Fres(:,ii);
            t=[1:length(y)]*1/Fech; % on ajoute la variable temporelle
            y_t = csaps(t,y,1);  % on cr�� une spline
         intgrf = fnint(y_t); % on int�gre
       V_new(:,ii)= fnval(intgrf,t);
end

% % ajout de la bonne composante d'int�gration
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
    %Calcul des Centre de Gravit� du sujet
    CG_Vic = squeeze(extraire_coordonnees_v2(Data,{'CenterOfMass'}))'; % Celui calcul� par Plug-In-Gait
    CoM=squeeze(barycentre(extraire_coordonnees_v2(Data,{'RASI','LASI','RPSI','LPSI'})))'; %Celui calcul� comme barycentre des �pines iliaques du bassin
    
    %Calucul directe (par d�rivation) des vitesses du CG
    VCoM=zeros(length(CoM),3);
    V_CG=zeros(length(CG_Vic),3);
    for ii=1:3
        y=CoM(:,ii);
%         yy = CG_Vic(:,ii);
        t=[1:length(y)]*1/Fech; % on ajoute la variable temporelle
        y_t = csaps(t,y);  % on cr�� une spline
%         yy_t = csaps(t,yy);
        derCoM = fnder(y_t); % on d�rive
%         derCG = fnder(yy_t);
        VCoM(:,ii)= fnval(derCoM,t)/1000;
%         V_CG(:,ii) = fvnal(derCG,t)/1000;
        VCoM_filtre = filtrage(VCoM,'s',Fech/4); %Filtrage de 'Stavitsky-Golay'
    end
    
    V_CG = mean(V_CG(1:length(Fres))); %D�rivation Plug-In-Gait
    V_CoM = mean(VCoM_filtre(1:length(Fres),:)); %D�rivation Barycentre des �pines
    V_new_moy = mean(V_new(1:length(Fres),:)); %Int�gration PF

    ecart=abs(V_CoM(1)-V_new_moy(1)); %Ecart-type entre les 3 valeurs moyennes calcul�s en AP

    if ecart>0.1
        Constante_INT=[-V_CoM(1) 0 0]; %% a revoir
        ecart=mean(V)+Constante_INT;
        V_new=(V-repmat(ecart,length(V),1))/1000;
    end

    figure; hold on;
    subplot(3,1,1);
    fastplot(CoM(1:length(Fres),:),'og');
%     fastplot(CG_Vic(1:length(Fres),:),'-b');
    legend('CG D�rivation');%,'PIG');
    ylabel('mm');
    subplot(3,1,2);
    plot(VCoM_filtre(1:length(Fres),2),'-b'); hold on;
%     plot(V_CG(1:length(Fres),1),'.-b');
    plot(V_new(1:length(Fres),2),'-r');
    ylabel('AP m/s');
    legend('D�rivation','Int�grationPF');
    subplot(3,1,3);
    plot(VCoM_filtre(1:length(Fres),3),'-b'); hold on;
    plot(V_new(1:length(Fres),3),'-r');
    ylabel('Vertical m/s');
    legend('D�rivation','Int�grationPF');
end

end

