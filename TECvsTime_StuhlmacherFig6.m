% Script to recreate Anna Stuhlmacher's figure (6)
% from Progress Report 7-30

close all

unsortedT = readtable('sondrestromFullSet.txt');
T = sortrows(unsortedT, 4); %sort based on time
Trows = height(T);

% count number of valid rows of NEL and create array of
% each time value
NELrows = 0;
times = [];
timesCnt = 0;

for i = 1:Trows
    if ~isequaln(T.Var1(i), NaN) && ~isequaln(T.Var1(i), 0) && ~isequaln(T.Var4(i), 0) && ~isequaln(T.Var4(i), NaN)  %if valid NEL and time value
        NELrows = NELrows + 1;
        
        if isempty(times) || (~isequaln(T.Var4(i), times(timesCnt)))
            times = cat(1,times,T.Var4(i));
            timesCnt = timesCnt + 1;
            
        end
    end
end

% create array of number of NEL values at each
% specific time
numTimes = [];
numNELatTime = 0;
thisTime = 1;
for i = 1:length(T.Var4)
    if T.Var4(i) == times(thisTime)  %%equal to current time
       if ~isequaln(T.Var1(i), NaN) && ~isequaln(T.Var1(i), 0)
           numNELatTime = numNELatTime + 1;
       end
    elseif ~isequaln(T.Var4(i), 0) && ~isequaln(T.Var4(i), NaN)  %%equal to next time
        numTimes = cat(1,numTimes,numNELatTime);
        thisTime = thisTime + 1;
        if ~isequaln(T.Var1(i), NaN) && ~isequaln(T.Var1(i), 0)
            numNELatTime = 1;
        else
            numNELatTime = 0;
        end
    end
end
numTimes = cat(1,numTimes,numNELatTime);
numTimes = [numTimes, times];
        

NEL = zeros(NELrows, 1);
GDALT = zeros(NELrows, 1);
% fill arrays of zeros with valid NEL values
% and corresponding GDALT values
NELcnt = 1;

for i = 1:Trows
    if ~isequaln(T.Var1(i), NaN) && ~isequaln(T.Var1(i), 0) && ~isequaln(T.Var3(i), NaN) && ~isequaln(T.Var3(i), 0)
        NEL(NELcnt) = T.Var1(i);
        GDALT(NELcnt) = T.Var3(i);
        NELcnt = NELcnt + 1;      
    end
end

% Reverse the log_10 for NE
NE = 10 .^ NEL;

TEC = zeros(length(numTimes), 1);
segBegin = 1;
xq = 150:10:500;
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

        vq = interp1(x,v,xq,'linear','extrap');
           
        
%         firstAlt = 0;
%         lastAlt = 0;
%         for j = 1:length(sortedNE)          %truncate altitudes
%             if sortedNE(j,1) > 155 && sortedNE(j,1) <= 165
%                 firstAlt = j;
%                 break
%             end
%         end
%         for j = 1:length(sortedNE)
%             if sortedNE(j,1) >= 455 && sortedNE(j,1) < 465
%                 lastAlt = j;
%             end
%         end
%         
%         if firstAlt >= 1 && lastAlt >= 1
%             sortedNE = sortedNE(firstAlt:lastAlt, :);
%
%             TEC(i) = trapz(sortedNE(:, 1), sortedNE(:, 2));        %integrate
%         else
%             TEC(i) = NaN;                  %exclude outliers
%         end

        TEC(i) = trapz(xq,vq);
            
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
xlabel('Time (UTC)'), ylabel('TEC (m^-^2)');
title('Total Electron Count vs Time, Sondrestrom 1984-2014');

