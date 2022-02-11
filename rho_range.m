function [rho_rangemat] = rho_range(parameters) 


global order_prismatic search_option
run_iter1 = 1;
for rho_alpha1 = 0:0.02:1
	for rho_alpha2 = 0:0.12566:6.2832
		if search_option ~= "tweak"
			search_spacevector = [rho_alpha1, rho_alpha2]; 
		else
			search_spacevector = [rho_alpha1*cos(rho_alpha2), rho_alpha1*sin(rho_alpha2)];
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
