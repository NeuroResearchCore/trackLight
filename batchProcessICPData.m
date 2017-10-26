function batchProcessICPData(pathToData, pathToResults)
% batchProcessICPData
%
% Input:
%    pathToData    - directory of ICP data (default: './sourceData/')
%    pathToResults - output directory (default: './results/')  
%
% Reference: "Bayesian tracking of intracranial pressure signal morphology" 
% Scalzo et al. Artif Intell Med. 2012 Feb;54(2):115-23.   
%
%==========================================================================
%   version 1.0 -- 10/2017 -- Fabien Scalzo, PhD 
%
addpath('./beatDetection');
addpath('./inference');
addpath('./models');
addpath('./peakDetection');

settings = getDefaultSettings();

if(nargin < 2)
    pathToData = settings.pathToData;
    pathToResults = settings.pathToResults;
end

listFiles = dir(strcat(pathToData, '*.mat'));

for i=1:length(listFiles)
    runTrackingOnFile(pathToData, pathToResults, listFiles(i).name, settings);
end