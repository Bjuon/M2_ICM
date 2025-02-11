f = 0:.25:500;
nw = 4;

psdParams = struct('f',0:.25:500,'thbw',nw);
Sp = Spectrum('input',data,'psdParams',psdParams);
Sp.whitenParams.method = 'power';
Sp.run;
Sp.plotDiagnostics;
Sp.plot;

step = 4;
S = Spectrum('input',data,'step',step);
S.rawParams = struct('f',0:.25:500,'hbw',1,'detrend','linear');
S.baseParams = struct('method','broken-power','smoother','rlowess');

S.run;
S.plot;


load('/Volumes/Data/Human/STN/TEST/MERPh_19012015_LFP_GBMOV_BASELINEASSIS_ON_PRE.mat')
load('/Volumes/Data/Human/STN/TEST/ETIAl_28092015_LFP_GBMOV_BASELINEASSIS_OFF_PRE.mat')
load('/Volumes/Data/Human/STN/TEST/GONFi_11102016_LFP_GBMOV_BASELINEASSIS_OFF_PRE.mat')
load('/Volumes/Data/Human/STN/TEST/GONFi_11102016_LFP_GBMOV_BASELINEASSIS_ON_PRE.mat')
load('/Volumes/Data/Human/STN/TEST/PHIJe_19122016_LFP_GBMOV_BASELINEASSIS_ON_PRE.mat')
load('/Volumes/Data/Human/STN/TEST/PHIJe_19122016_LFP_GBMOV_BASELINEASSIS_OFF_PRE.mat')
load('/Volumes/Data/Human/STN/TEST/FISOl_20062016_LFP_GBMOV_BASELINEDEBOUT_OFF_PRE.mat')
load('/Volumes/Data/Human/STN/TEST/FISOl_20062016_LFP_GBMOV_BASELINEASSIS_OFF_PRE.mat')
load('/Volumes/Data/Human/STN/TEST/BAUMa_01122014_LFP_GBMOV_BASELINEASSIS_ON_PRE.mat')
load('/Volumes/Data/Human/STN/TEST/ARDSy_09022015_LFP_GBMOV_BASELINEASSIS_ON_PRE.mat') % Wierd lines!
load('/Volumes/Data/Human/STN/TEST/SALJe_05102015_LFP_GBMOV_BASELINEASSIS_ON_PRE.mat')
s = data(1);

% artifacts = s.annotate;
% fix(artifacts)

%rawParams = struct('f',0:.05:558,'hbw',.75,'robust','huber','detrend','linear');
rawParams = struct('f',0:.01:558,'hbw',.75,'robust','huber','detrend','linear',...
   'reshape',true,'reshape_f',[50 100 150],'reshape_hw',1,'reshape_nhbw',5);
Sp = Spectrum('input',s,'step',5,'rawParams',rawParams);
%Sp.rejectParams = struct('artifacts',artifacts);
Sp.baseParams.method = 'broken-power';
Sp.baseParams.smoother = 'none';
Sp.baseParams.fmin = 1;
Sp.baseParams.fmax = 300;
tic;Sp.run;toc
%Sp.plotDiagnostics;
Sp.plot; 





% TODO
% make labels for separate processes equal!