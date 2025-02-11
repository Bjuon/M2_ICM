Fs = [512 1024 2048];
Fpass = 1;
Fstop = 0.01;

for i = 1:numel(Fs)
   s = SampledProcess(randn(10000,1),'Fs',Fs(i));
   for j = 1:numel(Fpass)
      for k = 1:numel(Fstop)
         tic;
         [~,h(i,j,k),d(i,j,k)] = highpass(s,'Fpass',Fpass(j),'Fstop',Fstop(k),'designOnly',true);
         toc
         disp(['FIR_highpass_' sprintf('%g_',Fs(i)) sprintf('%g_',Fpass(j)) sprintf('%1.3f',Fstop(k))])
      end
   end
end
savename = ['FIR_highpass'];
save([savename '.mat'],'h','d','Fs','Fpass','Fstop');
