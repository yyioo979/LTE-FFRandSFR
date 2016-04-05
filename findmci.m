function index = findmci(SINR,num)
%FINDMCI Summary of this function goes here
%   Detailed explanation goes here
[~,a]=sort(SINR,'descend');
index=a(1,1:num);
end

