function [peaks] = Mark3PForTracking(pulses, iValidIndex, fs, settings)
%
% Reference: "Bayesian tracking of intracranial pressure signal morphology" 
% Scalzo et al. Artif Intell Med. 2012 Feb;54(2):115-23.   
%
%==========================================================================
%   version 1.0 -- 10/2017 -- Fabien Scalzo, PhD 
%

% default:  fM3p = @Mark3P_RegressionTracking;
peaks = feval(settings.fM3p, pulses, iValidIndex, fs, settings);


