function [peak, bShoulder, amp, curvs, siz] = Detect3P(pulseSig, SPntFuncHandle, fs)
% Detect the peaks and shoulder points on an ICP pulse
%
%
%
% Author: Xiao Hu, Ph.D.


if nargin < 3
    fs = 400;
end;

if nargin < 2
    fs = 400;
    SPntFuncHandle = @DetectSPntByIntersection;
end

r2 = 0.85;

minLen = fs * 25/1000;
sig_diff1 = diff1(pulseSig, 5);
sig_diff2 = diff1(sig_diff1, 5);
sig_diff22 = [sig_diff2 ;zeros(length(sig_diff1)-length(sig_diff2),1)];
curv = sig_diff22(:)./((1+sig_diff1(:).*sig_diff1(:)).^(1.5));

% all segments with a downward concave shape
idx = find( sig_diff2 < 0);

cutoffpnt = find(diff(idx)~=1);
cutoffpnt = [0; cutoffpnt; length(idx)];
peak = [];
curvs = [];
siz = [];
amp = [];

len = length(pulseSig)*1000/fs;
bShoulder = [];

%---
if(numel(idx) == 0)
  return;
end
%---

for i=1:length(cutoffpnt)-1
    sigidx = idx(cutoffpnt(i)+1):idx(cutoffpnt(i+1));
    subsig = pulseSig(sigidx);
    subsig1 = sig_diff1(sigidx);
    subcurv = curv(sigidx);

    % first shoulder has to be on rising edge
    if (all(subsig1 <= 0) & isempty(peak))
        ;
        %last should has to be on the decreasing edge
    elseif(all(subsig1 > 0) & i == (length(cutoffpnt)-1) )
        ;
        %% a peak point
    elseif ( any(subsig1 > 0) &  any(subsig1 < 0) & length(subsig) > minLen)
        [mins, minIdx]= max(subsig);
        %    if( (sigidx(1) + minIdx) *1000/fs > (len * 0.1) &  (sigidx(1) + minIdx) *1000/fs < (len * r2 ))
        if(1)
            peak = [peak;sigidx(1) + minIdx];
            siz = [siz;NaN];
            curvs = [curvs;curv(peak(end))];
            amp = [amp;2 * subsig(minIdx) - subsig(1) - subsig(end)];
            bShoulder = [bShoulder;-1];
        end;
    elseif (1)  % trying to find shoulder point that has the maximal distance to the line contecting
        [pnt, dist] = feval(SPntFuncHandle, subsig, subsig1, subcurv);
        peak = [peak;sigidx(1) + pnt - 1];
        bShoulder = [bShoulder;1];
        siz = [siz;dist];
        curvs = [curvs;curv(peak(end))];
        amp = [amp; abs(subsig(1) - subsig(end))];
    end;
end;
