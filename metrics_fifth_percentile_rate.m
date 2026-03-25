
%% ========================================================================
%  5th Percentile Rate (Cell-Edge User Rate)
%  ========================================================================

function rate_5th = metrics_fifth_percentile_rate(rate_samples)
% METRICS_FIFTH_PERCENTILE_RATE  Calculate 5th percentile rate
%
%   Input:
%       rate_samples - Vector of rate samples
%
%   Output:
%       rate_5th - 5th percentile rate (cell-edge user performance)

    rate_5th = prctile(rate_samples, 5);
end