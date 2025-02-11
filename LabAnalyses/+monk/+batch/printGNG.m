clear all

import monk.load.*

monkey = 'Flocky';
dateStart = datenum('17/03/2017','dd/mm/yyyy');
dateEnd = datenum('28/05/2017','dd/mm/yyyy');


d = dir([monkey '*GNG_data-*.txt']);

keep = false(numel(d),1);
for i = 1:numel(d)
   
   hdr = loadEventIDE(d(i).name);
   
   ds{i} = hdr.Date;
   t(i) = datenum(hdr.Date,'dd/mm/yyyy');
   if (t(i) >= dateStart) && (t(i) <= dateEnd)
      keep(i) = true;
   end     
end
[~,I] = sort(t);
ds = ds(I)';
keep = keep(I);
d = d(I);
d(~keep) = [];
ds(~keep) = [];


goctl_rt_mean = zeros(numel(d),1);
gomix_rt_mean = zeros(numel(d),1);
goctl_rt_median = zeros(numel(d),1);
gomix_rt_median = zeros(numel(d),1);

goctl_mt_mean = zeros(numel(d),1);
gomix_mt_mean = zeros(numel(d),1);
goctl_mt_median = zeros(numel(d),1);
gomix_mt_median = zeros(numel(d),1);

for i = 1:numel(d)
   [hdr,data] = loadEventIDE(d(i).name);
   
   RT = [data.RT]';
   RT(RT==0) = NaN;
   TT = [data.TT]';
   TT(TT==0) = NaN;
   
   abort = logical([data.IsAbortTrial]');
   RT(abort) = NaN;
   TT(abort) = NaN;
   
   datestr{i} = hdr.Date;
   
   condition = {data.ConditionName}';
   goctl = strcmp(condition,'Go control');
   gomix = strcmp(condition,'Go');
   
   goctl_rt_mean(i) = nanmean(RT(goctl));
   gomix_rt_mean(i) = nanmean(RT(gomix));
   goctl_rt_median(i) = nanmedian(RT(goctl));
   gomix_rt_median(i) = nanmedian(RT(gomix));

   goctl_mt_mean(i) = nanmean(TT(goctl));
   gomix_mt_mean(i) = nanmean(TT(gomix));
   goctl_mt_median(i) = nanmedian(TT(goctl));
   gomix_mt_median(i) = nanmedian(TT(gomix));
end

tab = table(datestr',gomix_rt_mean, goctl_rt_mean,gomix_rt_mean - goctl_rt_mean,...
   gomix_rt_median, goctl_rt_median, gomix_rt_median - goctl_rt_median,...
   gomix_mt_mean, goctl_mt_mean,gomix_mt_mean - goctl_mt_mean,...
   gomix_mt_median, goctl_mt_median, gomix_mt_median - goctl_mt_median)
