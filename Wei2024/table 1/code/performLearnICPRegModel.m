function [model, dataLearn] = performLearnICPRegModel(options)
%  PERFORMLEARNICPREGMODEL learns the regression models

if(nargin<1)
    options.learner = @Reg_LearnKSR;
    options.ReguAlpha =  0.0003;
    options.ReguType = 'Ridge';
    options.KernelType = 'Gaussian';
    options.t = 3.1;
    
    options.normalizeHeartRate = 1;
    options.normalizeAUC = 1;
    options.removeOutliers = 1;
    options.pulseLength = 400;
 %   options.pulseLength = 600;%wmm20200506
    options.normalizeAcrossPatient = 1;
    
    options.useDerivative = 1;
    options.sigmaDerivative = 5;
    options.trainModel = 1;
    
    options.excludePatients = 1;
    options.patientsToExclude = [];
    
    options.saveModel = 1;
    options.outFileName = './icpRegModel0.mat';
end
load('D:\Fabien\ICPMiaomiao\code for MOCAIP and trackLight_master\ICPdatabase.mat', 'vv', 'l1', 'l2', 'l3', 'patient');
%load('./ArtificialICPdata0%noise400.mat', 'vv', 'l1', 'l2', 'l3', 'patient');%wmm20200506,ArtificialICPdata5%noise.mat

X = nan(numel(vv), options.pulseLength);

for i=1:numel(vv)
    mx = numel(vv{i});
    [vNorm, idxShift] = min(vv{i}(5:55));
    
    tmp = nan(1,mx);
    tmp(1:mx-idxShift+1) = vv{i}(idxShift:mx) - vNorm;
    X(i,1:min(options.pulseLength,mx)) = tmp(1:min(options.pulseLength,mx));
   
    l1(i) = l1(i) - idxShift;
    l2(i) = l2(i) - idxShift;
    l3(i) = l3(i) - idxShift;
end

if(options.normalizeHeartRate)
    for i=1:numel(vv)
        idx = linspace(1, nnz(~isnan(X(i,:))), options.pulseLength);
        l1(i) = l1(i) .* (options.pulseLength ./ nnz(~isnan(X(i,:))));
        l2(i) = l2(i) .* (options.pulseLength ./ nnz(~isnan(X(i,:))));
        l3(i) = l3(i) .* (options.pulseLength ./ nnz(~isnan(X(i,:))));
        
        X(i,:) = interp1(1:nnz(~isnan(X(i,:))), X(i,~isnan(X(i,:))), idx, 'pchip');
        
%         plot(X(i,:)); hold on; plot(round(l1(i)), X(i,round(l1(i))),  'go', 'MarkerSize', 8); 
%         plot(round(l2(i)), X(i,round(l2(i))),  'go', 'MarkerSize', 8); 
%         plot(round(l3(i)), X(i,round(l3(i))),  'go', 'MarkerSize', 8); 
%         close;
    end
end

if(options.normalizeAUC)
    for i=1:numel(vv)
        X(i,:) = X(i,:) ./ sum(X(i,:));
        
    end
end

if(options.removeOutliers)
    stdDev = std(X);
    meanValue = mean(X);
    zFactor = 1.5;
    outliers = sum(abs(X-repmat(meanValue,size(X,1),1)),2) > (zFactor * sum(stdDev));
    X = X(~outliers,:);
    dataLearn.outliers = outliers;
    l1 = l1(~outliers);
    l2 = l2(~outliers);
    l3 = l3(~outliers);
    patient = patient(~outliers);
end

if(options.useDerivative)
    [Dx, Dxx] = computePulseDerivatives(X, options);
    X = [X Dx Dxx];
end

if(options.excludePatients)
   keep = ~ismember(patient, options.patientsToExclude);
   X = X(keep,:);
   l1 = l1(keep,:);
   l2 = l2(keep,:);
   l3 = l3(keep,:);
end

if(options.normalizeAcrossPatient)
%    normFact.median = median(X,1);
%    normFact.std = nanstd(X,0,1);    
%    X = (X - repmat(normFact.median, size(X,1),1)) ./ repmat(normFact.std, size(X,1),1);    
   % X = NormalizeFea(X, 0);    


    normFact.median = median(X,1);
    normFact.std = nanstd(X,0,1);    
    X = (X - repmat(normFact.median, size(X,1),1)) ./ repmat(normFact.std, size(X,1),1);    
   % X = NormalizeFea(X, 0);    
    normFact.min = min(X(:));
    normFact.max = max(X(:));    
   
    X = (X - min(X(:))) ./ (max(X(:)) - min(X(:)));
end


% normalize labels
 model.normFactY.minValueY(1) = nanmin(l1);
 model.normFactY.maxValueY(1) = nanmax(l1);
 model.normFactY.minValueY(2) = nanmin(l2);
 model.normFactY.maxValueY(2) = nanmax(l2);
 model.normFactY.minValueY(3) = nanmin(l3);
 model.normFactY.maxValueY(3) = nanmax(l3);

 l1 = (l1 - model.normFactY.minValueY(1)) ./ (model.normFactY.maxValueY(1) -  model.normFactY.minValueY(1));
 l2 = (l2 - model.normFactY.minValueY(2)) ./ (model.normFactY.maxValueY(2) -  model.normFactY.minValueY(2));
 l3 = (l3 - model.normFactY.minValueY(3)) ./ (model.normFactY.maxValueY(3) -  model.normFactY.minValueY(3));
 
% Learn the regression model
dataLearn.X = X;

dataLearn.Y = [l1 l2 l3];
dataLearn.patient = patient;

if(options.trainModel)
   
    % neural network
    net1 = feedforwardnet(7);
    net2 = feedforwardnet(7);
    net3 = feedforwardnet(7);
    net1.trainParam.showWindow = false;
    net2.trainParam.showWindow = false;
    net3.trainParam.showWindow = false;
    model.net.p1 = train(net1, dataLearn.X', dataLearn.Y(:,1)', 'useParallel','yes', 'useGPU','yes', 'showResources','no');
    model.net.p2 = train(net2, dataLearn.X', dataLearn.Y(:,2)', 'useParallel','yes', 'useGPU','yes', 'showResources','no');
    model.net.p3 = train(net3, dataLearn.X', dataLearn.Y(:,3)', 'useParallel','yes', 'useGPU','yes', 'showResources','no');
    
    [K] = constructKernel(dataLearn.X,[],options);
    model.ksr.p1 = KSR(options, dataLearn.Y(:,1), K);
    model.ksr.p2 = KSR(options, dataLearn.Y(:,2), K);
    model.ksr.p3 = KSR(options, dataLearn.Y(:,3), K);
    
    model.sr.p1 = SR(options, dataLearn.Y(:,1), dataLearn.X);
    model.sr.p2 = SR(options, dataLearn.Y(:,2), dataLearn.X);
    model.sr.p3 = SR(options, dataLearn.Y(:,3), dataLearn.X);
    
    % decision trees
    paroptions = statset('UseParallel',true);
    model.tree.p1 = TreeBagger(70, dataLearn.X, dataLearn.Y(:,1), 'Method','regression', 'Options', paroptions);
    model.tree.p2 = TreeBagger(70, dataLearn.X, dataLearn.Y(:,2), 'Method','regression', 'Options', paroptions);
    model.tree.p3 = TreeBagger(70, dataLearn.X, dataLearn.Y(:,3), 'Method','regression', 'Options', paroptions);
        
    model.dataLearn = dataLearn;
    model.normFact = normFact;
  %  [model] = feval(options.learner, dataLearn, options);
end

if(options.saveModel)
    save(options.outFileName, 'model', 'options');
end
    