%refer to whereOutliers array for profNum's of outliers

function [estimated_guess,N] = viewProfile(profNum,profileSegs,GDALT,NE,times)

z = 100:10:500;
H = 50;

unsortedNE = [GDALT(profileSegs(profNum,1):profileSegs(profNum,2)) NE(profileSegs(profNum,1):profileSegs(profNum,2))];
sortedNE = sortrows(unsortedNE, 1);         %sort based on GDALT in order
        
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

figure
plot(N,z,':.',v,x,'o');
xlabel('Electron Density (Ne in m-3)'), ylabel('Altitude (km)');

if exist('times','var')
    GMTdate = datestr(times(profNum)/86400 + datenum(1970,1,1), 'dd-mmm-yyyy HH:MM:SS');
    title(strcat('Ne vs. Alt w/ Chapman Interpolation (', GMTdate, ')')); 
else
    title(strcat('Ne vs. Alt w/ Chapman Interpolation'));
end



 