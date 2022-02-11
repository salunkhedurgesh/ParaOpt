function [u_joint_x, s_joint1_x, s_joint1_z, s_joint2_x, s_joint2_z, rho] = leg_ikin_UPS(in_origin_t, in_origin_u, in_origin_s, in_origin_s_initial, in_t_s12_initial, alpha, beta)

in_origin_x = [1; 0; 0];
% in_origin_y = [0; 1; 0];
in_origin_z = [0; 0; 1];
in_origin_u11 = in_origin_u;
in_origin_s12 = in_origin_s(1:3);
in_origin_s12_initial = in_origin_s_initial(1:3);

u11x = in_origin_u11(1);
u11y = in_origin_u11(2);
u11z = in_origin_u11(3);

% Now, we know [u11, u21, s12, s22] in the origin frame. So, it is time to
% calculate the actuators' length

rho = norm(in_origin_s12 - in_origin_u11);

% Now, we need to calculate the orientation of u11 in the default
% configuration

% The universal joint is defined such that the z-axis of the u11's frame is
% along the actuator and y-axis perp(in_origin_z, actuator)

% So, let's understand the universal joint's (u11) frame:
% wrt_origin_z_in_u11 = in_origin(s12 - u11)
% wrt_origin_y_in_u11 = wrt_origin_z_in_u11 X in_origin_z
% wrt_origin_x_in_u11 = in_u11(y X z)

wrt_origin_z_in_u11 = in_origin_s12_initial - in_origin_u11;
wrt_origin_y_in_u11 = cross(wrt_origin_z_in_u11, in_origin_z);
if norm(wrt_origin_y_in_u11) == 0
    wrt_origin_y_in_u11 = cross(wrt_origin_z_in_u11, in_origin_u11);
end

u11_align_tilt_mat = eqr(wrt_origin_z_in_u11, in_origin_z);

% The torsion angle is calculated in the frame that has been tilted
% The torsion axis in this frame is [0; 0; 1]

torsion_align_vec1_u11 = [0; 1; 0]; % As we need to align the y-axis in this frame with the y-axis of the spherical joint
torsion_align_vec2_u11 = transpose(u11_align_tilt_mat) * wrt_origin_y_in_u11;

u11_align_torsion_axis = cross(torsion_align_vec1_u11, torsion_align_vec2_u11);
if norm(abs(u11_align_torsion_axis)/norm(u11_align_torsion_axis) - [0; 0; 1]) > 0.00001
    if norm(u11_align_torsion_axis) ~= 0
        fprintf("Torsion axis of the universal joint may be a problem, check IKIN for %.2d, %.2d\n", alpha, beta);
    end
end

u11_align_torsion_mat = eqr(torsion_align_vec1_u11, torsion_align_vec2_u11);

wrt_origin_T_of_u11 = trans_mat('x', u11x) * trans_mat('y', u11y) * trans_mat('z', u11z) * adapt(u11_align_tilt_mat) * adapt(u11_align_torsion_mat);

wrt_u11_T_of_origin = inv(wrt_origin_T_of_u11);
wrt_u11_s12 = wrt_u11_T_of_origin(1:3,1:3) * (in_origin_s12 - in_origin_u11);

% Now, to calculate the tilt_angle of the universal joint for aligning with
% the current spherical joint position

tilt_vec1_u11 = [0; 0; 1]; % it is wrt_u11_z_of_u11
tilt_vec2_u11 = wrt_u11_s12(1:3);

u11_tilt_mat = eqr(tilt_vec1_u11, tilt_vec2_u11);

check_uni = wrt_origin_T_of_u11 * adapt(u11_tilt_mat) * trans_mat('z', rho) * [0; 0; 0; 1];
if norm(in_origin_s12 - check_uni(1:3)) > 0.00001
    fprintf("Unable to reach s12 : mistake in universal joint itself");
end
% Orientation of the spherical joint with respect to the universal joint

wrt_origin_x_of_s12_initial = in_origin_t - in_origin_s12_initial;
wrt_s12_unrot_x_of_s12_unrot = [-1; 0; 0];

wrt_origin_T_of_s12_unrot = wrt_origin_T_of_u11 * adapt(u11_tilt_mat) * trans_mat('z', rho);
wrt_s12_unrot_T_of_origin = inv(wrt_origin_T_of_s12_unrot);

wrt_s12_unrot_x_of_s12_initial = wrt_s12_unrot_T_of_origin(1:3, 1:3) * wrt_origin_x_of_s12_initial;


% s12_align_tilt_mat = rodrig_mat3axis(s12_align_tilt_axis, s12_align_tilt_angle);

s12_align_tilt_mat = eqr(wrt_s12_unrot_x_of_s12_unrot(1:3), wrt_s12_unrot_x_of_s12_initial(1:3));

torsion_align_vec1_s12 = [0; 1; 0]; % As we need to align the y-axis in this frame with the y-axis of the spherical joint
temp_vec = cross((in_origin_t - in_origin_s12_initial), in_origin_t);
torsion_align_vec2_s12 = transpose(s12_align_tilt_mat) * wrt_s12_unrot_T_of_origin(1:3, 1:3) * temp_vec;

s12_align_torsion_axis = cross(torsion_align_vec1_s12, torsion_align_vec2_s12(1:3));
if norm(s12_align_torsion_axis) < 0.00001
    s12_align_torsion_axis = [1; 0; 0];
end
if norm(abs(s12_align_torsion_axis)/norm(s12_align_torsion_axis) - [1; 0; 0]) > 0.00001
    if norm(s12_align_torsion_axis) < 0.00001
        fprintf("Torsion axis of the spherical joint may be a problem, check IKIN for %.2f and %.2f \n", alpha, beta);
    end
end
% s12_align_torsion_angle = torsion_angle(torsion_align_vec1_s12, torsion_align_vec2_s12);

s12_align_torsion_mat = eqr(torsion_align_vec1_s12(1:3), torsion_align_vec2_s12(1:3));

wrt_origin_T_of_s12 = wrt_origin_T_of_s12_unrot * adapt(s12_align_tilt_mat) * adapt(s12_align_torsion_mat);
wrt_s12_T_of_origin = inv(wrt_origin_T_of_s12);

tilt_vec1_s12 = [-norm(in_t_s12_initial, 2); 0; 0];
temp_vec2 = in_origin_t - in_origin_s12;
tilt_vec2_s12 = wrt_s12_T_of_origin(1:3, 1:3) * temp_vec2;

% s12_tilt_axis = cross(tilt_vec1_s12, tilt_vec2_s12);
% s12_tilt_angle = tilt_angle(tilt_vec1_s12, tilt_vec2_s12);

s12_tilt_mat = eqr(tilt_vec1_s12, tilt_vec2_s12);
wrt_origin_T_of_s5 = wrt_origin_T_of_s12 * adapt(s12_tilt_mat);
wrt_s5_T_of_origin = inv(wrt_origin_T_of_s5);
check_vec_wo_last_angle = wrt_origin_T_of_s5 * [-norm(in_t_s12_initial, 2); 0; 0; 1];

if norm(check_vec_wo_last_angle(1:3) - in_origin_t) > 0.00001
    warning("Wrong IKIN, error in one of the first 5 angles\n");
end

s12_torsion_vec1 = [0; 1; 0]; % Because we need to align the y-axis now
temp_vec3 = cross((in_origin_t - in_origin_s12), in_origin_t);
s12_torsion_vec2 = wrt_s5_T_of_origin(1:3, 1:3) * temp_vec3;

s12_torsion_axis = cross(s12_torsion_vec1, s12_torsion_vec2(1:3));
if norm(abs(s12_torsion_axis)/norm(s12_torsion_axis) - [1; 0; 0]) > 0.00001
    if norm(s12_torsion_axis) > 0.00001
        fprintf("Error in s12 torsion axis\n");
    end
end
% s12_torsion_angle = torsion_angle(s12_torsion_vec1, s12_torsion_vec2);

s12_torsion_mat = eqr(s12_torsion_vec1, s12_torsion_vec2);

% wrt_origin_T_for_t_loop = wrt_origin_T_of_s5 * adapt(s12_torsion_mat) * trans_mat('x', -norm(in_t_s12_initial, 2));

p_lim_u1 = 1;
p_lim_s1 = 1;
p_lim_s2 = 1;

u_joint_x = u11_tilt_mat * in_origin_x;
u_joint_z = u11_tilt_mat * in_origin_z;
u_joint_x = u_joint_x(2);
u_joint_z = u_joint_z(2);

s_joint1_x = s12_tilt_mat * in_origin_x;
s_joint1_z = s12_tilt_mat * in_origin_z;
s_joint1_x = s_joint1_x(2);
s_joint1_z = s_joint1_z(2);

s_joint2_x = s12_tilt_mat * s12_torsion_mat * in_origin_x;
s_joint2_z = s12_tilt_mat * s12_torsion_mat * in_origin_z;
s_joint2_x = s_joint2_x(2);
s_joint2_z = s_joint2_z(2);

end