
function plot_fig1_density_sinr(M_List, Res, theoretical_limit_dB)
% PLOT_FIG1_DENSITY_SINR  Figure 1: Network Densification vs SINR
%
%   Shows SINR and power consumption vs number of BSs
%   Includes theoretical interference limit (Eq. 6)

    figure('Name', 'Fig1_Density_vs_SINR', 'Color', 'w', ...
        'Position', [100, 100, 750, 520], 'Renderer', 'painters');
    
    % Create dual y-axis
    yyaxis left
    
    % SINR curves (solid lines, filled markers)
    h1 = plot(M_List, Res.Prop_sinr, '-ro', 'LineWidth', 2.5, ...
        'MarkerFaceColor', 'r', 'MarkerSize', 9, 'MarkerEdgeColor', 'k'); hold on;
    h2 = plot(M_List, Res.RZF_sinr, '-bs', 'LineWidth', 2.5, ...
        'MarkerFaceColor', 'b', 'MarkerSize', 9, 'MarkerEdgeColor', 'k');
    h3 = plot(M_List, Res.Cell_sinr, '-k^', 'LineWidth', 2.5, ...
        'MarkerFaceColor', [0.5 0.5 0.5], 'MarkerSize', 9, 'MarkerEdgeColor', 'k');
    
    ylabel('Average User SINR (dB)', 'FontSize', 14, 'FontWeight', 'bold');
    ylim([-10, 25]);
    grid on;
    
    % Theoretical limit line
    h_limit = yline(theoretical_limit_dB, 'r--', 'LineWidth', 2.5);
    
    yyaxis right
    
    % Power curves (dashed lines)
    h4 = plot(M_List, Res.Prop_pwr, '--r*', 'LineWidth', 2, ...
        'MarkerSize', 10, 'MarkerEdgeColor', 'k'); hold on;
    h5 = plot(M_List, Res.RZF_pwr, '--b', 'LineWidth', 2, ...
        'MarkerFaceColor', 'w', 'MarkerSize', 8, 'MarkerEdgeColor', 'k');
    
    % Cellular always at full power
    P_cell = ones(size(M_List)) * 20;  % 20W = 43dBm
    h6 = plot(M_List, P_cell, ':k', 'LineWidth', 2);
    
    ylabel('Avg. BS Power (W)', 'FontSize', 14, 'FontWeight', 'bold');
    ylim([0, 25]);
    
    % Labels and formatting
    xlabel('Number of Base Stations (Network Density)', 'FontSize', 14, 'FontWeight', 'bold');
    
    % Legend
    legend([h1, h2, h3, h4, h5, h_limit], ...
        {'Proposed (SINR)', 'RZF (SINR)', 'Cellular (SINR)', ...
         'Proposed (Power)', 'RZF (Power)', 'Theoretical Limit (Eq. 6)'}, ...
        'Location', 'southeast', 'FontSize', 11, 'Box', 'off');
    
    set(gca, 'FontSize', 12, 'LineWidth', 1.5, 'TickDir', 'out');
    set(gca, 'XColor', 'k', 'YColor', 'k');
    ax = gca;
    ax.YAxis(1).Color = 'k';
    ax.YAxis(2).Color = 'k';
    
    % Save high-resolution figure
    print('Fig1_Density_vs_SINR.png', '-dpng', '-r300');
    print('Fig1_Density_vs_SINR.pdf', '-dpdf');
end
