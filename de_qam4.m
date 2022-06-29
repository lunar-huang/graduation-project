%以下為把4qam調制的信號还原的子函數
function y=de_qam4(x)     
   y=real(x);
   y1=imag(x);
    if         (y>=0)     y=1;
       else                     y=-1;
   end
   if         (y1>=0)   y1=1;
       else                     y1=-1;
    end
    x=complex(y,y1);
    if        x==1+j      y=[0 0];
      elseif  x==1-j      y=[0 1];
      elseif  x==-1+j     y=[1 0];
      elseif  x==-1-j     y=[1 1];

    end
