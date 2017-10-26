function [p] = Reg_PredKSR(dataTest, model, options)
% Prediction for Peak Detection
%
%       [p] = Reg_PredKSR(dataTest, model, options)
% 
%             Input:
%               data     X  - NxDim data matrix. Each row vector of data is a
%                        pulse vector. 
%                        Y  - Nx3 data matrix. Each row vector of data
%                        contains the location of the three peaks p1,p2,p3
%                            
%             Output:
%                  p   - peaks locations
% 
% Reference: "Bayesian tracking of intracranial pressure signal morphology" 
% Scalzo et al. Artif Intell Med. 2012 Feb;54(2):115-23.   
%
%==========================================================================
%   version 1.0 -- 10/2017 -- Fabien Scalzo, PhD 
%

if nargin < 3
    options.ReguAlpha = 0.001;
    options.ReguType = 'Ridge';
    options.KernelType = 'Gaussian';
    options.t = 6; 
    options.compress = 0;  
end

[K] = constructKernel(dataTest.X, model.dataLearn, options);
    
p = K*model.eig;
