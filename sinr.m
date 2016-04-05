function sr = sinr( ms_test_power )
%SINR Summary of this function goes here
%   Detailed explanation goes here
l=length(ms_test_power);
total=0;
for k=2:l
    total=total+dbmtop(ms_test_power(k));
end
sr=10*log10(dbmtop(ms_test_power(1))/total);
end