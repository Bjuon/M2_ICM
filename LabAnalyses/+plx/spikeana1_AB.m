function [p] = spikeana1_AB(dat,indspk,cut_off,resol,lim,bw)
% create a point process with infos, plot the average spkwf, the isi
% distribution, instantaneous rate.
% Input:
%   - dat : contains the spk data
%   - indspk : ind of psike to be analyzed
%   - cut_off : isi max
%   - resol : bin for isi distribution 
%   - lim : min isi for violation computation
%   - bw : bandwidth for the psth

import spk.*

if nargin<1;
    error('No data!')
elseif nargin<2;
    error('Which spike!')
elseif nargin<3;
    cut_off = 0.5;  % in sec
    resol = 0.005; % in sec
    lim = 0.002; % in sec
    bw = 0.5; % in sec
else
    cut_off = cut_off;
    resol = resol;
    lim = lim;
    bw = bw;
end

patient = dat.id;
side = dat.side;
depth = dat.depth;

spkname = dat.spkName{indspk};
abs_tstart = dat.start_t(indspk);
abs_tend = dat.end_t(indspk);

t=dat.spk{indspk};
totalspktime=(dat.end_t(indspk))-(dat.start_t(indspk));

%%% meanrate, snr
meanrate = numel(t) / (t(end)-t(1));
spsnr=spk.snr(dat.spkwf{indspk});

%Interpsike interval
isi=diff(t);
isi(isi>cut_off)= cut_off;
total_counts=size(isi,1);
mean_isi=mean(isi);
sd_isi=std(isi);
binvector=resol/2:resol:cut_off;
[ncounts,binvector] = hist (isi,binvector);
[X,Y]=max(ncounts);
prob_isi=ncounts/total_counts;
indviol = find(isi<lim); %in sec
violation = (size(indviol,1)/total_counts)*100;
limms = lim*10^3;

%%% psth (1s bin)
[rate,tpsth] = spk.getPsth(t,bw);

%%%plot spkwf
figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,2,1);
plot (mean(dat.spkwf{indspk},2));
errorbar(mean(dat.spkwf{indspk},2) , std(dat.spkwf{indspk},1,2));
title({sprintf('FR = %1.2fHz , TotTime = %1.0fs ',meanrate,totalspktime),sprintf('SNR-p2p= %1.2f- rms1= %1.2f- rms2= %1.2f',spsnr.p2p,spsnr.rms1,spsnr.rms2)}) 
axis tight

%%% plot isi distribution
subplot(2,2,2);
bar(binvector,prob_isi);
xlabel ('interspike interval [sec]');
ylabel ('probability per bin');
title({sprintf('meanISI = %1.2f s , sdISI = %1.2f s', mean_isi,sd_isi),sprintf('ISI<%1.0f ms = %1.2f percent',limms,violation)});
set(gca, 'XLim',[0 0.1]);

%%% plot instantaneous rate
subplot(2,2,[3 4]);
plot(tpsth,rate)
xlabel('time (s)')
ylabel('rate (Hz)')
title(sprintf(['Instantaneous rate-',' bw = %1.3fs'],bw))
hold off

p = PointProcess('times',dat.spk{indspk});
p.info('patient') = patient;
p.info('side') = side;
p.info('depth') = depth;
p.info('spkname') = spkname;
p.info('abs_tstart') = abs_tstart;
p.info('abs_tend') = abs_tend;
p.info('p2p') = spsnr.p2p;
p.info('rms1') = spsnr.rms1;
p.info('rms2') = spsnr.rms2;
p.info('violation') = violation;


