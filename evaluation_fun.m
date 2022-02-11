function [c_qual,rho_vec] = evaluation_fun(parameters) 
global search_option 
global reward 
global num_prismatic order_prismatic force_valid

op_dim = 2; 
c_qual_only_joint = 0;
rho_vec = [0, 0];
cen_jac_mat = jacobian_inst(parameters, [0, 0]); 
cen_det = det(inv(cen_jac_mat)); 
valid_iter = 1; 
skip = 0; 
invalid_points = 0;  

for eval_alpha1 = 0:0.02:1
	for eval_alpha2 = 0:0.12566:6.2832
		if search_option ~= "tweak"
			search_spacevector = [eval_alpha1, eval_alpha2]; 
		else
			search_spacevector = [eval_alpha1*cos(eval_alpha2), eval_alpha1*sin(eval_alpha2)];
		end
		[configuration_vector] = configuration_space(parameters, search_spacevector);
		[jac_mat] = jacobian_inst(parameters, search_spacevector); 
		if abs(det(inv(jac_mat))) < 5e-3 || det(inv(jac_mat))*cen_det < 0
			skip = 1;
			invalid_points = invalid_points + 1;
		end
		exg_qual = 1;
		quality = quality_fun(jac_mat);
		exg_qual = 5*quality; %Exaggerated quality to differentiate between results better
		if reward == "biased" 
			zone = zone_bias(search_spacevector);
			exg_qual = zone*exg_qual;
		elseif reward == "min_quality" 
			zone = zone_bias(search_spacevector);
			if zone < 4
				if objective_choice == 2
					if quality < 0.3
						invalid_points = invalid_points + 1;
						continue;
					end
				elseif objective_choice == 3
					if quality <= 0
						invalid_points = invalid_points + 1;
						continue;
					end
				end
			end
		end
		if skip == 1
			continue
		end
		limit_pass = check_limits(configuration_vector);
		if limit_pass == 0
			continue
		end

		rho_inst = zeros(1, num_prismatic);
		for funaut_iter2 = 1:num_prismatic
			rho_inst(funaut_iter2) = configuration_vector(order_prismatic(funaut_iter2));
		end
		valid_points_vec(valid_iter,1:5) = [search_spacevector, rho_inst, exg_qual];
		valid_iter = valid_iter + 1;
		c_qual_only_joint = c_qual_only_joint + exg_qual;

	end
end
if (skip ~= 1 || force_valid == 1) && valid_iter > 1 
	[c_qual, rho_vec] = prismatic_optimisation(parameters, valid_points_vec, c_qual_only_joint, 0);
elseif skip == 0 
	c_qual = -c_qual_only_joint;
else 
	c_qual = invalid_points;
end


end %function ends here 
