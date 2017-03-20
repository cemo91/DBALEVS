function Xnorm = normalize_data(X,m,v)
n= size(X,1);
d = size(X,2);
% Xnorm = zeros(size(X));
% % make observations zero-mean and variance one
meanX = full(m);
stdvX = full(v);
stdvX(stdvX < 10^(-5)) = 1; % avoid division by 0
Xnorm = (X - repmat(meanX, n, 1))./repmat(stdvX, n, 1);

% minX = min(X);
% maxX = max(X);
% ind = (minX ~= maxX);
% 
% Xnorm(:,ind) = (X(:,ind) - repmat(minX(:,ind),n,1))./repmat(maxX(:,ind)-minX(:,ind),n,1);
% scales the rows of X so they all have norm 1 
Xnorm = Xnorm ./ repmat(sqrt(sum(Xnorm.*Xnorm, 2)), 1, d);

end