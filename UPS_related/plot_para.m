function [u11, u21, s12, s22, h1_point, h2_point, t_point, x_plus, x_minus, y_plus, y_minus] = plot_para(parameters, alpha, beta)

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


s12_mobile = [s12x; s12y; s12z];
s22_mobile = [s22x; s22y; s22z];

fixed_T_mobile = trans_mat('z', t)*rot_mat('x', alpha)*rot_mat('y', beta);
h1_point = fixed_T_mobile*[0;0;s12z;1];
h2_point = fixed_T_mobile*[0;0;s22z;1];
t_point = fixed_T_mobile*[0;0;0;1];
s12 = fixed_T_mobile*[s12_mobile;1];
s22 = fixed_T_mobile*[s22_mobile;1];
u11 = [u11x, u11y, u11z];
u21 = [u21x, u21y, u21z];

%The universal joint
x_minus = fixed_T_mobile*[-0.2;0;0;1];
x_plus = fixed_T_mobile*[0.2;0;0;1];
y_minus = fixed_T_mobile*[0;-0.2;0;1];
y_plus = fixed_T_mobile*[0;0.2;0;1];

end
