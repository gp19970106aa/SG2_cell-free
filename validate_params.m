
function validate_params(params)
% VALIDATE_PARAMS  Check parameter consistency and validity

    warnings = {};
    errors = {};
    
    % Check power constraints
    if params.P_max <= 0
        errors{end+1} = 'P_max must be positive';
    end
    
    % Check SINR targets
    if params.Gamma_High_dB <= params.Gamma_Low_dB
        warnings{end+1} = 'Gamma_High should be greater than Gamma_Low';
    end
    
    % Check sparsity penalty
    if params.Mu_Cluster < 0
        errors{end+1} = 'Mu_Cluster must be non-negative';
    elseif params.Mu_Cluster > 1
        warnings{end+1} = 'Mu_Cluster > 1 may cause excessive sparsity';
    end
    
    % Check iteration counts
    if params.MaxIter_Cluster < 10
        warnings{end+1} = 'MaxIter_Cluster < 10 may not converge';
    end
    
    if params.MaxIter_Precod < 20
        warnings{end+1} = 'MaxIter_Precod < 20 may not converge';
    end
    
    % Print validation results
    if ~isempty(errors)
        fprintf('PARAMETER VALIDATION ERRORS:\n');
        for i = 1:length(errors)
            fprintf('  ✗ %s\n', errors{i});
        end
        error('Parameter validation failed');
    end
    
    if ~isempty(warnings)
        fprintf('PARAMETER VALIDATION WARNINGS:\n');
        for i = 1:length(warnings)
            fprintf('  ⚠ %s\n', warnings{i});
        end
        fprintf('\n');
    end
end