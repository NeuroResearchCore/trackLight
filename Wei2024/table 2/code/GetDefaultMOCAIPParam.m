function AlgoParam = GetDefaultMOCAIPParam
% Return the default parameters for running the MOCAIP algorithm
%
%
%
%
% Author:  Xiao Hu, Ph.D.

% Name of the pulse library 
AlgoParam.PulseLibName = 'pulselib.mat';

%Function pointer to the pulse recongnition function
AlgoParam.fnPulseReg = @ispulselegitimatebyCorr;


%Function pointer to the dominant pulse extraction function
AlgoParam.fnDomPulse = @clusterPulse;
%AlgoParam.fnDomPulse = @ClusterPulseMean;

%dimension of the basis constructed from pulse library
AlgoParam.PulseLibDim = 17;

%dimension of the basis constructed from pulse library
AlgoParam.ratio= 28.6235;


%Probability value for assigning a "null" position to {p1, p2, p3} when
%using a local pulse library
% -1:  not using local library
AlgoParam.ThresPEmptyLocal   = -1;

%Probability value for assigning a "null" position to {p1, p2, p3} when
%using a global pulse library
%
%-1: not using global library
AlgoParam.ThresPEmptyGlobal  = 0.02;

%Threshold for accepting the cluster as legitimate pulse when its average
%pusle's correlation with any member of the  global pulse library is beyond
%this threshold
AlgoParam.r1 =0.92;

%Threshold for accepting the cluster after it fails the correlation test
%against the global pulse library but satisfies the condition that 
%the correlation coefficient between its average pulse and the 90% of its
%members are greater than this threshold
AlgoParam.r2 =0.9;

%One of conditions for accepting a pulse cluster after it fails the
%correlation test against the global pulse library
AlgoParam.minNum = 1;

%A simple check on the maximal length of a pulse in seconds
AlgoParam.LegitimateLen = 1.5;

%Name of the procedure for detecting peak candidates
%DetectSPntByCurvature
%DetectSPntByVertDist
%DetectSPntByPDist
%DetectSPntByIntersection
AlgoParam.P3Proc = @DetectSPntByIntersection;

%Maximal shifting allowed when performing correlation test of two pulses in
%milliseconds
AlgoParam.maxShiftPos = 100;

%function pointer for loading the reference library. Choices are
%Calc3PMetrics: default
%Calc3PMetrics_backward: relative to the end point of pulse
%Calc3PMetrics_mix: p1 and p2 are relative to the start of the pulse while
%p3 relative to the end of pulse
%
AlgoParam.MetricProc = @Calc3PMetrics;

%function pointer for peak designation that does not use reference pulse
%library
AlgoParam.LogicProc = @P3LogicPro_default;

%Maximum distance between a regression prediction and a candidate peak.
%used in SeqAnalyzePulse() to call Assign_PeaksSingle()
AlgoParam.th1 = 30; % 30
AlgoParam.th2 = 30; % 30
AlgoParam.th3 = 30; % 30

%function pointer for the prediction of the peaks using a regression
%technique
AlgoParam.regPredictor = @Reg_PredKSR;

% technique used for the peak detection
% 1: default MOCAIP with Gaussian priors
% 2: KSR regression (see Scalzo et al 09)
% 3: KSR regression + derivative + sampling (see Scalzo et al 10)
AlgoParam.type = 3; 

% switch AlgoParam.type
%     case 2 
%         %AlgoParam.regFileName = 'icpRegModel1.mat';        
%         AlgoParam.regFileName = 'icpRegModel0.mat';
% %        AlgoParam.regFileName = 'icpRegModelNew.mat';            
%     case 3
%         AlgoParam.RegOptions.ReguAlpha = 0.009; 
%         AlgoParam.RegOptions.t = 5;    
%         AlgoParam.regFileName = 'type13_mix.mat';                
%         AlgoParam.optionsCurv.sigma = 5;   
%         AlgoParam.length = 499; 
%     case 4   
% end

%function pointer to onset
%AlgoParam.fnOnset = @DetectOnset;
AlgoParam.fnOnset = @DetectMinPointOpt;


%number of dominant pulses for updating gaussian parameters
AlgoParam.iAdaptBeatNumber = 30;

%number of dominant pulses whoese median gives the onset position for
%calucating L1-LT etc.
AlgoParam.iOnsetWin = 5;


%function pointer to the function that is used to determine the onset for
%calculating peak locations. Pulses in the library should use the same
% function. This will be enforced at the runtime
%@detectonset;
%@detectminpoint;
%AlgoParam.fnOnsetDetect = @detectonset;
AlgoParam.fnOnsetDetect = @DetectMinPointOpt;


% 0- raw peak predictions from regression models are used 
% 1- each raw peak prediction from regression models is assigned to its
% closest peak candidate (if any closer than AlgoParam.th(i))
% 2- each raw peak prediction from regression models is assigned to its
% closest peak candidate (if any closer than AlgoParam.th(i)), otherwise
% the raw prediction is used
AlgoParam.AssignPeakToCandidate = 2;


% Length of dominant pulses (in minutes)
AlgoParam.iMinute = 1;

