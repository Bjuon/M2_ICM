function MUA_read_file_phy


% load spike times
phydata.spike_times    = readNPY(fullfile(phydir, 'spike_times.npy'));     %each timing of any spike, in samples

% load clusters
phydata.cluster_group  = tdfread(fullfile(phydir, 'cluster_group.tsv'));   %phy classification.
phydata.cluster_info   = tdfread(fullfile(phydir, 'cluster_info.tsv'));    %id, amp, ch, depth, fr, group, n_spikes, sh
phydata.spike_clusters = readNPY(fullfile(phydir, 'spike_clusters.npy'));  %for each timing, which (merged) cluster. Include garbage clusters
