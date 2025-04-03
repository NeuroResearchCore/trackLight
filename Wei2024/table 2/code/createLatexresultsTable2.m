function createLatexresultsTable2()

load('./step1Table2_latest.mat', 'rmse');

names = {'LSTM', 'Ridge Regression', 'Kernel Ridge Regression', 'Neural Network', 'Random Forests', 'SVM'};
order = [2 3 6 1 4 5];

for peak = 1:3    
    fid = fopen(sprintf('./resultsTable2P%d_latest.txt', peak),'wt');
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
            fprintf(fid, '\\gradient{%.2f}', rmse{j}(k,idx));
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
fid = fopen(sprintf('./resultsTable2all_latest.txt'),'wt');
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
        fprintf(fid, '\\gradient{%.2f}', (rmse{1}(k,idx)+rmse{2}(k,idx)+rmse{3}(k,idx))./3);
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