function dist  = get_distance(X )
% Centers and makes std dev of points 1 
% before calculations

% The rows of X are the observations x_i
% Returns dist so the (ij)th entry is norm(x_i-x_j)^2

n = size(X,1);
% m = mean(X);
% stdv = std(X);
% Xscaled = (X - repmat(m, n, 1))./repmat(stdv, n, 1);
Xscaled = X;
dist = zeros(n, n);
%parfor
for row = 1:n
    r = (Xscaled - repmat(Xscaled(row, :),n,1))';
    dist(row, :) = sum(r.^2);
end