
%% ========================================================================
%  Large-Scale Fading Extraction
%  ========================================================================

function beta = extract_large_scale_fading(H)
% EXTRACT_LARGE_SCALE_FADING  Extract large-scale fading from channel
%
%   Input:
%       H  - Channel matrix (instantaneous or averaged)
%
%   Output:
%       beta - Large-scale fading matrix (M x K)
%
%   For Rayleigh fading: E[|h|^2] = beta

    beta = abs(H).^2;
end