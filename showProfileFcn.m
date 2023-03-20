% Generates profile of points clicked on TEC graph

function showProfileFcn(hObj, event, profTimes, profSegs, GDALT, NE)
% Inputs:
%  hObj (unused) the axes
%  event: info about mouse click
% OUTPUT
%  none
pt = event.IntersectionPoint;
profileTime = (pt(1) - datenum(1970,1,1))*86400;
disp("profileTime: ")
disp(profileTime)
% ind = find(profTimes == profileTime)
ind = find(abs(profTimes - profileTime) == min(abs(profTimes - profileTime)));
disp("index: ")
disp(ind)

segBegin = profSegs(ind,1);
segEnd = profSegs(ind,2);
unsortedNE = [GDALT(segBegin:segEnd) NE(segBegin:segEnd)];
sortedNE = sortrows(unsortedNE, 1);         %sort based on GDALT in order

% TEC = zeros(length(numTimes), 1);
% chapParams = zeros(length(numTimes),3);
z = 100:10:500;
H = 50;

% average values at very close/same altitudes
% then interpolate
perAlt = 1;
jBeg = 1;       %need these for indexing for Mvec
jEnd = 1;
x = [];     %vector of non-repeating altitudes
v = [];     %vector of averaged Ne's
for j = 2:length(sortedNE)
    if sortedNE(j,1) - sortedNE(j-1,1) <= 1 %group similar altitudes
        perAlt = perAlt + 1;
        jEnd = jEnd + 1;
    else
        Mvec = sortedNE(jBeg:jEnd, 2);  %average Ne of similar altitudes
        NeAvg = mean(Mvec);
        perAlt = 1;
        jEnd = jEnd + 1;
        jBeg = jEnd;
        x = cat(1,x,sortedNE(j-1,1));
        v = cat(1,v,NeAvg);
    end
end

Mvec = sortedNE(jBeg:jEnd, 2);  %does same as above else for last segment
NeAvg = mean(Mvec);
x = cat(1,x,sortedNE(length(sortedNE),1));
v = cat(1,v,NeAvg);

[Nmax,I] = max(v);
z0 = x(I);

[estimated_guess,N] = ChapmanFit(v,x,z,z0,Nmax,H);

% chapParams(i,:) = estimated_guess;


% TEC(i) = trapz(z,N);

% date(i) = datestr(times(i)/86400 + datenum(1970,1,1), 'dd-mmm-yyyy HH:MM:SS');
figure
plot(N,z)
xlabel('Electron density (Ne in m-3)'), ylabel('Altitude (km)')
timeStr = datestr(pt(1), 'dd-mmm-yyyy HH:MM:SS');
timeStrtxt = string(timeStr);
title('Profile w/ Chapman Fit at ' + timeStrtxt)


end % <--- optional if this is embedded into a function