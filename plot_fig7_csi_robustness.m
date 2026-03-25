
%% ========================================================================
%  Figure 7: CSI Robustness
%  ========================================================================

function plot_fig7_csi_robustness(Sigma_Values, Rate_Prop, Rate_RZF, Rate_Cell)
% PLOT_FIG7_CSI_ROBUSTNESS  Figure 7: Robustness to CSI Error

    figure('Name', 'Fig7_CSI_Robustness', 'Color', 'w', ...
        'Position', [100, 100, 650, 480], 'Renderer', 'painters');
    
    % Plot curves
    h1 = plot(Sigma_Values, Rate_Prop, '-ro', 'LineWidth', 2.5, ...
        'MarkerFaceColor', 'r', 'MarkerSize', 9, 'MarkerEdgeColor', 'k'); hold on;
    h2 = plot(Sigma_Values, Rate_RZF, '-bs', 'LineWidth', 2.5, ...
        'MarkerFaceColor', 'b', 'MarkerSize', 9, 'MarkerEdgeColor', 'k');
    h3 = plot(Sigma_Values, Rate_Cell, '-k^', 'LineWidth', 2.5, ...
        'MarkerFaceColor', [0.5 0.5 0.5], 'MarkerSize', 9, 'MarkerEdgeColor', 'k');
    
    % Labels
    xlabel('CSI Error Standard Deviation (\sigma_e)', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('Average Rate (Mbps)', 'FontSize', 14, 'FontWeight', 'bold');
    
    % Legend
    legend([h1, h2, h3], {'Proposed', 'RZF', 'Cellular'}, ...
        'Location', 'northeast', 'FontSize', 12, 'Box', 'off');
    
    grid on;
    ylim([0, max(Rate_Prop) * 1.15]);
    set(gca, 'FontSize', 12, 'LineWidth', 1.5, 'TickDir', 'out');
    
    % Save
    print('Fig7_CSI_Robustness.png', '-dpng', '-r300');
    print('Fig7_CSI_Robustness.pdf', '-dpdf');
end
