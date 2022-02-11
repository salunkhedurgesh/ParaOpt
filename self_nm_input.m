% function name: self_nm_input
% Description: The information required for the definition of the optimisation
% Inputs: None
% Outpus:
% 1. Dimension of the points in optimisation
% 2. The matrix related to the ranges of the parameters
% 3. The number of starts for multi-starting the Nelder Mead process
% 4. Number of iterations to be continued in case of encountering the same solution
% 5. The vector for passive limits of U-joint, S-joint and the ratio for
% the actuator stroke.
% 6. The choice of objective function
% 7. Availability of the sobolset function (to generate low discrepancy points)
% 8. filenames where the data is stored for the optimisation process

function [] = self_nm_input()

my_input();

global mech_name n ranges starts iterations limits objective_choice sobol_var reward opspace coarse_steps prismatic
global save_files num_prismatic order_prismatic stroke VelocityAmplification_range
mech_name = check_inputs(mech_name,"mech_name", "string", 1);
n = check_inputs(n, "n", "posinteger", 1);
coarse_steps = check_inputs(coarse_steps, "coarse_steps", "posinteger", 1);
prismatic = check_inputs(prismatic, "prismatic", "numbool", 1);
if prismatic == 1 && ~isa(stroke, 'double')
    error('Wrong input for the stroke of the prismatic joint, check ''my_input.m''');
elseif prismatic == 0
    stroke = 0;
end

if num_prismatic ~=0
    num_prismatic = check_inputs(num_prismatic, "num_prismatic", "posinteger", 1);
end
order_prismatic = check_inputs(order_prismatic, "order_prismatic", "vector", 1);

if n == 1
    ranges = check_inputs(ranges, "ranges", "vector", 1);
else
    ranges = check_inputs(ranges, "ranges", "matrix", 1);
end

if size(ranges, 1) ~= n 
    if size(ranges, 2) ~=2
        error('the range vector should be a row vector, check ''my_input.m''');
    end
    error('number of parameter ranges are not equal to the optimisation dimension, check ''my_input.m''');
elseif size(ranges, 1) ~= 1 && size(ranges, 2) ~=2
    error('the range matrix should have 2 columns, check ''my_input.m''');
end
for fun_seliter2 = 1: n
if ranges(fun_seliter2, 1) >= ranges(fun_seliter2, 2)
    cprintf('*blue', 'Wrong order of bounds in ranges (lower >= upper), check row number %d in my_input.m\n ', fun_seliter2);
    error('atleast one value of ranges is wrong as lower bound >= upper bound');
end
end

starts = check_inputs(starts, "starts", "posinteger", 1);
iterations = check_inputs(iterations, "iterations", "posinteger", 1);
if ~isa(limits, 'numeric')
    error('limits vector is incorrect, ''check my_input.m''')
end
objective_choice = check_inputs(objective_choice, "objective choice", "posinteger", 1);
if objective_choice ~= 1 && objective_choice ~= 2 && objective_choice ~= 3 && objective_choice ~= 9
    fprintf('[\bwrong objective choice, treating it as workspace ]\b\n');
    objective_choice = 1;
end
if objective_choice == 3
    VelocityAmplification_range = check_inputs(VelocityAmplification_range, "Velocity Amplification Range", "vector", 1);
end

if sobol_var ~= 0 && sobol_var ~= 1
        if exist('initial_sobolset.m', 'file')
            fprintf('[\bUsing the initial simplex set defined in <strong>initial_simplexset.m</strong> ]\b \n');
            sobol_var = 2;
        else
        fprintf('[\bWARNING: Invalid input, treating as 0 ]\b\n');
        sobol_var = 0;
        end
end
if reward ~= "binary" && reward ~= "biased" && reward ~= "min_quality" && reward ~= "plain"
    fprintf('[\bwrong reward chosen, changing it to plain ]\b');
    reward = "plain";
end

if objective_choice == 1 && reward ~= "plain"
    cprintf('*blue', 'boolean expected, 0 -> to stop and change parameters\n\t\t\t\t  1 -> to continue with reward = "plain"\n');
    fprintf(2, "The objective choice is 1 but the reward is not ""plain"", Do you want to continue?")
    prompt_inerror = '\n';
    usr_continue = input(prompt_inerror);
    if usr_continue == 1
        reward = "plain";
    else
        error('Input error');
    end
end

    
save_files = record_file();

fprintf('The mechanism name is %s with dimension %d\nThe number of starts are %d\n', mech_name, n, starts);
fprintf('The number of iterations to continue for same solution are %d \n', iterations);
fprintf('The limits vector is ');
for fun_seliter = 1:length(limits)
    if fun_seliter == 1
        fprintf('[');
        fprintf('%d, ', limits(fun_seliter));
    elseif fun_seliter == length(limits)
        fprintf('%d]\n', limits(fun_seliter));
    else
        fprintf('%d, ', limits(fun_seliter));
    end
end
obj = ["workspace", "Global conditioning number", "Velocity amplification factor", "User defined objective"];
obj_string = obj(objective_choice);
fprintf('The mechanism is being optimised for %s with %s rewarding function\n', obj_string, reward);

if sobol_var == 0
    fprintf('Sobolset functionality is not used \n');
else
    fprintf('Sobolset functionality is used to generate low discrepancy points for multi start \n');
end

if size(opspace, 2) ~=3
        fprintf('[\bWarning: opspace is badly defined, it should be a m x 3 matrix, where m is the output space\n \t\teach row should be in the form of [lower_bound, upper_bound, resolution]]\b \n');
        for fun_nmiiter1 = 1:size(opspace,1)
            opspace(fun_nmiiter1, 3) = (opspace(fun_nmiiter1,2) - opspace(fun_nmiiter1,1))/100;
        end
        fprintf(2, 'Change: resolution for search space is calculated by program as 100 divisions in lower and upper bound \n');
end

format shortg
c = clock;
foldername = num2str(c(3)) + "_" + num2str(c(2));
fprintf('The file names are %s and %s saved in %s folder. Both are opened in write mode \n', save_files(1), save_files(2), foldername);
end