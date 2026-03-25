%% ========================================================================
%  Smart Grid 2.0: Cell-Free MISO Simulation Framework
%  Two-Timescale JDC-IPC Algorithm - Complete Simulation Suite
%  ========================================================================
%  Author: Peng Gao et al.
%  Target Journal: Electric Power Systems Research
%  Revision: Major Revision Response
%  ========================================================================
%  This simulation framework addresses all reviewer comments:
%  - R1-Q3, R2-Q1: Two-timescale architecture implementation
%  - R2-Q4: Theoretical limit validation (Eq. 6)
%  - R2-Q5: CDF and outage probability analysis
%  - R1-Q7, R2-Q2: Dynamic priority response visualization
%  - R2-Q7, R2-Q9, R3-Q5: Convergence analysis
%  - R2-Q10: CSI error robustness
%  ========================================================================

function main_simulation()
    clc; clear; close all;
    warning('off', 'all');
    
    %% ==================== Global Configuration ====================
    fprintf('============================================================\n');
    fprintf('  SG2 Cell-Free MISO Simulation Framework\n');
    fprintf('  Two-Timescale JDC-IPC Algorithm\n');
    fprintf('============================================================\n\n');
    
    % --- System Parameters (Table I in manuscript) ---
    params.CarrierFreq     = 230e6;           % 230 MHz (power grid band)
    params.BW_Wide         = 1e6;             % 1 MHz (broadband)
    params.BW_NB           = 25e3;            % 25 kHz (narrowband)
    params.NoisePSD        = -130;            % dBm/Hz
    params.Noise_WB        = 10^((params.NoisePSD-30)/10) * params.BW_Wide;
    params.Noise_NB        = 10^((params.NoisePSD-30)/10) * params.BW_NB;
    params.P_max_dBm       = 43;              % 43 dBm = 20 W
    params.P_max           = 10^((params.P_max_dBm-30)/10);
    params.PathLossExp     = 3.5;             % Sub-GHz path loss exponent
    params.RefLoss_dB      = 30;              % Reference path loss at 1m
    
    % --- Algorithm Parameters ---
    params.Gamma_High_dB   = 15;              % High-priority SINR target
    params.Gamma_Low_dB    = 5;               % Low-priority SINR target
    params.Gamma_High_lin  = 10^(params.Gamma_High_dB/10);
    params.Gamma_Low_lin   = 10^(params.Gamma_Low_dB/10);
    params.Mu_Cluster      = 0.05;            % Sparsity penalty for clustering
    params.Mu_Precod       = 0;               % No sparsity in precoding phase
    params.ConvTol         = 1e-3;            % Convergence tolerance
    params.MaxIter_Cluster = 30;              % Max iterations for clustering
    params.MaxIter_Precod  = 50;              % Max iterations for precoding
    
    % --- Simulation Control ---
    run_all = true;  % Set to false to run individual simulations
    
    if run_all
        fprintf('Running complete simulation suite...\n\n');
        
        % Run all simulations
       run_fig1_density_vs_sinr(params);
     %   run_fig2_distance_vs_rate(params);
     %   run_fig3_cdf_analysis(params);
     %   run_fig4_outage_probability(params);
     %   run_fig5_dynamic_priority(params);
     %   run_fig6_convergence_analysis(params);
     %   run_fig7_csi_robustness(params);
        
        fprintf('\n============================================================\n');
        fprintf('  All simulations completed successfully!\n');
        fprintf('============================================================\n');
    else
        fprintf('Select simulation to run:\n');
        fprintf('  1 - Fig 1: Density vs SINR (with theoretical limit)\n');
        fprintf('  2 - Fig 2: Distance vs Rate\n');
        fprintf('  3 - Fig 3: CDF Analysis\n');
        fprintf('  4 - Fig 4: Outage Probability\n');
        fprintf('  5 - Fig 5: Dynamic Priority Response\n');
        fprintf('  6 - Fig 6: Convergence Analysis\n');
        fprintf('  7 - Fig 7: CSI Robustness\n');
    end
end

%% ========================================================================
%  Figure 1: Network Densification vs SINR (with Theoretical Limit)
%  Addresses: R2-Q4 (theoretical validation)
%  ========================================================================
function run_fig1_density_vs_sinr(params)
    fprintf('>>> Running Fig 1: Density vs SINR with Theoretical Limit...\n');
    
    % Simulation setup
    Sim1.Area         = 500;          % 500m x 500m
    Sim1.K_Users      = 8;
    Sim1.M_List       = [4, 9, 16, 25, 36, 49, 64];
    Sim1.Realizations = 200;         % High-accuracy Monte Carlo
    
    % Results storage
    Res.Prop_sinr = zeros(length(Sim1.M_List), 1);
    Res.RZF_sinr  = zeros(length(Sim1.M_List), 1);
    Res.Cell_sinr = zeros(length(Sim1.M_List), 1);
    Res.Prop_pwr  = zeros(length(Sim1.M_List), 1);
    Res.RZF_pwr   = zeros(length(Sim1.M_List), 1);
    
    fprintf('    Running Monte Carlo simulations (%d realizations)...\n', Sim1.Realizations);
    
    for m_idx = 1:length(Sim1.M_List)
        M_BS = Sim1.M_List(m_idx);
        acc_sinr_prop = 0; acc_sinr_rzf = 0; acc_sinr_cell = 0;
        acc_pwr_prop = 0; acc_pwr_rzf = 0;
        
        for r = 1:Sim1.Realizations
            % Random topology
            Pos_UE = (rand(Sim1.K_Users, 2) - 0.5) * Sim1.Area;
            [X, Y] = meshgrid(linspace(-Sim1.Area/2, Sim1.Area/2, sqrt(M_BS)));
            Pos_BS = [X(:), Y(:)];
            
            % Generate channel (instantaneous for precoding)
            H = channel_generate(Pos_BS, Pos_UE, params);
            
            % Proposed Two-Timescale JDC-IPC
            W_prop = two_timescale_jdc_ipc(H, params, ones(Sim1.K_Users, 1));
            sinr_prop = metrics_calculate_sinr(H, W_prop, params.Noise_WB);
            acc_sinr_prop = acc_sinr_prop + mean(10*log10(sinr_prop));
            acc_pwr_prop = acc_pwr_prop + (sum(abs(W_prop(:)).^2) / M_BS);
            
            % Standard RZF baseline
            W_rzf = baseline_rzf(H, params.P_max, params.Noise_WB);
            sinr_rzf = metrics_calculate_sinr(H, W_rzf, params.Noise_WB);
            acc_sinr_rzf = acc_sinr_rzf + mean(10*log10(sinr_rzf));
            acc_pwr_rzf = acc_pwr_rzf + (sum(abs(W_rzf(:)).^2) / M_BS);
            
            % Traditional Cellular baseline
            sinr_cell = baseline_cellular(H, params.P_max, params.Noise_WB);
            acc_sinr_cell = acc_sinr_cell + mean(10*log10(sinr_cell));
        end
        
        Res.Prop_sinr(m_idx) = acc_sinr_prop / Sim1.Realizations;
        Res.RZF_sinr(m_idx)  = acc_sinr_rzf / Sim1.Realizations;
        Res.Cell_sinr(m_idx) = acc_sinr_cell / Sim1.Realizations;
        Res.Prop_pwr(m_idx)  = acc_pwr_prop / Sim1.Realizations;
        Res.RZF_pwr(m_idx)   = acc_pwr_rzf / Sim1.Realizations;
        
        fprintf('    BS=%2d | SINR: Prop=%.2f, RZF=%.2f, Cell=%.2f dB\n', ...
            M_BS, Res.Prop_sinr(m_idx), Res.RZF_sinr(m_idx), Res.Cell_sinr(m_idx));
    end
    
    % Calculate theoretical interference limit (Eq. 6)
    % For square grid topology, interference coefficients c_j
    alpha = params.PathLossExp;
    % Approximate c_j values for dense square grid (distances relative to cell radius)
    c_j = [sqrt(2), 2, sqrt(5), sqrt(8), 3, sqrt(10), sqrt(13), 4];
    theoretical_limit_lin = 1 / sum(c_j.^(-alpha));
    theoretical_limit_dB = 10*log10(theoretical_limit_lin);
    
    fprintf('    Theoretical interference limit (Eq. 6): %.2f dB\n', theoretical_limit_dB);
    
    % Plot
    plot_fig1_density_sinr(Sim1.M_List, Res, theoretical_limit_dB);
    fprintf('    Figure saved: Fig1_Density_vs_SINR.png\n\n');
end

%% ========================================================================
%  Figure 2: Coverage Distance vs Achievable Rate
%  Addresses: Coverage-rate trade-off validation
%  ========================================================================
function run_fig2_distance_vs_rate(params)
    fprintf('>>> Running Fig 2: Distance vs Rate...\n');
    
    Sim2.Area         = 2500;
    Sim2.Dist_Points  = linspace(200, 2000, 12);
    Sim2.M_BS         = 16;
    Sim2.K_Load       = 8;
    Sim2.Realizations = 200;
    
    Res.Rate_High = zeros(length(Sim2.Dist_Points), 1);
    Res.Rate_Low  = zeros(length(Sim2.Dist_Points), 1);
    Res.Rate_RZF  = zeros(length(Sim2.Dist_Points), 1);
    Res.Rate_Cell = zeros(length(Sim2.Dist_Points), 1);
    Res.Rate_NB   = zeros(length(Sim2.Dist_Points), 1);
    
    Alpha_High = 10;
    Alpha_Low  = 5;
    
    fprintf('    Running Monte Carlo simulations...\n');
    
    for d_idx = 1:length(Sim2.Dist_Points)
        d_target = Sim2.Dist_Points(d_idx);
        acc_r = struct('high', 0, 'low', 0, 'rzf', 0, 'cell', 0, 'nb', 0);
        
        for r = 1:Sim2.Realizations
            Pos_BS = (rand(Sim2.M_BS, 2) - 0.5) * Sim2.Area;
            theta = rand * 2 * pi;
            Pos_UE_Test = [d_target * cos(theta), d_target * sin(theta)];
            Pos_UE_Dummy = (rand(Sim2.K_Load-1, 2) - 0.5) * Sim2.Area;
            All_UEs = [Pos_UE_Test; Pos_UE_Dummy];
            
            H = channel_generate(Pos_BS, All_UEs, params);
            
            % High priority (test user is high priority)
            Prio_High = [Alpha_High; ones(Sim2.K_Load-1, 1) * Alpha_Low];
            W_high = two_timescale_jdc_ipc(H, params, Prio_High);
            sinr_high = metrics_calculate_sinr(H, W_high, params.Noise_WB, 1);
            acc_r.high = acc_r.high + params.BW_Wide * log2(1 + sinr_high);
            
            % Low priority (test user is low priority)
            Prio_Low = [Alpha_Low; ones(Sim2.K_Load-1, 1) * Alpha_High];
            W_low = two_timescale_jdc_ipc(H, params, Prio_Low);
            sinr_low = metrics_calculate_sinr(H, W_low, params.Noise_WB, 1);
            acc_r.low = acc_r.low + params.BW_Wide * log2(1 + sinr_low);
            
            % RZF baseline
            W_rzf = baseline_rzf(H, params.P_max, params.Noise_WB);
            sinr_rzf = metrics_calculate_sinr(H, W_rzf, params.Noise_WB, 1);
            acc_r.rzf = acc_r.rzf + params.BW_Wide * log2(1 + sinr_rzf);
            
            % Cellular baseline
            sinr_cell = baseline_cellular(H, params.P_max, params.Noise_WB);
            acc_r.cell = acc_r.cell + params.BW_Wide * log2(1 + sinr_cell(1));
            
            % NB-IoT baseline
            [~, best_bs] = max(abs(H(:, 1)).^2);
            sig_nb = params.P_max * abs(H(best_bs, 1))^2;
            acc_r.nb = acc_r.nb + params.BW_NB * log2(1 + sig_nb / params.Noise_NB);
        end
        
        Res.Rate_High(d_idx) = (acc_r.high / Sim2.Realizations) / 1e6;
        Res.Rate_Low(d_idx)  = (acc_r.low / Sim2.Realizations) / 1e6;
        Res.Rate_RZF(d_idx)  = (acc_r.rzf / Sim2.Realizations) / 1e6;
        Res.Rate_Cell(d_idx) = (acc_r.cell / Sim2.Realizations) / 1e6;
        Res.Rate_NB(d_idx)   = (acc_r.nb / Sim2.Realizations) / 1e6;
        
        fprintf('    D=%4dm | High=%.2f, RZF=%.2f, Low=%.2f Mbps\n', ...
            d_target, Res.Rate_High(d_idx), Res.Rate_RZF(d_idx), Res.Rate_Low(d_idx));
    end
    
    plot_fig2_distance_rate(Sim2.Dist_Points, Res);
    fprintf('    Figure saved: Fig2_Distance_vs_Rate.png\n\n');
end

%% ========================================================================
%  Figure 3: CDF Analysis (5th Percentile Rate)
%  Addresses: R2-Q5 (reliability metrics)
%  ========================================================================
function run_fig3_cdf_analysis(params)
    fprintf('>>> Running Fig 3: CDF Analysis...\n');
    
    Sim3.M_BS         = 16;
    Sim3.K_Users      = 8;
    Sim3.Area         = 500;
    Sim3.Realizations = 1000;  % Large sample for accurate CDF
    
    all_rates_prop = [];
    all_rates_rzf  = [];
    all_rates_cell = [];
    
    fprintf('    Running large-scale Monte Carlo (%d realizations)...\n', Sim3.Realizations);
    
    for r = 1:Sim3.Realizations
        Pos_BS = (rand(Sim3.M_BS, 2) - 0.5) * Sim3.Area;
        Pos_UE = (rand(Sim3.K_Users, 2) - 0.5) * Sim3.Area;
        H = channel_generate(Pos_BS, Pos_UE, params);
        
        % Proposed
        W_prop = two_timescale_jdc_ipc(H, params, ones(Sim3.K_Users, 1));
        sinr_prop = metrics_calculate_sinr(H, W_prop, params.Noise_WB);
        rates_prop = params.BW_Wide * log2(1 + sinr_prop);
        all_rates_prop = [all_rates_prop; rates_prop];
        
        % RZF
        W_rzf = baseline_rzf(H, params.P_max, params.Noise_WB);
        sinr_rzf = metrics_calculate_sinr(H, W_rzf, params.Noise_WB);
        rates_rzf = params.BW_Wide * log2(1 + sinr_rzf);
        all_rates_rzf = [all_rates_rzf; rates_rzf];
        
        % Cellular
        sinr_cell = baseline_cellular(H, params.P_max, params.Noise_WB);
        rates_cell = params.BW_Wide * log2(1 + sinr_cell);
        all_rates_cell = [all_rates_cell; rates_cell];
        
        if mod(r, 1000) == 0
            fprintf('      Completed %d/%d realizations\n', r, Sim3.Realizations);
        end
    end
    
    % Calculate 5th percentile rates
    p5_prop = prctile(all_rates_prop, 5);
    p5_rzf  = prctile(all_rates_rzf, 5);
    p5_cell = prctile(all_rates_cell, 5);
    
    fprintf('    5th Percentile Rate: Prop=%.2f, RZF=%.2f, Cell=%.2f Mbps\n', ...
        p5_prop/1e6, p5_rzf/1e6, p5_cell/1e6);
    
    plot_fig3_cdf(all_rates_prop/1e6, all_rates_rzf/1e6, all_rates_cell/1e6, [p5_prop, p5_rzf, p5_cell]/1e6);
    fprintf('    Figure saved: Fig3_CDF_Analysis.png\n\n');
end

%% ========================================================================
%  Figure 4: Outage Probability vs Target Rate
%  Addresses: R2-Q5 (reliability metrics)
%  ========================================================================
function run_fig4_outage_probability(params)
    fprintf('>>> Running Fig 4: Outage Probability...\n');
    
    Sim4.M_BS         = 16;
    Sim4.K_Users      = 8;
    Sim4.Area         = 500;
    Sim4.Realizations = 1000;
    Sim4.R_Targets    = linspace(0.5, 5, 20);  % Mbps
    
    outage_prop = zeros(length(Sim4.R_Targets), 1);
    outage_rzf  = zeros(length(Sim4.R_Targets), 1);
    outage_cell = zeros(length(Sim4.R_Targets), 1);
    
    % Pre-generate all rates
    all_rates_prop = [];
    all_rates_rzf  = [];
    all_rates_cell = [];
    
    fprintf('    Generating rate samples...\n');
    for r = 1:Sim4.Realizations
        Pos_BS = (rand(Sim4.M_BS, 2) - 0.5) * Sim4.Area;
        Pos_UE = (rand(Sim4.K_Users, 2) - 0.5) * Sim4.Area;
        H = channel_generate(Pos_BS, Pos_UE, params);
        
        W_prop = two_timescale_jdc_ipc(H, params, ones(Sim4.K_Users, 1));
        sinr_prop = metrics_calculate_sinr(H, W_prop, params.Noise_WB);
        all_rates_prop = [all_rates_prop; params.BW_Wide * log2(1 + sinr_prop)];
        
        W_rzf = baseline_rzf(H, params.P_max, params.Noise_WB);
        sinr_rzf = metrics_calculate_sinr(H, W_rzf, params.Noise_WB);
        all_rates_rzf = [all_rates_rzf; params.BW_Wide * log2(1 + sinr_rzf)];
        
        sinr_cell = baseline_cellular(H, params.P_max, params.Noise_WB);
        all_rates_cell = [all_rates_cell; params.BW_Wide * log2(1 + sinr_cell)];
    end
    
    fprintf('    Calculating outage probabilities...\n');
    for idx = 1:length(Sim4.R_Targets)
        R_target = Sim4.R_Targets(idx) * 1e6;  % Convert to bps
        outage_prop(idx) = mean(all_rates_prop < R_target);
        outage_rzf(idx)  = mean(all_rates_rzf < R_target);
        outage_cell(idx) = mean(all_rates_cell < R_target);
    end
    
    plot_fig4_outage(Sim4.R_Targets, outage_prop, outage_rzf, outage_cell);
    fprintf('    Figure saved: Fig4_Outage_Probability.png\n\n');
end

%% ========================================================================
%  Figure 5: Dynamic Priority Response (Time-Series)
%  Addresses: R1-Q7, R2-Q2 (cyber-physical coupling)
%  ========================================================================
function run_fig5_dynamic_priority(params)
    fprintf('>>> Running Fig 5: Dynamic Priority Response...\n');
    
    Sim5.M_BS         = 16;
    Sim5.K_Users      = 4;
    Sim5.Area         = 300;
    Sim5.Time_Slots   = 25;
    
    % Fault scenario: User 1 experiences grid anomaly at t=8, clears at t=18
    Sim5.Fault_Start  = 8;
    Sim5.Fault_End    = 18;
    Sim5.Gamma_Normal = 5;    % dB
    Sim5.Gamma_Fault  = 15;   % dB (elevated during fault)
    
    % Fixed topology for time-series
    Pos_BS = (rand(Sim5.M_BS, 2) - 0.5) * Sim5.Area;
    Pos_UE = (rand(Sim5.K_Users, 2) - 0.5) * Sim5.Area;
    
    % Results storage
    Results.SINR_User1 = zeros(Sim5.Time_Slots, 1);
    Results.SINR_User2 = zeros(Sim5.Time_Slots, 1);
    Results.Lambda_User1 = zeros(Sim5.Time_Slots, 1);
    Results.Lambda_User2 = zeros(Sim5.Time_Slots, 1);
    Results.Target_User1 = zeros(Sim5.Time_Slots, 1);
    
    fprintf('    Running time-series simulation...\n');
    
    for t = 1:Sim5.Time_Slots
        % Generate new channel realization (fast fading)
        H = channel_generate(Pos_BS, Pos_UE, params);
        
        % Determine priority based on grid state
        if t >= Sim5.Fault_Start && t <= Sim5.Fault_End
            % Fault period: User 1 is high priority
            Gamma_Target = [params.Gamma_High_lin; params.Gamma_Low_lin * ones(Sim5.K_Users-1, 1)];
            Results.Target_User1(t) = params.Gamma_High_dB;
        else
            % Normal period: All users low priority
            Gamma_Target = params.Gamma_Low_lin * ones(Sim5.K_Users, 1);
            Results.Target_User1(t) = params.Gamma_Low_dB;
        end
        
        % Run algorithm and capture Lagrange multipliers
        [W, lambda] = two_timescale_jdc_ipc_with_output(H, params, ones(Sim5.K_Users, 1), Gamma_Target);
        sinr_all = metrics_calculate_sinr(H, W, params.Noise_WB);
        
        Results.SINR_User1(t) = 10*log10(sinr_all(1));
        Results.SINR_User2(t) = 10*log10(sinr_all(2));
        Results.Lambda_User1(t) = 10*log10(lambda(1));  % dB scale for visualization
        Results.Lambda_User2(t) = 10*log10(lambda(2));
        
        fprintf('    t=%2d | Target=%.0f dB | SINR_U1=%.1f dB | lambda_U1=%.1f dB\n', ...
            t, Results.Target_User1(t), Results.SINR_User1(t), Results.Lambda_User1(t));
    end
    
    plot_fig5_dynamic_priority(Results, Sim5);
    fprintf('    Figure saved: Fig5_Dynamic_Priority.png\n\n');
end

%% ========================================================================
%  Figure 6: Convergence Analysis
%  Addresses: R2-Q7, R2-Q9, R3-Q5 (convergence & complexity)
%  ========================================================================
function run_fig6_convergence_analysis(params)
    fprintf('>>> Running Fig 6: Convergence Analysis...\n');
    
    Sim6.M_BS    = 16;
    Sim6.K_Users = 8;
    Sim6.Area    = 500;
    
    % Fixed topology
    Pos_BS = (rand(Sim6.M_BS, 2) - 0.5) * Sim6.Area;
    Pos_UE = (rand(Sim6.K_Users, 2) - 0.5) * Sim6.Area;
    H = channel_generate(Pos_BS, Pos_UE, params);
    
    % Run algorithm with iteration tracking
    fprintf('    Running convergence tracking...\n');
    [W, conv_history] = two_timescale_jdc_ipc_convergence(H, params, ones(Sim6.K_Users, 1));
    
    % Sparsity trade-off analysis
    Mu_Values = [0.001, 0.01, 0.05, 0.1, 0.2, 0.5];
    Active_Links = zeros(length(Mu_Values), 1);
    Sum_Rate = zeros(length(Mu_Values), 1);
    
    fprintf('    Running sparsity trade-off analysis...\n');
    for idx = 1:length(Mu_Values)
        params.Mu_Cluster = Mu_Values(idx);
        W_test = two_timescale_jdc_ipc(H, params, ones(Sim6.K_Users, 1));
        Active_Links(idx) = nnz(abs(W_test) > 1e-6);
        sinr_test = metrics_calculate_sinr(H, W_test, params.Noise_WB);
        Sum_Rate(idx) = sum(params.BW_Wide * log2(1 + sinr_test)) / 1e6;
    end
    
    plot_fig6_convergence(conv_history, Mu_Values, Active_Links, Sum_Rate);
    fprintf('    Figure saved: Fig6_Convergence_Analysis.png\n\n');
end

%% ========================================================================
%  Figure 7: CSI Error Robustness
%  Addresses: R2-Q10 (channel estimation error)
%  ========================================================================
function run_fig7_csi_robustness(params)
    fprintf('>>> Running Fig 7: CSI Robustness...\n');
    
    Sim7.M_BS         = 16;
    Sim7.K_Users      = 8;
    Sim7.Area         = 500;
    Sim7.Realizations = 500;
    Sim7.Sigma_Values = [0, 0.02, 0.05, 0.08, 0.1, 0.15, 0.2];  % CSI error std
    
    Rate_Prop = zeros(length(Sim7.Sigma_Values), 1);
    Rate_RZF  = zeros(length(Sim7.Sigma_Values), 1);
    Rate_Cell = zeros(length(Sim7.Sigma_Values), 1);
    
    fprintf('    Running robustness analysis...\n');
    
    for s_idx = 1:length(Sim7.Sigma_Values)
        sigma_e = Sim7.Sigma_Values(s_idx);
        acc_prop = 0; acc_rzf = 0; acc_cell = 0;
        
        for r = 1:Sim7.Realizations
            Pos_BS = (rand(Sim7.M_BS, 2) - 0.5) * Sim7.Area;
            Pos_UE = (rand(Sim7.K_Users, 2) - 0.5) * Sim7.Area;
            
            % True channel
            H_true = channel_generate(Pos_BS, Pos_UE, params);
            
            % Estimated channel with error
            H_est = channel_with_csi_error(H_true, sigma_e);
            
            % Proposed (using estimated channel)
            W_prop = two_timescale_jdc_ipc(H_est, params, ones(Sim7.K_Users, 1));
            sinr_prop = metrics_calculate_sinr(H_true, W_prop, params.Noise_WB);  % Evaluate on true channel
            acc_prop = acc_prop + mean(params.BW_Wide * log2(1 + sinr_prop));
            
            % RZF
            W_rzf = baseline_rzf(H_est, params.P_max, params.Noise_WB);
            sinr_rzf = metrics_calculate_sinr(H_true, W_rzf, params.Noise_WB);
            acc_rzf = acc_rzf + mean(params.BW_Wide * log2(1 + sinr_rzf));
            
            % Cellular
            sinr_cell = baseline_cellular(H_true, params.P_max, params.Noise_WB);
            acc_cell = acc_cell + mean(params.BW_Wide * log2(1 + sinr_cell));
        end
        
        Rate_Prop(s_idx) = (acc_prop / Sim7.Realizations) / 1e6;
        Rate_RZF(s_idx)  = (acc_rzf / Sim7.Realizations) / 1e6;
        Rate_Cell(s_idx) = (acc_cell / Sim7.Realizations) / 1e6;
        
        fprintf('    sigma_e=%.2f | Prop=%.2f, RZF=%.2f, Cell=%.2f Mbps\n', ...
            sigma_e, Rate_Prop(s_idx), Rate_RZF(s_idx), Rate_Cell(s_idx));
    end
    
    plot_fig7_csi_robustness(Sim7.Sigma_Values, Rate_Prop, Rate_RZF, Rate_Cell);
    fprintf('    Figure saved: Fig7_CSI_Robustness.png\n\n');
end

%% ========================================================================
%  Helper: Initialize results structure
%  ========================================================================
function Res = initialize_results()
    Res = struct();
end
