function batch_spikeana2_Stacie
% calls the fonction burst, regularity and detectPause located in
% LabTools/subtrees/matutils/spk

boucle1 = dir('*Right*.mat');
boucle2 = dir('*Left*.mat');
boucle = [boucle1; boucle2];

for nfile = 1:numel(boucle);
    load(boucle(nfile).name)
    disp(boucle(nfile).name)
    
    [p] = plx.spikeana2_AB(p);
    eval(['save ' boucle(nfile).name ' p;'])
    
    clearvars -except boucle nfile
end




