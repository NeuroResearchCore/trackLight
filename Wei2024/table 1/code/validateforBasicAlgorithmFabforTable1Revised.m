function validateforBasicAlgorithmFabforTable1Revised()

nFold = 3;

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
options.noiseRate = 0;

[norm, dataLearn] = performLearnICPRegModel(options);
uPatient = unique(dataLearn.patient);

CV = cvpartition(numel(uPatient), 'KFold',nFold);

mxVal = max(dataLearn.X(:));
dataLearn.X = dataLearn.X ./ mxVal;

noiseRate = [0 0.05 0.1 0.15];
for noiseIdx = 1:numel(noiseRate)
    noiseSignal = rand(size(dataLearn.X)).* (noiseRate(noiseIdx) .* max(dataLearn.X(:)));
    dataNoise = dataLearn.X + noiseSignal;

    for learner=1:1
        for peak=1:3
            for fold=1:nFold                
                idxTest = ~ismember(dataLearn.patient, uPatient(CV.training(fold)));
%                Yhat = feval(options.testList{learner}, dataNoise(idxTest,:), models{learner}.model{fold, peak});                

                Yhat_t = runMOCAIPonBeatArray(dataNoise(idxTest,:), []);
                Yhat = Yhat_t(:,peak);
                
                errI{fold} = (dataLearn.Y(idxTest,peak) - ((Yhat - norm.normFactY.minValueY(peak)) ./norm.normFactY.maxValueY(peak))  );
                sseI{fold} = (dataLearn.Y(idxTest,peak) - ((Yhat - norm.normFactY.minValueY(peak)) ./norm.normFactY.maxValueY(peak)) ).^2;
                ssyI{fold} = (dataLearn.Y(idxTest,peak) - nanmean(dataLearn.Y(idxTest,peak))).^2;
                
                gtValue = (dataLearn.Y(idxTest,peak) .* norm.normFactY.maxValueY(peak)) + norm.normFactY.minValueY(peak);
                predValue = Yhat;
                seeI_corrected{fold} = (gtValue - predValue) .^2;
                %Yhat3(:,peak) = Yhat;%wmm20200821
            end
            
            sse = nansum(cell2mat(seeI_corrected'));            % SSE = sum( (Y - Yhat) ^2)
            ssy = nansum(cell2mat(ssyI'));            % SSY = sum( (Y - mean(Y) ^2)    
            rsquared{peak}(noiseIdx, learner) = 1 - (sse ./ ssy);    % 1 - (SSE / SSY)
                        
            rmse{peak}(noiseIdx, learner) = sqrt(sse ./ numel(cell2mat(seeI_corrected')));

            errTotal = cell2mat(errI');                        
            biasE = nanmean(errTotal);
            stdE{peak}(noiseIdx, learner) = (nanmean(errTotal.^2) - biasE.^2) / sqrt(numel(errTotal));
            
            meanAbsErr{peak}(noiseIdx, learner) = nanmean(abs(cell2mat(errI'))) .* (norm.normFactY.maxValueY(peak)-norm.normFactY.minValueY(peak));  
            nbSample = numel(errTotal);
            ssSD = cell2mat(errI') .* (norm.normFactY.maxValueY(peak)-norm.normFactY.minValueY(peak));  
            SD{peak}(noiseIdx, learner) = sqrt(sum((ssSD - mean(ssSD)).^2) / nbSample);        
             
            meanValue(peak) = nanmean((dataLearn.Y(:,peak) .* norm.normFactY.maxValueY(peak)) + norm.normFactY.minValueY(peak));
        end
    end
end

rmse{1} = rmse{1} ./ meanValue(1);
rmse{2} = rmse{2} ./ meanValue(2);
rmse{3} = rmse{3} ./ meanValue(3);

avgRMSE = (rmse{1} + rmse{2} + rmse{3}) ./3;

%RMSE has the same unit than the predicted values, so, it has to be understood that we have to take a look at the importance of the RMSE in comparaison with the predicted values. 
% How we could know if it is good or not? we have to compute the Scatter Index, which is simply the RMSE divided by the average value of the observed value. 
% SI= (RMSE/average observed value)*100%. 
% it will be more easy to know if it is a good model or not. If SI < 10% is a good model, SI<5% is a very good model. For Ashrae standard, a model of prediction has to have an R2 higher than 0.75 and a SI below 30% if we consider annual data and 10% if we consider hourly or monthly data.


save('./step1Table1_latest_mocaip.mat');

% load('./step1Table1.mat', 'meanAbsErr', 'noiseRate', 'norm');
% 
% figure(1);
% cr = parula(10);
% cr = flipud(cr);
% for peak=1:3
%     subplot(1, 3, peak);
%     b = bar(categorical(100 .* noiseRate),  cell2mat(meanAbsErr(peak)) * (norm.normFactY.maxValueY(peak)-norm.normFactY.minValueY(peak)));    
%     title(sprintf('Peak %d', peak));
%     ylabel('MAE (ms)');
%     xlabel('Noise (%)');
%     set(gcf, 'color', 'w');
%     set(gca, 'color', 'w');
%     axis square;
%     
%     for k=1:5
%         b(k).FaceColor = cr((k*2),:);
%     end
%     if(peak ==3)
%         figure(2);
% %        subplot(1,4,4);
%         axis off;
%         hl = legend(b, 'Ridge Regression', 'Kernel Ridge Regression', 'Neural Network', 'Random Forest', 'SVM');
%         title(hl,  'Algorithm');        
% %        newPosition = [0.76 0.425 0.2 0.2];
% %        set(hl,'Position', newPosition,'Units', 'normalized');
%     end
% end
% 
% 
% 
% figure(2);
% entries = categorical({'Ridge', 'Kernel Ridge', 'Neural Net', 'Random Forest', 'SVM'}, {'Ridge', 'Kernel Ridge', 'Neural Net', 'Random Forest', 'SVM'});
% for peak=1:3
%     subplot(3, 1, peak);
%     title(sprintf('P%d', peak));
%     b = bar(entries, cell2mat(meanAbsErr(peak))' * (norm.normFactY.maxValueY(peak)-norm.normFactY.minValueY(peak)));
%     lgb = legend('0', '5%', '10%', '15%', 'Location', 'eastoutside');
%     title(lgb, 'Noise');
%     ylabel('Mean Absolute Error (ms)');
%     xlabel('Machine learning model');
%     
%     for k=1:4
%         b(k).FaceColor = cr((k*2),:);
%     end
% end
% g=1;
