function [assignedP] = Assign_PeaksSingle(candidateP, regressionP, AlgoParam)
% assign peaks to candidateP using regression peaks
%
%       [assignedP] = Assign_Peaks(candidateP, regressionP)
% 
%             Input:
%                 - candidateP:   candidate peaks
%                 - regressionP:  peaks located predicted by SR
%             Output:
% 
% Reference: "Bayesian tracking of intracranial pressure signal morphology" 
% Scalzo et al. Artif Intell Med. 2012 Feb;54(2):115-23.   
%
%==========================================================================
%   version 1.0 -- 10/2017 -- Fabien Scalzo, PhD 
%

th1 = AlgoParam.th1;
th2 = AlgoParam.th2;
th3 = AlgoParam.th3;

assignedP = ones(1, 3);

p1done = 0;
p2done = 0;
p3done = 0;

% assign the peak where the distance btw the prediction and the
% candidate is the lowest
for j=1:3
    if(~isempty(candidateP))
        
        if(p1done == 0) 
            dist1 = abs(candidateP - regressionP(1)); 
            [min1, ind1] = min(dist1);
        else min1 = inf;
        end        
        if(p2done == 0) 
            dist2 = abs(candidateP - regressionP(2)); 
            [min2, ind2] = min(dist2);
        else min2 = inf;
        end        
        if(p3done == 0) 
            dist3 = abs(candidateP - regressionP(3)); 
            [min3, ind3] = min(dist3); 
        else min3 = inf;
        end
            
        [best, indbest] = min([min1 min2 min3]);    
        switch indbest
            case 1 
                if(min1 <= th1)
                    assignedP(indbest) = candidateP(ind1);
                end
                p1done = 1;         
                candidateP(ind1)=[];            
            case 2   
                if(min2 <= th2)
                    assignedP(indbest) = candidateP(ind2);
                end
                p2done = 1;             
                candidateP(ind2)=[];            
            case 3  
                if(min3 <= th3)
                    assignedP(indbest) = candidateP(ind3);
                end
                p3done = 1;  
                candidateP(ind3)=[];
        end
    end
end

ind = find(assignedP==1);
assignedP(ind) = nan;

if(AlgoParam.AssignPeakToCandidate == 2)
    if(~isempty(ind))
        assignedP(ind) = regressionP(ind);
    end
end


