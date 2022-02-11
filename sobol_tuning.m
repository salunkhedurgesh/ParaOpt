% Description: Generating the initial simplexes for all the multi starts
% Inputs:
% 1. ranges of the parameters in matrix of (n x 2)
% 2. number of multi starts (positive integer)
% 3. the output space range in form of m x 3 matrix
% Outpus:
% 1. Initial simplex for all multi starts

function S = sobol_tuning()

global ranges starts opspace shrink_times
n = size(ranges, 1);
val = (n+1)*starts;
p = sobolset(n,'Skip',1e3,'Leap',1e2);
p = scramble(p,'MatousekAffineOwen');
S = zeros(val,n);
shrink_times = 0;

%This loop is because the sobolset generates many points from
% the given range of the parameters but we want those points that have no
% singularity curves in the defined output workspace

i = 1;
j = 1;
par_inst = zeros(1,n);
write_sing(opspace);
open_permit = 0;

while(j<=val)
    for par = 1:n
        par_inst(par) = ranges(par, 1) + p(i,par)*(ranges(par, 2) - ranges(par, 1));
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
    
    if i > j*1000
        shrink_times = shrink_times + 1;
        if shrink_times > 3
            fprintf(2, 'unable to generate the valid points, that is, <strong>cannot find</strong> enough points that are <strong>non-singular even in 25%% range of bounds of the output space</strong> consider:\n<strong>1. Giving better ranges of the parameters</strong>\n');
            fprintf(2, '<strong>2. Check definition of the mechanism and output of jacobian_inst.m</strong> \n')
            open_permit = 1;
        end       
        write_sing(opspace);
    end
    
end
end
