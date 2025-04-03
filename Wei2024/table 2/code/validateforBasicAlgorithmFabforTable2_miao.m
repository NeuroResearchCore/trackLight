function validateforBasicAlgorithmFabforTable2_miao()

options.learnerList = {@trainLSTM, @trainRidgeRegression, @trainKernelRidgeRegression, @trainNeuralNet, @trainDecisionForest, @trainSVM};
options.testList =    {@testLSTM, @testRidgeRegression,  @testKernelRidgeRegression,  @testNeuralNet,  @testDecisionForest,  @testSVM};

% set options for ML methods
optionsKSR{1}.ReguType = 'Ridge';
optionsKSR{1}.ReguAlpha = .0018;
optionsKSR{1}.t = 2;

optionsKSR{2}.ReguType = 'Ridge';
optionsKSR{2}.ReguAlpha = .0001;
optionsKSR{2}.t = 4;

optionsKSR{3}.ReguType = 'Ridge';
optionsKSR{3}.ReguAlpha = .0008;
optionsKSR{3}.t = 4;


optionsSR.ReguType = 'Ridge';
optionsSR.ReguAlpha = .002; %5

optionsSVM.Standardize = false;
optionsSVM.KernelFunction = 'polynomial';
optionsSVM.PolynomialOrder = 2;
optionsSVM.Epsilon = 0.0075;
optionsSVM.BoxConstraint = 0.085;

options.DecisionForest.paroptions = statset('UseParallel',true);
options.DecisionForest.nbTrees = 100;

options.neuralNet.nbLayers = 6;

optionsLSTM.numberHidden = 50;

optionsList = {optionsLSTM, optionsSR, optionsKSR, options.neuralNet, options.DecisionForest, optionsSVM};
%optionsList = {optionsSR,optionsLSTM};

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
        if(strcmp(func2str(options.learnerList{learner}), 'trainKernelRidgeRegression'))
            optionsTrain = optionsList{learner}{peak};  
        else
            optionsTrain = optionsList{learner};
        end
        
        models{learner}.model{peak} = feval(options.learnerList{learner}, dataLearn.X(idxTrain,:),...
            dataLearn.Y(idxTrain, peak), optionsTrain);
    end    
end

idxTest = CV.testing;  

noiseRate = [0 0.05 0.1 0.15];
for noiseIdx = 1:numel(noiseRate)
    
    noiseSignal = rand(size(dataLearn.X)).* (noiseRate(noiseIdx) .* max(dataLearn.X(:)));
    dataNoise = dataLearn.X + noiseSignal;
    
    
    for learner=1:numel(options.testList)
        for peak=1:3            
            Yhat = feval(options.testList{learner}, dataNoise(idxTest,:), models{learner}.model{peak});
            errI = (dataLearn.Y(idxTest,peak) - Yhat);
            sseI = (dataLearn.Y(idxTest,peak) - Yhat).^2;
            ssyI = (dataLearn.Y(idxTest,peak) - mean(dataLearn.Y(idxTest,peak))).^2;
                        
            sse = sum(sseI);            % SSE = sum( (Y - Yhat) ^2)
            ssy = sum(ssyI);            % SSY = sum( (Y - mean(Y) ^2)
            rsquared{peak}(noiseIdx, learner) = 1 - (sse ./ ssy);    % 1 - (SSE / SSY)
            
            rmse{peak}(noiseIdx, learner) = sqrt(sse ./ numel(sseI));
            
            errTotal = errI;
            biasE = mean(errTotal);
            stdE{peak}(noiseIdx, learner) = (mean(errTotal.^2) - biasE.^2) / sqrt(numel(errTotal));
            
            meanAbsErr{peak}(noiseIdx, learner) = mean(abs(errI));
               
            nbSample = numel(errTotal);
            ssSD = errI .* (norm.normFactY.maxValueY(peak)-norm.normFactY.minValueY(peak));  
            SD{peak}(noiseIdx, learner) = sqrt(sum((ssSD - mean(ssSD)).^2) / nbSample);                       
        end
    end
end

save('./step1Table2_latest.mat',  'rsquared', 'stdE', 'rmse', 'meanAbsErr', 'noiseRate', 'norm', 'SD');