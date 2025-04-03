function [peak] = correctQRS(tpeak, tsig, fs)
if nargin < 3
    fs = 400;
end;

peak = [];
for i=1:length(tpeak)
    t0 = tpeak(i)-round(80*fs/1000);
    if (t0 <= 0) t0 = 1;end;
    if i > 1
        [t, idx]= max(tsig(t0: min(end,tpeak(i)+round(80*fs/1000)) ));
        tpeakk = t0 + idx-1;
        if i > 2
            if(tpeakk == peak(end))
                continue;
            end;
        end;
    else
        [t, idx]= max( tsig(t0: min(end,tpeak(i)+round(80*fs/1000))));
        tpeakk = t0 + idx-1;
    end;
    peak =[peak;tpeakk];
end;
