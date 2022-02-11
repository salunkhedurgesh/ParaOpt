% This is an attempt to write a general Nelder Mead code
% To change a mechanism please take care of the following files:
% 1. constraints.m: the inverse kinematics of the mechanism you want to optimize
% 2. determinant.m : The symbolic expression of the Jacobian
% 3. RDW_sing: the parameters defined should be present with determinant.m
% 4. rho_range: It is a sub-part of the inverse kinematics where the actuator ranges are required

%Code written by:
% 1. Durgesh Salunkhe, LS2N, France (durgesh.salunkhe@ls2n.fr)
%under a project supervised by:
% 1. Damien Chablat, LS2N, France
% 2. Marcello Sanguineti, UNIGE, Italy
% 3. Shivesh Kumar, DFKI, Germany
% 4. Guillaume Michel, CHU Nantes, France

close all;
clear all;
clc

global n coarse prismatic opspace save_files
global git_mood

main_start_time = clock;
prompt_you = 'Do you have pre-written function for inputs? (0 for no and 1 for yes)\n';
if input(prompt_you) == 1
    fprintf("Taking inputs from my_input.m file \n");
    self_nm_input();
else
    NMinput();
end

opspace_backedup = opspace;
coarse = 1;

format shortg
c = clock;
month_list = ["Jan", "Feb", "mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
foldername = num2str(size(opspace, 1)) +"dof_results_" + num2str(c(3))+ month_list(c(2));
if ~exist(foldername, 'dir')
    mkdir (foldername);
end

save_files(1) = foldername + "/" + save_files(1);
save_files(2) = foldername + "/" + save_files(2);
save_files(3) = foldername + "/" + save_files(3);

f1 = fopen(save_files(1),'r');
f2 = fopen(save_files(2),'r');
if f1 > 0
    fclose(f1);
    warning('File %s already exists, change name to avoid data loss\n', save_files(1));
elseif f2 > 0
    fclose(f2);
    warning('File %s already exists, change name to avoid data loss\n', save_files(2));
end

cprintf('*blue','\n\nType the necessary update - Why are you running the code?\nstring expected (example: "Trying to check the new set of constraints")');
prompt_git = '\n';
git_mood = input(prompt_git);

fprintf('The file names are %s and %s saved in %s folder. Both are opened in write mode \n', save_files(1), save_files(2), foldername);

[best_point, best_rho, saved_S_eval] = nelder_mead_ms(git_mood);
main_end_time = clock;

elapsed_time = etime(main_end_time, main_start_time);
thours = floor(elapsed_time/3600);
temp1 = mod(elapsed_time, 3600);
tminutes = floor(temp1/60);
tseconds = mod(temp1, 60);

fprintf("The total time elapsed for comple operation is %d hours %d minutes and %.1f seconds \n", thours, tminutes, tseconds);
reopen_points_fileID = fopen(save_files(2),'a');
fprintf(reopen_points_fileID, "The total time elapsed for comple operation is %d hours %d minutes and %.1f seconds\n", thours, tminutes, tseconds);
fclose(reopen_points_fileID);

arranged_multistarts = sortrows(saved_S_eval, n + 1);
refine_threshold = range_respect(floor(0.2*size(arranged_multistarts, 1)), [1, 10]);

chosen_refine(1, 1:n) = arranged_multistarts(1, 1:n);
run_iter1 = 2;
for fun_mainiter = 2:size(arranged_multistarts, 1)
    if run_iter1 > refine_threshold
        break
    end
    if arranged_multistarts(fun_mainiter, n+1) > 0.75*arranged_multistarts(1, n+1)
        chosen_refine(run_iter1, 1:n) = arranged_multistarts(fun_mainiter, 1:n);
    end
    run_iter1 = run_iter1 + 1;
end


coarse = 0;
write_evaluation_refine();
write_refmaxeval();
max_evaluation_refine = refmaxeval_fun();
write_rhorangerefine();
pause(3)
for refine_iter = 1:size(chosen_refine, 1)
    [refined_best_point, refined_best_rho, refine_eval] = nelder_mead_refine(chosen_refine(refine_iter, 1:n), save_files(3), max_evaluation_refine);
    refine_record_mat(refine_iter, :) = [refined_best_point, refined_best_rho, refine_eval];
end

end_time2 = clock;

elapsed_time = etime(end_time2, main_start_time);
thours = floor(elapsed_time/3600);
temp1 = mod(elapsed_time, 3600);
tminutes = floor(temp1/60);
tseconds = mod(temp1, 60);

elapsed_time2 = etime(end_time2, main_end_time);
thours2 = floor(elapsed_time2/3600);
temp12 = mod(elapsed_time2, 3600);
tminutes2 = floor(temp12/60);
tseconds2 = mod(temp12, 60);

arrange_refine = sortrows(refine_record_mat, n + 3);

fprintf("\nThe optimised point after refining is found \n");
for print_iter = 1:n
    fprintf("\nParameter %d = %f, \t", print_iter, arrange_refine(1, print_iter));
end
fprintf("\nThe evaluation is %f",arrange_refine(1,n+3));
if prismatic == 1
    fprintf("\nThe actuator ranges are: ");
    fprintf("[%f, %f] \n", arrange_refine(1, n+1), arrange_refine(1,n+2));
end

fprintf("The total time for refining operation is %d hours %d minutes and %.1f seconds \n", thours2, tminutes2, tseconds2);
fprintf("The total time elapsed for complete including refining operation is %d hours %d minutes and %.1f seconds \n", thours, tminutes, tseconds);
reopen_points_fileID = fopen(save_files(2),'a');
fprintf(reopen_points_fileID, "\nThe total time elapsed for refining is %d hours %d minutes and %.1f seconds\n", thours2, tminutes2, tseconds2);
fprintf(reopen_points_fileID, "The total time elapsed for operation including refining is %d hours %d minutes and %.1f seconds\n", thours, tminutes, tseconds);
fprintf(reopen_points_fileID, "\nThe optimised point after refining is found \n");
for print_iter = 1:n
    fprintf(reopen_points_fileID, "\nParameter %d = %f, \t", print_iter, arrange_refine(1, print_iter));
end
if prismatic == 1
    fprintf(reopen_points_fileID, "\nThe actuator ranges are: ");
    fprintf(reopen_points_fileID, "[%f, %f] \n", arrange_refine(1, n+1), arrange_refine(1,n+2));
end

refine_reopen =fopen(save_files(3), 'a');
fprintf(refine_reopen, "\nThe optimised point after refining is found \n");
for print_iter = 1:n
    fprintf(refine_reopen, "\nParameter %d = %f, \t", print_iter, arrange_refine(1, print_iter));
end
if prismatic == 1
    fprintf(refine_reopen, "\nThe actuator ranges are: ");
    fprintf(refine_reopen, "[%f, %f] \n", arrange_refine(1, n+1), arrange_refine(1,n+2));
end

fclose(reopen_points_fileID);
fclose(refine_reopen);

if exist('plot_mech.m', 'file')
    plot_mech(arrange_refine(1, 1:n));
end
if exist('hmap_mech.m', 'file')
    hmap_mech(arrange_refine(1, 1:n), foldername);
end




