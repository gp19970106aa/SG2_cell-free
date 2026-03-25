

%% ========================================================================
%  Average User SINR
%  ========================================================================

function sinr_avg = metrics_average_sinr(sinr_vec)
% METRICS_AVERAGE_SINR  Calculate average SINR in dB
%
%   Input:
%       sinr_vec - Linear SINR values
%
%   Output:
%       sinr_avg - Average SINR in dB

    sinr_avg = mean(10 * log10(sinr_vec));
end