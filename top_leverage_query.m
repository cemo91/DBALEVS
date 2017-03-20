labeled_indices = initial_labeled_indices;
unlabeled_indices = setdiff((1:size(training_data_scaled,1))', labeled_indices);

disp(kernel_type);
tstart = tic;
if strcmp(kernel_type, 'rbf')
    kernel = RBF_kernel(get_distance(training_data_scaled),sigma);
elseif strcmp(kernel_type, 'lin')
    kernel = linear_kernel(training_data_scaled);
elseif strcmp(kernel_type, 'poly')
    kernel = poly_kernel(training_data_scaled,degree,coefficient);
end

[leverage_scores,~,low_rank,~] = calculate_leverage(kernel,eig_threshold);
if normalize
    leverage_scores = leverage_scores*(size(leverage_scores,1)/low_rank);
end
time_topleverage_compute(t) = toc(tstart);

for i=1:iter
    disp(['iteration' num2str(i)]);
    tstart = tic;
    query = topleverage(leverage_scores,unlabeled_indices,b_size);
    time_topleverage(i,t) = toc(tstart);
    labeled_indices = [labeled_indices;query];

    unlabeled_indices = setdiff(unlabeled_indices, query);
    [~,~,accuracy_temp,~,~] = process_svm(training_data_scaled(labeled_indices,:),training_label(labeled_indices),test_data_scaled,test_label,0,classifier_kernel);
    accuracy_topleverage(i,t) = accuracy_temp;
end