labeled_indices = initial_labeled_indices;
unlabeled_indices = setdiff((1:size(training_data_scaled,1))', labeled_indices);

for i=1:iter
    tstart = tic;
    query = uncertainty_sampling(training_data_scaled,training_label,labeled_indices,unlabeled_indices,b_size,classifier_kernel);
    time_uncertainty(i,t) = toc(tstart);
    labeled_indices=[labeled_indices;query];
    unlabeled_indices = setdiff(unlabeled_indices, query);
    [~,~,accuracy_temp,~,~] = process_svm(training_data_scaled(labeled_indices,:),training_label(labeled_indices),test_data_scaled,test_label,0,classifier_kernel);
    accuracy_uncertainty(i,t) = accuracy_temp(1);
end