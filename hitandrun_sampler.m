function W = hitandrun_sampler(m, X_selected, Y_selected, epsilon)
    
% HITANDRUN_SAMPLER The (noisy) Hit-and-Run sampling algorithm
% c.f., "Near-optimal batch mode active learning and adaptive submodular
% optimization", Yuxin Chen and Andreas Krause, ICML'13.
%
%   hitandrun_sampler(...) implements the noisy version of the hit-and-run
%   algorithm described in [Chen & Krause '13].
%
%   Input:
%       - m: the number of hypotheses we want to sample
%       - X_selected: [dim T] matrix, data points that have already been
%       selected 
%       - Y_selected: [1 T] matrix, the labels aquired for X_selected.
%       Therefore, the constraints are expressed as: -Y(X.W) <= 0 
%       - epsilon: the (previously known) noise level, or error rate.
%
%   Demo: run hitandrun_sampler, with no input (all default)
%
%   Author: Yuxin Chen
%
%   Created: 09.2012
%

    if nargin < 1
        % for demo only: a toy example to illusrtate the noisy hit-and-run
        % sampler 
        
        close all;  
        dim = 2;
        nl = 2; % number of constraints
        T = 200;
        m = 500;
        epsilon = 0.02;
        
        % randomly generate labeled data    
        X = randn(dim, T);
        A = X(:,1:1:nl); % suppose #nl examples are labeled, thus #nl constraints
    end % end of demo
    
    if nargin > 1
        dim = size(X_selected, 1);
        A = bsxfun(@times, -X_selected, Y_selected);
    end
    
    b = zeros(1,size(A,2));
    % m particles
    W = zeros(dim,m);
    
    % initialization
    h = zeros(dim,1);
    
    % in the noiseless case, initiate the sampler with a warm start
    if epsilon == 0
        count = 0;
        while true
            count = count+1;
            h = HitAndRun(zeros(1,dim), b', h, epsilon);
            if all(A'*h<=b') || count>5000
                break;
            end
        end
        W(:,1) = h;
    end
    
    W = NoisyHitAndRun(A',b',W, epsilon);
    
    if nargin < 1
        % we can only plot the 2d and 3d case
        plot_samples(A,W);
    end
end


function X = NoisyHitAndRun(A,b,X,epsilon)
% HIT-AND-RUN: Sampling of uniformly distributed vectors x from the convex
% body defined by a set of constraints (labeled samples) and the unit ball
    H = zeros(size(X));
    for k=1:size(X,2)-1
        x = X(:,k);
        
        if epsilon == 0
            if ~all(A*x<=b)
                error('initial point infeasible');
            end
        end

        % Generate a random direction vector (uniformly covering the surface of
        % a unit sphere)
        r = randn(size(A,2),1);
        r = r/norm(r);
        % noise free. Draw from the convex body
        if epsilon == 0
            [d_neg,d_pos] = distToConstraints(A,b,x,r);
            % a random number [-d_neg,d_pos)
            t = -d_neg+(d_pos+d_neg)*rand(1);
            
            % next sample
        else
            % choose sector according to P, then sample each circle sector uniformly
            [d_neg,d_pos] = getDistsToConstraints(A,b,x,r);

            % get the segments of g(t)=x+t*r introuduced by the convex constraints
            d_segments = unique([-d_neg; d_pos]);
            lamda = .5; % lamda \in (0,1)
            d_seg_points = lamda * d_segments(1:end-1) + (1-lamda) * d_segments(2:end); % distance to test/sample points in different segments
            cord_seg_points = x*ones(1,length(d_seg_points)) + r*d_seg_points'; % coordinates of test points

            % evaluate each segment to get its probability of being chosen: p \prop (epsilon/(1-epsilon))^k, where k is the number of 1's
            eval_seg_points = (A*cord_seg_points > 0); % or we can use '<' instead of '<='
            d_seg_len = d_segments(2:end) - d_segments(1:end-1);
            P = (epsilon/(1-epsilon)).^sum(eval_seg_points,1).*d_seg_len';
            %         P = P/(sum(P(:)));
            % draw intervals according to distribution p
            % aa = [0; cumsum(P(:))/sum(P)];
            [tmp,interval] = histc(rand(1),[0; cumsum(P(:))/sum(P)]);

            sector_in_use = eval_seg_points(:,interval);
            % uniformly choose a point in the selected interval
            t = d_segments(interval) + (d_segments(interval+1) - d_segments(interval)) * rand(1);
            % choose segments according to P, sample each line segment uniformly

        end
        X(:,k+1) = X(:,k) + t*r;
    end
end



function x = HitAndRun(A,b,x,epsilon)
% HIT-AND-RUN: Sampling of uniformly distributed vectors x from the convex 
% body defined by a set of constraints (labeled samples) and the unit ball

    if epsilon == 0
        if ~all(A*x<=b)
            error('initial point infeasible');
        end
    end
    
    % Generate a random direction vector (uniformly covering the surface of 
    % a unit sphere)
    r = randn(size(A,2),1);
    r = r/norm(r);
    % noise free. Draw from the convex body
    [d_neg,d_pos] = distToConstraints(A,b,x,r);
    % a random number [-d_neg,d_pos)
    t = -d_neg+(d_pos+d_neg)*rand(1);
    
    % next sample
    x = x + t*r;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine the distances between point x and all the intersection points 
% between g(t)=x+t*r (in directions -r and +r) and all constraints A.x <= b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [d_neg,d_pos] = getDistsToConstraints(A,b,x,r)
    d_pos = [];
    d_neg = [];
    
    if ~all(A==0)
        for i=1:size(A,1)
            rho = (A(i,:)*x-b(i))/(A(i,:)*r);
            xci = x - r*rho; % intersection point with constraint i
            d_x_xci = norm(xci - x); % distance
            if r'*(xci - x) >= 0.0 % xci is in direction +r
                d_pos = [d_pos; d_x_xci];
            else % xci is in direction -r
                d_neg = [d_neg; d_x_xci];
            end
        end
    end
    
    % intersection point with the unit sphere (in directions -r and +r).
    rho = (r'*x)/(r'*r);
    xcenter = x - r*rho;
    xchord = 2*sqrt(1-(norm(xcenter))^2);
    d_x_ccenter = norm(xcenter - x);
    
    if r'*(xcenter - x) >= 0.0 % chord center in in direcetion +r
        d_x_ball_pos = xchord/2 + d_x_ccenter;
        d_x_ball_neg = xchord/2 - d_x_ccenter;
        
    else % chord center in in direcetion -r
        d_x_ball_pos = xchord/2 - d_x_ccenter;
        d_x_ball_neg = xchord/2 + d_x_ccenter;
    end
    
    % get distances (distances between x and intersection points within the unit ball)
    if ~any(d_pos<d_x_ball_pos) % if along direction +r, x only bounded by the unit ball
        d_pos = d_x_ball_pos;
    else
        d_pos = d_pos(d_pos<d_x_ball_pos); % only keep the intervals within the ball
        d_pos = sort(d_pos); % sorted list of distances in direction +r
        d_pos = [d_pos; d_x_ball_pos];
    end
    if ~any(d_neg<d_x_ball_neg) % if along direction -r, x is only bounded by the unit ball
        d_neg = d_x_ball_neg;
    else
        d_neg = d_neg(d_neg<d_x_ball_neg); % only keep the intervals within the ball
        d_neg = sort(d_neg); % sorted list of distances in direction -r
        d_neg = [d_neg; d_x_ball_neg];
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [d_neg,d_pos] = distToConstraints(A,b,x,r)
% Determine the minimum distances between point x and the (two) intersection
% points of constraints A.x <= b and line g(t)=x+t*r (in directions -r and +r).
    d_pos = Inf;
    d_neg = Inf;
    
    if ~all(A==0)
        for i=1:size(A,1)
            rho = (A(i,:)*x-b(i))/(A(i,:)*r);
            xci = x - r*rho; % intersection point with constraint i
            d_x_xci = norm(xci - x); % distance
            if r'*(xci - x) >= 0.0 % xci is in direction +r
                if d_x_xci < d_pos
                    d_pos = d_x_xci;
                end
            else % xci is in direction -r
                if d_x_xci < d_neg
                    d_neg = d_x_xci;
                end
            end
        end
    end
    
    % intersection point with the unit sphere (in directions -r and +r).
    rho = (r'*x)/(r'*r);
    xcenter = x - r*rho;
    xchord = 2*sqrt(1-(norm(xcenter))^2);
    d_x_ccenter = norm(xcenter - x);
    
    if r'*(xcenter - x) >= 0.0 % chord center in in direcetion +r
        d_x_ball_pos = xchord/2 + d_x_ccenter;
        d_x_ball_neg = xchord/2 - d_x_ccenter;
        
        if d_x_ball_pos < d_pos
            d_pos = d_x_ball_pos;
        end
        if d_x_ball_neg < d_neg
            d_neg = d_x_ball_neg;
        end
    else % chord center in in direcetion -r
        d_x_ball_pos = xchord/2 - d_x_ccenter;
        d_x_ball_neg = xchord/2 + d_x_ccenter;
        
        if d_x_ball_pos < d_pos
            d_pos = d_x_ball_pos;
        end
        if d_x_ball_neg < d_neg
            d_neg = d_x_ball_neg;
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%