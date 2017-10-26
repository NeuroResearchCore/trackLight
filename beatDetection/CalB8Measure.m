function [beats] = CalB8Measure(ICP, R, peak, foot)
%   Calculate beat-aided beat-to-beat mean measures
%

beats = cell(length(R)-1,1);
for i=1:length(R)-1
    beats{i} = [];
    if (isnan(peak(i)) || isnan(foot(i)) || isnan(R(i)) || isnan(R(i+1)))
        continue;
    end
    subidx = R(i):R(i+1)-1;
    beats{i} = ICP(subidx);
end
