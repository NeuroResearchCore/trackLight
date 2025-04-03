function [model] = trainDecisionForest(X, Y, options)

model = TreeBagger(options.nbTrees, X, Y, 'Method', 'regression', 'Options', options.paroptions);
%Mdl = TreeBagger(3,X(idxTrain,:),Y(idxTrain),'Method','regression', 'Options', paroptions);

%[Yhat, ~] = predict(Mdl,  X(idxTest,:));


