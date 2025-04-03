function [model] = trainLSTM(X, Y, options)

% warning off parallel:gpu:device:DeviceLibsNeedsRecompiling
% try
%     gpuArray.eye(2)^2;
% catch ME
% end
% try
%     nnet.internal.cnngpu.reluForward(1);
% catch ME
% end

numFeatures = size(X,2);
numResponses = 1;
numHiddenUnits = options.numberHidden;

layers = [ ...
    sequenceInputLayer(numFeatures)
    lstmLayer(numHiddenUnits)
    fullyConnectedLayer(numResponses)
    regressionLayer];

options = trainingOptions('adam', ...
    'MaxEpochs',200, ...
    'GradientThreshold',1, ...
    'InitialLearnRate',0.005, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',125, ...
    'LearnRateDropFactor',0.2, ...
    'verbose', 0);
%    'Plots','training-progress');

 model = trainNetwork(X',Y',layers,options);
