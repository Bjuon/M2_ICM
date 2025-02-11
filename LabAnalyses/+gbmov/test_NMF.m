[datadir,infodir,savedir] = gbmov.getPaths();
conditions = {'OFF' 'ON'};
tasks = {'BASELINEASSIS'};
info = gbmov.PatientInfo('path',infodir);
%%
f = 1:.01:100;
PON = [];
POFF = [];
BR_OFF = [];
dB = false;
psd = 'detail';
%normalize = struct('fmin',1,'fmax',100,'method','integral');
normalize = struct('fmin',4,'fmax',48,'method','integral');

for i = 1:info.n
   id = info.clinicInfo(i).PATIENTID;
   for j = 1:numel(tasks)
      dOFF = dir([datadir '/' id '*' tasks{j} '*OFF*.mat']);
      
      try
         if (numel(dOFF) == 1)     
            
            temp = load(fullfile(datadir,dOFF.name));
            [tempP,~,labels] = extract(temp.PSD,'f',f,'psd',psd,'dB',dB,'normalize',normalize);
            POFF = [POFF , tempP];
            
            % NOTE we set up contralateral scores here
            br = zeros(1,numel(temp.PSD.labels_));
            ind = strcmp({temp.PSD.labels_.side},'right');
            %br(ind) = info.info(id).BR_OFF_L;
            %br(ind) = info.info(id).UPDRSIII_ON_L;
            br(ind) = info.info(id).UPDRSIII_OFF_L;
            ind = strcmp({temp.PSD.labels_.side},'left');
            %br(ind) = info.info(id).BR_OFF_R;
            %br(ind) = info.info(id).UPDRSIII_ON_R;
            br(ind) = info.info(id).UPDRSIII_OFF_R;
            BR_OFF = [BR_OFF , br];
         else
            disp(['no OFF data ' id]);
         end
      catch
         disp(['no PSD data ' id]);
         continue;
      end
   end
end


POFFs = POFF(1:10:end,:);
%PONs = PON(1:10:end,:);
fs = f(1:10:end);

% figure;
% subplot(121); 
% imagesc(fs,fs,cov(POFFs','omitrows'));
% subplot(122); 
% imagesc(fs,fs,cov(PONs','omitrows'));

% figure;
% subplot(121); 
% imagesc(fs,fs,corr(POFFs','rows','complete'));
% subplot(122); 
% imagesc(fs,fs,corr(PONs','rows','complete'));

ind = isnan(sum(POFF));
POFF(:,ind) = [];
% PON(:,ind) = [];

[coeff,score,latent,t2,explained,mu] = pca(POFF','rows','complete');

ind = isnan(BR_OFF);
Y = BR_OFF(~ind);
% X = POFF(1:10:end,~ind)';

k = 10;
X = score(~ind,1:k);
%X = score(~ind,:);

rng(1);
opt = statset('Maxiter',1000,'Display','final');
[W,H] = nnmf(POFF',k,'options',opt,'algorithm','als');
%[W,H] = nnmf(POFF',k);
X = W(~ind,1:k);

% [b,ci,r,rint,stats] = regress(Y',[ones(size(Y')),X]);
% stats
% % 
% plot(b)
% hold on
% plot(ci,'--')
% plot([1 k],[0 0])
% % 
rng(1);
[B FitInfo] = lassoglm([ones(size(Y')),X],Y','normal','CV',10,'alpha',.75);
min1pts = find(B(:,FitInfo.Index1SE))
figure;
subplot(211); hold on
plot([0 k],[0 0],'--')
BB = B(:,FitInfo.Index1SE);
plot(BB);
subplot(212); hold on
BB = BB(min1pts);
ind2 = BB<0;
plot(f,H(min1pts(ind2) - 1,:)','-')
ind2 = BB>0;
plot(f,H(min1pts(ind2) - 1,:)','--')

[b,ci,r,rint,stats] = regress(Y',[ones(size(Y')),X(:,min1pts-1)]);
stats