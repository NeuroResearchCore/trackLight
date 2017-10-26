function [tracking] = performTracking(peaks, algoParam)
%  performTracking track ICP peaks across pulses
%
% Reference: "Bayesian tracking of intracranial pressure signal morphology" 
% Scalzo et al. Artif Intell Med. 2012 Feb;54(2):115-23.   
%
%==========================================================================
%   version 1.0 -- 10/2017 -- Fabien Scalzo, PhD 
%

if(nargin<2)
    algoParam = getDefaultTrackingParam2();
end

load(algoParam.modelFileName, 'model');                               

% initialize the tracking
beliefs = cell(size(peaks,1), 1);
beliefs{1} = intializeTracker(peaks, 1, algoParam);    
tracking(1,:) = [beliefs{1}.mu1L beliefs{1}.mu2L beliefs{1}.mu3L beliefs{1}.mu1E beliefs{1}.mu2E beliefs{1}.mu3E];

for j=2:size(peaks,1)      
    % temporal prior
    temporalPrior = evalTemporalModel(beliefs{j-1}, algoParam);    
    % compute likelihood
    likelihood = evalLikelihood(peaks, j, algoParam);                
    % estimate beliefs (likelihood * temporal prior), 
    beliefs{j} = evalBeliefs(likelihood, temporalPrior, algoParam);                
    % update beliefs (belief * pairwise marginals)
    beliefs{j} = updateBeliefs(beliefs{j}, model.potentialsP, algoParam);    
    
    if(~algoParam.parametricModel)
        tracking(j,:) = [mean(beliefs{j}.kde1L) mean(beliefs{j}.kde2L) mean(beliefs{j}.kde3L) mean(beliefs{j}.kde1E) mean(beliefs{j}.kde2E) mean(beliefs{j}.kde3E)];    
    else
        tracking(j,:) = [beliefs{j}.mu1L beliefs{j}.mu2L beliefs{j}.mu3L beliefs{j}.mu1E beliefs{j}.mu2E beliefs{j}.mu3E];    
    end   
end