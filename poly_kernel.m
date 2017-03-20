function K = poly_kernel(X,d,c)
    K=((X'*X)+c).^d;
end