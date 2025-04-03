function [Yhat] = testLSTM(X, model)

Yhat = predict(model, X');
Yhat = Yhat';