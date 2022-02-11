 function R = rot_mat(axis,angle)
    if axis == 'x'
        R = [1, 0 , 0, 0;
             0, cos(angle), -sin(angle), 0;
             0, sin(angle), cos(angle), 0;
             0,0,0,1];
    elseif axis == 'y'
        R = [cos(angle), 0, sin(angle), 0;
             0, 1, 0, 0;
             -sin(angle), 0, cos(angle), 0;
             0, 0, 0, 1];
    elseif axis == 'z'
         R = [cos(angle), -sin(angle), 0, 0;
             sin(angle), cos(angle), 0, 0;
             0, 0, 1, 0;
             0, 0, 0, 1];
    else
        fprintf('Invalid input - check the axis or angle');
    end
end
