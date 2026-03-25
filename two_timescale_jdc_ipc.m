
function W = two_timescale_jdc_ipc(H, params, priority_vec)
% TWO_TIMESCALE_JDC_IPC  Two-Timescale Joint Dynamic Clustering and 
%   Interference-Aware Power Control Algorithm
%
%   Input:
%       H           - Instantaneous channel matrix (M x K)
%       params      - System parameters structure
%       priority_vec - Priority weights for users (K x 1)
%
%   Output:
%       W           - Optimized precoding matrix (M x K)
%
%   This function implements the complete two-timescale algorithm:
%   1. Long-term statistical clustering (reweighted l1-norm minimization)
%   2. Short-term WMMSE precoding (fixed cluster, no sparsity penalty)

    [M, K] = size(H);
    
    % ====================================================================
    %  PHASE 1: Long-Term Statistical Clustering
    %  Uses statistical CSI (large-scale fading) for stable cluster formation
    %  ====================================================================
    
    % Extract large-scale fading (statistical CSI)
    % For Rayleigh fading: E[|h|^2] = large-scale gain
    H_stat = zeros(M, K);
    for m = 1:M
        for k = 1:K
            H_stat(m, k) = sqrt(mean(abs(H(m, k)).^2));  % Statistical gain
        end
    end
    
    % Initialize clustering precoding
    W_cluster = baseline_rzf(H_stat, params.P_max, params.Noise_WB);
    lambda = 10 * ones(K, 1) .* priority_vec;
    nu = 1e-3 * ones(M, 1);
    MSE_target = 1 ./ (1 + params.Gamma_Low_lin * ones(K, 1));
    
    % Reweighted l1-norm weights
    beta_mk = ones(M, K);
    
    % Clustering iterations
    for iter = 1:params.MaxIter_Cluster
        % Use sparsity penalty only after initial iterations (warm start)
        if iter < 5
            curr_Mu = 0;
        else
            curr_Mu = params.Mu_Cluster;
        end
        
        % 1. MMSE Receiver (statistical CSI)
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
        
        % 2. Update sparsity weights (reweighted l1-norm)
        epsilon = 1e-3;
        beta_mk = 1 ./ (abs(W_cluster) + epsilon);
        
        % 3. Closed-form precoding update
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
        
        % 4. Lagrange multiplier updates
        grad_lambda = MSE_curr - MSE_target;
        step_lambda = 10.0;
        lambda = max(0.1, lambda + step_lambda * grad_lambda);
        
        bs_pwr = sum(abs(W_cluster).^2, 2);
        grad_nu = bs_pwr - params.P_max;
        nu = max(0, nu + 0.01 * grad_nu);
    end
    
    % Extract active clusters from sparsity pattern
    threshold = 1e-3 * max(abs(W_cluster(:)));
    active_mask = abs(W_cluster) > threshold;
    
    % ====================================================================
    %  PHASE 2: Short-Term WMMSE Precoding
    %  Uses instantaneous CSI within fixed cluster (no sparsity penalty)
    %  ====================================================================
    
    % Initialize with clustering result
    W = W_cluster;
    lambda = 10 * ones(K, 1) .* priority_vec;
    nu = 1e-3 * ones(M, 1);
    
    % Adjust MSE target based on priority
    MSE_target = zeros(K, 1);
    for k = 1:K
        if priority_vec(k) >= 8  % High priority threshold
            MSE_target(k) = 1 / (1 + params.Gamma_High_lin);
        else
            MSE_target(k) = 1 / (1 + params.Gamma_Low_lin);
        end
    end
    
    % WMMSE iterations (no sparsity penalty)
    for iter = 1:params.MaxIter_Precod
        % 1. MMSE Receiver (instantaneous CSI)
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
        
        % 2. Closed-form precoding update (no sparsity, fixed cluster)
        Q = zeros(M, M);
        for j = 1:K
            Q = Q + lambda(j) * (abs(u(j))^2) * (H(:, j) * H(:, j)');
        end
        Q = Q + 1e-6 * eye(M);
        
        for k = 1:K
            % Apply cluster mask: only use active BS-UE links
            Nu_mat = diag(nu);
            Phi = Q + Nu_mat + eye(M);
            b = lambda(k) * conj(u(k)) * H(:, k);
            W_new = Phi \ b;
            
            % Enforce cluster structure
            W_new(~active_mask(:, k)) = 0;
            W(:, k) = W_new;
        end
        
        % 3. Lagrange multiplier updates (asymmetric for stability)
        grad_lambda = MSE_curr - MSE_target;
        step_lambda_up = 15.0;
        step_lambda_down = 0.15;  % Slower decrease to maintain QoS
        
        for k = 1:K
            if grad_lambda(k) > 0
                lambda(k) = lambda(k) + step_lambda_up * grad_lambda(k);
            else
                lambda(k) = max(0.1, lambda(k) + step_lambda_down * grad_lambda(k));
            end
        end
        
        bs_pwr = sum(abs(W).^2, 2);
        grad_nu = bs_pwr - params.P_max;
        nu = max(0, nu + 0.02 * grad_nu);
    end
    
    % Final power normalization
    bs_pwr = sum(abs(W).^2, 2);
    for m = 1:M
        if bs_pwr(m) > params.P_max
            W(m, :) = W(m, :) * sqrt(params.P_max / bs_pwr(m));
        end
    end
end
