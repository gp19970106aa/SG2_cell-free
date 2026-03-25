
%% ========================================================================
%  Baseline: Standard RZF Precoding
%  ========================================================================

function W = baseline_rzf(H, P_max, Noise)
% BASELINE_RZF  Standard Regularized Zero-Forcing Precoding
%
%   Serves as the baseline comparison for the proposed algorithm

    [M, K] = size(H);
    
    % Regularization factor
    alpha = (K * Noise / P_max);
    
    % RZF beamforming
    W = (H * H' + alpha * eye(M)) \ H;
    
    % Power normalization per BS
    for m = 1:M
        p_curr = norm(W(m, :))^2;
        if p_curr > 0
            scale = sqrt(P_max / p_curr);
            W(m, :) = W(m, :) * scale;
        end
    end
end
