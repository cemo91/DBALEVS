function [index] = DBALEVS(data_scaled,label,index_labeled,index_unlabeled,thresh,ker_type,sigma,degree,coefficient,batch_size,lambda,cl_kernel)
    
    %[,top_leverage,d1,d2,c_pos,c_neg,k_pos,k_neg,pos_size,neg_size,predicted_label]
    
    [~,prediction,~,~,~] = process_svm(data_scaled(index_labeled,:),label(index_labeled),data_scaled(index_unlabeled,:),label(index_unlabeled),0,cl_kernel);
    indices_positive = [index_unlabeled(prediction == 1);index_labeled(label(index_labeled) == 1)];
    indices_negative = [index_unlabeled(prediction == -1);index_labeled(label(index_labeled) == -1)];
    
    is_unlabeled_pos = [ones(size(index_unlabeled(prediction == 1),1),1);zeros(size(index_labeled(label(index_labeled) == 1),1),1)];
    is_unlabeled_neg = [ones(size(index_unlabeled(prediction == -1),1),1);zeros(size(index_labeled(label(index_labeled) == -1),1),1)];
    
    labeled_pos_count = sum(~(is_unlabeled_pos));
    labeled_neg_count = sum(~(is_unlabeled_neg));
    
    if strcmp(ker_type, 'rbf')
        positive_kernel = RBF_kernel(get_distance(data_scaled(indices_positive,:)),sigma);
        negative_kernel = RBF_kernel(get_distance(data_scaled(indices_negative,:)),sigma);
    elseif strcmp(ker_type, 'lin')
        positive_kernel = linear_kernel(data_scaled(indices_positive,:));
        negative_kernel = linear_kernel(data_scaled(indices_negative,:));
    elseif strcmp(ker_type, 'poly')
        positive_kernel = poly_kernel(data_scaled(indices_positive,:),degree,coefficient);
        negative_kernel = poly_kernel(data_scaled(indices_negative,:),degree,coefficient);
    end
    
    pos_size = size(positive_kernel,1);
    neg_size = size(negative_kernel,1);
    
    [positive_leverage,~,low_rank_pos,~] = calculate_leverage(positive_kernel,thresh);
    [negative_leverage,~,low_rank_neg,~] = calculate_leverage(negative_kernel,thresh);
    
    
    k = (batch_size/2);
    set_size_pos = 1/(sum(~is_unlabeled_pos) + k);
    V_sigma = 1:pos_size;
    F_lev = sfo_fn_leverage(positive_leverage,positive_kernel,lambda,set_size_pos,V_sigma);
    C = ones(1,length(V_sigma)); % unit cost
    opt = sfo_opt({'cost', C, 'greedy_initial_set', [(sum(is_unlabeled_pos)+1):pos_size]});
    
    [index_pos,scores,evals_s] = sfo_greedy_lazy(F_lev,V_sigma,k,opt);

    index_pos = indices_positive(index_pos(labeled_pos_count+1:end)');
    
    
    
    set_size_neg = 1/(sum(~is_unlabeled_neg) + k);
    V_sigma = 1:neg_size;
    F_lev = sfo_fn_leverage(negative_leverage,negative_kernel,lambda,set_size_neg,V_sigma);
    C = ones(1,length(V_sigma)); % unit cost
    opt = sfo_opt({'cost', C, 'greedy_initial_set', [(sum(is_unlabeled_neg)+1):neg_size]});
    
    [index_neg,scores,evals_s] = sfo_greedy_lazy(F_lev,V_sigma,k,opt);

    index_neg = indices_negative(index_neg(labeled_neg_count+1:end)');
    index = [index_pos;index_neg];
    disp(['size of returned set: ' num2str(size(index,1))]);
end
