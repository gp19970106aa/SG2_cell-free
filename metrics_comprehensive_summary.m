
%% ========================================================================
%  Comprehensive Performance Summary
%  ========================================================================

function summary = metrics_comprehensive_summary(H, W, Noise, BW, params)
% METRICS_COMPREHENSIVE_SUMMARY  Generate comprehensive performance summary
%
%   Input:
%       H      - Channel matrix
%       W      - Precoding matrix
%       Noise  - Noise power
%       BW     - Bandwidth
%       params - System parameters
%
%   Output:
%       summary - Structure with all key metrics

    [rate_vec, sum_rate] = metrics_calculate_rate(H, W, Noise, BW);
    sinr_vec = metrics_calculate_sinr(H, W, Noise);
    [EE, total_power] = metrics_energy_efficiency(H, W, Noise, BW, params.P_max * 0.1);
    JFI = metrics_fairness_index(rate_vec);
    
    summary.Sum_Rate_Mbps = sum_rate / 1e6;
    summary.Avg_Rate_Mbps = mean(rate_vec) / 1e6;
    summary.Avg_SINR_dB = mean(10 * log10(sinr_vec));
    summary.Min_SINR_dB = min(10 * log10(sinr_vec));
    summary.Energy_Efficiency = EE;
    summary.Total_Power_W = total_power;
    summary.Fairness_JFI = JFI;
    summary.Total_Power_Transmit = sum(abs(W(:)).^2);
end
