function beliefs = updateBeliefs(beliefs, potentialsP, algoParam)
%
% Use pairwise potentials to update the belief of each state
%
%
% Evaluate conditionals
%
% http://en.wikipedia.org/wiki/Multivariate_normal_distribution
%
% for the Gaussian case it is:
% \mu = \mu_1 + \Sigma_{12} \Sigma_{22}^{-1} (  a - \mu_2) 
% \Sigma = \Sigma_{11} - \Sigma_{12} \Sigma_{22}^{-1} \Sigma_{21}
%
%
% b_{1,t} = b_{1,t} \psi(x_{1,t}, x_{2,t} =  b_{2,t}) \psi(x_{1,t}, x_{3,t} =  b_{3,t})
% b_{2,t} = b_{2,t} \psi(x_{2,t}, x_{1,t} =  b_{1,t}) \psi(x_{2,t}, x_{3,t} =  b_{3,t})
% b_{3,t} = b_{3,t} \psi(x_{3,t}, x_{1,t} =  b_{1,t}) \psi(x_{3,t}, x_{2,t} =  b_{2,t})    
%
% Reference: "Bayesian tracking of intracranial pressure signal morphology" 
% Scalzo et al. Artif Intell Med. 2012 Feb;54(2):115-23.   
%
%==========================================================================
%   version 1.0 -- 10/2017 -- Fabien Scalzo, PhD 
%

% evaluate conditional
if(algoParam.parametricModel)       
    % latency
    % mean
    cond_12.mu = beliefs.mu1L + potentialsP.mu12L;
    cond_21.mu = beliefs.mu2L - potentialsP.mu12L;
        
    cond_13.mu = beliefs.mu1L + potentialsP.mu13L;
    cond_31.mu = beliefs.mu3L - potentialsP.mu13L;

    cond_23.mu = beliefs.mu2L + potentialsP.mu23L;
    cond_32.mu = beliefs.mu3L - potentialsP.mu23L;
        
    % std
    cond_12.std = potentialsP.std12L * algoParam.pairwiseSigmaL;
    cond_21.std = potentialsP.std12L * algoParam.pairwiseSigmaL;

    cond_13.std = potentialsP.std13L * algoParam.pairwiseSigmaL;
    cond_31.std = potentialsP.std13L * algoParam.pairwiseSigmaL;

    cond_23.std = potentialsP.std23L * algoParam.pairwiseSigmaL;    
    cond_32.std = potentialsP.std23L * algoParam.pairwiseSigmaL;      


    % Gaussian Product
    beliefs.std1Lb = 1 ./ ((1 ./ beliefs.std1L) + (1 ./ cond_21.std) + (1 ./ cond_31.std));
    beliefs.mu1L = ((beliefs.mu1L ./ beliefs.std1L) + (cond_21.mu ./ cond_21.std) + (cond_31.mu ./ cond_31.std)) .* beliefs.std1Lb;

    beliefs.std2Lb = 1 ./ ((1 ./ beliefs.std2L) + (1 ./ cond_12.std) + (1 ./ cond_32.std));
    beliefs.mu2L = ((beliefs.mu2L ./ beliefs.std2L) + (cond_12.mu ./ cond_12.std) + (cond_32.mu ./ cond_32.std)) .* beliefs.std2Lb;

    beliefs.std3Lb = 1 ./ ((1 ./ beliefs.std3L) + (1 ./ cond_13.std) + (1 ./ cond_23.std));
    beliefs.mu3L = ((beliefs.mu3L ./ beliefs.std3L) + (cond_13.mu ./ cond_13.std) + (cond_23.mu ./ cond_23.std)) .* beliefs.std3Lb;

    beliefs.std1L = beliefs.std1Lb;
    beliefs.std2L = beliefs.std2Lb;
    beliefs.std3L = beliefs.std3Lb;
    
    % elevation
    cond_12.mu = beliefs.mu1E + potentialsP.mu12E;
    cond_21.mu = beliefs.mu2E - potentialsP.mu12E;
        
    cond_13.mu = beliefs.mu1E + potentialsP.mu13E;
    cond_31.mu = beliefs.mu3E - potentialsP.mu13E;

    cond_23.mu = beliefs.mu2E + potentialsP.mu23E;
    cond_32.mu = beliefs.mu3E - potentialsP.mu23E;
        
    % std
    cond_12.std = potentialsP.std12E * algoParam.pairwiseSigmaE;
    cond_21.std = potentialsP.std12E * algoParam.pairwiseSigmaE;

    cond_13.std = potentialsP.std13E * algoParam.pairwiseSigmaE;
    cond_31.std = potentialsP.std13E * algoParam.pairwiseSigmaE;

    cond_23.std = potentialsP.std23E * algoParam.pairwiseSigmaE;    
    cond_32.std = potentialsP.std23E * algoParam.pairwiseSigmaE;      


    % Gaussian Product
    beliefs.std1Eb = 1 ./ ((1 ./ beliefs.std1E) + (1 ./ cond_21.std) + (1 ./ cond_31.std));
    beliefs.mu1E = ((beliefs.mu1E ./ beliefs.std1E) + (cond_21.mu ./ cond_21.std) + (cond_31.mu ./ cond_31.std)) .* beliefs.std1Eb;

    beliefs.std2Eb = 1 ./ ((1 ./ beliefs.std2E) + (1 ./ cond_12.std) + (1 ./ cond_32.std));
    beliefs.mu2E = ((beliefs.mu2E ./ beliefs.std2E) + (cond_12.mu ./ cond_12.std) + (cond_32.mu ./ cond_32.std)) .* beliefs.std2Eb;

    beliefs.std3Eb = 1 ./ ((1 ./ beliefs.std3E) + (1 ./ cond_13.std) + (1 ./ cond_23.std));
    beliefs.mu3E = ((beliefs.mu3E ./ beliefs.std3E) + (cond_13.mu ./ cond_13.std) + (cond_23.mu ./ cond_23.std)) .* beliefs.std3Eb;

    beliefs.std1E = beliefs.std1Eb;
    beliefs.std2E = beliefs.std2Eb;
    beliefs.std3E = beliefs.std3Eb;
  
    
    
    
    
%     % evaluate conditional
%     % mean
%     cond_12.mu = potentialsP.mu12(2) + (potentialsP.std12(2,1) * (1./potentialsP.std12(1,1)) * (beliefs.mu1 - potentialsP.mu12(1)));
%     cond_21.mu = potentialsP.mu12(1) + (potentialsP.std12(1,2) * (1./potentialsP.std12(2,2)) * (beliefs.mu2 - potentialsP.mu12(2)));
%         
%     cond_13.mu = potentialsP.mu13(2) + (potentialsP.std13(2,1) * (1./potentialsP.std13(1,1)) * (beliefs.mu1 - potentialsP.mu13(1)));
%     cond_31.mu = potentialsP.mu13(1) + (potentialsP.std13(1,2) * (1./potentialsP.std13(2,2)) * (beliefs.mu3 - potentialsP.mu13(2)));
% 
%     cond_23.mu = potentialsP.mu23(2) + (potentialsP.std23(2,1) * (1./potentialsP.std23(1,1)) * (beliefs.mu2 - potentialsP.mu23(1)));
%     cond_32.mu = potentialsP.mu23(1) + (potentialsP.std23(1,2) * (1./potentialsP.std23(2,2)) * (beliefs.mu3 - potentialsP.mu23(2)));
%     
%     
%     % std
%     cond_12.std = potentialsP.std12(1,1) - (potentialsP.std12(1,2) * (1/potentialsP.std12(2,2) * (potentialsP.std12(2,1))));
%     cond_21.std = potentialsP.std12(2,2) - (potentialsP.std12(1,2) * (1/potentialsP.std12(1,1) * (potentialsP.std12(2,1))));
% 
%     cond_13.std = potentialsP.std13(1,1) - (potentialsP.std13(1,2) * (1/potentialsP.std13(2,2) * (potentialsP.std13(2,1))));
%     cond_31.std = potentialsP.std13(2,2) - (potentialsP.std13(1,2) * (1/potentialsP.std13(1,1) * (potentialsP.std13(2,1))));
% 
%     cond_23.std = potentialsP.std23(1,1) - (potentialsP.std23(1,2) * (1/potentialsP.std23(2,2) * (potentialsP.std23(2,1))));
%     cond_32.std = potentialsP.std23(2,2) - (potentialsP.std23(1,2) * (1/potentialsP.std23(1,1) * (potentialsP.std23(2,1))));
% 
% 
    
else
    
    % find the conditional distr. P( x(~i) | x(i) = A(i))
    %                     P is a KDE, i is a dimension index (e.g. [2,3]) and A
    %                     is an [Ndim x 1] double
        
    f = algoParam.OptionsKDE.sigmaPairFact;
    
    pts = getPoints(beliefs.kde1L);
    for i=1:algoParam.OptionsKDE.nParticle
        tmp12(i) = mean(condition(potentialsP.kde12L, 1, [pts(i); 0]));        
        tmp13(i) = mean(condition(potentialsP.kde13L, 1, [pts(i); 0]));        
    end     
    cond_12 = kde(mean(tmp12), std(tmp12)*f);
    cond_13 = kde(mean(tmp13), std(tmp13)*f);

    pts = getPoints(beliefs.kde2L);    
    for i=1:algoParam.OptionsKDE.nParticle
        tmp21(i) = mean(condition(potentialsP.kde12L, 2, [0; pts(i)]));        
        tmp23(i) = mean(condition(potentialsP.kde13L, 1, [pts(i); 0]));        
    end     
    cond_21 = kde(mean(tmp21), std(tmp21)*f);
    cond_23 = kde(mean(tmp23), std(tmp23)*f);

    pts = getPoints(beliefs.kde3L);   
    for i=1:algoParam.OptionsKDE.nParticle
        tmp31(i) = mean(condition(potentialsP.kde13L, 2, [0; pts(i)]));        
        tmp32(i) = mean(condition(potentialsP.kde23L, 2, [0; pts(i)]));        
    end     
    cond_31 = kde(mean(tmp31), std(tmp31)*f);
    cond_32 = kde(mean(tmp32), std(tmp32)*f);

    
%     pts = getPoints(beliefs.kde1E);
%     for i=1:algoParam.OptionsKDE.nParticle
%         tmp12(i) = mean(condition(potentialsP.kde12E, 1, [pts(i); 0]));        
%         tmp13(i) = mean(condition(potentialsP.kde13E, 1, [pts(i); 0]));        
%     end     
%     cond_12E = kde(mean(tmp12), std(tmp12)*f);
%     cond_13E = kde(mean(tmp13), std(tmp13)*f);
% 
%     pts = getPoints(beliefs.kde2E);    
%     for i=1:algoParam.OptionsKDE.nParticle
%         tmp21(i) = mean(condition(potentialsP.kde12E, 2, [0; pts(i)]));        
%         tmp23(i) = mean(condition(potentialsP.kde13E, 1, [pts(i); 0]));        
%     end     
%     cond_21E = kde(mean(tmp21), std(tmp21)*f);
%     cond_23E = kde(mean(tmp23), std(tmp23)*f);
% 
%     pts = getPoints(beliefs.kde3E);   
%     for i=1:algoParam.OptionsKDE.nParticle
%         tmp31(i) = mean(condition(potentialsP.kde13E, 2, [0; pts(i)]));        
%         tmp32(i) = mean(condition(potentialsP.kde23E, 2, [0; pts(i)]));        
%     end     
%     cond_31E = kde(mean(tmp31), std(tmp31)*f);
%     cond_32E = kde(mean(tmp32), std(tmp32)*f);

    
    
    % NonParametric product
    dummy = kde(double(1 + (500-1).*rand(algoParam.OptionsKDE.nParticle .* 2,1))', 1);
   
    beliefs.kde1L = productApprox(dummy, {beliefs.kde1L, cond_21, cond_31},{},{},'exact');
    beliefs.kde2L = productApprox(dummy, {beliefs.kde2L, cond_12, cond_32},{},{},'exact');
    beliefs.kde3L = productApprox(dummy, {beliefs.kde3L, cond_13, cond_23},{},{},'exact');    

%     dummy = kde(double(0.5 + (50-0.5).*rand(algoParam.OptionsKDE.nParticle .* 2,1))', 1);
%    
%     beliefs.kde1E = productApprox(dummy, {beliefs.kde1E, cond_21E, cond_31E},{},{},'exact');
%     beliefs.kde2E = productApprox(dummy, {beliefs.kde2E, cond_12E, cond_32E},{},{},'exact');
%     beliefs.kde3E = productApprox(dummy, {beliefs.kde3E, cond_13E, cond_23E},{},{},'exact');    

end   






