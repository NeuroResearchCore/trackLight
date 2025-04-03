function validateforBasicAlgorithmFabforTable2_revised()

options.normalizeHeartRate = 1;
options.normalizeAUC = 1;
options.removeOutliers = 1;
options.pulseLength = 400;

options.useDerivative = 0;
options.sigmaDerivative = 5;
options.normalizeAcrossPatient = 0;

options.excludePatients = 0;
options.patientsToExclude = [];

options.trainModel = 0;
options.saveModel = 0;
options.noiseRate = 0;

[norm, dataLearn] = performLearnICPRegModel(options);
uPatient = dataLearn.patient;

CV.training = 1:50;
CV.testing = 51:numel(dataLearn.patient);

mxVal = max(dataLearn.X(:));
dataLearn.X = dataLearn.X ./ mxVal;

idxTest = CV.testing;  

noiseRate = [0 0.05 0.1 0.15];
for noiseIdx = 1:numel(noiseRate)
    
    noiseSignal = rand(size(dataLearn.X)).* (noiseRate(noiseIdx) .* max(dataLearn.X(:)));
    dataNoise = dataLearn.X + noiseSignal;    
    
    for learner=1:1
        for peak=1:3            
            
            Yhat_t = runMOCAIPonBeatArray(dataNoise(idxTest,:), []);
            Yhat = Yhat_t(:,peak);
            sseI = (dataLearn.Y(idxTest,peak) - ((Yhat - norm.normFactY.minValueY(peak)) ./norm.normFactY.maxValueY(peak)) ).^2;
            ssyI = (dataLearn.Y(idxTest,peak) - nanmean(dataLearn.Y(idxTest,peak))).^2;

            sse = nansum(sseI);            % SSE = sum( (Y - Yhat) ^2)
            ssy = nansum(ssyI);            % SSY = sum( (Y - mean(Y) ^2)
            
            rmse{peak}(noiseIdx, learner) = sqrt(sse ./ numel(sseI));            
        end
    end
end

save('./step1Table2_mocaip.mat',  'rmse');