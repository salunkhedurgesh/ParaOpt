function [] = write_maxeval()
global coarse coarse_steps opspace num_prismatic reward

temp_opspace = opspace;
global prismatic

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

wri_maxID = fopen('maxeval_fun.m', 'w');
fprintf(wri_maxID, "function c_qual = maxeval_fun() \n");
fprintf(wri_maxID, "global search_option \n");
if reward ~= "plain"
    fprintf(wri_maxID, "global reward \n");
end
if prismatic == 1
    fprintf(wri_maxID, "global num_prismatic order_prismatic\n\n");
end

fprintf(wri_maxID, "op_dim = %i; \n", op_dim);
fprintf(wri_maxID, "c_qual_only_joint = 0;\n");
fprintf(wri_maxID, "quality = 1;\n");
fprintf(wri_maxID, "skip = 0;\n");
fprintf(wri_maxID, "valid_iter = 1;\n");

%%% Start of FOR LOOP %%%
for iter = 1:op_dim
    fprintf(wri_maxID, "for " + string(obj_var(iter)) + " = " + string(temp_opspace(iter, 1)) + ":" + string(temp_opspace(iter, 3)) + ":" + string(temp_opspace(iter, 2)) + "\n");
    for iter2 = 1:k
        fprintf(wri_maxID, "\t");
    end
    k = k+1;
end

fprintf(wri_maxID, "if search_option ~= ""tweak""\n");
tab_nec(op_dim+2, wri_maxID);
fprintf(wri_maxID, "search_spacevector = [");
for funaut_iter1 = 1:op_dim
    fprintf(wri_maxID, string(obj_var(funaut_iter1)));
    if funaut_iter1 == op_dim
        fprintf(wri_maxID, "]; \n");
    else
        fprintf(wri_maxID, ", ");
    end
end
tab_nec(op_dim+1, wri_maxID);
fprintf(wri_maxID, "else\n");
tab_nec(op_dim+2, wri_maxID);
fprintf(wri_maxID, "search_spacevector = [");
fprintf(wri_maxID, string(obj_var(1)));
fprintf(wri_maxID, "*cos(");
fprintf(wri_maxID, string(obj_var(2)));
fprintf(wri_maxID, "), ");

fprintf(wri_maxID, string(obj_var(1)));
fprintf(wri_maxID, "*sin(");
fprintf(wri_maxID, string(obj_var(2)));
fprintf(wri_maxID, ")];\n");
tab_nec(op_dim+1, wri_maxID);
fprintf(wri_maxID, "end\n");


%%% Checking the quality function %%%
tab_nec(op_dim+1, wri_maxID);
fprintf(wri_maxID, "exg_qual = 1;\n");
if reward ~= "plain"
    tab_nec(op_dim+1, wri_maxID);
    fprintf(wri_maxID, "exg_qual = 5*quality; %%Exaggerated quality to differentiate between results better\n");
    
    %%% Biased reward function %%%
    tab_nec(op_dim+1, wri_maxID);
    fprintf(wri_maxID, "if reward == ""biased"" \n");
    tab_nec(op_dim+2, wri_maxID);
    fprintf(wri_maxID, "zone = zone_bias(search_spacevector);\n");
    tab_nec(op_dim+2, wri_maxID);
    fprintf(wri_maxID, "exg_qual = zone*exg_qual;\n");
    tab_nec(op_dim+1, wri_maxID);
    fprintf(wri_maxID, "elseif reward == ""min_quality"" \n");
    tab_nec(op_dim+2, wri_maxID);
    fprintf(wri_maxID, "zone = zone_bias(search_spacevector);\n");
    tab_nec(op_dim+2, wri_maxID);
    fprintf(wri_maxID, "if zone < 4\n");
    tab_nec(op_dim+3, wri_maxID);
    fprintf(wri_maxID, "if quality < 0.3\n");
    tab_nec(op_dim+4, wri_maxID);
    fprintf(wri_maxID, "invalid_points = invalid_points + 1;\n");
    tab_nec(op_dim+4, wri_maxID);
    fprintf(wri_maxID, "continue;\n");
    tab_nec(op_dim+3, wri_maxID);
    fprintf(wri_maxID, "end\n");
    tab_nec(op_dim+2, wri_maxID);
    fprintf(wri_maxID, "end\n");
    tab_nec(op_dim+1, wri_maxID);
    fprintf(wri_maxID, "end\n");
end

tab_nec(op_dim+1, wri_maxID);
fprintf(wri_maxID, "if skip == 1\n");
tab_nec(op_dim+2, wri_maxID);
fprintf(wri_maxID, "continue\n");
tab_nec(op_dim+1, wri_maxID);
fprintf(wri_maxID, "end\n");

tab_nec(op_dim+1, wri_maxID);
fprintf(wri_maxID, "valid_iter = valid_iter + 1;\n");
tab_nec(op_dim+1, wri_maxID);
fprintf(wri_maxID, "c_qual_only_joint = c_qual_only_joint + exg_qual;\n");

%%% Start of END loop %%%
k = k-2;

fprintf(wri_maxID, "\n");
for iter = 1:op_dim
    for iter2 = 1:k
        fprintf(wri_maxID, "\t");
    end
    k = k-1;
    fprintf(wri_maxID, "end\n");
end
fprintf(wri_maxID, "\tc_qual = -c_qual_only_joint;\n");

fprintf(wri_maxID, "\nend %%function ends here \n");
fclose(wri_maxID);
end
