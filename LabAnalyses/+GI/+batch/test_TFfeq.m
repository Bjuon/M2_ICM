figure, 

TF_1   = tfr(lfp,'method','chronux','tBlock',tBlock,'tStep',0.03,'f',[1 100],'tapers',[3 5],'pad',1);
TF_5   = tfr(lfp,'method','chronux','tBlock',tBlock,'tStep',0.03,'f',[5 100],'tapers',[3 5],'pad',1);

subplot(3,1,1)
surf(TF_1(1).times{1},TF_1(1).f,10*log10(TF_1(1).values{1}(:,:,1)'),'edgecolor','none');  view(0,90);
title('TF 1 - 100 Hz'), caxis([-35 10 ])
subplot(3,1,2)
surf(TF_1(1).times{1},TF_1(1).f(5:end),10*log10(TF_1(1).values{1}(:,5:end,1)'),'edgecolor','none');  view(0,90);
title('TF 1 - 100 Hz - plot with 5 Hz cut'), caxis([-35 10 ])
subplot(3,1,3)
surf(TF_5(1).times{1},TF_5(1).f,10*log10(TF_5(1).values{1}(:,:,1)'),'edgecolor','none');  view(0,90);
title('TF 5 - 100 Hz'), caxis([-35 10 ])



figure,
subplot(3,1,1)
surf(TF(1).times{1},TF(1).f,10*log10(TF(1).values{1}(:,:,1)'),'edgecolor','none');  view(0,90);
title('TF raw'), caxis([-35 10 ])
subplot(3,1,2)
surf(TF(1).times{1},TF(1).f,squeeze(TF(1).values{1}(:,:,1)'),'edgecolor','none');  view(0,90);
title('TF bslBIP'), caxis([-15 15 ])
subplot(3,1,3)
surf(TF(1).times{1},TF(1).f,squeeze(TF(1).values{1}(:,:,1)'),'edgecolor','none');  view(0,90);
title('TF bslFOG'), caxis([-15 15 ])


figure,
subplot(2,1,1)
surf(bslTFadd_BIP(1).times{1},bslTFadd_BIP(1).f,real(10*log10(bslTFadd_BIP(1).values{1}(:,:,1)')),'edgecolor','none');  view(0,90);
title('bslTFadd_BIP'), caxis([-35 10])
subplot(2,1,2)
surf(bslTFadd(1).times{1},bslTFadd(1).f,real(10*log10(bslTFadd(1).values{1}(:,:,1)')),'edgecolor','none');  view(0,90);
title('bslTFadd'), caxis([-35 10])
