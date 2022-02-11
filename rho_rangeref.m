function [rho_rangemat] = rho_rangeref(parameters) 


global order_prismatic search_option
run_iter1 = 1;
for refrho_alpha1 = 0:0.01:1
	for refrho_alpha2 = 0:0.1:6.2832
		if search_option ~= "tweak"
			search_spacevector = [refrho_alpha1, refrho_alpha2]; 
		else
			search_spacevector = [refrho_alpha1*cos(refrho_alpha2), refrho_alpha1*sin(refrho_alpha2)];
		end
		[configuration_vector] = configuration_space(parameters, search_spacevector);
		rho_instmat(run_iter1, 1:length(order_prismatic)) = configuration_vector(order_prismatic);
		run_iter1 = run_iter1 + 1;

	end 
end 
for stor_iter = 1:size(rho_instmat, 2)
	rho_rangemat(stor_iter, 1) = min(rho_instmat(:, stor_iter));
	rho_rangemat(stor_iter, 2) = max(rho_instmat(:, stor_iter));
end

end %function ends here 
