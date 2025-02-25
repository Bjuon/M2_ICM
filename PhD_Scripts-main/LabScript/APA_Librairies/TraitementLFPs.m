function [LFPs_post LFPs] = TraitementLFPs(LFPs_in,fs)
%% Prétraitement des LFPs pour visualisation

%Preprocessing
if isstruct(LFPs_in)
    LFPs = extract_lfps_from_struct(LFPs_in);
else
    LFPs = LFPs_in;
end

if nargin<2
    fs=512;
end

% Création des filtres
% [b , a] = butter(2,([4  100]./ (fs/2)), 'bandpass'); % Coupe-bande principal
% [b , a] = butter(500,5/(fs/2), 'high'); % Passe-haut principal
StopWidth = 2; %Largeur de coupe
D=StopWidth/2;
[b50 , a50] = butter(4,    ([50-D  50+D]./ (fs/2) ), 'stop'); %butter à 50
% [b100,a100] = butter(2,    ([100-D 100+D]./ (fs/2) ), 'stop'); %butter à 100
% [b150,a150] = butter(2,    ([150-D 150+D]./ (fs/2) ), 'stop'); %butter à 150
% [b200,a200] = butter(2,    ([200-D 200+D]./ (fs/2) ), 'stop'); %butter à 200
% try
%     [b250,a250] = butter(2,    ([250-D 250+D]./ (fs/2) ), 'stop'); %butter à 250
% catch ERR
% end

% Filtrage et removal de la composante continue
for c=1:size(LFPs,1)
    x = LFPs(c,:);
    
    % DC removal
    base = nanmean(x);
    x = x - base;
    
    % Noise removal ( |Amp| > 300 microVolts)
    x(abs(x)>300) = 0;
    
    % Notch filtering (50Hz & Harmonics)
%     y = filtfilt (b,a,x); % Coupe-bande principal
%     y = filtrage(x,'firls',500,[3 100],fs); % Passe-Bande (FIR au moindres carrés, ordre 500)
    y = filtfilt (b50,a50,x); %filtfilt
%     y = filtfilt (b100,a100,y); %filtfilt
%     y = filtfilt (b150,a150,y); %filtfilt
%     y = filtfilt (b200,a200,y); %filtfilt
%     try
%         y = filtfilt (b250,a250,y); %filtfilt
%     catch ERR_FsMax
%     end
%     
    % Artifact removal (|Amp| >µ + 6?)
    sem = nanstd(abs(y));
    mean_amp = nanmean(abs(y));
    threshold = mean_amp + 6*sem;
    y(abs(y)>threshold) = 0;
    y = filtrage(y,'g',6,100,fs); %Smoothing using recursive gaussian filter with a 100Hz cutoff frequency
    
%     base = nanmean(y(1:round(fs*0.2)));
%     y = y - base;
    
    LFPs_post(c,:) = y;
end