%以下為解4qam調制的子函數
function output=de_map4(input)
         [m,n]=size(input);
         output=zeros(2*m,n);
         for j=1:n
           for i=1:m
           y=de_qam4(input(i,j));
           for ic=1:2
               output(2*(i-1)+ic,j)=y(ic);
           end
       end
   end
