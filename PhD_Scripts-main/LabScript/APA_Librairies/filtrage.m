function vect_filtrees=filtrage(V,filtre,ordre,Fc,Fech)
%function vect_filtrees=filtrage(V,filtre,ordre,Fc,Fech)
%% Filtrage récursif d'un signal V=filtrage(V,filtre,ordre,Fc,Fech)
% filtre : 'b' butterworth bas, 'h' butterworth haut, 'fir' réponse impulsionnel fini, 'firls' fir aux moindres carrés, 'db' digitalized butterworth = butter+fir,
%          'm' moving-average, 'l' loess, 's' stavitsky-golay 'g' gaussien
% ordre : ordre du filtre OU nombre de points de la fenetre (si 's')
% Fc : fréquence (ou bande) de coupure du filtre ou ordre du ploynome (si 's')
% Fech : fréquence d'echantillonage de base du signal

Nyq = Fech/2;
switch filtre
    case 'b'
    %% Butterworth a la freq de coupure (passe-bas)
        [b,a] = butter(ordre,Fc/Nyq);
        vect_filtrees = filtfilt(b,a,V);
    case 'h'
    %% Butterworth a la freq de coupure (passe-haut)
        [b,a] = butter(ordre,Fc/Nyq,'high');
        vect_filtrees = filtfilt(b,a,V);
    case 'db' 
        %% Digitalizd Butterworth (passe-bas)
        b = maxflat(ordre,'sym',Fc/Nyq);
        vect_filtrees = filtfilt(b,1,V);
    case 'fir'
    %% Filtre 'FIR' classique a la freq de coupure (passe-bas)
        b=fir1(ordre,Fc/Nyq);
        vect_filtrees=filtfilt(b,1,V);
    case 'firls'
    %% Filtre 'FIR' au moindres carrés (passe-bande)
        b = firls(ordre,[0 Fc(1) Fc(1) Fc(2) Fc(2) Nyq]./Nyq,[0 0 1 1 0 0]);        
%         freqz(b,1);
        vect_filtrees = filtfilt(b,1,V);    
    case 'm'
    %% Filtrage (moving average filter) (passe-bas)
        window = ones(ordre,1)/ordre;
        vect_filtrees = filtfilt(window,1,V);
    case 'l'
    %% Filtrage loess (passe-bas)
        ww=ordre/length(V);
        vect_filtrees=smooth(V,ww,'loess');
    case 's'
    %% Filtrage de Savitzky-Golay (moving polynome) (passe-bas sans déphasage)
        N=2*Fc+1;
        vect_filtrees=sgolayfilt(V,ordre,N);
    case 'g'
    %% Filtrage Gaussien à réponse impulsionelle finie (passe-bas)
       a=3.011*Fc;
       N=ceil(0.398*Fech/Fc);   %filter half-width, excluding midpoint
       L=2*N+1;                %full length of FIR filter
       b=zeros(1,L);
       for k=-N:N
           b(k+N+1)=3.011*(Fc/Fech)*exp(-pi*(a*k/Fech)^2);
       end;
       b=b/sum(b);
       vect_filtrees=filtfilt(b,1,V); 
    otherwise
       vect_filtrees =smooth(V);
end

% %% Affichage
% fastplot(V,'r'); hold on
% fastplot(vect_filtrees,'g');
% legend('Raw data','Smoothed data');
end