

%% ========================================================================
%  Path Loss Model (Sub-GHz Specific)
%  ========================================================================

function PL_dB = path_loss_subGHz(dist, params)
% PATH_LOSS_SUBGHZ  Calculate path loss for sub-GHz band
%
%   Input:
%       dist   - Distance in meters
%       params - System parameters
%
%   Output:
%       PL_dB  - Path loss in dB
%
%   Model: PL(d) = PL(d0) + 10*alpha*log10(d/d0)

    alpha = params.PathLossExp;
    RefLoss_dB = params.RefLoss_dB;
    d0 = 1;  % Reference distance 1m
    
    dist = max(dist, d0);
    PL_dB = RefLoss_dB + 10 * alpha * log10(dist / d0);
end