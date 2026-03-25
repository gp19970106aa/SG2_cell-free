

%% ========================================================================
%  Two-Timescale JDC-IPC with Convergence Tracking
%  ========================================================================

function [W, conv_history] = two_timescale_jdc_ipc_convergence(H, params, priority_vec)
% TWO_TIMESCALE_JDC_IPC_CONVERGENCE  Algorithm with convergence history output
%
%   Output:
%       conv_history - Structure with iteration-by-iteration metrics

    [M, K] = size(H);
    
    conv_history.Iterations = 0;
    conv_history.Obj_Value = [];
    conv_history.Sum_MSE = [];
    conv_history.Sum_Power = [];
    
    % Phase 1: Clustering
    H_stat = zeros(M, K);
    for m = 1:M
        for k = 1:K
            H_stat(m, k) = sqrt(mean(abs(H(m, k)).^2));
        end
    end
    
    W_cluster = baseline_rzf(H_stat, params.P_max, params.Noise_WB);
    lambda = 10 * ones(K, 1) .* priority_vec;
    nu = 1e-3 * ones(M, 1);
    MSE_target = 1 ./ (1 + params.Gamma_Low_lin * ones(K, 1));
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
            Q = Q + lambda(j) * (abs(u(j))^2) * (H_stat(:, j) * H_stat(:, j)');
        end
        Q = Q + 1e-6 * eye(M);
        
        for k = 1:K
            D_k = diag(curr_Mu * beta_mk(:, k));
            Nu_mat = diag(nu);
            Phi = Q + D_k + Nu_mat + eye(M);
            b = lambda(k) * conj(u(k)) * H_stat(:, k);
            W_cluster(:, k) = Phi \ b;
        end
        
        grad_lambda = MSE_curr - MSE_target;
        lambda = max(0.1, lambda + 10.0 * grad_lambda);
        
        bs_pwr = sum(abs(W_cluster).^2, 2);
        nu = max(0, nu + 0.01 * (bs_pwr - params.P_max));
        
        % Track convergence
        obj_val = sum(abs(W_cluster(:)).^2) + curr_Mu * sum(abs(W_cluster(:)));
        conv_history.Obj_Value = [conv_history.Obj_Value; obj_val];
        conv_history.Sum_MSE = [conv_history.Sum_MSE; sum(MSE_curr)];
        conv_history.Sum_Power = [conv_history.Sum_Power; sum(bs_pwr)];
        conv_history.Iterations = conv_history.Iterations + 1;
    end
    
    threshold = 1e-3 * max(abs(W_cluster(:)));
    active_mask = abs(W_cluster) > threshold;
    
    % Phase 2: WMMSE precoding
    W = W_cluster;
    lambda = 10 * ones(K, 1) .* priority_vec;
    nu = 1e-3 * ones(M, 1);
    MSE_target = 1 ./ (1 + params.Gamma_Low_lin * ones(K, 1));
    
    precod_start = conv_history.Iterations + 1;
    
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
        
        grad_lambda = MSE_curr - MSE_target;
        for k = 1:K
            if grad_lambda(k) > 0
                lambda(k) = lambda(k) + 15.0 * grad_lambda(k);
            else
                lambda(k) = max(0.1, lambda(k) + 0.15 * grad_lambda(k));
            end
        end
        
        bs_pwr = sum(abs(W).^2, 2);
        nu = max(0, nu + 0.02 * (bs_pwr - params.P_max));
        
        % Track convergence
        obj_val = sum(abs(W(:)).^2);
        conv_history.Obj_Value = [conv_history.Obj_Value; obj_val];
        conv_history.Sum_MSE = [conv_history.Sum_MSE; sum(MSE_curr)];
        conv_history.Sum_Power = [conv_history.Sum_Power; sum(bs_pwr)];
        conv_history.Iterations = conv_history.Iterations + 1;
    end
    
    % Final power normalization
    bs_pwr = sum(abs(W).^2, 2);
    for m = 1:M
        if bs_pwr(m) > params.P_max
            W(m, :) = W(m, :) * sqrt(params.P_max / bs_pwr(m));
        end
    end
end