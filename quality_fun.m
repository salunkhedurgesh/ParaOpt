function quality = quality_fun(jac_mat)

global objective_choice VelocityAmplification_range
global n
if n > 1
    ellipsoid_jac = jac_mat' * jac_mat; %because jac_mat mat is J^(-1)
    vaf = eig(ellipsoid_jac);
    a1 = norm(jac_mat);
    a2 = norm(inv(jac_mat));
    conditioning_num = 1/(a1 * a2);
elseif n == 1
    vaf = jac_mat;
    conditioning_num = jac_mat;
end

if min(vaf)< VelocityAmplification_range(1) || max(vaf)>VelocityAmplification_range(2)
    %     cnum_vaf = -norm([min(vaf) - 1; max(vaf) - 1]);
    cnum_vaf = 0; %This is an issue, I need to figure out,
    %What is the issue?
    %When I assign negative value, I am punishing and not rewarding less
    %This is an issue as the c_qual changes sign as if it is invalid
else
    cnum_vaf = 1/(1 + norm([min(vaf) - 1; max(vaf) - 1]));
end
% quality_indices = [conditioning_num, min(vaf), max(vaf)];

if objective_choice == 1 || objective_choice == 2
    quality = conditioning_num;
elseif objective_choice == 3
    quality = cnum_vaf;
end