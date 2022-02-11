function [] = write_evaluation()
global coarse coarse_steps opspace num_prismatic reward

temp_opspace = opspace;
global prismatic search_option

if coarse == 1
    for funaut_iter2 = 1:size(temp_opspace, 1)
        temp_opspace(funaut_iter2, 3) = (temp_opspace(funaut_iter2, 2) - temp_opspace(funaut_iter2, 1))/coarse_steps;
    end
end
op_dim = size(temp_opspace, 1);
for fun_evaliter1 = 1:op_dim
    obj_var(fun_evaliter1) = "eval_alpha" + num2str(fun_evaliter1);
end

if op_dim == 1
    obj_var(2) = "eval_alpha2";
end
k = 1;

wri_objID = fopen('evaluation_fun.m', 'w');
fprintf(wri_objID, "function [c_qual,rho_vec] = evaluation_fun(parameters) \n");
fprintf(wri_objID, "global search_option \n");
if reward ~= "plain"
    fprintf(wri_objID, "global reward \n");
end
if prismatic == 1
    fprintf(wri_objID, "global num_prismatic order_prismatic force_valid\n\n");
end

fprintf(wri_objID, "op_dim = %i; \n", op_dim);
fprintf(wri_objID, "c_qual_only_joint = 0;\n");
fprintf(wri_objID, "rho_vec = [0, 0];\n");

op_mean = zeros(1, size(opspace, 1));
op_span = zeros(1, size(opspace, 1));
for range_iter1 = 1:size(opspace, 1)
    op_mean(range_iter1) = opspace(range_iter1, 1) + (opspace(range_iter1, 2) - opspace(range_iter1, 1))/2;
    op_span(range_iter1) = opspace(range_iter1, 2) - opspace(range_iter1, 1);
end
if search_option == "tweak"
    op_meanstr = "0, 0";
else
op_meanstr= num2str(op_mean);
end
fprintf(wri_objID, "cen_jac_mat = jacobian_inst(parameters, [" + op_meanstr + "]); \n");
fprintf(wri_objID, "cen_det = det(inv(cen_jac_mat)); \n");
fprintf(wri_objID, "valid_iter = 1; \nskip = 0; \ninvalid_points = 0;  \n\n");

%%% Start of FOR LOOP %%%
for iter = 1:op_dim
    fprintf(wri_objID, "for " + string(obj_var(iter)) + " = " + string(temp_opspace(iter, 1)) + ":" + string(temp_opspace(iter, 3)) + ":" + string(temp_opspace(iter, 2)) + "\n");
    for iter2 = 1:k
        fprintf(wri_objID, "\t");
    end
    k = k+1;
end

fprintf(wri_objID, "if search_option ~= ""tweak""\n");
tab_nec(op_dim+2, wri_objID);
fprintf(wri_objID, "search_spacevector = [");
for funaut_iter1 = 1:op_dim
    fprintf(wri_objID, string(obj_var(funaut_iter1)));
    if funaut_iter1 == op_dim
        fprintf(wri_objID, "]; \n");
    else
        fprintf(wri_objID, ", ");
    end
end
tab_nec(op_dim+1, wri_objID);
fprintf(wri_objID, "else\n");
tab_nec(op_dim+2, wri_objID);
fprintf(wri_objID, "search_spacevector = [");
fprintf(wri_objID, string(obj_var(1)));
fprintf(wri_objID, "*cos(");
fprintf(wri_objID, string(obj_var(2)));
fprintf(wri_objID, "), ");

fprintf(wri_objID, string(obj_var(1)));
fprintf(wri_objID, "*sin(");
fprintf(wri_objID, string(obj_var(2)));
fprintf(wri_objID, ")];\n");
tab_nec(op_dim+1, wri_objID);
fprintf(wri_objID, "end\n");

tab_nec(op_dim+1, wri_objID);
fprintf(wri_objID, "[configuration_vector] = configuration_space(parameters, search_spacevector);\n");
tab_nec(op_dim+1, wri_objID);
fprintf(wri_objID, "[jac_mat] = jacobian_inst(parameters, search_spacevector); \n");
tab_nec(op_dim+1, wri_objID);
%%% Checking the singularity condition %%%
fprintf(wri_objID, "if abs(det(inv(jac_mat))) < 5e-3 || det(inv(jac_mat))*cen_det < 0\n");
tab_nec(op_dim+2, wri_objID);
fprintf(wri_objID, "skip = 1;\n");
tab_nec(op_dim+2, wri_objID);
fprintf(wri_objID, "invalid_points = invalid_points + 1;\n");
tab_nec(op_dim+1, wri_objID);
fprintf(wri_objID, "end\n");
%%% Checking the quality function %%%
tab_nec(op_dim+1, wri_objID);
fprintf(wri_objID, "exg_qual = 1;\n");
if reward ~= "plain"
    tab_nec(op_dim+1, wri_objID);
    fprintf(wri_objID, "quality = quality_fun(jac_mat);\n");
    tab_nec(op_dim+1, wri_objID);
    fprintf(wri_objID, "exg_qual = 5*quality; %%Exaggerated quality to differentiate between results better\n");
    
    %%% Biased reward function %%%
    tab_nec(op_dim+1, wri_objID);
    fprintf(wri_objID, "if reward == ""biased"" \n");
    tab_nec(op_dim+2, wri_objID);
    fprintf(wri_objID, "zone = zone_bias(search_spacevector);\n");
    tab_nec(op_dim+2, wri_objID);
    fprintf(wri_objID, "exg_qual = zone*exg_qual;\n");
    tab_nec(op_dim+1, wri_objID);
    fprintf(wri_objID, "elseif reward == ""min_quality"" \n");
    tab_nec(op_dim+2, wri_objID);
    fprintf(wri_objID, "zone = zone_bias(search_spacevector);\n");
    tab_nec(op_dim+2, wri_objID);
    fprintf(wri_objID, "if zone < 4\n");
    tab_nec(op_dim+3, wri_objID);
    fprintf(wri_objID, "if objective_choice == 2\n");
    tab_nec(op_dim+4, wri_objID);
    fprintf(wri_objID, "if quality < 0.3\n");
    tab_nec(op_dim+5, wri_objID);
    fprintf(wri_objID, "invalid_points = invalid_points + 1;\n");
    tab_nec(op_dim+5, wri_objID);
    fprintf(wri_objID, "continue;\n");
    tab_nec(op_dim+4, wri_objID);
    fprintf(wri_objID, "end\n");
    tab_nec(op_dim+3, wri_objID);
    fprintf(wri_objID, "elseif objective_choice == 3\n");
    tab_nec(op_dim+4, wri_objID);
    fprintf(wri_objID, "if quality <= 0\n");
    tab_nec(op_dim+5, wri_objID);
    fprintf(wri_objID, "invalid_points = invalid_points + 1;\n");
    tab_nec(op_dim+5, wri_objID);
    fprintf(wri_objID, "continue;\n");
    tab_nec(op_dim+4, wri_objID);
    fprintf(wri_objID, "end\n");
    tab_nec(op_dim+3, wri_objID);
    fprintf(wri_objID, "end\n");
    
    tab_nec(op_dim+2, wri_objID);
    fprintf(wri_objID, "end\n");
    tab_nec(op_dim+1, wri_objID);
    fprintf(wri_objID, "end\n");
end

tab_nec(op_dim+1, wri_objID);
fprintf(wri_objID, "if skip == 1\n");
tab_nec(op_dim+2, wri_objID);
fprintf(wri_objID, "continue\n");
tab_nec(op_dim+1, wri_objID);
fprintf(wri_objID, "end\n");

tab_nec(op_dim+1, wri_objID);
fprintf(wri_objID, "limit_pass = check_limits(configuration_vector);\n");
tab_nec(op_dim+1, wri_objID);
fprintf(wri_objID, "if limit_pass == 0\n");
tab_nec(op_dim+2, wri_objID);
fprintf(wri_objID, "continue\n");
tab_nec(op_dim+1, wri_objID);
fprintf(wri_objID, "end\n\n");

valid_size = num2str(op_dim + num_prismatic + 1);
if prismatic == 1
    tab_nec(op_dim+1, wri_objID);
    fprintf(wri_objID, "rho_inst = zeros(1, num_prismatic);\n");
    tab_nec(op_dim+1, wri_objID);
    fprintf(wri_objID, "for funaut_iter2 = 1:num_prismatic\n");
    tab_nec(op_dim+2, wri_objID);
    fprintf(wri_objID, "rho_inst(funaut_iter2) = configuration_vector(order_prismatic(funaut_iter2));\n");
    tab_nec(op_dim+1, wri_objID);
    fprintf(wri_objID, "end\n");
    tab_nec(op_dim+1, wri_objID);
    fprintf(wri_objID, "valid_points_vec(valid_iter,1:" + valid_size + ") = [search_spacevector, rho_inst, exg_qual];\n");
end
tab_nec(op_dim+1, wri_objID);
fprintf(wri_objID, "valid_iter = valid_iter + 1;\n");
tab_nec(op_dim+1, wri_objID);
fprintf(wri_objID, "c_qual_only_joint = c_qual_only_joint + exg_qual;\n");

%%% Start of END loop %%%
k = k-2;

fprintf(wri_objID, "\n");
for iter = 1:op_dim
    for iter2 = 1:k
        fprintf(wri_objID, "\t");
    end
    k = k-1;
    fprintf(wri_objID, "end\n");
end
if prismatic == 0
    fprintf(wri_objID, "if skip == 1 \n");
    fprintf(wri_objID, "\tc_qual = invalid_points;\n");
    fprintf(wri_objID, "else \n");
    fprintf(wri_objID, "\tc_qual = -c_qual_only_joint;\n");
    fprintf(wri_objID, "end \n\n");
else
    fprintf(wri_objID, "if (skip ~= 1 || force_valid == 1) && valid_iter > 1 \n");
    fprintf(wri_objID, "\t[c_qual, rho_vec] = prismatic_optimisation(parameters, valid_points_vec, c_qual_only_joint, 0);\n");
    fprintf(wri_objID, "elseif skip == 0 \n");
    fprintf(wri_objID, "\tc_qual = -c_qual_only_joint;\n");
    fprintf(wri_objID, "else \n");
    fprintf(wri_objID, "\tc_qual = invalid_points;\n");
    fprintf(wri_objID, "end\n\n");
end
fprintf(wri_objID, "\nend %%function ends here \n");
fclose(wri_objID);

end
