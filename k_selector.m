function k = k_selector(eig_vals,threshold)
    k = 1;
    eig_vals = sort(eig_vals,'descend');
%     eig_vals = eig_vals./max(eig_vals);
    while (sum(eig_vals(1:k))/sum(eig_vals)) < threshold
        k = k+1;
    end
%     while  eig_vals(k) > threshold 
%         k = k+1;
%     end
end