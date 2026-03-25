

%% ========================================================================
%  Per-BS Power Statistics
%  ========================================================================

function [P_avg, P_max_bs, P_min_bs] = metrics_bs_power_stats(W, M)
% METRICS_BS_POWER_STATS  Calculate per-BS power statistics
%
%   Input:
%       W - Precoding matrix (M x K)
%       M - Number of BSs
%
%   Output:
%       P_avg   - Average BS power
%       P_max_bs - Maximum BS power
%       P_min_bs - Minimum BS power

    bs_power = sum(abs(W).^2, 2);  # Power per BS
    
    P_avg = mean(bs_power);
    P_max_bs = max(bs_power);
    P_min_bs = min(bs_power);
end