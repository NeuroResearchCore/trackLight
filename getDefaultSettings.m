function AlgoParam = getDefaultSettings()
% getDefaultSettings
% Return the default parameters 
%
% Reference: "Bayesian tracking of intracranial pressure signal morphology" 
% Scalzo et al. Artif Intell Med. 2012 Feb;54(2):115-23.   
%
%==========================================================================
%   version 1.0 -- 10/2017 -- Fabien Scalzo, PhD 
%

%           pathToICPData   - directory of ICP data (default: './sourceData/')
AlgoParam.pathToData = './sourceData/';

%           pathToResults   - output directory (default: './results/')  
AlgoParam.pathToResults = './results/';

AlgoParam.clusterDuration = 60;  % 180, in seconds (1 = pulse by pulse)

AlgoParam.ifs = 125; % input sample frequency
AlgoParam.inputFileType = 'Merritt';
AlgoParam.computeExtendedMetrics = 0;
AlgoParam.type = 2; 
AlgoParam.performBayesianTracking = 1; 

AlgoParam.smoothFactor = .1; % lower = smoother

AlgoParam.length = 499;          % for regression the pulse is resized

%Name of the procedure for detecting peak candidates
AlgoParam.P3Proc = @DetectSPntByIntersection;

%function pointer to onset
AlgoParam.fnOnset = @DetectOnset;

AlgoParam.RegOptions.regPredictor = @Reg_PredKSR;

% %Maximum distance between a regression prediction and a candidate peak.
AlgoParam.th1 = 37; 
AlgoParam.th2 = 37;
AlgoParam.th3 = 37; 

% detect shoulder of the pulse
%AlgoParam.fnMinPoint = @DetectMinPoint;
AlgoParam.fnMinPoint = @DetectMinPointOpt;

% detect3P
AlgoParam.fnDetect3P = @Detect3P;

% curvature
AlgoParam.optionsCurv.sigma = 5;   


% tracking model
AlgoParam.parametricModel = 1;
AlgoParam.modelFileName = sprintf('trackingModel%d%d.mat', 3, AlgoParam.parametricModel);

AlgoParam.stdValues = [40 ...
   50 ...
   60 ...
  80 ...
   30 ...
   30 ...
    20 ...
    20 ...    
    20 ...
    20 ...
    20 ...
    20 ...
    15 ...
    15 ...
    15 ...
    15 ... 
    15 ...
    15 ...
   45.7208 ...
   30 ...
   30 ...
   22.0496 ...
   30 ...
   23.2563 ...
    15 ...
    15 ...
    8];

AlgoParam.temporalSigma = AlgoParam.stdValues .* 0.01;  
AlgoParam.observationSigma = AlgoParam.temporalSigma ./ AlgoParam.smoothFactor;
AlgoParam.initialSigma = AlgoParam.temporalSigma ./ 0.0475;

% 0- raw peak predictions from regression models are used 
% 1- each raw peak prediction from regression models is assigned to its
% closest peak candidate (if any closer than AlgoParam.th(i))
% 2- each raw peak prediction from regression models is assigned to its
% closest peak candidate (if any closer than AlgoParam.th(i)), otherwise
% the raw prediction is used
AlgoParam.AssignPeakToCandidate = 2;

AlgoParam.fnOnsetDetect = @DetectMinPointOpt;

switch AlgoParam.type
    case 1
        AlgoParam.fM3p = @Mark3P_OriginalTracking;
    case 2
        % default
        AlgoParam.fM3p = @Mark3P_RegressionTracking;
        AlgoParam.regFileName = 'icpRegModel0.mat';
        AlgoParam.regPredictor = @Reg_PredKSR;
    case 3        
        AlgoParam.fM3p = @Mark3P_RegressionDerivativeTracking;    
        AlgoParam.RegOptions.ReguAlpha = 0.009; 
        AlgoParam.RegOptions.t = 5;    
        AlgoParam.regFileName = 'type13_mix.mat';                
        AlgoParam.optionsCurv.sigma = 5;   
        AlgoParam.length = 499;         
end
