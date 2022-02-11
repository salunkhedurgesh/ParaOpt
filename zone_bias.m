function [zone] = zone_bias(search_space)

global opspace 
op_mean = zeros(1, size(opspace, 1));
op_span = zeros(1, size(opspace, 1));
for range_iter1 = 1:size(opspace, 1)
    op_mean(range_iter1) = opspace(range_iter1, 1) + (opspace(range_iter1, 2) - opspace(range_iter1, 1))/2;
    op_span(range_iter1) = opspace(range_iter1, 2) - opspace(range_iter1, 1);
end

global search_option

if search_option == "tweak"
    if norm(search_space) < 0.25
        zone = 4;
    elseif norm(search_space) < 0.5
        zone = 3;
    elseif norm(search_space) < 0.75
        zone = 2;
    else
        zone = 1;
    end
    return
end

zone1_limits = [op_mean - op_span/8; op_mean + op_span/8];
zone2_limits = [op_mean - op_span/4;  op_mean + op_span/4];
zone3_limits = [op_mean - 3*op_span/8;  op_mean + 3*op_span/8];


if search_space >= zone1_limits(1,:)
    if search_space <= zone1_limits(2,:)
        zone = 4;
        return
    end
end

if search_space >= zone2_limits(1,:)
    if search_space <= zone2_limits(2,:)
        zone = 3;
        return
    end
end

if search_space >= zone3_limits(1,:)
    if search_space <= zone3_limits(2,:)
        zone = 2;
        return
    end
end

zone = 1;


end