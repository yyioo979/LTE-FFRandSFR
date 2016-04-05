function ls = loss(distance)
%LOSS Summary of this function goes here
%   Detailed explanation goes here
MHz=2000;
ls=20*log10(distance/1000)+20*log10(MHz)-28+randn+0.1*normrnd(0,6);
end

