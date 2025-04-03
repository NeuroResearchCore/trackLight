function [pnt, dist] = DetectSPntByIntersection(sig, deriv, curv)
%   One of methods for detecting shoulder point based on the intersection
%   point of a concave (convex) curve and a convex (concave) curve
%
%
% Author:  Xiao Hu, Ph.D. Dynamic Neuro Systems Lab
pnt = NaN;
dist = NaN;


if (length(sig) <= 0)
    return;
end;
if mean(deriv) < 0
    pnt = 1;    
else
    pnt = length(sig);
end
dist = sig(end) - sig(1);