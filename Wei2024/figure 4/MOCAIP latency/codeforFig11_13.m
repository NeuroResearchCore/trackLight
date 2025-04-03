%200data to train, predict all data start from 0,
%5data to predct one,sequence = 5
clear;
% cd C:\Users\fabien\Downloads\BayesiantoFabien\BayesiantoFabien;

trainNum = 200;
allNum = 320;
sequence = [30 20 12];%lstm tracking stepsize
%load('E:\code - Copy\Code table 2\table 2\simulatedData.mat','l1','l2','l3');
load('.\simulatedData.mat','l1','l2','l3');
% load('E:\code - Copy\learnPeakDetector\icpRegModel2017.mat','options');
Gt = [l1' l2' l3'];
latencys = [l1' l2' l3'];
segments = 20;      %divide all data into segments to keep the missing part distributr evenly
segmentLength = round(size(Gt,1)/segments);
misNum = 1;         % number of missing part in every segment
misNumMax = 4;      % maxi number of missing datas in every missing part
misNumMin = 2;      % mini number of missing datas in every missing part
mislength = misNumMin+randi(misNumMax-misNumMin,misNum,segments);  %5~15
% misFnum = trainNum+randi(allNum-trainNum-misNumMax,1,misNum);      %150~301

%Generate noise latency
dataNoise = max(latencys(1:end)).*((rand(3,allNum))'-0.5).*0.05;
testLatencysN= latencys;
testLatencysN(((1):end),:) = testLatencysN(((1):end),:)+dataNoise;

%Generate missing latency
testLatencys = latencys; 
for i =1:segments
    %the first number index of every missing part
    misFnum(1) = (i-1)*segmentLength+randi(round(segmentLength/misNum)-misNumMax,1,1); 
    %the last number index of every missing part
    misLnum(1) = misFnum(1)+mislength(1,i)-1;                  
    testLatencys(misFnum(1):misLnum(1),:)=latencys(misFnum(1):misLnum(1),:)./0;
for j = 2:misNum
    misFnum(j) = misLnum(j-1)+randi(round(segmentLength/misNum)-misNumMax,1,1);
    misLnum(j) = misFnum(j)+mislength(j,i)-1;
    testLatencys(misFnum(j):misLnum(j),:)=latencys(misFnum(j):misLnum(j),:)./0;
    
end
end
testLatencysM = testLatencys;
% testLatencysM(1:sequence(:),:) = latencys(1:sequence(:),:);

% idxTrain = 1:1:trainNum;
% % idxTest = trainNum+1:1:allNum;
% idxTest = 1:1:allNum;
% for peak=1:3
%     
%     testLatencysN(1:sequence(peak),:) = latencys(1:sequence(peak),:);
%     testLatencysM(1:sequence(peak),:) = latencys(1:sequence(peak),:);
% %     tracking2(:,peak) = KalmanTracking3(testLatencysN(idxTest,peak),Gt(:,peak),idxTrain, idxTest);
% %     tracking2(:,peak) = LinearKalmanTracking5(testLatencysN(idxTest,peak),Gt(:,peak),idxTrain, idxTest);
% %     tracking3(:,peak) = LSTMTracking6(testLatencysN(idxTest,peak),Gt(:,peak), idxTrain, idxTest, sequence(peak));
% %    tracking4(:,peak) = LSTMTracking6(testLatencysM(idxTest,peak),Gt(:,peak), idxTrain, idxTest, sequence(peak));
% 
% end
%% clustering
winSize = 6;
for i=1:3
    for cursor=1:winSize:size(testLatencysN,1)-winSize
        svalues = testLatencysN(cursor:cursor+winSize,i);
        C = clusterdata(svalues, 3);
        [cnt_unique, unique_a] = hist(C, unique(C));
        [v, idx] = max(cnt_unique);
        
        filteredN(cursor:cursor+winSize-1,i) =  repmat(mean(svalues(C==idx)), 1, winSize);
    end
    
     for cursor=1:winSize:size(testLatencysM,1)-winSize
        svalues = testLatencysM(cursor:cursor+winSize,i);
        if(nnz(isinf(svalues))>0)
            svalues(isinf(svalues)) = [];
        end
        C = clusterdata(svalues, 3);
        [cnt_unique, unique_a] = hist(C, unique(C));
        [v, idx] = max(cnt_unique);
        
        filteredM(cursor:cursor+winSize-1,i) =  repmat(mean(svalues(C==idx)), 1, winSize);
     end    
end
% figure(1);
% plot(testLatencysN,'b','DisplayName','Latency with 5% noise' );
% hold on;%'Color', [0.5 0.5 0.5]
% plot(filteredN,'r','DisplayName','MOCAIP prediction');
% print('./mocaipNoise','-dpng','-r200');
% xlabel('Index')
% ylabel('Latency(ms)')
% title('MOCAIP tracking')
% legend('Peak latency with noise','','','MOCAIP prediction')

% figure(2);
% plot(testLatencysM, 'b','DisplayName','Latency with missing data'); 
% hold on;
% plot(filteredM,'r','DisplayName','LSTM prediction');
% print('./mocaipMissing3.png','-dpng','-r200');
% save('mocaip', 'filteredN', 'testLatencysN', 'filteredM', 'testLatencysM');
% xlabel('Index')
% ylabel('Latency(ms)')
% title('MOCAIP tracking')
% legend('Peak latency with missing data','','','MOCAIP prediction')

Tracking = giveNullValue(testLatencysM(1:length(filteredM),:),filteredM);

tmp = testLatencysM(1:length(filteredM),:);
tmp(isinf(tmp(:,1)),:) = filteredM(isinf(tmp(:,1)),:);

figure;
%plot(testLatencysM,'b','DisplayName','Latency with missing data','Linewidth',1);
%hold on;
plot(tmp,'-r','DisplayName','MOCAIP prediction','Linewidth',1);
hold on;
xlabel('Index')
ylabel('Latency (ms)')
title('MOCAIP tracking')
%legend('Peak latency with missing data','','','MOCAIP prediction')

plot(Gt, 'Color', [0.15 0.15 0.15], 'LineWidth', 1, 'LineStyle','-'); 
hold on;

g=1;

% 
% 
% 
% % set options for ML methods
% optionsKSR.ReguType = 'Ridge';
% optionsKSR.ReguAlpha = .01;
% optionsKSR.t = 1;
% 
% optionsSR.ReguType = 'Ridge';
% optionsSR.ReguAlpha = .01;
% 
% optionsSVM = 'empty';
% 
% options.DecisionForest.paroptions = statset('UseParallel',true);
% options.DecisionForest.nbTrees = 100;
% 
% options.neuralNet.nbLayers = 7;
% 
% optionsList = {optionsSR, optionsKSR, options.neuralNet, options.DecisionForest, optionsSVM};
% 
% options.normalizeHeartRate = 1;
% options.normalizeAUC = 1;
% options.removeOutliers = 1;
% options.pulseLength = 400;
% 
% options.useDerivative = 0;
% options.sigmaDerivative = 5;
% options.normalizeAcrossPatient = 0;
% 
% options.excludePatients = 0;
% options.patientsToExclude = [];
% 
% options.trainModel = 0;
% options.saveModel = 0;
% %options.outFileName = 'E:\code - Copy\learnPeakDetector\icpRegModel2020.mat';%wmm20200506
% 
% options.noiseRate = 0;
% 
% load('.\simulatedData.mat', 'vv', 'l1', 'l2', 'l3');
% for i = 1:size(vv,2)
%     X(i,:) = vv{i};
% end
% 
% fs = 400;
% Y = Gt(idxTest,:);
% figure;
% title('Bayesian tracking');
% 
% listSigma = [1 1.2 1.7 2 2.5 3 3.5 4];
% cl = jet(numel(listSigma));
% options =  getDefaultTrackingParam2();
% 
% for idx=1:numel(listSigma)
%     options.observationSigmaL = listSigma(idx);    
%     options.observationSigmaE = options.observationSigmaL ./ 3;
% 
%     tracking = bayesianTracking(X, testLatencysN, Gt(idxTest,:), fs, @DetectOnset, options);
% 
%     plot(tracking(:,1),'-.', 'Color', cl(idx,:)); hold on;
%     err = Y(:,1)-tracking(:,1);
%     rmeanE2(idx) = sqrt(mean(err(:, 1).^2));
% end
% lg = legend( num2str(listSigma'));
% plot(Y(:,1),'--', 'Color', 'k');
% htitle = get(lg,'Title');
% set(htitle,'String','Sigma');
% 
% print('./bayesianTracking','-dpng','-r200');
% 
%   
% %%
% 
% Tracking = giveNullValue(testLatencysM,tracking3);
% 
% figure;
% plot(testLatencysM,'DisplayName','Latency with missing data');
% hold on;
% plot(Tracking,'.','DisplayName','LSTM prediction');
% 
% figure;
% plot(testLatencysN,'DisplayName','Latency with 10% noise');
% hold on;
% plot(tracking1,'DisplayName','LSTM prediction');
% 
% figure;
% plot(latencys,'DisplayName','Original latency');
% hold on;
% plot(tracking1,'DisplayName','LSTM prediction');
