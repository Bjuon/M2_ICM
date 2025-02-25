function lfp_post = Pretraitement_LFP(lfps_in,fs)
% function lfp_post = Pretraitement_LFP(lfps_in,fs)
%% Prétraitement des LFPs avant découpage en essais (coupe-bande [1-250]Hz + Noise removal (50/100/150 Hz) + lissage Gausseen à 200Hz)
% lfps = [N x t] N: nombre de channels epar ligne
% Fs = frequence d'échantillonage

%% Création du filtre notch
StopWidth = 2; %Largeur de coupe (du filtre Notch)
D = StopWidth/2;
% [b50 , a50] = butter(4,([ 50-D  50+D]./ (fs/2) ), 'stop'); %butter à 50
% [b100 , a100] = butter(4,([ 100-D  100+D]./ (fs/2) ), 'stop'); %butter à 100
parms.Fs = fs;
parms.fpass = [0 100];
parms.tapers = [2 3];
parms.pad = 2;

lfp_post = NaN*ones(size(lfps_in));
for i=1:size(lfps_in,1)
    x = lfps_in(i,:);
    
    % DC removal
    base = nanmean(x);
    x = x - base;
    
    %Filtering [2 - 250] Hz
    y = filtrage(x,'firls',400,[1 250],fs); % Passe-Bande (FIR au moindres carrés, ordre 500)
    
    %Notch @ 50 & 100
%     y = filtfilt (b50,a50,y); %filtfilt
%     y = filtfilt (b100,a100,y); %filtfilt
    y = rmlinesc(y,parms,[],[],[50 100 150 200]);
    
%     % Artifact removal (|Amp| >µ + 6?)
%     sem = nanstd(abs(y));
%     mean_amp = nanmean(abs(y));
%     threshold = mean_amp + 6*sem;
%     y(abs(y)>threshold) = 0;
    y = filtrage(y,'g',6,200,fs); %Smoothing using recursive gaussian filter with a 200Hz cutoff frequency
    
    lfp_post(i,:) = y;
end
    