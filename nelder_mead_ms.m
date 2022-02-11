% function name: nelder_mead_ms()
% Description: Implementation of single start Nelder Mead
% Inputs: None
% Outpus:
% 1. type of the mechanism
% 2. initial simplex
% 3. objective_choice
% 4. ranges of the parameters
% 5. limit for the joints
% 6. sobolset functionality

function [best_point, best_rho, saved_S_eval] = nelder_mead_ms(git_mood)

global mech_name n ranges starts iterations limits objective_choice sobol_var  opspace save_files
global co_eff_mat max_evaluation

if objective_choice == 1
    objective_choice_string = "Workspace";
elseif objective_choice == 2
    objective_choice_string = "Global_Conditioning_Index";
elseif objective_choice == 3
    objective_choice_string = "Velocity_Amplification_Factor";
end

fprintf('Opening file named %s for storing the deep analysis of the multi-start optimisation \n', save_files(1));
deep_fileID = fopen(save_files(1),'w');
fprintf(deep_fileID, '########## GIT UPDATE ##########\n');
fprintf(deep_fileID, '%s\n\n', git_mood);
fprintf(deep_fileID, '########## INFORMATION ABOUT THE MECHANISM AND ITS OPTIMIZING ELEMENTS ##########\n');
fprintf(deep_fileID, 'The type of mechanism optimised is %s\n', mech_name);
fprintf(deep_fileID, 'The dimension of the optimisation is %d, the number of starts are %d\n', n, starts);
fprintf(deep_fileID, 'The number of iterations if same solution is encountered is %d \n', iterations);
fprintf(deep_fileID, 'The limits are:\n');
for lim_iter2 = 1:size(limits, 1)
    fprintf(deep_fileID, 'Limit %i : [%d, %d]\n', lim_iter2, limits(lim_iter2, 1), limits(lim_iter2, 2));
end
fprintf(deep_fileID, 'The objective function aims to calculate design for the best %s \n', objective_choice_string);
fprintf(deep_fileID, 'The ranges for the parameters are: \n\n');
for i = 1:n
    fprintf(deep_fileID, 'Parameter %d range: [%0.2f to %0.2f] \n', i, ranges(i,1), ranges(i,2));
end
fprintf(deep_fileID, 'The dimension of the output space is %d \n', size(opspace, 1));
fprintf(deep_fileID, 'The resolution for fine search space is: [');
for fun_nmmsiter1 = 1:size(opspace, 1)
    fprintf(deep_fileID, '%d, ', opspace(fun_nmmsiter1, 3));
end
fprintf(deep_fileID, '] \n');

cprintf('blue', 'Please wait: Calculating the set of valid points for a initial simplex point that is non-singular in the desired RDW \n')

if sobol_var == 0
    simplex_set = rand_tuning();
elseif sobol_var == 1
    simplex_set = sobol_tuning();
elseif sobol_var == 2
    simplex_set = initial_simplexset();
    if size(simplex_set, 1) < (n+1)*starts || size(simplex_set, 2) ~= n
        fprintf(2, 'The self defined initial simplex set should have <strong>atleast</strong> %d points of <strong>exactly</strong> %d dimension\n', n+1, n);
        fprintf(2, 'i.e, the output of file initial_simplexset.m should be a matrix of (r, %d), where, r >= %d, n: dimension of optimisation\n', n, n+1);
        error('Input error')
    end
else
    error('Error in sobol_var, the sobol_var should be either 0, 1 or 2');
end

for i = 1:(n+1)*starts
    for j = 1:n
        fprintf(deep_fileID, '%f \t', simplex_set(i, j));
    end
    fprintf(deep_fileID, '\n');
    if mod(i, n+1) == 0
        fprintf(deep_fileID, '\n NEW SIMPLEX \n');
    end
end

fprintf('<strong>Done: Calculated initial simplexes for %d starts</strong> \n\n', starts);
multi_eval = 1; %to avoid cases in which the evaluation stays at zero
no_valid_pt = 0;

for multi_start = 1:starts
    fprintf(deep_fileID, '########## START NUMBER: %d ##########\n', multi_start);
    fprintf('########## <strong>START NUMBER: %d of %d </strong>##########\n', multi_start, starts);
    co_eff_mat = [1, 2, 0.5, 0.5]; %[reflection, expansion, contraction, shrinkgae]
    fprintf("The reflection, expansion, contraction and shrinkage co-efficients used are:  <strong>[%d, %d, %0.2f, %0.2f] </strong>\n", co_eff_mat(1), co_eff_mat(2), co_eff_mat(3), co_eff_mat(4));
    fprintf("In case you want to change them, the assignment is done in [\b<strong>nelder_mead_ms.m</strong>]\b\n")
    S = simplex_set(((n+1)*(multi_start-1) +1):(n+1)*multi_start,:);
    
    write_evaluation();
    write_maxeval();
    max_evaluation = maxeval_fun();
    write_rhorange();
    
    [single_best_point, single_best_rho, single_eval, optimum, mean_iter_time, cont_iter] = nelder_mead(S,deep_fileID);
    print_single_nm(deep_fileID, single_best_point, single_best_rho, single_eval,optimum, mean_iter_time, cont_iter);
    
    % Post single start
    saved_S_eval(multi_start,:) = [single_best_point, single_eval];
    if single_eval > 0
        no_valid_pt = 1;
    end
    if single_eval < multi_eval
        best_point = single_best_point;
        best_rho = single_best_rho;
        multi_eval = single_eval;
    elseif single_eval > 0
        warning('Could not find a single point that has no invalid points')
        best_point = single_best_point;
        best_rho = single_best_rho;
        multi_eval = single_eval;
    end
    
    if no_valid_pt ~= 1
        fprintf("Best point yet is: ");
        fprintf("%f \t", best_point);
        fprintf("\nThe actuator range is: ");
        fprintf("%f \t", best_rho);
        fprintf("\n");
        fprintf(deep_fileID, "Best point yet is: ");
        fprintf(deep_fileID, "%f \t", best_point);
        fprintf(deep_fileID, "\nThe actuator range is: ");
        fprintf(deep_fileID, "%f \t", best_rho);
        fprintf(deep_fileID, "\n");
    else
        fprintf(2, "Best point with Invalid points in the workspace yet is: ");
        fprintf(2, "%f \t", best_point);
        fprintf(2, "\nThe actuator range is: ");
        fprintf(2, "%f \t", best_rho);
        fprintf("\n");
        fprintf(deep_fileID, "Best point with Invalid points in the workspace yet is: ");
        fprintf(deep_fileID, "%f \t", best_point);
        fprintf(deep_fileID, "\nThe actuator range with Invalid points in the workspace is: ");
        fprintf(deep_fileID, "%f \t", best_rho);
        fprintf(deep_fileID, "\n");
    end
    
end
fprintf('\nCompleted all starts of Nelder Mead: Closing file %s \n', save_files(1));
fclose(deep_fileID);

% Saving the points file

fprintf('Opening a file named %s to save all the optimised points with different starting simplex \n \n', save_files(2));
points_fileID = fopen(save_files(2),'w');
fprintf(points_fileID, 'The type of mechanism optimised is %s\n', mech_name);
fprintf(points_fileID, 'The dimension of the optimisation is %d, the number of starts are %d\n', n, starts);
fprintf(points_fileID, 'The number of iterations if same solution is encountered is %d \n', iterations);
fprintf(points_fileID, 'The limits are:\n');
for lim_iter2 = 1:size(limits, 1)
    fprintf(deep_fileID, 'Limit %i : [%d, %d]\n', lim_iter2, limits(lim_iter2, 1), limits(lim_iter2, 2));
end
fprintf(points_fileID, 'The objective function aims to calculate %s design \n', objective_choice);
fprintf(points_fileID, 'The ranges for the parameters are: \n\n');
for i = 1:size(saved_S_eval,1)
    fprintf(points_fileID, "\n The parameters for start %d are:\n", i);
    fprintf(points_fileID, "%f \t", saved_S_eval(i,1:n));
    fprintf(points_fileID, "\nThe evaluation for this parameters is: " );
    fprintf(points_fileID, "%f \n", saved_S_eval(i, n+1));
end
fprintf(points_fileID, "\nThe best point before refining is:\n");
fprintf(points_fileID, "%f \t", best_point);
fprintf(points_fileID, "With evaluation %f \n", multi_eval);
fclose(points_fileID);

fileID3 = fopen('temp.txt','w');
for i = 1:size(saved_S_eval,1)
    fprintf(fileID3, "%f \t", saved_S_eval(i,1:n));
end
fclose(fileID3);

end
