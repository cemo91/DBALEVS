function [ Indices, CPU_Times ] = batch_active( X, Y_orig, ...
    m, score_function, batch_size, max_labels, learning_method, predict_model)
    
% , Scores, Mistakes, F1, CPU_Times 

% BATCH_ACTIVE The batch-mode (greedy) active learning algorithm.
% c.f., "Near-optimal batch mode active learning and adaptive submodular
% optimization", Yuxin Chen and Andreas Krause, ICML'13.
%
%   batch_active(...) implements an active learning learning algorithm, that
%   iteratively selects the best data point within a batch of size batch_size, 
%   requests the labels after obatin batch_size data points, and then resample 
%   the versions space using hit-and-run algorithm.
%
    % the 'noise' parameter as input for the approximated hit-and-run sampler
    epsilon = 0.02;
    
    % add one dimension to dataset as bias term
    biased = true; 
    
    time0 = cputime;
    cpu_time = 0;

    % debug settings
    [dim, T] = size(X);
    T_active = min([max_labels T]);

    Indices = zeros(1, T_active);
    Scores = zeros(1, T_active);
    Mistakes = zeros(1, T_active);
    F1 = zeros(1, T_active);
    CPU_Times = zeros(1, T_active);
    
    Unlabeled = true(1, T);
    
    X_labeled = [];
    Y_labeled = [];
    
    if biased
        X_selected = [X_labeled; ones(1, size(X_labeled, 2))];
        Y_selected = Y_labeled;
    else
        X_selected = X_labeled;
        Y_selected = Y_labeled;
    end
    
    % an additional dimension account for halfspaces with a bias
    if biased
        W_resampled = hitandrun_sampler(m, zeros(dim+1,1), 0, epsilon);
        biasX = ones(1,T);
    else
        W_resampled = hitandrun_sampler(m, zeros(dim,1), 0, epsilon);
        biasX = [];
    end
    
    X_Biased = [X; biasX];
    underlying_W = W_resampled;
    
    % temporary variables for BMAL algorithm (using hit-and-run algorithm 
    % for version space sampling) 
    partitions = zeros(m, T);
    current_partitions = zeros(m, T);
    partition_inds = zeros(m, T);
    max_num_partitions = min(m, 2^batch_size);
    equivalent_partitions_stat = zeros(max_num_partitions, T);
    equivalent_partitions_probability = zeros(max_num_partitions, T);
    equivalent_partitions_eliminated = zeros(max_num_partitions, T);
    
   
    index = 0;
    score = 0;
    svm_start_index = 1;
    
    
    % run algorithm
    for t=1:T_active
        
        b = mod(t, batch_size);
        if b == 1
            disp('new batch');
        end
        disp(num2str(t));
        
        switch score_function
            % generalized binary search
            case {'gbs'}
                % at the beginning of each batch
                if b == 1 || batch_size == 1
                    partitions = (W_resampled'*X_Biased) >= 0;
                    
                    % all hypotheses induce the same labeling on the
                    % unlabeled pool
                    if range(partitions,1) == 0;
                        % no updates. fill the result vector with the last
                        % value calculated
                        k = find(Indices == 0, 1);
                        Indices(k:end)=index;
                        Scores(k:end) = score;
                        Mistakes(k:end) = Mistakes(t-1);
                        F1(k:end)=F1(t-1);
                        CPU_Times(k:end) = CPU_Times(t-1);
                        break;
                    end
                    last_partitions = zeros(m, 1);
                end
                
                current_partitions = bsxfun(@plus, last_partitions, 2^(b-1) * partitions);
                %
                % first node of a batch, use the gbs function
                for i = 1:T
                    [~, ~, partition_inds(:,i)] = unique(current_partitions(:,i));
                end
                sample_index = bsxfun(@times, 1:size(current_partitions,2), ones(size(current_partitions)));
                sub = [partition_inds(:), sample_index(:)];
                equivalent_partitions_stat = accumarray(sub, 1, [max_num_partitions, T]);
                
                equivalent_partitions_probability = bsxfun(@rdivide, equivalent_partitions_stat, sum(equivalent_partitions_stat));
                equivalent_partitions_eliminated = 1 - equivalent_partitions_probability;
                
                s = sum(equivalent_partitions_probability .* equivalent_partitions_eliminated);
                
                [sort_s, sort_i] = sort(s, 'descend');
                sort_ul = Unlabeled(sort_i);
                
                % find the best unlabeled sample
                ind = find(sort_ul, 1, 'first');
                
                score = sort_s(ind);
                index = sort_i(ind);
                
                last_partitions = current_partitions(:, index);
                
            case 'random'
                s = rand(1, T);
                % find best score
                [score, index] = min(s);
            otherwise
                error('invalid score_function parameter');
        end
        
        % label the data (will not be chosen in the future)
        Unlabeled(index) = false;
        
        % receive test results
        x = X(:, index);
        y = Y_orig(index);
        
        % constraints
        X_labeled = [X_labeled x];
        Y_labeled = [Y_labeled y];
        
        if strcmp(score_function, 'random') && strcmp (score_function, 'svm')
            % do nothing: don't need to update particle model   
        else
            %% update underlying hyphotheses model
            % =============================================================
            if biased
                X_selected = [X_labeled; ones(1, size(X_labeled, 2))];
                Y_selected = Y_labeled;
            else
                X_selected = X_labeled;
                Y_selected = Y_labeled;
            end
            underlying_W = hitandrun_sampler(m, X_selected, Y_selected, epsilon);

            %% =============================================================
            % keep track of the current version space distribution at the end of a batch:
            if b == 0
                if strcmp( learning_method, 'active')
                    
                    % update the particle model
                    W_resampled = underlying_W;
                elseif strcmp (learning_method, 'passive')
                    % "passive" learning: directly sample from prior. Normal
                    W_resampled = randn(dim, m);
                    
                    for i=1:m
                        W_resampled(:,i) = particle_normalize(W_resampled(:,i), 'one');
                    end
                else
                    error('invalid learning method parameter');
                end
                
            end
        end
        %%
        
        % do not count time to update posterior and calculate mistakes
        cpu_time = cpu_time + (cputime - time0);
        CPU_Times(t) = cpu_time;
        
%         % predict model
%         switch predict_model
%             
%             % majority vote
%             case 'mvote'
%                 Lw = 2*(W_resampled'*X_Biased > 0) - 1;
%                 % majority vote
%                 Lp = 2*(sum(Lw,1) > 0) - 1;
%             
%             % svm predictor 
%             case 'svm'
%                 
%                 Group = Y_orig;
%                 Group(Unlabeled) = NaN;
%                 
%                 % only use svm if there're at least two distinguished
%                 % labels in the labeled data set
%                 if length(unique(Y_orig(~Unlabeled))) < 2
%                     
%                     % randomly select another data point in the opposite class
%                     rp = randperm(T);
%                     rand_ind = rp(find((Y_orig(rp) ~= Y_orig(index)), 1, 'first'));
%                     Group(rand_ind) = Y_orig(rand_ind);
%                     
%                 end
%                 
%                 % classify using svm
%                 SVMStruct = svmtrain(X', Group);
%                 Lp = svmclassify(SVMStruct, X')';
%                 
%             otherwise
%                 error('invalid score_function parameter');
%                 
%         end
        
        Indices(t) = index;
%         Scores(t) = score;
%         [Mistakes(t), F1(t)] = f1_evaluation(Lp, Y_orig);
%         
        time0 = cputime;
    end
end

function [Mistakes, F1]= f1_evaluation(Lp, Y_orig)
    Mistakes = sum(Lp ~= Y_orig);
    
    tp = sum((Lp == 1).*(Y_orig == 1));
    % tn = sum((Lp == -1).*(Y_orig == -1));
    fp = sum((Lp == 1).*(Y_orig == -1));
    fn = sum((Lp == -1).*(Y_orig == 1));
    p = tp / (tp + fp);
    r = tp / (tp + fn);
    
    F1 = 2*p*r/(p+r);

end


