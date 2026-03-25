

%% ========================================================================
%  Parameter Presets
%  ========================================================================

function params = get_params_preset(preset_name)
% GET_PARAMS_PRESET  Load predefined parameter configurations
%
%   Presets:
%   - 'default': Standard configuration for main results
%   - 'fast': Reduced Monte Carlo for quick testing
%   - 'high_accuracy': Increased Monte Carlo for final results
%   - 'sensitive_priority': Enhanced priority differentiation

    params = get_simulation_params();
    
    switch preset_name
        case 'default'
            % Already set by get_simulation_params()
            
        case 'fast'
            params.Realiz_Standard = 500;
            params.Realiz_Large = 2000;
            params.MaxIter_Cluster = 20;
            params.MaxIter_Precod = 30;
            
        case 'high_accuracy'
            params.Realiz_Standard = 5000;
            params.Realiz_Large = 20000;
            params.MaxIter_Cluster = 50;
            params.MaxIter_Precod = 100;
            
        case 'sensitive_priority'
            params.Gamma_High_dB = 18;      % Higher differentiation
            params.Gamma_Low_dB = 3;
            params.Step_Lambda_Up = 25.0;   % More aggressive response
            
        otherwise
            error('Unknown preset: %s', preset_name);
    end
end
