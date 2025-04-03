function [Yhat] = testRidgeRegression(X, model)
    
    Yhat = X * model.eig; 