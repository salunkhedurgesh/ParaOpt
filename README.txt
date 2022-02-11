This folder contains all the files necessary to implement the general optimisation algorithm for Parallel manipulators

How to run it:

There are 2 preloaded examples: 
1. The 1-dof lambda mechanism
2. The 2-dof 2UPS-1U mechanism (Done in master thesis)

In order to run for the "LAMBDA mechanism":

1. Open matlab and go to the directory where the current files are present
2. right click on the 'lambda_mech' folder and select option 'Add to path'
3. Make sure that no other folder is added to the path (for example: UPS_related)
4. run the main.m file
5. When asked 'Do you have pre-written function for inputs? (0 for no and 1 for yes)', PRESS 1
6. Later you wil need to add a string to give a small comment about the purpose of running code
   for e.g: "Running to check the optimisation of lambda mechanism"
VOILA!!

In order to run for the "2UPS-1U mechanism":

1. Open matlab and go to the directory where the current files are present
2. right click on the 'UPS_related' folder and select option 'Add to path'
3. Make sure that no other folder is added to the path (for example: lambda_mech)
4. run the main.m file
5. When asked 'Do you have pre-written function for inputs? (0 for no and 1 for yes)', PRESS 1
6. Later you wil need to add a string to give a small comment about the purpose of running code
   for e.g: "Running to check the optimisation of 2dof 2UPS-1U mechanism"
VOILA!!

In order to run any other mechanism:

The code will provide 2 Input vectors
first: set of parameters that define the mechanism
second: vector of the current configuration in the workspace

You need following things:

1. A file whose output is all those parameters on which the constraints will be implemented (e.g: passive joints, active joints)
2. A file whose output is the jacobian matrix
3. fill out the my_input. file if you don't want the interactive input of the library
4. You can also plot the mechanism with optimised parameters by writing a file plot_mech

Check the my_input.m and plot_mech.m in the existing folders of UPS_related and lambda_mech to get the template of these files
