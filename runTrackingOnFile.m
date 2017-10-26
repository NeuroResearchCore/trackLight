function [rawPeaks, rawMetrics, domPulsesAUC, pulsesTime, mICP, tracking] = runTrackingOnFile(pathToData, pathToResults, fileName, settings)
% runTrackingOnFile performs morphological tracking on a .mat or .bin file
%
%    runTrackingOnFile(pathToData, pathToResults, fileName, AlgoParam)
% 
%        Input:
%           pathToData    - directory of ICP data (default: './sourceData/')
%           pathToResults - output directory (default: './results/')  
%           fileName      - ICP file to process
%           settings     - see getDefaultSettings()
%
% Reference: "Bayesian tracking of intracranial pressure signal morphology" 
% Scalzo et al. Artif Intell Med. 2012 Feb;54(2):115-23.   
%
%==========================================================================
%   version 1.0 -- 10/2017 -- Fabien Scalzo, PhD 
%

if(nargin < 4)
    settings = getDefaultSettings();
end

% generate dominant pulses over a segment of ICP
[domPulses, domPulsesAUC, pulsesTime, mICP] = getBeatClusters(strcat(pathToData,fileName), settings);  %#ok<ASGLU>

% execute peak detection and feature extraction on each average ICP pulse
[rawPeaks, rawMetrics] = runMOCAIP(domPulsesAUC, settings);

% Execute bayesian tracking to "smooth" the results over time
if(settings.performBayesianTracking)
    metricsV = convertMetricsToVector(rawMetrics);
    tracking = performTracking(metricsV);
else 
    tracking = [];
end

% save results
[~, ~, ext] = fileparts(fileName);
judgeFile = strrep(fileName, ext, '_avgWaveforms.mat');
save(strcat(pathToResults,judgeFile), 'domPulses', 'domPulsesAUC', 'pulsesTime', 'mICP', 'rawPeaks', 'rawMetrics', 'tracking');