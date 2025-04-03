function [peak_Xvalue,peak_Yvalue] = FindPeakEnhance(pulses,sinLatency,Dx,Dxx) 
%find continuous pulses peaks x value and y value,the principle is: 
%1. get the three peaks' range,then we can confirm the lowest band
%of Peak1 and the highest Peak3
%2.for peak1, find the minima of 1st derivative from the positive side, the
%positive side range should be found first
%3.for peak3, find the minima of 1st derivative from the negitive side , the
%negitive side range should be found first
%4.for peak2, find the minima of 1st derivative from both side, the
%both side range should be found first

%peak1:75~100,peak2:126~163,peak3:180~217

%%Peak 1:   75~max(100,(Peak1+Peak2)/2)
Peak1 = sinLatency(1);
Peak2 = sinLatency(2);
Peak3 = sinLatency(3);
i1 = 75:1:floor((Peak1+Peak2)/2);
for i = 1:1:length(i1)
    if(Dx(i1(i))<=0)
        del1 = i1(i);
        i1 = i1(1):del1;
        break;
    end
end
[minDxValue,DxIdx] = min(abs(Dx(i1(1:end))));
if(numel(minDxValue)>1)  % 2 Dx =0
    
    peak_Xvalue(1) = i1(DxIdx(1));
    peak_Yvalue(1) = pulses(i1(DxIdx(1)));
else
  
        peak_Xvalue(1) = i1(DxIdx);
        peak_Yvalue(1) = pulses(i1(DxIdx));
    
end

%%Peak 2:   (Peak1+Peak2)/2)~(Peak2+Peak3)/2)
i2 = floor((Peak1+Peak2)/2):1:floor((Peak2+Peak3)/2);

for i = 1:1:length(i2)
    if(Dx(i2(i))<=0&&i2(i)>=Peak2)
        del2 = i2(i);
        i2 = i2(1):del2+1;
        break;
    end
end

for ii = 1:1:length(i2)
    iInverse = length(i2)-ii+1;
    if(Dx(i2(iInverse))>=0&&i2(iInverse)<=Peak2)
        del2 = i2(iInverse);
        i2 = del2:i2(end);
        break;
    end
end
[minDxValue,DxIdx] = min(abs(Dx(i2(1:end))));
if(numel(minDxValue)>1)
    
    [minVaule,PuIdx]=min(abs(Peak2-pulses(DxIdx)));
    peak_Xvalue(2) = i2(DxIdx(PuIdx));
    peak_Yvalue(2) = pulses(i2(DxIdx(PuIdx)));
else
    
    peak_Xvalue(2) = i2(DxIdx);
    peak_Yvalue(2) = pulses(i2(DxIdx));
end

%%Peak 3:   (Peak1+Peak2)/2~217

i3 = floor((Peak2+Peak3)/2):1:217;
for iii = 1:1:length(i3)
   iInverse = length(i3)-iii+1;
    if(Dx(i3(iInverse))>=0)
        del3 = i3(iInverse);
        i3 = del3:i3(end);
        break;
    end
end
[minDxValue,DxIdx] = min(abs(Dx(i3(1:end))));
if(numel(minDxValue)>1)  % 2 Dx =0
    
    peak_Xvalue(3) = i3(DxIdx(end));
    peak_Yvalue(3) = pulses(i3(DxIdx(end)));
else
    
    peak_Xvalue(3) = i3(DxIdx);
    peak_Yvalue(3) = pulses(i3(DxIdx));
end

