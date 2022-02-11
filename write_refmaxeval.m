function [] = write_refmaxeval()
global opspace reward

temp_opspace = opspace;
global prismatic

op_dim = size(temp_opspace, 1);
for fun_evaliter1 = 1:op_dim
    refobj_var(fun_evaliter1) = "refeval_alpha" + num2str(fun_evaliter1);
end
if op_dim == 1
    refobj_var(2) = "refeval_alpha2";
end
k = 1;

wri_refmaxID = fopen('refmaxeval_fun.m', 'w');
fprintf(wri_refmaxID, "function c_qual = refmaxeval_fun() \n");
fprintf(wri_refmaxID, "global search_option \n");
if reward ~= "plain"
    fprintf(wri_refmaxID, "global reward \n");
end
if prismatic == 1
    fprintf(wri_refmaxID, "global num_prismatic order_prismatic\n\n");
end

fprintf(wri_refmaxID, "op_dim = %i; \n", op_dim);
fprintf(wri_refmaxID, "c_qual_only_joint = 0;\n");
fprintf(wri_refmaxID, "quality = 1;\n");
fprintf(wri_refmaxID, "skip = 0;\n");
fprintf(wri_refmaxID, "valid_iter = 1;\n");

%%% Start of FOR LOOP %%%
for iter = 1:op_dim
    fprintf(wri_refmaxID, "for " + string(refobj_var(iter)) + " = " + string(temp_opspace(iter, 1)) + ":" + string(temp_opspace(iter, 3)) + ":" + string(temp_opspace(iter, 2)) + "\n");
    for iter2 = 1:k
        fprintf(wri_refmaxID, "\t");
    end
    k = k+1;
end

fprintf(wri_refmaxID, "if search_option ~= ""tweak""\n");
tab_nec(op_dim+2, wri_refmaxID);
fprintf(wri_refmaxID, "search_spacevector = [");
for funaut_iter1 = 1:op_dim
    fprintf(wri_refmaxID, string(refobj_var(funaut_iter1)));
    if funaut_iter1 == op_dim
        fprintf(wri_refmaxID, "]; \n");
    else
        fprintf(wri_refmaxID, ", ");
    end
end
tab_nec(op_dim+1, wri_refmaxID);
fprintf(wri_refmaxID, "else\n");
tab_nec(op_dim+2, wri_refmaxID);
fprintf(wri_refmaxID, "search_spacevector = [");
fprintf(wri_refmaxID, string(refobj_var(1)));
fprintf(wri_refmaxID, "*cos(");
fprintf(wri_refmaxID, string(refobj_var(2)));
fprintf(wri_refmaxID, "), ");

fprintf(wri_refmaxID, string(refobj_var(1)));
fprintf(wri_refmaxID, "*sin(");
fprintf(wri_refmaxID, string(refobj_var(2)));
fprintf(wri_refmaxID, ")];\n");
tab_nec(op_dim+1, wri_refmaxID);
fprintf(wri_refmaxID, "end\n");


%%% Checking the quality function %%%
tab_nec(op_dim+1, wri_refmaxID);
fprintf(wri_refmaxID, "exg_qual = 1;\n");
if reward ~= "plain"
    tab_nec(op_dim+1, wri_refmaxID);
    fprintf(wri_refmaxID, "exg_qual = 5*quality; %%Exaggerated quality to differentiate between results better\n");
    
    %%% Biased reward function %%%
    tab_nec(op_dim+1, wri_refmaxID);
    fprintf(wri_refmaxID, "if reward == ""biased"" \n");
    tab_nec(op_dim+2, wri_refmaxID);
    fprintf(wri_refmaxID, "zone = zone_bias(search_spacevector);\n");
    tab_nec(op_dim+2, wri_refmaxID);
    fprintf(wri_refmaxID, "exg_qual = zone*exg_qual;\n");
    tab_nec(op_dim+1, wri_refmaxID);
    fprintf(wri_refmaxID, "elseif reward == ""min_quality"" \n");
    tab_nec(op_dim+2, wri_refmaxID);
    fprintf(wri_refmaxID, "zone = zone_bias(search_spacevector);\n");
    tab_nec(op_dim+2, wri_refmaxID);
    fprintf(wri_refmaxID, "if zone < 4\n");
    tab_nec(op_dim+3, wri_refmaxID);
    fprintf(wri_refmaxID, "if quality < 0.3\n");
    tab_nec(op_dim+4, wri_refmaxID);
    fprintf(wri_refmaxID, "invalid_points = invalid_points + 1;\n");
    tab_nec(op_dim+4, wri_refmaxID);
    fprintf(wri_refmaxID, "continue;\n");
    tab_nec(op_dim+3, wri_refmaxID);
    fprintf(wri_refmaxID, "end\n");
    tab_nec(op_dim+2, wri_refmaxID);
    fprintf(wri_refmaxID, "end\n");
    tab_nec(op_dim+1, wri_refmaxID);
    fprintf(wri_refmaxID, "end\n");
end

tab_nec(op_dim+1, wri_refmaxID);
fprintf(wri_refmaxID, "if skip == 1\n");
tab_nec(op_dim+2, wri_refmaxID);
fprintf(wri_refmaxID, "continue\n");
tab_nec(op_dim+1, wri_refmaxID);
fprintf(wri_refmaxID, "end\n");

tab_nec(op_dim+1, wri_refmaxID);
fprintf(wri_refmaxID, "valid_iter = valid_iter + 1;\n");
tab_nec(op_dim+1, wri_refmaxID);
fprintf(wri_refmaxID, "c_qual_only_joint = c_qual_only_joint + exg_qual;\n");

%%% Start of END loop %%%
k = k-2;

fprintf(wri_refmaxID, "\n");
for iter = 1:op_dim
    for iter2 = 1:k
        fprintf(wri_refmaxID, "\t");
    end
    k = k-1;
    fprintf(wri_refmaxID, "end\n");
end
fprintf(wri_refmaxID, "\tc_qual = -c_qual_only_joint;\n");

fprintf(wri_refmaxID, "\nend %%function ends here \n");
fclose(wri_refmaxID);
end
