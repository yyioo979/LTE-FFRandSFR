function fair = fair( num )
%FAIR Summary of this function goes here
%   Detailed explanation goes here
fair=(sum(num(:)))^2/(length(num)*sum(num(:).^2));

end

