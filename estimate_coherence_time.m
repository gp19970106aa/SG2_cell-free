
%% ========================================================================
%  Channel Coherence Time Estimation
%  ========================================================================

function T_c = estimate_coherence_time(params, velocity)
% ESTIMATE_COHERENCE_TIME  Estimate channel coherence time
%
%   Input:
%       params   - System parameters (CarrierFreq)
%       velocity - UE velocity in m/s (0 for static)
%
%   Output:
%       T_c      - Coherence time in seconds
%
%   Formula: T_c ≈ 0.423 / f_D, where f_D = v * f_c / c

    c = 3e8;  % Speed of light
    f_c = params.CarrierFreq;
    
    % Doppler shift
    f_D = velocity * f_c / c;
    
    if f_D > 0
        T_c = 0.423 / f_D;
    else
        T_c = inf;  % Static scenario (SG2 typical)
    end
end