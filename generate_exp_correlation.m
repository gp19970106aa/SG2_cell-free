


%% ========================================================================
%  Exponential Correlation Matrix Generator
%  ========================================================================

function R = generate_exp_correlation(N, corr_coef)
% GENERATE_EXP_CORRELATION  Generate exponential correlation matrix
%
%   Input:
%       N          - Matrix size
%       corr_coef  - Correlation coefficient (0 to 1)
%
%   Output:
%       R          - Correlation matrix (N x N)
%
%   Model: R(i,j) = corr_coef^|i-j|

    R = zeros(N, N);
    for i = 1:N
        for j = 1:N
            R(i, j) = corr_coef^abs(i - j);
        end
    end
end
