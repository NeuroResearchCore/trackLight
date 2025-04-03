function foot = DetectOnset(subsig, fs)

sig_diff1 = diff1(subsig, 5);
[~, peak1] = max((sig_diff1));

ix=1;
c = 0;

while(1)
    xidx = max(1,peak1-ix):peak1+ix;
    
    if (xidx(end) > length(subsig)) 
        c = 1;
        break;
    end;
    asig = subsig(xidx);
    pp = polyfit(xidx(:), asig(:), 1); 
    subsighat = polyval(pp, xidx);
    if ( corr(asig(:), subsighat(:)) <0.999)
        c = 1;
        break;
    end;
    ix = ix+1;
end
if (c==1)
    pos = DetectMinPoint(subsig, fs);
    minSig = subsig(fix(pos));
    try
        foot = (minSig- pp(2))/pp(1);
        if (foot < 1)
            foot = NaN;
        end;
    catch
        foot = NaN;
    end
else
    if (subsig(1) == min(subsig))
        foot = 1;
    else
        foot = NaN;
    end
end

if(foot > length(subsig))
    foot = nan;
end
    