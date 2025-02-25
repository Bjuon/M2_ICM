col = [TA_D Sol_D TA_G Sol_G];

StopWidth = 8;
fs = 2000;
D=StopWidth/2;

figure
Offset=  10;
for i=1:4
    plot(col(:,i) - (i-1)*Offset);
    hold on
end

figure
for i=1:4
    subplot(1,4,i);
    x=col(:,i);
    
    [P, f] = psd(x,fs,fs, hanning(fs), fs/2, 'mean'); 
    plot(f,P);
    grid
end

[b10 , a10] = Butter(2,    ([ 10-D  10+D]./ (fs/2) ), 'stop'); %butter
[b20 , a20] = Butter(2,    ([ 20-D  20+D]./ (fs/2) ), 'stop'); %butter
[b30 , a30] = Butter(2,    ([ 30-D  30+D]./ (fs/2) ), 'stop'); %butter
[b40 , a40] = Butter(2,    ([ 40-D  40+D]./ (fs/2) ), 'stop'); %butter
[b50 , a50] = Butter(2,    ([ 50-D  50+D]./ (fs/2) ), 'stop'); %butter
[b100,a100] = Butter(2,    ([100-D 100+D]./ (fs/2) ), 'stop'); %butter
[b150,a150] = Butter(2,    ([150-D 150+D]./ (fs/2) ), 'stop'); %butter
[b200,a200] = Butter(2,    ([200-D 200+D]./ (fs/2) ), 'stop'); %butter
[b250,a250] = Butter(2,    ([250-D 250+D]./ (fs/2) ), 'stop'); %butter
[b350,a350] = Butter(2,    ([350-D 350+D]./ (fs/2) ), 'stop'); %butter
[b450,a450] = Butter(2,    ([450-D 450+D]./ (fs/2) ), 'stop'); %butter

for i=1:4
    x = col(:,i);        
    x = x - nanmean(x);
    x(isnan(x))=0;
    y = filtrage(x,'b',2,50,fs);
%     y = filtrage(y,'m',20,5,fs);
%     y = filtfilt (b10,a10,x); %filtfilt
%     y = filtfilt (b20,a20,x); %filtfilt
%     y = filtfilt (b30,a30,x); %filtfilt
%     y = filtfilt (b40,a40,x); %filtfilt
%     y = filtfilt (b50,a50,x); %filtfilt
%     y = filtfilt (b100,a100,y); %filtfilt
%     y = filtfilt (b150,a150,y); %filtfilt
%     y = filtfilt (b200,a200,y); %filtfilt
%     y = filtfilt (b250,a250,y); %filtfilt
%     y = filtfilt (b350,a350,y); %filtfilt
%     y = filtfilt (b450,a450,y); %filtfilt
    fcol(:,i)=y;
end


figure
for i=1:4
    plot(fcol(:,i) - (i-1)*Offset);
    hold on
end
figure
for i=1:4
    subplot(1,4,i);
    x=fcol(:,i);
    
    [P, f] = psd(x,fs,fs, hanning(fs), fs/2, 'mean'); 
    plot(f,P);
    grid
end

filterd_data = fcol;  %salva ed usa questi dati

%Redressement
data_redressee=abs(filterd_data);

% t=[1:length(data_redressee)]*1/fs;
% 
% f1=figure;
% for i=1:4
%     plot(t,data_redressee(:,i) - (i-1)*Offset);
%     hold on
% end

f1=figure;
% subplot(2,1,1);
for i=1:4
    plot(data_redressee(:,i) - (i-1)*Offset);
    hold on
end
