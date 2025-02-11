% nRand = 10000;
% t1 = -1.5;
% t2 = 1.5;

function [rStats, rStats_bonf, t] = ResamplingTest(times,nRand,t1,t2)

import spk.*

clear AllPerm
[r,t,r_sem,~,reps] = getPsth(times,0.075, 'method','hist', 'window', [t1 t2]); 
%reps : nbTime * nbTrial * nbCells
%r :  nbTime * nbCells
r = r(1:end-1,:);
t = t(1:end-1);
r_sem = r_sem(1:end-1,:,:);
reps = reps(1:end-1,:,:);

rng('shuffle')
for nr = 1:nRand
    %nr
    clear reps_Perm
    for nTrial = 1:size(reps,2)
        t_shift = circshift([1:length(t)]', randperm(length(t),1));
        reps_Perm(:,nTrial,:) = reps(t_shift,nTrial,:); %nbTime * nbTrial * nbCells
    end
    AllPerm(:,nr,:) = nanmean(reps_Perm,2); %nbTime * nbRand * nbCells
end

AllPerm = permute(AllPerm, [1 3 2]); %nbTime * nbCells * nbRand
rTest = repmat(r, [1 1 nRand]) > AllPerm;

rTest = sum(rTest,3)/nRand * 100;

rStats = zeros(size(r));
rStats(rTest>97.5) = 1;
rStats(rTest<2.5) = -1; %nbTime * nbCells

rStats_bonf = zeros(size(r));
rStats_bonf(rTest>99.95) = 1;
rStats_bonf(rTest<0.05) = -1; %nbTime * nbCells


