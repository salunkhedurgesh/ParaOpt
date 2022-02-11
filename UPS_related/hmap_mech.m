% clear cnum;
% clear all
% close all
% clc
% % parameters = [1.460027 	1.492489 	0.074953 	1.270403 	-1.592705 	0.207068 	1.406987 	-0.592608 	0.085110 	0.920942 	-0.066873 	0.410076 	3.903761];
% parameters = [1.305506 	0.175931 	0.015756 	0.931778 	-1.507154 	0.058928 	1.312649 	0.999608 	-0.059587 	0.329540 	1.420063 	0.019006 	3.986142];
% parameters = [1         -0.1            0            1         -0.1            0            1       1.4708            0    1       1.4708            0            4];
function [] = hmap_mech(parameters, foldername)
global save_files
path_filename = foldername + "/" + save_files(4);
print2file = fopen(path_filename, 'w');
u11x = parameters(1) * cos(parameters(2));
u11y = parameters(1) * sin(parameters(2));
u11z = parameters(3);

s12x = parameters(4) * cos(parameters(5));
s12y = parameters(4) * sin(parameters(5));
s12z = parameters(6);

u21x = parameters(7) * cos(parameters(8));
u21y = parameters(7) * sin(parameters(8));
u21z = parameters(9);

s22x = parameters(10) * cos(parameters(11));
s22y = parameters(10) * sin(parameters(11));
s22z = parameters(12);

t = parameters(13);
i1 = 1;
i2 = 1;
cum_val = 0;
cum_val_vaf = 0;
elements = 0;
alpha_border = 0.8;
beta_border = 0.8;
for beta = 3 : -0.01 : -3
    for alpha = -3 : 0.01 : 3
        jac_mat = jacobian_inst(parameters, [alpha, beta]);
        ellipsoid_jac = jac_mat' * jac_mat; %because jac_mat mat is J^(-1)
        vaf = eig(ellipsoid_jac);
        S = svd(jac_mat);
        cnum(i1, i2) = min(S)/max(S);
        if min(vaf)< 0.3 || max(vaf)>3
            cnum_vaf(i1,i2) = -norm([min(vaf) - 1; max(vaf) - 1]);
        else
            cnum_vaf(i1,i2) = 1/(1 + norm([min(vaf) - 1; max(vaf) - 1]));
        end
        
        if norm([alpha, beta]) <= 1
            cum_val = cum_val + cnum(i1,i2);
            cum_val_vaf = cum_val_vaf + cnum_vaf(i1,i2);
            elements = elements + 1;
            rdw_points(elements, :) = [i1, i2];
            rdw_angles(elements, :) = [alpha, beta];
            rdw_cnum(elements) = cnum(i1,i2);
            rdw_vaf(elements, :) = cnum_vaf(i1,i2);
        end
        if abs(norm([alpha,beta])- 1) < 0.01
            cnum_vaf(i1,i2) = -1;
            cnum(i1, i2) = 0;
        end
        i2 = i2+1;
    end
    i1 = i1+1;
    i2 = 1;
end
mean_val = cum_val/elements;
cum_variance = 0;
point_vector = zeros(1, 101);
for reloop = 1:elements
    cum_variance = cum_variance + (cnum(rdw_points(reloop,1), rdw_points(reloop, 2)) - mean_val)^2;
    temp_c = floor(rdw_cnum(reloop)*100);
    temp_in = temp_c + 1; % to avoid the zero floor
    point_vector(1, temp_in) = point_vector(1, temp_in) + 1;
end
std_devi = sqrt(cum_variance/elements);

mean_val_vaf = cum_val_vaf/elements;
cum_vaf_variance = 0;
for reloop = 1:elements
    cum_vaf_variance = cum_vaf_variance + (cnum_vaf(rdw_points(reloop,1), rdw_points(reloop, 2)) - mean_val_vaf)^2;
end



std_devi_vaf = sqrt(cum_vaf_variance/elements);

[min_con, min_index] = min(rdw_cnum);
[max_con, max_index] = max(rdw_cnum);
[min_vafmin, vafmin_index] = min(rdw_vaf);
[max_vafmax, vafmax_index] = max(rdw_vaf);
% title_string = ['Heat Map for the conditioning number', ' ', num2str(min_con), ' ', num2str(max_con)];
title_string_report = 'Heat Map for the conditioning number';
h = heatmap(cnum, 'GridVisible','off', 'Colormap',parula, 'title', title_string_report);
set(gca,'FontSize',14, 'FontName', 'CMU Serif')
cdl = h.XDisplayLabels;
size(h.XDisplayLabels)
gap = zeros(1, (size(h.XDisplayLabels, 1) - 1)/12 - 1);
gap_static = repmat(" ",1, size(gap,2));
label_arrayx = [];
label_arrayy = [];
for label_i = -3:0.5:3
    if label_i == 3
        label_arrayx = [label_arrayx, '3'];
    else
        temp_str = string(label_i);
        label_arrayx = [label_arrayx, temp_str, gap_static];
    end
end

for ylabel_i = 3:-0.5:-3
    if ylabel_i == -3
        label_arrayy = [label_arrayy, '-3'];
    else
        temp_stry = string(ylabel_i);
        label_arrayy = [label_arrayy, temp_stry, gap_static];
    end
end
op1 = size(label_arrayx, 1);
op2 = size(label_arrayy, 1);

% Current Display Labels
% h.XDisplayLabels = repmat(' ',size(cdl,1), size(cdl,2));
h.XDisplayLabels = label_arrayx';
h.YDisplayLabels = label_arrayy';


title_string_reportvmin = 'Heat Map for the quality related to VAF';
figure()
vmin_plot = heatmap(cnum_vaf, 'GridVisible','off', 'Colormap',parula, 'title', title_string_reportvmin);
set(gca,'FontSize',14, 'FontName', 'CMU Serif')

vmin_plot.XDisplayLabels = label_arrayx';
vmin_plot.YDisplayLabels = label_arrayy';



fprintf(print2file, "The standard deviation for the conditioning number is %.2f \n", std_devi);
fprintf(print2file, "The mean value for the conditioning number is %.2f \n", mean_val);
fprintf(print2file, "The minimum value of conditioning number is %.3f and the maximum value is %.2f \n", min_con, max_con);
fprintf(print2file, "Minimum cnum configuration at %0.2f, %0.2f \n", rdw_angles(min_index, 1), rdw_angles(min_index, 2));
fprintf(print2file, "Maximum cnum configuration at %0.2f, %0.2f \n", rdw_angles(max_index, 1), rdw_angles(max_index, 2));

fprintf(print2file, "The standard deviation for the VAF number is %.2f \n", std_devi_vaf);
fprintf(print2file, "The mean value for the VAF number is %.2f \n", mean_val_vaf);
fprintf(print2file, "The minimum value for vaf_quality is %.3f \n", min_vafmin);
fprintf(print2file, "Minimum vaf_quality configuration at %0.2f, %0.2f \n", rdw_angles(vafmin_index, 1), rdw_angles(vafmin_index, 2));
fprintf(print2file, "The maximum vaf_quality value is %.2f \n", max_vafmax);
fprintf(print2file, "Maximum vaf_quality configuration at %0.2f, %0.2f \n", rdw_angles(vafmax_index, 1), rdw_angles(vafmax_index, 2));
end