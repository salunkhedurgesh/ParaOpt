function R = rodrig_mat3axis(axis,angle)
  axis_norm = norm(axis(1:3),2);
  axis = axis/axis_norm;
    R = [cos(angle) + (axis(1)^2)*(1-cos(angle)), axis(1)*axis(2)*(1 - cos(angle)) - axis(3)*sin(angle), axis(2)*sin(angle) + axis(1)*axis(3)*(1- cos(angle));
         axis(1)*axis(2)*(1 - cos(angle)) + axis(3)*sin(angle), cos(angle) + (axis(2)^2)*(1-cos(angle)), -axis(1)*sin(angle) + axis(2)*axis(3)*(1- cos(angle));
         -axis(2)*sin(angle) + axis(1)*axis(3)*(1- cos(angle)), axis(2)*axis(3)*(1 - cos(angle)) + axis(1)*sin(angle), cos(angle) + (axis(3)^2)*(1-cos(angle))];
end
