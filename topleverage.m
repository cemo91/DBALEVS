function [index] = topleverage(leverage_scores,index_unlabeled,batch_size)
    unlabeled_leverage = leverage_scores(index_unlabeled);
    [~,idx] = sort(unlabeled_leverage,'descend');
    index_unlabeled = index_unlabeled(idx);
    index = index_unlabeled(1:batch_size);    
end