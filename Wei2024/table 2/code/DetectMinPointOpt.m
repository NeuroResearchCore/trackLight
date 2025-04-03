function pos = DetectMinPointOpt(dv, dummy1)
%
% Fast detection of the shoulder
%           
%===================================================================
%  Version 1.1 -- Sept 2009
%  Authors: Fabien Scalzo, Xiao Hu 
%

[maxv, maxpos] = max(dv);
[t pos] = min(dv(1:maxpos));
