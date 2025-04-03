function barPlotFigure()

load('./step1Table2_m.mat', 'meanAbsErr', 'noiseRate', 'norm', 'rmse');

cr = parula(12);
cr = flipud(cr);


% RMSE
figure;
entries = categorical({'LSTM', 'Ridge Regression', 'Kernel Ridge Regression', 'Neural Network', 'Random Forest', 'SVM'},...
{'LSTM', 'Ridge Regression', 'Kernel Ridge Regression', 'Neural Network', 'Random Forest', 'SVM'}),    
for peak=1:3
    subplot(1, 3, peak);
    title(sprintf('Peak %d', peak));
    b = bar(entries, cell2mat(rmse(peak))' * (norm.normFactY.maxValueY(peak)-norm.normFactY.minValueY(peak)), 'EdgeColor', 'none');
    title(sprintf('Peak %d', peak));

 %   lgb = legend('0', '5%', '10%', '15%', 'Location', 'eastoutside');
 %   title(lgb, 'Noise');
    ylabel('RMSE (ms)',  'FontSize', 18);
%    xlabel('Algorithm');
    
    set(gcf, 'color', 'w');
    set(gca, 'color', 'w');
    axis square;
    ax = gca;
    ax.YAxis.FontSize = 18;
    ax.XAxis.FontSize = 18;

    xtickangle(45);
    for k=1:4
        b(k).FaceColor = cr((k*3)-2,:);
    end
end
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
print('./Table2c_RMSE.png', '-painters', '-r300', '-dpng');
close;


figure;
cr = parula(12);
cr = flipud(cr);
for peak=1:3
    s = subplot(1, 3, peak);
    b = bar(categorical(100 .* noiseRate),  cell2mat(rmse(peak)) * (norm.normFactY.maxValueY(peak)-norm.normFactY.minValueY(peak)), 'EdgeColor', 'none'); 
    title(sprintf('Peak %d', peak));
    ylabel('RMSE (ms)', 'FontSize', 8);
    xlabel('Noise (%)', 'FontSize', 8);
    set(gcf, 'color', 'w');
    set(gca, 'color', 'w');
    ax = gca; 
    ax.FontSize = 6; 
    axis square;
    
    for k=1:6
        b(k).FaceColor = cr((k*2),:);
    end
end
print('./Table2b_RMSE.png', '-r300', '-dpng');
close;





figure;
entries = categorical({'LSTM', 'Ridge Regression', 'Kernel Ridge Regression', 'Neural Network', 'Random Forest', 'SVM'},...
{'LSTM', 'Ridge Regression', 'Kernel Ridge Regression', 'Neural Network', 'Random Forest', 'SVM'}),    
for peak=1:3
    subplot(1, 3, peak);
    title(sprintf('Peak %d', peak));
    b = bar(entries, cell2mat(meanAbsErr(peak))' * (norm.normFactY.maxValueY(peak)-norm.normFactY.minValueY(peak)), 'EdgeColor', 'none');
 %   lgb = legend('0', '5%', '10%', '15%', 'Location', 'eastoutside');
 %   title(lgb, 'Noise');
    ylabel('MAE (ms)',  'FontSize', 18);
%    xlabel('Algorithm');
    
    set(gcf, 'color', 'w');
    set(gca, 'color', 'w');
    axis square;
    ax = gca;
    ax.YAxis.FontSize = 18;
    ax.XAxis.FontSize = 18;

    xtickangle(45);
    for k=1:4
        b(k).FaceColor = cr((k*3)-2,:);
    end
end
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
print('./Table2c.png', '-painters', '-r300', '-dpng');
close;

figure;
b = bar(entries, cell2mat(meanAbsErr(peak))' * (norm.normFactY.maxValueY(peak)-norm.normFactY.minValueY(peak)), 'EdgeColor', 'none');
for k=1:4
    b(k).FaceColor = cr((k*3)-2,:);
end
hl = legend('0', '5%', '10%', '15%', 'Location', 'eastoutside');
title(hl, 'Noise');
set(gcf,'Position',(get(hl,'Position')...
    .*[0, 0, 1, 1].*get(gcf,'Position')));
% The legend is still offset so set its normalized position vector to
% fill the figure
set(hl,'Position',[0,0,1,1]);
% Put the figure back in the middle screen area
set(gcf, 'Position', get(gcf,'Position') + [500, 400, 0, 0]);
print('./Legend2c.png', '-r300', '-dpng');
close;
g=1;





for peak=1:3
    subplot(1, 3, peak); hold on;
    p = plot(categorical(100 .* noiseRate),  cell2mat(meanAbsErr(peak)) * (norm.normFactY.maxValueY(peak)-norm.normFactY.minValueY(peak)), 'o-', 'lineWidth', 2);
    for k=1:6
        p(k).Color = cr((k*2),:);
        p(k).MarkerFaceColor = cr((k*2),:);
    end
end
print('./Table2a.png', '-r300', '-dpng');
close;


figure;
cr = parula(12);
cr = flipud(cr);
for peak=1:3
    s = subplot(1, 3, peak);
    b = bar(categorical(100 .* noiseRate),  cell2mat(meanAbsErr(peak)) * (norm.normFactY.maxValueY(peak)-norm.normFactY.minValueY(peak)), 'EdgeColor', 'none'); 
    title(sprintf('Peak %d', peak));
    ylabel('MAE (ms)', 'FontSize', 8);
    xlabel('Noise (%)', 'FontSize', 8);
    set(gcf, 'color', 'w');
    set(gca, 'color', 'w');
    ax = gca; 
    ax.FontSize = 6; 
    axis square;
    
    for k=1:6
        b(k).FaceColor = cr((k*2),:);
    end
end
print('./Table2b.png', '-r300', '-dpng');
close;

% legend
figure;
set(gcf,'Position',[0,0,1024,1024]);
c = bar(categorical(100 .* noiseRate),  cell2mat(meanAbsErr(1)) * (norm.normFactY.maxValueY(1)-norm.normFactY.minValueY(1)), 'EdgeColor', 'none');
for k=1:6
    c(k).FaceColor = cr((k*2),:);
end
axis off;
hl = legend(c, 'LSTM', 'Ridge Regression', 'Kernel Ridge Regression', 'Neural Network', 'Random Forest', 'SVM');
title(hl,  'Algorithm');
%newPosition = [0 0 1 1];
%set(hl,'Position', newPosition, 'Units', 'normalized');
set(gcf,'Position',(get(hl,'Position')...
    .*[0, 0, 1, 1].*get(gcf,'Position')));
% The legend is still offset so set its normalized position vector to
% fill the figure
set(hl,'Position',[0,0,1,1]);
% Put the figure back in the middle screen area
set(gcf, 'Position', get(gcf,'Position') + [500, 400, 0, 0]);
print('./legendTable2.png', '-r300', '-dpng');
close;





