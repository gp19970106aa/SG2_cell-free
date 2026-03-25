
%% ========================================================================
%  Figure 5: Dynamic Priority Response
%  ========================================================================

function plot_fig5_dynamic_priority(Results, Sim5)
% PLOT_FIG5_DYNAMIC_PRIORITY  Figure 5: Time-Series Dynamic Priority Response

    figure('Name', 'Fig5_Dynamic_Priority', 'Color', 'w', ...
        'Position', [100, 100, 800, 500], 'Renderer', 'painters');
    
    t = 1:Sim5.Time_Slots;
    
    % Subplot 1: Target SINR
    subplot(2, 1, 1);
    plot(t, Results.Target_User1, '-k', 'LineWidth', 2); hold on;
    plot(t, Results.SINR_User1, '-ro', 'LineWidth', 2, 'MarkerFaceColor', 'r', 'MarkerSize', 6);
    plot(t, Results.SINR_User2, '-bs', 'LineWidth', 2, 'MarkerFaceColor', 'b', 'MarkerSize', 6);
    
    % Fault period shading
    area([Sim5.Fault_Start, Sim5.Fault_End, Sim5.Fault_End, Sim5.Fault_Start], ...
        [0, 0, 20, 20], 'FaceColor', 'r', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
    
    ylabel('SINR (dB)', 'FontSize', 13, 'FontWeight', 'bold');
    legend({'Target (User 1)', 'Actual (User 1)', 'Actual (User 2)'}, ...
        'Location', 'best', 'FontSize', 10);
    grid on;
    ylim([0, 20]);
    set(gca, 'FontSize', 11, 'LineWidth', 1.5);
    
    % Subplot 2: Lagrange Multipliers
    subplot(2, 1, 2);
    plot(t, Results.Lambda_User1, '-r*', 'LineWidth', 2, 'MarkerSize', 8); hold on;
    plot(t, Results.Lambda_User2, '-b', 'LineWidth', 2);
    
    % Fault period shading
    area([Sim5.Fault_Start, Sim5.Fault_End, Sim5.Fault_End, Sim5.Fault_Start], ...
        [min([Results.Lambda_User1; Results.Lambda_User2]), ...
         min([Results.Lambda_User1; Results.Lambda_User2]), ...
         max([Results.Lambda_User1; Results.Lambda_User2]), ...
         max([Results.Lambda_User1; Results.Lambda_User2])], ...
        'FaceColor', 'r', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
    
    xlabel('Time Slot', 'FontSize', 13, 'FontWeight', 'bold');
    ylabel('\lambda (dB)', 'FontSize', 13, 'FontWeight', 'bold');
    legend({'\lambda_1 (User 1)', '\lambda_2 (User 2)'}, ...
        'Location', 'best', 'FontSize', 10);
    grid on;
    set(gca, 'FontSize', 11, 'LineWidth', 1.5);
    
    % Save
    print('Fig5_Dynamic_Priority.png', '-dpng', '-r300');
    print('Fig5_Dynamic_Priority.pdf', '-dpdf');
end