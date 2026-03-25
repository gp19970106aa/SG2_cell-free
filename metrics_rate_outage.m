

%% ========================================================================
%  Rate Outage Probability
%  ========================================================================

function P_out = metrics_rate_outage(rate_samples, Rate_threshold)
% METRICS_RATE_OUTAGE  Calculate rate outage probability
%
%   Input:
%       rate_samples   - Vector of rate samples (bps)
%       Rate_threshold - Required rate threshold (bps)
%
%   Output:
%       P_out - Outage probability

    P_out = mean(rate_samples < Rate_threshold);
end