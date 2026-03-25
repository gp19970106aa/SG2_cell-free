
%% ========================================================================
%  Two-Timescale JDC-IPC with Output (for dynamic priority analysis)
%  ========================================================================

function [W, lambda] = two_timescale_jdc_ipc_with_output(H, params, priority_vec, Gamma_Target)
% TWO_TIMESCALE_JDC_IPC_WITH_OUTPUT  Algorithm with Lagrange multiplier output
%
%   Additional input:
%       Gamma_Target - Per-user SINR targets (K x 1)
%
%   Additional output:
%       lambda       - Final Lagrange multipliers (for visualization)

    [M, K] = size(H);
    
    % Phase 1: Statistical clustering (same as above)
    H_stat = zeros(M, K);
    for m = 1:M
        for k = 1:K
            H_stat(m, k) = sqrt(mean(abs(H(m, k)).^2));
        end
    end
    
    W_cluster = baseline_rzf(H_stat, params.P_max, params.Noise_WB);
    lambda_cluster = 10 * ones(K, 1);
    nu = 1e-3 * ones(M, 1);
    MSE_target_cluster = 1 ./ (1 + params.Gamma_Low_lin * ones(K, 1));
    beta_mk = ones(M, K);
    
    for iter = 1:params.MaxIter_Cluster
        if iter < 5
            curr_Mu = 0;
        else
            curr_Mu = params.Mu_Cluster;
        end
        
        u = zeros(K, 1);
        MSE_curr = zeros(K, 1);
        for k = 1:K
            rx_pwr = params.Noise_WB;
            for j = 1:K
                rx_pwr = rx_pwr + abs(H_stat(:, k)' * W_cluster(:, j))^2;
            end
            if rx_pwr > 1e-12
                u(k) = (H_stat(:, k)' * W_cluster(:, k)) / rx_pwr;
            else
                u(k) = 0;
            end
            MSE_curr(k) = 1 - real(u(k) * H_stat(:, k)' * W_cluster(:, k));
        end
        
        epsilon = 1e-3;
        beta_mk = 1 ./ (abs(W_cluster) + epsilon);
        
        Q = zeros(M, M);
        for j = 1:K
            Q = Q + lambda_cluster(j) * (abs(u(j))^2) * (H_stat(:, j) * H_stat(:, j)');
        end
        Q = Q + 1e-6 * eye(M);
        
        for k = 1:K
            D_k = diag(curr_Mu * beta_mk(:, k));
            Nu_mat = diag(nu);
            Phi = Q + D_k + Nu_mat + eye(M);
            b = lambda_cluster(k) * conj(u(k)) * H_stat(:, k);
            W_cluster(:, k) = Phi \ b;
        end
        
        grad_lambda = MSE_curr - MSE_target_cluster;
        lambda_cluster = max(0.1, lambda_cluster + 10.0 * grad_lambda);
        
        bs_pwr = sum(abs(W_cluster).^2, 2);
        nu = max(0, nu + 0.01 * (bs_pwr - params.P_max));
    end
    
    threshold = 1e-3 * max(abs(W_cluster(:)));
    active_mask = abs(W_cluster) > threshold;
    
    % Phase 2: WMMSE precoding with custom Gamma targets
    W = W_cluster;
    lambda = 10 * ones(K, 1) .* priority_vec;
    nu = 1e-3 * ones(M, 1);
    MSE_target = 1 ./ (1 + Gamma_Target);
    
    for iter = 1:params.MaxIter_Precod
        u = zeros(K, 1);
        MSE_curr = zeros(K, 1);
        for k = 1:K
            rx_pwr = params.Noise_WB;
            for j = 1:K
                rx_pwr = rx_pwr + abs(H(:, k)' * W(:, j))^2;
            end
            if rx_pwr > 1e-12
                u(k) = (H(:, k)' * W(:, k)) / rx_pwr;
            else
                u(k) = 0;
            end
            MSE_curr(k) = 1 - real(u(k) * H(:, k)' * W(:, k));
        end
        
        Q = zeros(M, M);
        for j = 1:K
            Q = Q + lambda(j) * (abs(u(j))^2) * (H(:, j) * H(:, j)');
        end
        Q = Q + 1e-6 * eye(M);
        
        for k = 1:K
            Nu_mat = diag(nu);
            Phi = Q + Nu_mat + eye(M);
            b = lambda(k) * conj(u(k)) * H(:, k);
            W_new = Phi \ b;
            W_new(~active_mask(:, k)) = 0;
            W(:, k) = W_new;
        end
        
        % Asymmetric lambda update
        for k = 1:K
            if MSE_curr(k) > MSE_target(k)
                lambda(k) = lambda(k) + 15.0 * (MSE_curr(k) - MSE_target(k));
            else
                lambda(k) = max(0.1, lambda(k) + 0.15 * (MSE_curr(k) - MSE_target(k)));
            end
        end
        
        bs_pwr = sum(abs(W).^2, 2);
        nu = max(0, nu + 0.02 * (bs_pwr - params.P_max));
    end
    
    % Final power normalization
    bs_pwr = sum(abs(W).^2, 2);
    for m = 1:M
        if bs_pwr(m) > params.P_max
            W(m, :) = W(m, :) * sqrt(params.P_max / bs_pwr(m));
        end
    end
end