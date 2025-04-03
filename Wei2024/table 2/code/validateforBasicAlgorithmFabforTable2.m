function validateforBasicAlgorithmFabforTable2()

options.learnerList = {@trainLSTM, @trainRidgeRegression, @trainKernelRidgeRegression, @trainNeuralNet, @trainDecisionForest, @trainSVM};
options.testList =    {@testLSTM, @testRidgeRegression,  @testKernelRidgeRegression,  @testNeuralNet,  @testDecisionForest,  @testSVM};

%options.learnerList = {@trainRidgeRegression};
%options.testList =    {@testRidgeRegression};

% set options for ML methods
optionsKSR.ReguType = 'Ridge';
optionsKSR.ReguAlpha = .001;
%optionsKSR.t = 1;

optionsSR.ReguType = 'Ridge';
optionsSR.ReguAlpha = 5;

optionsSVM = 'empty';

options.DecisionForest.paroptions = statset('UseParallel',true);
options.DecisionForest.nbTrees = 100;

options.neuralNet.nbLayers = 7;

optionsLSTM.numberHidden = 20;

optionsList = {optionsLSTM, optionsSR, optionsKSR, options.neuralNet, options.DecisionForest, optionsSVM};
%optionsList = {optionsSR};

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
            
       %     figure(peak);
       %     plot(Yhat, '-'); 
        end
    end
end

save('./step1Table2.mat',  'rsquared', 'stdE', 'rmse', 'meanAbsErr', 'noiseRate', 'norm');

load('./step1Table2.mat', 'meanAbsErr', 'noiseRate', 'norm', 'rmse');

cr = parula(12);
cr = flipud(cr);


% RMSE
figure;
entries = categorical({'LSTM', 'Ridge Regression', 'Kernel Ridge Regression', 'Neural Network', 'Random Forest', 'SVM'},...
{'LSTM', 'Ridge Regression', 'Kernel Ridge Regression', 'Neural Network', 'Random Forest', 'SVM'}),    
for peak=1:3
    subplot(1, 3, peak);
    title(sprintf('Peak %d', peak));
    b = bar(entries, cell2mat(rmse(peak))' * (norm.normFactY.maxValueY(peak)-norm.normFactY.minValueY(peak)), 'EdgeColor', 'none');
    title(sprintf('Peak %d', peak));

 %   lgb = legend('0', '5%', '10%', '15%', 'Location', 'eastoutside');
 %   title(lgb, 'Noise');
    ylabel('RMSE (ms)',  'FontSize', 18);
%    xlabel('Algorithm');
    
    set(gcf, 'color', 'w');
    set(gca, 'color', 'w');
    axis square;
    ax = gca;
    ax.YAxis.FontSize = 18;
    ax.XAxis.FontSize = 18;

    xtickangle(45);
    for k=1:4
        b(k).FaceColor = cr((k*3)-2,:);
    end
end
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
print('./Table2c_RMSE.png', '-painters', '-r300', '-dpng');
close;


figure;
cr = parula(12);
cr = flipud(cr);
for peak=1:3
    s = subplot(1, 3, peak);
    b = bar(categorical(100 .* noiseRate),  cell2mat(rmse(peak)) * (norm.normFactY.maxValueY(peak)-norm.normFactY.minValueY(peak)), 'EdgeColor', 'none'); 
    title(sprintf('Peak %d', peak));
    ylabel('RMSE (ms)', 'FontSize', 8);
    xlabel('Noise (%)', 'FontSize', 8);
    set(gcf, 'color', 'w');
    set(gca, 'color', 'w');
    ax = gca; 
    ax.FontSize = 6; 
    axis square;
    
    for k=1:6
        b(k).FaceColor = cr((k*2),:);
    end
end
print('./Table2b_RMSE.png', '-r300', '-dpng');
close;





figure;
entries = categorical({'LSTM', 'Ridge Regression', 'Kernel Ridge Regression', 'Neural Network', 'Random Forest', 'SVM'},...
{'LSTM', 'Ridge Regression', 'Kernel Ridge Regression', 'Neural Network', 'Random Forest', 'SVM'}),    
for peak=1:3
    subplot(1, 3, peak);
    title(sprintf('Peak %d', peak));
    b = bar(entries, cell2mat(meanAbsErr(peak))' * (norm.normFactY.maxValueY(peak)-norm.normFactY.minValueY(peak)), 'EdgeColor', 'none');
 %   lgb = legend('0', '5%', '10%', '15%', 'Location', 'eastoutside');
 %   title(lgb, 'Noise');
    ylabel('MAE (ms)',  'FontSize', 18);
%    xlabel('Algorithm');
    
    set(gcf, 'color', 'w');
    set(gca, 'color', 'w');
    axis square;
    ax = gca;
    ax.YAxis.FontSize = 18;
    ax.XAxis.FontSize = 18;

    xtickangle(45);
    for k=1:4
        b(k).FaceColor = cr((k*3)-2,:);
    end
end
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
print('./Table2c.png', '-painters', '-r300', '-dpng');
close;

figure;
b = bar(entries, cell2mat(meanAbsErr(peak))' * (norm.normFactY.maxValueY(peak)-norm.normFactY.minValueY(peak)), 'EdgeColor', 'none');
for k=1:4
    b(k).FaceColor = cr((k*3)-2,:);
end
hl = legend('0', '5%', '10%', '15%', 'Location', 'eastoutside');
title(hl, 'Noise');
set(gcf,'Position',(get(hl,'Position')...
    .*[0, 0, 1, 1].*get(gcf,'Position')));
% The legend is still offset so set its normalized position vector to
% fill the figure
set(hl,'Position',[0,0,1,1]);
% Put the figure back in the middle screen area
set(gcf, 'Position', get(gcf,'Position') + [500, 400, 0, 0]);
print('./Legend2c.png', '-r300', '-dpng');
close;
g=1;





for peak=1:3
    subplot(1, 3, peak); hold on;
    p = plot(categorical(100 .* noiseRate),  cell2mat(meanAbsErr(peak)) * (norm.normFactY.maxValueY(peak)-norm.normFactY.minValueY(peak)), 'o-', 'lineWidth', 2);
    for k=1:6
        p(k).Color = cr((k*2),:);
        p(k).MarkerFaceColor = cr((k*2),:);
    end
end
print('./Table2a.png', '-r300', '-dpng');
close;


figure;
cr = parula(12);
cr = flipud(cr);
for peak=1:3
    s = subplot(1, 3, peak);
    b = bar(categorical(100 .* noiseRate),  cell2mat(meanAbsErr(peak)) * (norm.normFactY.maxValueY(peak)-norm.normFactY.minValueY(peak)), 'EdgeColor', 'none'); 
    title(sprintf('Peak %d', peak));
    ylabel('MAE (ms)', 'FontSize', 8);
    xlabel('Noise (%)', 'FontSize', 8);
    set(gcf, 'color', 'w');
    set(gca, 'color', 'w');
    ax = gca; 
    ax.FontSize = 6; 
    axis square;
    
    for k=1:6
        b(k).FaceColor = cr((k*2),:);
    end
end
print('./Table2b.png', '-r300', '-dpng');
close;

% legend
figure;
set(gcf,'Position',[0,0,1024,1024]);
c = bar(categorical(100 .* noiseRate),  cell2mat(meanAbsErr(1)) * (norm.normFactY.maxValueY(1)-norm.normFactY.minValueY(1)), 'EdgeColor', 'none');
for k=1:6
    c(k).FaceColor = cr((k*2),:);
end
axis off;
hl = legend(c, 'LSTM', 'Ridge Regression', 'Kernel Ridge Regression', 'Neural Network', 'Random Forest', 'SVM');
title(hl,  'Algorithm');
%newPosition = [0 0 1 1];
%set(hl,'Position', newPosition, 'Units', 'normalized');
set(gcf,'Position',(get(hl,'Position')...
    .*[0, 0, 1, 1].*get(gcf,'Position')));
% The legend is still offset so set its normalized position vector to
% fill the figure
set(hl,'Position',[0,0,1,1]);
% Put the figure back in the middle screen area
set(gcf, 'Position', get(gcf,'Position') + [500, 400, 0, 0]);
print('./legendTable2.png', '-r300', '-dpng');
close;





