

indON = strcmp(out.CONDITION,'ON');

diff = grpstats(out,{'PATIENTID' 'SIDE'},'mean',...
   'DataVars',{'PSD' 'BRADYKINESIA_DIFF_CONTRA' 'RIGIDITY_DIFF_CONTRA' ...
   'TREMOR_DIFF_CONTRA' 'AXIAL_DIFF' 'EQUIVLDOPA' 'UPDRSIV'});

diff = grpstats(out,{'PATIENTID' 'SIDE'},'mean',...
   'DataVars',{'PSD' 'BRADYKINESIA_DIFF_CONTRA' 'RIGIDITY_DIFF_CONTRA' ...
   'TREMOR_DIFF_CONTRA' 'AXIAL_DIFF'});

%
figure; hold on
plot(f,nanmean(out.PSD(indON,:)),'c-');
plot(f,nanmean(out.PSD(~indON,:)),'m-');
% set(gca,'yscale','log')

%indLO = out.AXIAL_DIFF <= nanmedian(diff.mean_AXIAL_DIFF);
indLO = out.RIGIDITY_DIFF_CONTRA <= nanmedian(diff.mean_RIGIDITY_DIFF_CONTRA);
%indLO = out.BRADYKINESIA_DIFF_CONTRA <= nanmedian(diff.mean_BRADYKINESIA_DIFF_CONTRA);
%indLO = out.TREMOR_DIFF_CONTRA <= nanmedian(diff.mean_TREMOR_DIFF_CONTRA);
%indLO = out.EQUIVLDOPA <= nanmedian(diff.mean_EQUIVLDOPA);
%indLO = out.UPDRSIV <= nanmedian(diff.mean_UPDRSIV);

func = @nanmean;
figure; hold on
subplot(211); hold on
% plot(f,func(out.PSD(indLO,:)),'k-')
% plot(f,func(out.PSD(~indLO,:)),'k--')
plot(f,func(out.PSD(indON&indLO,:)),'r-')
plot(f,func(out.PSD((~indON)&indLO,:)),'b-')
plot(f,func(out.PSD(indON&(~indLO),:)),'r--')
plot(f,func(out.PSD((~indON)&(~indLO),:)),'b--')

subplot(212); hold on
plot(f,func(out.PSD((~indON)&indLO,:))-func(out.PSD(indON&indLO,:)),'k-')
subplot(212); hold on
plot(f,func(out.PSD((~indON)&(~indLO),:))-func(out.PSD(indON&(~indLO),:)),'k--')

% subplot(212); hold on
% plot(f,nanmean(out.PSD((~indON)&indLO,:))./nanmean(out.PSD(indON&indLO,:)),'k-')
% subplot(212); hold on
% plot(f,nanmean(out.PSD((~indON)&(~indLO),:))./nanmean(out.PSD(indON&(~indLO),:)),'k--')

edges = prctile(diff.mean_RIGIDITY_DIFF_CONTRA,[0 25 50 75 100]);
edges(1) = edges(1) - 1;
edges(end) = edges(end) + 1;
figure; hold on
c = ['b' 'g' 'r' 'k'];
for i = 1:(numel(edges)-1)
   ind = (out.RIGIDITY_DIFF_CONTRA>edges(i)) & (out.RIGIDITY_DIFF_CONTRA<=edges(i+1));
   sum(ind)
   plot(f,func(out.PSD(ind,:)),[c(i) '-'])
%    plot(f,nanmedian(out.PSD((~indON)&ind,:)  )-...
%       nanmedian(out.PSD(indON&ind,:)),[c(i) '-'])
end


%indLO2 = diff.mean_BRADYKINESIA_DIFF_CONTRA <= nanmedian(diff.mean_BRADYKINESIA_DIFF_CONTRA);
indLO2 = diff.mean_RIGIDITY_DIFF_CONTRA <= nanmedian(diff.mean_RIGIDITY_DIFF_CONTRA);
%indLO2 = diff.mean_UPDRSIV <= nanmedian(diff.mean_UPDRSIV);

figure; hold on
plot(f,mean(diff.mean_PSD(indLO2,:)),'m-')
plot(f,mean(diff.mean_PSD(~indLO2,:)),'c--')
