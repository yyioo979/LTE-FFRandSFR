function tout = throughout(SINR,slot_include,T_frame)
%THROUGHOUT Summary of this function goes here
%   Detailed explanation goes here
if SINR < -3.14
    tout=0;
elseif SINR >= -3.14 && SINR < -0.73
    tout=slot_include*(2*1/12)/T_frame;
elseif SINR >= -0.73 && SINR < 2.09
    tout=slot_include*(2*1/6)/T_frame;
elseif SINR >= 2.09 && SINR < 4.75
    tout=slot_include*(2*1/3)/T_frame;
elseif SINR >= 4.75 && SINR <7.86
    tout=slot_include*(2*1/2)/T_frame;   
elseif SINR >= 7.86 && SINR < 9.94
    tout=slot_include*(2*2/3)/T_frame;    
elseif SINR >= 9.94 && SINR < 13.45
    tout=slot_include*(2*1/2)/T_frame; 
elseif SINR >= 13.45 && SINR < 18.6
    tout=slot_include*(2*2/3)/T_frame;    
elseif SINR >= 18.6 && SINR < 24.58
    tout=slot_include*(2*2/3)/T_frame;    
elseif SINR >= 24.58
    tout=slot_include*(2*5/6)/T_frame;    
end
end

