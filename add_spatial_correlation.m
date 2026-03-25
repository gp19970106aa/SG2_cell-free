
%% ========================================================================
%  Spatial Correlation Model
%  ========================================================================

function H_corr = add_spatial_correlation(H, corr_matrix_BS, corr_matrix_UE)
% ADD_SPATIAL_CORRELATION  Add spatial correlation to channel
%
%   Input:
%       H              - Uncorrelated channel matrix
%       corr_matrix_BS - BS correlation matrix (M x M)
%       corr_matrix_UE - UE correlation matrix (K x K)
%
%   Output:
%       H_corr         - Correlated channel
%
%   Model: H_corr = corr_matrix_BS^(1/2) * H * corr_matrix_UE^(1/2)

    % Cholesky decomposition
    L_BS = chol(corr_matrix_BS, 'lower');
    L_UE = chol(corr_matrix_UE, 'lower');
    
    % Apply correlation
    H_corr = L_BS * H * L_UE';
end
