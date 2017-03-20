% PLOT_SAMPLES plot functions for the hit-and-run sampler
%
%   plot_samples(...) plots the hit-and-run sampling results in 2d or 3d
%   dimensional space. 
%
%   Input:
%       - A: constraints (i.e., the data points queried)
%       - W: the samples (i.e., the finite version space)
%
%   Author: Yuxin Chen
%
%   Created: 09.2012

function plot_samples (A,W)
        dim = size(W,1);
        plotScatter(W, dim);
        plotConstraints(A', dim);
        title('uniform sampling under the convex body (unit ball and a set of linear constraints)');
        hold off;
end


function plotScatter(W, dim)
% plot sampled hypotheses in the current version space
    switch dim
        case 2
            plot(W(1,:),W(2,:),'.');
            hold on;
            axis([-1,1,-1,1]); axis square; grid on;
        case 3
            % NOTE here: scatter3 cann't be used (not displayable in transparent plot)
            plot3(W(1,:),W(2,:),W(3,:),'.'); hold on;
        otherwise
            error('dimension cannot be plotted');
    end
end

function plotConstraints(A, dim)
% plot the unit ball and linear constraints
    switch dim
        case 2
            lightGrey = 0.6* [1 1 1];
            ang=0:0.01:2*pi;
            xp=cos(ang);
            yp=sin(ang);
            plot(xp,yp, 'Color',lightGrey); hold on;

            eps = 2^(-52);
            for i=1:size(A,1)
                xa = [-1, 1];
                ya = - A(i,1)/(A(i,2)+eps) * xa;
                plot(xa,ya,'-','Color',lightGrey);
                arrowpos = 0.8*[A(i,2), -A(i,1)]/norm(A(i,:));
                arrowdir = [-A(i,1), -A(i,2)]/norm(A(i,:));
                quiver(arrowpos(1), arrowpos(2), arrowdir(1), arrowdir(2), .2, 'r', 'LineWidth', 2, 'MaxHeadSize', 1);
            end
        case 3
            [xp,yp,zp] = sphere; lightGrey = 0.8* [1 1 1];
            surface(xp,yp,zp,'FaceColor', 'none','EdgeColor',lightGrey); hold on;
            for i=1:size(A,1)
                point = [0,0,0];
                normal = A(i,:);
                % a plane is a*x+b*y+c*z+d=0. [a,b,c] is the normal. Thus, we have to calculate d and we're set
                d = -point*normal';
                [xx,yy]=ndgrid([-1 1], [-1 1]); % create x,y
                z = (-normal(1)*xx - normal(2)*yy - d)/normal(3); % calculate corresponding z
                surf(xx,yy,z, 'FaceColor',[1 0 0], 'FaceAlpha', 0.2, 'EdgeColor', 'none'); % plot the surface
            end
            axis square; grid on;
            axis([-1,1,-1,1,-1,1,0,1]);
        otherwise
            error('dimension cannot be plotted');
    end
    hold off;
end

