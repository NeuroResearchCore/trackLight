function [out, rawMocaip] = performTrackingFromFileDemo(szJudgeFile, clustersForTracking, modelFileName, algoParam)
%  performTracking track ICP peaks across pulses
%
%===================================================================
%  Version 1.0 -- 2010
%  Authors: Fabien Scalzo
%

% read ICP dominant pulses,  see generateDominantPulsesForTracking.m

% domPulsesFile = strrep(fname, '.mat', '_domPulses.mat');
% load(domPulsesFile, 'clustersForTracking');

% load pre-computed peak locations detected using MOCAIP,
% see runMocaipForTracking.m
if(algoParam.type == 3)
%    szJudgeFile = strrep(domPulsesFile, '.mat', '_peak_auto_judge.mat');  
    
    load(szJudgeFile, 'cluster_PeakForTracking', 'sz', 'fs', 'nb');    
    peaks = cluster_PeakForTracking;       
    rawMocaip = peaks;       
    % peaks{1}  -> position of the peaks on the raw pulses
    % ...
    % peaks{10} -> position of the peaks on 3 min dominant pulses
else
    peaks = [];
    rawMocaip = [];
end

% load tracking model, see performLearnTrackingModel.m
load(modelFileName, 'model');                               

% raw icp pulses
pulses = clustersForTracking{1};   
       
% initialize the tracking
beliefs{1} = intializeTracker(pulses(1,:), [],  peaks{1}, 1, algoParam, model);    
out(1,:) = [beliefs{1}.mu1 beliefs{1}.mu2 beliefs{1}.mu3 beliefs{1}.muE1 beliefs{1}.muE2 beliefs{1}.muE3];

for j=2:size(pulses,1)      
    % temporal prior
    temporalPrior = evalTemporalModel(beliefs{j-1}, model.potentialsT, algoParam);    
    % compute likelihood
    likelihood = evalLikelihoodDemo(peaks{1}, j, algoParam);                
    % estimate beliefs (likelihood * temporal prior), 
    beliefs{j} = evalBeliefs(likelihood, temporalPrior, algoParam);                
    % update beliefs (belief * pairwise marginals)
    beliefs{j} = updateBeliefs(beliefs{j}, model.potentialsP, algoParam);    
    
    out(j,:) = [beliefs{j}.mu1 beliefs{j}.mu2 beliefs{j}.mu3 beliefs{j}.muE1 beliefs{j}.muE2 beliefs{j}.muE3];    
end