function [] = plot_mech(parameters)

global opspace

figure()
for theta = opspace(1):0.01:opspace(2)
    theta = [45, 45];
    plot([0, parameters(1)], [0, 0], '-k', 'LineWidth', 2);
    title('Plot for the Lambda mechanism');
    xlabel('circle - Revolute joints, red -> Actuator','FontSize',12);
    axis([-1 4 -0.2 1.2])
    hold on;
    plot([0, cos(theta(1, 1))], [0, sin(theta(1, 1))], '-b', 'LineWidth', 2);
    plot(cos(theta(1, 1)), sin(theta(1, 1)), 'or', 'MarkerSize', 10);
    plot([parameters(1), cos(theta(1, 1))],[0, sin(theta(1, 1))], '-r', 'LineWidth', 2)
    plot(parameters(1), 0, 'or', 'MarkerSize', 10);
    pause(0.01)
    hold off;
end

end
