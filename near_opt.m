labeled_indices = initial_labeled_indices;
unlabeled_indices = setdiff((1:size(training_data_scaled,1))', labeled_indices);

n_hypoteses = 300;
score_function = 'gbs';
max_labels = b_size*iter;
learning_method = 'active';
predict_model = 'svm';

[query, time_nearopt_exp] = batch_active(training_data_scaled(unlabeled_indices,:)', training_label(unlabeled_indices)', n_hypoteses, score_function, b_size, max_labels, learning_method, predict_model);

for i=1:iter
    labeled_indices = [initial_labeled_indices;query(1:i*b_size)'];
    [~,~,accuracy_temp,~,~] = process_svm(training_data_scaled(labeled_indices,:),training_label(labeled_indices),test_data_scaled,test_label,0,classifier_kernel);
    accuracy_nearopt(i,t) = accuracy_temp(1);
    if i==1
        time_nearopt(i,t) = time_nearopt_exp(i*b_size);
    else
        time_nearopt(i,t) = time_nearopt_exp(i*b_size) - time_nearopt_exp((i-1)*b_size);
    end
end