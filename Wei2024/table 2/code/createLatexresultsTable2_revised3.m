function createLatexresultsTable2_revised3()

load('D:\Fabien\paperMiaomiaoLatest\allfigures\figures\common\rmse_Latency_BayesianTracking2.mat');
load('D:\Fabien\paperMiaomiaoLatest\allfigures\figures\common\rmse_Latency_Kalman2.mat');
load('D:\Fabien\paperMiaomiaoLatest\allfigures\figures\common\rmse_Latency_LSTM2.mat');
load('D:\Fabien\paperMiaomiaoLatest\allfigures\figures\common\rmse_Latency_MOCAIP2.mat');

%names = {'LSTM (Tracking)', 'Bayesian Tracking', 'Kalman Filtering', 'MOCAIP (Tracking)'};
%rmsetracking = [rmseLSTM  rmseBayesianTracking rmseKalman rmseMOCAIP];
rmseMOCAIPTracking = rmseMOCAIP;

load('./step1Table2_mocaip.mat',  'rmse');
rmseMOCAIP = rmse;

load('./step1Table2_latest.mat', 'rmse');
%rmse = [rmse rmseMOCAIP];


% rmse = rmse .* 50;
% rmseMOCAIP = rmseMOCAIP .* 50;
% rmseLSTM = rmseLSTM .* 50;
% rmseBayesianTracking = rmseBayesianTracking .* 50;
% rmseKalman = rmseKalman .* 50;
% rmseMOCAIPTracking = rmseMOCAIPTracking .* 50;

names = {'LSTM', 'Spectral Regression', 'Kernel Spectral Regression', 'Neural Network', 'Random Forests', 'SVM', 'MOCAIP', 'LSTM', 'Bayesian', 'Kalman Filter', 'MOCAIP'};
order = [2 3 6 1 4 5 7 8 9 10 11];

for peak = 1:3    
    fid = fopen(sprintf('D:/Fabien/paperMiaomiaoLatest/allfigures/figures/common/resultsTable2P%d_revised3.txt', peak),'wt');
    fprintf(fid, '\\resizebox{\\textwidth}{!}{%%\n');
    fprintf(fid, '\\begin{tabular}{c | l P{2.5cm} P{2.5cm} P{2.5cm} P{2.5cm} } \n');
    fprintf(fid, '\\toprule \n');
    fprintf(fid, '\\multicolumn{2}{l}{Peak %d} & \\textbf{Noise 0$ \\%% $} & \\textbf{Noise 5$ \\%% $} & \\textbf{Noise 10$ \\%% $} & \\textbf{Noise 15$ \\%% $} \\\\ \n', peak);
    fprintf(fid, '\\midrule \n');
        
    for i=1:numel(names)
        idx = order(i);

        if(idx ==8)
            fprintf(fid, '\\hline \n');
        end
 
        if(i==1)
            fprintf(fid, '\\multirow{7}{*}{\\STAB{\\rotatebox[origin=c]{90}{Single Waveform}}} &');       
        elseif(i==8)
            fprintf(fid, '\\multirow{4}{*}{\\STAB{\\rotatebox[origin=c]{90}{Tracking}}} &');       
        else
            fprintf(fid, ' & ');
        end
 
        fprintf(fid, '\\textbf{%s} & ', names{idx});
        j = peak;
        for k=1:4

            if(idx<7)
                fprintf(fid, '\\gradient{%.1f}', 50. * rmse{j}(k,idx));
            end
            if(idx == 7)    
                fprintf(fid, '\\gradient{%.1f}', 50. * rmseMOCAIP{j}(k,1));
            end
            if(idx == 8)
                fprintf(fid, '\\gradient{%.1f}', 50. * rmseLSTM(peak,k));
            end
            if(idx == 9)
                fprintf(fid, '\\gradient{%.1f}', 50. * rmseBayesianTracking(peak,k));
            end
            if(idx == 10)
                fprintf(fid, '\\gradient{%.1f}', 50. * rmseKalman(peak,k));
            end
            if(idx == 11)
                fprintf(fid, '\\gradient{%.1f}', 50. * rmseMOCAIPTracking(peak,k));
            end

            if(k~=4)
                fprintf(fid, ' & ');
            end
        end
        fprintf(fid, '\\\\ \n');
    end
    fprintf(fid, '\\bottomrule \n');
    fprintf(fid, '\\end{tabular} \n');
    fprintf(fid, '}');
    fclose(fid);
end

% Avg
fid = fopen(sprintf('D:/Fabien/paperMiaomiaoLatest/allfigures/figures/common/resultsTable2all_revised3.txt'),'wt');
fprintf(fid, '\\resizebox{\\textwidth}{!}{%%\n');
fprintf(fid, '\\begin{tabular}{ c | l P{2.5cm} P{2.5cm} P{2.5cm} P{2.5cm} } \n');
fprintf(fid, '\\toprule \n');
fprintf(fid, '\\multicolumn{2}{l}{All Peaks} & \\textbf{Noise 0$ \\%% $} & \\textbf{Noise 5$ \\%% $} & \\textbf{Noise 10$ \\%% $} & \\textbf{Noise 15$ \\%% $} \\\\ \n');
fprintf(fid, '\\midrule \n');

for i=1:numel(names)
    idx = order(i);

    if(idx ==8)
        fprintf(fid, '\\hline \n');
    end

    if(i==1)
        fprintf(fid, '\\multirow{7}{*}{\\STAB{\\rotatebox[origin=c]{90}{Single Waveform}}} &');
    elseif(i==8)
        fprintf(fid, '\\multirow{4}{*}{\\STAB{\\rotatebox[origin=c]{90}{Tracking}}} &');
    else
        fprintf(fid, ' & ');
    end

    fprintf(fid, '\\textbf{%s} & ', names{idx});
    for k=1:4
        if(idx<7)
            fprintf(fid, '\\gradient{%.1f}', 50. *  (rmse{1}(k,idx)+rmse{2}(k,idx)+rmse{3}(k,idx))./3);    
        end
        if(idx==7)
            fprintf(fid, '\\gradient{%.1f}', 50. *  (rmseMOCAIP{1}(k,1)+rmseMOCAIP{2}(k,1)+rmseMOCAIP{3}(k,1))./3);            
        end
        if(idx==8)
            fprintf(fid, '\\gradient{%.1f}', 50. * (rmseLSTM(1,k)+rmseLSTM(2,k)+rmseLSTM(3,k))./3);            
        end
        if(idx==9)
            fprintf(fid, '\\gradient{%.1f}', 50. *  (rmseBayesianTracking(1,k)+rmseBayesianTracking(2,k)+rmseBayesianTracking(3,k))./3);                    
        end
        if(idx==10)
                fprintf(fid, '\\gradient{%.1f}', 50. *  (rmseKalman(1,k)+rmseKalman(2,k)+rmseKalman(3,k))./3);                                 
        end
        if(idx==11)
            fprintf(fid, '\\gradient{%.1f}', 50. *  (rmseMOCAIPTracking(1,k)+rmseMOCAIPTracking(2,k)+rmseMOCAIPTracking(3,k))./3);           
        end
            
        if(k~=4)
            fprintf(fid, ' & ');
        end
    end
    fprintf(fid, '\\\\ \n');
end
fprintf(fid, '\\bottomrule \n');
fprintf(fid, '\\end{tabular} \n');
fprintf(fid, '}');
    fclose(fid);





% \resizebox{\textwidth}{!}{%
% \begin{tabular}{ c | l P{2.5cm} P{2.5cm} P{2.5cm} P{2.5cm} } 
% \toprule 
%  \multicolumn{2}{l}{Peak 1} & \textbf{Noise 0$ \% $} & \textbf{Noise 5$ \% $} & \textbf{Noise 10$ \% $} & \textbf{Noise 15$ \% $} \\ 
% \midrule 
%  \multirow{7}{*}{\STAB{\rotatebox[origin=c]{90}{Single Waveform}}} & \textbf{Ridge Regression} & \gradient{0.25} & \gradient{0.35} & \gradient{0.47} & \gradient{0.61}\\ 
%  & \textbf{Kernel Ridge Regression} & \gradient{0.25} & \gradient{0.26} & \gradient{0.28} & \gradient{0.32}\\ 
% & \textbf{SVM} & \gradient{0.26} & \gradient{0.23} & \gradient{0.26} & \gradient{0.33}\\ 
% & \textbf{LSTM (single waveform)} & \gradient{0.27} & \gradient{0.27} & \gradient{0.27} & \gradient{0.27}\\ 
% & \textbf{Neural Network} & \gradient{0.22} & \gradient{0.33} & \gradient{0.33} & \gradient{0.33}\\ 
% & \textbf{Random Forests} & \gradient{0.27} & \gradient{0.28} & \gradient{0.28} & \gradient{0.28}\\ 
% & \textbf{MOCAIP (single waveform)} & \gradient{0.09} & \gradient{0.82} & \gradient{0.73} & \gradient{0.69}\\ 
% \hline 
% \multirow{4}{*}{\STAB{\rotatebox[origin=c]{90}{Tracking}}} & \textbf{LSTM (Tracking)} & \gradient{0.02} & \gradient{0.02} & \gradient{0.03} & \gradient{0.04}\\ 
% & \textbf{Bayesian Tracking} & \gradient{0.03} & \gradient{0.03} & \gradient{0.04} & \gradient{0.05}\\ 
% & \textbf{Kalman Filter} & \gradient{0.00} & \gradient{0.03} & \gradient{0.05} & \gradient{0.07}\\ 
% & \textbf{MOCAIP (Tracking)} & \gradient{0.04} & \gradient{0.04} & \gradient{0.06} & \gradient{0.07}\\ 
% \bottomrule 
% \end{tabular} 
% }
