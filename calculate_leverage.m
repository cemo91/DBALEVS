function [lev, eig_val, k, c_lev] = calculate_leverage(matrix,perc)
    [V,D] = eig(matrix);
    eig_val = diag(D);
    [~,idx] = sort(diag(D),1,'descend'); % D nin diagonal elementlerini sort et
    V = V(:, idx); % V yi D deki siraya gore sort et
    
    %k-selection
    k = k_selector(eig_val,perc);
%     k = size(matrix,1);

    U1 = V(:,1:k);
%     lev = zeros(size(matrix,1),1);
%     for j=1:size(matrix,1)
%        lev(j) = (norm(U1(j,:)))^2;
%     end
    
    c_lev = U1*U1';
%     lev = diag(c_lev).*(size(matrix,1)/k);
    lev = diag(c_lev);
end