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
load('E:\code - Copy\learnPeakDetector\ICPdatabase.mat', 'l1', 'l2', 'l3', 'vv');

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
    if(i == 110)
        g =1;
    end
    pd1 = makedist('Normal','mu',sinLatency(1,i),'sigma',sigma);
    pd2 = makedist('Normal','mu',sinLatency(2,i),'sigma',sigma);
    pd3 = makedist('Normal','mu',sinLatency(3,i),'sigma',sigma);
    y(1,:) = pdf(pd1,x) .* sineICP(1,i);
    y(2,:) = pdf(pd2,x) .* sineICP(2,i);
    y(3,:) = pdf(pd3,x) .* sineICP(3,i);
    pulses(i,:) = sum(y,1);
    
    [Dx, Dxx] = derivative2(pulses(i,:));
    [peak_Xvalue,peak_Yvalue] = FindPeakEnhance(pulses(i,:),sinLatency(:,i),Dx, Dxx);
        
    if(display)
        plot(pulses(i,:)); hold on;
        plot(peak_Xvalue(1), peak_Yvalue(1), 'ro');
        plot(peak_Xvalue(2), peak_Yvalue(2), 'ro');
        plot(peak_Xvalue(3), peak_Yvalue(3), 'ro');
         
        title(num2str(i));
        pause(1);
        clf;
    end
    b = 1;
    if(i == 9 ||i == 25||i == 1||i == 32)
        plot(pulses(i,:)); hold on;
        plot(peak_Xvalue(1), peak_Yvalue(1), 'ro');
        plot(peak_Xvalue(2), peak_Yvalue(2), 'ro');
        plot(peak_Xvalue(3), peak_Yvalue(3), 'ro');
        b = b+1;
    end
    l11(i,1) = peak_Xvalue(1);
    l22(i,1) = peak_Xvalue(2);
    l33(i,1) = peak_Xvalue(3);
    vv1{i} = pulses(i,:).*9;     
    patient1 = i;
end
save('ArtificialDataNoNnoise400','vv1','l11','l22','l33','patient');

% add noise
noiseRate = [0 0.05 0.1 0.15];
for noiseIdx = 1:numel(noiseRate)
    noiseSignal = (rand(size(pulses))-0.5) .* (noiseRate(noiseIdx) .* max(pulses(:)));
    pulsesWithNoise{noiseIdx} = pulses + noiseSignal;
end

% plot(pulsesWithNoise{1}(1,:)); hold on;
% plot(pulsesWithNoise{2}(1,:)); 
% plot(pulsesWithNoise{3}(1,:)); 
% plot(pulsesWithNoise{4}(1,:)); 

