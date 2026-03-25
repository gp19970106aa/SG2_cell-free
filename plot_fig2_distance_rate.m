
%% ========================================================================
%  Figure 2: Distance vs Rate
%  ========================================================================

function plot_fig2_distance_rate(Dist_Points, Res)
% PLOT_FIG2_DISTANCE_RATE  Figure 2: Coverage Distance vs Achievable Rate

    figure('Name', 'Fig2_Distance_vs_Rate', 'Color', 'w', ...
        'Position', [100, 100, 650, 480], 'Renderer', 'painters');
    
    % Plot curves
    h1 = plot(Dist_Points, Res.Rate_NB, '-m>', 'LineWidth', 2.5, ...
        'MarkerFaceColor', 'm', 'MarkerSize', 8, 'MarkerEdgeColor', 'k'); hold on;
    h2 = plot(Dist_Points, Res.Rate_Cell, '-k^', 'LineWidth', 2.5, ...
        'MarkerFaceColor', [0.5 0.5 0.5], 'MarkerSize', 8, 'MarkerEdgeColor', 'k');
    h3 = plot(Dist_Points, Res.Rate_RZF, '-bs', 'LineWidth', 2.5, ...
        'MarkerFaceColor', 'b', 'MarkerSize', 8, 'MarkerEdgeColor', 'k');
    h4 = plot(Dist_Points, Res.Rate_High, '-ro', 'LineWidth', 2.5, ...
        'MarkerFaceColor', 'r', 'MarkerSize', 8, 'MarkerEdgeColor', 'k');
    h5 = plot(Dist_Points, Res.Rate_Low, '--ro', 'LineWidth', 2.5, ...
        'MarkerFaceColor', 'w', 'MarkerSize', 8, 'MarkerEdgeColor', 'r');
    
    % Labels
    xlabel('Distance from Network Center (m)', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('Achievable Rate (Mbps)', 'FontSize', 14, 'FontWeight', 'bold');
    
    % Legend
    legend([h1, h2, h3, h4, h5], ...
        {'NB-IoT (25 kHz)', 'Cellular', 'RZF Cell-Free', ...
         'Proposed (High-Priority)', 'Proposed (Low-Priority)'}, ...
        'Location', 'northeast', 'FontSize', 11, 'Box', 'off');
    
    grid on;
    ylim([0, max(Res.Rate_High) * 1.15]);
    set(gca, 'FontSize', 12, 'LineWidth', 1.5, 'TickDir', 'out');
    
    % Coverage limit annotation
    xline(2000, ':k', 'Coverage Limit', 'LineWidth', 1.5, 'LabelVerticalAlignment', 'bottom');
    
    % Save
    print('Fig2_Distance_vs_Rate.png', '-dpng', '-r300');
    print('Fig2_Distance_vs_Rate.pdf', '-dpdf');
end
