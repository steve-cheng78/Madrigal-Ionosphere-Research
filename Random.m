
TEC = zeros(length(numTimes), 1);
segBegin = 1;
z = 100:10:500;
H = 50;
% integrate GDALT vs. NE for TEC values
for i = 1:length(numTimes)
    if numTimes(i) ~= 1
        segEnd = segBegin + numTimes(i) - 1;
        unsortedNE = [GDALT(segBegin:segEnd) NE(segBegin:segEnd)];
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

%         if length(x) >= 3
%             vq = interp1(x,v,xq,'linear','extrap');
%         end
        
        [Nmax,I] = max(v);
        z0 = x(I);
        
        [estimated_guess,N] = ChapmanFit(v,x,z,z0,Nmax,H);


        if trapz(z,N) < 10^15
            TEC(i) = trapz(z,N);
        end
        
            
%         if (TEC(i) > 6e15)
%             disp("outlier at ");
%             disp(times(i));
%         end
        segBegin = segBegin + numTimes(i);
    end
end

mmTEC = movmean(TEC, 250);

% convert unix time to universal time
date = strings(length(times), 1);
for i = 1:length(date)
     date(i) = datestr(times(i)/86400 + datenum(1970,1,1), 'dd-mmm-yyyy HH:MM:SS');
end
% convert date to numerical value for matlab plotting
plotDate = datenum(date);

plot(plotDate, mmTEC);
datetick('x', 'yyyy-mm-dd');
xlim([plotDate(1) plotDate(end)])
xlabel('Time (UTC)'), ylabel('TEC (m^-^2)');
title('Total Electron Count vs Time, Millstone 1964-2021');
%title('Total Electron Count vs Time, Millstone 1970-1984');

