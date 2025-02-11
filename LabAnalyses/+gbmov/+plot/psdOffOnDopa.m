function psdOffOnDopa(OFF,ON)
flines = [4 8 12 20 30 70 250 350];

fOFF = OFF.raw.f';
pOFF{1} = squeeze(OFF.raw.values{1});
pOFF{2} = squeeze(OFF.base.values{1});
pOFF{3} = squeeze(OFF.detail.values{1});

fON = ON.raw.f';
pON{1} = squeeze(ON.raw.values{1});
pON{2} = squeeze(ON.base.values{1});
pON{3} = squeeze(ON.detail.values{1});

fmin = 1;%f(1);
fmax = max(fOFF(end),fON(end));

flines(flines >= fmax) = [];

figure;
h = subplot(321);
OFF.plot('handle',h,'psd','raw','sep',10,'fmin',fmin,'fmax',fmax,...
   'logx',true,'dB',true,'label',true);
ON.plot('handle',h,'psd','raw','sep',10,'fmin',fmin,'fmax',fmax,...
   'logx',true,'dB',true,'LineStyle','--');
grid on;
title('Raw spectrum');
%xlabel('Frequency (Hz)');
ylabel('Power (dB)');

h = subplot(323);
OFF.plot('handle',h,'psd','base','sep',10,'fmin',fmin,'fmax',fmax,...
   'dB',true,'logx',true);
ON.plot('handle',h,'psd','base','sep',10,'fmin',fmin,'fmax',fmax,...
   'dB',true,'logx',true,'LineStyle','--');
grid on;
title('Base spectrum');
%xlabel('Frequency (Hz)');
ylabel('Power (dB)');

h = subplot(325);
OFF.plot('handle',h,'psd','detail','sep',4,'fmin',fmin,'fmax',fmax,...
   'dB',false,'logx',true);
ON.plot('handle',h,'psd','detail','sep',4,'fmin',fmin,'fmax',fmax,...
   'dB',false,'logx',true,...
   'LineStyle','--','vline',flines,'percentile',[0.5 0.9999]);
title('Detail spectrum');
xlabel('Frequency (Hz)');
ylabel('Power (standardized)');


if numel(fON) ~= numel(fOFF)
   f = fOFF;
   fmin = max(ON.baseParams.fmin,OFF.baseParams.fmin);
   fmax = min(ON.baseParams.fmax,OFF.baseParams.fmax);
   %fmax = OFF.baseParams.fmax;
   indON = (fON>=fmin) & (fON<=fmax);
   indOFF = (fOFF>=fmin) & (fOFF<=fmax);
   if sum(indON) == sum(indOFF)
      f = fOFF(indOFF);
      ind = indOFF;
   end
else
   f = fON;
   ind = (f>=fmin) & (f<=fmax);
   f = f(ind);
end

nChannels = OFF.nChannels;

for i = [2 4 6]
   subplot(3,2,i); hold on
   shiftlog = 0;
   for chan = 1:nChannels
      plot(f,shiftlog + log10(pON{i/2}(ind,chan)./pOFF{i/2}(ind,chan)),...
         'color',OFF.labels_(chan).color);
      plot([f(1) f(end)],[shiftlog shiftlog],...
         'color',OFF.labels_(chan).color,'LineStyle',':');
      shiftlog = shiftlog + 0.5;
   end
   set(gca,'xscale','log');
   axis tight
   ylabel('ON/OFF (dB)');
end
xlabel('Frequency (Hz)');
