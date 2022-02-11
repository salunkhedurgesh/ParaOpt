function R = rodrig_mat4axis(axis,angle)
  axis_norm = norm(axis(1:3),2);
  axis = axis/axis_norm;
    R = eye(4);
    R(1:3, 1:3) = rodrig_mat3axis(axis, angle);
end
