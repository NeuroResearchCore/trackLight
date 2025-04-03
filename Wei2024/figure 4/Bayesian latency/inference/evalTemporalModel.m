function T = evalTemporalModel(previousState, algoParam)
%  evalTemporalModel  evaluate the belief of the current state given the
%  previous state evaluated on the temporal model
%
%     p(x_{i,t} | p(x_{i,t-1}, i=1,2,3
%
%
% Reference: "Bayesian tracking of intracranial pressure signal morphology" 
% Scalzo et al. Artif Intell Med. 2012 Feb;54(2):115-23.   
%
%==========================================================================
%   version 1.0 -- 10/2017 -- Fabien Scalzo, PhD 
%

if(algoParam.parametricModel)         
    % latency
    T.mu1L = previousState.mu1L;
    T.mu2L = previousState.mu2L;
    T.mu3L = previousState.mu3L;

    T.std1L = (previousState.std1L + algoParam.temporalSigmaL)/2;
    T.std2L = (previousState.std2L + algoParam.temporalSigmaL)/2;
    T.std3L = (previousState.std3L + algoParam.temporalSigmaL)/2;        
   
    % elevation
    T.mu1E = previousState.mu1E;
    T.mu2E = previousState.mu2E;
    T.mu3E = previousState.mu3E;

    T.std1E = (previousState.std1E + algoParam.temporalSigmaE)/2;
    T.std2E = (previousState.std2E + algoParam.temporalSigmaE)/2;
    T.std3E = (previousState.std3E + algoParam.temporalSigmaE)/2;            
    
else        
    % latency    
    adjustBW(previousState.kde1L, double((mean(getbw(previousState.kde1L)) .* algoParam.temporalSigmaL)/2));
    adjustBW(previousState.kde2L, double((mean(getbw(previousState.kde2L)) .* algoParam.temporalSigmaL)/2));
    adjustBW(previousState.kde3L, double((mean(getbw(previousState.kde3L)) .* algoParam.temporalSigmaL)/2));        
    
    T.kde1L = resample(previousState.kde1L, double(algoParam.OptionsKDE.nParticle));        
    T.kde2L = resample(previousState.kde2L, double(algoParam.OptionsKDE.nParticle));
    T.kde3L = resample(previousState.kde3L, double(algoParam.OptionsKDE.nParticle));        

    % elevation    
    adjustBW(previousState.kde1E, double((mean(getbw(previousState.kde1E)) .* algoParam.temporalSigmaE)/2));
    adjustBW(previousState.kde2E, double((mean(getbw(previousState.kde2E)) .* algoParam.temporalSigmaE)/2));
    adjustBW(previousState.kde3E, double((mean(getbw(previousState.kde3E)) .* algoParam.temporalSigmaE)/2));        
    
    T.kde1E = resample(previousState.kde1E, double(algoParam.OptionsKDE.nParticle));        
    T.kde2E = resample(previousState.kde2E, double(algoParam.OptionsKDE.nParticle));
    T.kde3E = resample(previousState.kde3E, double(algoParam.OptionsKDE.nParticle));            
end    


% \std_{t to t-1} =  - \std_{t,t-1}^2 * \std_{t-1}^-1
%    T.std1 = (previousState.std1 + model.std1)/2;
%    T.std2 = (previousState.std2 + model.std2)/2;
%    T.std3 = (previousState.std3 + model.std3)/2;        
