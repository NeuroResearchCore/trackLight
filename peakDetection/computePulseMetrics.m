function [LTInfo, AmpInfo, CurvInfo, SlopeInfo, AuxInfo] = computePulseMetrics(v, ppk, fs, onsetFun)

mICP = mean(v);
sig_diff1 = diff1(v, 5);
sig_diff2 = diff1(sig_diff1, 5);
curv = abs(sig_diff2(:))./((1+sig_diff1(:).*sig_diff1(:)).^(1.5));
acurv = (sig_diff2(:))./((1+sig_diff1(:).*sig_diff1(:)).^(1.5));

%first peak is not missing
if ~isnan(ppk(1))
    subsig = v(1:ppk(1));
    lt = feval(onsetFun, subsig, fs);
    if (isnan(lt))
        [diasP, lt]= min(subsig);
    else
        [diasP]= min(subsig);
    end;
elseif ~isnan(ppk(2))
    subsig = v(1:ppk(2));
    [diasP, lt]= min(subsig);
    lt = feval(onsetFun, subsig, fs);
else
    subsig = v(1:floor(length(v)/3));
    [diasP, lt]= min(subsig);
end;

% First peak
AmpInfo.dV1 = v(fix(lt)) - diasP;
CurvInfo.Curvv1 = curv(fix(lt));
LTInfo.LT = lt;
if (~isnan(ppk(1)))
    LTInfo.Lv1p1 = ppk(1) - lt;
%--
    AmpInfo.dP1 =  v(ppk(1)) - diasP;
%    AmpInfo.dP1 =  v(ppk(1));
    CurvInfo.Curvp1 = curv(ppk(1));
    SlopeInfo.k1 = AmpInfo.dP1 / (LTInfo.Lv1p1 / fs);
else
    LTInfo.Lv1p1 = NaN;
    AmpInfo.dP1 = NaN;
    CurvInfo.Curvp1 = NaN;
    SlopeInfo.k1 = NaN;
end;


% second peak is not missing
if ~isnan(ppk(2))
    LTInfo.Lv1p2 = ppk(2) - lt;
%--
    AmpInfo.dP2 = v(ppk(2)) - diasP;
%    AmpInfo.dP2 = v(ppk(2));
    CurvInfo.Curvp2 = curv(ppk(2));
else
    LTInfo.Lv1p2 = NaN;
    AmpInfo.dP2 = NaN;
    CurvInfo.Curvp2 = NaN;
end;

% third peak is not missing
if ~isnan(ppk(3))
    LTInfo.Lv1p3 = ppk(3) - lt;
%--
    AmpInfo.dP3 = v(ppk(3)) - diasP;
%    AmpInfo.dP3 = v(ppk(3));
    CurvInfo.Curvp3 = curv(ppk(3));
    [minP, minPos] = min(v(ppk(3):end));
    SlopeInfo.RC3 = abs(v(ppk(3)) - minP)/(minPos/fs);
else
    LTInfo.Lv1p3 = NaN;
    AmpInfo.dP3 = NaN;
    CurvInfo.Curvp3 = NaN;
    SlopeInfo.RC3 = NaN;
end;


% find v2
if(~isnan(ppk(1)) && ~isnan(ppk(2)))
    subsig = acurv(ppk(1):ppk(2));
    tidx = FindLocalExtrem(subsig, 1, 0);
    if (isnan(tidx))
        tidx = fix(numel(subsig)/2);
    end;
    ml2 = lt + LTInfo.Lv1p1  +  tidx - 1;

    AmpInfo.dV2 = v(ml2) - diasP;
    CurvInfo.Curvv2 = curv(ml2);
    LTInfo.Lv2p2 = ppk(2) - ml2;
    SlopeInfo.RC1 =  abs(v(ppk(1)) - v(ml2))/((ml2-ppk(1))/fs);
    SlopeInfo.k2 =  abs(v(ppk(2)) - v(ml2))/(LTInfo.Lv2p2/fs);
    %     plot(v);
    %     hold on;
    %     plot(ppk(1:2), v(ppk(1:2)), 'k*');
    %     plot(ppk(2)-ml2, v(fix(ppk(2)-ml2)),'ro');
else
    AmpInfo.dV2 = NaN;
    CurvInfo.Curvv2 = NaN;
    LTInfo.Lv2p2 = NaN;
    SlopeInfo.RC1 =  NaN;
    SlopeInfo.k2 =  NaN;
end;

if(~isnan(ppk(2)) & ~isnan(ppk(3)))
    subsig = acurv(ppk(2):ppk(3));
    tidx = FindLocalExtrem(subsig, 1, 0);
    if (isnan(tidx))
        tidx = fix(numel(subsig)/2);
    end;
    ml3 = lt + LTInfo.Lv1p2 +  tidx - 1;

    AmpInfo.dV3 = v(ml3) - diasP;
    CurvInfo.Curvv3 = curv(ml3);
    LTInfo.Lv3p3 = ppk(3) - ml3;

    SlopeInfo.RC2 =  abs(v(ppk(2)) - v(ml3))/((ml3-ppk(2))/fs);
    SlopeInfo.k3 =  abs(v(ppk(3)) - v(ml3))/( LTInfo.Lv3p3/fs);
else
    AmpInfo.dV3 = NaN;
    CurvInfo.Curvv3 = NaN;
    LTInfo.Lv3p3 = NaN;
    SlopeInfo.RC2 = NaN;
    SlopeInfo.k3 =  NaN;
end;

LTInfo.LT = LTInfo.LT * 1000 / fs;
LTInfo.Lv1p1 = LTInfo.Lv1p1 * 1000 / fs;
LTInfo.Lv1p2 = LTInfo.Lv1p2 * 1000 / fs;
LTInfo.Lv1p3 = LTInfo.Lv1p3 * 1000 / fs;
LTInfo.Lv2p2 = LTInfo.Lv2p2 * 1000 / fs;
LTInfo.Lv3p3 = LTInfo.Lv3p3 * 1000 / fs;


AuxInfo.TCurv = mean(curv);
AuxInfo.mICP = mICP;
AuxInfo.diasP = diasP;