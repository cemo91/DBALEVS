

labeled_indices = initial_labeled_indices;
unlabeled_indices = setdiff((1:size(training_data_scaled,1))', labeled_indices);

for i=1:iter
    tstart = tic;
    query_indices = (unlabeled_indices(randperm(size(unlabeled_indices,1),b_size)));
    time_random(i,t) = toc(tstart);
    labeled_indices = [labeled_indices; query_indices];
    unlabeled_indices = setdiff(unlabeled_indices, query_indices);
    
    [~,~,accuracy_temp,~,~] = process_svm(training_data_scaled(labeled_indices,:), training_label(labeled_indices), test_data_scaled, test_label, 0,classifier_kernel);
    accuracy_random(i,t) = accuracy_temp(1);
end