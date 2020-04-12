clc; close all; clear all;
%%%
%% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 15);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["ID", "eName", "Gender", "Age", "Country", "fGenre", "CurrentOdour", "ShapeScore", "Colour", "Texture", "Emotion", "Pleasentness", "Pitch", "PickedGenre", "Guess"];
opts.VariableTypes = ["categorical", "categorical", "categorical", "double", "categorical", "categorical", "categorical", "double", "string", "double", "categorical", "double", "double", "categorical", "categorical"];

% Specify file level properties
opts.ImportErrorRule = "omitrow";
opts.MissingRule = "omitrow";
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read"; 

% Specify variable properties
% opts = setvaropts(opts, "Colour", "WhitespaceRule", "preserve");
% opts = setvaropts(opts, ["ID", "eName", "Gender", "Country", "fGenre", "CurrentOdour", "Colour", "Emotion", "PickedGenre", "Guess"], "EmptyFieldRule", "auto");

% Import the data
results = readtable("results-anom.txt", opts);

% Remove the first 8 partisipants as the have so pitch scores and therefore inconsistent
results(1:80, :) = [];

% Clear temporary variables
clear opts
load('noPitch.mat');
%% Varible Init
odours = string(table2array(unique(results(:, 7))));
shapeScores = zeros(size(results, 1) / 10, 10);
textureScores = zeros(size(results, 1) / 10, 10);
pleasentnessScores = zeros(size(results, 1) / 10, 10);
pitchScores = zeros(size(results, 1) / 10, 10);
guess = strings(size(results, 1) / 10, 10);
genre = strings(size(results, 1) / 10, 10);
emotions = strings(size(results, 1) / 10, 10);
colours = strings(size(results, 1) / 10, 10);
achual = strings(size(results, 1) / 10, 10);
gender = strings(size(results, 1) / 10, 10);
age = zeros(size(results, 1) / 10, 10);

for i = 1:10
    shapeScores(:, i) = table2array(results(strcmp(string(table2array(results(:, 7))), odours(i)), 8));
    textureScores(:, i) = table2array(results(strcmp(string(table2array(results(:, 7))), odours(i)), 10));
    pleasentnessScores(:, i) = table2array(results(strcmp(string(table2array(results(:, 7))), odours(i)), 12));
    pitchScores(:, i) = table2array(results(strcmp(string(table2array(results(:, 7))), odours(i)), 13));
    guess(:, i) = table2array(results(strcmp(string(table2array(results(:, 7))), odours(i)), 15));
    genre(:, i) = table2array(results(strcmp(string(table2array(results(:, 7))), odours(i)), 14));
    emotions(:, i) = table2array(results(strcmp(string(table2array(results(:, 7))), odours(i)), 11));
    colours(:, i) = table2array(results(strcmp(string(table2array(results(:, 7))), odours(i)), 9));
    gender(:, i) = table2array(results(strcmp(string(table2array(results(:, 7))), odours(i)), 3));
    age(:, i) = table2array(results(strcmp(string(table2array(results(:, 7))), odours(i)), 4));
    achual(:, i) = table2array(results(strcmp(string(table2array(results(:, 7))), odours(i)), 7));
end

age = vertcat(age, age2);
age = age';

meanAge = mean(age(1,:));
stdAge = std(age(1,:));

gender = vertcat(gender, gender2);
gender = gender';
numMale = sum(strcmp(gender(1, :), 'Male'));
numFemale = sum(strcmp(gender(1, :), 'Female')) ;

markers = strings(11, 1);
markers(1) = '+';
markers(2) = 'o';
markers(3) = 'h';
markers(4) = 'x';
markers(5) = 's';
markers(6) = 'd';
markers(7) = '^';
markers(8) = 'v';
markers(9) = '<';
markers(10) = '>';
markers(11) = '*';

correct = strcmp(vertcat(guess, guess2), repmat(odours', size(vertcat(guess, guess2), 1), 1));
agecp = corr(age(1,:)', mean(correct, 2));

shapeScoreCorrect = vertcat(shapeScores, shapeScores2);
textureScoreCorrect = vertcat(textureScores, textureScores2);
pleasentnessScoreCorrect = vertcat(pleasentnessScores, pleasentnessScores2);
pitchScoreCorrect = pitchScores;

%% Shape Graph
[shapeScores, mu, sigma] = zscore(vertcat(shapeScores, shapeScores2), 0, 'all');
shapeScoresMean = mean(shapeScores);
[vals, order] = sort(shapeScoresMean);
[p, tbl, stats] = friedman(shapeScores);

fprintf('Shape P = %.20f \n', p);
[c,m,h,gnames] = multcompare(stats, 'Alpha', 0.05, 'CType', 'bonferroni');

h = figure; hold on;
for i = 1:10
    b = bar(i, vals(i));
    set(b, 'FaceColor', [1, 1, 1], 'lineWidth', 3);
end
plot([0.5, 10.5], [0, 0], 'k', 'LineWidth', 2);
ci = (tinv(0.05, size(shapeScores,1)-1))*(std(shapeScores) / sqrt(length(shapeScores)));

% sig = not(shapeScoresMean + abs(ci) > 0 & shapeScoresMean - abs(ci) < 0);
er = errorbar(1:10, vals, ci(order));
% se = std(shapeScores) / sqrt(length(shapeScores));
% er = errorbar(1:10, vals, se(order));
er.Color = [1 0 0];                            
er.LineStyle = 'none'; 
er.CapSize = 15;
er.LineWidth = 3;

t = [c(c(:, end) < 0.05, 1), c(c(:, end) < 0.05, 2)];
t = vertcat(t, [c(c(:, end) < 0.05, 2), c(c(:, end) < 0.05, 1)]);

y = 1:10;

counter = ones(10, 1)*0.3;
counter(vals-mean(shapeScoresMean)>0) = -counter(vals-mean(shapeScoresMean)>0);

nOrder = odours(order);
% Plot all odour comparison markers
for i = 1:size(t, 1)
    plot(find(strcmp(nOrder, odours(t(i, 2)))), 0+counter(find(strcmp(nOrder, odours(t(i, 2))))), 'k', 'Marker', ...
        markers(find(strcmp(nOrder, odours(t(i, 1))))), 'MarkerSize', 6, 'LineWidth',1.2);
%     
    if vals(find(strcmp(nOrder, odours(t(i, 2)))))-mean(shapeScoresMean) > 0
        counter(find(strcmp(nOrder, odours(t(i, 2))))) = counter(find(strcmp(nOrder, odours(t(i, 2))))) - 0.15;
    else
        counter(find(strcmp(nOrder, odours(t(i, 2))))) = counter(find(strcmp(nOrder, odours(t(i, 2))))) + 0.15;
    end
end
% ttest for scales grand mean
[t2, p, ci, stat] = ttest(shapeScores, 0, 'Tail', 'Both', 'Alpha', 0.005);

diff = t2(order) == 1;
plot(y(diff), 0+counter(diff), 'k.', 'Marker', markers(11), 'MarkerSize', 6, 'LineWidth',1.2);

y = linspace(1, 9, 9);

xlim([0.5, 10.5]);
% ylim([min(y-mean(shapeScoresMean)), max(y-mean(shapeScoresMean))]);
title('Angularity Scores');

for i = 1:10
    LH(i) = plot(nan, nan, 'k.', 'Marker', markers(i), 'MarkerSize', 6, 'LineWidth',1.2);
    L{i} = odours(order(i));
end

t = strsplit(string((L(7))), ' ');
L(7) = cellstr(([char(t(1)), newline, char(t(2)), ' ', char(t(3))]));
t = strsplit(string((L(6))), ' ');
L(6) = cellstr(([char(t(1)), newline, char(t(2))]));

legend(LH, L, 'FontSize', 10, 'location','eastoutside');

set(gca, 'FontName', 'Helvetica', 'FontSize', 15, 'FontWeight', 'Bold', ...
    'XTick', 1:10, 'XTickLabels', odours(order), 'XTickLabelRotation', 50, ...
    'XColor', [0, 0, 0], 'YColor', [0, 0, 0]);


%% Texture Graph
[textureScores, mu, sigma] = zscore(vertcat(textureScores, textureScores2), 0, 'all');
textureScoresMean = mean(textureScores);
[vals, order] = sort(textureScoresMean);
[p, tbl, stats] = friedman(textureScores);

fprintf('Texture P = %.20f \n', p);
[c,m,h,gnames] = multcompare(stats, 'Alpha', 0.05, 'CType', 'bonferroni');

h = figure; hold on;
for i = 1:10
    b = bar(i, vals(i));
    set(b, 'FaceColor', [1, 1, 1], 'LineWidth', 2);
end
plot([0.5, 10.5], [0, 0], 'k', 'LineWidth', 2);
ci = (tinv(0.05, size(textureScores,1)-1))*(std(textureScores) / sqrt(length(textureScores)));

% sig = not(shapeScoresMean + abs(ci) > 0 & shapeScoresMean - abs(ci) < 0);
er = errorbar(1:10, vals, ci(order));
% se = std(shapeScores) / sqrt(length(shapeScores));
% er = errorbar(1:10, vals, se(order));
er.Color = [1 0 0];                            
er.LineStyle = 'none'; 
er.CapSize = 15;
er.LineWidth = 3;

t = [c(c(:, end) < 0.05, 1), c(c(:, end) < 0.05, 2)];
t = vertcat(t, [c(c(:, end) < 0.05, 2), c(c(:, end) < 0.05, 1)]);

y = 1:10;

counter = ones(10, 1)*0.3;
counter(vals-mean(textureScoresMean)>0) = -counter(vals-mean(textureScoresMean)>0);

nOrder = odours(order);
% Plot all odour comparison markers
for i = 1:size(t, 1)
    plot(find(strcmp(nOrder, odours(t(i, 2)))), 0+counter(find(strcmp(nOrder, odours(t(i, 2))))), 'k', 'Marker', ...
        markers(find(strcmp(nOrder, odours(t(i, 1))))), 'MarkerSize', 6, 'LineWidth',1.2);
%     
    if vals(find(strcmp(nOrder, odours(t(i, 2)))))-mean(shapeScoresMean) > 0
        counter(find(strcmp(nOrder, odours(t(i, 2))))) = counter(find(strcmp(nOrder, odours(t(i, 2))))) - 0.15;
    else
        counter(find(strcmp(nOrder, odours(t(i, 2))))) = counter(find(strcmp(nOrder, odours(t(i, 2))))) + 0.15;
    end
end
% ttest for scales grand mean
[t2, p, ci, stat] = ttest(textureScores, 0, 'Tail', 'Both', 'Alpha', 0.005);

diff = t2(order) == 1;
plot(y(diff), 0+counter(diff), 'k.', 'Marker', markers(11), 'MarkerSize', 6, 'LineWidth',1.2);

y = linspace(1, 9, 9);

xlim([0.5, 10.5]);
% ylim([min(y-mean(shapeScoresMean)), max(y-mean(shapeScoresMean))]);
title('Texture Scores');

for i = 1:10
    LH(i) = plot(nan, nan, 'k.', 'Marker', markers(i), 'MarkerSize', 6, 'LineWidth',1.2);
    L{i} = odours(order(i));
end

t = strsplit(string((L(5))), ' ');
L(5) = cellstr(([char(t(1)), newline, char(t(2)), ' ', char(t(3))]));
t = strsplit(string((L(1))), ' ');
L(1) = cellstr(([char(t(1)), newline, char(t(2))]));

legend(LH, L, 'FontSize', 10, 'location','eastoutside');

set(gca, 'FontName', 'Helvetica', 'FontSize', 15, 'FontWeight', 'Bold', ...
    'XTick', 1:10, 'XTickLabels', odours(order), 'XTickLabelRotation', 50, ...
    'XColor', [0, 0, 0], 'YColor', [0, 0, 0]);

y2 = get(gca, 'YTickLabels');
y2(end) = {['Smooth ', char(y2(end))]};
y2(1) = {['Rough ', char(y2(1))]};
set(gca, 'YTicklabels', y2);
%% Pleasentness Graph
[pleasentnessScores, mu, sigma] = zscore(vertcat(pleasentnessScores, pleasentnessScores2), 0, 'all');
pleasentnessScoresMean = mean(pleasentnessScores);
[vals, order] = sort(pleasentnessScoresMean);
[p, tbl, stats] = friedman(pleasentnessScores);

fprintf('pleasentness P = %.20f \n', p);
[c,m,h,gnames] = multcompare(stats, 'Alpha', 0.05, 'CType', 'bonferroni');

h = figure; hold on;
for i = 1:10
    b = bar(i, vals(i));
    set(b, 'FaceColor', [1, 1, 1], 'LineWidth', 2);
end
plot([0.5, 10.5], [0, 0], 'k', 'LineWidth', 2);
ci = (tinv(0.05, size(pleasentnessScores,1)-1))*(std(pleasentnessScores) / sqrt(length(pleasentnessScores)));

% sig = not(shapeScoresMean + abs(ci) > 0 & shapeScoresMean - abs(ci) < 0);
er = errorbar(1:10, vals, ci(order));
% se = std(shapeScores) / sqrt(length(shapeScores));
% er = errorbar(1:10, vals, se(order));
er.Color = [1 0 0];                            
er.LineStyle = 'none'; 
er.CapSize = 15;
er.LineWidth = 3;

t = [c(c(:, end) < 0.05, 1), c(c(:, end) < 0.05, 2)];
t = vertcat(t, [c(c(:, end) < 0.05, 2), c(c(:, end) < 0.05, 1)]);

y = 1:10;

counter = ones(10, 1)*0.3;
counter(vals-mean(pleasentnessScoresMean)>0) = -counter(vals-mean(pleasentnessScoresMean)>0);

nOrder = odours(order);
% Plot all odour comparison markers
for i = 1:size(t, 1)
    plot(find(strcmp(nOrder, odours(t(i, 2)))), 0+counter(find(strcmp(nOrder, odours(t(i, 2))))), 'k', 'Marker', ...
        markers(find(strcmp(nOrder, odours(t(i, 1))))), 'MarkerSize', 6, 'LineWidth',1.2);
%     
    if vals(find(strcmp(nOrder, odours(t(i, 2)))))-mean(shapeScoresMean) > 0
        counter(find(strcmp(nOrder, odours(t(i, 2))))) = counter(find(strcmp(nOrder, odours(t(i, 2))))) - 0.15;
    else
        counter(find(strcmp(nOrder, odours(t(i, 2))))) = counter(find(strcmp(nOrder, odours(t(i, 2))))) + 0.15;
    end
end
% ttest for scales grand mean
[t2, p, ci, stat] = ttest(pleasentnessScores, 0, 'Tail', 'Both', 'Alpha', 0.005);

diff = t2(order) == 1;
plot(y(diff), 0+counter(diff), 'k.', 'Marker', markers(11), 'MarkerSize', 6, 'LineWidth',1.2);

y = linspace(1, 9, 9);

xlim([0.5, 10.5]);
% ylim([min(y-mean(shapeScoresMean)), max(y-mean(shapeScoresMean))]);
title('Pleasentness Scores');

for i = 1:10
    LH(i) = plot(nan, nan, 'k.', 'Marker', markers(i), 'MarkerSize', 6, 'LineWidth',1.2);
    L{i} = odours(order(i));
end

t = strsplit(string((L(4))), ' ');
L(4) = cellstr(([char(t(1)), newline, char(t(2)), ' ', char(t(3))]));
t = strsplit(string((L(1))), ' ');
L(1) = cellstr(([char(t(1)), newline, char(t(2))]));

legend(LH, L, 'FontSize', 10, 'location','eastoutside');

set(gca, 'FontName', 'Helvetica', 'FontSize', 15, 'FontWeight', 'Bold', ...
    'XTick', 1:10, 'XTickLabels', odours(order), 'XTickLabelRotation', 50, ...
    'XColor', [0, 0, 0], 'YColor', [0, 0, 0],'YTick', -1:0.3:1.3);
ylim([-1.1, 1.3]);
y2 = get(gca, 'YTickLabels');
y2(end) = {['Pleasent ', char(y2(end))]};
y2(1) = {['Unpleasent ', char(y2(1))]};
set(gca, 'YTicklabels', y2);

%% Pitch Graph
[pitchScores, mu, sigma] = zscore(log2(pitchScores), 0, 'all');
pitchScoresMean = mean(pitchScores);
[vals, order] = sort(pitchScoresMean);
[p, tbl, stats] = friedman(pitchScores);

fprintf('pitch P = %.20f \n', p);
[c,m,h,gnames] = multcompare(stats, 'Alpha', 0.05, 'CType', 'bonferroni');

h = figure; hold on;
for i = 1:10
    b = bar(i, vals(i));
    set(b, 'FaceColor', [1, 1, 1], 'LineWidth', 2);
end
plot([0.5, 10.5], [0, 0], 'k', 'LineWidth', 2);
ci = (tinv(0.05, size(pitchScores,1)-1))*(std(pitchScores) / sqrt(length(pitchScores)));

% sig = not(shapeScoresMean + abs(ci) > 0 & shapeScoresMean - abs(ci) < 0);
er = errorbar(1:10, vals, ci(order));
% se = std(shapeScores) / sqrt(length(shapeScores));
% er = errorbar(1:10, vals, se(order));
er.Color = [1 0 0];                            
er.LineStyle = 'none'; 
er.CapSize = 15;
er.LineWidth = 3;

t = [c(c(:, end) < 0.05, 1), c(c(:, end) < 0.05, 2)];
t = vertcat(t, [c(c(:, end) < 0.05, 2), c(c(:, end) < 0.05, 1)]);

y = 1:10;

counter = ones(10, 1)*0.3;
counter(vals-mean(pitchScoresMean)>0) = -counter(vals-mean(pitchScoresMean)>0);

nOrder = odours(order);
% Plot all odour comparison markers
for i = 1:size(t, 1)
    plot(find(strcmp(nOrder, odours(t(i, 2)))), 0+counter(find(strcmp(nOrder, odours(t(i, 2))))), 'k', 'Marker', ...
        markers(find(strcmp(nOrder, odours(t(i, 1))))), 'MarkerSize', 6, 'LineWidth',1.2);
%     
    if vals(find(strcmp(nOrder, odours(t(i, 2)))))-mean(shapeScoresMean) > 0
        counter(find(strcmp(nOrder, odours(t(i, 2))))) = counter(find(strcmp(nOrder, odours(t(i, 2))))) - 0.15;
    else
        counter(find(strcmp(nOrder, odours(t(i, 2))))) = counter(find(strcmp(nOrder, odours(t(i, 2))))) + 0.15;
    end
end
% ttest for scales grand mean
[t2, p, ci, stat] = ttest(pitchScores, 0, 'Tail', 'Both', 'Alpha', 0.005);

diff = t2(order) == 1;
plot(y(diff), 0+counter(diff), 'k.', 'Marker', markers(11), 'MarkerSize', 6, 'LineWidth',1.2);

y = linspace(1, 9, 9);

xlim([0.5, 10.5]);
% ylim([min(y-mean(shapeScoresMean)), max(y-mean(shapeScoresMean))]);
title('Pitch Scores');

for i = 1:10
    LH(i) = plot(nan, nan, 'k.', 'Marker', markers(i), 'MarkerSize', 6, 'LineWidth',1.2);
    L{i} = odours(order(i));
end

t = strsplit(string((L(4))), ' ');
L(4) = cellstr(([char(t(1)), newline, char(t(2)), ' ', char(t(3))]));
t = strsplit(string((L(3))), ' ');
L(3) = cellstr(([char(t(1)), newline, char(t(2))]));

legend(LH, L, 'FontSize', 10, 'location','eastoutside');

set(gca, 'FontName', 'Helvetica', 'FontSize', 15, 'FontWeight', 'Bold', ...
    'XTick', 1:10, 'XTickLabels', odours(order), 'XTickLabelRotation', 50, ...
    'XColor', [0, 0, 0], 'YColor', [0, 0, 0], 'YTick', -1:0.5:1.5);
ylim([-1, 1.5]);
y2 = get(gca, 'YTickLabels');
y2(end) = {['Higher Pitch ', char(y2(end))]};
y2(1) = {['Lower Pitch ', char(y2(1))]};
set(gca, 'YTicklabels', y2);
%% Identification
t = categorical(repmat(odours', size(shapeScores, 1), 1));
figure; hold off;
tmp = vertcat(guess, guess2);
cm = confusionchart(t(:), categorical(tmp(:)));
cl = cm.ClassLabels;
cm = cm.NormalizedValues;
close(gcf);
cm(not(sum(cm, 2) > 1), :) = [];

confpercent = cm / size(vertcat(pleasentnessScores, pleasentnessScores2), 1);

figure; 
imagesc(confpercent);
title('Identifcation Association Matrix');
% set the colormap
colormap(flipud(gray));
ylabel('Presented Stimuli');
xlabel('Assigned Stimuli');

set(gca,'XTick',1:size(cl, 1),...
    'XTickLabel',string(cl),...
    'YTick',1:size(odours),...
    'YTickLabel',odours,...
    'TickLength',[0 0],...
    'FontName', 'Helvetica', ...
    'FontSize', 12, ...
    'FontWeight', 'Bold', 'XColor', [0 0 0], 'YColor', [0 0 0],...
    'Ylim', [0.5, 10.5]);
xtickangle(90)

c = colorbar;
c.Ticks = linspace(0, max(max(confpercent)), 6);
c.TickLabels = num2cell(linspace(0, round(max(max(confpercent))*100), 6));
c.Label.String = "Accurarcy (%)";
c.Label.FontSize = 12;
% c.Label.Fontname = 'Helvetica';
c.Label.FontWeight = 'Bold';
c.Label.Color = [0 0 0];
hold on;
plot([10.5, 10.5],[0, 10.5],'k', 'LineWidth', 2);

%%
acc2 = 0;

hold off;
cm = confusionchart(t(:), categorical(tmp(:)));
cl = cm.ClassLabels;
cm = cm.NormalizedValues;
close(gcf);
cm(not(sum(cm, 2) > 1), :) = [];

acc1 =  sum(cm(logical(eye(10)))) / sum(sum(cm));
inAcc = cm(logical(eye(10))) / size(shapeScores, 1);
% % Citrus
% acc2 = acc2 + sum(cm(7, strcmp(string(cl), 'Lemon') | strcmp(string(cl), 'Orange') | strcmp(string(cl), 'Pineapple')));
% acc2 = acc2 + sum(cm(8, strcmp(string(cl), 'Lemon') | strcmp(string(cl), 'Orange') | strcmp(string(cl), 'Pineapple')));
% % Fruits
% acc2 = acc2 + sum(cm(3, strcmp(string(cl), 'Cherry') | strcmp(string(cl), 'Strawberry') | strcmp(string(cl), 'Banana') | strcmp(string(cl), 'Coconut')));
% % Coffee Shop
% acc2 = acc2 + sum(cm(2, strcmp(string(cl), 'Coffee') | strcmp(string(cl), 'Toffee') | strcmp(string(cl), 'Caramel') | strcmp(string(cl), 'Fudge') | strcmp(string(cl), 'Vanilla')));
% acc2 = acc2 + sum(cm(4, strcmp(string(cl), 'Coffee') | strcmp(string(cl), 'Toffee') | strcmp(string(cl), 'Caramel') | strcmp(string(cl), 'Fudge') | strcmp(string(cl), 'Vanilla')));
% % Common Nature
% acc2 = acc2 + sum(cm(5, strcmp(string(cl), 'Lavender') | strcmp(string(cl), 'Pine') | strcmp(string(cl), 'Freshly Cut Grass') | strcmp(string(cl), 'Eucalyptus') | strcmp(string(cl), 'Rose') | strcmp(string(cl), 'Honey')));
% acc2 = acc2 + sum(cm(6, strcmp(string(cl), 'Lavender') | strcmp(string(cl), 'Pine') | strcmp(string(cl), 'Freshly Cut Grass') | strcmp(string(cl), 'Eucalyptus') | strcmp(string(cl), 'Rose') | strcmp(string(cl), 'Honey')));
% acc2 = acc2 + sum(cm(10, strcmp(string(cl), 'Lavender') | strcmp(string(cl), 'Pine') | strcmp(string(cl), 'Freshly Cut Grass') | strcmp(string(cl), 'Eucalyptus') | strcmp(string(cl), 'Rose') | strcmp(string(cl), 'Honey')));
% % House Hold
% acc2 = acc2 + sum(cm(7, strcmp(string(cl), 'Lemon') | strcmp(string(cl), 'Orange') | strcmp(string(cl), 'Peppermint') | strcmp(string(cl), 'Eucalyptus') | strcmp(string(cl), 'Black Pepper') | strcmp(string(cl), 'Coconut') | strcmp(string(cl), 'Musk') | strcmp(string(cl), 'Lavender')));
% acc2 = acc2 + sum(cm(8, strcmp(string(cl), 'Lemon') | strcmp(string(cl), 'Orange') | strcmp(string(cl), 'Peppermint') | strcmp(string(cl), 'Eucalyptus') | strcmp(string(cl), 'Black Pepper') | strcmp(string(cl), 'Coconut') | strcmp(string(cl), 'Musk') | strcmp(string(cl), 'Lavender')));
% acc2 = acc2 + sum(cm(9, strcmp(string(cl), 'Lemon') | strcmp(string(cl), 'Orange') | strcmp(string(cl), 'Peppermint') | strcmp(string(cl), 'Eucalyptus') | strcmp(string(cl), 'Black Pepper') | strcmp(string(cl), 'Coconut') | strcmp(string(cl), 'Musk') | strcmp(string(cl), 'Lavender')));
% acc2 = acc2 + sum(cm(1, strcmp(string(cl), 'Lemon') | strcmp(string(cl), 'Orange') | strcmp(string(cl), 'Peppermint') | strcmp(string(cl), 'Eucalyptus') | strcmp(string(cl), 'Black Pepper') | strcmp(string(cl), 'Coconut') | strcmp(string(cl), 'Musk') | strcmp(string(cl), 'Lavender')));
% 
% acc2 = acc2 / (sum(sum(cm')) + size(tmp, 1) + size(tmp, 1));

%acc2 = acc2 + sum(cm(1, strcmp(string(cl), 'Coffee') | strcmp(string(cl), 'Toffee') | strcmp(string(cl), 'Caramel') | strcmp(string(cl), 'Fudge') | strcmp(string(cl), 'Vanilla')));
% acc2 = acc2 + sum(cm(2, strcmp(string(cl), 'Coffee') | strcmp(string(cl), 'Toffee') | strcmp(string(cl), 'Caramel') | strcmp(string(cl), 'Fudge') | strcmp(string(cl), 'Vanilla')));
% acc2 = acc2 + sum(cm(3, strcmp(string(cl), 'Cherry') | strcmp(string(cl), 'Pineapple') | strcmp(string(cl), 'Strawberry') | strcmp(string(cl), 'Banana') | strcmp(string(cl), 'Coconut')));
% acc2 = acc2 + sum(cm(4, strcmp(string(cl), 'Coffee') | strcmp(string(cl), 'Toffee') | strcmp(string(cl), 'Caramel') | strcmp(string(cl), 'Fudge') | strcmp(string(cl), 'Vanilla')));
% acc2 = acc2 + sum(cm(5, strcmp(string(cl), 'Lavender') | strcmp(string(cl), 'Rose') | strcmp(string(cl), 'Musk')));
% acc2 = acc2 + sum(cm(6, strcmp(string(cl), 'Musk') | strcmp(string(cl), 'Lavender') | strcmp(string(cl), 'Rose')));
% acc2 = acc2 + sum(cm(7, strcmp(string(cl), 'Lemon') | strcmp(string(cl), 'Orange')));
% acc2 = acc2 + sum(cm(8, strcmp(string(cl), 'Lemon') | strcmp(string(cl), 'Orange')));
% acc2 = acc2 + sum(cm(9, strcmp(string(cl), 'Peppermint') | strcmp(string(cl), 'Eucalyptus')));
% acc2 = acc2 + sum(cm(10, strcmp(string(cl), 'Pine') | strcmp(string(cl), 'Black Pepper') | strcmp(string(cl), 'Freshly Cut Grass')));
% acc2 = acc2 / (sum(sum(cm')));

%% Genre
cm = zeros(10, size(unique(genre), 1));
g = unique(genre);
tmp = vertcat(genre, genre2);
for i = 1:10
    for j = 1:size(tmp, 1)
       for k = 1:size(g, 1)
          if strcmp(tmp(j, i), g(k))
              cm(i, k) = cm(i, k) + 1;
          end
       end
    end
end

cmG = cm;

cmG = cmG / size(tmp, 1);

confpercent = cm / size(tmp, 1);
figure;
% plotting the colors
imagesc(confpercent);
title('Genre Association Matrix');

% set the colormap
colormap(flipud(gray));

% Setting the axis labels
set(gca,'XTick',1:size(g, 1),...
    'XTickLabel',g,...
    'YTick',1:size(odours),...
    'YTickLabel',odours,...
    'TickLength',[0 0],...
    'FontName', 'Helvetica', ...
    'FontSize', 12, ...
    'FontWeight', 'Bold', 'XColor', [0 0 0], 'YColor', [0 0 0]);
xtickangle(90)
c = colorbar;
c.Ticks = linspace(0, max(max(confpercent)), 6);
c.TickLabels = num2cell(linspace(0, round(max(max(confpercent))*100), 6));
c.Label.String = "Assignment (%)";
c.Label.FontSize = 12;
% c.Label.Fontname = 'Helvetica';
c.Label.FontWeight = 'Bold';
[tbl,chi2,p,labels] = crosstab(tmp(:), repelem(odours,size(tmp, 1)));


%[h,p2,stats] = chi2gof(cm(:, 1), 'nbins', length(cm(:, 1)), 'Alpha',0.01);
%% Genre Dependency
correctCM = zeros(10, size(unique(genre), 1));
incorrectCM = zeros(10, size(unique(genre), 1));
% g = unique(genre);
tmp = vertcat(genre, genre2);

for i = 1:10
    for j = 1:size(tmp, 1)        
        if correct(j, i) == 1
            for k = 1:size(g, 1)
                if strcmp(tmp(j, i), g(k))
                    correctCM(i, k) = correctCM(i, k) + 1;
                end
            end
        else
            for k = 1:size(g, 1)
                if strcmp(tmp(j, i), g(k))
                    incorrectCM(i, k) = incorrectCM(i, k) + 1;
                end
            end
        end
    end
end

confpercent = (incorrectCM' ./ max(incorrectCM'))';
confpercent2 = (correctCM' ./ max(correctCM'))';
fprintf('Genre Frobenius Norm = %0.20f\n', norm((confpercent * 100) - (confpercent2*100), 'Fro'));
% [confpercent, pvals] = corr((cm' ./ max(cm'))', confpercent);
figure;
% plotting the colors
imagesc(confpercent - confpercent2);
title({'Relative Genre', 'Association Matrix'});

% set the colormap
colormap(flipud(gray));

% Setting the axis labels
set(gca,'XTick',1:size(g, 1),...
    'XTickLabel',g,...
    'YTick',1:size(odours),...
    'YTickLabel',odours,...
    'TickLength',[0 0],...
    'FontName', 'Helvetica', ...
    'FontSize', 12, ...
    'FontWeight', 'Bold', 'XColor', [0 0 0], 'YColor', [0 0 0]);
xtickangle(90)
c = colorbar;

c.Ticks = linspace(floor(min(min(confpercent - confpercent2))), ceil(max(max(confpercent - confpercent2))), 7);
c.TickLabels = num2cell(round(linspace(floor(min(min(confpercent - confpercent2))), ceil(max(max(confpercent - confpercent2))), 7), 2));
c.Label.String = "Relative Assignment (%)";
c.Label.FontSize = 12;
% c.Label.Fontname = 'Helvetica';
c.Label.FontWeight = 'Bold';

%% Emotions

cm = zeros(10, 11);
g = strings(10, 1);
g(1) = 'Neutral';
g(2) = 'Happy';
g(3) = 'Sad';
g(4) = 'Angry';
g(5) = 'Aroused';
g(6) = 'Scared';
g(7) = 'Disgust';
g(8) = 'Calm';
g(9) = 'Bored';
g(10) = 'Excited';
vec = strings(size(results, 1) + size(results2, 1), 1);

tmp = vertcat(emotions, emotions2);

in = 1;
sent = 0;
for i = 1:10
    for j = 1:size(tmp, 1)
       sent = 0;
       for k = 1:size(g, 1)
          if strcmp(tmp(j, i), g(k))
              cm(i, k) = cm(i, k) + 1;
              sent = 1;
              vec(in) = g(k);
              in = in + 1;
          end
          if k == 10 && sent == 0
              cm(i, 11) = cm(i, 11) + 1;
              vec(in) = 'Other';
              in = in + 1;
          end
       end
    end
end

cmE = cm;
cmE = cmE / size(tmp, 1);
cmE(:, end) = [];

g = vertcat(g, 'Other');
 
confpercent = (cm / size(tmp, 1));
figure;
% plotting the colors
imagesc(confpercent);
title('Emotional Association Matrix');

% set the colormap
colormap(flipud(gray));

% Setting the axis labels
set(gca,'XTick',1:size(g, 1),...
    'XTickLabel',g,...
    'YTick',1:size(odours),...
    'YTickLabel',odours,...
    'TickLength',[0 0],...
    'FontName', 'Helvetica', ...
    'FontSize', 12, ...
    'FontWeight', 'Bold', 'XColor', [0 0 0], 'YColor', [0 0 0]);
xtickangle(90)
c = colorbar;
c = colorbar;
c.Ticks = linspace(0, max(max(confpercent)), 6);
c.TickLabels = num2cell(linspace(0, round(max(max(confpercent))*100), 6));
c.Label.String = "Assignment (%)";
c.Label.FontSize = 12;
% c.Label.Fontname = 'Helvetica';
c.Label.FontWeight = 'Bold';

[tbl,chi2,p,labels] = crosstab(vec, repelem(odours, size(emotions, 1) + size(emotions2, 1)));

%% Emotion Dependency

CMcorrect = zeros(10, 11);
CMincorrect = zeros(10, 11);
g = strings(10, 1);
g(1) = 'Neutral';
g(2) = 'Happy';
g(3) = 'Sad';
g(4) = 'Angry';
g(5) = 'Aroused';
g(6) = 'Scared';
g(7) = 'Disgust';
g(8) = 'Calm';
g(9) = 'Bored';
g(10) = 'Excited';
vec2 = strings(size(results, 1) + size(results2, 1), 1);

tmp = vertcat(emotions, emotions2);

in = 1;
sent = 0;
for i = 1:10
    for j = 1:size(tmp, 1)
        sent = 0;
        if correct(j, i) == 1
            for k = 1:size(g, 1)
                if strcmp(tmp(j, i), g(k))
                    CMcorrect(i, k) = CMcorrect(i, k) + 1;
                    sent = 1;
                    vec2(in) = g(k);
                    in = in + 1;
                end
                if k == 10 && sent == 0
                    CMcorrect(i, 11) = CMcorrect(i, 11) + 1;
                    vec2(in) = 'Other';
                    in = in + 1;
                end
            end
        end
    end
end

g = strings(10, 1);
g(1) = 'Neutral';
g(2) = 'Happy';
g(3) = 'Sad';
g(4) = 'Angry';
g(5) = 'Aroused';
g(6) = 'Scared';
g(7) = 'Disgust';
g(8) = 'Calm';
g(9) = 'Bored';
g(10) = 'Excited';
vec3 = strings(size(results, 1) + size(results2, 1), 1);

tmp = vertcat(emotions, emotions2);

in = 1;
sent = 0;
for i = 1:10
    for j = 1:size(tmp, 1)
        sent = 0;
        if correct(j, i) == 0
            for k = 1:size(g, 1)
                if strcmp(tmp(j, i), g(k))
                    CMincorrect(i, k) = CMincorrect(i, k) + 1;
                    sent = 1;
                    vec3(in) = g(k);
                    in = in + 1;
                end
                if k == 10 && sent == 0
                    CMincorrect(i, 11) = CMincorrect(i, 11) + 1;
                    vec3(in) = 'Other';
                    in = in + 1;
                end
            end
        end
    end
end


cmE2 = cm;
cmE2 = cmE2 / size(tmp, 1);
cmE2(:, end) = [];

g = vertcat(g, 'Other');
 
confpercent = (CMincorrect' ./ max(CMincorrect'))';
confpercent2 = (CMcorrect' ./ max(CMcorrect'))';
fprintf('Emotions Frobenius Norm = %0.20f\n', norm((confpercent * 100) - (confpercent2*100), 'Fro'));


% [confpercent, pvals] = corr((cm' ./ max(cm'))', confpercent);
figure;
% plotting the colors
imagesc(confpercent - confpercent2);
title({'Relative Emotional', 'Association Matrix'});

% set the colormap
colormap(flipud(gray));

% Setting the axis labels
set(gca,'XTick',1:size(g, 1),...
    'XTickLabel',g,...
    'YTick',1:size(odours),...
    'YTickLabel',odours,...
    'TickLength',[0 0],...
    'FontName', 'Helvetica', ...
    'FontSize', 12, ...
    'FontWeight', 'Bold', 'XColor', [0 0 0], 'YColor', [0 0 0]);
xtickangle(90)
c = colorbar;

% c.Ticks = linspace(floor(min(min(confpercent - confpercent2))), ceil(max(max(confpercent - confpercent2))), 7);
% c.TickLabels = num2cell(round(linspace(floor(min(min(confpercent - confpercent2))), ceil(max(max(confpercent - confpercent2))), 7), 2));
c.Label.String = "Relative Assignment (%)";
c.Label.FontSize = 12;
% c.Label.Fontname = 'Helvetica';
c.Label.FontWeight = 'Bold';

% [tbl,chi2,p,labels] = crosstab(vec, repelem(odours, size(emotions, 1) + size(emotions2, 1)));

%% Category Tests
categoricallyCorrect = zeros(size(shapeScores, 1), size(shapeScores, 2));
citrus = {'Lemon', 'Orange'};
leafy = {'Peppermint', 'Eucalyptus'};
floral = {'Rose', 'Lavender', 'Musk'};
otherFruits = {'Cherry', 'Pineapple' ,'Strawberry', 'Banana', 'Coconut'};
woody = {'Pine', 'Black Pepper', 'Freshly Cut Grass'};
SpicySmokeyNutty = {'Coffee', 'Toffee', 'Caramel', 'Fudge', 'Vanilla'};

guesses = vertcat(guess, guess2);
for i = 1:10
    if i == 1
        for j = 1:size(woody, 2)
            categoricallyCorrect(:, i) = categoricallyCorrect(:, i) + strcmp(guesses(:, i), woody(j)); 
        end
    elseif i == 2
        for j = 1:size(SpicySmokeyNutty, 2)
            categoricallyCorrect(:, i) = categoricallyCorrect(:, i) + strcmp(guesses(:, i), SpicySmokeyNutty(j)); 
        end
    elseif i == 3
        for j = 1:size(otherFruits, 2)
            categoricallyCorrect(:, i) = categoricallyCorrect(:, i) + strcmp(guesses(:, i), otherFruits(j)); 
        end
    elseif i == 4
        for j = 1:size(SpicySmokeyNutty, 2)
            categoricallyCorrect(:, i) = categoricallyCorrect(:, i) + strcmp(guesses(:, i), SpicySmokeyNutty(j)); 
        end
    elseif i == 5
        for j = 1:size(woody, 2)
            categoricallyCorrect(:, i) = categoricallyCorrect(:, i) + strcmp(guesses(:, i), woody(j)); 
        end
    elseif i == 6
        for j = 1:size(floral, 2)
            categoricallyCorrect(:,i) = categoricallyCorrect(:, i) + strcmp(guesses(:, i), floral(j)); 
        end
    elseif i == 7
        for j = 1:size(citrus, 2)
            categoricallyCorrect(:, i) = categoricallyCorrect(:, i) + strcmp(guesses(:, i), citrus(j)); 
        end
    elseif i == 8
        for j = 1:size(citrus, 2)
            categoricallyCorrect(:, i) = categoricallyCorrect(:, i) + strcmp(guesses(:, i), citrus(j)); 
        end
    elseif i == 9
        for j = 1:size(leafy, 2)
            categoricallyCorrect(:, i) = categoricallyCorrect(:, i) + strcmp(guesses(:, i), leafy(j)); 
        end
    else
        for j = 1:size(woody, 2)
            categoricallyCorrect(:, i) = categoricallyCorrect(:, i) + strcmp(guesses(:, i), woody(j)); 
        end
    end
end
indAcc = sum(categoricallyCorrect) / size(shapeScores, 1);
meanAcc = mean(indAcc);

%%
t = categorical(repmat(odours', 68, 1));
figure; hold off;
tmp = vertcat(guess, guess2);
cm = confusionchart(t(:), categorical(tmp(:)));
cl = cm.ClassLabels;
cm = cm.NormalizedValues;
close(gcf);
cm(not(sum(cm, 2) > 1), :) = [];

confpercent = cm / 68;

figure; 
imagesc(confpercent);
title('Identifcation Association Matrix');
% set the colormap
colormap(flipud(gray));
ylabel('Presented Stimuli');
xlabel('Assigned Stimuli');

set(gca,'XTick',1:size(cl, 1),...
    'XTickLabel',string(cl),...
    'YTick',1:size(odours),...
    'YTickLabel',odours,...
    'TickLength',[0 0],...
    'FontName', 'Helvetica', ...
    'FontSize', 12, ...
    'FontWeight', 'Bold', 'XColor', [0 0 0], 'YColor', [0 0 0],...
    'Ylim', [0.5, 10.5]);
xtickangle(90)

c = colorbar;
c.Ticks = linspace(0, max(max(confpercent)), 6);
c.TickLabels = num2cell(linspace(0, round(max(max(confpercent))*100), 6));
c.Label.String = "Accurarcy (%)";
c.Label.FontSize = 12;
% c.Label.Fontname = 'Helvetica';
c.Label.FontWeight = 'Bold';
c.Label.Color = [0 0 0];
hold on;
plot([10.5, 10.5],[0, 10.5],'k', 'LineWidth', 2);
%% Shape Score Dependency

[shapeScores2, mu, sigma] = zscore(shapeScoreCorrect, 0, 'all');

% shapeScoresMean = mean(shapeScores);
[vals, order] = sort(mean(shapeScores2));

h = figure; hold on;

lastX = zeros(1,3);
lastY = zeros(1,3);
plot([0.5, 10.5], [0, 0], 'k', 'lineWidth', 3);
for i = 1:10
    % Mean
    [v, or] = sort([mean(shapeScores2(~correct(:,order(i)), order(i))), ...
        mean(shapeScores2(correct(:,order(i)), order(i))), mean(shapeScores2(logical(categoricallyCorrect(:,order(i))), order(i)))]);
    
    if i == 1
%         plot(i, mean(pleasentnessScores2(~correct(:,order(i)), order(i))), 'r^', 'MarkerSize', 10, 'MarkerFaceColor', [1, 0,0], 'MarkerEdgeColor', [1, 0, 0]);
%         plot(i, mean(pleasentnessScores2(correct(:,order(i)), order(i))), 'gs', 'MarkerSize', 15, 'MarkerFaceColor', [50/255, 220/255, 82/255], 'MarkerEdgeColor', [50/255, 220/255, 82/255]);

%           Red  
            ci = (tinv(0.05, size(shapeScores2(~correct(:,order(i)), order(i)),1)-1))*(std(shapeScores2(~correct(:,order(i)), order(i))) / sqrt(length(shapeScores2(~correct(:,order(i)), order(i)))));
            er = errorbar(i, mean(shapeScores2(~correct(:,order(i)), order(i))), ci);

            er.Color = [1 0 0];                            
            er.LineStyle = 'none'; 
            er.CapSize = 15;
            er.LineWidth = 3;
            % Green
             ci = (tinv(0.05, size(shapeScores2(correct(:,order(i)), order(i)),1)-1))*(std(shapeScores2(correct(:,order(i)), order(i))) / sqrt(length(shapeScores2(correct(:,order(i)), order(i)))));
            er = errorbar(i, mean(shapeScores2(correct(:,order(i)), order(i))), ci);

            er.Color = [50/255 220/255 82/255];                            
            er.LineStyle = 'none'; 
            er.CapSize = 15;
            er.LineWidth = 3;
%         plot(i, mean(pleasentnessScores2(logical(categoricallyCorrect(:,order(i))), order(i))), 'bx', 'MarkerSize', 15);
    else
%         plot([i-1, i], [lastY(1), mean(pleasentnessScores2(~correct(:,order(i)), order(i)))], 'r^', 'lineWidth', 3, 'MarkerSize', 10, 'MarkerFaceColor', [1, 0, 0]);
        plot([i-1, i], [lastY(1), mean(shapeScores2(~correct(:,order(i)), order(i)))], 'r-', 'lineWidth', 3);
        
%         plot([i-1, i], [lastY(2), mean(pleasentnessScores2(correct(:,order(i)), order(i)))], 'gs', 'lineWidth', 3, 'MarkerSize', 15, 'MarkerFaceColor', [50/255, 220/255, 82/255], 'MarkerEdgeColor', [50/255, 220/255, 82/255]);
        plot([i-1, i], [lastY(2), mean(shapeScores2(correct(:,order(i)), order(i)))], 'g-', 'lineWidth', 3, 'Color', [50/255, 220/255, 82/255]);
        
        %  Red
        ci = (tinv(0.05, size(shapeScores2(~correct(:,order(i)), order(i)),1)-1))*(std(shapeScores2(~correct(:,order(i)), order(i))) / sqrt(length(shapeScores2(~correct(:,order(i)), order(i)))));
        er = errorbar(i, mean(shapeScores2(~correct(:,order(i)), order(i))), ci);
        
        er.Color = [1 0 0];
        er.LineStyle = 'none';
        er.CapSize = 15;
        er.LineWidth = 3;
        % Green
        ci = (tinv(0.05, size(shapeScores2(correct(:,order(i)), order(i)),1)-1))*(std(shapeScores2(correct(:,order(i)), order(i))) / sqrt(length(shapeScores2(correct(:,order(i)), order(i)))));
        er = errorbar(i, mean(shapeScores2(correct(:,order(i)), order(i))), ci);
        
        er.Color = [50/255 220/255 82/255];
        er.LineStyle = 'none';
        er.CapSize = 15;
        er.LineWidth = 3;
%         plot([i-1, i], [lastY(3), mean(pleasentnessScores2(logical(categoricallyCorrect(:,order(i))), order(i)))], 'bx', 'lineWidth', 3, 'MarkerSize', 15, 'MarkerFaceColor', [0, 0, 1]);
%         plot([i-1, i], [lastY(3), mean(pleasentnessScores2(logical(categoricallyCorrect(:,order(i))), order(i)))], 'b-', 'lineWidth', 3);
    end
    lastY(1) = mean(shapeScores2(~correct(:,order(i)), order(i)));
    lastY(2) = mean(shapeScores2(correct(:,order(i)), order(i)));
    lastY(3) = mean(shapeScores2(logical(categoricallyCorrect(:,order(i))), order(i)));
    

    
end

for i = 1:10
    [sig,p,stats] = anovan(shapeScores2(:, order(i)), {logical(correct(:,order(i)))}, 'Display', 'Off');
    tmp111 = shapeScores2(logical(~correct(:,order(i))), order(i));
%     [sig, newP, dsad, stats] = ttest(tmp111, mean(pleasentnessScores2(logical(correct(:,order(i))), order(i))), 'Tail', 'Both');

    if sig < 0.051
         fprintf('Angularity: %s, %.20f,\n', odours(order(i)), sig);
        if mean(tmp111) < 0
            text(i-0.25, -1.5, '*', 'FontWeight', 'Bold', 'FontSize', 40, 'FontName', 'Halvetica');
        else
            text(i-0.25, -1.5, '*', 'FontWeight', 'Bold', 'FontSize', 40, 'FontName', 'Halvetica');
        end
    end
end

xlim([0.5 10.5]);
title({'Angularity Scores', 'Identification Dependency'});
set(gca, 'FontName', 'Helvetica', 'FontSize', 15, 'FontWeight', 'Bold', ...
    'XTick', 1:10, 'XTickLabels', odours(order), 'XTickLabelRotation', 50, ...
    'XColor', [0, 0, 0], 'YColor', [0, 0, 0]);

%% Texture Score Dependency
[textureScores2, mu, sigma] = zscore(textureScoreCorrect, 0, 'all');

% shapeScoresMean = mean(shapeScores);
[vals, order] = sort(mean(textureScores2));

h = figure; hold on;

allY = zeros(1,10);
lastY = zeros(1,3);
plot([0.5, 10.5], [0, 0], 'k', 'lineWidth', 3);
for i = 1:10
    % Mean
    [v, or] = sort([mean(textureScores2(~correct(:,order(i)), order(i))), ...
        mean(textureScores2(correct(:,order(i)), order(i))), mean(textureScores2(logical(categoricallyCorrect(:,order(i))), order(i)))]);
    
    if i == 1
%         plot(i, mean(pleasentnessScores2(~correct(:,order(i)), order(i))), 'r^', 'MarkerSize', 10, 'MarkerFaceColor', [1, 0,0], 'MarkerEdgeColor', [1, 0, 0]);
%         plot(i, mean(pleasentnessScores2(correct(:,order(i)), order(i))), 'gs', 'MarkerSize', 15, 'MarkerFaceColor', [50/255, 220/255, 82/255], 'MarkerEdgeColor', [50/255, 220/255, 82/255]);

%           Red  
            ci = (tinv(0.05, size(textureScores2(~correct(:,order(i)), order(i)),1)-1))*(std(textureScores2(~correct(:,order(i)), order(i))) / sqrt(length(textureScores2(~correct(:,order(i)), order(i)))));
            er = errorbar(i, mean(textureScores2(~correct(:,order(i)), order(i))), ci);

            er.Color = [1 0 0];                            
            er.LineStyle = 'none'; 
            er.CapSize = 15;
            er.LineWidth = 3;
            % Green
             ci = (tinv(0.05, size(textureScores2(correct(:,order(i)), order(i)),1)-1))*(std(textureScores2(correct(:,order(i)), order(i))) / sqrt(length(textureScores2(correct(:,order(i)), order(i)))));
            er = errorbar(i, mean(textureScores2(correct(:,order(i)), order(i))), ci);

            er.Color = [50/255 220/255 82/255];                            
            er.LineStyle = 'none'; 
            er.CapSize = 15;
            er.LineWidth = 3;
%         plot(i, mean(pleasentnessScores2(logical(categoricallyCorrect(:,order(i))), order(i))), 'bx', 'MarkerSize', 15);
    else
%         plot([i-1, i], [lastY(1), mean(pleasentnessScores2(~correct(:,order(i)), order(i)))], 'r^', 'lineWidth', 3, 'MarkerSize', 10, 'MarkerFaceColor', [1, 0, 0]);
        plot([i-1, i], [lastY(1), mean(textureScores2(~correct(:,order(i)), order(i)))], 'r-', 'lineWidth', 3);
        
%         plot([i-1, i], [lastY(2), mean(pleasentnessScores2(correct(:,order(i)), order(i)))], 'gs', 'lineWidth', 3, 'MarkerSize', 15, 'MarkerFaceColor', [50/255, 220/255, 82/255], 'MarkerEdgeColor', [50/255, 220/255, 82/255]);
        plot([i-1, i], [lastY(2), mean(textureScores2(correct(:,order(i)), order(i)))], 'g-', 'lineWidth', 3, 'Color', [50/255, 220/255, 82/255]);
        
        %  Red
        ci = (tinv(0.05, size(textureScores2(~correct(:,order(i)), order(i)),1)-1))*(std(textureScores2(~correct(:,order(i)), order(i))) / sqrt(length(textureScores2(~correct(:,order(i)), order(i)))));
        er = errorbar(i, mean(textureScores2(~correct(:,order(i)), order(i))), ci);
        
        er.Color = [1 0 0];
        er.LineStyle = 'none';
        er.CapSize = 15;
        er.LineWidth = 3;
        % Green
        ci = (tinv(0.05, size(textureScores2(correct(:,order(i)), order(i)),1)-1))*(std(textureScores2(correct(:,order(i)), order(i))) / sqrt(length(textureScores2(correct(:,order(i)), order(i)))));
        er = errorbar(i, mean(textureScores2(correct(:,order(i)), order(i))), ci);
        
        er.Color = [50/255 220/255 82/255];
        er.LineStyle = 'none';
        er.CapSize = 15;
        er.LineWidth = 3;
%         plot([i-1, i], [lastY(3), mean(pleasentnessScores2(logical(categoricallyCorrect(:,order(i))), order(i)))], 'bx', 'lineWidth', 3, 'MarkerSize', 15, 'MarkerFaceColor', [0, 0, 1]);
%         plot([i-1, i], [lastY(3), mean(pleasentnessScores2(logical(categoricallyCorrect(:,order(i))), order(i)))], 'b-', 'lineWidth', 3);
    end
    lastY(1) = mean(textureScores2(~correct(:,order(i)), order(i)));
    lastY(2) = mean(textureScores2(correct(:,order(i)), order(i)));
    lastY(3) = mean(textureScores2(logical(categoricallyCorrect(:,order(i))), order(i)));
    

    
end

for i = 1:10
    [sig,p,stats] = anovan(textureScores2(:, order(i)), {logical(correct(:,order(i)))}, 'Display', 'Off');
    tmp111 = textureScores2(logical(~correct(:,order(i))), order(i));

    if sig < 0.051
         fprintf('Texture: %s, %.20f,\n', odours(order(i)), sig);
        if mean(tmp111) < 0
            text(i-0.25, -1.5, '*', 'FontWeight', 'Bold', 'FontSize', 40, 'FontName', 'Halvetica');
        else
            text(i-0.25, -1.5, '*', 'FontWeight', 'Bold', 'FontSize', 40, 'FontName', 'Halvetica');
        end
    end
end


xlim([0.5 10.5]);
ylim([-1.5, 1.5]);
title({'Smoothness Scores', 'Identification Dependency'});
set(gca, 'FontName', 'Helvetica', 'FontSize', 15, 'FontWeight', 'Bold', ...
    'XTick', 1:10, 'XTickLabels', odours(order), 'XTickLabelRotation', 50, ...
    'XColor', [0, 0, 0], 'YColor', [0, 0, 0], 'YTick', -1.5:0.5:1.5);

y2 = get(gca, 'YTickLabels');
y2(end) = {['Smooth ', char(y2(end))]};
y2(1) = {['Rough ', char(y2(1))]};
set(gca, 'YTicklabels', y2);

%% Pleasentness scores dependentcy
[pleasentnessScores2, mu, sigma] = zscore(pleasentnessScoreCorrect, 0, 'all');

% shapeScoresMean = mean(shapeScores);
[vals, order] = sort(mean(pleasentnessScores2));

h = figure; hold on;
lastX = zeros(1,3);
lastY = zeros(1,3);

plot([0.5, 10.5], [0, 0], 'k', 'lineWidth', 3);
for i = 1:10
    % Mean
    [v, or] = sort([mean(pleasentnessScores2(~correct(:,order(i)), order(i))), ...
        mean(pleasentnessScores2(correct(:,order(i)), order(i))), mean(pleasentnessScores2(logical(categoricallyCorrect(:,order(i))), order(i)))]);
    
    if i == 1
%         plot(i, mean(pleasentnessScores2(~correct(:,order(i)), order(i))), 'r^', 'MarkerSize', 10, 'MarkerFaceColor', [1, 0,0], 'MarkerEdgeColor', [1, 0, 0]);
%         plot(i, mean(pleasentnessScores2(correct(:,order(i)), order(i))), 'gs', 'MarkerSize', 15, 'MarkerFaceColor', [50/255, 220/255, 82/255], 'MarkerEdgeColor', [50/255, 220/255, 82/255]);

%           Red  
            ci = (tinv(0.05, size(pleasentnessScores2(~correct(:,order(i)), order(i)),1)-1))*(std(pleasentnessScores2(~correct(:,order(i)), order(i))) / sqrt(length(pleasentnessScores2(~correct(:,order(i)), order(i)))));
            er = errorbar(i, mean(pleasentnessScores2(~correct(:,order(i)), order(i))), ci);

            er.Color = [1 0 0];                            
            er.LineStyle = 'none'; 
            er.CapSize = 15;
            er.LineWidth = 3;
            % Green
             ci = (tinv(0.05, size(pleasentnessScores2(correct(:,order(i)), order(i)),1)-1))*(std(pleasentnessScores2(correct(:,order(i)), order(i))) / sqrt(length(pleasentnessScores2(correct(:,order(i)), order(i)))));
            er = errorbar(i, mean(pleasentnessScores2(correct(:,order(i)), order(i))), ci);

            er.Color = [50/255 220/255 82/255];                            
            er.LineStyle = 'none'; 
            er.CapSize = 15;
            er.LineWidth = 3;
%         plot(i, mean(pleasentnessScores2(logical(categoricallyCorrect(:,order(i))), order(i))), 'bx', 'MarkerSize', 15);
    else
%         plot([i-1, i], [lastY(1), mean(pleasentnessScores2(~correct(:,order(i)), order(i)))], 'r^', 'lineWidth', 3, 'MarkerSize', 10, 'MarkerFaceColor', [1, 0, 0]);
        plot([i-1, i], [lastY(1), mean(pleasentnessScores2(~correct(:,order(i)), order(i)))], 'r-', 'lineWidth', 3);
        
%         plot([i-1, i], [lastY(2), mean(pleasentnessScores2(correct(:,order(i)), order(i)))], 'gs', 'lineWidth', 3, 'MarkerSize', 15, 'MarkerFaceColor', [50/255, 220/255, 82/255], 'MarkerEdgeColor', [50/255, 220/255, 82/255]);
        plot([i-1, i], [lastY(2), mean(pleasentnessScores2(correct(:,order(i)), order(i)))], 'g-', 'lineWidth', 3, 'Color', [50/255, 220/255, 82/255]);
        
        %  Red
        ci = (tinv(0.05, size(pleasentnessScores2(~correct(:,order(i)), order(i)),1)-1))*(std(pleasentnessScores2(~correct(:,order(i)), order(i))) / sqrt(length(pleasentnessScores2(~correct(:,order(i)), order(i)))));
        er = errorbar(i, mean(pleasentnessScores2(~correct(:,order(i)), order(i))), ci);
        
        er.Color = [1 0 0];
        er.LineStyle = 'none';
        er.CapSize = 15;
        er.LineWidth = 3;
        % Green
        ci = (tinv(0.05, size(pleasentnessScores2(correct(:,order(i)), order(i)),1)-1))*(std(pleasentnessScores2(correct(:,order(i)), order(i))) / sqrt(length(pleasentnessScores2(correct(:,order(i)), order(i)))));
        er = errorbar(i, mean(pleasentnessScores2(correct(:,order(i)), order(i))), ci);
        
        er.Color = [50/255 220/255 82/255];
        er.LineStyle = 'none';
        er.CapSize = 15;
        er.LineWidth = 3;
%         plot([i-1, i], [lastY(3), mean(pleasentnessScores2(logical(categoricallyCorrect(:,order(i))), order(i)))], 'bx', 'lineWidth', 3, 'MarkerSize', 15, 'MarkerFaceColor', [0, 0, 1]);
%         plot([i-1, i], [lastY(3), mean(pleasentnessScores2(logical(categoricallyCorrect(:,order(i))), order(i)))], 'b-', 'lineWidth', 3);
    end
    lastY(1) = mean(pleasentnessScores2(~correct(:,order(i)), order(i)));
    lastY(2) = mean(pleasentnessScores2(correct(:,order(i)), order(i)));
    lastY(3) = mean(pleasentnessScores2(logical(categoricallyCorrect(:,order(i))), order(i)));
    

    
end

for i = 1:10
    [sig,p,stats] = anovan(pleasentnessScores2(:, order(i)), {logical(correct(:,order(i)))});
    tmp111 = pleasentnessScores2(logical(~correct(:,order(i))), order(i));
%     [sig, newP, dsad, stats] = ttest(tmp111, mean(pleasentnessScores2(logical(correct(:,order(i))), order(i))), 'Tail', 'Both');

    if sig < 0.051
         fprintf('Pleasentness: %s, %.20f,\n', odours(order(i)), sig);
        if mean(tmp111) < 0
            text(i-0.25, -1.7, '*', 'FontWeight', 'Bold', 'FontSize', 40, 'FontName', 'Halvetica');
        else
            text(i-0.25, -1.7, '*', 'FontWeight', 'Bold', 'FontSize', 40, 'FontName', 'Halvetica');
        end
    end
end



xlim([0.5 10.5]);
title({'Pleasentness Scores', 'Identification Dependency'});

ylim([-1.7, 1.7]);
set(gca, 'FontName', 'Helvetica', 'FontSize', 15, 'FontWeight', 'Bold', ...
    'XTick', 1:10, 'XTickLabels', odours(order), 'XTickLabelRotation', 50, ...
    'XColor', [0, 0, 0], 'YColor', [0, 0, 0], 'YTick', [-1.7, -1, 0, 1, 1.7]);
y2 = get(gca, 'YTickLabels');
y2(end) = {['Pleasent ', char(y2(end))]};
y2(1) = {['Unpleasent ', char(y2(1))]};
set(gca, 'YTicklabels', y2);
%% Pitch scores dependentcy
correct = correct(1:60, :);
categoricallyCorrect = categoricallyCorrect(1:60, :);
[pitchScores2, mu, sigma] = zscore(log2(pitchScoreCorrect), 0, 'all');

% shapeScoresMean = mean(shapeScores);
[vals, order] = sort(mean(pitchScores2));

h = figure; hold on;
lastX = zeros(1,3);
lastY = zeros(1,3);

plot([0.5, 10.5], [0, 0], 'k', 'lineWidth', 3);
for i = 1:10
    % Mean
    [v, or] = sort([mean(pitchScores2(~correct(:,order(i)), order(i))), ...
        mean(pitchScores2(correct(:,order(i)), order(i))), mean(pitchScores2(logical(categoricallyCorrect(:,order(i))), order(i)))]);
    
    if i == 1
%         plot(i, mean(pleasentnessScores2(~correct(:,order(i)), order(i))), 'r^', 'MarkerSize', 10, 'MarkerFaceColor', [1, 0,0], 'MarkerEdgeColor', [1, 0, 0]);
%         plot(i, mean(pleasentnessScores2(correct(:,order(i)), order(i))), 'gs', 'MarkerSize', 15, 'MarkerFaceColor', [50/255, 220/255, 82/255], 'MarkerEdgeColor', [50/255, 220/255, 82/255]);

%           Red  
            ci = (tinv(0.05, size(pitchScores2(~correct(:,order(i)), order(i)),1)-1))*(std(pitchScores2(~correct(:,order(i)), order(i))) / sqrt(length(pitchScores2(~correct(:,order(i)), order(i)))));
            er = errorbar(i, mean(pitchScores2(~correct(:,order(i)), order(i))), ci);

            er.Color = [1 0 0];                            
            er.LineStyle = 'none'; 
            er.CapSize = 15;
            er.LineWidth = 3;
            % Green
             ci = (tinv(0.05, size(pitchScores2(correct(:,order(i)), order(i)),1)-1))*(std(pitchScores2(correct(:,order(i)), order(i))) / sqrt(length(pitchScores2(correct(:,order(i)), order(i)))));
            er = errorbar(i, mean(pitchScores2(correct(:,order(i)), order(i))), ci);

            er.Color = [50/255 220/255 82/255];                            
            er.LineStyle = 'none'; 
            er.CapSize = 15;
            er.LineWidth = 3;
%         plot(i, mean(pleasentnessScores2(logical(categoricallyCorrect(:,order(i))), order(i))), 'bx', 'MarkerSize', 15);
    else
%         plot([i-1, i], [lastY(1), mean(pleasentnessScores2(~correct(:,order(i)), order(i)))], 'r^', 'lineWidth', 3, 'MarkerSize', 10, 'MarkerFaceColor', [1, 0, 0]);
        plot([i-1, i], [lastY(1), mean(pitchScores2(~correct(:,order(i)), order(i)))], 'r-', 'lineWidth', 3);
        
%         plot([i-1, i], [lastY(2), mean(pleasentnessScores2(correct(:,order(i)), order(i)))], 'gs', 'lineWidth', 3, 'MarkerSize', 15, 'MarkerFaceColor', [50/255, 220/255, 82/255], 'MarkerEdgeColor', [50/255, 220/255, 82/255]);
        plot([i-1, i], [lastY(2), mean(pitchScores2(correct(:,order(i)), order(i)))], 'g-', 'lineWidth', 3, 'Color', [50/255, 220/255, 82/255]);
        
        %  Red
        ci = (tinv(0.05, size(pitchScores2(~correct(:,order(i)), order(i)),1)-1))*(std(pitchScores2(~correct(:,order(i)), order(i))) / sqrt(length(pitchScores2(~correct(:,order(i)), order(i)))));
        er = errorbar(i, mean(pitchScores2(~correct(:,order(i)), order(i))), ci);
        
        er.Color = [1 0 0];
        er.LineStyle = 'none';
        er.CapSize = 15;
        er.LineWidth = 3;
        % Green
        ci = (tinv(0.05, size(pitchScores2(correct(:,order(i)), order(i)),1)-1))*(std(pitchScores2(correct(:,order(i)), order(i))) / sqrt(length(pitchScores2(correct(:,order(i)), order(i)))));
        er = errorbar(i, mean(pitchScores2(correct(:,order(i)), order(i))), ci);
        
        er.Color = [50/255 220/255 82/255];
        er.LineStyle = 'none';
        er.CapSize = 15;
        er.LineWidth = 3;
%         plot([i-1, i], [lastY(3), mean(pleasentnessScores2(logical(categoricallyCorrect(:,order(i))), order(i)))], 'bx', 'lineWidth', 3, 'MarkerSize', 15, 'MarkerFaceColor', [0, 0, 1]);
%         plot([i-1, i], [lastY(3), mean(pleasentnessScores2(logical(categoricallyCorrect(:,order(i))), order(i)))], 'b-', 'lineWidth', 3);
    end
    lastY(1) = mean(pitchScores2(~correct(:,order(i)), order(i)));
    lastY(2) = mean(pitchScores2(correct(:,order(i)), order(i)));
    lastY(3) = mean(pitchScores2(logical(categoricallyCorrect(:,order(i))), order(i)));
    

    
end

for i = 1:10
    [sig,p,stats] = anovan(pitchScores2(:, order(i)), {logical(correct(:,order(i)))});
    tmp111 = pitchScores2(logical(~correct(:,order(i))), order(i));
%     [sig, newP, dsad, stats] = ttest(tmp111, mean(pleasentnessScores2(logical(correct(:,order(i))), order(i))), 'Tail', 'Both');

    if sig < 0.051
         fprintf('Pleasentness: %s, %.20f,\n', odours(order(i)), sig);
        if mean(tmp111) < 0
            text(i-0.25, -1.4, '*', 'FontWeight', 'Bold', 'FontSize', 40, 'FontName', 'Halvetica');
        else
            text(i-0.25, -1.4, '*', 'FontWeight', 'Bold', 'FontSize', 40, 'FontName', 'Halvetica');
        end
    end
end

xlim([0.5 10.5]);
ylim([-1.5, 1.5]);
title({'Pitch Scores', 'Identification Dependency'});
set(gca, 'FontName', 'Helvetica', 'FontSize', 15, 'FontWeight', 'Bold', ...
    'XTick', 1:10, 'XTickLabels', odours(order), 'XTickLabelRotation', 50, ...
    'XColor', [0, 0, 0], 'YColor', [0, 0, 0], 'YTick', -1.5:0.5:1.5);

y2 = get(gca, 'YTickLabels');
y2(end) = {['Higher Pitch ', char(y2(end))]};
y2(1) = {['Lower Pitch ', char(y2(1))]};
set(gca, 'YTicklabels', y2);
%%

%% Colours
colours = strtrim(colours);
colours = strrep(colours, '[', '');
colours = strrep(colours, ']', '');
colours =  str2double(split(colours, ' '));
colours2 = strtrim(colours2);
colours2 = strrep(colours2, '[', '');
colours2 = strrep(colours2, ']', '');
colours2 =  str2double(split(colours2, ' '));

[r,g,b] = meshgrid(linspace(0,1,7.8));
rgb = [r(:), g(:), b(:)];
lab = rgb2lab(rgb, 'ColorSpace', 'adobe-rgb-1998');
a = lab(:,2);
b = lab(:,3);
L = lab(:,1);
k = boundary(a,b,L);
% figure; hold on; grid on;
% subplot(2, 1, 1); 
figure;
hold on; grid on;
% plot3(a(k), b(k), L(k), '.', 'MarkerFaceColor', rgb(k, :));
t = trisurf(k,a,b,L,...
    'FaceVertexCData',rgb, 'FaceAlpha',0.1,'EdgeColor','none', 'FaceColor','interp');

tmp = find(rgb(:,1) == rgb(:,2));
tmp2 = find(rgb(tmp,2) == rgb(tmp, 3));
grays = horzcat(tmp(tmp2), tmp(tmp2), tmp(tmp2));

k = vertcat(k, grays);
for i = 1:size(k, 1)
    plot3(a(k(i)), b(k(i)), L(k(i)), '.', 'MarkerSize', 25, 'MarkerEdgeColor', rgb(k(i), :));
end
xlabel('a*'); ylabel('b*'); zlabel('L*');
title('L*a*b* Colour Gamut');
set(gca, 'FontName', 'Helvetica', 'FontSize', 15, 'FontWeight', 'Bold', ...
    'XColor', [0, 0, 0], 'YColor', [0, 0, 0]);

cLocs = zeros(size(colours, 1) + size(colours2, 1), size(colours, 2) + size(colours2, 2));
tmp = vertcat(colours, colours2);
size(tmp)
for i = 1:size(tmp, 1)
   for j = 1:size(tmp, 2)
       min = inf;
       loc = -1;
       for z = 1:size(k, 1)
           c = rgb2lab([tmp(i,j,1) / 255, tmp(i,j,2)/255, tmp(i,j,3)/255], 'ColorSpace', 'adobe-rgb-1998');
%            deltaE = lab(k(i), :)
%            deltaE = sqrt(sum((c - lab(k(z), :)) .^ 2));
            deltaE = deltaE2000(c, lab(k(z), :));
           if deltaE < min
              min = deltaE; 
              cLocs(i, j) = z;
           end
       end
   end
end
%%

% achual = [];
% for i = 1:size(cLocs, 1)
%     if i == 1
%         achual = zeros(50,50,3);
%         achual(:,:,1) = colours(i,10,1);
%         achual(:,:,2) = colours(i,10,2);
%         achual(:,:,3) = colours(i,10,3);
%     end
%     tmp = zeros(50,50,3);
%     tmp(:,:,1) = colours(i,10,1);
%     tmp(:,:,2) = colours(i,10,2);
%     tmp(:,:,3) = colours(i,10,3);
%     achual = vertcat(achual, tmp);
% end
% 
% 
% assigned = [];
% 
% for i = 1:size(cLocs, 1)
%     if i == 1
%         assigned = zeros(50,50,3);
%         assigned(:,:,1) = rgb(k(cLocs(i,10)), 1) * 255;
%         assigned(:,:,2) = rgb(k(cLocs(i,10)), 2) * 255;
%         assigned(:,:,3) = rgb(k(cLocs(i,10)), 3) * 255;
%     end
%     tmp = zeros(50,50,3);
%     tmp(:,:,1) = rgb(k(cLocs(i,10)), 1) * 255;
%     tmp(:,:,2) = rgb(k(cLocs(i,10)), 2) * 255;
%     tmp(:,:,3) = rgb(k(cLocs(i,10)), 3) * 255;
%     assigned = vertcat(assigned, tmp);
% end
% achual = horzcat(achual, assigned);
% figure; imshow(uint8(achual));

%%
colours = vertcat(colours, colours2);
colourScores = zeros(size(colours, 1), size(colours, 2));
lightScores = zeros(size(colours, 1), size(colours, 2));
for i = 1:size(colours, 1)
    for j = 1:size(colours, 2)
        min = inf;
        loc = -1;
%         for z = 1:size(k, 1)
           
            li = rgb2lab([colours(i,j,1) / 255, colours(i,j,2)/255, colours(i,j,3)/255], 'ColorSpace', 'adobe-rgb-1998');
            lightScores(i, j) = li(1);
            
%             li(1) = 70;
%             t = lab2rgb(li);
%             t(t > 1) = 1;
%             t(t < 0) = 0;
%             a = rgb2hsv(t);
%             t = rgb2hsv([colours(i,j,1) / 255, colours(i,j,2)/255, colours(i,j,3)/255]);
            colourScores(i, j) = atan2(li(3), li(2));
            
%         end
    end
end
colourScores = rad2deg(colourScores);
colourScores(colourScores < 0) = 360 - abs(colourScores(colourScores < 0));

[t3, p, ci, stat] = ttest(lightScores, 50, 'Tail', 'Both', 'Alpha', 0.05/10);
[t2, p2, ci2, stat2] = ttest(colourScores, 180.5, 'Tail', 'Both', 'Alpha', 0.05/10);

[tbl,chi2,p3,labels] = crosstab(round((colourScores(:) / max(colourScores(:)) * 14)), repelem(odours,size(colourScores, 1)));
[tbl,chi22,p4,labels] = crosstab(round((lightScores(:) / max(lightScores(:)) * 10)), repelem(odours,size(lightScores, 1)));
%%
store = zeros(50, 10);
freq = zeros(9, 10);
for i = 1:10
    [t, ~, tc] = unique(cLocs(:, i));
    count = accumarray(tc,1);
    t(count < 3) = [];
    count(count < 3) = [];
%     freq(1:size(count, 1), i) = count;
    [a, s] = sort(count,'descend');
    freq(1:size(count, 1), i) = a;
    if i == 9
        store(1:size(t,1)-1, i) = t(s(2:end));
         freq(1:size(count, 1)-1, i) = a(2:end);
    else
        store(1:size(t,1), i) = t(s);
         freq(1:size(count, 1), i) = a;
    end
%     store(1:size(t,1), i) = t(s);
end
freq = flipud(freq);


% store(1, 9) = store(2,9);
% store(2, 9) = store(3, 9);
% store(3, 9) = 0;
m = -inf;
for i = 1:10
    if nnz(store(:, i)) > m
       m = nnz(store(:, i));
    end
end
palette = store(1:m, :);
palette(palette == 0) = size(k, 1);

t = zeros(size(palette, 1)*50, 10*50);

CommonColours = zeros(size(palette, 1), 10, 3);

for i = 1:10
   for j = 1:size(palette, 1)
       t(j*50-49:j*50, i*50-49:i*50, 1) = rgb(k(palette(j,i)), 1);
       t(j*50-49:j*50, i*50-49:i*50, 2) = rgb(k(palette(j,i)), 2);
       t(j*50-49:j*50, i*50-49:i*50, 3) = rgb(k(palette(j,i)), 3);
       
       CommonColours(j,i,1) = rgb(k(palette(j,i)), 1)*255;
       CommonColours(j,i,2) = rgb(k(palette(j,i)), 2)*255;
       CommonColours(j,i,3) = rgb(k(palette(j,i)), 3)*255;
   end
end
CommonColours = flipud(CommonColours);
% xlabs =  odours;
% xlabs(t2 == 1) = append(xlabs(t2 == 1), '{\color{red}*}');
% xlabs(t3 == 1) = append(xlabs(t3 == 1), '{\color{blue}*}');
% subplot(2, 1, 2);
%%
figure;
imshow(flipud(t));
set(gca, 'visible', 'on')
set(gca,'XTick',25:50:500,...
    'XTickLabel',odours,...
    'YTick', [], ...
    'TickLength',[0 0],...
    'FontName', 'Helvetica', ...
    'FontSize', 15, ...
    'FontWeight', 'Bold', 'XColor', [0 0 0], 'YColor', [0 0 0]);
xtickangle(90)
title('Common Colours');
% annotation('arrow',[0 0],[0, 50 * m]);
ylabel(' \Leftarrow Frequency');
%% Common hues
cHues = zeros(size(palette,1), size(palette,2));
C = zeros(size(palette,1), size(palette,2));
for i = 1:size(cHues, 1)
    for j = 1:size(cHues, 2)
        l = rgb2lab(rgb(k(palette(i, j)), :), 'ColorSpace', 'adobe-rgb-1998');
%         l(1) = 50;
        t = lab2rgb(l);
        t(t > 1) = 1;
        t(t < 0) = 0;
        cHues(i, j) = atan2(l(3), l(2));
        C(i, j) = sqrt(l(2)^2+l(3)^2);
%         a = rgb2hsv(t);
%         
%         cHues(i, j) = a(1)*360;
    end
end
cHues = rad2deg(cHues);
cHues(cHues < 0) = 360 - abs(cHues(cHues < 0));
%%

X1 = -128:0.1:127;
Y1 = -128:0.1:127;
Z1 = zeros(1, size(-128:0.1:127, 2));

X = [];
Y = [];
Z = [];

for i = 60:85
    X = horzcat(X, X1);
    Y = horzcat(Y, Y1);
    Z = horzcat(Z, zeros(1, size(Z1, 2)) + i);
end

X2 = [];
Y2 = [];
Z2 = [];
for r = 0:0.05:1
    X2 = horzcat(X2, rescale(cos(X), r*-128, r*127));
    Y2 = horzcat(Y2, rescale(sin(Y), r*-128, r*127));
    Z2 = horzcat(Z2, Z);
end

rgb = lab2rgb([Z2', X2', Y2']);
rgb(rgb > 1) = 1;
rgb(rgb < 0) = 0;
k = boundary(X2',Y2',Z2', 0.0000001);


figure; hold on; axis equal;
in = Z2 <= 80;
k = boundary(X2(in)',Y2(in)',Z2(in)', 0.0000001);

trisurf(k, X2(in), Y2(in), Z2(in),'FaceColor','interp',...
        'FaceVertexCData',rgb(in, :),'EdgeColor','none');

xlim([-300, 300]);    
ylim([-300, 300]);


medHues = zeros(1, 10);
medC = zeros(1, 10);
for i = 1:10
    [vals, or] = sort(cHues(cHues(:, i) ~= 0, i));
    tmp2 = C(C(:, i) ~= 0, i);
    tmp2 = tmp2(or);
    
    if rem(length(vals), 2) == 1
       % Odd
       medHues(1, i) = vals(ceil(size(vals, 1)/2));
       medC(1, i) = C(ceil(size(tmp2, 1)/2));
%        medC = (1, i) = C()
    else
       % Even 
       medHues(1, i) = (vals(size(vals,1)/2) + vals((size(vals,1)/2)+1))/2;
       medC(1, i) = (C(size(tmp2, 1)/2) + vals((size(tmp2,1)/2)+1))/2;
    end
%     medHues(1, i) = median(cHues(cHues(:, i) ~= 0, i));
end

for i = 1:10
    x = 127 * cos(deg2rad(medHues(i)));
    y = 127 * sin(deg2rad(medHues(i)));
    plot3(x,y,80, 'k.', 'MarkerSize', 10);
%     text(x, y, 80, odours(i), 'Rotation', medHues(i), 'FontWeight', 'Bold', 'FontSize', 15);
    if i == 9
         text(x- 5, y-5, 80, odours(i), 'Rotation', medHues(i), 'FontWeight', 'Bold', 'FontSize', 15);
    elseif i == 10
         text(x - 5, y+5, 80, odours(i), 'Rotation', medHues(i), 'FontWeight', 'Bold', 'FontSize', 15);
    else
         text(x, y, 80, odours(i), 'Rotation', medHues(i), 'FontWeight', 'Bold', 'FontSize', 15);
    end
end

set(gca, 'FontName', 'Helvetica', 'FontSize', 15, 'FontWeight', 'Bold', ...
    'XColor', [1, 1, 1], 'YColor', [1, 1, 1], 'XTick', [], 'YTick', []);
title('Median Hue Angles');


%% Colour Dependency
correct = strcmp(vertcat(guess, guess2), repmat(odours', size(vertcat(guess, guess2), 1), 1));
%% Colours
% colours = strtrim(colours);
% colours = strrep(colours, '[', '');
% colours = strrep(colours, ']', '');
% colours =  str2double(split(colours, ' '));
% colours2 = strtrim(colours2);
% colours2 = strrep(colours2, '[', '');
% colours2 = strrep(colours2, ']', '');
% colours2 =  str2double(split(colours2, ' '));

[r,g,b] = meshgrid(linspace(0,1,7.8));
rgb = [r(:), g(:), b(:)];
lab = rgb2lab(rgb, 'ColorSpace', 'adobe-rgb-1998');
a = lab(:,2);
b = lab(:,3);
L = lab(:,1);
k = boundary(a,b,L);
figure; hold on; grid on;
subplot(2, 1, 1); 
figure;
hold on; grid on;
% plot3(a(k), b(k), L(k), '.', 'MarkerFaceColor', rgb(k, :));
t = trisurf(k,a,b,L,...
    'FaceVertexCData',rgb, 'FaceAlpha',0.1,'EdgeColor','none', 'FaceColor','interp');

tmp = find(rgb(:,1) == rgb(:,2));
tmp2 = find(rgb(tmp,2) == rgb(tmp, 3));
grays = horzcat(tmp(tmp2), tmp(tmp2), tmp(tmp2));

k = vertcat(k, grays);
for i = 1:size(k, 1)
    plot3(a(k(i)), b(k(i)), L(k(i)), '.', 'MarkerSize', 25, 'MarkerEdgeColor', rgb(k(i), :));
end
xlabel('a*'); ylabel('b*'); zlabel('L*');
title('L*a*b* Colour Gamut');
set(gca, 'FontName', 'Helvetica', 'FontSize', 15, 'FontWeight', 'Bold', ...
    'XColor', [0, 0, 0], 'YColor', [0, 0, 0]);

cLocs2 = zeros(size(colours, 1) + size(colours2, 1), size(colours, 2) + size(colours2, 2));
% tmp = vertcat(colours, colours2);
tmp = colours;

for i = 1:size(tmp, 1)
   for j = 1:size(tmp, 2)
       if correct(i,j) == 0
           min = inf;
           loc = -1;
           for z = 1:size(k, 1)
               c = rgb2lab([tmp(i,j,1) / 255, tmp(i,j,2)/255, tmp(i,j,3)/255], 'ColorSpace', 'adobe-rgb-1998');
               %            deltaE = lab(k(i), :)
               %            deltaE = sqrt(sum((c - lab(k(z), :)) .^ 2));
               deltaE = deltaE2000(c, lab(k(z), :));
               if deltaE < min
                   min = deltaE;
                   cLocs2(i, j) = z;
               end
           end
       end
   end
end
%%
store = zeros(50, 10);

for i = 1:10
    [t, ~, tc] = unique(cLocs2(:, i));
    count = accumarray(tc,1);
    t(count < 3) = [];
    count(count < 3) = [];
    [a, s] = sort(count,'descend');
    if i == 9
        store(1:size(t,1)-1, i) = t(s(2:end));
    else
        store(1:size(t,1), i) = t(s);
    end
end


% store(1, 9) = store(2,9);
% store(2, 9) = store(3, 9);
% store(3, 9) = 0;
m = -inf;
for i = 1:10
    if nnz(store(:, i)) > m
       m = nnz(store(:, i));
    end
end
palette = store(1:m, :);
palette(palette == 0) = size(k, 1);

t = zeros(size(palette, 1)*50, 10*50);

for i = 1:10
   for j = 1:size(palette, 1)
       t(j*50-49:j*50, i*50-49:i*50, 1) = rgb(k(palette(j,i)), 1);
       t(j*50-49:j*50, i*50-49:i*50, 2) = rgb(k(palette(j,i)), 2);
       t(j*50-49:j*50, i*50-49:i*50, 3) = rgb(k(palette(j,i)), 3);
   end
end
t(1:50, :,:) = [];
figure;
imshow(flipud(t));
set(gca, 'visible', 'on')
set(gca,'XTick',25:50:500,...
    'XTickLabel',odours,...
    'YTick', [], ...
    'TickLength',[0 0],...
    'FontName', 'Helvetica', ...
    'FontSize', 15, ...
    'FontWeight', 'Bold', 'XColor', [0 0 0], 'YColor', [0 0 0]);
xtickangle(90)
title({'Common Colours For', 'Misclassified Odours'});
% annotation('arrow',[0 0],[0, 50 * m]);
ylabel(' \Leftarrow Frequency');

%% Chi Squere Test Colour
before = [4, 6, 7, 7, 4, 5, 9, 7 , 7, 4];
after = [4, 4, 0, 2, 4, 2, 0, 1, 0, 4];

for i = 1:10
    n1 = before(i); N1 = before(i);
    n2 = after(i); N2 = before(i);
    % Pooled estimate of proportion
    p0 = (n1+n2) / (N1+N2);
    % Expected counts under H0 (null hypothesis)
    n10 = N1 * p0;
    n20 = N2 * p0;
    % Chi-square test, by hand
    observed = [n1 N1-n1 n2 N2-n2];
    expected = [n10 N1-n10 n20 N2-n20];
    chi2stat = sum((observed-expected).^2 ./ expected);
    pval = 1 - chi2cdf(chi2stat,1);
    
    if pval <= 0.05
        fprintf('%s, %0.5f, %0.5f\n', odours(i), pval, chi2stat);
    end
end
%% PCA Graph

crs = zeros(10, 3);
crs(1, :) = [128/255, 0, 0];
crs(2, :) = [245/255, 130/255, 48/255];
crs(3, :) = [225/255,225/255,25/255];
crs(4, :) = [60/255, 180/255, 75/255];
crs(5, :) = [128/255,128/255,128/255];
crs(6, :) = [0,0,0];
crs(7, :) = [145/255,30/255,180/255];
crs(8, :) = [1,128/255, 0];
crs(9, :) = [170/255,255/255, 195/255];
crs(10, :) = [230/255,190/255,1];


emotionsScores = ones(size(emotions, 1), size(emotions, 2)) * -1;
vec = reshape(vec, [68 10]);

for i = 1:size(emotionsScores, 1)
    for j = 1:size(emotionsScores, 2)
        if strcmp(vec(i,j), "Angry")
            emotionsScores(i, j) = 1;
        elseif strcmp(vec(i,j), "Sad")
            emotionsScores(i, j) = 2;
        elseif strcmp(vec(i,j), "Bored")
            emotionsScores(i, j) = 3;
        elseif strcmp(vec(i,j), "Disgust")
            emotionsScores(i, j) = 4;
        elseif strcmp(vec(i,j), "Scared")
            emotionsScores(i, j) = 5;
        elseif strcmp(vec(i,j), "Neutral")
            emotionsScores(i, j) = 5.5;
        elseif strcmp(vec(i,j), "Other")
            emotionsScores(i, j) = 0;
        elseif strcmp(vec(i,j), "Aroused")
            emotionsScores(i, j) = 7;
        elseif strcmp(vec(i,j), "Excited")
            emotionsScores(i, j) = 8;
        elseif strcmp(vec(i,j), "Happy")
            emotionsScores(i, j) = 9;
        elseif strcmp(vec(i,j), "Calm")
            emotionsScores(i, j) = 10;
        end
    end
end


mat = zeros(7, 10);
m = mode(categorical(genre));
l = unique(genre);

for i = 1:size(mat, 1)
    t = double(strcmp(string(m), l(i)));
    mat(i, :) = double(strcmp(string(m), l(i)));
end
% m = mode(catagorical(genre))
% dummyvar(categorical(genre(:)))
%%
t = categorical(repmat(odours', 60, 1));
figure; hold off;
cm = confusionchart(t(:), categorical(guess(:)));
cl = cm.ClassLabels;
cm = cm.NormalizedValues;
close(gcf);
cm(not(sum(cm, 2) > 1), :) = [];
accs = (cm(logical(eye(10)))/size(guess, 1)) * 100;

% 
lightScores = round(lightScores, 2);
% Ignore the neutral option
lightScores(lightScores == 100) = NaN;
% Ignore the values where the slider wasn't adjusted (i.e they didnt care about the lightness)
lightScores(lightScores < 51 & lightScores > 49) = NaN;

pcaDataset = vertcat(mean(vertcat(shapeScores, shapeScores2)), mean(vertcat(textureScores, textureScores2)), mean(vertcat(pleasentnessScores, pleasentnessScores2)), ...
    mean(pitchScores), nanmean(lightScores), accs')';

pcaDataset = horzcat(pcaDataset, cmG, cmE);
 
pcaDataset = zscore(pcaDataset);
[coeff,score,latent,tsquared,explained,mu] = pca(pcaDataset);

figure; hold on; grid on;
for i = 1:10
    plot3(score(i, 1), score(i, 2), score(i, 3), 'k.', 'MarkerSize', 25);
    text(score(i, 1)+ 0.3, score(i, 2),score(i, 3), odours(i), 'FontSize',10, 'FontWeight', 'Bold', 'FontName', 'Helvetica');
end
xlabel('PC 1'); ylabel('PC 2'); zlabel('PC 3');
set(gca,...
    'FontName', 'Helvetica', ...
    'FontSize', 15, ...
    'FontWeight', 'Bold', 'XColor', [0 0 0], 'YColor', [0 0 0], 'ZColor', [0 0 0]);

ylim([-6 6]); xlim([-6 6]);

% coeff(end-2, :) = [];
% [coeff,T] = rotatefactors(coeff(:,1:4), 'Method', 'Varimax');
labs = string({'Angularity', 'Smoothness', 'Pleasentness', 'Pitch', 'Lightness', 'Identification', 'Classical', 'Country', 'Jazz', 'Metal', 'Rap', 'Rock', 'Soul', 'Neutral', 'Happy', 'Sad', 'Angry', 'Aroused', 'Scared', 'Disgust', 'Calm', 'Bored', 'Excited'});
% figure; biplot(coeff(:, 1:2), 'Varlabels', labs)
figure; hold on; grid on;
% plot([-0.5 0.5], [0, 0], 'Color', [0, 0, 0], 'LineWidth', 1.5);
% plot([0 0], [-0.5, 0.5], 'Color', [0, 0, 0], 'LineWidth', 1.5);

for i = 1:size(labs, 2)
    plot(coeff(i, 1), coeff(i,2), 'k.', 'MarkerSize', 25); hold on;
    
    if strcmp(labs(i), 'Calm')
        text(coeff(i, 1)+ 0.02, coeff(i, 2) +0.02,labs(i), 'FontSize',10, 'FontWeight', 'Bold', 'FontName', 'Helvetica');
    elseif strcmp(labs(i), 'Soul')
        text(coeff(i, 1)+0.02, coeff(i, 2) + 0.015,labs(i), 'FontSize',10, 'FontWeight', 'Bold', 'FontName', 'Helvetica');
    elseif strcmp(labs(i), 'Smoothness')
        text(coeff(i, 1)+0.01, coeff(i, 2) - 0.015,labs(i), 'FontSize',10, 'FontWeight', 'Bold', 'FontName', 'Helvetica');
    elseif strcmp(labs(i), 'Identification')
        text(coeff(i, 1)+0.02, coeff(i, 2) -0.015,labs(i), 'FontSize',10, 'FontWeight', 'Bold', 'FontName', 'Helvetica');
    elseif strcmp(labs(i), 'Rap')
        text(coeff(i, 1) -0.035, coeff(i, 2) +0.04,labs(i), 'FontSize',10, 'FontWeight', 'Bold', 'FontName', 'Helvetica');
    elseif strcmp(labs(i), 'Scared')
        text(coeff(i, 1)-0.05, coeff(i, 2) +0.04,labs(i), 'FontSize',10, 'FontWeight', 'Bold', 'FontName', 'Helvetica');
    elseif strcmp(labs(i), 'Sad')
        text(coeff(i, 1)+0.02, coeff(i, 2) - 0.015,labs(i), 'FontSize',10, 'FontWeight', 'Bold', 'FontName', 'Helvetica');
    elseif strcmp(labs(i), 'Disgust')
        text(coeff(i, 1)-0.15, coeff(i, 2),labs(i), 'FontSize',10, 'FontWeight', 'Bold', 'FontName', 'Helvetica');
    else
        text(coeff(i, 1) + 0.02, coeff(i, 2),labs(i), 'FontSize',10, 'FontWeight', 'Bold', 'FontName', 'Helvetica');
    end
end

xlabel('Component 1'); ylabel('Component 2');
set(gca,...
    'FontName', 'Helvetica', ...
    'FontSize', 15, ...
    'FontWeight', 'Bold', 'XColor', [0 0 0], 'YColor', [0 0 0], 'ZColor', [0 0 0]);
ylim([-0.5 0.52]); xlim([-0.5 0.6]);
grid minor;

for i = 1:10
    n1 = sum(correct(:,i)); N1 = size(correct,1);
    n2 = sum(not(correct(:, i))); N2 = size(correct, 1);
    x1 = [repmat('a',N1,1); repmat('b',N2,1)];
    x2 = [repmat(1,n1,1); repmat(2,N1-n1,1); repmat(1,n2,1); repmat(2,N2-n2,1)];
    [tbl,chi2stat,pval] = crosstab(x1,x2);
    fprintf('%0.20f\n', chi2stat);
end