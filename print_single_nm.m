% function name: print_single_nm()
% Description: Saving the filenames for further process
% Inputs:
% None
% Outpus:
% 1. Prints the necessary information on screen
% 2. saves the same information on a file for record of deep analysis

function print_single_nm(print_fileID, single_best_point, single_best_rho, single_eval, optimum, mean_iter_time, cont_iter)
global n iterations prismatic coarse
if coarse == 0
    print_iterations = 2*iterations;
else
    print_iterations = iterations;
end

if optimum == 1
    fprintf("\nThe optimised point is found \n");
    for print_iter = 1:n
        fprintf("\nParameter %d = %f, \t", print_iter, single_best_point(print_iter));
    end
    if prismatic == 1
    fprintf("\nThe actuator ranges are: ");
    fprintf("%f \t", single_best_rho);
    end
    fprintf("\nThe evaluation at this point is %d \n", single_eval);
    fprintf("The mean iteration time is %0.2f seconds\n", mean_iter_time);
    fprintf("The total print_iterations performed are %d \n\n", cont_iter);
    fprintf(print_fileID, "\nThe optimised point is found \n");
    for print_iter = 1:n
        fprintf(print_fileID, "\nParameter %d = %f, \t", print_iter, single_best_point(print_iter));
    end
    if prismatic == 1
    fprintf(print_fileID, "\nThe actuator ranges are: ");
    fprintf(print_fileID, "%f \t", single_best_rho);
    end
    fprintf(print_fileID, "\nThe evaluation at this point is %d \n", single_eval);
    fprintf(print_fileID, "The mean iteration time is %0.2f seconds\n", mean_iter_time);
    fprintf(print_fileID, "The total print_iterations performed are %d \n\n", cont_iter);
else
    fprintf("\nThe simplex stopped after %d print_iterations \n", print_iterations);
    for print_iter = 1:n
        fprintf("\nParameter %d = %f, \t", print_iter, single_best_point(print_iter));
    end
    if prismatic == 1
    fprintf("\nThe actuator ranges are: ");
    fprintf("%f \t", single_best_rho);
    end
    fprintf("\nThe evaluation at this point is %d \n", single_eval);
    fprintf("The mean iteration time is %0.2f seconds\n\n", mean_iter_time);
    fprintf("The total print_iterations performed are %d \n\n", cont_iter);
    fprintf(print_fileID, "\nThe simplex stopped after %d print_iterations \n", print_iterations);
    for print_iter = 1:n
        fprintf(print_fileID, "\nParameter %d = %f, \t", print_iter, single_best_point(print_iter));
    end
    if prismatic == 1
    fprintf(print_fileID, "\nThe actuator ranges are: ");
    fprintf(print_fileID, "%f \t", single_best_rho);
    end
    fprintf(print_fileID, "\nThe evaluation at this point is %d \n", single_eval);
    fprintf(print_fileID, "The mean iteration time is %0.2f seconds\n", mean_iter_time);
    fprintf(print_fileID, "The total print_iterations performed are %d \n\n", cont_iter);
end
end