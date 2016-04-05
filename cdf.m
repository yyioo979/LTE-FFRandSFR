function cd = cdf( ms1_data )
%CDF Summary of this function goes here
%   输入一维数组，返回统计函数，第1行为数值，第2行为数量，第3行为比例
num=0;
unum=0;
for x=-10:2:50
    unum=0;
    num=num+1;
    cd(1,num)=x;
    for k=1:length(ms1_data)
        if ms1_data(k)<=x
            unum=unum+1;
        end
    end
    cd(2,num)=unum;
    cd(3,num)=unum/length(ms1_data);
end

