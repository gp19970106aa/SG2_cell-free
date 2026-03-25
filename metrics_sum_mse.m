
%% ========================================================================
%  Sum MSE (for WMMSE convergence tracking)
%  ========================================================================

function sum_mse = metrics_sum_mse(H, W, u, Noise)
% METRICS_SUM_MSE  Calculate sum MSE for WMMSE algorithm
%
%   Input:
%       H     - Channel matrix
%       W     - Precoding matrix
%       u     - MMSE receiver coefficients
%       Noise - Noise power
%
%   Output:
%       sum_mse - Sum of per-user MSE

    [M, K] = size(H);
    sum_mse = 0;
    
    for k = 1:K
        % Received signal power
        rx_pwr = Noise;
        for j = 1:K
            rx_pwr = rx_pwr + abs(H(:, k)' * W(:, j))^2;
        end
        
        % MSE for user k
        mse_k = 1 - real(u(k) * H(:, k)' * W(:, k));
        sum_mse = sum_mse + mse_k;
    end
end