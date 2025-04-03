function onset = DetectPulseOnset(asig, fs, wMS)
%
%  Detect locations of onset for a pulsatile signal
%  <sig>:      Single-channel pulsatile signal
%  <fs>:        Sampling rate
%  <wMs>:    Window in milliseconds to search for onset after a
%                  threshold-crossing point is detected. This value will
%                  also create a lag between the detected onset and the
%                  actual onset. This lag is very desirable for using our
%                  subsequent algorithm of finding the onset. As it can be
%                  used a surrogate QRS R Peak position. Hence, we should
%                  use the maximal onset latency as a window. ICP: 120 ms.
%                  ABP: 220 ms; CBFV: 160 ms;
% Author:  Xiao Hu, Ph.D.
%
% Reference:  "An Open-source Algorithm to Detect Onset of Arterial Blood
% Pressure Pulses", W Zong, T Heldt, GB Moody, and RG Mark

% Some other constants 

% the percentage of the onset to onset interval that the blank window should be equal to 
BlankWindowRatio = 0.7;  

% the percentage of the maxmal value of the slope sum function to detect
% the onset
AmplitudeRatio = 0.1;

% the percentage of maximal amplitude for  threshould crossing
DetectionThreshold = 0.6;

%Filters the signal
sig = zpiir(asig, 3, 0.1, 20, 5 * 2 / fs);

%Number of samples in the window
wSmp = round(wMS * fs / 1000);

%Takes the difference between consecutive elements of the array
diffsig = diff(sig);
%Preallocation
z = NaN(numel(sig)-1 - wSmp, 1);
for i=wSmp+1: numel(sig)-1
    subsig = diffsig(i-wSmp:i);
    z(i-wSmp) = sum(subsig(subsig>0));
end;
zz = z;
diffz = diff1(z, 10);


aa(1) = subplot(211);
hold off;
plot(z);


nLearningWin = 5 * fs;
z0 = 3 * mean(z(1:nLearningWin)) * DetectionThreshold;

onset = [];
tPnt = [];
blankWin = 0.5 * fs;  %500 milliseconds
diffzThres = NaN;
robIt = 1; %hamilton comment may remove 
while(1)
    ix = min(find(z > z0)); 
    while (diffz(ix) < 0)
        e = diffz(ix:end) - diffzThres;        
        ix = ix + min(find(e>0));
    end;
    tPnt = [tPnt;ix];
    diffzThres = diffz(ix);
    if isempty(ix)
        break;
    end;
    srcWin = max(1,ix - wSmp):ix+wSmp;
    if srcWin(end) > numel(sig)
        break;
    end;
    if ( max(z(srcWin)) - min(z(srcWin)) > 0)        
        maxSSF = max(z(srcWin)) * AmplitudeRatio;
        srchWin = srcWin;
        for jj = 1:length(srcWin)
            if (z(srchWin(end-jj+1)) < maxSSF)
                break;
            end;
        end;        
        a = srcWin(end) - jj + 1;
        onset = [onset;a];
        z0 = 0.5 * z0 + 0.5 * max(z(srcWin)) * DetectionThreshold;
        z(1:min(end,a+ blankWin)) = NaN;
        if length(onset) > 1
            blankWin = round((onset(end) - onset(end-1)) * BlankWindowRatio);
        end;
    end;
%     plot(sig);
%     hold on
%     plot(onset, sig(onset), 'o');
%     pause;
    robIt = robIt+1 
end;

hold on
plot(onset, zz(onset), 'ro');
plot(tPnt, zz(tPnt), 'r+');
aa(2) = subplot(212);
hold off;
plot(sig);
hold on
plot(asig, 'k');
plot(onset, sig(onset), 'ro');
plot(onset, asig(onset), 'ko');
linkaxes(aa, 'x');