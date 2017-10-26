function [peaks, metrics] = runMOCAIP(pulses, settings)
% 
% Detect peaks and extract MOCAIP metrics on a series of dominant pulses
% 
% INPUT:
%           <pulses>        list of dominant pulses
%           <fs>            sampling rate
%           <AlgoParam>     options (see getDefaultTrackingParam())
%
% OUTPUT:
%           <metrics>       list of MOCAIP metrics for each pulse
%           
% Reference: "Bayesian tracking of intracranial pressure signal morphology" 
% Scalzo et al. Artif Intell Med. 2012 Feb;54(2):115-23.   
%
%==========================================================================
%   version 1.0 -- 10/2017 -- Fabien Scalzo, PhD 
%
peaks = [];
metrics = [];

if(size(pulses,1) == 0)
    return;
end

fs = 400;   % all the pulses have been resampled to 400hz

% detect peaks on each pulse
peaks = detectPeaks(pulses, ones(size(pulses,1),1), fs, settings);

% extract morphological metrics on each pulse
for k=1:size(peaks, 1)
    [metrics{k}.LTInfo, metrics{k}.AmpInfo, metrics{k}.CurvInfo, metrics{k}.SlopeInfo, metrics{k}.AuxInfo] =...
        computePulseMetrics(pulses(k,:), round(peaks(k, :)), fs, @DetectOnset);
end

peaks = peaks .* 1000 ./ 400;
