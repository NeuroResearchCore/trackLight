function beliefs = evalBeliefs(likelihood, temporalPrior, algoParam)
% 
%       b_{i,t} = \phi_{i,t}  p(x_{i,t} | p(x_{i,t-1}, i=1,2,3
%
% References: 
% - ccrma.stanford.edu/~jos/sasp/Product_Two_Gaussian_PDFs.html
% - Ihler et al, Efficient Multiscale Sampling from Products of Gaussian
% Mixtures
% -"Bayesian tracking of intracranial pressure signal morphology" 
% Scalzo et al. Artif Intell Med. 2012 Feb;54(2):115-23.   
%
%==========================================================================
%   version 1.0 -- 10/2017 -- Fabien Scalzo, PhD 
%

if(algoParam.parametricModel)      
    
    % latency
    % Product of Gaussian Densities
    beliefs.std1L = 1 ./ ((1 ./ likelihood.std1L) + (1 ./ temporalPrior.std1L));
    beliefs.std2L = 1 ./ ((1 ./ likelihood.std2L) + (1 ./ temporalPrior.std2L));
    beliefs.std3L = 1 ./ ((1 ./ likelihood.std3L) + (1 ./ temporalPrior.std3L));

    beliefs.mu1L = ((likelihood.mu1L ./ likelihood.std1L) + (temporalPrior.mu1L ./ temporalPrior.std1L)) .* beliefs.std1L;
    beliefs.mu2L = ((likelihood.mu2L ./ likelihood.std2L) + (temporalPrior.mu2L ./ temporalPrior.std2L)) .* beliefs.std2L;
    beliefs.mu3L = ((likelihood.mu3L ./ likelihood.std3L) + (temporalPrior.mu3L ./ temporalPrior.std3L)) .* beliefs.std3L;

    if(isnan(likelihood.mu1L))
        beliefs.mu1L = temporalPrior.mu1L;
        beliefs.std1L = temporalPrior.std1L;
    end
    if(isnan(likelihood.mu2L))
        beliefs.mu2L = temporalPrior.mu2L;
        beliefs.std2L = temporalPrior.std2L;
    end
    if(isnan(likelihood.mu3L))
        beliefs.mu3L = temporalPrior.mu3L;
        beliefs.std3L = temporalPrior.std3L;
    end
    
    % elevation
    beliefs.std1E = 1 ./ ((1 ./ likelihood.std1E) + (1 ./ temporalPrior.std1E));
    beliefs.std2E = 1 ./ ((1 ./ likelihood.std2E) + (1 ./ temporalPrior.std2E));
    beliefs.std3E = 1 ./ ((1 ./ likelihood.std3E) + (1 ./ temporalPrior.std3E));

    beliefs.mu1E = ((likelihood.mu1E ./ likelihood.std1E) + (temporalPrior.mu1E ./ temporalPrior.std1E)) .* beliefs.std1E;
    beliefs.mu2E = ((likelihood.mu2E ./ likelihood.std2E) + (temporalPrior.mu2E ./ temporalPrior.std2E)) .* beliefs.std2E;
    beliefs.mu3E = ((likelihood.mu3E ./ likelihood.std3E) + (temporalPrior.mu3E ./ temporalPrior.std3E)) .* beliefs.std3E;

    if(isnan(beliefs.mu1E))
        if(~isnan(temporalPrior.mu1E))
            beliefs.mu1E = temporalPrior.mu1E;
            beliefs.std1E = temporalPrior.std1E;
        else
            if(~isnan(likelihood.mu1E))
                beliefs.mu1E = likelihood.mu1E;
                beliefs.std1E = likelihood.std1E;
            end        
        end
    end
    if(isnan(beliefs.mu2E))
        if(~isnan(temporalPrior.mu2E))
            beliefs.mu2E = temporalPrior.mu2E;
            beliefs.std2E = temporalPrior.std2E;
        else
            if(~isnan(likelihood.mu2E))
                beliefs.mu2E = likelihood.mu2E;
                beliefs.std2E = likelihood.std2E;
            end        
        end
    end
    if(isnan(beliefs.mu3E))
        if(~isnan(temporalPrior.mu3E))
            beliefs.mu3E = temporalPrior.mu3E;
            beliefs.std3E = temporalPrior.std3E;
        else
            if(~isnan(likelihood.mu3E))
                beliefs.mu3E = likelihood.mu3E;
                beliefs.std3E = likelihood.std3E;
            end        
        end
    end   
    
    
else
    % NonParametric product
    dest = kde(double(1 + (500-1).*rand(algoParam.OptionsKDE.nParticle .* 2,1))', 1);

    if(isfield(likelihood, 'kde1L'))
        beliefs.kde1L = productApprox(dest, {likelihood.kde1L, temporalPrior.kde1L},{},{},'exact');
    else beliefs.kde1L = temporalPrior.kde1L; end
                
    if(isfield(likelihood, 'kde2L'))
        beliefs.kde2L = productApprox(dest, {likelihood.kde2L, temporalPrior.kde2L},{},{},'exact');
    else beliefs.kde2L = temporalPrior.kde2L; end

    if(isfield(likelihood, 'kde3L'))
        beliefs.kde3L = productApprox(dest, {likelihood.kde3L, temporalPrior.kde3L},{},{},'exact');
    else beliefs.kde3L = temporalPrior.kde3L; end

    clear dest;
    dest = kde(double(0.5 + (50-0.5).*rand(algoParam.OptionsKDE.nParticle,1))', 1);    
    
    if(isfield(likelihood, 'kde1E'))
        beliefs.kde1E = productApprox(dest, {likelihood.kde1E, temporalPrior.kde1E},{},{},'exact');
    else beliefs.kde1E = temporalPrior.kde1E; end
    
    if(isfield(likelihood, 'kde2E'))
        beliefs.kde2E = productApprox(dest, {likelihood.kde2E, temporalPrior.kde2E},{},{},'exact');
    else beliefs.kde2E = temporalPrior.kde2E; end

    if(isfield(likelihood, 'kde3E'))
    beliefs.kde3E = productApprox(dest, {likelihood.kde3E, temporalPrior.kde3E},{},{},'exact');    
    else beliefs.kde3E = temporalPrior.kde3E; end
    
end
