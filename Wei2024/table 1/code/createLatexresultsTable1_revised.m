function createLatexresultsTable1_revised()

load('./step1Table1_latest_mocaip.mat','rmse', 'avgRMSE');
rmseMOCAIP = rmse;
avgRMSEMOCAIP = avgRMSE;

load('../step1Table1_latest.mat', 'rmse', 'avgRMSE');

names = {'LSTM', 'Spectral Regression', 'Kernel Spectral Regression', 'Neural Network', 'Random Forests', 'SVM', 'MOCAIP'};
order = [2 3 6 1 4 5 7];

for peak = 1:3    
    fid = fopen(sprintf('./resultsTable1P%d_revised2.txt', peak),'wt');
    fprintf(fid, '\\resizebox{\\textwidth}{!}{%%\n');
    fprintf(fid, '\\begin{tabular}{ l P{2.5cm} P{2.5cm} P{2.5cm} P{2.5cm} } \n');
    fprintf(fid, '\\toprule \n');
    fprintf(fid, ' Peak %d & \\textbf{Noise 0$ \\%% $} & \\textbf{Noise 5$ \\%% $} & \\textbf{Noise 10$ \\%% $} & \\textbf{Noise 15$ \\%% $} \\\\ \n', peak);
    fprintf(fid, '\\midrule \n');
    
    for i=1:numel(names)
        idx = order(i);        
        fprintf(fid, '\\textbf{%s} & ', names{idx});
        j = peak;
        for k=1:4
            if(idx~=7)
                fprintf(fid, '\\gradient{%.2f}', rmse{j}(k,idx));
            else
                fprintf(fid, '\\gradient{%.2f}', rmseMOCAIP{j}(k,1));            
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
fid = fopen(sprintf('./resultsTable1all_revised2.txt'),'wt');
fprintf(fid, '\\resizebox{\\textwidth}{!}{%%\n');
fprintf(fid, '\\begin{tabular}{ l P{2.5cm} P{2.5cm} P{2.5cm} P{2.5cm} } \n');
fprintf(fid, '\\toprule \n');
fprintf(fid, ' All Peaks & \\textbf{Noise 0$ \\%% $} & \\textbf{Noise 5$ \\%% $} & \\textbf{Noise 10$ \\%% $} & \\textbf{Noise 15$ \\%% $} \\\\ \n');
fprintf(fid, '\\midrule \n');

for i=1:numel(names)
    idx = order(i);
    fprintf(fid, '\\textbf{%s} & ', names{idx});
%    j = peak;
    for k=1:4
        if(idx~=7)
            fprintf(fid, '\\gradient{%.2f}', avgRMSE(k,idx));
        else
            fprintf(fid, '\\gradient{%.2f}', avgRMSEMOCAIP(k,1));                        
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

% 
% 
% 
% %load('./step1Table1_latest.mat', 'SD', 'meanAbsErr');
% load('./step1Table1_latest.mat', 'rmse', 'avgRMSE');
% 
% names = {'LSTM', 'Ridge Regression', 'Kernel Ridge Regression', 'Neural Network', 'Random Forests', 'SVM'};
% order = [2 3 6 1 4 5];
% 
% % stdE{1} = SD{1};
% % stdE{2} = SD{2};
% % stdE{3} = SD{3};
% % rmse{1} = meanAbsErr{1};  
% % rmse{2} = meanAbsErr{2};
% % rmse{3} = meanAbsErr{3};
% 
% for peak = 1:3    
%     fid = fopen(sprintf('./resultsTable1_latestP%d.txt', peak),'wt');
%     fprintf(fid, '\\resizebox{\\textwidth}{!}{%%\n');
%     fprintf(fid, '\\begin{tabular}{ l p{2.5cm} p{2.5cm} p{2.5cm} p{2.5cm} } \n');
%     fprintf(fid, '\\toprule \n');
%     fprintf(fid, ' Peak %d & \\textbf{Noise 0$ \\%% $} & \\textbf{Noise 5$ \\%% $} & \\textbf{Noise 10$ \\%% $} & \\textbf{Noise 15$ \\%% $} \\\\ \n', peak);
%     fprintf(fid, '\\midrule \n');
%     
%     for i=1:numel(names)
%         idx = order(i);
%         fprintf(fid, '\\textbf{%s} & ', names{idx});
%         j = peak;
%         for k=1:4
% %            fprintf(fid, '\\gradient{%.1f} $ \\pm %.1f$ ', rmse{j}(k,idx), stdE{j}(k,idx));
%              fprintf(fid, '\\gradient{%.2f} ', rmse{j}(k,idx));
%             if(k~=4)
%                 fprintf(fid, ' & ');
%             end
%         end
%         fprintf(fid, '\\\\ \n');
%     end
%     fprintf(fid, '\\bottomrule \n');
%     fprintf(fid, '\\end{tabular} \n');
%     fprintf(fid, '}');
%     fclose(fid);
% end
% 
% % Avg
% fid = fopen(sprintf('./resultsTable1all_latest.txt'),'wt');
% fprintf(fid, '\\resizebox{\\textwidth}{!}{%%\n');
% fprintf(fid, '\\begin{tabular}{ l P{2.5cm} P{2.5cm} P{2.5cm} P{2.5cm} } \n');
% fprintf(fid, '\\toprule \n');
% fprintf(fid, ' All Peaks & \\textbf{Noise 0$ \\%% $} & \\textbf{Noise 5$ \\%% $} & \\textbf{Noise 10$ \\%% $} & \\textbf{Noise 15$ \\%% $} \\\\ \n');
% fprintf(fid, '\\midrule \n');
% 
% for i=1:numel(names)
%     idx = order(i);
%     fprintf(fid, '\\textbf{%s} & ', names{idx});
% %    j = peak;
%     for k=1:4
%         fprintf(fid, '\\gradient{%.2f} ', avgRMSE(k,idx));
%         if(k~=4)
%             fprintf(fid, ' & ');
%         end
%     end
%     fprintf(fid, '\\\\ \n');
% end
% fprintf(fid, '\\bottomrule \n');
% fprintf(fid, '\\end{tabular} \n');
% fprintf(fid, '}');
%     fclose(fid);
% 
