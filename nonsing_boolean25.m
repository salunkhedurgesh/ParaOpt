function [det_boolean] = nonsing_boolean25(parameters) 

op_dim = 3; 
cen_jac_mat = jacobian_inst(parameters, [0  0  0]); 
cen_det = det(inv(cen_jac_mat)); 
global search_option 
det_boolean = 1; 

for sing_alpha1 = -0.125:0.01:0.125
	for sing_alpha2 = -0.125:0.01:0.125
		for sing_alpha3 = -0.19635:0.01:0.19635
			if search_option ~= "tweak"
				search_spacevector = [sing_alpha1, sing_alpha2, sing_alpha3]; 
			else
				search_spacevector = [sing_alpha1*cos(sing_alpha2), sing_alpha1*sin(sing_alpha2)];
			end
			[jac_mat] = jacobian_inst(parameters, search_spacevector); 
			if abs(det(inv(jac_mat))) < 5e-3 || det(inv(jac_mat))*cen_det < 0
				det_boolean = 0; 
				break 
			end
		end 
	end 
end 

end %function ends here 
