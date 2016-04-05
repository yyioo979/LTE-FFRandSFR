function index = findpf(pf_num,pf_level,pf_tout,tpf)
%FINDPF Summary of this function goes here
%   Detailed explanation goes here
index(1,1:length(pf_num))=pf_num;%第一行num,第二行level
index(2,1:length(pf_level))=pf_level(1,:);
index(3,1:length(pf_level))=pf_level(2,:);%第三行判断
a=pf_tout./pf_level(1,:);
[max_level,ind]=max(a);
if index(3,ind)==0
    index(1,ind)=index(1,ind)+1;
    index(2,ind)=index(2,ind)+1/tpf*max_level;
    index(3,ind)=1;
else
    a(ind)=[];
    [max_level,ind]=max(a);
    index(1,ind)=index(1,ind)+1;
    index(2,ind)=index(2,ind)+1/tpf*max_level;
    index(3,ind)=1;
end
end

