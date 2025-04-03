function BlandAltmanFigure()

% options.learnerList = {@trainLSTM, @trainRidgeRegression, @trainKernelRidgeRegression, @trainNeuralNet, @trainDecisionForest, @trainSVM};
% options.testList =    {@testLSTM, @testRidgeRegression,  @testKernelRidgeRegression,  @testNeuralNet,  @testDecisionForest,  @testSVM};

options.learnerList = {@trainSVM};
options.testList =    {@testSVM};

% set options for ML methods
optionsKSR.ReguType = 'Ridge';
optionsKSR.ReguAlpha = .0008;
optionsKSR.t = 4;

optionsSR.ReguType = 'Ridge';
optionsSR.ReguAlpha = .002; %5

optionsSVM.epsilon = 0.5;

options.DecisionForest.paroptions = statset('UseParallel',true);
options.DecisionForest.nbTrees = 100;

options.neuralNet.nbLayers = 7;

optionsLSTM.numberHidden = 20;

%optionsList = {optionsLSTM, optionsSR, optionsKSR, options.neuralNet, options.DecisionForest, optionsSVM};
optionsList = {optionsSVM};

options.normalizeHeartRate = 1;
options.normalizeAUC = 1;
options.removeOutliers = 1;
options.pulseLength = 400;

options.useDerivative = 0;
options.sigmaDerivative = 5;
options.normalizeAcrossPatient = 0;

options.excludePatients = 0;
options.patientsToExclude = [];

options.trainModel = 0;
options.saveModel = 0;
%options.outFileName = 'E:\code - Copy\learnPeakDetector\icpRegModel2020.mat';%wmm20200506

options.noiseRate = 0;

% load('E:\code - Copy\learnPeakDetector\ICPdatabase.mat', 'vv', 'l1', 'l2', 'l3', 'patient');


[norm, dataLearn] = performLearnICPRegModel(options);
uPatient = dataLearn.patient;

CV.training = 1:50;
CV.testing = 51:numel(dataLearn.patient);

mxVal = max(dataLearn.X(:));
dataLearn.X = dataLearn.X ./ mxVal;

for learner=1:numel(options.learnerList)
    idxTrain = CV.training;
    for peak=1:3
        models{learner}.model{peak} = feval(options.learnerList{learner}, dataLearn.X(idxTrain,:),...
            dataLearn.Y(idxTrain, peak), optionsList{learner});
    end    
end

%load('../table 1/models.mat', 'models');
idxTest = CV.testing;  

% figure(1);
% plot(dataLearn.Y(idxTest,1), '--'); hold on;
% figure(2);
% plot(dataLearn.Y(idxTest,2), '--'); hold on;
% figure(3);
% plot(dataLearn.Y(idxTest,3), '--'); hold on;

noiseRate = [0 0.05 0.1 0.15];
%noiseRate = fliplr(noiseRate);
for noiseIdx = 1:numel(noiseRate)
    
    noiseSignal = rand(size(dataLearn.X)).* (noiseRate(noiseIdx) .* max(dataLearn.X(:)));
    dataNoise = dataLearn.X + noiseSignal;
    
    
    for learner=1:numel(options.testList)
        for peak=1:3            
            Yhat = feval(options.testList{learner}, dataNoise(idxTest,:), models{learner}.model{peak});
            gt = dataLearn.Y(idxTest,peak);
                                  
            % BA plot paramters
            tit = sprintf('Peak %d - Learner %d - Noise %d', peak, learner, noiseIdx); % figure title
            label = {'Groundtruth','Prediction','mL/min'}; % Names of data sets
            corrinfo = {'RMSE'}; % stats to display of correlation scatter plot
            BAinfo = {'IQR', 'SD', 'LOA', 'RPC'}; % stats to display on Bland-ALtman plot

            h = figure;
          %  set(h, 'Visible', 'off');
            [~, ~, statsStruct] = BlandAltman(h, gt,Yhat,{'ICP'}, tit, {'peak'}, 'data1Mode', 'Truth', 'corrInfo',corrinfo,'baInfo',BAinfo,'showFitCI',' on', 'legend', 'off');
         
             statsStruct.differenceSTD
                       
%             sse = sum(sseI);            % SSE = sum( (Y - Yhat) ^2)
%             ssy = sum(ssyI);            % SSY = sum( (Y - mean(Y) ^2)
%             rsquared{peak}(noiseIdx, learner) = 1 - (sse ./ ssy);    % 1 - (SSE / SSY)
%             
%             rmse{peak}(noiseIdx, learner) = sqrt(sse ./ numel(sseI));
%             
%             errTotal = errI;
%             biasE = mean(errTotal);
%             stdE{peak}(noiseIdx, learner) = (mean(errTotal.^2) - biasE.^2) / sqrt(numel(errTotal));
%             
%             meanAbsErr{peak}(noiseIdx, learner) = mean(abs(errI));
            
       %     figure(peak);
       %     plot(Yhat, '-'); 
        end
    end
end

save('./step1Table2_m.mat',  'rsquared', 'stdE', 'rmse', 'meanAbsErr', 'noiseRate', 'norm');
