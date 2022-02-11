function [c_qual, rho_vec] = prismatic_optimisation(parameters, valid_points_vec, c_qual_only_joint, refine_var)

global stroke opspace num_prismatic

if refine_var == 0
total_rho = rho_range(parameters);
else
total_rho = rho_rangeref(parameters);
end

if max(total_rho(:,2)) > stroke*min(total_rho(:,1))
    %Maximizing the valid points by applying the actuator limits
    j = 1;
    stroke_step = 3;
    xmin_step = ((max(total_rho(:,2))/stroke) - min(total_rho(:,1)))/stroke_step;
    
    for x_min = min(total_rho(:,1)):xmin_step:max(total_rho(:,2))/stroke
        c_qual_temp = 0; %initializing the value to calculate cumulative quality
        total_valid_points = 0; %initializing the value to calculate total number of valid points
        for i = 1:size(valid_points_vec, 1)
            pris_vec = valid_points_vec(i, size(opspace, 1) +1 : size(opspace, 1) + num_prismatic);
            if pris_vec < x_min
                %If any instance(alpha,beta) does not satisfy actuator length,
                %then skip that iteration and evaluate the quality as '0'
                continue;
            elseif pris_vec > stroke*x_min
                %If any instance(alpha,beta) does not satisfy actuator length,
                %then skip that iteration and evaluate the quality as '0'
                continue;
            end
            c_qual_temp = c_qual_temp + valid_points_vec(i, size(valid_points_vec, 2));
            total_valid_points = total_valid_points + 1;
        end
        c_qual_mat(j,1:3) = [c_qual_temp, x_min total_valid_points];
        j = j+1;
    end
    
    [c_qual,act_index] = max(c_qual_mat(:,1));
    c_qual = -c_qual;
    rho_vec_min = c_qual_mat(act_index,2);    
    rho_vec = [rho_vec_min, rho_vec_min*stroke];
else
    c_qual = -c_qual_only_joint;
    rho_vec = [min(total_rho(:,1)), max(total_rho(:, 2))];
end

end