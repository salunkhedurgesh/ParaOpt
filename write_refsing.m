function [] = write_refsing(opspace)
global coarse coarse_steps

temp_opspace = opspace;
op_dim = size(temp_opspace, 1);
for fun_singiter1 = 1:op_dim
    var_list(fun_singiter1) = "sing_alpha" + num2str(fun_singiter1);
end
if op_dim == 1
    var_list(2) = "sing_alpha2";
end
k = 1;

non_refsingID = fopen('nonsing_refboolean.m', 'w');
fprintf(non_refsingID, "function [det_boolean] = nonsing_refboolean(parameters) \n\n");

fprintf(non_refsingID, "global search_option \n");
fprintf(non_refsingID, "op_dim = %i; \n", op_dim);
fprintf(non_refsingID, "cen_jac_mat = jacobian_inst(parameters, zeros(op_dim)); \n");
fprintf(non_refsingID, "cen_det = det(inv(cen_jac_mat)); \n");
fprintf(non_refsingID, "det_boolean = 1; \n\n");
for iter = 1:op_dim
    fprintf(non_refsingID, "for " + string(var_list(iter)) + " = " + string(temp_opspace(iter, 1)) + ":" + string(temp_opspace(iter, 3)) + ":" + string(temp_opspace(iter, 2)) + "\n");
    for iter2 = 1:k
        fprintf(non_refsingID, "\t");
    end
    k = k+1;
end

fprintf(non_refsingID, "if search_option ~= ""tweak""\n");
tab_nec(op_dim+2, non_refsingID);
fprintf(non_refsingID, "search_spacevector = [");
for funaut_iter1 = 1:op_dim
    fprintf(non_refsingID, string(var_list(funaut_iter1)));
    if funaut_iter1 == op_dim
        fprintf(non_refsingID, "]; \n");
    else
        fprintf(non_refsingID, ", ");
    end
end
tab_nec(op_dim+1, non_refsingID);
fprintf(non_refsingID, "else\n");
tab_nec(op_dim+2, non_refsingID);
fprintf(non_refsingID, "search_spacevector = [");
fprintf(non_refsingID, string(var_list(1)));
fprintf(non_refsingID, "*cos(");
fprintf(non_refsingID, string(var_list(2)));
fprintf(non_refsingID, "), ");

fprintf(non_refsingID, string(var_list(1)));
fprintf(non_refsingID, "*sin(");
fprintf(non_refsingID, string(var_list(2)));
fprintf(non_refsingID, ")];\n");
tab_nec(op_dim+1, non_refsingID);
fprintf(non_refsingID, "end\n");

tab_nec(op_dim+1, non_refsingID);
fprintf(non_refsingID, "[jac_mat] = jacobian_inst(parameters, search_spacevector); \n");
tab_nec(op_dim+1, non_refsingID);
fprintf(non_refsingID, "if abs(det(inv(jac_mat))) < 5e-3 || det(inv(jac_mat))*cen_det < 0\n");
tab_nec(op_dim+2, non_refsingID);
fprintf(non_refsingID, "det_boolean = 0; \n");
tab_nec(op_dim+2, non_refsingID);
fprintf(non_refsingID, "break \n");
tab_nec(op_dim+1, non_refsingID);
fprintf(non_refsingID, "end");
k = k-2;
fprintf(non_refsingID, "\n");
for iter = 1:op_dim
    for iter2 = 1:k
        fprintf(non_refsingID, "\t");
    end
    k = k-1;
    fprintf(non_refsingID, "end \n");
end

fprintf(non_refsingID, "\nend %%function ends here \n");
fclose(non_refsingID);
end
