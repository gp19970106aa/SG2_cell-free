
%% ========================================================================
%  Active Link Ratio (Sparsity Metric)
%  ========================================================================

function active_ratio = metrics_active_link_ratio(W, threshold)
% METRICS_ACTIVE_LINK_RATIO  Calculate ratio of active BS-UE links
%
%   Input:
%       W         - Precoding matrix
%       threshold - Threshold for considering a link "active"
%
%   Output:
%       active_ratio - Fraction of active links

    [M, K] = size(W);
    total_links = M * K;
    active_links = nnz(abs(W) > threshold);
    
    active_ratio = active_links / total_links;
end