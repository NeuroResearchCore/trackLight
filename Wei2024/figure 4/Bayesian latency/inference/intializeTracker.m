function previousState = intializeTracker(peaks, pulseIdx, algoParam)    
%
% intializeTracker
%
%
% Reference: "Bayesian tracking of intracranial pressure signal morphology" 
% Scalzo et al. Artif Intell Med. 2012 Feb;54(2):115-23.   
%
%==========================================================================
%   version 1.0 -- 10/2017 -- Fabien Scalzo, PhD 
%

% latency
previousState.mu1L = double(peaks(pulseIdx,2));
previousState.mu2L = double(peaks(pulseIdx,3));
previousState.mu3L = double(peaks(pulseIdx,4));

previousState.std1L = double(algoParam.initialSigmaL*algoParam.initialSigmaL);
previousState.std2L = double(algoParam.initialSigmaL*algoParam.initialSigmaL);
previousState.std3L = double(algoParam.initialSigmaL*algoParam.initialSigmaL);

% elevation
previousState.mu1E = double(peaks(pulseIdx,8));
previousState.mu2E = double(peaks(pulseIdx,9));
previousState.mu3E = double(peaks(pulseIdx,10));

previousState.std1E = double(algoParam.initialSigmaE*algoParam.initialSigmaE);
previousState.std2E = double(algoParam.initialSigmaE*algoParam.initialSigmaE);
previousState.std3E = double(algoParam.initialSigmaE*algoParam.initialSigmaE);

% nonparametric
if(~algoParam.parametricModel)
    previousState.kde1L = resample(kde(previousState.mu1L, algoParam.initialSigmaL), algoParam.OptionsKDE.nParticle);
    previousState.kde2L = resample(kde(previousState.mu2L, algoParam.initialSigmaL), algoParam.OptionsKDE.nParticle);
    previousState.kde3L = resample(kde(previousState.mu3L, algoParam.initialSigmaL), algoParam.OptionsKDE.nParticle);

    previousState.kde1E = resample(kde(previousState.mu1E, algoParam.initialSigmaE), algoParam.OptionsKDE.nParticle);
    previousState.kde2E = resample(kde(previousState.mu2E, algoParam.initialSigmaE), algoParam.OptionsKDE.nParticle);
    previousState.kde3E = resample(kde(previousState.mu3E, algoParam.initialSigmaE), algoParam.OptionsKDE.nParticle);    
end
