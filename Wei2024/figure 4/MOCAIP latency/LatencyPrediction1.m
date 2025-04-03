%overlapping, 150*1/20 to train, 150*1/20 to test
function LatencyPrediction1()
load('./ksr_latency_beatbybeat.mat','gt1','gt2','gt3','l1','l2','l3');
latencys = [l1' l2' l3'];
Gt = [gt1' gt2' gt3'];
for i = 1:length(gt1)-15
    latencyS(i,:,:) = latencys(i:i+15-1,:);
    GtS(i,:,:) = Gt(i:i+15-1,:);
end
% idxTest = round(2/3*length(gt1)):1:length(gt1);
% idxTrain = 1:1:round(2/3*length(gt1))-1;
load('E:\code - Copy\learnPeakDetector\icpRegModel2017.mat','options');
setForTrain = randperm(size(GtS,1)-15,round(size(GtS,1)/2));
temp1 = ones(1,size(GtS,1));
temp1(setForTrain)=0;
setIdxTrain = logical(~temp1);
setIdxTest = logical(temp1);



% nFold = 2;
% CV = cvpartition(numel(gt1), 'KFold',nFold);
% for i=1:nFold
% 
%     cv.training{i} =CV.training(i);
%     cv.test{i} = CV.training(i);
%     
% end
% for j = 1:length(idxTest)

for fold=1:1%nFold  

    tracking2 = zeros(nnz(setIdxTest),3);
    tracking3 = zeros(nnz(setIdxTest),3);
    for peak=1:3

%        tracking2(:,peak) = KalmanTracking3(latencyS(idxTest,peak),GtS(:,peak),setIdxTrain, setIdxTest, options);
        
       tracking3 = LSTMTracking4(latencyS(:,:,peak),GtS(:,:,peak), setIdxTrain, setIdxTest);

    end

% err1{fold} = (Gt(idxTest,:) - latencys(idxTest,:));
% err2{fold} = (Gt(idxTest,:) - tracking2(:,1:3));
% err3{fold} = (Gt(idxTest,:) - tracking3(:,1:3)); 

end
% end
% err11 = cell2mat(err1');
% err21 = cell2mat(err2');
% err31 = cell2mat(err3');
% for peak=1:3 
%     
%    rmeanE1(:, peak) = sqrt(mean(err11(:, peak).^2));
%    biasE1(:, peak) = mean(err11(:, peak));
%    stdE1(:, peak) = (mean(err11(:, peak).^2) - biasE1(:, peak).^2) / sqrt(numel(err11(:, peak)));
%     
%    rmeanE2(:, peak) = sqrt(mean(err21(:, peak).^2));
%    biasE2(:, peak) = mean(err21(:, peak));
%    stdE2(:, peak) = (mean(err21(:, peak).^2) - biasE2(:, peak).^2) / sqrt(numel(err21(:, peak)));
%    %LSTM tracking
%    rmeanE3(:, peak) = sqrt(mean(err31(:, peak).^2));
%    biasE3(:, peak) = mean(err31(:, peak));
%    stdE3(:, peak) = (mean(err31(:, peak).^2) - biasE3(:, peak).^2) / sqrt(numel(err31(:, peak)));
% 
% end
           
g=1;