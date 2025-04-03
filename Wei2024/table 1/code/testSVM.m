function [Yhat] = testSVM(X, model)

[Yhat] = model.svm.predict(X);
