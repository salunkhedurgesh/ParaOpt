function t = trans_mat(axis,value)

   if axis == 'x'
       t = [1, 0, 0, value; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1];
   elseif axis == 'y'
       t = [1, 0, 0, 0; 0, 1, 0, value; 0, 0, 1, 0; 0, 0, 0, 1];
   elseif axis == 'z'
        t = [1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, value; 0, 0, 0, 1];
   else
       fprintf('Invalid input - check the axis or the value');
   end
end
