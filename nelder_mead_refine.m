% function name: nelder_mead()
% Description: Implementation of single start Nelder Mead
% Inputs:
% 1. type of the mechanism
% 2. initial simplex
% 3. objective_choice
% 4. ranges of the parameters
% 5. limit for the joints
% Outpus:
% 1. optimised set of parameter (highly possible: local minima)
% 2. optimised actuator range

% type = "2UPS";limits = [45, 45, 1.5]; iterations = 50; objective_choice = "no_compact"; co_eff_mat = [1, 2, 0.5, 0.5];reward = "linear"; maximize = "inner_conditioning"; refine_fileID = 'refined_haha.txt';
function [refine_best_point, refine_best_rho, single_eval] = nelder_mead_refine(S_raw, refine_file, max_evaluation_refine)

global  iterations ranges co_eff_mat 
global mech_name n starts limits objective_choice opspace save_files git_mood

if objective_choice == 1
    objective_choice_string = "Workspace";
elseif objective_choice == 2
    objective_choice_string = "Global Conditioning Index";
elseif objective_choice == 3
    objective_choice_string = "Velocity Amplification Factor";
end

refine_fileID = fopen(refine_file,'a');
fprintf(refine_fileID, "Started the refining process\n \n");
fprintf('Opening file named %s for storing the deep analysis of the multi-start optimisation \n', save_files(3));

fprintf(refine_fileID, '########## GIT UPDATE ##########\n');
fprintf(refine_fileID, '%s \n\n', git_mood);
fprintf(refine_fileID, '########## INFORMATION ABOUT THE MECHANISM AND ITS OPTIMIZING ELEMENTS ##########\n');
fprintf(refine_fileID, 'The type of mechanism optimised is %s\n', mech_name);
fprintf(refine_fileID, 'The dimension of the optimisation is %d, the number of starts are %d\n', n, starts);
fprintf(refine_fileID, 'The number of iterations if same solution is encountered is %d \n', 2*iterations);
fprintf(refine_fileID, 'The limits are:\n');
for lim_iter2 = 1:size(limits, 1)
    fprintf(refine_fileID, 'Limit %i : [%d, %d]\n', lim_iter2, limits(lim_iter2, 1), limits(lim_iter2, 2));
end
fprintf(refine_fileID, 'The objective function aims to calculate design for the best %s \n', objective_choice_string);
fprintf(refine_fileID, 'The ranges for the parameters are: \n\n');
for i = 1:n
    fprintf(refine_fileID, 'Parameter %d range: [%0.2f to %0.2f] \n', i, ranges(i,1), ranges(i,2));
end
fprintf(refine_fileID, 'The dimension of the output space is %d \n', size(opspace, 1));
fprintf(refine_fileID, 'The resolution for fine search space is: [');
for fun_nmmsiter1 = 1:size(opspace, 1)
    fprintf(refine_fileID, '%d, ', opspace(fun_nmmsiter1, 3));
end
fprintf(refine_fileID, '] \n');

S = zeros(length(S_raw)+1, length(S_raw));
k = randi([-10, 10], length(S_raw), length(S_raw));
S(1,:) = S_raw;
for row = 2:length(S_raw)+1
    for col = 1:length(S_raw)
        S(row, col) = S_raw(col) + k(row-1, col)*0.01*(ranges(col,2)-ranges(col,1));
    end
end
iteration = 1;
prev_min_eval = 0;
n = length(S(1,:));
optimum = 0;
cont_iter = 1;
cumu_time = 0;
improvement = 1; % Atleast this much percentage of increase should happen to consider that we have a better point

while(iteration <= 2*iterations) % stops if the solution has not changed for specified iterations
    tic
    evaluations = zeros(n+1,1);
    for i = 1:n+1
        [evaluations(i), ~] = evalrefine_fun(S(i,:));
    end
    
    [max_eval,max_index] = max(evaluations); %To calculate the point correspoding to the worst evaluation
    [min_eval,min_index] = min(evaluations); %To calculate the point correspoding to the worst evaluation
    
    %We also need to save the second max value
    evaluations_backup = evaluations;
    evaluations_backup(max_index) = -inf;
    [second_max_eval, ~] = max(evaluations_backup);
    %% Sortation 
    %Sorting is done for ease of understanding and operation
    
    Sort_S = zeros(n+1,n);
    j = 2;
    for i = 1:n+1
        if i == max_index
            continue;
        elseif i == min_index
            continue;
        else
            Sort_S(j,:) = S(i,:);
            j = j+1;
        end
    end
    
    Sort_S(1,:) = S(min_index,:); %So the Simplex is sorted such that the first element is min eval
    Sort_S(j,:) = S(max_index,:); %So the Simplex is sorted such that the last element is max eval
    S_min = Sort_S(1,:);
    %% Stopping conditions
    % If the optimised value has been reached
    %i.e The simplex has shrinked below an acceptable epsilon1 value and the
    %function evaluation of all the points of simplex are identical with a
    %tolerance of epsilon2 then it is good time to stop
    epsilon1_vec = zeros(n, 1);
    %         epsilon2 = epsilon1; %It is purposefully kept higher as we have evaluations in the terms of thousand
    for range_iter = 1:n
        epsilon1_vec(range_iter) = abs((ranges(range_iter, 2) - ranges(range_iter, 1))/100);
    end
    epsilon2 = abs(min(evaluations)*0.01);
    stop_j = 2;
    stop_k =1;
    simplex_length = zeros(0.5*(n^2 +n), n);%0.5*(n^2 +n) -> (n+1)^C_2
    eval_length = zeros(1,0.5*(n^2 +n));
    while stop_j<n+2
        for i = stop_j:n+1
            simplex_length(stop_k, 1:n) = abs((S(stop_j-1,:) - S(i,:)));
            eval_length(stop_k) = abs(evaluations(stop_j-1) - evaluations(i));
            stop_k = stop_k+1;
        end
        stop_j = stop_j + 1;
    end
    simplex_size = zeros(n, 1);
    for range_iter2 = 1:n
        simplex_size(range_iter2) = max(simplex_length(:, range_iter2));
    end
    eval_size = max(eval_length);
    
    if simplex_size < epsilon1_vec
        if eval_size < epsilon2
            optimum = 1;
            break;
        end
    end
    %% Calculating the new point (average of the first n sorted-points)
    mean_point = zeros(1,n);
    for i = 1:n
        mean_point(i) = sum(Sort_S(1:n,i))/n;
    end
    
    %% Stage 3: Successive reflection, Expansion, acontraction and Shrinkage
    %Setting co-efficients for the simplex
    r_coeff = co_eff_mat(1); %Reflection co-efficient
    e_coeff = co_eff_mat(2); %Expansion co-efficient
    k_coeff = co_eff_mat(3); %Contraction co-efficient
    s_coeff = co_eff_mat(4); %Shrinkage co-efficient
    
    %Reflection : reflect_point = mean_point + reflect_coeff*(mean_point - S(n+1,:))
    reflect_point = mean_point + r_coeff*(mean_point - Sort_S(n+1,:));
    reflect_point = range_respect(reflect_point,ranges);
    [reflect_evaluation,~] = evalrefine_fun(reflect_point);
    
    if min_eval < reflect_evaluation && reflect_evaluation < max_eval
        Sort_S(n+1,:) = reflect_point;
        fprintf('Reflection in process \n');
        
    elseif reflect_evaluation < min_eval
        min_eval = reflect_evaluation;
        S_min = reflect_point;
        expand_point = mean_point + e_coeff*(reflect_point-mean_point);
        % In other words:
        % expand_point = mean_point + e_coeff*r_coeff(mean_point - Sort_S(n+1,:));
        % It is necessary that e_coeff > 1 so that
        % e_coeff*r_coeff > r_coeff
        
        expand_point = range_respect(expand_point,ranges);
        [expand_evaluation, ~] = evalrefine_fun(expand_point);
        
        if expand_evaluation < reflect_evaluation
            min_eval = expand_evaluation;
            S_min = expand_point;
            Sort_S(n+1,:) = expand_point;
            fprintf('Expansion in process \n');
        else
            Sort_S(n+1,:) = reflect_point;
            fprintf('Checked expansion but reflection in process \n');
        end
        
    elseif reflect_evaluation > second_max_eval
        
        if second_max_eval < reflect_evaluation && reflect_evaluation < max_eval
            outside_contract_point = mean_point + k_coeff*(reflect_point-mean_point);
            outside_contract_point = range_respect(outside_contract_point, ranges);
            [outside_contract_evaluation,~] = evalrefine_fun(outside_contract_point);
            
            if outside_contract_evaluation < reflect_evaluation
                Sort_S(n+1,:) = outside_contract_point;
                fprintf('Outside contraction in process \n');
            else %Perform Shrinkage
                fprintf('Outside contraction of no use: Shrinkage in process \n');
                for i = 2:n+1
                    Sort_S(i,:) = Sort_S(i,:) - s_coeff*(Sort_S(i,:) - Sort_S(1,:));
                    Sort_S(i,:) = range_respect(Sort_S(i,:),ranges);
                end
            end
            
        elseif reflect_evaluation > max_eval
            inside_contract_point = mean_point - k_coeff*(mean_point-Sort_S(n+1,:));
            inside_contract_point = range_respect(inside_contract_point, ranges);
            [inside_contract_evaluation, ~] = evalrefine_fun(inside_contract_point);
            
            if inside_contract_evaluation < max_eval
                Sort_S(n+1,:) = inside_contract_point;
                fprintf('Inside contraction in process \n');
            else %Perform Shrinkage
                fprintf('Inside contraction of no use: Shrinkage in process \n');
                for i = 2:n+1
                    Sort_S(i,:) = Sort_S(i,:) - s_coeff*(Sort_S(i,:) - Sort_S(1,:));
                    Sort_S(i,:) = range_respect(Sort_S(i,:),ranges);
                end
            end
        end
        
    end
    
    S = Sort_S; % In order to be able to run in loop
    end_time = toc;
    cumu_time = cumu_time + end_time;
    mean_iter_time = cumu_time/cont_iter;
    
    cont_iter = cont_iter + 1;
    
    if min_eval < (1+(improvement/100))*prev_min_eval %atleast 5 percent improvement, this is necessary to stop the algorithm early
        iteration = 1;
        fprintf("Better point found.. continuing\n");
        fprintf("New evaluation is %d \n", min_eval);
        fprintf("time required for this iteration is %f seconds \n", end_time);
        fprintf("The parameters are \n");
        fprintf("[");
        for para_iter = 1:n-1
            fprintf("%f, ", Sort_S(1,para_iter));
        end
        fprintf("%f] \n\n", Sort_S(1,n));
        fprintf(refine_fileID, "The parameter explored is \n");
        fprintf(refine_fileID, "[");
        for para_iter = 1:n-1
            fprintf(refine_fileID, "%f, ", Sort_S(1,para_iter));
        end
        fprintf(refine_fileID, "%f] \n\n", Sort_S(1,n));
        prev_min_eval = min_eval;
    else
        iteration = iteration+1;
        fprintf("Same solution encountered or less than %d %% improvement\n", improvement);
        fprintf("The evaluation is %d \n", min_eval);
        fprintf("time required for this iteration is %f seconds \n\n", end_time);
        fprintf("The parameters are \n");
        fprintf("[");
        for para_iter = 1:n-1
            fprintf("%f, ", Sort_S(1,para_iter));
        end
        fprintf("%f] \n\n", Sort_S(1,n));
    end
    
    if abs(min_eval) > 0.953*abs(max_evaluation_refine)
        optimum = 1;
        break
    end
end

[single_eval, refine_best_rho] = evalrefine_fun(S_min);
refine_best_point = S_min;
print_single_nm(refine_fileID, refine_best_point, refine_best_rho, single_eval, optimum, mean_iter_time, cont_iter);


end