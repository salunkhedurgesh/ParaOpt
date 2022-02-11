function mat = eqr(vec_a, vec_b)

vec_a = vec_a(1:3);
vec_b = vec_b(1:3);
tilt_angle = acos(dot(vec_a, vec_b)/(norm(vec_a, 2) * norm(vec_b, 2)));
tilt_axis = cross(vec_a, vec_b);

if norm(tilt_axis) == 0
    tilt_axis = vec_a;
end

mat = rodrig_mat3axis(tilt_axis, tilt_angle);

end
