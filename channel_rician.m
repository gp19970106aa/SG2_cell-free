
%% ========================================================================
%  Rician Fading Channel (for LOS scenarios)
%  ========================================================================

function H_rician = channel_rician(Pos_BS, Pos_UE, params, K_factor)
% CHANNEL_RICIAN  Generate Rician fading channel
%
%   Input:
%       Pos_BS   - BS positions
%       Pos_UE   - UE positions
%       params   - System parameters
%       K_factor - Rician K-factor (ratio of LOS to NLOS power)
%
%   Output:
%       H_rician - Rician fading channel matrix

    M = size(Pos_BS, 1);
    K_users = size(Pos_UE, 1);
    H_rician = zeros(M, K_users);
    
    alpha = params.PathLossExp;
    RefLoss_dB = params.RefLoss_dB;
    C_PL = 10^(-RefLoss_dB/10);
    
    K_lin = 10^(K_factor / 10);  % Convert K-factor to linear
    
    for k = 1:K_users
        for m = 1:M
            dist = norm(Pos_BS(m, :) - Pos_UE(k, :));
            dist = max(dist, 10);
            
            beta = C_PL * (dist ^ (-alpha));
            
            % LOS component (deterministic, phase based on distance)
            phase_los = 2 * pi * dist / (c / params.CarrierFreq);
            h_los = sqrt(K_lin / (K_lin + 1)) * exp(1i * phase_los);
            
            % NLOS component (Rayleigh)
            h_nlos = sqrt(1 / (K_lin + 1)) * (randn + 1i * randn) / sqrt(2);
            
            H_rician(m, k) = sqrt(beta) * (h_los + h_nlos);
        end
    end
end