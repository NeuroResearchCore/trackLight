function AlgoParam = getDefaultTrackingParam2()
% Return the default parameters for running the MOCAIP algorithm
AlgoParam.parametricModel = 1;

AlgoParam.displayTrackingResults = 1;




AlgoParam.szChannel = 'ICP';  % select a channel (ICP,RMCA,LMCA)

AlgoParam.OptionsKDE.nParticle = 150;
AlgoParam.OptionsKDE.sigmaPairFact = 50;
AlgoParam.OptionsKDE.sigmaPriorFact = 10;
AlgoParam.OptionsKDE.sigmaTemporalFact = 1;


% number of length for the dominant pulses
AlgoParam.minRecLenForTracking = 1;
AlgoParam.clusterDuration = round(logspace(0,2.255,10));
AlgoParam.sinusNoise = 1;


AlgoParam.length = 499;          % for regression the pulse is resized

% Name of the pulse library 
AlgoParam.PulseLibName = 'pulselib.mat';

%Function pointer to the pulse recongnition function
AlgoParam.fnPulseReg = @ispulselegitimatebycorr;


%Function pointer to the dominant pulse extraction function
AlgoParam.fnDomPulse = @ClusterPulse;


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
% 0.04 (old value)
AlgoParam.ThresPEmptyGlobal  = 0.01;

%Threshold for accepting the cluster as legitimate pulse when its average
%pusle's correlation with any member of the  global pulse library is beyond
%this threshold
AlgoParam.r1 =0.95;

%Threshold for accepting the cluster after it fails the correlation test
%against the global pulse library but satisfies the condition that 
%the correlation coefficient between its average pulse and the 90% of its
%members are greater than this threshold
AlgoParam.r2 =0.9;

%One of conditions for accepting a pulse cluster after it fails the
%correlation test against the global pulse library
%AlgoParam.minNum = 1;
AlgoParam.minNum = 8;

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

%function pointer to onset
AlgoParam.fnOnset = @DetectOnset;

AlgoParam.RegOptions.ReguType = 'Ridge';
AlgoParam.RegOptions.KernelType = 'Gaussian';

AlgoParam.RegOptions.ReguAlpha = 0.009; % 0.009
AlgoParam.RegOptions.t = 5;    % 5

AlgoParam.RegOptions.learner = @Reg_LearnKSR;
AlgoParam.RegOptions.SRlearner = @Reg_LearnSR;

AlgoParam.RegOptions.predictor = @Reg_Predict;
AlgoParam.RegOptions.regPredictor = @Reg_PredKSR;

AlgoParam.MocaipOptions.learner = @Mocaip_Learn;
AlgoParam.MocaipOptions.predictor = @Mocaip_Pred;

%Maximum distance between a regression prediction and a candidate peak
AlgoParam.RegOptions.th1 = 37; 
AlgoParam.RegOptions.th2 = 37; 
AlgoParam.RegOptions.th3 = 37; 

% detect shoulder of the pulse
%AlgoParam.fnMinPoint = @DetectMinPoint;
AlgoParam.fnMinPoint = @DetectMinPointOpt;

% detect3P
AlgoParam.fnDetect3P = @Detect3P;

% curvature
AlgoParam.optionsCurv.sigma = 5;   



% tracking model
AlgoParam.modelFileName = sprintf('trackingModel%d%d_new.mat', 3, AlgoParam.parametricModel);


if(~AlgoParam.parametricModel) 
    AlgoParam.initialSigmaL = 30;
    AlgoParam.initialSigmaE = 5;

    AlgoParam.temporalSigmaL = 0.2;   % should be equal to var(model.temporalmodel.kde).2,.2
    AlgoParam.temporalSigmaE = 0.2;

    AlgoParam.observationSigmaL = 20; %1,10
    AlgoParam.observationSigmaE = 3; 
else
    AlgoParam.observationSigmaL = 2.3;%6.25; 
    AlgoParam.temporalSigmaL = 3.25;                                
    AlgoParam.pairwiseSigmaL = 75;  % 25, higher -> less influence or less confident                
    AlgoParam.initialSigmaL = 15;                                     

    AlgoParam.observationSigmaE = AlgoParam.observationSigmaL ./ 3;
    AlgoParam.temporalSigmaE = AlgoParam.temporalSigmaL  ./ 10;                 
    AlgoParam.pairwiseSigmaE = AlgoParam.pairwiseSigmaL ./ 10; 
    AlgoParam.initialSigmaE = AlgoParam.initialSigmaL ./ 10;                                     
    
end
