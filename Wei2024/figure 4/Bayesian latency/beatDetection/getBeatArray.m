function [beats] = getBeatArray(ecg, icp, fs)
%
%   Detect individual ICP beats using ECG-QRS detection
%
%  Reference
%  Hu et al. An algorithm for extracting intracranial pressure latency relative to electrocardiogram R wave.
%       Physiological measurement (2008) 29 459-71.
%
%==========================================================================
%   version 1.0 -- 10/2017 -- Fabien Scalzo, PhD
%

beats = [];

icp(isnan(icp)) = nanmean(icp);
icp(isinf(icp)) = nanmean(icp);

if(nnz(isnan(icp)) > 0 || nnz(isinf(icp)) > 0)
    return;
end

minECG = prctile(ecg, 20);
maxECG = prctile(ecg, 80);
k = (0.5-(-0.5))/(maxECG - minECG); b = -0.5 - k * minECG;
ecg = ecg * k + b;
H2 = qrsdetect(ecg(:), fix(fs+0.5), 1);
%idx = find(H2.EVENT.TYP == hex2dec('0501'));
R = H2.EVENT.POS;
if(isempty(R))
    return;
end
R = correctQRS(R, ecg, fs);

fr = fs./diff(R);

if( (mean(fr) <= 0.5) || (mean(fr) >= 5))
    return;
end;

fc_h = quantile(fr, 0.3);
fc_l = quantile(fr, 0.5);

fICP = zpIIR(icp,  2, 0.1, 30, fc_h*2/fs,1);
fICP = zpIIR(fICP,  2, 0.1, 30, fc_l *2/fs,0);
lICP = zpIIR(icp,  2, 0.05, 30, 5*2/fs,1);

dp = GetDefaultDP(median(diff(R)*1000/fs), 0, fs);

maxpos = B8PeakDetect(R, fICP, ecg, dp, fs);
foot = B8FootDetect(R, maxpos, lICP, ecg, fs);

beats = CalB8Measure(lICP, R, maxpos, foot);
