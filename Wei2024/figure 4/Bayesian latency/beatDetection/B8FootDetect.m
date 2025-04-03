function [foot] = B8FootDetect(R, peak, fICP, lECG, fs, opt)
%Fiducial point-aided foot detection for ICP pulse
%Return foot location between R and peak
if nargin < 5
    fs = 400;
end;
if nargin < 6
    opt = 1;
end;

for i=1:length(peak)
    if (isnan(peak(i)))
        foot(i) = NaN;
        continue;
    end;
    s0 = R(i);
    subsig = fICP(R(i):peak(i));

    if(opt == 1)
        foot(i) = DetectOnset(subsig, fs) + s0 - 1;
    else
        [subsig, foot(i)] = min(fICP(R(i):peak(i)));
        foot(i) = foot(i) + R(i);
    end
end;






