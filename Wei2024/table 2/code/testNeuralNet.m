function [Yhat] = testNeuralNet(X, model)

Yhat = model(X');
Yhat = Yhat';