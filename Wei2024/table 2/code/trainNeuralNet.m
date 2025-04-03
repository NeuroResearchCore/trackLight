function [model] = trainNeuralNet(X, Y, options)

net = feedforwardnet(options.nbLayers);
%net.trainFcn = 'trainscg';
net.trainParam.showWindow = false;
model = train(net, X', Y', 'useParallel','yes', 'useGPU','yes', 'showResources','no');
