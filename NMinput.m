% function name: NMinput
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

function [] = NMinput()
global mech_name n ranges starts iterations limits objective_choice
global sobol_var reward opspace prismatic coarse_steps save_files
global num_prismatic order_prismatic VelocityAmplification_range
global search_option %A tweak to search the circular workspace
global force_valid

search_option = "non_tweak"; %Because I don't want the users to use this functionality
%The "tweak" option is introduced to have the search space in circular shape for 2 dof
force_valid = 0;
num_prismatic = 0;
order_prismatic = 0;
prismatic = 0;
% Defining the configuration of the mechanism
cprintf('*blue', 'string ');
prompt_type = '\nInput the type of mechanism you want to optimise\nInput a string, eg: "2UPS-1U", "my_mechanism" \n';
mech_name = input(prompt_type);


% Defining the dimension of the problem. It means the number of
% parameters that are to be optimised, eg:[a, a_prime, h, t] suggests
% that n = 4 in 2UPS+1U and in 2PUS+1U we have n = 5; [a, a_prime, h, t, offset]
cprintf('*blue', 'positive integer ');
prompt_dimension = '\nDimension of the optimisation problem (n)\n';
n = input(prompt_dimension);
if ~isa(n, 'numeric') || n < 1
    error('Optimisation dimension should be a positive integer');
elseif mod(n, 1) ~= 0
    n = floor(n);
    cprintf('red', '!! decimal entered when integer expected, n = %d \n', n);
end

% Defining the ranges of the parameters to search points in the
% optimisation model. The dimension should be n x 2. It contains the
% lower bound and upper bound of each parameter
if n == 1
    cprintf('*blue', '[1 x 2] vector \n');
else
    cprintf('*blue', '[%d x 2] matrix \n', n);
end
fprintf('Input the range of %d parameters in a %d x 2 matrix', n, n);
prompt_ranges = '\n';
ranges = input(prompt_ranges);
if size(ranges(1,:)) ~= 2
    error('Wrong dimension of ranges matrix, the number of columns should be 2');
elseif size(ranges(:,1)) ~= n
    error('Wrong dimension of ranges matrix, the number of rows should be equal to the dimension of the optimisation (n)');
end
for i = 1:n
    if ranges(i,1) >= ranges(i,2)
        cprintf('red', 'Error in defining range for parameter %d\n', i);
        cprintf('red', 'lower bound = %f and upper bound = %f\n', ranges(i,1), ranges(i,2));
        error('Error in defining ranges: the lower bound of atleast one of the parameters is either equal to or greater than upper bound');
    end
end

% Defining the number of starts for the Nelder Mead optimisation. The
% multi-start is necessary as te Nelder Mead often returns a local
% minima. In order to achieve global minima, we have to start the
% Simplex process with several different initial points.
cprintf('*blue', 'positive integer \n');
prompt_start = 'Number of multi-starts for the optimisation problem\n';
starts = input(prompt_start);
if mod(starts, 1) ~= 0
    fprintf('[\bWARNING: The input for starts is %d, it will be changed to %d ]\b\n', starts, floor(starts));
    starts = floor(starts);
elseif starts < 1
    error('Incorrect number of starts. The input should be a positive integer\n');
end

% Defining the number of iterations to be continued in case of
% encountering the same solution. This is used to save time. Ideally
% the Simplex should converge so small that distance between any two
% parameters of the Simplex point is less than a small epsilon value.
cprintf('*blue', 'positive integer \n');
prompt_iterations = 'Number of iterations in case of non-changing solution point (Recommended value: 10)\n';
iterations = input(prompt_iterations);

% Defining the limits:
% 1. Passive joint limit for Universal joint
% 2. Passive joint limit for Spherical joint
% Ratio for the stroke length and size of the actuator.
% The stroke (rho1 and rho2) varies from a minimum length to
% ratio*minimum length. This helps us optimizing the mechanism with
% feasible actuator ranges
cprintf('*blue', 'a matrix k x 2, where k are the entities in output of configuration space\n');
cprintf('*blue', 'the row of the matrix should be in the form [lower_limit, upper_limit]\n');
prompt_limits = 'The vector for limits to be implemented: the "vector" should be in same order that of the output of constraints.m \nexample:[limit1, limit2, limit3] \n';
limits = input(prompt_limits);

% Defining the type of objective function we want
% The options are:
% 1. workspace: Searches for a design that provides the maximum
% workspace
% 2. compact: Searches for a design with highest workspace:size ratio
cprintf('*blue', 'Choose: 1, 2, 3 or 9 \n');
prompt_objective_choice = 'What type of objective function are you looking for \n';
fprintf('The options being:\n');
cprintf('*blue','1');
fprintf('-> ''workspace'' : Searches for a design that provides the maximum feasible workspace\n');
cprintf('*blue','2');
fprintf(' -> ''GCI'' : Searches for a design with highest Global conditioning number \n');
cprintf('*blue','3');
fprintf(' ->''VAF'' : Searches for a design with highest velocity amplification factor \n');
cprintf('*blue','9');
fprintf(' -> If you have designed your own objective function and want to provide the evaluation directly \n');

objective_choice = input(prompt_objective_choice);
if objective_choice == 3
    cprintf('*blue', 'vector [2 x 1] in the form of [lower_amplification, higher_amplification] \n');
    prompt_vafrange = 'Acceptable range of velocity amplification\n';
    VelocityAmplification_range = input(prompt_vafrange);
end

% Taking input for the sobolset functionality
cprintf('*blue', 'boolean(0 or 1) \n');
prompt_sobol = 'Do you have sobolset functionality (1 for yes, 0 for no)\nTo check the same try executing this command : "p = sobolset(4)"\n';
sobol_var = input(prompt_sobol);
if sobol_var ~= 0 && sobol_var ~= 1
    if exist('initial_sobolset.m', 'file')
        fprintf('[\bUsing the initial simplex set defined in <strong>initial_simplexset.m</strong> ]\b \n');
        sobol_var = 2;
    else
        fprintf('[\bWARNING: Invalid input, treating as 0 ]\b\n');
        sobol_var = 0;
    end
end

% Taking input for the reward type
if objective_choice ~= 1
    cprintf('*blue', 'options: "binary", "biased", "min_quality", "default"\n');
    prompt_reward = 'Type of reward function("binary", "biased", "min_quality")\nType "default" if unsure\n';
    reward = input(prompt_reward);
    if reward ~= "binary" && reward ~= "linear" && reward ~= "min_quality"
        cprintf('*blue', 'Note: default reward strategy : binary reward\n');
        reward = "binary";
    end
else
    reward = "plain";
end

% Taking input for the output search space
cprintf('*blue', 'm x 3 matrix, where m -> number of outputs"\n');
prompt_opspace = 'm x 3 matrix with row for a single search space as\n[lower_bound, upper_bound, resolution]\n';
opspace = input(prompt_opspace);
opspace = check_inputs(opspace, "opspace", "matrix");
if size(opspace, 2) ~=3
    fprintf('[\bWarning: opspace is badly defined, it should be a m x 3 matrix, where m is the output space\n \t\teach row should be in the form of [lower_bound, upper_bound, resolution]]\b \n');
    for fun_nmiiter1 = 1:size(opspace,1)
        opspace(fun_nmiiter1, 3) = (opspace(fun_nmiiter1,2) - opspace(fun_nmiiter1,1))/100;
    end
    fprintf(2, 'Change: resolution for search space is calculated by program as 100 divisions in lower and upper bound \n');
end

% Taking input for the coarse steps
cprintf('*blue', 'Positive integer \n');
prompt_coarse = 'In how many steps do you want to divide the search space for coarse travel? (Recommended: 20)\n';
coarse_steps = input(prompt_coarse);

% Taking input for the prismatic joint
cprintf('*blue', 'boolean\n');
prompt_prismatic = 'Does your mechanism have prismatic actuators? (0 -> NO, 1 -> YES)\n';
prismatic = input(prompt_prismatic);
prismatic = check_inputs(prismatic, "prismatic", "numbool", 1);

if prismatic == 1
    % Taking input for the number of the prismatic joints
    cprintf('*blue', 'Positive number (example: 1.5) \n');
    prompt_stroke = 'How many prismatic joints are there in your mechanism?\n';
    stroke  = input(prompt_stroke);
    if ~isa(stroke, 'double')
        error('Wrong input for stroke, positive number expected!')
    end
end

if prismatic == 1
    % Taking input for the number of the prismatic joints
    cprintf('*blue', 'Positive integer \n');
    prompt_numpri = 'How many prismatic joints are there in your mechanism?\n';
    num_prismatic  = input(prompt_numpri);
    num_prismatic = check_inputs(num_prismatic, "num_prismatic", "posinteger", 1);
    
    % Taking input for the order of the prismatic joints
    if num_prismatic == 1
        cprintf('*blue', 'Positive integer \n');
    else
        cprintf('*blue', 'Vector \n');
    end
    prompt_ordpri = 'What is the index of the prismatic joints in the output of your configuration_space file?\n';
    order_prismatic  = input(prompt_ordpri);
    order_prismatic = check_inputs(order_prismatic, "order_prismatic", "vector", 1);
end
cprintf('*blue', 'Choose: 0 or 1 \n');
prompt_force_valid = 'Do you want to find optimised results even if invalid points exist in the desired workspace? \n';
force_valid = input(prompt_force_valid);
save_files = record_file();
end