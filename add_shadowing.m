
%% ========================================================================
%  Shadowing Model
%  ========================================================================

function H_shadow = add_shadowing(H, sigma_shadow)
% ADD_SHADOWING  Add log-normal shadowing to channel
%
%   Input:
%       H            - Channel matrix (without shadowing)
%       sigma_shadow - Shadowing std in dB (typically 6-10 dB)
%
%   Output:
%       H_shadow     - Channel with shadowing

    [M, K] = size(H);
    
    % Generate shadowing (log-normal, correlated per UE)
    shadow_dB = sigma_shadow * randn(1, K);
    shadow_lin = 10.^(shadow_dB / 20);
    
    % Apply shadowing
    H_shadow = H .* shadow_lin;
end