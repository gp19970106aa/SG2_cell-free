
%% ========================================================================
%  Energy Efficiency
%  ========================================================================

function [EE, total_power] = metrics_energy_efficiency(H, W, Noise, BW, P_circuit)
% METRICS_ENERGY_EFFICIENCY  Calculate energy efficiency
%
%   Input:
%       H         - Channel matrix
%       W         - Precoding matrix
%       Noise     - Noise power
%       BW        - Bandwidth
%       P_circuit - Circuit power consumption (W)
%
%   Output:
%       EE         - Energy efficiency (bps/Hz/W or bits/Joule)
%       total_power - Total power consumption (W)

    [rate_vec, sum_rate] = metrics_calculate_rate(H, W, Noise, BW);
    
    % Total transmit power
    P_transmit = sum(abs(W(:)).^2);
    
    % Total power (transmit + circuit)
    total_power = P_transmit + P_circuit;
    
    % Energy efficiency (spectral efficiency per Watt)
    EE = (sum_rate / BW) / total_power;  % bps/Hz/W
end