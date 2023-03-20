function [newDir] = addSlash(dir)
% addSlash adds an extra backslash as needed so that directories
% can be used in Matlab
%
% Prevents the escaped character error.

% For example: 
% C:\Users\cheng\AppData\Local\Temp\
% becomes
% C:\\Users\\cheng\\AppData\\Local\\Temp\\
%

slashCnt = 0;
for i = 1:length(dir)
    if dir(i) == '\'
        slashCnt = slashCnt + 1;
    end
end

for i = 1:(length(dir)+slashCnt)
    if dir(i) == '\' && dir(i - 1) ~= '\'
        dir = append(dir(1:i), dir(i:end));
    end
end

newDir = dir;
end

