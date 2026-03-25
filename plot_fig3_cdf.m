
%% ========================================================================
%  Figure 3: CDF Analysis
%  ========================================================================

function plot_fig3_cdf(rates_prop, rates_rzf, rates_cell, p5_values)
% PLOT_FIG3_CDF  Figure 3: CDF of Achievable Rate

    figure('Name', 'Fig3_CDF_Analysis', 'Color', 'w', ...
        'Position', [100, 100, 650, 480], 'Renderer', 'painters');
    
    % Sort rates for CDF
    [sorted_prop, ~] = sort(rates_prop);
    [sorted_rzf, ~] = sort(rates_rzf);
    [sorted_cell, ~] = sort(rates_cell);
    
    N_prop = length(sorted_prop);
    N_rzf = length(sorted_rzf);
    N_cell = length(sorted_cell);
    
    cdf_prop = (1:N_prop)' / N_prop;
    cdf_rzf = (1:N_rzf)' / N_rzf;
    cdf_cell = (1:N_cell)' / N_cell;
    
    % Plot CDF curves
    h1 = plot(sorted_prop, cdf_prop, '-r', 'LineWidth', 2.5); hold on;
    h2 = plot(sorted_rzf, cdf_rzf, '-b', 'LineWidth', 2.5);
    h3 = plot(sorted_cell, cdf_cell, '-k', 'LineWidth', 2.5);
    
    % 5th percentile markers
    plot(p5_values(1), 0.05, 'ro', 'MarkerSize', 12, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
    plot(p5_values(2), 0.05, 'bs', 'MarkerSize', 12, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k');
    plot(p5_values(3), 0.05, 'k^', 'MarkerSize', 12, 'MarkerFaceColor', [0.5 0.5 0.5], 'MarkerEdgeColor', 'k');
    
    % 5th percentile reference line
    yline(0.05, '--k', 'LineWidth', 1.5);
    
    % Labels
    xlabel('Achievable Rate (Mbps)', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('CDF', 'FontSize', 14, 'FontWeight', 'bold');
    
    % Legend
    legend([h1, h2, h3], {'Proposed', 'RZF', 'Cellular'}, ...
        'Location', 'southeast', 'FontSize', 12, 'Box', 'off');
    
    grid on;
    xlim([0, max([sorted_prop; sorted_rzf; sorted_cell])]);
    ylim([0, 1]);
    set(gca, 'FontSize', 12, 'LineWidth', 1.5, 'TickDir', 'out');
    
    % 5th percentile annotation
    text(p5_values(1) + 0.1, 0.08, sprintf('5th: %.2f Mbps', p5_values(1)), ...
        'Color', 'r', 'FontSize', 11, 'FontWeight', 'bold');
    
    % Save
    print('Fig3_CDF_Analysis.png', '-dpng', '-r300');
    print('Fig3_CDF_Analysis.pdf', '-dpdf');
end
