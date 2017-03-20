function K = RBF_kernel(dist, sigma)
% RBF kernel
K = zeros(size(dist));
for row=1:size(dist,1)
    K(row, :) = exp(-dist(row,:)/sigma^2);
end

end