
%% ========================================================================
%  Figure 4: Outage Probability
%  ========================================================================

function plot_fig4_outage(R_Targets, outage_prop, outage_rzf, outage_cell)
% PLOT_FIG4_OUTAGE  Figure 4: Outage Probability vs Target Rate

    figure('Name', 'Fig4_Outage_Probability', 'Color', 'w', ...
        'Position', [100, 100, 650, 480], 'Renderer', 'painters');
    
    % Plot with log y-axis
    h1 = semilogy(R_Targets, outage_prop + 1e-6, '-ro', 'LineWidth', 2.5, ...
        'MarkerFaceColor', 'r', 'MarkerSize', 8, 'MarkerEdgeColor', 'k'); hold on;
    h2 = semilogy(R_Targets, outage_rzf + 1e-6, '-bs', 'LineWidth', 2.5, ...
        'MarkerFaceColor', 'b', 'MarkerSize', 8, 'MarkerEdgeColor', 'k');
    h3 = semilogy(R_Targets, outage_cell + 1e-6, '-k^', 'LineWidth', 2.5, ...
        'MarkerFaceColor', [0.5 0.5 0.5], 'MarkerSize', 8, 'MarkerEdgeColor', 'k');
    
    % Labels
    xlabel('Target Rate (Mbps)', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('Outage Probability', 'FontSize', 14, 'FontWeight', 'bold');
    
    % Legend
    legend([h1, h2, h3], {'Proposed', 'RZF', 'Cellular'}, ...
        'Location', 'northwest', 'FontSize', 12, 'Box', 'off');
    
    grid on;
    ylim([1e-4, 1]);
    set(gca, 'FontSize', 12, 'LineWidth', 1.5, 'TickDir', 'out', 'YScale', 'log');
    
    % Save
    print('Fig4_Outage_Probability.png', '-dpng', '-r300');
    print('Fig4_Outage_Probability.pdf', '-dpdf');
end