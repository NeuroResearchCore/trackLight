function [pnt, dist] = DetectSPntByIntersection(sig, deriv, ~)

if(mean(deriv) < 0)
    pnt = 1;    
else
    pnt = length(sig);
end
dist = sig(end) - sig(1);