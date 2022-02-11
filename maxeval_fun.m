function c_qual = maxeval_fun() 
global search_option 
global reward 
global num_prismatic order_prismatic

op_dim = 2; 
c_qual_only_joint = 0;
quality = 1;
skip = 0;
valid_iter = 1;
for eval_alpha1 = 0:0.02:1
	for eval_alpha2 = 0:0.12566:6.2832
		if search_option ~= "tweak"
			search_spacevector = [eval_alpha1, eval_alpha2]; 
		else
			search_spacevector = [eval_alpha1*cos(eval_alpha2), eval_alpha1*sin(eval_alpha2)];
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
