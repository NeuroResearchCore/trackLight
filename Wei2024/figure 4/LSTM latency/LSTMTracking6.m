%function yhat = LSTMforICP(X, YY, idxTrain, idxTest, options)
%Input: Latencys and Ground truths for training , sequence of Latencys
%prediction by basic algorithms for testing ,200data to train,test on all
%data
%Output: prediction of Latencys testing sequence
%datastyle: 1*1,one by one OR time,input 5 datas to predict 1 data
%series,A:1:end-1,2:numTimeStepsTest,Ypred2(i-1,:) is the input;
%B:1:length,1:numTimeStepsTest,XTest(i,:) is the input
function yhat = LSTMTracking6(Yhat, YY, idxTrain,  idxTest,stepSize)
%%  data preparation for LSTM: do not need to input pulses, only need X value of peaks to predict,choose 3/6 as training data
%LSTM is used to predict one value£¬so only add noise on Xvalue 
%YY=dataLearn.Y(:,1);
%idxTest=idxTrain ;
numTimeStepsTrain = length(idxTrain);
numTimeStepsTest = length(idxTest);

%trained by data without noise,tested by data with noise

dataTrain = YY(idxTrain);
dataTest = Yhat;
% mu0 = mean(YY);
% sig0 = std(YY);
mu = mean(dataTrain);
sig = std(dataTrain);
dataTrainStandardized = (dataTrain - mu) ./ sig; %standardize is helpful for Ypred1
%dataTrainStandardized = dataTrain;
%YTrain same as Xtrain 
% XTrain = dataTrainStandardized(1:end-1);
% YTrain = dataTrainStandardized(2:end);
% stepSize = 6;

for i = 1:(length(dataTrainStandardized)-stepSize)
   
     XTrain(i,:) = dataTrainStandardized(i:(i+stepSize-1));    
    %     XTrain(i,:,:) = dataTrainStandardized(i:(i+stepSize-1));    
end
YTrain = dataTrainStandardized((stepSize+1):end);
% XTrain = (1:1:length(dataTrainStandardized))';
% YTrain = dataTrainStandardized;

% XTrain = dataTrainStandardized(1:end-1);
% YTrain = dataTrainStandardized(2:end);

%dataTestStandardized_withNoise = dataTest_withNoise;
% mu1 = mean(dataTest);
% sig1 = std(dataTest);
mu1 = mean(YY(idxTest));% if there is Nans in Xtest£¬
sig1 = std(YY(idxTest));
dataTestStandardized = (dataTest - mu1) ./ sig1;% no use
%YTrain same as Xtrain 
XTest = dataTestStandardized(1:end);%[dataTrainStandardized(end); %(1:1:length(dataTestStandardized))';
YTest = YY(idxTest);


%% LSTM train
numFeatures = stepSize;
numResponses = 1;
numHiddenUnits = 200;

layers = [ ...
    sequenceInputLayer(numFeatures)
    lstmLayer(numHiddenUnits)
    fullyConnectedLayer(numResponses)
    regressionLayer];

options = trainingOptions('adam', ...
    'MaxEpochs',200, ...
    'MiniBatchSize',20, ...
    'GradientThreshold',0.6, ...    
    'InitialLearnRate',0.005, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',125, ...
    'LearnRateDropFactor',0.75, ... 
    'Verbose',0);
 net = trainNetwork(XTrain',YTrain',layers,options);

%PeakPredicted_LSTM = 
%%  test

% net1 = predictAndUpdateState(net,XTrain');
% [net1,YPred1] = predictAndUpdateState(net1,YTrain(end));
% 
% numTimeStepsTest = numel(XTest);
% for i = 2:numTimeStepsTest  %%%%%%%%%%
%     [net1,YPred1(i,:)] = predictAndUpdateState(net1,YPred1(i-1,:),'ExecutionEnvironment','cpu');
% end
% 
% YPred1 = sig1.*YPred1+mu1;
% 
% rmse1 = sqrt(mean((YPred1-YTest).^2))
% stdE1 = (mean((YPred1-YTest).^2) - (mean(YPred1-YTest)).^2) / sqrt(numel(YPred1))
%% 
% figure
% plot(idxTrain,dataTrain)
% hold on
% plot(idxTest,YPred1,'.-')
% hold off
% xlabel('Month')
% ylabel('Cases')
% title('Forecast')
% legend(['Observed', 'Forecast'])
% 
% figure
% subplot(2,1,1)
% plot(YTest)
% hold on
% plot(YPred1,'.-')
% hold off
% legend('Observed', 'Forecast')
% ylabel('Cases')
% title('Forecast')
% 
% subplot(2,1,2)
% stem(YPred1 - YTest)
% xlabel('Month')
% ylabel('Error')
% str = ['RMSE= ',num2str(rmse)];
% title(str)
%% Update Network State with Observed Values
net2 = resetState(net);
% net2 = predictAndUpdateState(net2,XTrain');
net2 = predictAndUpdateState(net,XTrain');
% [net2,YPred2(1)] = predictAndUpdateState(net2,YTrain(end-4:end));
% [net2,YPred2(2)] = predictAndUpdateState(net2,[YTrain(end-3:end);YPred2(1)]);
% [net2,YPred2(3)] = predictAndUpdateState(net2,[YTrain(end-2:end);YPred2(1);YPred2(2)]);
% [net2,YPred2(4)] = predictAndUpdateState(net2,[YTrain(end-1:end);YPred2(1);YPred2(2);YPred2(3)]);
% [net2,YPred2(5)] = predictAndUpdateState(net2,[YTrain(end);YPred2(1);YPred2(2);YPred2(3);YPred2(4)]);
  YPred2 = [];
YPred2(1:stepSize)=dataTestStandardized(1:stepSize);
numTimeStepsTest = numel(XTest);
for i = (1+stepSize):(numTimeStepsTest) %%%%%%%%%%1:numTimeStepsTest
    Ypredd = YPred2((i-1-stepSize+1):(i-1));
     [net2,YPred2(i)] = predictAndUpdateState(net2,Ypredd','ExecutionEnvironment','cpu');%XTest(i,:)%YPred2(i-1,:)
end

YPred2 = sig*YPred2 + mu;
 yhat = YPred2';
% rmse0 = sqrt(mean((dataTest-YTest ).^2))
% stdE0 = (mean((dataTest-YTest).^2) - (mean(dataTest-YTest)).^2) / sqrt(numel(dataTest))
% rmse2 = sqrt(mean((YPred2-YTest).^2))
% stdE2 = (mean((YPred2-YTest).^2) - (mean(YPred2-YTest)).^2) / sqrt(numel(YPred2))

% figure
% subplot(2,1,1)
% plot(YTest)
% hold on
% plot(dataTest,'-o')
% plot(YPred2,'.-')
% hold off
% % legend(['Observed', 'Predicted'])
% % ylabel('Cases')
% % title('Forecast with Updates')
% % 
% subplot(2,1,2)
% % stem(YPred1 - YTest)
% % hold on
% stem(YPred2 - YTest)
% %  hold off
% xlabel('Month')
% ylabel('Error')
% str = ['RMSE= ',num2str(rmse2)];
% title(str)