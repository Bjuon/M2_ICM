function [p] = spikeana2_AB(p)
% burts detection, pauses detection and regularity measures

a = spk.burst(p.intervals{1},1.5,1);

total.num_bursts = a(1).num_bursts;
total.mean_spikes_per_burst = a(1).mean_spikes_per_burst;
total.median_spikes_per_burst = a(1).median_spikes_per_burst;
total.total_spikes_in_bursts = a(1).total_spikes_in_bursts;
total.mean_intra_burst_frequency = a(1).mean_intra_burst_frequency;
total.median_intra_burst_frequency = a(1).median_intra_burst_frequency;
total.proportion_time_in_bursts = a(1).proportion_time_in_bursts;
total.proportion_spikes_in_bursts = a(1).proportion_spikes_in_bursts;

detail = rmfield(a,{'num_bursts',...
    'mean_spikes_per_burst',...
    'median_spikes_per_burst',...
    'total_spikes_in_bursts',...
    'mean_intra_burst_frequency',...
    'median_intra_burst_frequency',...
    'proportion_time_in_bursts',...
    'proportion_spikes_in_bursts'});
    
p.info('detail_burstLS') = detail;
p.info('total_burstLS') = total;

p.info('regularity') = p.apply(@(x) spk.regularity(x,'method',{'cv' 'cv2' 'lv' 'lvr' 'ir'}));

p.info('pauses') = p.apply(@(x) spk.detectPause(x));

