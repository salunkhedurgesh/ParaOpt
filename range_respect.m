% function name: range_respect()
% Description: Checking for the generated points for range
% Inputs:
% 1. Input point
% 2. ranges of parameters
% Outpus:
% 1. the point synthesized for right ranges

function return_point = range_respect(in_point,ranges)
    
    n = size(ranges, 1);
    for i = 1:n
        if in_point(i) < ranges(i,1)
            in_point(i) = ranges(i,1);
        elseif in_point(i) > ranges(i,2)
            in_point(i) = ranges(i,2);
        end
    end
    return_point = in_point;
end