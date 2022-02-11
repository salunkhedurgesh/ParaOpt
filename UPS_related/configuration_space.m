function [configuration_vector] = configuration_space(parameters, search_spacevector)

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

alpha = search_spacevector(1);
beta = search_spacevector(2);

origin = [0; 0; 0];
in_origin_x = [1; 0; 0];
in_origin_y = [0; 1; 0];
in_origin_z = [0; 0; 1];

in_origin_t = [0; 0; t];

in_origin_u11 = [u11x; u11y; u11z];
in_origin_u21 = [u21x; u21y; u21z];

in_t_s12_initial = [s12x; s12y; s12z];
in_t_s22_initial = [s22x; s22y; s22z];

wrt_origin_T_of_t = trans_mat('z', t) * rot_mat('x', alpha) * rot_mat('y', beta);
wrt_origin_T_of_t_initial = trans_mat('z', t);

in_origin_s12 = wrt_origin_T_of_t * [in_t_s12_initial; 1];
in_origin_s12_initial = wrt_origin_T_of_t_initial * [in_t_s12_initial; 1];

in_origin_s22 = wrt_origin_T_of_t * [in_t_s22_initial; 1];
in_origin_s22_initial = wrt_origin_T_of_t_initial * [in_t_s22_initial; 1];

seg1 = [in_origin_u11';in_origin_s12(1:3)'];
seg2 = [in_origin_u21';in_origin_s22(1:3)'];

collision_dist = seg_dist(seg1, seg2);
[u_joint_x1, s_joint1_x1, s_joint1_z1, s_joint2_x1, s_joint2_z1, rho1] = leg_ikin_UPS(in_origin_t, in_origin_u11, in_origin_s12, in_origin_s12_initial, in_t_s12_initial, alpha, beta);
[u_joint_x2, s_joint1_x2, s_joint1_z2, s_joint2_x2, s_joint2_z2, rho2] = leg_ikin_UPS(in_origin_t, in_origin_u21, in_origin_s22, in_origin_s22_initial, in_t_s22_initial, alpha, beta);

rho_inst = [rho1, rho2];
p_lim_uni = [u_joint_x1, u_joint_x2];
p_lim_sph11 = [s_joint1_x1, s_joint1_z1];
p_lim_sph12 = [s_joint2_x1, s_joint2_z1];
p_lim_sph21 = [s_joint1_x2, s_joint1_z2];
p_lim_sph22 = [s_joint2_x2, s_joint2_z2];

configuration_vector = [p_lim_uni, p_lim_sph11, p_lim_sph12, p_lim_sph21, p_lim_sph22, rho_inst, collision_dist];

end