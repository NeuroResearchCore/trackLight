function [peaks] = detectPeaks(pulses, iValidIndex, fs, settings)
%
% Reference: "Bayesian tracking of intracranial pressure signal morphology" 
% Scalzo et al. Artif Intell Med. 2012 Feb;54(2):115-23.   
%
%==========================================================================
%   version 1.0 -- 10/2017 -- Fabien Scalzo, PhD 
%

% switch AlgoParamTracking.type
%     case 1
%         fM3p = @Mark3P_OriginalTracking;
%     case 2
%         fM3p = @Mark3P_RegressionTracking;
%         AlgoParamTracking.regFileName = 'icpRegModel0.mat';
%         AlgoParamTracking.regPredictor = @Reg_PredKSR;
%     case 3        
%         fM3p = @Mark3P_RegressionDerivativeTracking;    
%         AlgoParamTracking.RegOptions.ReguAlpha = 0.009; 
%         AlgoParamTracking.RegOptions.t = 5;    
%         AlgoParamTracking.regFileName = 'type13_mix.mat';                
%         AlgoParamTracking.optionsCurv.sigma = 5;   
%         AlgoParamTracking.length = 499;         
% end
 
%AlgoParamTracking.peakDetectionModel = 'C:\Users\fabien\Documents\learnPeakDetector\icpRegModel2017.mat';
%load(AlgoParamTracking.peakDetectionModel);

model = settings.model;
options = settings.options;

pulses = double(pulses);
[Dx, Dxx] = computePulseDerivatives(pulses, options);
X = [pulses Dx Dxx];

%X = NormalizeFea(X, 0);    
    
    X = (X - repmat(model.normFact.median,size(X,1), 1)) ./ repmat(model.normFact.std, size(X,1),1);    
    X = (X - model.normFact.min) ./ (model.normFact.max - model.normFact.min);

    [p1Tree, ~] = predict(model.tree.p1, X);
    [p2Tree, ~] = predict(model.tree.p2, X);
    [p3Tree, ~] = predict(model.tree.p3, X);
   
    p1Tree = (p1Tree.*(model.normFactY.maxValueY1-model.normFactY.minValueY1)) + model.normFactY.minValueY1;
    p2Tree = (p2Tree.*(model.normFactY.maxValueY2-model.normFactY.minValueY2)) + model.normFactY.minValueY2;
    p3Tree = (p3Tree.*(model.normFactY.maxValueY3-model.normFactY.minValueY3)) + model.normFactY.minValueY3;
    
    
    [Ktest] = constructKernel(X, model.dataLearn.X, options);
    p1ksr = Ktest*model.ksr.p1;    
    p2ksr = Ktest*model.ksr.p2;    
    p3ksr = Ktest*model.ksr.p3;
    
    p1ksr = (p1ksr.*(model.normFactY.maxValueY1-model.normFactY.minValueY1)) + model.normFactY.minValueY1;
    p2ksr = (p2ksr.*(model.normFactY.maxValueY2-model.normFactY.minValueY2)) + model.normFactY.minValueY2;
    p3ksr = (p3ksr.*(model.normFactY.maxValueY3-model.normFactY.minValueY3)) + model.normFactY.minValueY3;
    
    if(nnz(isnan(p1ksr)))  p1ksr(isnan(p1ksr)) = nanmean(p1ksr);    end
    if(nnz(isnan(p2ksr)))  p2ksr(isnan(p2ksr)) = nanmean(p2ksr);    end
    if(nnz(isnan(p3ksr)))  p3ksr(isnan(p3ksr)) = nanmean(p3ksr);    end
    
%    peaks = [(p1ksr*(model.normFactY.maxValueY1-model.normFactY.minValueY1))+model.normFactY.minValueY1) p2ksr p3ksr];
    
    p1Net =  model.net.p1(X')';
    p2Net =  model.net.p2(X')';
    p3Net =  model.net.p3(X')';

    p1Net = (p1Net.*(model.normFactY.maxValueY1-model.normFactY.minValueY1)) + model.normFactY.minValueY1;
    p2Net = (p2Net.*(model.normFactY.maxValueY2-model.normFactY.minValueY2)) + model.normFactY.minValueY2;
    p3Net = (p3Net.*(model.normFactY.maxValueY3-model.normFactY.minValueY3)) + model.normFactY.minValueY3;
    
    p1Ensemble = (p1Tree + p1Net + p1ksr) ./ 3;
    p2Ensemble = (p2Tree + p2Net + p2ksr) ./ 3;
    p3Ensemble = (p3Tree + p3Net + p3ksr) ./ 3;
    
    peaks.latency = [p1Ensemble p2Ensemble p3Ensemble];
    peaks.amplitude = zeros(numel(p1Ensemble), 3);
    for i=1:numel(p1Ensemble)
        try
        peaks.amplitude(i,:) = [pulses(i,round(p1Ensemble(i))) pulses(i,round(p2Ensemble(i))) pulses(i,round(p3Ensemble(i)))];
        catch
           continue;
        end
    end
    
 %   Yhat = Yhat';
 
 
%   imagesc(pulses)
% hold on;
% plot(p1Ensemble, 1:numel(p1Ensemble), 'k.');
% plot(p2Ensemble, 1:numel(p2Ensemble), 'kx');
% plot(p3Ensemble, 1:numel(p3Ensemble), 'ks');
    
%     i=1;
%          plot(pulses(i,:)); hold on; plot(round(p1Ensemble(i)), pulses(i,round(p1Ensemble(i))),  'go', 'MarkerSize', 8); 
%          plot(round(p2Ensemble(i)), pulses(i,round(p2Ensemble(i))),  'go', 'MarkerSize', 8); 
%          plot(round(p3Ensemble(i)), pulses(i,round(p3Ensemble(i))),  'go', 'MarkerSize', 8); 
%          close;

    
    
    
    
%     p1sr = X*model.sr.p1;
%     p2sr = X*model.sr.p2;
%     p3sr = X*model.sr.p3;
    
%    hold on; for i=1:size(pulses,1) plot(p1ksr(i), i, 'mo'); plot(p2ksr(i)-35, i, 'ko'); plot(p3ksr(i), i, 'go'); end
    
%    model.sr.p1 = SR(options, dataLearn.Y(:,1), dataLearn.X);
 %   model.sr.p2 = SR(options, dataLearn.Y(:,2), dataLearn.X);
  %  model.sr.p3 = SR(options, dataLearn.Y(:,3), dataLearn.X);
    
  %  model.dataLearn = dataLearn;
  %  model.normFact = normFact;



%[Ktest] = constructKernel(domPulses, model.dataLearn.X, options);
%peaks = Ktest*model.eig;

%[Ktest] = constructKernel(domPulses, model.dataLearn.X, options);
%peaks = domPulses*model.eig;


%g=1;
%peaks = feval(fM3p, pulses, iValidIndex, fs, AlgoParamTracking);


