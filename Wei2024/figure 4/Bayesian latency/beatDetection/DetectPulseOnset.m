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

% the percentage of the maxmal value of the slope sum function to detect
% the onset
AmplitudeRatio = 0.01;


%low pass filter
sig = zpIIR(asig, 3, 0.1, 20, 5 * 2 / fs);
wSmp = round(wMS * fs / 1000);

BlankWindowRatio = 0.9;

%delta x
diffsig = diff(sig);
z = NaN(numel(sig)-1 - wSmp, 1);

%calculate slope sum function
for i=wSmp+1: numel(sig)-1
    subsig = diffsig(i-wSmp:i);
    z(i-wSmp) = sum(subsig(subsig>0));
end;

z0 =  mean(z);
onset = [1];
tPnt = [];
zThres = 0;
blankWin = round(400 * fs / 1000);
subIdx = onset(1):onset(1) + 4*blankWin;

MedianArrayWinSize = 5;

% this values controls the final acceptance
PrcofMaxAMP = 0.2;
SSFAmpArray = ones(MedianArrayWinSize, 1) * (max(z) - min(z)) * PrcofMaxAMP;

% the percentage of maximal amplitude for threshould crossing
DetectionThreshold = 0.2;
SSFCrossThresholdArray = ones(MedianArrayWinSize, 1) * z0 * DetectionThreshold;

idx = 1;
while(1)   
    ix = min(find(z(min(end,subIdx)) > z0));
    if isempty(ix)
        break;
    end;
    ix = subIdx(ix);    
    tPnt = [tPnt;ix];
    srcWin = max(1,ix - wSmp):ix+wSmp;
    
    %if the window has passed the length of the data, then exit
    if(srcWin(end) > length(z))
        break;
    end;
    
    % This section of code is to remove the initial zero-region in the SSF
    % function before looking for onset (if such region exists)
    zPnt = find(z(srcWin)==0);
    if(~isempty(zPnt))
        zPnt = srcWin(zPnt);
        if(  any(zPnt < ix))
            srcWin = zPnt(max(find(zPnt<ix))):ix+wSmp;
        end;
    end;
    
    %accept the window
    if ( max(z(srcWin)) - min(z(srcWin)) > zThres)
               
        %calculate the threshold for next cycle
        SSFAmp = (max(z(srcWin)) - min(z(srcWin))) * PrcofMaxAMP;
        SSFAmpArray(rem(idx, MedianArrayWinSize)+1) = SSFAmp;
        zThres =    median(SSFAmpArray);
        
        SSFCrossThresholdArray(rem(idx, MedianArrayWinSize)+1) = mean(z(srcWin))* DetectionThreshold;
        z0 =    median(SSFCrossThresholdArray);
        
        minSSF = min(z(srcWin)) +  SSFAmp*AmplitudeRatio;
        a = srcWin(1) + min(find(z(srcWin) >= minSSF));
        onset = [onset; a];
        
        %adaptively determine analysis window for next cycle.
        bw = blankWin;        
        subIdx = round(a + bw: a+3 * bw);
        idx = idx + 1;
    else
        % no beat detected 
        subIdx = round(subIdx + blankWin);
    end;
end;



