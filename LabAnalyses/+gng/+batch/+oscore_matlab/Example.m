%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:  Example of using the function that computes the oscillation score from spike 
%               times stored as a list of trials
%
% Author:       Ovidiu F. Jurjut and Raul C. Muresan, 13.10.2011
%
% Disclaimer:   This code is freely usable for non-profit scientific purposes.
%               I do not warrant that the code is bug free. Use it at your own risk!
%
% Article:      The Oscillation Score: An Efficient Method for Estimating Oscillation 
%               Strength in Neuronal Activity
%               Muresan et al. 2008, Journal of Neurophysiology 99: 1333-1353               
%               http://jn.physiology.org/content/99/3/1333
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;

% Example values for the parameters
SamplingFrequency = 1000.0;     % Suppose we have a sampling frequency of 1 Khz.
TrialLength = 3500; %4000;             % Suppose we have a trial length of 4000 ms.
TrialNumber = 19; %20;               % Suppose we have 20 trials; 
                                % IMPORTANT: if you have a single trial, the confidence score is not defined, hence it will be set to 0!
OscillationFreq = 35.0;         % Suppose we have an oscillation frequency of 35 Hz
FMin = 5;                      % Suppose we want to look in the gamma-low band 30-50 Hz
FMax = 50;                      % Suppose we want to look in the gamma-low band 30-50 Hz

% Produce some random time stamps, with an oscillation frequency of OscillationFreq and store them in a list of trials
time = 0:1:TrialLength-1; % take a time grid
for i=1:TrialNumber % Create spike time stamps for each trial
    SubThreshold=sin(2*pi*OscillationFreq/SamplingFrequency*time)+randn(1,TrialLength+1);         
    Trial=find(SubThreshold > 2.7);    % The time stamps are the times when SubThreshold crosses 2.8 
    TrialList{i} = Trial;              % Add the trials to the list
end

% Compute the oscillation score and confidence of the estimate
% The OScoreSpikes function requires 5 parameters:
%   1. TrialList - array of cells of size (1 x Trial_Count) where each cell contains an array of spike times corresponding to one trial.
%   2. TrialLength - duration of trial in sample units
%   3. FMin - low boundary of the frequency band of interest in Hz
%   4. FMax - high boundary of the frequency band of interest in Hz
%   5. SamplingFrequency - sampling frequency of the time stamps in Hz
% and returns:
%   OS - oscillation score for the specified frequency band
%   CS - the confidence of the oscillation score estimate
%   OFq - peak oscillating frequency in the specified frequency band in Hz
%   AC - array containing the autocorrelogram computed on all trials
%   ACWP - array containing the autocorrelogram computed on all trials, smoothed and with no central peak
%   S - array containing the frequency spectrum of the smoothed peakless autocorrelogram

[OS, CS, OFq, AC, ACWP, S] = OScoreSpikes(TrialList, TrialLength, FMin, FMax, SamplingFrequency);

% NOTE: calling the function with less output variables, will return only the first outputs.
% Thus calling OS = OScoreSpikes(...) will return only the oscillation score, 
% and calling [OS, CS, OFq] = OScoreSpikes(...) will return the first 3 outputs.

% Plot the autocorrelogram and the smoothed, peakless autocorrelogram
CorrelationWindow = floor(size(AC,2)/2);
t=-CorrelationWindow:1:CorrelationWindow;
figure(1);
plot(t,AC);
xlabel('Time lag [bins]','FontSize',14);
ylabel('Count','FontSize',14);
title('Autocorrelogram (AC)','FontSize',14);
figure(2);
plot(t,ACWP);
xlabel('Time lag [bins]','FontSize',14);
ylabel('Count','FontSize',14);
title('Smoothed, peakless AC','FontSize',14);

% Plot the spectrum of the smoothed, peakless autocorrelogram
N = size(S,2);
f=0:SamplingFrequency/(2*N):SamplingFrequency/2*(N-1)/N;
figure(3);
plot(f,S);
xlabel('Frequency [Hz]','FontSize',14);
ylabel('Magnitude','FontSize',14);
title('Spectrum of the smoothed, peakless AC','FontSize',14);
