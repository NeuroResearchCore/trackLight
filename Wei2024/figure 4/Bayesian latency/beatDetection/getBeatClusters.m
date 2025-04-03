function [avgPulses, pulsesTime, mICP] = getBeatClusters(fileName, settings)
% Extract a series of average pulses from a mat file 
%
%    getBeatClusters(pathToData, pathToResults, fileName, AlgoParam)
% 
%        Input:
%           fileName      - ICP file to process
%           settings     - see getDefaultSettings()
%
%        Output:
%           domPulses     list of dominant pulses
%           domPulsesAUC  list of dominant pulses normalized wrt AUC
%           pulsesTime    time of each pulse 
%           fs            sampling rate
%           mICP          average ICP for each pulse
%
% Reference: "Bayesian tracking of intracranial pressure signal morphology" 
% Scalzo et al. Artif Intell Med. 2012 Feb;54(2):115-23.   
%
%==========================================================================
%   version 1.0 -- 10/2017 -- Fabien Scalzo, PhD 
%

load(fileName, 'icp', 'ecg', 'ticp');

[clusters, relativeTime] = extractIndividualPulses(icp, ecg, settings);

[avgPulses, pulsesTime, mICP] = clusterPulses(clusters, relativeTime, settings);
