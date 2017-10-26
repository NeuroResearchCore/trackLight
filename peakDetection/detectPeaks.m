function [peaks] = detectPeaks(pulses, iValidIndex, fs, AlgoParamTracking)
%
% Reference: "Bayesian tracking of intracranial pressure signal morphology" 
% Scalzo et al. Artif Intell Med. 2012 Feb;54(2):115-23.   
%
%==========================================================================
%   version 1.0 -- 10/2017 -- Fabien Scalzo, PhD 
%

switch AlgoParamTracking.type
    case 1
        fM3p = @Mark3P_OriginalTracking;
    case 2
        fM3p = @Mark3P_RegressionTracking;
        AlgoParamTracking.regFileName = 'icpRegModel0.mat';
        AlgoParamTracking.regPredictor = @Reg_PredKSR;
    case 3        
        fM3p = @Mark3P_RegressionDerivativeTracking;    
        AlgoParamTracking.RegOptions.ReguAlpha = 0.009; 
        AlgoParamTracking.RegOptions.t = 5;    
        AlgoParamTracking.regFileName = 'type13_mix.mat';                
        AlgoParamTracking.optionsCurv.sigma = 5;   
        AlgoParamTracking.length = 499;         
end

peaks = feval(fM3p, pulses, iValidIndex, fs, AlgoParamTracking);


