% Generates profile of points clicked on TEC graph

function showProfileFcn(~, event, profTimes, T)
% Inputs:
%  hObj (unused) the axes
%  event: info about mouse click
% OUTPUT
%  none
pt = event.IntersectionPoint;
profileTime = datetime(pt(1),'ConvertFrom','posixtime');
disp("profileTime: " + string(profileTime))
% ind = find(profTimes == profileTime)
ind = find(abs(profTimes - profileTime) == min(abs(profTimes - profileTime)));
disp("index: " + num2str(ind))
seg = T.time == profTimes(ind);
NE = sortrows(T(seg,:), "gdalt");

z = 100:10:500;
H = 50;

[x, ia] = unique(NE.gdalt);
NE = NE(ia,:);

[Nmax, I] = max(NE.nel);
z0 = x(I);

[estimated_guess, N] = ChapmanFit(NE.nel, x, z, z0, Nmax, H);

% chapParams(i,:) = estimated_guess;

figure
plot(N,z)
xlabel('Electron density (Ne in m-3)'), ylabel('Altitude (km)')
timeStr = datestr(pt(1), 'dd-mmm-yyyy HH:MM:SS');
timeStrtxt = string(timeStr);
title('Profile w/ Chapman Fit at ' + timeStrtxt)

hold on
scatter(NE.nel,NE.gdalt)

end
