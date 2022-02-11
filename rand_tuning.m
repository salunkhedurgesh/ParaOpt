% Description: Generating the initial simplexes for all the multi starts
% Inputs:
% 1. type of the mechanism
% 2. ranges of the parameters in matrix of (n x 2)
% 3. number of multi starts
% None
% Outpus:
% 1. Initial simplex for all multi starts

function S = rand_tuning()
global ranges starts opspace shrink_times
n = size(ranges, 1);
val = (n+1)*starts;
p = rand(val*1000, n);
fprintf('Generating points using random function \n');

S = zeros(val,n);
shrink_times = 0;

% This loop is because the random function generates many points from
% the given range of the parameters but we want those points that have no
% singularity curves in the defined output workspace

i = 1;
j = 1;
par_inst = zeros(1,n);

write_sing(opspace);
open_permit = 0;

while(j<=val)
    for par = 1:n
        par_inst(par) = ranges(par, 1) + p(i, par)*(ranges(par, 2) - ranges(par, 1));
    end
    if shrink_times == 0 || open_permit == 1
        sing_bool = nonsing_boolean(par_inst);
    elseif shrink_times == 1
        sing_bool = nonsing_boolean75(par_inst);
    elseif shrink_times == 2
        sing_bool = nonsing_boolean50(par_inst);
    elseif shrink_times == 3
        sing_bool = nonsing_boolean25(par_inst);
    end
    if sing_bool == 1 || open_permit == 1
        S(j,:) = par_inst;
        j = j+1;
    end
    i = i+1;
    
    if i > size(p(:,1))
        shrink_times = shrink_times + 1;
        if shrink_times > 3
            fprintf(2, 'unable to generate the valid points, that is, <strong>cannot find</strong> enough points that are <strong>non-singular even in 25%% range of bounds of the output space</strong> consider:\n<strong>1. Giving better ranges of the parameters</strong>\n');
            fprintf(2, '<strong>2. Check definition of the mechanism and output of jacobian_inst.m</strong> \n')
            open_permit = 1;
        end
        my_opspace = opspace;
        shrink_by = [0.75, 0.5, 0.25];
        my_opspace(:, 1:2) =  shrink_by(shrink_times)*opspace(:, 1:2);
        for fun_raniter1 = 1: size(opspace, 1)
            if opspace(fun_raniter1, 3) > 0.1*(my_opspace(fun_raniter1, 2) - my_opspace(fun_raniter1, 1))
                res_fac = (opspace(fun_raniter1, 2) - opspace(fun_raniter1, 1))/opspace(fun_raniter1, 3);
                my_opspace(fun_raniter1, 3) = (my_opspace(fun_raniter1, 2) - my_opspace(fun_raniter1, 1))/res_fac;
            end
        end
        write_sing(my_opspace);
        
    end
    
end
end
