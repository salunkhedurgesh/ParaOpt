% seg1 -> 2x3 matrix representing 2 points in 3d
% seg2 -> 2x3 matrix representing 2 points in 3d

function dist = seg_dist(seg1, seg2)

% seg1 = [u11x, u11y, u11z; 
%         s12x, s12y, s12z];
%     
% seg2 = [u21x, u21y, u21z; 
%         s22x, s22y, s22z];
    iter = 1;
    step = 5;
    for i = 0:step
        for j = 0:step
            for k = 1:3
                point_seg1(k) = seg1(1, k) + (seg1(2, k) - seg1(1, k))*i/step;                      
                point_seg2(k) = seg2(1, k) + (seg2(2, k) - seg2(1, k))*j/step;
            end
            
            dist_vec(iter) = norm(point_seg1-point_seg2, 2);

            iter = iter + 1;
        end
    end
    
    dist = min(dist_vec);
end