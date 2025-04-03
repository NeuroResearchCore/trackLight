function [p3, score] = Assign3P(peak, lt, pulseSmpLen, refP, funMetricCalc, ThresPEmpty)
% Assign candidate peaks to 3 peaks optimally based on a library of
% standard pulses.
% refP is a 4-D array with the last column indicating the
% length of the standard pulse, the position of whose three peaks are saved
% in the first three columns.
% funMetricCalc is a function pointer to the calculation function of
% probaility metrics
%
%
% Author: Xiao Hu Ph.D.

% Parametric method
%
if nargin < 6
    ThresPEmpty = 0.01;
end;

%save the original peak candidates
opeak = peak;

[peak, refP] = feval(funMetricCalc, peak, lt, pulseSmpLen, refP);

stdP = std(refP);
if size(refP, 1) > 1
    refP = mean(refP);
end;

for i=1:length(peak)
    p = repmat(peak(i), 1, 3);
    z(i,:) = (refP - p)./stdP;
    pvalue(i,:) = (1-normcdf(abs(z(i,:))))*2;
end;

if isempty(find(pvalue > ThresPEmpty))
    p3 = ones(1, 3) * NaN;
    score = NaN;
else
    pvalue(find(pvalue <= ThresPEmpty)) = 0;
    score = pvalue;
    cost = zeros(7, 1);

    % cost of having only one peak
    for i=1:3
        cost(i) = max(pvalue(:,i));
    end;

    %cost of having p1, p2
    kp = [1 2; 2 1];
    segp = NaN * ones(size(kp, 1), 3);
    for k=1:2
        pp = pvalue;
        acost(k) = 0;
        for i=1:2
            [kcost, idx] = max(pp(:,kp(k, i)));
            segp(k, kp(k, i)) = idx;
            acost(k) = acost(k) + kcost;
            if(i==1 & kp(i)==1)
                pp(1:idx,:) = 0;
            elseif(i==1 & kp(i)==2)
                pp(idx:end,:) = 0;
            end;
        end;
    end;
    [cost(4),selidx] = max(acost);
    optP{4}= segp(selidx,:);

    %cost of having p2, p3
    kp = [2 3; 3 2];
    segp = NaN * ones(size(kp, 1), 3);
    for k=1:2
        pp = pvalue;
        acost(k) = 0;
        for i=1:2
            [kcost, idx] = max(pp(:,kp(k,i)));
            segp(k, kp(k, i)) = idx;
            acost(k) = acost(k) + kcost;
            if(i==1 & kp(i)==2)
                pp(1:idx,:) = 0;
            elseif(i==1 & kp(i)==3)
                pp(idx:end,:) = 0;
            end;
        end;
    end;
    [cost(5),selidx] = max(acost);
    optP{5}= segp(selidx,:);


    %cost of having p1, p3
    kp = [1 3; 3 1];
    segp = NaN * ones(size(kp, 1), 3);
    for k=1:2
        pp = pvalue;
        acost(k) = 0;
        for i=1:2
            [kcost, idx] = max(pp(:,kp(k,i)));
            segp(k, kp(k, i)) = idx;
            acost(k) = acost(k) + kcost;
            if(i==1 & kp(i)==1)
                pp(1:idx,:) = 0;
            elseif(i==1 & kp(i)==3)
                pp(idx:end,:) = 0;
            end;
        end;
    end;
    [cost(6),selidx] = max(acost);
    optP{6}= segp(selidx,:);


    %cost of having p1, p2, p3
    %kp = [1 2 3; 1 3 2; 2 1 3; 3 2 1; 3 1 2];
    kp = [1 2 3; 1 3 2; 2 1 3; 2 3 1; 3 1 2; 3 2 1] ;
    segp = NaN * ones(size(kp, 1), 3);
    for k=1:size(kp, 1)
        acost(k) = 0;
        l = 1; % lower bound for locating the best assignment
        u = size(pp, 1); %upper bound for locating the best assignment
        for i=1:3
            if (l> u)
                segp(k, kp(k, i)) = NaN;
                break;
            else
                [kcost, idx] = max(pvalue(l:u,kp(k, i)));
                segp(k, kp(k, i)) = idx + l - 1;
                acost(k) = acost(k) + kcost;

                if i==3
                    break;
                end;
                kkp = kp(k, 1:i);
                if(isempty(find(kp(k, i + 1) > kkp)))
                    l = 1;
                else
                    l = 1+ segp(k, max(kkp(find(kp(k, i + 1) > kkp))));
                end;
                if(isempty(find(kp(k, i + 1) < kkp)))
                    u = size(pp,1);
                else
                    u = segp(k, min(kkp(find(kp(k, i + 1) < kkp)))) - 1;
                end;
            end;
        end;
    end;
    cost(7) = max(acost);
    [cost(7),selidx] = max(acost);
    optP{7}= segp(selidx,:);

    p3 = NaN * ones(1,3);
    [cost, pidx]= max(cost);
    if pidx<=3
        [t,p3(pidx)] = max(pvalue(:,pidx));
        p3(pidx) = opeak(p3(pidx));
    else
        idx = find(~isnan(optP{pidx}));
        p3(idx) = opeak(optP{pidx}(idx));
    end;
end;