function EMG_traite=TraitementEMG(x,fs)
%% Fonction de filtrage et redressement
StopWidth = 8;
D=StopWidth/2;

[b,a] = butter(2,([20 50]./(fs/2)),'stop');
% [b10 , a10] = butter(2,    ([ 10-D  10+D]./ (fs/2) ), 'stop'); %butter
% [b20 , a20] = butter(2,    ([ 20-D  20+D]./ (fs/2) ), 'stop'); %butter
% [b30 , a30] = butter(2,    ([ 30-D  30+D]./ (fs/2) ), 'stop'); %butter
% [b40 , a40] = butter(2,    ([ 40-D  40+D]./ (fs/2) ), 'stop'); %butter
% [b50 , a50] = butter(2,    ([ 50-D  50+D]./ (fs/2) ), 'stop'); %butter
% [b100,a100] = butter(2,    ([100-D 100+D]./ (fs/2) ), 'stop'); %butter
% [b150,a150] = butter(2,    ([150-D 150+D]./ (fs/2) ), 'stop'); %butter
% [b200,a200] = butter(2,    ([200-D 200+D]./ (fs/2) ), 'stop'); %butter
% [b250,a250] = butter(2,    ([250-D 250+D]./ (fs/2) ), 'stop'); %butter
% [b350,a350] = butter(2,    ([350-D 350+D]./ (fs/2) ), 'stop'); %butter
% [b450,a450] = butter(2,    ([450-D 450+D]./ (fs/2) ), 'stop'); %butter
% 
[r,c]=size(x);
if r>c
    x = x  - repmat(nanmean(x,1),r,1);   
else
    x = x  - repmat(nanmean(x,2),1,c);
    x = x';
end
x(isnan(x))=0;

y = filtfilt (b,a,x);
% y = filtfilt (b10,a10,x); %filtfilt
% y = filtfilt (b20,a20,y); %filtfilt
% y = filtfilt (b30,a30,y); %filtfilt
% y = filtfilt (b40,a40,y); %filtfilt
% y = filtfilt (b50,a50,y); %filtfilt
% 
% y = filtfilt (b100,a100,x); %filtfilt
% y = filtfilt (b150,a150,y); %filtfilt
% y = filtfilt (b200,a200,y); %filtfilt
% y = filtfilt (b250,a250,y); %filtfilt
% y = filtfilt (b350,a350,y); %filtfilt
% y = filtfilt (b450,a450,y); %filtfilt
EMG_traite=y;

%% Redressement
% EMG_traite=abs(EMG_traite);
end