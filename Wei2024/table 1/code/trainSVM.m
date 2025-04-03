function [model] = trainSVM(X, Y, options)

svm = fitrsvm( X, Y, 'Standardize', false,  'KernelFunction', 'gaussian');
%, 'KernelScale','auto');
%svm = fitcsvm( X(idxTrain,:), Y(idxTrain), 'Standardize', false, 'KernelFunction', 'gaussian');


%svm = fitcsvm( X(idxTrain,:), Y(idxTrain), 'Standardize',true,'KernelFunction','rbf', 'KernelScale','auto');

%Yhat = svm.predict(X(idxTest,:));

%g=1;
%[~, tmp] = svm.predict(X(idxTest,:));
%Yhat = tmp(:,1);

model.svm = svm;