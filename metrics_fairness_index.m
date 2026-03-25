
%% ========================================================================
%  Jain's Fairness Index
%  ========================================================================

function JFI = metrics_fairness_index(rate_vec)
% METRICS_FAIRNESS_INDEX  Calculate Jain's Fairness Index
%
%   Input:
%       rate_vec - Per-user rates
%
%   Output:
%       JFI - Fairness index (0 to 1, 1 = perfectly fair)
%
%   Formula: JFI = (sum(x_i))^2 / (n * sum(x_i^2))

    n = length(rate_vec);
    sum_x = sum(rate_vec);
    sum_x2 = sum(rate_vec.^2);
    
    if sum_x2 > 0
        JFI = (sum_x^2) / (n * sum_x2);
    else
        JFI = 0;
    end
end