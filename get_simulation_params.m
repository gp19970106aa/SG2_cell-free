
function params = get_simulation_params()
% GET_SIMULATION_PARAMS  Return comprehensive parameter structure

    %% ==================== System Parameters ====================
    % These match Table I in the manuscript
    
    params.CarrierFreq     = 230e6;           % 230 MHz (power grid band in China)
    params.BW_Wide         = 1e6;             % 1 MHz (broadband mode)
    params.BW_NB           = 25e3;            % 25 kHz (narrowband/NB-IoT)
    
    % Noise configuration
    params.NoisePSD        = -130;            % dBm/Hz
    params.Noise_WB        = 10^((params.NoisePSD-30)/10) * params.BW_Wide;   % Wideband noise
    params.Noise_NB        = 10^((params.NoisePSD-30)/10) * params.BW_NB;     % Narrowband noise
    
    % Power configuration
    params.P_max_dBm       = 43;              % 43 dBm = 20 W per BS
    params.P_max           = 10^((params.P_max_dBm-30)/10);
    
    % Path loss model (sub-GHz specific)
    params.PathLossExp     = 3.5;             % Path loss exponent (3.0-3.5 for sub-GHz)
    params.RefLoss_dB      = 30;              % Reference path loss at 1m
    
    %% ==================== QoS Requirements ====================
    % SINR targets for different priority levels
    
    params.Gamma_High_dB   = 15;              % High-priority (e.g., differential protection)
    params.Gamma_Low_dB    = 5;               % Low-priority (e.g., meter reading)
    params.Gamma_High_lin  = 10^(params.Gamma_High_dB/10);
    params.Gamma_Low_lin   = 10^(params.Gamma_Low_dB/10);
    
    %% ==================== Algorithm Parameters ====================
    % Two-Timescale JDC-IPC algorithm settings
    
    % Sparsity penalty
    params.Mu_Cluster      = 0.05;            % Clustering phase (controls link sparsity)
    params.Mu_Precod       = 0;               % Precoding phase (no sparsity)
    
    % Iteration limits
    params.MaxIter_Cluster = 30;              % Long-term clustering iterations
    params.MaxIter_Precod  = 50;              % Short-term precoding iterations
    
    % Convergence
    params.ConvTol         = 1e-3;            % Convergence tolerance
    
    % Lagrange multiplier step sizes (asymmetric for stability)
    params.Step_Lambda_Up      = 15.0;        % When QoS violated (fast increase)
    params.Step_Lambda_Down    = 0.15;        % When QoS satisfied (slow decrease)
    params.Step_Nu             = 0.02;        % Power constraint multiplier
    
    % Regularization
    params.Epsilon_ReWeight  = 1e-3;          % For reweighted l1-norm stability
    params.Delta_Smooth      = 1e-8;          % For non-differentiable approximation
    
    %% ==================== Clustering Parameters ====================
    % User-centric clustering threshold
    
    params.Gamma_Th          = 0.5;           % Relative threshold for cluster formation
                                            % (BS included if gain >= gamma_th * max_gain)
    
    %% ==================== Simulation Settings ====================
    % Monte Carlo and visualization settings
    
    % Realization counts (balance accuracy vs. runtime)
    params.Realiz_Fast     = 200;             % For quick tests
    params.Realiz_Standard = 2000;            % For main figures
    params.Realiz_Large    = 10000;           % For CDF/outage analysis
    
    % Network topology
    params.M_Default       = 16;              % Default number of BSs
    params.K_Default       = 8;               % Default number of UEs
    params.Area_Default    = 500;             % Default area size (meters)
    
    % CSI error range for robustness analysis
    params.Sigma_CSI_Test  = [0, 0.02, 0.05, 0.08, 0.1, 0.15, 0.2];
    
    % Sparsity penalty range for trade-off analysis
    params.Mu_Test         = [0.001, 0.01, 0.05, 0.1, 0.2, 0.5];
    
    %% ==================== Figure Settings ====================
    % Plotting configuration
    
    params.Fig_DPI         = 300;             % Output resolution
    params.Fig_Width       = 650;             % Default figure width (pixels)
    params.Fig_Height      = 480;             % Default figure height (pixels)
    
    % Color scheme (academic style)
    params.Color_Prop      = [1, 0, 0];       % Red for proposed
    params.Color_RZF       = [0, 0, 1];       % Blue for RZF
    params.Color_Cell      = [0, 0, 0];       % Black for cellular
    params.Color_NB        = [1, 0, 1];       % Magenta for NB-IoT
    
    %% ==================== SG2 Scenario Parameters ====================
    % Smart Grid 2.0 specific settings
    
    % Service types
    params.Service.Types = {'Differential_Protection', 'PMU', 'Meter_Reading', 'Monitoring'};
    params.Service.Latency = [0.01, 0.05, 1.0, 0.5];      % seconds
    params.Service.Reliability = [0.99999, 0.9999, 0.99, 0.999];  % success probability
    
    % Grid state transition (for dynamic priority)
    params.Grid.State_Normal = 0;
    params.Grid.State_Fault = 1;
    params.Grid.Fault_Duration = 10;          % Time slots
    
    %% ==================== Computational Complexity ====================
    % For complexity analysis and coherence time validation
    
    params.Complexity.M_Cluster = 'O(M^3*K)';     % Per iteration (clustering)
    params.Complexity.M_Precod = 'O(M^3 + M^2*K)'; % Per iteration (precoding)
    
    % Channel coherence time (for static SG2 terminals)
    params.Coherence.Velocity = 0;                % m/s (static)
    params.Coherence.Time = inf;                  % Static scenario
    
    %% ==================== Backhaul Model ====================
    % For backhaul overhead estimation
    
    params.Backhaul.CSI_Bits = 32;            % Bits per complex CSI coefficient
    params.Backhaul.Quantization_Bits = 16;   % Bits for quantized weights
    
end
