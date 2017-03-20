function newScore = inc(F,A,el)
A = sfo_unique_fast(A);
F = init(F,A);

if sum(A==el)>0
    newScore = get(F,'current_val');
%     newScore = -inf;
    return;
end

if (isempty(A))
    ker_sset = F.ker(el,el);
    f_lev = sum(F.lev(el) + ones(size(F.lev(el)))) - (F.lambda*F.s_size*(sum(sum(triu(ker_sset-diag(diag(ker_sset)))))));
else
    A_n = [A el];
    ker_sset = F.ker(A_n,A_n);
    f_lev = sum(F.lev(A_n) + ones(size(F.lev(A_n)))) - (F.lambda*F.s_size*(sum(sum(triu(ker_sset-diag(diag(ker_sset)))))));
end

newScore = f_lev;