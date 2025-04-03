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

% generate waveforms
pulses = zeros(nbWaveforms, 400);
sigma = 25;
x = 1:400;
peak = zeros(3,nbWaveforms);
for i=1:nbWaveforms
    pd1 = makedist('Normal','mu',sinLatency(1,i),'sigma',sigma);
    pd2 = makedist('Normal','mu',sinLatency(2,i),'sigma',sigma);
    pd3 = makedist('Normal','mu',sinLatency(3,i),'sigma',sigma);
    y(1,:) = pdf(pd1,x) .* sineICP(1,i);
    y(2,:) = pdf(pd2,x) .* sineICP(2,i);
    y(3,:) = pdf(pd3,x) .* sineICP(3,i);
    pulses(i,:) = sum(y,1);
    
    [Dx, Dxx] = derivative2(pulses(i,:));
    [peak_Xvalue,peak_Yvalue] = FindPeakEnhance(pulses(i,:),sinLatency(:,i),Dx, Dxx);
        
    l1(i) = peak_Xvalue(1);
    l2(i) = peak_Xvalue(2);
    l3(i) = peak_Xvalue(3);
    vv{i} = pulses(i,:).*9;     
end
save('ArtificialDataNoNnoise400','vv','l1','l2','l3');

% add noise
noiseRate = [0 0.05 0.1 0.15];
for noiseIdx = 1:numel(noiseRate)
    noiseSignal = (rand(size(pulses))-0.5) .* (noiseRate(noiseIdx) .* max(pulses(:)));
    pulsesWithNoise{noiseIdx} = pulses + noiseSignal;
end

figure;
plot3(repmat(1,1,400), 1:400, pulsesWithNoise{1}(1,:), '-'); hold on;
plot3(repmat(2,1,400), 1:400, pulsesWithNoise{2}(1,:), '-'); 
plot3(repmat(3,1,400), 1:400, pulsesWithNoise{3}(1,:), '-');
plot3(repmat(4,1,400), 1:400, pulsesWithNoise{4}(1,:), '-'); 

plot3([1 4], [l1(1) l1(1)], [pulsesWithNoise{1}(1,l1(1)) pulsesWithNoise{1}(1,l1(1))], 'go--');
plot3([1 4], [l2(1) l2(1)], [pulsesWithNoise{1}(1,l2(1)) pulsesWithNoise{1}(1,l2(1))], 'go--');
plot3([1 4], [l3(1) l3(1)], [pulsesWithNoise{1}(1,l3(1)) pulsesWithNoise{1}(1,l3(1))], 'go--');

title('Noise simulation');
zlabel('ICP');
ylabel('Time');
xlabel('Noise level');
print('./artificialData1.png', '-r300', '-dpng');
close;

