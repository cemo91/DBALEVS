labeled_indices = initial_labeled_indices;
unlabeled_indices = setdiff((1:size(training_data_scaled,1))', labeled_indices);

disp(kernel_type);

for i=1:iter
    disp(['iteration' num2str(i)]);
    tstart = tic;
    query = DBALEVS(training_data_scaled,training_label,labeled_indices,unlabeled_indices,eig_threshold,kernel_type,sigma,deg,coeff,b_size,lambda,classifier_kernel);
    time_dbalevs(i,t) = toc(tstart);
    labeled_indices = [labeled_indices;query];

    unlabeled_indices = setdiff(unlabeled_indices, query);
    [~,~,accuracy_temp,~,~] = process_svm(training_data_scaled(labeled_indices,:),training_label(labeled_indices),test_data_scaled,test_label,0,classifier_kernel);
    accuracy_dbalevs(i,t) = accuracy_temp;
end
