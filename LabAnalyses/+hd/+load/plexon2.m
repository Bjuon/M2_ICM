function [dat,success] = LoadData_GPi(fname,spkname,start_t,end_t)

[OpenedFileName,Version,Freq,Comment,Trodalness,NPW,PreThresh,SpikePeakV,SpikeADResBits,SlowPeakV,SlowADResBits,Duration,DateTime] ...
   = plx_information(fname);

channelStr = 'ContinuousChannel00';
%channelStr = 'Channel0'; %'ContinuousChannel00';
alphabet = char('a'+(1:26)-1)';

dat.fileName = fname;
dat.spkName = spkname;
dat.start_t = start_t;
dat.end_t = end_t;
for i = 1:numel(spkname)
   channel = [channelStr spkname{i}(1)];
   if strcmp(spkname{i}(2),'u')
      spkname{i}(2) = 'U';
   end
   unit = find(alphabet==spkname{i}(2));
   [n, temp] = plx_ts(fname,channel,unit);%temp = allts{unit,channel};
   ind = (temp>=start_t(i))&(temp<=end_t(i));
   dat.spk{i} = temp(ind) - start_t(i);
   [~,~,~, temp] = plx_waves(fname,channel,unit);%temp = allwf{unit,channel}';
   dat.spkwf{i} = temp(ind,:)';
end