function [maxpos] = B8PeakDetect(peak,fICP, lECG, DetectParam, fs)
% Fiducial point aided ICP peak detection
% Find one ICP peak for those detectable dominant beats
% peak: fiducial points of dominant beats in lECG

if (nargin < 5)
    fs = 400;
end;

gap00 = DetectParam.gap00;
gap01 = DetectParam.gap01;
interval_desired0 = DetectParam.w00;
interval_desired1 = DetectParam.w01;

k1 = DetectParam.k1;
k2 = DetectParam.k2;
pp=[];
iPrev = -1;
gaprp = [];

maxpos = []; foot = [];MissedR =[];pp=[];rpeak=[];
%array for spurious R wave detection

for i=1:length(peak)-1
    j0 = 0;
    subidx = peak(i):peak(i+1)-1;
    subsig = fICP(subidx);
    c = 0;
    for j=2:length(subsig)-1
        if ( j >= gap00  &  j <= gap01 & subsig(j) > subsig(j-1) & subsig(j) > subsig(j+1) & subsig(j) > 0 )
        %if ( subsig(j) > subsig(j-1) & subsig(j) > subsig(j+1) & subsig(j) > 0 )
            maxpos = [maxpos; j+peak(i)-1];
            c = 1;
            break;
        end;
    end;
    
    if ( i > 1)
        rrhat  = peak(i)-peak(i-1); % a better way should be used
    else
        rrhat = median(diff(peak));
    end;
    
    if ( c == 0 )   %no candiate beat found, add a place holder
        maxpos = [maxpos; NaN]; 
        continue;
    end;
    
    pi = maxpos(end) - peak(i) + 1;
    pp = [pp;pi];
    if (length(pp) > 2)
        interval_cur = pi - gap00;
        gap00 = gap00 + k1 * ( interval_cur - interval_desired0) + k2 * ( pp(end) - pp(end-1));
        interval_cur = gap01 - pi;
        gap01 = gap01 + k1 * (interval_desired1 - interval_cur) + k2 * ( pp(end) - pp(end-1));
    end;
end;




