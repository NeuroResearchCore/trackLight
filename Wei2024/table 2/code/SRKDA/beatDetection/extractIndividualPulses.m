function [clusters, relativeTime] = extractIndividualPulses(icp, ecg, settings)
%
% Reference: "Bayesian tracking of intracranial pressure signal morphology" 
% Scalzo et al. Artif Intell Med. 2012 Feb;54(2):115-23.   
%
%==========================================================================
%   version 1.0 -- 10/2017 -- Fabien Scalzo, PhD 
%

nMinute = settings.clusterDuration / 60;
nsmp = nMinute * 60 * settings.ifs;
nseg = floor(min(length(icp),length(ecg)) ./ nsmp);

relativeTime = zeros(1,nseg);
clusters = cell(1,nseg);

%  i=1:nseg %wmm
for i=1:nseg
    idx1 = (i-1) * nsmp + 1;
    idx2 = i * nsmp;
    
    relativeTime(i) = nMinute * (i-1);
    [beats] = getBeatArray(ecg(idx1:idx2), icp(idx1:idx2), settings.ifs);
    clusters{i} = beats;
end