clear;

trainNum = 20; %200
allNum = 320;
sequence = [30 20 12];%lstm tracking stepsize

load('D:\Fabien\paperMiaomiaoLatest\allfigures\figures\common\simulatedData.mat','l1','l2','l3');
Gt = [l1' l2' l3'];
latencys = [l1' l2' l3'];

% Generate noise latency
dataNoise0 = zeros(size(latencys));
dataNoise1 = max(latencys(1:end)).*((rand(3,allNum))'-0.5) .* 0.05;
dataNoise2 = max(latencys(1:end)).*((rand(3,allNum))'-0.5) .* 0.10;
dataNoise3 = max(latencys(1:end)).*((rand(3,allNum))'-0.5) .* 0.15;

testLatencysN = latencys;
testLatencysN0 = testLatencysN + dataNoise0;
testLatencysN1 = testLatencysN + dataNoise1;
testLatencysN2 = testLatencysN + dataNoise2;
testLatencysN3 = testLatencysN + dataNoise3;

idxTrain = 1:trainNum;
idxTest = 1:allNum;
for peak=1:3
    
    testLatencysN(1:sequence(peak),:) = latencys(1:sequence(peak),:);
    
    tracking0(:,peak) = KalmanTracking3(testLatencysN0(idxTest,peak),Gt(:,peak), idxTrain, idxTest);
    tracking1(:,peak) = KalmanTracking3(testLatencysN1(idxTest,peak),Gt(:,peak), idxTrain, idxTest);
    tracking2(:,peak) = KalmanTracking3(testLatencysN2(idxTest,peak),Gt(:,peak), idxTrain, idxTest);
    tracking3(:,peak) = KalmanTracking3(testLatencysN3(idxTest,peak),Gt(:,peak), idxTrain, idxTest);
end

  
%---------------------
% quantitative results 
%---------------------

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

[norm, ~] = performLearnICPRegModel(options);

gt = testLatencysN;

for noiseLevel=0:3
    for peak=1:3
        gt_peak = gt(:,peak);
        gt_peak = (gt_peak - norm.normFactY.minValueY(peak)) ./ norm.normFactY.maxValueY(peak);
        op = sprintf('(tracking%d(:,peak) - norm.normFactY.minValueY(peak)) ./ norm.normFactY.maxValueY(peak)',noiseLevel);
        Yhat = eval(op);
        sseI = (gt_peak - Yhat ).^2;
        sse = nansum(sseI);            % SSE = sum( (Y - Yhat) ^2)
        rmseKalman(peak, noiseLevel+1) = sqrt(sse ./ numel(sseI));
    end
end

save('D:\Fabien\paperMiaomiaoLatest\allfigures\figures\common\rmse_Latency_Kalman2.mat', "rmseKalman");
