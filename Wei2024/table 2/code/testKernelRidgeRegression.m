function [Yhat] = testKernelRidgeRegression(X, model)

[Ktest] = constructKernel(X, model.Xtrain, model.options);
Yhat = Ktest * model.eig;
