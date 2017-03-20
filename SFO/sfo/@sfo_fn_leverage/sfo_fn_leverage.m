function F = sfo_fn_leverage(leverage,kernel,lambda,set_size,V)
F.lev = leverage;
F.ker = kernel;
F.s_size = set_size;
F.lambda = lambda;
F.V = V;

F.indsA = [];
F.invAc = [];
F.indsAc = [];
F.cholA = [];

F = class(F,'sfo_fn_leverage',sfo_fn);
F = set(F,'current_set',-1);
