

%% ========================================================================
%  Baseline: Traditional Cellular
%  ========================================================================

function sinr_vec = baseline_cellular(H, P_max, Noise)
% BASELINE_CELLULAR  Traditional Cellular Network (single-BS association)
%
%   Each UE connects to the BS with strongest channel
%   All BSs transmit at full power (interference-limited regime)

    [M, K] = size(H);
    sinr_vec = zeros(K, 1);
    
    for k = 1:K
        % Find serving BS (strongest channel)
        [gain_best, idx_best] = max(abs(H(:, k)).^2);
        
        % Signal power
        S = P_max * gain_best;
        
        % Interference from other BSs
        I = 0;
        for m = 1:M
            if m ~= idx_best
                I = I + P_max * abs(H(m, k))^2;
            end
        end
        
        % SINR
        sinr_vec(k) = S / (I + Noise);
    end
end
