function [VV, peakLib, funcStr] = LoadPulseLib(libName, iRequiredFs, exclusivePatID) %#ok<INUSL>
% libName:  File name of the peak location and ICP pulse library
% VV:  ICP pulses saved in the library
% peakLib:  peak locations (all three) in sample number per the required
% sampling frequency
% Author: Xiao Hu, Ph.D.

% if not to exclude any data
if nargin < 3
    exclusivePatID = '-1';
end;

funcStr = NaN;
re = load(libName);
if (isfield(re, 'fnOnsetDetect'))
    funcStr = re.fnOnsetDetect;
end;
iOriginalFs = re.fs;
stdVV = re.vv;
patIDArray = re.patID;

iDBEntry = length(stdVV);

ix = 0;
ixArray = [];
len = ones(length(iDBEntry),1); % in # of samples at 400 Hz
for i=1:iDBEntry
    len(i) = length(stdVV{i}) * 1000 / 400;
    if (strcmp(patIDArray{i}, exclusivePatID) ~= 1)
        ix = ix + 1;
        ixArray = [ixArray;i];
        VV{ix} = resample(stdVV{i}, iRequiredFs, iOriginalFs);
    end;
end;

peakLib = ones(ix, 3);

peakLib(:,1) =  (re.l1(ixArray))';
peakLib(:,2) =  (re.l2(ixArray))';
peakLib(:,3) =  (re.l3(ixArray))';
%save the length of the pulse
peakLib(:,4) =  len(ixArray)';

%onset as detected by the minimum point
peakLib(:,5) =  (re.lt(ixArray))';
peakLib = peakLib * iRequiredFs / 1000;
