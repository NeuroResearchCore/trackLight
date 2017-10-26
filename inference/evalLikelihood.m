function L = evalLikelihood(peaks, pulseIndex, algoParam)
%  evalLikelihood detect ICP peaks in current pulse using regression model
%
%         \phi_{i,t} = p(x_{i,t} | p(y_{i,t}), i=1,2,3
%
% Reference: "Bayesian tracking of intracranial pressure signal morphology" 
% Scalzo et al. Artif Intell Med. 2012 Feb;54(2):115-23.   
%
%==========================================================================
%   version 1.0 -- 10/2017 -- Fabien Scalzo, PhD 
%

% latency
L.mu1L = double(peaks(pulseIndex,2));
L.mu2L = double(peaks(pulseIndex,3));
L.mu3L = double(peaks(pulseIndex,4));

L.std1L = algoParam.observationSigmaL*algoParam.observationSigmaL;
L.std2L = algoParam.observationSigmaL*algoParam.observationSigmaL;
L.std3L = algoParam.observationSigmaL*algoParam.observationSigmaL;

% elevation
L.mu1E = double(peaks(pulseIndex,8));
L.mu2E = double(peaks(pulseIndex,9));
L.mu3E = double(peaks(pulseIndex,10));
        
L.std1E = algoParam.observationSigmaE*algoParam.observationSigmaE;
L.std2E = algoParam.observationSigmaE*algoParam.observationSigmaE;
L.std3E = algoParam.observationSigmaE*algoParam.observationSigmaE;

if(~algoParam.parametricModel)
    if(~isnan(L.mu1L))
        L.kde1L = kde(L.mu1L, double(algoParam.observationSigmaL));
    end
    
    if(~isnan(L.mu2L))
        L.kde2L = kde(L.mu2L, double(algoParam.observationSigmaL));
    end
    
    if(~isnan(L.mu3L))
        L.kde3L = kde(L.mu3L, double(algoParam.observationSigmaL));
    end

    if(~isnan(L.mu1E))
        L.kde1E = kde(L.mu1E, double(algoParam.observationSigmaE));
    end
    
    if(~isnan(L.mu2E))
        L.kde2E = kde(L.mu2E, double(algoParam.observationSigmaE));
    end
    
    if(~isnan(L.mu3E))        
        L.kde3E = kde(L.mu3E, double(algoParam.observationSigmaE));
    end
end

