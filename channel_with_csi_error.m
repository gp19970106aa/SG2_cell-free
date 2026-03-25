
%% ========================================================================
%  Channel with CSI Estimation Error
%  ========================================================================

function H_est = channel_with_csi_error(H_true, sigma_e)
% CHANNEL_WITH_CSI_ERROR  Generate estimated channel with error
%
%   Input:
%       H_true  - True channel matrix
%       sigma_e - CSI error standard deviation (0 to 1)
%
%   Output:
%       H_est   - Estimated channel
%
%   Model: h_est = sqrt(1 - sigma_e^2) * h_true + sigma_e * e
%   where e ~ CN(0, I) is independent estimation error

    [M, K] = size(H_true);
    
    % Generate independent error matrix
    E = (randn(M, K) + 1i * randn(M, K)) / sqrt(2);
    
    % Estimated channel
    H_est = sqrt(1 - sigma_e^2) * H_true + sigma_e * E;
end