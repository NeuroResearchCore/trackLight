function  peak = Mark3P_Original(clusterRe, iValidIndex, fs, AlgoParam)

if nargin < 2
    iValidIndex = ones(length(clusterRe),1);
end
if nargin < 3
    fs = 400;
end
if nargin < 4
    AlgoParam = GetDefaultMOCAIPParam();
end
warning off;

%--------------------------------------------------------------------------
% Load the Models or reference library
%--------------------------------------------------------------------------
[stdVV, peakLib, funcStr] = LoadPulseLib('PulseLib.mat', fs);
%         [stdVV, peakLib, funcStr] = LoadPulseLib('PulseLibraryCBFV.mat', fs, patID);
if(strcmpi(func2str(AlgoParam.fnOnsetDetect), funcStr)~=1)
    for i=1:length(stdVV)
        [tmp, maxPos] = max(stdVV{i});
        peakLib(i, 5) = feval(AlgoParam.fnOnsetDetect, stdVV{i}(1:maxPos), fs);
    end;
end;
if(isfield(AlgoParam, 'priorP3'))
    if(~isempty(AlgoParam.priorP3))
        for i=1:3
            peakLib(:, i) =  peakLib(:, i) + AlgoParam.priorP3(i) - mean(peakLib(:, i));
        end;                
        %correct LT as well
        peakLib(:, 5) =  peakLib(:, 5) + AlgoParam.priorP3(4) - mean(peakLib(:, 5));
    end;
end;

%--------------------------------------------------------------------------
% Assign the 3 Peaks among peak candidates
%--------------------------------------------------------------------------
peak = NaN(size(clusterRe,1), 3);
iProcessed = 0;
onset = NaN(size(clusterRe,1), 1);
for j=1:size(clusterRe,1)    
%        [dr, dv] = FindDominantPulse(clusterRe{j});
        dv = clusterRe(j,:);
        [p3, bShoulder, amp, curvs, siz] = Detect3P(dv, AlgoParam.P3Proc, fs);
        if(isempty(p3))
            continue;
        end;
        [maxv, maxpos] = max(dv);
        if (maxpos == 1)
            continue;
        end;
        iProcessed = iProcessed + 1;                
        onset(j) = feval(AlgoParam.fnOnsetDetect, dv, fs);
        if (AlgoParam.ThresPEmptyGlobal~=-1)
            if ( AlgoParam.iAdaptBeatNumber > 0)
                if ( rem(iProcessed,  AlgoParam.iAdaptBeatNumber) == 0)
                    for kkk = 1:3
                        medianP = fix(nanmedian(peak(j-AlgoParam.iAdaptBeatNumber+1:j-1, kkk)));
                        if (~isnan(medianP))
                            peakLib(:, kkk) =  peakLib(:, kkk) + medianP - mean(peakLib(:, kkk));
                        end;
                    end;
                    %correct LT as well
                    medianOnset =  fix(nanmedian(onset(j-AlgoParam.iAdaptBeatNumber+1:j-1)));
                    peakLib(:, 5) =  peakLib(:, 5) + medianOnset - mean(peakLib(:, 5));
                end;
                aOnset =  fix(nanmedian(onset(max(1,j-AlgoParam.iOnsetWin):j)));
                peak(j, :) = Assign3P(p3,  aOnset,  length(dv), peakLib, AlgoParam.MetricProc, AlgoParam.ThresPEmptyGlobal);
            else
                peak(j, :) = Assign3P(p3,  onset(j),  length(dv), peakLib, AlgoParam.MetricProc, AlgoParam.ThresPEmptyGlobal);
            end;
        else
            peak(j, :) = feval(AlgoParam.LogicProc, p3, bShoulder, amp, curvs, siz);
        end
end

end