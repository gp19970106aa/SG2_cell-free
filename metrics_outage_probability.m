
%% ========================================================================
%  Outage Probability
%  ========================================================================

function P_out = metrics_outage_probability(sinr_samples, SINR_threshold)
% METRICS_OUTAGE_PROBABILITY  Calculate outage probability
%
%   Input:
%       sinr_samples   - Vector of SINR samples (from multiple realizations)
%       SINR_threshold - Required SINR threshold
%
%   Output:
%       P_out - Outage probability (fraction below threshold)

    P_out = mean(sinr_samples < SINR_threshold);
end
