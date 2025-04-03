%200data to train, predict all data start from 0,
%5data to predct one,sequence = 5
clear;
% cd C:\Users\fabien\Downloads\BayesiantoFabien\BayesiantoFabien;

trainNum = 200;
allNum = 320;
sequence = [30 20 12];%lstm tracking stepsize
%load('E:\code - Copy\Code table 2\table 2\simulatedData.mat','l1','l2','l3');
%load('.\simulatedData.mat','l1','l2','l3');
load('D:\Fabien\paperMiaomiaoLatest\allfigures\figures\common\simulatedData.mat','l1','l2','l3');

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


figure;
hold on;
plot(testLatencysN, 'Color', [0.25 0.25 0.25], 'LineWidth', .5);

x = 1:1:size(filteredN,1);
y = filteredN(:,1)';
z = zeros(size(x));
col = x;  % This is the color, vary with x in this case.
surface([x;x],[y;y],[z;z],[col;col],...
        'facecol','no',...
        'edgecol','interp',...
        'linew',1.5, ...
        'FaceAlpha',0.5);

y = filteredN(:,2)';
surface([x;x],[y;y],[z;z],[col;col],...
        'facecol','no',...
        'edgecol','interp',...
        'linew',1.5, ...
        'FaceAlpha',0.5);

y = filteredN(:,3)';
surface([x;x],[y;y],[z;z],[col;col],...
        'facecol','no',...
        'edgecol','interp',...
        'linew',1.5, ...
        'FaceAlpha',0.5);

hold on;

xlabel('Index of Artificial Pulse', 'FontSize', 14);
ylabel('Peak Latency (ms)', 'FontSize', 14);
title('MOCAIP');
set(gcf, 'color', 'w');
box on;

pleg = [0.54 0.790476190476191 0.35 0.110809523809527];
txpos = 0.15;
pt1 = [pleg(1)+pleg(3)*txpos pleg(2)-pleg(4)*0.005 0.1 0.1];
pt2 = [0.545+(0.23-0.154) pleg(2)-pleg(4)*0.4 0.1 0.1];

a1 = annotation('rectangle',pleg,'facecolor','w');
t1 = annotation('textbox',[0.625 0.835160239266044 0.323214276613934 0.0630952369244326],'string','Latency with 5% noise','edgecolor','none','fitboxtotext','on');
annotation('line',[0.555 0.595],...
    [0.864285714285714 0.864285714285716],'Color', [0.25 0.25 0.25], 'LineWidth', .5);

cl = parula(6);
t2 = annotation('textbox',pt2,'string','MOCAIP estimate','edgecolor','none','fitboxtotext','on');
bh = 0.025;
bw = 0.008;
a11 = annotation('rectangle',[0.55 0.8 bw bh],'facecolor',cl(1,:),'edgecolor','none');
a12 = annotation('rectangle',[0.55+bw   0.8 bw bh],'facecolor',cl(2,:),'edgecolor','none');
a13 = annotation('rectangle',[0.55+2*bw 0.8 bw bh],'facecolor',cl(3,:),'edgecolor','none');
a14 = annotation('rectangle',[0.55+3*bw 0.8 bw bh],'facecolor',cl(4,:),'edgecolor','none');
a15 = annotation('rectangle',[0.55+4*bw 0.8 bw bh],'facecolor',cl(5,:),'edgecolor','none');
a16 = annotation('rectangle',[0.55+5*bw 0.8 bw bh],'facecolor',cl(6,:),'edgecolor','none');

h = gcf;
set(h,'Units','Inches');
 pos = get(h,'Position');
 set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
 print(h, './MOCAIPLatency','-dpng','-r300');
 print(h, './MOCAIPLatency','-deps2c','-r300')
 close;
