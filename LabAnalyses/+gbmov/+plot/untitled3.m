out.BRADYKINESIA_DIFF_CONTRA = out.BRADYKINESIA_OFF_CONTRA - out.BRADYKINESIA_ON_CONTRA;
out.RIGIDITY_DIFF_CONTRA = out.RIGIDITY_OFF_CONTRA - out.RIGIDITY_ON_CONTRA;
out.TREMOR_DIFF_CONTRA = out.TREMOR_OFF_CONTRA - out.TREMOR_ON_CONTRA;

statarray = grpstats(out,{'PATIENTID' 'SIDE'},'mean',...
   'DataVars',{'BRADYKINESIA_DIFF_CONTRA' 'RIGIDITY_DIFF_CONTRA' 'TREMOR_DIFF_CONTRA'})

indON = strcmp(out.CONDITION,'ON');

%indlo = out.TREMOR_DIFF_CONTRA<=1;
%indlo = out.BRADYKINESIA_DIFF_CONTRA<=5;
indlo = out.RIGIDITY_DIFF_CONTRA<=3;

figure; hold on
subplot(211); hold on
plot(f,nanmean(PSD(:,indON),2),'c-')
plot(f,nanmean(PSD(:,(~indON)),2),'m-')
subplot(211); hold on
plot(f,nanmean(PSD(:,indON&indlo),2),'r-')
plot(f,nanmean(PSD(:,(~indON)&indlo),2),'b-')
subplot(212); hold on
plot(f,nanmean(PSD(:,(~indON)&indlo),2)-nanmean(PSD(:,indON&indlo),2),'k-')
subplot(211); hold on
plot(f,nanmean(PSD(:,indON&(~indlo)),2),'r--')
plot(f,nanmean(PSD(:,(~indON)&(~indlo)),2),'b--')
subplot(212); hold on
plot(f,nanmean(PSD(:,(~indON)&(~indlo)),2)-nanmean(PSD(:,indON&(~indlo)),2),'k--')


statarray = grpstats(out,{'PATIENTID'},'mean',...
   'DataVars','UPDRSIV')

indlo = out.UPDRSIV<8;

figure; hold on
plot(f,nanmean(PSD(:,indON&indlo),2),'r-')
plot(f,nanmean(PSD(:,(~indON)&indlo),2),'b-')
plot(f,nanmean(PSD(:,indON&(~indlo)),2),'r--')
plot(f,nanmean(PSD(:,(~indON)&(~indlo)),2),'b--')
set(gca,'yscale','log');