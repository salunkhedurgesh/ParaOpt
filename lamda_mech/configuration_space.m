function [configuration_vector] = configuration_space(parameters, search_spacevector)

theta = search_spacevector(1);

l2 = 1;
l1 = parameters(1);

rho_inst = sqrt(l1^2 + l2^2-2*l1*l2*cos(theta));

configuration_vector = rho_inst;

end