function [F,f_lev] = init(F,sset)
sset = sfo_unique_fast(sset);

if ~isequal(sset,get(F,'current_set'))
    if isempty(sset)
        f_lev = 0;
    else
        ker_sset = F.ker(sset,sset);
        f_lev = sum(F.lev(sset) + ones(size(F.lev(sset)))) - (F.lambda*F.s_size*(sum(sum(triu(ker_sset-diag(diag(ker_sset)))))));
    end
    F = set(F,'current_val',f_lev,'current_set',sset);
else
    f_lev = get(F,'current_val');
end
