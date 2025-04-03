function extremePos = FindLocalExtrem(asig, bMax, bFirst)
%
%
%   Find the first local extreme point maxium or minimum
%
%   bFirst = 1:  first extreme
%   bFirst = 2:  extreme in the middle

if nargin < 2
    bMax = 1;
end;

extremePos = NaN;
idx = 1;
if bMax == 1
    for i=2:numel(asig)-1
        if ( asig(i) > asig(i-1) &  asig(i) > asig(i+1))
            extremePos(idx) = i;
            idx = idx + 1;
            if (bFirst==1)
                break;
            end;
        end;
    end;
else
    for i=2:numel(asig)-1
        if (  asig(i) < asig(i-1) &  asig(i) < asig(i+1))
            extremePos = i;
            extremePos(idx) = i;
            idx = idx + 1;
            if(bFirst==1)
                break;
            end;
        end;
    end;
end;

if (bFirst ~=1)
    if any(~isnan(extremePos))
        [tt, tpos] = max(asig(extremePos)); %abs(extremePos - numel(asig)/2));
        extremePos = extremePos(tpos);
    end;
end;