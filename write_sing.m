function [] = write_sing(opspace)
global coarse coarse_steps shrink_times search_option

temp_opspace = opspace;
if coarse == 1
    for funaut_iter2 = 1:size(temp_opspace, 1)
        temp_opspace(funaut_iter2, 3) = (temp_opspace(funaut_iter2, 2) - temp_opspace(funaut_iter2, 1))/coarse_steps;
    end
end

if shrink_times ~= 0
    my_opspace = opspace;
    shrink_by = [0.75, 0.5, 0.25];
    my_opspace(:, 1:2) =  shrink_by(shrink_times)*opspace(:, 1:2);
    for fun_raniter1 = 1: size(opspace, 1)
        if opspace(fun_raniter1, 3) > 0.1*(my_opspace(fun_raniter1, 2) - my_opspace(fun_raniter1, 1))
            res_fac = (opspace(fun_raniter1, 2) - opspace(fun_raniter1, 1))/opspace(fun_raniter1, 3);
            my_opspace(fun_raniter1, 3) = (my_opspace(fun_raniter1, 2) - my_opspace(fun_raniter1, 1))/res_fac;
        end
    end
    temp_opspace = my_opspace;
end


op_dim = size(temp_opspace, 1);
for fun_singiter1 = 1:op_dim
    var_list(fun_singiter1) = "sing_alpha" + num2str(fun_singiter1);
end
if op_dim == 1
    var_list(2) = "sing_alpha2";
end
k = 1;

if shrink_times == 0
    non_singID = fopen('nonsing_boolean.m', 'w');
    fprintf(non_singID, "function [det_boolean] = nonsing_boolean(parameters) \n\n");
elseif shrink_times == 1
    non_singID = fopen('nonsing_boolean75.m', 'w');
    fprintf(non_singID, "function [det_boolean] = nonsing_boolean75(parameters) \n\n");
elseif shrink_times == 2
    non_singID = fopen('nonsing_boolean50.m', 'w');
    fprintf(non_singID, "function [det_boolean] = nonsing_boolean50(parameters) \n\n");
elseif shrink_times == 3
    non_singID = fopen('nonsing_boolean25.m', 'w');
    fprintf(non_singID, "function [det_boolean] = nonsing_boolean25(parameters) \n\n");
end

fprintf(non_singID, "op_dim = %i; \n", op_dim);

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

fprintf(non_singID, "cen_jac_mat = jacobian_inst(parameters, [" + op_meanstr + "]); \n");
fprintf(non_singID, "cen_det = det(inv(cen_jac_mat)); \n");
fprintf(non_singID, "global search_option \n");
fprintf(non_singID, "det_boolean = 1; \n\n");
for iter = 1:op_dim
    fprintf(non_singID, "for " + string(var_list(iter)) + " = " + string(temp_opspace(iter, 1)) + ":" + string(temp_opspace(iter, 3)) + ":" + string(temp_opspace(iter, 2)) + "\n");
    for iter2 = 1:k
        fprintf(non_singID, "\t");
    end
    k = k+1;
end

fprintf(non_singID, "if search_option ~= ""tweak""\n");
tab_nec(op_dim+2, non_singID);
fprintf(non_singID, "search_spacevector = [");
for funaut_iter1 = 1:op_dim
    fprintf(non_singID, string(var_list(funaut_iter1)));
    if funaut_iter1 == op_dim
        fprintf(non_singID, "]; \n");
    else
        fprintf(non_singID, ", ");
    end
end
tab_nec(op_dim+1, non_singID);
fprintf(non_singID, "else\n");
tab_nec(op_dim+2, non_singID);
fprintf(non_singID, "search_spacevector = [");
fprintf(non_singID, string(var_list(1)));
fprintf(non_singID, "*cos(");
fprintf(non_singID, string(var_list(2)));
fprintf(non_singID, "), ");

fprintf(non_singID, string(var_list(1)));
fprintf(non_singID, "*sin(");
fprintf(non_singID, string(var_list(2)));
fprintf(non_singID, ")];\n");
tab_nec(op_dim+1, non_singID);
fprintf(non_singID, "end\n");

tab_nec(op_dim+1, non_singID);
fprintf(non_singID, "[jac_mat] = jacobian_inst(parameters, search_spacevector); \n");
tab_nec(op_dim+1, non_singID);
fprintf(non_singID, "if abs(det(inv(jac_mat))) < 5e-3 || det(inv(jac_mat))*cen_det < 0\n");
tab_nec(op_dim+2, non_singID);
fprintf(non_singID, "det_boolean = 0; \n");
tab_nec(op_dim+2, non_singID);
fprintf(non_singID, "break \n");
tab_nec(op_dim+1, non_singID);
fprintf(non_singID, "end");
k = k-2;
fprintf(non_singID, "\n");
for iter = 1:op_dim
    for iter2 = 1:k
        fprintf(non_singID, "\t");
    end
    k = k-1;
    fprintf(non_singID, "end \n");
end

fprintf(non_singID, "\nend %%function ends here \n");

fclose(non_singID);
end
