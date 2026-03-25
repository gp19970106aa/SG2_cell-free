
%% ========================================================================
%  Statistical CSI (Temporal Average)
%  ========================================================================

function H_stat = generate_statistical_csi(Pos_BS, Pos_UE, params, N_samples)
% GENERATE_STATISTICAL_CSI  Generate statistical CSI via temporal averaging
%
%   Input:
%       Pos_BS     - BS positions
%       Pos_UE     - UE positions
%       params     - System parameters
%       N_samples  - Number of channel realizations to average
%
%   Output:
%       H_stat     - Statistical channel gain matrix

    M = size(Pos_BS, 1);
    K = size(Pos_UE, 1);
    H_stat = zeros(M, K);
    
    % Accumulate channel power over multiple realizations
    for n = 1:N_samples
        H_inst = channel_generate(Pos_BS, Pos_UE, params);
        H_stat = H_stat + abs(H_inst).^2;
    end
    
    % Average and take square root
    H_stat = sqrt(H_stat / N_samples);
end
