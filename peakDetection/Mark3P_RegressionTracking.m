function  peak = Mark3P_RegressionTracking(clusterRe, iValidIndex, fs, AlgoParam)
%
% Reference: "Bayesian tracking of intracranial pressure signal morphology" 
% Scalzo et al. Artif Intell Med. 2012 Feb;54(2):115-23.   
%
%==========================================================================
%   version 1.0 -- 10/2017 -- Fabien Scalzo, PhD 
%

load(AlgoParam.regFileName, 'model', 'options', 'len');
AlgoParam.RegOptions = options;                                                                  

% Extract dominant pulses and detect peak candidates
fact = fs/400;

vv = cell(1,size(clusterRe,1));
pc = cell(1,size(clusterRe,1));

P3Proc = AlgoParam.P3Proc;
parfor j=1:size(clusterRe,1)
    if(iValidIndex(j)==1)          
        % extract dominant pulse
        v = clusterRe(j,:)';
        
        % detect peak candidates
        pc{j} = Detect3P(v, P3Proc, fs);

        % resample the pulse if not 400
        if(fs ~= 400)                
            x = 1:size(v,1);
            xi = 1:fact:size(v,1); 
            vv{j} = interp1(x,v,xi, 'cubic')';       
            pc{j} = pc{j} ./ fact;           
        else
            vv{j} = v;
        end
    end
end

% Assign the 3 Peaks among peak candidates
peak = NaN(size(clusterRe,1), 3);
regPredictor = AlgoParam.regPredictor;
RegOptions = AlgoParam.RegOptions;
AssignPeakToCandidate = AlgoParam.AssignPeakToCandidate;
modelW = model;
lenW = len;

parfor j=1:size(clusterRe,1)   
    if((iValidIndex(j)== 1) && ~isempty(vv{j}))
        peak(j,:) = DetectPeaksReg(vv{j}, 400, modelW, lenW, regPredictor, RegOptions);
        if(AssignPeakToCandidate)
            peak(j,:) = Assign_PeaksSingle(pc{j}, peak(j,:), AlgoParam);                       
        end
    end
end

peak(peak(:,3) > lenW, 3) = lenW - 5;
peak = round(peak .* fact);
peak(peak <= 0) = 1;
