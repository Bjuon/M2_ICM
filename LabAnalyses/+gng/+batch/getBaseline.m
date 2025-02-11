
function [BslTiming, Bsl] = getBaseline(EventTimes, tstart, tend, reps, t)

% input
% EventTimes = vector of event times of size : nbTrial * 1 
% tstart = starting time of baseline relative to event
% tend = ending time of baseline relative to event
% reps = raster matrice : nbTime bins * nb trials * nbNeurones
% t = teimes or reps

BslTiming = [EventTimes + tstart EventTimes + tend];
Time_bins = bsxfun(@ge, t', BslTiming(:,1))' & bsxfun(@le, t', BslTiming(:,2))';
%check
if max(length(tstart:0.001:tend) - sum(Time_bins)) > 2
    idMax = find(length(tstart:0.001:tend) - sum(Time_bins) > 2);
    error(['trials ' num2str(idMax) ' are too short']) 
end
if min(length(tstart:0.001:tend) - sum(Time_bins)) < 0
    idMin = find(length(tstart:0.001:tend) - sum(Time_bins) < 0);
    error(['trials ' num2str(idMin) ' are too long']) 
end
clear Bsl
for t_count = 1 : size(Time_bins,2)
    %Bsl(:,t_count,:) = reps(find(Time_bins==1,min(sum(Time_bins))),t_count,:);
    Bsl(:,t_count,:) = reps(find(Time_bins(:,t_count)==1,min(sum(Time_bins))),t_count,:);
end