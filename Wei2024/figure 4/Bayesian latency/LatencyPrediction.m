%1/2 to train, 1/2 to test
function LatencyPrediction()
load('./ksr_latency_beatbybeat.mat','gt1','gt2','gt3','l1','l2','l3');
latencys = [l1' l2' l3'];
Gt = [gt1' gt2' gt3'];
% idxTest = round(2/3*length(gt1)):1:length(gt1);
% idxTrain = 1:1:round(2/3*length(gt1))-1;
load('E:\code - Copy\learnPeakDetector\icpRegModel2017.mat','options');
Gt2 = Gt;%2
Gt3 = Gt;%2
nFold = 2;
CV = cvpartition(numel(gt1), 'KFold',nFold);
for i=1:nFold

    cv.training{i} =CV.training(i);
    cv.test{i} = CV.training(i);
    
end
% for j = 1:length(idxTest)
for fold=1:nFold  
    idxTrain = cv.training{fold};
    idxTest = cv.test{fold};
    tracking2 = zeros(nnz(idxTest),3);
    tracking3 = zeros(nnz(idxTest),3);
    for peak=1:3

       tracking2(:,peak) = KalmanTracking3(latencys(idxTest,peak),Gt2(:,peak),idxTrain, idxTest, options);
       tracking3(:,peak) = LSTMTracking3(latencys(idxTest,peak),Gt3(:,peak), idxTrain, idxTest, options);
%        Gt2(idxTest(j),peak) = tracking2(j,peak);%2
%        Gt3(idxTest(j),peak) = tracking3(j,peak);%2
    end
%     idxTrain = [idxTrain idxTest(j)];%1
%     idxTest = idxTest(2:end);%2
err1{fold} = (Gt(idxTest,:) - latencys(idxTest,:));
err2{fold} = (Gt(idxTest,:) - tracking2(:,1:3));
err3{fold} = (Gt(idxTest,:) - tracking3(:,1:3)); 

end
% end
err11 = cell2mat(err1');
err21 = cell2mat(err2');
err31 = cell2mat(err3');
for peak=1:3 
    
   rmeanE1(:, peak) = sqrt(mean(err11(:, peak).^2));
   biasE1(:, peak) = mean(err11(:, peak));
   stdE1(:, peak) = (mean(err11(:, peak).^2) - biasE1(:, peak).^2) / sqrt(numel(err11(:, peak)));
    
   rmeanE2(:, peak) = sqrt(mean(err21(:, peak).^2));
   biasE2(:, peak) = mean(err21(:, peak));
   stdE2(:, peak) = (mean(err21(:, peak).^2) - biasE2(:, peak).^2) / sqrt(numel(err21(:, peak)));
   %LSTM tracking
   rmeanE3(:, peak) = sqrt(mean(err31(:, peak).^2));
   biasE3(:, peak) = mean(err31(:, peak));
   stdE3(:, peak) = (mean(err31(:, peak).^2) - biasE3(:, peak).^2) / sqrt(numel(err31(:, peak)));

end
           
g=1;