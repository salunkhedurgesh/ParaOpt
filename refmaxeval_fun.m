function c_qual = refmaxeval_fun() 
global search_option 
global reward 
global num_prismatic order_prismatic

op_dim = 2; 
c_qual_only_joint = 0;
quality = 1;
skip = 0;
valid_iter = 1;
for refeval_alpha1 = 0:0.01:1
	for refeval_alpha2 = 0:0.1:6.2832
		if search_option ~= "tweak"
			search_spacevector = [refeval_alpha1, refeval_alpha2]; 
		else
			search_spacevector = [refeval_alpha1*cos(refeval_alpha2), refeval_alpha1*sin(refeval_alpha2)];
		end
		exg_qual = 1;
		exg_qual = 5*quality; %Exaggerated quality to differentiate between results better
		if reward == "biased" 
			zone = zone_bias(search_spacevector);
			exg_qual = zone*exg_qual;
		elseif reward == "min_quality" 
			zone = zone_bias(search_spacevector);
			if zone < 4
				if quality < 0.3
					invalid_points = invalid_points + 1;
					continue;
				end
			end
		end
		if skip == 1
			continue
		end
		valid_iter = valid_iter + 1;
		c_qual_only_joint = c_qual_only_joint + exg_qual;

	end
end
	c_qual = -c_qual_only_joint;

end %function ends here 
