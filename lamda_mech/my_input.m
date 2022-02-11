function [] = my_input()

global mech_name n ranges starts iterations limits objective_choice sobol_var reward opspace 
global prismatic stroke coarse_steps num_prismatic order_prismatic
global VelocityAmplification_range search_option force_valid
%Complete each variable accordingly
search_option = "non_tweak";
%The "tweak" option is introduced to have the search space in circular shape for 2 dof

force_valid = 0; %This option used only for 3-RPR mechanism where an optimised paarmeter is
                %suggested even after having invalid points in the desired
                %workspace
mech_name = "1 dof lambda mechanism";%string expected ("my_mechanism")
n = 1; %%positive integer
ranges = [1, 4]; %This is the range of l1 with respect to l2
%%matrix of nx2 dimension first column is of lower bounds and second column for higher bounds

starts = 100; %%positive integer expected
iterations = 10; %%positive integer expected
limits = zeros(1, 2);
%%a matrix k x 2 expected, where k are the entities in output of configuration space
                      % the row of the matrix should be in the form [lower_limit, upper_limit] 
                      % In case of prismatic joint, if you don't have a
                      % limit, type [0, 0];
objective_choice = 3; %% integer expected : 1(workspace), 2(GCI), 3(VAF), 9(self-designed objective function) 
VelocityAmplification_range = [0.3, 3]; %%Vector [1 x 2] expected with form [lpwer_amplification, higher_amplification]
sobol_var = 1;%%0, 1, 2 expected %if 2, then make sure that the initial_simplexset is correct
reward = "plain";%%string expected: Type of reward function("binary", "biased", "min_quality")
opspace = [deg2rad(45),deg2rad(135), 0.01]; %%matrix of m x 3 expected where m is the number of output co-ordinates and 
                         %%each row is in the format [lower_bound, upper_bound, resolution]
prismatic = 1; %%boolean expected, 0 -> If the mechanism does not have a prismatic joint as an actuator
                                 % 1 -> If the mechanism does have a prismatic joint as an actuator 
coarse_steps = 50; %%Positive integer expected, It decides the number of division of the search space while performing
                   % a coarse search
num_prismatic = 1; %%Integer (including 0) expected, the variable to store the number of prismatic joints
                   % in your mechanism, this is used to implement a better
                   % prismatic constraint
stroke = 1.5; %%Positive number expected if num_prismatic joint is not equal to zero
              % Enter zero otherwise
order_prismatic = 1; %% If no prismatic joint exists in your mechanism
                          %  then input 0 or else input the vector
                          %  having numbers that are index relating to
                          %  prismatic "active" joints in your output of
                          %  configuration file
                          
                          %for example if you are calculating the RRPR
                          %mechanism, and let's say you have a limit on one
                          %revolute joint and your output of
                          %configuration_space file is 
                          %[passive_limit, actuator_value], then the 
                          %order_prismatic = 2 for you as you are mentioning
                          %the active joint in 2nd place in the
                          %output of your configuration_space file joint
                           
end