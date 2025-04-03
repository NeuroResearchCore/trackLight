function [tracking, metricsV] = bayesianTracking(v, ppk,Y, fs, onsetFun)
% settings = getDefaultSettings();
for k = 1:size(v,1)

    [metrics{k}.LTInfo, metrics{k}.AmpInfo, metrics{k}.CurvInfo, metrics{k}.SlopeInfo, metrics{k}.AuxInfo] =...
               computePulseMetrics_mm(v(k,:), round(ppk(k, :)), fs, onsetFun);
           % [metrics{k}.LTInfo, metrics{k}.AmpInfo, metrics{k}.CurvInfo, metrics{k}.SlopeInfo, metrics{k}.AuxInfo] =...
           %    computePulseMetrics_mm(v(k,:), round(ppk(k, :)), fs, onsetFun);

end

metricsV = convertMetricsToVector(metrics);
tracking = performTracking(metricsV);
% figure;
% plot(tracking(:,1),'-.');
% hold on;
% plot(Y(:,1),'--');
% title('Bayesian tracking');
% err = Y(:,1)-tracking(:,1);
% rmeanE2 = sqrt(mean(err(:, 1).^2))
% biasE2 = mean(err(:, 1));
% stdE2 = (mean(err(:, 1).^2) - biasE2.^2) / sqrt(numel(err(:, 1)))

