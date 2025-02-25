function [t0 indT0]=calcul_APA_T0_v3(xCP,t,flag,seuils)
%% Fonction qui calcul les paramètres stochastiques (SMP) d'un signal stabilométrique (Collins & De Luca 1993, Chiari et al. 2000)
% (t0,indT0) = coordonnés de T0 (1er évt Biomécanique lors de l'initiation du pas)
%              calculé comme l'intersection des 2 droites de regression linéaire (Robuste) de chaque phase
% Données d'entrées : xCP: positions du CP, t : durée de l'intervalle à étudier, 
%                     seuils : seuils du coefficient de correlation et de la pente pour l'identification de la zone constante
%                     flag : flag d'affichage
% Dans cette version la définition du nombre de région/zone (K) du signal
% CP se fait de manière itérative en partant de 2 régimes (1: linéaire constant 2: décroissance)

t0 =NaN;

Sentence = 'ML';

if nargin<4
    seuils(1) = 0.88; %Seuil du coefficient de correlation
    seuils(2) = 4; % Seuil de la pente
    flag = 0;
end

for phase=1:2 % 1: ML 2:AP
    if phase==2 %
        Sentence = 'AP';
    end
    pos = xCP(:,phase);
    %% Identification automatique des phases s et l
    % Définition du nombre de Clusters (intervals)de la courbes en fonction des maximas 
    if ~isempty(findpeaks(pos))
        K = length(findpeaks(pos)) +1;
    else
        K = 2; % On définit 2 Clusters par défaut (correspondant au 2 zones d'intérêts)
    end

    % Délimitation intiale par la méthode des K-Mean
    [idx,C,sumD,D] = kmeans(pos,K);
    [ordre_k occur]= unique(idx);
    ordre_occur = sort(occur);
    
    %initialisation des paramètres de contrôl
    fin_phase_s = ordre_occur(1);
    try
        [bbs,stats]=robustfit(t(1:fin_phase_s),pos(1:fin_phase_s));
         pente = bbs(2);
         r2 = stats.coeffcorr(1,2);
    catch error
        disp([error.identifier,' - ',error.message]);
        pente = seuils(2);
        r2 = seuils(1);
    end
   
    
    ii=1;
    while(abs(r2)<seuils(1) && abs(pente)>abs(seuils(2))) && fin_phase_s>4
        [idx_s,C,sumD,D] = kmeans(pos(1:fin_phase_s),2); % On subdivise le 1er Cluster en 2
        [ordre_ks occur_s]= unique(idx_s);
        occur_s = sort(occur_s);
        fin_phase_s = occur_s(1); %% Fin de la phase constante
        ordre_occur = [fin_phase_s;ordre_occur];
        K=K+1;
        
        % Calcul de la regression linéaire et des coefficients de Diffusion de la zone constante
        disp(strcat('Détection T0, itération n°',num2str(ii)));
        try
            [bbs,stats]=robustfit(t(1:fin_phase_s+1),pos(1:fin_phase_s+1));
            pente = bbs(2);
            r2 = stats.coeffcorr(1,2);
            ii=ii+1;
        catch err
            disp([err.identifier,': ',err.message]);
            pente = seuils(2);
            r2 = seuils(1);
        end
    end        
             
    ordre_occur = [1;fin_phase_s;ordre_occur(2:end)];
    
    for i=1:2
        intervals(i,:)=[ordre_occur(i) ordre_occur(i+1)];
%         plot(t(intervals(i,1):intervals(i,2)),pos(intervals(i,1):intervals(i,2)),'Color',[i/K i/K i/K],'Linestyle','*');
        Num_Cluster(i) = idx(ordre_occur(i));
    end
    
    s_interval = [intervals(1,1):intervals(1,2)];
    Delta_T1 = t(s_interval(end)); %Temps délimitant la zone s (==t théorique)

    l_interval = [intervals(2,1):intervals(2,2)];


    % Calcul de la regression linéaire et des coefficients de Diffusion de la zone l
    try
        [bbl,stats2]=robustfit(t(l_interval),pos(l_interval));
    catch error2
        disp([error2.identifier,': ',error2.message]);
        [bbl,stats2]=robustfit(t(l_interval(1):end),pos(l_interval(1):end));
    end

    %Calcul du pt critique
    if exist('bbs','var')
        Droite_s.pts = [t(s_interval(1)) bbs(1)+bbs(2)*t(s_interval(1)) 0];
        Droite_s.V_dir = [cos(atan(bbs(2))) sin(atan(bbs(2))) 0];
        Droite_l.pts = [t(l_interval(1)) bbl(1)+bbl(2)*t(l_interval(1)) 0];
        Droite_l.V_dir = [cos(atan(bbl(2))) sin(atan(bbl(2))) 0];
    else
        t0 = NaN;
        indT0 = 1;
        break
    end

    if K>1
        Point_c(phase,:) = intersection_de_droites(Droite_s,Droite_l);
    end
    
    if flag==1
        subplot(2,1,phase);
        plot(t,pos,'k-');
        hold on
        xlabel('(s)')
        ylabel('(mm)')
        title(Sentence)
        afficheX(Delta_T1,'k-.');
        plot(t(s_interval),bbs(1)+bbs(2)*t(s_interval),'r-','LineWidth',1.5);
        plot(t(l_interval),bbl(1)+bbl(2)*t(l_interval),'b-','LineWidth',1.25);
        affiche_droite(Droite_s.pts,Droite_s.V_dir,'r-.','Linewidth',1.25);
        affiche_droite(Droite_l.pts,Droite_l.V_dir,'b-.','Linewidth',1.25);
        plot(Point_c(phase,1),Point_c(phase,2),'ko','MarkerSize',10,'LineWidth',1.5);
    end
end
%% Affectation des paramètres
pp = min(abs(Point_c));

indT0 = find(abs(t-pp(1))<0.02,1,'first');
if isempty(indT0)
    indT0 = 3;
end
t0 = t(indT0);    

end