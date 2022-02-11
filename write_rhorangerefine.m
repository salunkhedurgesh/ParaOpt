function [] = write_rhorangerefine()

global opspace 

op_dim = size(opspace, 1);
for fun_rhoiter1 = 1:op_dim
    rhorangeref_list(fun_rhoiter1) = "refrho_alpha" + num2str(fun_rhoiter1);
end

if op_dim == 1
    rhorangeref_list(2) = "refrho_alpha2";
end
    
temp_opspace = opspace;
k = 1;
write_refrhoID = fopen('rho_rangeref.m', 'w');
fprintf(write_refrhoID, "function [rho_rangemat] = rho_rangeref(parameters) \n\n");
fprintf(write_refrhoID, "\nglobal order_prismatic search_option\n");
fprintf(write_refrhoID, "run_iter1 = 1;\n");

for iter = 1:op_dim
    fprintf(write_refrhoID, "for " + string(rhorangeref_list(iter)) + " = " + string(temp_opspace(iter, 1)) + ":" + string(temp_opspace(iter, 3)) + ":" + string(temp_opspace(iter, 2)) + "\n");
    for iter2 = 1:k
        fprintf(write_refrhoID, "\t");
    end
    k = k+1;
end

fprintf(write_refrhoID, "if search_option ~= ""tweak""\n");
tab_nec(op_dim+2, write_refrhoID);
fprintf(write_refrhoID, "search_spacevector = [");
for funaut_iter1 = 1:op_dim
    fprintf(write_refrhoID, string(rhorangeref_list(funaut_iter1)));
    if funaut_iter1 == op_dim
        fprintf(write_refrhoID, "]; \n");
    else
        fprintf(write_refrhoID, ", ");
    end
end
tab_nec(op_dim+1, write_refrhoID);
fprintf(write_refrhoID, "else\n");
tab_nec(op_dim+2, write_refrhoID);
fprintf(write_refrhoID, "search_spacevector = [");
fprintf(write_refrhoID, string(rhorangeref_list(1)));
fprintf(write_refrhoID, "*cos(");
fprintf(write_refrhoID, string(rhorangeref_list(2)));
fprintf(write_refrhoID, "), ");

fprintf(write_refrhoID, string(rhorangeref_list(1)));
fprintf(write_refrhoID, "*sin(");
fprintf(write_refrhoID, string(rhorangeref_list(2)));
fprintf(write_refrhoID, ")];\n");
tab_nec(op_dim+1, write_refrhoID);
fprintf(write_refrhoID, "end\n");

tab_nec(op_dim+1, write_refrhoID);
fprintf(write_refrhoID, "[configuration_vector] = configuration_space(parameters, search_spacevector);\n");
tab_nec(op_dim+1, write_refrhoID);
fprintf(write_refrhoID, "rho_instmat(run_iter1, 1:length(order_prismatic)) = configuration_vector(order_prismatic);\n");
tab_nec(op_dim+1, write_refrhoID);
fprintf(write_refrhoID, "run_iter1 = run_iter1 + 1;\n");

k = k-2;
fprintf(write_refrhoID, "\n");
for iter = 1:op_dim
    for iter2 = 1:k
        fprintf(write_refrhoID, "\t");
    end
    k = k-1;
    fprintf(write_refrhoID, "end \n");
end

fprintf(write_refrhoID, "for stor_iter = 1:size(rho_instmat, 2)\n");
fprintf(write_refrhoID, "\trho_rangemat(stor_iter, 1) = min(rho_instmat(:, stor_iter));\n");
fprintf(write_refrhoID, "\trho_rangemat(stor_iter, 2) = max(rho_instmat(:, stor_iter));\n");
fprintf(write_refrhoID, "end\n");

fprintf(write_refrhoID, "\nend %%function ends here \n");
fclose(write_refrhoID);
end

