
%% ========================================================================
%  Achievable Rate
%  ========================================================================

function [rate_vec, sum_rate] = metrics_calculate_rate(H, W, Noise, BW)
% METRICS_CALCULATE_RATE  Calculate achievable rate per user and sum rate
%
%   Input:
%       H     - Channel matrix
%       W     - Precoding matrix
%       Noise - Noise power
%       BW    - Bandwidth in Hz
%
%   Output:
%       rate_vec  - Per-user rate (bps)
%       sum_rate  - Sum rate (bps)

    sinr_vec = metrics_calculate_sinr(H, W, Noise);
    rate_vec = BW * log2(1 + sinr_vec);
    sum_rate = sum(rate_vec);
end