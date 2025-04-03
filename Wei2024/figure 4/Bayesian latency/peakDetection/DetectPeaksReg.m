function [p3] = DetectPeaksReg(pulseIn, fs, model, len, predictor, options, display)
%  DetectPeaksReg detects the peaks using regression model.
%
%      o <pulseIn>    -- ICP pulse 
%      o <fs>         -- frequency rate
%      o <model>      -- regression model
%      o <len>        -- length of the pulses
%      o <predictor>  -- regression function 
%      o <options>    -- options used for regression by <predictor>
%      o <display>    -- to display the pulse and the position of the peaks
%
% OUTPUT:
%
%      o <p3>    -- position of the peaks (p1, p2, p3)
%
% Reference: "Bayesian tracking of intracranial pressure signal morphology" 
% Scalzo et al. Artif Intell Med. 2012 Feb;54(2):115-23.   
%
%==========================================================================
%   version 1.0 -- 10/2017 -- Fabien Scalzo, PhD 
%
if nargin < 7
    display = 0;
end

fact = fs/400;

% resample
if(fs ~= 400)
    x = 1:size(pulseIn,1); 
    xi = 1:fact:size(pulseIn,1); 
    pulseIn = interp1(x, pulseIn, xi, 'cubic')';
end

dataTest.X = zeros(1,len);

% resize the pulse to the mean lenght
if(size(pulseIn,1) <= len)
    % replicate the last value 
    dataTest.X(1:size(pulseIn,1)) = pulseIn(1:size(pulseIn,1));
    dataTest.X(size(pulseIn,1):len) =  pulseIn(size(pulseIn,1));              
else
    dataTest.X(1:len) = pulseIn(1:len);
end    

% normalize the pulse 
minw = min(dataTest.X');   
dataTest.X = dataTest.X - minw;    
maxw = max(dataTest.X);
dataTest.X = dataTest.X/maxw;   

% Predict the value using the regression model 
[p3] = feval(predictor, dataTest, model, options);
p3 = p3 * fact;

if(display == 1) 
    plot( dataTest.X ); hold on;
    plot( p3(1),   dataTest.X(round(p3(1))),'kx', 'MarkerSize',10, 'LineWidth',2);
    plot( p3(2),   dataTest.X(round(p3(2))),'kx', 'MarkerSize',10, 'LineWidth',2);
    plot( p3(3),   dataTest.X(round(p3(3))),'kx', 'MarkerSize',10, 'LineWidth',2);
end