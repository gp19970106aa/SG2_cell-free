

%% ========================================================================
%  Convergence Metric
%  ========================================================================

function [converged, rel_change] = metrics_check_convergence(W_curr, W_prev, tol)
% METRICS_CHECK_CONVERGENCE  Check algorithm convergence
%
%   Input:
%       W_curr - Current precoding matrix
%       W_prev - Previous precoding matrix
%       tol    - Convergence tolerance
%
%   Output:
%       converged   - Boolean: has algorithm converged?
%       rel_change  - Relative change in W

    diff_norm = norm(W_curr(:) - W_prev(:));
    W_norm = norm(W_prev(:));
    
    if W_norm > 0
        rel_change = diff_norm / W_norm;
    else
        rel_change = inf;
    end
    
    converged = (rel_change < tol);
end
