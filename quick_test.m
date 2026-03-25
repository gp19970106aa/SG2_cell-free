%% ========================================================================
%  Quick Test Script for SG2 Simulation Framework
%  ========================================================================
%  This script runs a minimal test to verify the framework works correctly
%  Run time: ~1-2 minutes
%  ========================================================================

function quick_test()
    clc; clear; close all;
    warning('off', 'all');
    
    fprintf('============================================================\n');
    fprintf('  SG2 Cell-Free MISO Simulation - Quick Test\n');
    fprintf('============================================================\n\n');
    
    %% System Parameters
    params.CarrierFreq     = 230e6;
    params.BW_Wide         = 1e6;
    params.NoisePSD        = -130;
    params.P_max_dBm       = 43;
    params.P_max           = 10^((params.P_max_dBm-30)/10);
    params.Noise_WB        = 10^((params.NoisePSD-30)/10) * params.BW_Wide;
    params.PathLossExp     = 3.5;
    params.RefLoss_dB      = 30;
    params.Gamma_High_dB   = 15;
    params.Gamma_Low_dB    = 5;
    params.Gamma_High_lin  = 10^(params.Gamma_High_dB/10);
    params.Gamma_Low_lin   = 10^(params.Gamma_Low_dB/10);
    params.Mu_Cluster      = 0.05;
    params.Mu_Precod       = 0;
    params.MaxIter_Cluster = 30;
    params.MaxIter_Precod  = 50;
    
    %% Test 1: Basic Algorithm Functionality
    fprintf('Test 1: Basic Algorithm Functionality...\n');
    
    M = 16; K = 8; Area = 500;
    Pos_BS = (rand(M, 2) - 0.5) * Area;
    Pos_UE = (rand(K, 2) - 0.5) * Area;
    
    % Generate channel
    H = channel_generate(Pos_BS, Pos_UE, params);
    fprintf('  Channel generated: M=%d BSs, K=%d UEs\n', M, K);
    fprintf('  Channel norm: ||H||_F = %.4f\n', norm(H, 'fro'));
    
    % Run algorithm
    W = two_timescale_jdc_ipc(H, params, ones(K, 1));
    fprintf('  Precoding matrix computed: size(W) = [%d, %d]\n', size(W, 1), size(W, 2));
    
    % Calculate SINR
    sinr = metrics_calculate_sinr(H, W, params.Noise_WB);
    fprintf('  Average SINR: %.2f dB\n', mean(10*log10(sinr)));
    fprintf('  Min SINR: %.2f dB\n', min(10*log10(sinr)));
    
    % Check power constraint
    bs_power = sum(abs(W).^2, 2);
    fprintf('  Max BS power: %.2f W (limit: %.2f W)\n', max(bs_power), params.P_max);
    
    if all(bs_power <= params.P_max * 1.01)  % 1% tolerance
        fprintf('  ✓ Power constraint satisfied\n');
    else
        fprintf('  ✗ Power constraint VIOLATED!\n');
    end
    
    fprintf('\n');
    
    %% Test 2: Two-Timescale Verification
    fprintf('Test 2: Two-Timescale Architecture Verification...\n');
    
    % Run with convergence tracking
    [W, conv] = two_timescale_jdc_ipc_convergence(H, params, ones(K, 1));
    
    fprintf('  Total iterations: %d\n', conv.Iterations);
    fprintf('  Clustering phase: ~%d iterations\n', params.MaxIter_Cluster);
    fprintf('  Precoding phase: ~%d iterations\n', params.MaxIter_Precod);
    
    % Check convergence
    if length(conv.Obj_Value) > 10
        obj_change = abs(conv.Obj_Value(end) - conv.Obj_Value(end-5)) / conv.Obj_Value(end-5);
        fprintf('  Objective change (last 5 iter): %.6f\n', obj_change);
        
        if obj_change < 0.01
            fprintf('  ✓ Algorithm converged\n');
        else
            fprintf('  ⚠ Algorithm may not have fully converged\n');
        end
    end
    
    % Check sparsity (clustering effect)
    active_links = nnz(abs(W) > 1e-6);
    total_links = M * K;
    fprintf('  Active links: %d / %d (%.1f%%)\n', active_links, total_links, 100*active_links/total_links);
    
    fprintf('\n');
    
    %% Test 3: Dynamic Priority Response
    fprintf('Test 3: Dynamic Priority Response...\n');
    
    % Normal period
    Gamma_Normal = params.Gamma_Low_lin * ones(K, 1);
    [W_normal, lambda_normal] = two_timescale_jdc_ipc_with_output(H, params, ones(K, 1), Gamma_Normal);
    sinr_normal = metrics_calculate_sinr(H, W_normal, params.Noise_WB);
    
    % Fault period (User 1 elevated)
    Gamma_Fault = [params.Gamma_High_lin; params.Gamma_Low_lin * ones(K-1, 1)];
    [W_fault, lambda_fault] = two_timescale_jdc_ipc_with_output(H, params, ones(K, 1), Gamma_Fault);
    sinr_fault = metrics_calculate_sinr(H, W_fault, params.Noise_WB);
    
    fprintf('  User 1 SINR: Normal=%.2f dB → Fault=%.2f dB (Δ=%.2f dB)\n', ...
        10*log10(sinr_normal(1)), 10*log10(sinr_fault(1)), ...
        10*log10(sinr_fault(1)/sinr_normal(1)));
    fprintf('  User 1 λ: Normal=%.2f dB → Fault=%.2f dB (Δ=%.2f dB)\n', ...
        10*log10(lambda_normal(1)), 10*log10(lambda_fault(1)), ...
        10*log10(lambda_fault(1)/lambda_normal(1)));
    
    if sinr_fault(1) > sinr_normal(1) * 1.5  % At least 50% improvement
        fprintf('  ✓ Priority mechanism working correctly\n');
    else
        fprintf('  ⚠ Priority response may be weak\n');
    end
    
    fprintf('\n');
    
    %% Test 4: CSI Error Robustness
    fprintf('Test 4: CSI Error Robustness...\n');
    
    sigma_test = [0, 0.05, 0.1, 0.15];
    rates = zeros(size(sigma_test));
    
    for idx = 1:length(sigma_test)
        H_est = channel_with_csi_error(H, sigma_test(idx));
        W_test = two_timescale_jdc_ipc(H_est, params, ones(K, 1));
        sinr_test = metrics_calculate_sinr(H, W_test, params.Noise_WB);  % Evaluate on true channel
        rates(idx) = mean(params.BW_Wide * log2(1 + sinr_test)) / 1e6;
    end
    
    fprintf('  Rate vs CSI error:\n');
    for idx = 1:length(sigma_test)
        fprintf('    σ_e=%.2f: %.2f Mbps (degradation: %.1f%%)\n', ...
            sigma_test(idx), rates(idx), 100*(rates(1)-rates(idx))/rates(1));
    end
    
    if rates(end) > rates(1) * 0.7  % Less than 30% degradation at σ_e=0.15
        fprintf('  ✓ Algorithm shows good robustness\n');
    else
        fprintf('  ⚠ Algorithm may be sensitive to CSI error\n');
    end
    
    fprintf('\n');
    
    %% Test 5: Baseline Comparison
    fprintf('Test 5: Baseline Comparison...\n');
    
    % Generate multiple realizations for statistical significance
    N_test = 50;
    sinr_prop = zeros(N_test, K);
    sinr_rzf = zeros(N_test, K);
    sinr_cell = zeros(N_test, K);
    
    for n = 1:N_test
        Pos_BS = (rand(M, 2) - 0.5) * Area;
        Pos_UE = (rand(K, 2) - 0.5) * Area;
        H = channel_generate(Pos_BS, Pos_UE, params);
        
        W_prop = two_timescale_jdc_ipc(H, params, ones(K, 1));
        sinr_prop(n, :) = metrics_calculate_sinr(H, W_prop, params.Noise_WB)';
        
        W_rzf = baseline_rzf(H, params.P_max, params.Noise_WB);
        sinr_rzf(n, :) = metrics_calculate_sinr(H, W_rzf, params.Noise_WB)';
        
        sinr_cell(n, :) = baseline_cellular(H, params.P_max, params.Noise_WB)';
    end
    
    avg_sinr_prop = mean(10*log10(sinr_prop(:)));
    avg_sinr_rzf = mean(10*log10(sinr_rzf(:)));
    avg_sinr_cell = mean(10*log10(sinr_cell(:)));
    
    fprintf('  Average SINR comparison (%d realizations):\n', N_test);
    fprintf('    Proposed: %.2f dB\n', avg_sinr_prop);
    fprintf('    RZF:      %.2f dB (Δ=%.2f dB)\n', avg_sinr_rzf, avg_sinr_prop - avg_sinr_rzf);
    fprintf('    Cellular: %.2f dB (Δ=%.2f dB)\n', avg_sinr_cell, avg_sinr_prop - avg_sinr_cell);
    
    if avg_sinr_prop > avg_sinr_rzf && avg_sinr_prop > avg_sinr_cell
        fprintf('  ✓ Proposed algorithm outperforms baselines\n');
    else
        fprintf('  ⚠ Performance gain not consistent - check parameters\n');
    end
    
    fprintf('\n');
    
    %% Summary
    fprintf('============================================================\n');
    fprintf('  Quick Test Complete!\n');
    fprintf('============================================================\n');
    fprintf('\n');
    fprintf('If all tests passed (✓), the framework is ready for full simulation.\n');
    fprintf('Run main_simulation() to generate all 7 figures for the revision.\n');
    fprintf('\n');
end
