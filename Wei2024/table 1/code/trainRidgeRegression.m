function [model] = trainRidgeRegression(X, Y, options)
 
eig = SR(options, Y, X); 

model.eig = eig;
model.options = options;