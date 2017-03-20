function main_active( dataset, score_function, m, random_trials, batch_size, max_labels, ...
    learning_method, predict_model, show_plot )

%MAIN_ACTIVE  the BMAL implementation using hit-and-run sampling algorithm.
% c.f., "Near-optimal batch mode active learning and adaptive submodular
% optimization", Yuxin Chen and Andreas Krause, ICML'13.
%
%   Input:
%       - dataset: the name of the data set to load, example values are: 
%       'australian' (default), 'wdbc'.
%       - score_function: the name of the BMAL score functions. Possible
%       values are: 'gbs' (default), 'random'
%       - m: number of hypotehses
%       - random-trials: number of random trials initiated
%       - batch_size: batch size of the BMAL algorithm
%       - max_labels: maximum number of labels queried (the cardinatility
%       constraints)
%       - learning_method: 'active' (default) or 'passive'
%       - predict_model: the prediction model we use to evaluate the
%       algorithm. Possible choices: 'svm' (default), 'mvote' (majority vote).
%       - show_plot: boolean value, if true, then plot the evaluation
%       results (e.g., the utility of selecting each point, and f1 score)
%
%   Demo: using default parameters for demonstration
%
%   Author: Yuxin Chen
%
%   Created: 09.2012

%
    close all; 
    
    if nargin < 1
       dataset = 'australian';
    end
    
    if nargin < 2
         score_function = 'gbs';
    end
    
    if nargin < 3
        m = 300;
    end
    
    if nargin < 4
        random_trials = 2;
    end
    
    if nargin < 5
%         batch_size = 3;
        batch_size = 10;
    end
    
    if nargin < 6
%          max_labels = 15;
        max_labels = 30;
    end
    
    if nargin < 7
        learning_method = 'active';
    end
    
    if nargin < 8
        predict_model = 'svm';
    end
    
    if nargin < 9
        show_plot = true;
    end
    
    [X, Y] = load_dataset(dataset, true, false);
    
    
    Indices = zeros(max_labels, 1);
    Scores = zeros(random_trials, max_labels);
    Mistakes = zeros(random_trials, max_labels);
    F1 = zeros(random_trials, max_labels);
    Times = zeros(random_trials, max_labels);
    
    [~, T] = size(X);
    
    disp(['dataset: ' dataset]);
    
    % output files
    TimeFileName = ['out/Time_' dataset '_batch' num2str(batch_size) '_p' num2str(m) '_trials' num2str(random_trials) '_' score_function '_' learning_method '_' predict_model '.txt'];
    MistakeFileName = ['out/Mistake_' dataset '_batch' num2str(batch_size) '_p' num2str(m) '_trials' num2str(random_trials) '_' score_function '_' learning_method '_' predict_model '.txt'];
    F1FileName = ['out/F1_' dataset '_batch' num2str(batch_size) '_p' num2str(m) '_trials' num2str(random_trials) '_' score_function '_' learning_method '_' predict_model '.txt'];
    
    if exist(TimeFileName, 'file')
        delete(TimeFileName);
    end
    if exist(MistakeFileName, 'file')
        delete(MistakeFileName);
    end
    if exist(F1FileName, 'file')
        delete(F1FileName);
    end
    
    
    for trial=1:random_trials
        disp(['random trial ' num2str(trial)]);
        % get random permutation for random start
        perm = randperm(T);
        
        X_perm = X(:,perm);
        Y_perm = Y(perm);
        
        % perform batch mode active learning
        [Indices(:), Scores(trial,:), Mistakes(trial,:), F1(trial, :), Times(trial,:)] = batch_active(...
            X_perm, Y_perm, m, score_function, batch_size, max_labels,...
            learning_method, predict_model);
        
        dlmwrite(TimeFileName, Times(trial,:), '-append');
        dlmwrite(MistakeFileName, Mistakes(trial,:), '-append');
        dlmwrite(F1FileName, F1(trial, :), '-append');
        
        Indices(:) = perm(Indices(:));
        
        line_styles = {'-ro', '-bx', '-g+', '-kd', '-ms', '-cp', '-y*', '-r^'};
        
    end
    
    score_avg = sum(Scores, 1)/random_trials;
    % accuracy_avg = 1 - sum(Mistakes, 1) / (random_trials * length(Y));
    f1_avg = mean(F1, 1);
    
    savefile = ['out/_' dataset '_batch' num2str(batch_size) '_p' num2str(m) ...
        '_trials' num2str(random_trials) '_' score_function '_' learning_method '_' predict_model '.mat'];
    save(savefile, 'Scores', 'Mistakes', 'F1', 'Times', 'T');
    
    if show_plot == true
        h_score = figure;
        plot(1:max_labels, score_avg(:), line_styles{1});
        hold on;
        set(gca, 'YMinorTick', 'on', 'XGrid', 'on', 'YGrid', 'on');
        set(gca,'XTick',1:max_labels);
        title(['Average score: ' dataset ', ' score_function]);
        hold off;
        saveas(h_score, ['out/_' dataset '_batch' num2str(batch_size) '_p' num2str(m) '_trials' num2str(random_trials) '_' score_function '_' learning_method '_' predict_model '_score.fig']);
        
        
        h_f1 = figure;
        plot(1:max_labels, f1_avg(:), line_styles{1});
        hold on;
        set(gca, 'YMinorTick', 'on', 'XGrid', 'on', 'YGrid', 'on');
        set(gca,'XTick',1:max_labels);
        title(['F1 performance: ' dataset ', ' score_function]);
        hold off;
        saveas(h_f1, ['out/_' dataset '_batch' num2str(batch_size) '_p' num2str(m) '_trials' num2str(random_trials) '_' score_function '_' learning_method '_' predict_model '_f1.fig']);
        
    end
end