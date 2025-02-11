%%Time specifications:
Fs = 512;                   % samples per second
dt = 1/Fs;                   % seconds per sample
StopTime = 5;             % seconds
t = (0:dt:StopTime-dt)';     % seconds
%%Sine wave:
Fc = 20;                     % hertz
%x = cos(2*pi*4*t) + cos(2*pi*15*t) + 4*randn(size(t));
x = zeros(size(t));
ind = (t>2) & (t<3);
x(ind) = cos(2*pi*4*t(ind)) + cos(2*pi*15*t(ind)) + cos(2*pi*70*t(ind));
x = x + 2*randn(size(t));
% Plot the signal versus time:
% figure;
% plot(t,x);
% xlabel('time (in seconds)');
% title('Signal versus Time');
% zoom xon;

movingwin = [0.5 0.05];
params = struct('tapers',[3 5],'pad',1,'Fs',Fs,'fpass',[2 100],'trialave',0);
[S,t,f] = mtspecgramc(x-mean(x),movingwin,params);

%figure;
subplot(231);
plot_matrix(S,t,f)
subplot(232); 
plot(f,10*log10(mean(S))); hold on
plot(f,10*log10(S(49,:)));
hold off
subplot(233);
plot(t,mean(S'))

params = struct('tapers',[1 1],'pad',1,'Fs',Fs,'fpass',[2 100],'trialave',0);
[S,t,f] = mtspecgramc(x-mean(x),movingwin,params);

subplot(234);
plot_matrix(S,t,f)
subplot(235);
plot(f,10*log10(mean(S))); hold on
plot(f,10*log10(S(49,:)));
hold off
subplot(236);
plot(t,mean(S'))
