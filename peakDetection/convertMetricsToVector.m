function metricsV = convertMetricsToVector(metrics)

for i=1:length(metrics)
    try metricsV(i,1) = metrics{i}.LTInfo.LT; catch metricsV(i,1) = nan; end
    try metricsV(i,2) = metrics{i}.LTInfo.Lv1p1; catch metricsV(i,2) = nan; end
    try metricsV(i,3) = metrics{i}.LTInfo.Lv1p2; catch metricsV(i,3) = nan; end
    try metricsV(i,4) = metrics{i}.LTInfo.Lv1p3; catch metricsV(i,4) = nan; end
    try metricsV(i,5) = metrics{i}.LTInfo.Lv2p2; catch metricsV(i,5) = nan; end
    try metricsV(i,6) = metrics{i}.LTInfo.Lv3p3; catch metricsV(i,6) = nan; end
    
    try metricsV(i,7) = metrics{i}.AmpInfo.dV1; catch metricsV(i,7) = nan; end
    try metricsV(i,8) = metrics{i}.AmpInfo.dP1; catch metricsV(i,8) = nan; end
    try metricsV(i,9) = metrics{i}.AmpInfo.dP2; catch metricsV(i,9) = nan; end
    try metricsV(i,10) = metrics{i}.AmpInfo.dP3; catch metricsV(i,10) = nan; end
    try metricsV(i,11) = metrics{i}.AmpInfo.dV2; catch metricsV(i,11) = nan; end
    try metricsV(i,12) = metrics{i}.AmpInfo.dV3; catch metricsV(i,12) = nan; end
    
    try metricsV(i,13) = metrics{i}.CurvInfo.Curvv1; catch metricsV(i,13) = nan; end
    try metricsV(i,14) = metrics{i}.CurvInfo.Curvp1; catch metricsV(i,14) = nan; end
    try metricsV(i,15) = metrics{i}.CurvInfo.Curvp2; catch metricsV(i,15) = nan; end
    try metricsV(i,16) = metrics{i}.CurvInfo.Curvp3; catch metricsV(i,16) = nan; end
    try metricsV(i,17) = metrics{i}.CurvInfo.Curvv2; catch metricsV(i,17) = nan; end
    try metricsV(i,18) = metrics{i}.CurvInfo.Curvv3; catch metricsV(i,18) = nan; end
    
    try metricsV(i,19) = metrics{i}.SlopeInfo.k1; catch metricsV(i,19) = nan; end
    try metricsV(i,20) = metrics{i}.SlopeInfo.RC3; catch metricsV(i,20) = nan; end
    try metricsV(i,21) = metrics{i}.SlopeInfo.RC1; catch metricsV(i,21) = nan; end
    try metricsV(i,22) = metrics{i}.SlopeInfo.k2; catch metricsV(i,22) = nan; end
    try metricsV(i,23) = metrics{i}.SlopeInfo.RC2; catch metricsV(i,23) = nan; end
    try metricsV(i,24) = metrics{i}.SlopeInfo.k3; catch metricsV(i,24) = nan; end
    
    try metricsV(i,25) = metrics{i}.AuxInfo.TCurv; catch metricsV(i,25) = nan; end
    try metricsV(i,26) = metrics{i}.AuxInfo.mICP; catch metricsV(i,26) = nan; end
    try metricsV(i,27) = metrics{i}.AuxInfo.diasP; catch metricsV(i,27) = nan; end
end

end