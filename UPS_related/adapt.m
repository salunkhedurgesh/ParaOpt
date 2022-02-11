function mat = adapt(inmat)
mat = eye(4);
mat(1:3, 1:3) = inmat;
end