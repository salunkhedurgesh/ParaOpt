%%% det_mat is the "inversejacobian" %%%
function [jac_mat] = jacobian_inst(parameters, search_spacevector)

l2 = 1;
l1 = parameters(1);
theta = search_spacevector(1);

rho_inst = sqrt(l1^2 + l2^2-2*l1*l2*cos(theta));

jac_mat =  l1*l2*sin(theta)/rho_inst;

end
