

%% ========================================================================
%  QoS Satisfaction Ratio
%  ========================================================================

function qos_ratio = metrics_qos_satisfaction(sinr_vec, SINR_targets)
% METRICS_QOS_SATISFACTION  Calculate fraction of users meeting QoS
%
%   Input:
%       sinr_vec     - Achieved SINR values
%       SINR_targets - Required SINR targets
%
%   Output:
%       qos_ratio - Fraction of users meeting their QoS target

    satisfied = sinr_vec >= SINR_targets;
    qos_ratio = sum(satisfied) / length(SINR_targets);
end
