

indLO = grp.RIGIDITY_DIFF_CONTRA <= nanmedian(grp.RIGIDITY_DIFF_CONTRA);
[coeff, score, latent, tsquared, explained] = pca(grp.PSD);

figure;
for i = 1:4
   subplot(2,2,i); hold on
   title(num2str(corr(grp.RIGIDITY_DIFF_CONTRA,score(:,i))));
   plot(grp.RIGIDITY_DIFF_CONTRA,score(:,i),'k.')
   plot(grp.RIGIDITY_DIFF_CONTRA(indLO),score(indLO,i),'bo')
   plot(grp.RIGIDITY_DIFF_CONTRA(~indLO),score(~indLO,i),'ro')
   lsline
end

indLO = out.RIGIDITY_DIFF_CONTRA <= nanmedian(grp.RIGIDITY_DIFF_CONTRA);
[coeff, score, latent, tsquared, explained] = pca(out.PSD);
figure;
for i = 1:4
   subplot(2,2,i); hold on
   title(num2str(corr(out.RIGIDITY_DIFF_CONTRA,score(:,i))));
   plot(out.RIGIDITY_DIFF_CONTRA,score(:,i),'k.')
   plot(out.RIGIDITY_DIFF_CONTRA(indLO),score(indLO,i),'bo')
   plot(out.RIGIDITY_DIFF_CONTRA(~indLO),score(~indLO,i),'ro')
   lsline
end


psd = grp.psd;

temp = grp;
temp.PSD = temp.PSD(:,1:1000:end);
temp.SIG = [];

dlmwrite('psd.txt',temp.PSD);

temp.PSD = [];
writetable(temp,'clinic.txt');