function [dat,success] = LoadData_GPi(fname,spkname,start_t,end_t)

[OpenedFileName,Version,Freq,Comment,Trodalness,NPW,PreThresh,SpikePeakV,SpikeADResBits,SlowPeakV,SlowADResBits,Duration,DateTime] ...
   = plx_information(fname);

% get some counts
[tscounts, wfcounts, evcounts, slowcounts] = plx_info(OpenedFileName,1);

% gives actual number of units (including unsorted) and actual number of
% channels plus 1
[nunits1, nchannels1] = size( tscounts );

% we will read in the timestamps of all units,channels into a two-dim cell
% array named allts, with each cell containing the timestamps for a unit,channel.
% Note that allts second dim is indexed by the 1-based channel number.
% preallocate for speed
allts = cell(nunits1, nchannels1);
allwf = cell(nunits1, nchannels1);
for iunit = 0:nunits1-1   % starting with unit 0 (unsorted)
   for ich = 1:nchannels1-1
      if ( tscounts( iunit+1 , ich+1 ) > 0 )
         % get the timestamps for this channel and unit
         [nts, allts{iunit+1,ich}] = plx_ts(OpenedFileName, ich , iunit );
         if nts == 0
            disp(OpenedFileName)
           % keyboard
         end
         [~,~,ts,allwf{iunit+1,ich}] = plx_waves(OpenedFileName, ich , iunit );
      end
   end
end

alphabet = char('a'+(1:26)-1)';

dat.fileName = fname;
dat.spkName = spkname;
dat.start_t = start_t;
dat.end_t = end_t;
for i = 1:numel(spkname)
   channel = str2num(spkname{i}(1));
   unit = find(alphabet==spkname{i}(2)) + 1;
   temp = allts{unit,channel};
   ind = (temp>=start_t(i))&(temp<=end_t(i));
   dat.spk{i} = temp(ind) - start_t(i);
   temp = allwf{unit,channel}';
   dat.spkwf{i} = temp(:,ind);
end