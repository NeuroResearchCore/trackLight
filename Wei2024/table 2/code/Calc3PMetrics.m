function [peak, refP] = Calc3PMetrics_forward(peakCandidates, lt, pulseSmpLen, libRefP)
% Calculate metrics for optimal 3 P assignment
%
%
%
%
% Author: Xiao Hu, Ph.D.

%relative to the onset
peak = peakCandidates - lt;
% peak(1) = peak(1) + 20;
% if (length(peak) >=2)
%     peak(2) = peak(2) + 55;
% end;
% if (length(peak) >=3)
%     peak(3) = peak(3) + 55;
% end;
% if (length(peak) >=4)
%     peak(4:end) = 1000;
% end;
%relative to the onset
refP = libRefP(:, 1:3) - repmat(libRefP(:, 5), 1, 3);