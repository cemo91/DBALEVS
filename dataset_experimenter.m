load(dataset{d});
load(random_indices{d});
load(init_pool{d});
exp_count = 50;
initial_pool = 4;

b_size = 10;
iter = 30;

training_data = zeros(ceil(size(X,1)/2),size(X,2));
training_indices = zeros(size(training_data,1),1);
training_label = zeros(size(training_data,1),1);
test_data = zeros((size(X,1)-size(training_data,1)),size(X,2));

accuracy = zeros(exp_count,1);
accuracy_dbalevs = zeros(iter,exp_count);
accuracy_random = zeros(iter,exp_count);
accuracy_uncertainty = zeros(iter,exp_count);
accuracy_topleverage = zeros(iter,exp_count);
accuracy_nearopt = zeros(iter,exp_count);

time_dbalevs = zeros(iter,exp_count);
time_random = zeros(iter,exp_count);
time_uncertainty = zeros(iter,exp_count);
time_nearopt = zeros(iter,exp_count);
time_topleverage = zeros(iter,exp_count);
time_topleverage_compute = zeros(exp_count,1);

classifier_kernel = 'rbf';

for t=1:exp_count
    disp(['t=' num2str(t)]);
    r_ind = randomize(:,t);
    training_data = X(r_ind, :);
    training_indices = r_ind;
    training_label = y(r_ind);
    count = 1:size(X,1);
    count = setdiff(count,training_indices);
    test_data = X(count,:);
    test_label = y(count);

    m = mean(training_data);
    v = std(training_data);
    
    training_data_scaled = normalize_data(training_data, m, v);
    test_data_scaled = normalize_data(test_data,m,v);
    
    clear training_data
    clear test_data

%     upper = size(training_data,1);
%     initial_labeled_indices = randperm(upper, initial_pool)';
%     while sum(training_label(initial_labeled_indices)) ~= 0
%         initial_labeled_indices = randperm(upper, initial_pool)';
%     end
%     initial_indices(t) = {initial_labeled_indices};
 

    initial_labeled_indices = initial_indices{t};
    
    
    params_name = ['parameters/params_' names{d}];
    load(params_name);
    normalize = 0;
    if d == 1
        lambda = 0.1;
    else
        lambda = 1;
    end
    
    disp('random');
    run('random');
    
    disp('uncertainty');
    run('uncertainty');
    
    disp('top leverage');
    run('top_leverage_query');
    
    disp('DBALEVS');
    run('DBALEVS_query');
    
    disp('Near Optimal');
    run('near_opt');
    
end
