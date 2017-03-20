function index = uncertainty_sampling(data,label,index_labeled,index_unlabeled,batch_size,ker)
    [~,~,~,posterior,~] = process_svm(data(index_labeled,:),label(index_labeled),data(index_unlabeled,:),label(index_unlabeled),1,ker);
    confidence = (abs(posterior(:,1) - 0.5) + abs(posterior(:,2) - 0.5))./2;   
    [~,idx] = sort(confidence,'descend');   
    sorted_unlabeled = index_unlabeled(idx,:);   
    index = sorted_unlabeled(1:batch_size,:);
end