function H = channel_generate(Pos_BS, Pos_UE, params)
% CHANNEL_GENERATE  Generate channel matrix with path loss and Rayleigh fading
%
%   Input:
%       Pos_BS  - BS positions (M x 2)
%       Pos_UE  - UE positions (K x 2)
%       params  - System parameters (PathLossExp, RefLoss_dB)
%
%   Output:
%       H       - Channel matrix (M x K)
%
%   Channel model: h = sqrt(beta) * g
%   where beta = path loss, g = Rayleigh fading ~ CN(0,1)

    M = size(Pos_BS, 1);
    K = size(Pos_UE, 1);
    H = zeros(M, K);
    
    alpha = params.PathLossExp;
    RefLoss_dB = params.RefLoss_dB;
    C_PL = 10^(-RefLoss_dB/10);  % Path loss constant at 1m reference
    
    for k = 1:K
        for m = 1:M
            % Distance
            dist = norm(Pos_BS(m, :) - Pos_UE(k, :));
            dist = max(dist, 10);  % Minimum distance 10m to avoid singularity
            
            % Path loss
            beta = C_PL * (dist ^ (-alpha));
            
            % Small-scale fading (Rayleigh)
            g = (randn + 1i * randn) / sqrt(2);
            
            % Composite channel
            H(m, k) = sqrt(beta) * g;
        end
    end
end
