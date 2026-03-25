
%% ========================================================================
%  Backhaul Overhead Estimation
%  ========================================================================

function backhaul_bits = metrics_backhaul_overhead(W, active_mask, CSI_bits)
% METRICS_BACKHAUL_OVERHEAD  Estimate backhaul overhead
%
%   Input:
%       W           - Precoding matrix
%       active_mask - Boolean mask of active links
%       CSI_bits    - Bits per CSI coefficient
%
%   Output:
%       backhaul_bits - Estimated backhaul overhead in bits

    [M, K] = size(W);
    active_links = nnz(active_mask);
    
    # Each active link requires CSI feedback
    backhaul_bits = active_links * CSI_bits;
end