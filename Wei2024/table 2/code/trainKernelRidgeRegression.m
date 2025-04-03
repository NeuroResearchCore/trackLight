function [model] = trainKernelRidgeRegression(X, Y, options)

[K] = constructKernel(X,[],options);
eig = KSR(options, Y, K);

model.eig = eig;
model.Xtrain = X;
model.options = options;