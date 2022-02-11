function [] = write_evaluation_refine()
global opspace num_prismatic reward search_option

temp_opspace = opspace;
global prismatic

op_dim = size(temp_opspace, 1);
for fun_evaliter1 = 1:op_dim
    objref_var(fun_evaliter1) = "refeval_alpha" + num2str(fun_evaliter1);
end
if op_dim == 1
    objref_var(2) = "refeval_alpha2";
end
k = 1;

wri_objrefID = fopen('evalrefine_fun.m', 'w');
fprintf(wri_objrefID, "function [c_qual,rho_vec] = evalrefine_fun(parameters) \n");
fprintf(wri_objrefID, "global search_option force_valid\n");
if reward ~= "plain"
    fprintf(wri_objrefID, "global reward \n");
end
if prismatic == 1
    fprintf(wri_objrefID, "global num_prismatic order_prismatic\n\n");
end

fprintf(wri_objrefID, "op_dim = %i; \n", op_dim);
fprintf(wri_objrefID, "c_qual_only_joint = 0;\n");
fprintf(wri_objrefID, "rho_vec = [0, 0];\n");

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
fprintf(wri_objrefID, "cen_jac_mat = jacobian_inst(parameters, [" + op_meanstr + "]); \n");
fprintf(wri_objrefID, "cen_det = det(inv(cen_jac_mat)); \n");
fprintf(wri_objrefID, "valid_iter = 1; \nskip = 0; \ninvalid_points = 0;  \n\n");

%%% Start of FOR LOOP %%%
for iter = 1:op_dim
    fprintf(wri_objrefID, "for " + string(objref_var(iter)) + " = " + string(temp_opspace(iter, 1)) + ":" + string(temp_opspace(iter, 3)) + ":" + string(temp_opspace(iter, 2)) + "\n");
    for iter2 = 1:k
        fprintf(wri_objrefID, "\t");
    end
    k = k+1;
end

fprintf(wri_objrefID, "if search_option ~= ""tweak""\n");
tab_nec(op_dim+2, wri_objrefID);
fprintf(wri_objrefID, "search_spacevector = [");
for funaut_iter1 = 1:op_dim
    fprintf(wri_objrefID, string(objref_var(funaut_iter1)));
    if funaut_iter1 == op_dim
        fprintf(wri_objrefID, "]; \n");
    else
        fprintf(wri_objrefID, ", ");
    end
end
tab_nec(op_dim+1, wri_objrefID);
fprintf(wri_objrefID, "else\n");
tab_nec(op_dim+2, wri_objrefID);
fprintf(wri_objrefID, "search_spacevector = [");
fprintf(wri_objrefID, string(objref_var(1)));
fprintf(wri_objrefID, "*cos(");
fprintf(wri_objrefID, string(objref_var(2)));
fprintf(wri_objrefID, "), ");

fprintf(wri_objrefID, string(objref_var(1)));
fprintf(wri_objrefID, "*sin(");
fprintf(wri_objrefID, string(objref_var(2)));
fprintf(wri_objrefID, ")];\n");
tab_nec(op_dim+1, wri_objrefID);
fprintf(wri_objrefID, "end\n");

tab_nec(op_dim+1, wri_objrefID);
fprintf(wri_objrefID, "[configuration_vector] = configuration_space(parameters, search_spacevector);\n");
tab_nec(op_dim+1, wri_objrefID);
fprintf(wri_objrefID, "[jac_mat] = jacobian_inst(parameters, search_spacevector); \n");
tab_nec(op_dim+1, wri_objrefID);
%%% Checking the singularity condition %%%
fprintf(wri_objrefID, "if abs(det(inv(jac_mat))) < 5e-3 || det(inv(jac_mat))*cen_det < 0\n");
tab_nec(op_dim+2, wri_objrefID);
fprintf(wri_objrefID, "skip = 1;\n");
tab_nec(op_dim+2, wri_objrefID);
fprintf(wri_objrefID, "invalid_points = invalid_points + 1;\n");
tab_nec(op_dim+1, wri_objrefID);
fprintf(wri_objrefID, "end\n");
%%% Checking the quality function %%%
tab_nec(op_dim+1, wri_objrefID);
fprintf(wri_objrefID, "exg_qual = 1;\n");
if reward ~= "plain"
    tab_nec(op_dim+1, wri_objrefID);
    fprintf(wri_objrefID, "quality = quality_fun(jac_mat);\n");
    tab_nec(op_dim+1, wri_objrefID);
    fprintf(wri_objrefID, "exg_qual = 5*quality; %%Exaggerated quality to differentiate between results better\n");
    
    %%% Biased reward function %%%
    tab_nec(op_dim+1, wri_objrefID);
    fprintf(wri_objrefID, "if reward == ""biased"" \n");
    tab_nec(op_dim+2, wri_objrefID);
    fprintf(wri_objrefID, "zone = zone_bias(search_spacevector);\n");
    tab_nec(op_dim+2, wri_objrefID);
    fprintf(wri_objrefID, "exg_qual = zone*exg_qual;\n");
    tab_nec(op_dim+1, wri_objrefID);
    fprintf(wri_objrefID, "elseif reward == ""min_quality"" \n");
    tab_nec(op_dim+2, wri_objrefID);
    fprintf(wri_objrefID, "zone = zone_bias(search_spacevector);\n");
    tab_nec(op_dim+2, wri_objrefID);
    fprintf(wri_objrefID, "if zone < 4\n");
    tab_nec(op_dim+3, wri_objrefID);
    fprintf(wri_objrefID, "if objective_choice == 2\n");
    tab_nec(op_dim+4, wri_objrefID);
    fprintf(wri_objrefID, "if quality < 0.3\n");
    tab_nec(op_dim+5, wri_objrefID);
    fprintf(wri_objrefID, "invalid_points = invalid_points + 1;\n");
    tab_nec(op_dim+5, wri_objrefID);
    fprintf(wri_objrefID, "continue;\n");
    tab_nec(op_dim+4, wri_objrefID);
    fprintf(wri_objrefID, "end\n");
    tab_nec(op_dim+3, wri_objrefID);
    fprintf(wri_objrefID, "elseif objective_choice == 3\n");
    tab_nec(op_dim+4, wri_objrefID);
    fprintf(wri_objrefID, "if quality <= 0\n");
    tab_nec(op_dim+5, wri_objrefID);
    fprintf(wri_objrefID, "invalid_points = invalid_points + 1;\n");
    tab_nec(op_dim+5, wri_objrefID);
    fprintf(wri_objrefID, "continue;\n");
    tab_nec(op_dim+4, wri_objrefID);
    fprintf(wri_objrefID, "end\n");
    tab_nec(op_dim+3, wri_objrefID);
    fprintf(wri_objrefID, "end\n");
    
    tab_nec(op_dim+2, wri_objrefID);
    fprintf(wri_objrefID, "end\n");
    tab_nec(op_dim+1, wri_objrefID);
    fprintf(wri_objrefID, "end\n");
end

tab_nec(op_dim+1, wri_objrefID);
fprintf(wri_objrefID, "if skip == 1\n");
tab_nec(op_dim+2, wri_objrefID);
fprintf(wri_objrefID, "continue\n");
tab_nec(op_dim+1, wri_objrefID);
fprintf(wri_objrefID, "end\n");

tab_nec(op_dim+1, wri_objrefID);
fprintf(wri_objrefID, "limit_pass = check_limits(configuration_vector);\n");
tab_nec(op_dim+1, wri_objrefID);
fprintf(wri_objrefID, "if limit_pass == 0\n");
tab_nec(op_dim+2, wri_objrefID);
fprintf(wri_objrefID, "continue\n");
tab_nec(op_dim+1, wri_objrefID);
fprintf(wri_objrefID, "end\n\n");

valid_size = num2str(op_dim + num_prismatic + 1);
if prismatic == 1
    tab_nec(op_dim+1, wri_objrefID);
    fprintf(wri_objrefID, "rho_inst = zeros(1, num_prismatic);\n");
    tab_nec(op_dim+1, wri_objrefID);
    fprintf(wri_objrefID, "for funaut_iter2 = 1:num_prismatic\n");
    tab_nec(op_dim+2, wri_objrefID);
    fprintf(wri_objrefID, "rho_inst(funaut_iter2) = configuration_vector(order_prismatic(funaut_iter2));\n");
    tab_nec(op_dim+1, wri_objrefID);
    fprintf(wri_objrefID, "end\n");
    tab_nec(op_dim+1, wri_objrefID);
    fprintf(wri_objrefID, "valid_points_vec(valid_iter,1:" + valid_size + ") = [search_spacevector, rho_inst, exg_qual];\n");
end
tab_nec(op_dim+1, wri_objrefID);
fprintf(wri_objrefID, "valid_iter = valid_iter + 1;\n");
tab_nec(op_dim+1, wri_objrefID);
fprintf(wri_objrefID, "c_qual_only_joint = c_qual_only_joint + exg_qual;\n");

%%% Start of END loop %%%
k = k-2;

fprintf(wri_objrefID, "\n");
for iter = 1:op_dim
    for iter2 = 1:k
        fprintf(wri_objrefID, "\t");
    end
    k = k-1;
    fprintf(wri_objrefID, "end\n");
end
if prismatic == 0
    fprintf(wri_objrefID, "if skip == 1 \n");
    fprintf(wri_objrefID, "\tc_qual = invalid_points;\n");
    fprintf(wri_objrefID, "else \n");
    fprintf(wri_objrefID, "\tc_qual = -c_qual_only_joint;\n");
    fprintf(wri_objrefID, "end \n\n");
else
    fprintf(wri_objrefID, "if (skip ~= 1 || force_valid == 1) && valid_iter > 1\n");
    fprintf(wri_objrefID, "\t[c_qual, rho_vec] = prismatic_optimisation(parameters, valid_points_vec, c_qual_only_joint, 1);\n");
    fprintf(wri_objrefID, "elseif skip == 0 \n");
    fprintf(wri_objrefID, "\tc_qual = -c_qual_only_joint;\n");
    fprintf(wri_objrefID, "else \n");
    fprintf(wri_objrefID, "\tc_qual = invalid_points;\n");
    fprintf(wri_objrefID, "end\n\n");
end
fprintf(wri_objrefID, "\nend %%function ends here \n");
fclose(wri_objrefID);
end
