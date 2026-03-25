

%% ========================================================================
%  Figure 6: Convergence Analysis
%  ========================================================================

function plot_fig6_convergence(conv_history, Mu_Values, Active_Links, Sum_Rate)
% PLOT_FIG6_CONVERGENCE  Figure 6: Convergence and Sparsity Trade-off

    figure('Name', 'Fig6_Convergence_Analysis', 'Color', 'w', ...
        'Position', [100, 100, 750, 450], 'Renderer', 'painters');
    
    % Subplot (a): Convergence
    subplot(1, 2, 1);
    iterations = 1:length(conv_history.Obj_Value);
    
    plot(iterations, conv_history.Obj_Value, '-b', 'LineWidth', 2); hold on;
    
    % Mark phase transition
    xline(conv_history.Iterations - 50, '--k', 'Precoding Phase', 'LineWidth', 1.5);
    
    xlabel('Iteration', 'FontSize', 13, 'FontWeight', 'bold');
    ylabel('Objective Value', 'FontSize', 13, 'FontWeight', 'bold');
    grid on;
    set(gca, 'FontSize', 11, 'LineWidth', 1.5);
    title('(a) Convergence Curve', 'FontSize', 12, 'FontWeight', 'bold');
    
    % Subplot (b): Sparsity Trade-off
    subplot(1, 2, 2);
    [ax, h1, h2] = plotyy(Mu_Values, Active_Links, Mu_Values, Sum_Rate);
    
    set(h1, 'LineStyle', '-', 'Color', 'r', 'LineWidth', 2.5, 'Marker', 'o', 'MarkerSize', 8);
    set(h2, 'LineStyle', '--', 'Color', 'b', 'LineWidth', 2.5, 'Marker', 's', 'MarkerSize', 8);
    
    xlabel('\mu (Sparsity Penalty)', 'FontSize', 13, 'FontWeight', 'bold');
    ylabel(ax(1), 'Active Links', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'r');
    ylabel(ax(2), 'Sum Rate (Mbps)', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'b');
    
    set(ax(1), 'FontSize', 11, 'LineWidth', 1.5, 'YColor', 'r');
    set(ax(2), 'FontSize', 11, 'LineWidth', 1.5, 'YColor', 'b');
    grid on;
    title('(b) Sparsity-Rate Trade-off', 'FontSize', 12, 'FontWeight', 'bold');
    
    % Save
    print('Fig6_Convergence_Analysis.png', '-dpng', '-r300');
    print('Fig6_Convergence_Analysis.pdf', '-dpdf');
end
