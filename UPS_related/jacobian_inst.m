%%% det_mat is the "inversejacobian" %%%
function [jac_mat] = jacobian_inst(parameters, search_space)

% Inverse kinematics of "2UPS - 1U" with SS-joint and spherical orientation
% such that all the joints are in their default alignment (zero rotation)
% when alpha = 0 and beta = 0 (the home position of the mechanism)

% Through the 13 parameters, we know:
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

alpha = search_space(1);
beta = search_space(2);
j11 = (2*sign(u11y - s12y*cos(alpha) + s12z*cos(beta)*sin(alpha) - s12x*sin(beta)*sin(alpha))*abs(u11y - s12y*cos(alpha) + s12z*cos(beta)*sin(alpha) - s12x*sin(beta)*sin(alpha))*(s12y*sin(alpha) + s12z*cos(beta)*cos(alpha) - s12x*sin(beta)*cos(alpha)) + 2*abs(t - u11z + s12y*sin(alpha) + s12z*cos(beta)*cos(alpha) - s12x*sin(beta)*cos(alpha))*sign(t - u11z + s12y*sin(alpha) + s12z*cos(beta)*cos(alpha) - s12x*sin(beta)*cos(alpha))*(s12y*cos(alpha) - s12z*cos(beta)*sin(alpha) + s12x*sin(beta)*sin(alpha)))/(2*(abs(t - u11z + s12y*sin(alpha) + s12z*cos(beta)*cos(alpha) - s12x*sin(beta)*cos(alpha))^2 + abs(s12x*cos(beta) - u11x + s12z*sin(beta))^2 + abs(u11y - s12y*cos(alpha) + s12z*cos(beta)*sin(alpha) - s12x*sin(beta)*sin(alpha))^2)^(1/2));
j12 = -(2*abs(t - u11z + s12y*sin(alpha) + s12z*cos(beta)*cos(alpha) - s12x*sin(beta)*cos(alpha))*sign(t - u11z + s12y*sin(alpha) + s12z*cos(beta)*cos(alpha) - s12x*sin(beta)*cos(alpha))*(s12x*cos(beta)*cos(alpha) + s12z*sin(beta)*cos(alpha)) - 2*abs(s12x*cos(beta) - u11x + s12z*sin(beta))*sign(s12x*cos(beta) - u11x + s12z*sin(beta))*(s12z*cos(beta) - s12x*sin(beta)) + 2*sign(u11y - s12y*cos(alpha) + s12z*cos(beta)*sin(alpha) - s12x*sin(beta)*sin(alpha))*abs(u11y - s12y*cos(alpha) + s12z*cos(beta)*sin(alpha) - s12x*sin(beta)*sin(alpha))*(s12x*cos(beta)*sin(alpha) + s12z*sin(beta)*sin(alpha)))/(2*(abs(t - u11z + s12y*sin(alpha) + s12z*cos(beta)*cos(alpha) - s12x*sin(beta)*cos(alpha))^2 + abs(s12x*cos(beta) - u11x + s12z*sin(beta))^2 + abs(u11y - s12y*cos(alpha) + s12z*cos(beta)*sin(alpha) - s12x*sin(beta)*sin(alpha))^2)^(1/2));
j21 = (2*sign(u21y - s22y*cos(alpha) + s22z*cos(beta)*sin(alpha) - s22x*sin(beta)*sin(alpha))*abs(u21y - s22y*cos(alpha) + s22z*cos(beta)*sin(alpha) - s22x*sin(beta)*sin(alpha))*(s22y*sin(alpha) + s22z*cos(beta)*cos(alpha) - s22x*sin(beta)*cos(alpha)) + 2*abs(t - u21z + s22y*sin(alpha) + s22z*cos(beta)*cos(alpha) - s22x*sin(beta)*cos(alpha))*sign(t - u21z + s22y*sin(alpha) + s22z*cos(beta)*cos(alpha) - s22x*sin(beta)*cos(alpha))*(s22y*cos(alpha) - s22z*cos(beta)*sin(alpha) + s22x*sin(beta)*sin(alpha)))/(2*(abs(t - u21z + s22y*sin(alpha) + s22z*cos(beta)*cos(alpha) - s22x*sin(beta)*cos(alpha))^2 + abs(s22x*cos(beta) - u21x + s22z*sin(beta))^2 + abs(u21y - s22y*cos(alpha) + s22z*cos(beta)*sin(alpha) - s22x*sin(beta)*sin(alpha))^2)^(1/2));
j22 = -(2*abs(t - u21z + s22y*sin(alpha) + s22z*cos(beta)*cos(alpha) - s22x*sin(beta)*cos(alpha))*sign(t - u21z + s22y*sin(alpha) + s22z*cos(beta)*cos(alpha) - s22x*sin(beta)*cos(alpha))*(s22x*cos(beta)*cos(alpha) + s22z*sin(beta)*cos(alpha)) - 2*abs(s22x*cos(beta) - u21x + s22z*sin(beta))*sign(s22x*cos(beta) - u21x + s22z*sin(beta))*(s22z*cos(beta) - s22x*sin(beta)) + 2*sign(u21y - s22y*cos(alpha) + s22z*cos(beta)*sin(alpha) - s22x*sin(beta)*sin(alpha))*abs(u21y - s22y*cos(alpha) + s22z*cos(beta)*sin(alpha) - s22x*sin(beta)*sin(alpha))*(s22x*cos(beta)*sin(alpha) + s22z*sin(beta)*sin(alpha)))/(2*(abs(t - u21z + s22y*sin(alpha) + s22z*cos(beta)*cos(alpha) - s22x*sin(beta)*cos(alpha))^2 + abs(s22x*cos(beta) - u21x + s22z*sin(beta))^2 + abs(u21y - s22y*cos(alpha) + s22z*cos(beta)*sin(alpha) - s22x*sin(beta)*sin(alpha))^2)^(1/2));

jac_mat = [j11, j12; j21, j22];

end
