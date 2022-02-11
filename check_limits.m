function [limit_boolean] = check_limits(configuration_vector)
global limits

limit_boolean = 1;
for lim_iter = 1:size(limits, 1)
    if limits(lim_iter, 1) ~= 0 && limits(lim_iter, 2) ~= 0
        if configuration_vector(lim_iter) < limits(lim_iter, 1) || configuration_vector(lim_iter) > limits(lim_iter, 2)
            limit_boolean = 0;
            return
        end
    end
end

end