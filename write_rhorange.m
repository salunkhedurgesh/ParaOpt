function [] = write_rhorange()

global opspace coarse coarse_steps

op_dim = size(opspace, 1);
for fun_rhoiter1 = 1:op_dim
    rhorange_list(fun_rhoiter1) = "rho_alpha" + num2str(fun_rhoiter1);
end

if op_dim == 1
    rhorange_list(2) = "rho_alpha2";
end
    
temp_opspace = opspace;
k = 1;
if coarse == 1
    for funaut_iter2 = 1:size(temp_opspace, 1)
        temp_opspace(funaut_iter2, 3) = (temp_opspace(funaut_iter2, 2) - temp_opspace(funaut_iter2, 1))/coarse_steps;
    end
end
write_rhoID = fopen('rho_range.m', 'w');
fprintf(write_rhoID, "function [rho_rangemat] = rho_range(parameters) \n\n");
fprintf(write_rhoID, "\nglobal order_prismatic search_option\n");
fprintf(write_rhoID, "run_iter1 = 1;\n");

for iter = 1:op_dim
    fprintf(write_rhoID, "for " + string(rhorange_list(iter)) + " = " + string(temp_opspace(iter, 1)) + ":" + string(temp_opspace(iter, 3)) + ":" + string(temp_opspace(iter, 2)) + "\n");
    for iter2 = 1:k
        fprintf(write_rhoID, "\t");
    end
    k = k+1;
end

fprintf(write_rhoID, "if search_option ~= ""tweak""\n");
tab_nec(op_dim+2, write_rhoID);
fprintf(write_rhoID, "search_spacevector = [");
for funaut_iter1 = 1:op_dim
    fprintf(write_rhoID, string(rhorange_list(funaut_iter1)));
    if funaut_iter1 == op_dim
        fprintf(write_rhoID, "]; \n");
    else
        fprintf(write_rhoID, ", ");
    end
end
tab_nec(op_dim+1, write_rhoID);
fprintf(write_rhoID, "else\n");
tab_nec(op_dim+2, write_rhoID);
fprintf(write_rhoID, "search_spacevector = [");
fprintf(write_rhoID, string(rhorange_list(1)));
fprintf(write_rhoID, "*cos(");
fprintf(write_rhoID, string(rhorange_list(2)));
fprintf(write_rhoID, "), ");

fprintf(write_rhoID, string(rhorange_list(1)));
fprintf(write_rhoID, "*sin(");
fprintf(write_rhoID, string(rhorange_list(2)));
fprintf(write_rhoID, ")];\n");
tab_nec(op_dim+1, write_rhoID);
fprintf(write_rhoID, "end\n");

tab_nec(op_dim+1, write_rhoID);
fprintf(write_rhoID, "[configuration_vector] = configuration_space(parameters, search_spacevector);\n");
tab_nec(op_dim+1, write_rhoID);
fprintf(write_rhoID, "rho_instmat(run_iter1, 1:length(order_prismatic)) = configuration_vector(order_prismatic);\n");
tab_nec(op_dim+1, write_rhoID);
fprintf(write_rhoID, "run_iter1 = run_iter1 + 1;\n");

k = k-2;
fprintf(write_rhoID, "\n");
for iter = 1:op_dim
    for iter2 = 1:k
        fprintf(write_rhoID, "\t");
    end
    k = k-1;
    fprintf(write_rhoID, "end \n");
end

fprintf(write_rhoID, "for stor_iter = 1:size(rho_instmat, 2)\n");
fprintf(write_rhoID, "\trho_rangemat(stor_iter, 1) = min(rho_instmat(:, stor_iter));\n");
fprintf(write_rhoID, "\trho_rangemat(stor_iter, 2) = max(rho_instmat(:, stor_iter));\n");
fprintf(write_rhoID, "end\n");

fprintf(write_rhoID, "\nend %%function ends here \n");
fclose(write_rhoID);
end

