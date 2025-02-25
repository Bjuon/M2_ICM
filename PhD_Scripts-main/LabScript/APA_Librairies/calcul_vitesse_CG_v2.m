function [V_new VCoM V_CG]= calcul_vitesse_CG_v2(Fres,Fech,Data,flag,P,V0)
%% Calcul des vitesses du CG par int�gration num�rique
% Fres = Composants de la GRF
% Fech = fr�quence d'�chantillonage des donn�es (vid�o)
% V0 = vecteure vitesse initiale utilis�e comme constante l'int�gration(optionnel)
% P = poids du sujet en N (optionnel)
% Data = structure contenant les donn�es d'acquisition (optionnelle)
% flag = flag d'affichage (== 0 par d�faut)
% SOrties
% V_new = vecteur vitesse du CG [Nx3] obtenu par int�gration des donn�es PF
% VCoM = vecteur vitesse du CG [Nx3] obtenu par d�rivation des marqueurs du bassin
% V_CG = vecteur vitesse du CG [Nx3] obtenu par d�rivation de la position CG obtenue par le protocole Plug-In-Gait

%% Extraction du poids
if ~exist('P','var')
    P = mean(Fres(20:Fech/2,:),1); % on prend la moyenne de la composante Z sur la 1�re demi-seconde de l'acquisition
end

F0 = repmat(P,length(Fres),1);
% F0 = repmat([0 0 P(3)],length(Fres),1);
gravite = 9.80928; % observatoire gravim�trique de strasbourg

%Pr�conditionnement du vecteur r�action � la dur�e sur la PF
Last = round(find(Fres==0,1,'first')); % Derni�re frame sur la PF        

Fres = (Fres - F0).*1/(P(3)/gravite); % On normalise � la masse

%% Int�gration
V_new=[];y=[];t=[];
for ii=1:3
 y=Fres(:,ii);
            t=[1:length(y)]*1/Fech; % on ajoute la variable temporelle
            y_t = csaps(t,y);  % on cr�� une spline
         intgrf = fnint(y_t); % on int�gre
       V_new(:,ii)= fnval(intgrf,t);
end

%Filtrage num�rique
% V_new = filtrage(V_new,'s',Fech/5); %Filtrage de 'Stavitsky-Golay'

% % ajout de la bonne composante d'int�gration
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
    %Calcul des Centre de Gravit� du sujet
    CG_Vic = squeeze(extraire_coordonnees_v2(Data,{'CenterOfMass'}))'; % Celui calcul� par Plug-In-Gait
    CoM = squeeze(barycentre(extraire_coordonnees_v2(Data,{'RASI','LASI','RPSI','LPSI'})))'; %Celui calcul� comme barycentre des �pines iliaques du bassin
    
    %Calcul directe (par d�rivation) des vitesses du CG
    VCoM=zeros(length(CoM),3);
    V_CG=zeros(length(CG_Vic),3);
    for ii=1:3
        y=CoM(:,ii);        
        t=[1:length(y)]*1/Fech; % on ajoute la variable temporelle
        y_t = csaps(t,y);  % on cr�� une spline         
        derCoM = fnder(y_t); % on d�rive         
        VCoM(:,ii)= fnval(derCoM,t)/1000;       
%         VCoM = filtrage(VCoM,'s',Fech/5); %Filtrage de 'Stavitsky-Golay'
        if ~isnan(CG_Vic)
            yy = CG_Vic(:,ii);
            yy_t = csaps(t,yy);
            derCG = fnder(yy_t);
            V_CG(:,ii) = fvnal(derCG,t)/1000; %D�rivation Plug-In-Gait
        end
    end
    
%     V_CoM_moy = mean(VCoM(1:length(Fres),:)); %D�rivation Barycentre des �pines
%     V_new_moy = mean(V_new(1:length(Fres),:)); %Int�gration PF
%     V_CG_moy = mean(V_CG(1:length(Fres),:)); %D�rivation PIG

%     ecart=std([V_CoM_moy(2) V_new_moy(2) V_CG_moy(2)]); %Ecart-type entre les 3 valeurs moyennes calcul�s en AP

    % Affichage
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
        subplot(3,1,3);
        plot(t,VCoM(1:length(Fres),3),'-b'); hold on;
        plot(t,V_CG(1:length(Fres),3),'.-b');
        plot(t,V_new(1:length(Fres),3),'-r');
        ylabel('Vertical m/s');
        xlabel('sec');
        legend('D�rivation','PIG','Int�grationPF');
    end
end

end