clear;

display = 0;

nbPeriod = 10;
% generic sine dynamic
x = -pi:0.2:pi;
sinWave(1,:) = repmat(sin(x)+1, 1, nbPeriod);
x2 = -pi:0.18:pi;
tmp = repmat(sin(x2)+1, 1, nbPeriod);
sinWave(2,:) = tmp(1:size(sinWave,2));
x3 = -pi:0.16:pi;
tmp = repmat(sin(x3)+1, 1, nbPeriod);
sinWave(3,:) = tmp(1:size(sinWave,2));

nbWaveforms = size(sinWave,2);

scaling = linspace(.1,1,nbWaveforms);
sinWave = ((sinWave-1) .* scaling)+1;

% extract mean and standard deviation
% load('./ICPdatabase.mat');
load('E:\code - Copy\learnPeakDetector\ICPdatabase.mat');

meanLatency(1) = mean(l1);
meanLatency(2) = mean(l2);
meanLatency(3) = mean(l3);

sdLatency(1) = std(l1);
sdLatency(2) = std(l2);
sdLatency(3) = std(l3);

for i=1:numel(vv)
    e1(i) = vv{i}(round(l1(i)));
    e2(i) = vv{i}(round(l2(i)));
    e3(i) = vv{i}(round(l3(i)));
end
clear l1 l2 l3 vv;
meanICP(1) = mean(e1);
meanICP(2) = mean(e2);
meanICP(3) = mean(e3);

sdICP(1) = std(e1)/5;
sdICP(2) = std(e2)/5;
sdICP(3) = std(e3)/5;

% create peak locations
for peak=1:3
    sinLatency(peak,:) = (sdLatency(peak) * sinWave(1,:)) + meanLatency(peak); 
    sineICP(peak,:) = (sdICP(peak) * sinWave(peak,:)) + meanICP(peak); 
end

figure;
plot(sinLatency', '-'); hold on;
title('Simulated ICP waveform data - peak latency');
print('./artificialData2a.png', '-r300', '-dpng');
close;

figure;
plot(sineICP', '-'); hold on;
title('Simulated ICP waveform data - peak elevation');
print('./artificialData2b.png', '-r300', '-dpng');
close;