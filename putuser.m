function user = putuser( user_num,r )
%PUTUSER Summary of this function goes here
%   Detailed explanation goes here
for k=1:user_num
    uangle=rand(1,1)*2*pi;
      if (uangle>pi/3 && uangle<2*pi/3) || (uangle>4*pi/3 && uangle<5*pi/3)
        axis_angle=uangle-pi/3;
    elseif (uangle>2*pi/3 && uangle<pi) || (uangle>5*pi/3 && uangle<2*pi)
        axis_angle=uangle-2*pi/3;
    else
        axis_angle=uangle;
    end
    udistance=sqrt(3)*r/(2*sin(pi/3+axis_angle));
    ulength=rand(1,1)*abs(udistance);
    if ulength>=r
        ulength=r;
    end
    user(1,k)=ulength*exp(i*uangle);
end
end

