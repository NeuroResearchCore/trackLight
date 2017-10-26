 function [domPulses, domPulsesAUC, pulsesTime, mICP] = clusterPulses(aCluster, timing, AlgoParam)
%
% Extract a series of dominant pulses from the raw pulses
%
% INPUT:
%           <aCluster>      list of raw ICP pulses (grouped in 5min blocks)
%           <fs>            sampling rate
%           <AlgoParam>     options (see getDefaultTrackingParam())
%
% OUTPUT:
%           <domPulses>     list of dominant pulses
%
% Reference: "Bayesian tracking of intracranial pressure signal morphology" 
% Scalzo et al. Artif Intell Med. 2012 Feb;54(2):115-23.   
%
%==========================================================================
%   version 1.0 -- 10/2017 -- Fabien Scalzo, PhD 
%

domPulses = [];
domPulsesAUC = [];
pulsesTime = [];
mICP = [];

fs = AlgoParam.ifs;
nbclusters = numel(aCluster);

listLength = zeros(1,nbclusters);
for j=1:nbclusters
    listLength(j) = numel(aCluster{j});
end

sz = 125;

domPulses = nan(nbclusters, sz, 'single');
mICP = nan(1, nbclusters, 'double');

for j=1:nbclusters
    if(~isempty(aCluster{j}) && iscell(aCluster{j}))
        rawPulses = nan(listLength(j), sz, 'single');
        mICPRaw = nan(1, listLength(j), 'double');
        
        for k=1:listLength(j)
            if(numel((aCluster{j}{k}) > 30))
                mICPRaw(k) = nanmean(aCluster{j}{k});
                mx = min(sz,numel(aCluster{j}{k}));
                
                [vNorm, idxShift] = min(aCluster{j}{k}(5:20));
                
                tmp = nan(1,sz);
                tmp(1:mx-(idxShift+3)) = aCluster{j}{k}(idxShift+4:mx) - vNorm;
                rawPulses(k,:) = tmp;
            end
        end
        
        mICP(j) = nanmean(mICPRaw);
        domPulses(j,:) = trimmean(rawPulses, 10);
    end
end

pulsesTime = timing;

clear aCluster rawPulses mICPRaw;

% resample the pulseto 400hz
fact = fs / 400;

domPulsesb = nan(size(domPulses,1), round(AlgoParam.length .* fact));
domPulsesb(:,1:size(domPulses,2)) = domPulses;
domPulses = domPulsesb;
clear domPulsesb;

x = 1:size(domPulses,2);
xi = linspace(1, size(domPulses,2), AlgoParam.length);

x2 = [50:80 125];
x2i = 80:125;

domPulses2 = domPulses;
domPulses = nan(size(domPulses2,1), AlgoParam.length);
domPulsesAUC = nan(size(domPulses2,1), AlgoParam.length);

domPulses2 = domPulses2 - repmat(min(domPulses2(:,1:5)'),round(AlgoParam.length .* fact),1)';

domPulses2(isnan(domPulses2)) = 0;

for i=1:size(domPulses2,1)
    
    %--
    domPulses2(i,125) = 0;
    yy = interp1(x2,domPulses2(i,x2),x2i, 'pchip');
    domPulses2(i,x2i) = yy;
    %--
    
    domPulses(i,:) = interp1(x, domPulses2(i,:), xi, 'cubic');
    domPulsesAUC(i,:) = domPulses(i,:) ./ sum(domPulses(i,1:200));
end
clear domPulses2;



