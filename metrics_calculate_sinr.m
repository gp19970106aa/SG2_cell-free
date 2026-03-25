
function sinr_vec = metrics_calculate_sinr(H, W, Noise, user_indices)
% METRICS_CALCULATE_SINR  Calculate per-user SINR
%
%   Input:
%       H            - Channel matrix (M x K)
%       W            - Precoding matrix (M x K)
%       Noise        - Noise power
%       user_indices - Optional: specific users to calculate (default: all)
%
%   Output:
%       sinr_vec     - SINR vector for specified users

    [M, K_total] = size(H);
    
    if nargin < 4
        user_indices = 1:K_total;
    end
    
    sinr_vec = zeros(length(user_indices), 1);
    idx = 1;
    
    for k = user_indices
        % Signal power
        signal = abs(H(:, k)' * W(:, k))^2;
        
        % Interference from other users
        interference = 0;
        for j = 1:K_total
            if j ~= k
                interference = interference + abs(H(:, k)' * W(:, j))^2;
            end
        end
        
        % SINR
        sinr_vec(idx) = signal / (interference + Noise);
        idx = idx + 1;
    end
end