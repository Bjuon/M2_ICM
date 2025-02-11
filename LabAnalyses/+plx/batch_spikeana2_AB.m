function batch_spikeana2_AB
% calls the fonction burst, regularity and detectPause located in
% LabTools/subtrees/matutils/spk

boucledir = dir();

for ndir = 1:numel(boucledir);
    indbad = strfind(boucledir(ndir).name,'.');
    if ~isempty(indbad)
        continue;
    else
        cd(boucledir(ndir).name)
        
        boucle1 = dir('*Right*.mat');
        boucle2 = dir('*Left*.mat');
        boucle = [boucle1; boucle2];
        
        for nfile = 1:numel(boucle);
            load(boucle(nfile).name)
            disp(boucle(nfile).name)
            
            [p] = plx.spikeana2_AB(p);
            eval(['save ' boucle(nfile).name ' p;'])
            
            clearvars -except boucledir ndir boucle nfile
        end
        cd ..
    end
end
