function hoverShowProf (~, ~, ax, sideProfile, sideProfPts, xData, T)

C = get(ax, 'CurrentPoint');
Cdate = num2ruler(C(1),ax.XAxis);

ind = find(abs(Cdate-xData) == min(abs(Cdate-xData)));

z = 100:10:500;
H = 50;

NE = sortrows(T(T.time == xData(ind),:), "gdalt");

[x, ia] = unique(NE.gdalt);
NE = NE(ia,:);
% NOTE: only takes first element of unique altitude data.
% previous code averaged same altitude data.

[Nmax, I] = max(NE.nel);
z0 = x(I);
[estimated_guess, N] = ChapmanFit(NE.nel, x, z, z0, Nmax, H);

sideProfile.XData = N;
sideProfile.YData = z;
sideProfPts.XData = NE.nel;
sideProfPts.YData = NE.gdalt;
sideProfile.Parent.XLabel.String = 'Electron density (Ne in m-3)';
sideProfile.Parent.YLabel.String = 'Altitude (km)';
timeStr = xData(ind);%datestr(pt(1), 'dd-mmm-yyyy HH:MM:SS');
timeStrtxt = string(timeStr);
sideProfile.Parent.Title.String = 'Profile w/ Chapman Fit at ' + timeStrtxt;


end % <--- optional if this is embedded into a function
