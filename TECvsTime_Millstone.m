%INCOMPLETE DATASET???

Millstone1 = readtable('MillstoneISRredo_1961_1975.txt');
unsortedT = Millstone1;
clear Millstone1
Millstone2 = readtable('MillstoneISRredo_1976_1985.txt');
unsortedT = [unsortedT; Millstone2];
clear Millstone2
Millstone3 = readtable('MillstoneISRredo_1986_1995.txt');
unsortedT = [unsortedT; Millstone3];
clear Millstone3
Millstone4 = readtable('MillstoneISRredo_1996_2010.txt');
unsortedT = [unsortedT; Millstone4];
clear Millstone4
Millstone5 = readtable('MillstoneISRredo_2011_2022.txt');
unsortedT = [unsortedT;Millstone5];
clear Millstone5
T = sortrows(unsortedT, 4); %sort based on time
clear unsortedT
Trows = height(T);

% count number of valid rows of NEL and create array of
% each time value
NELrows = 0;
profTimes = [];
timesCnt = 0;

for i = 1:Trows
    if ~isequaln(T.Var1(i), NaN) && ~isequaln(T.Var4(i), NaN) && ~isequaln(T.Var1(i), 0) && ~isequaln(T.Var4(i), 0) %if valid NEL and time value
        NELrows = NELrows + 1;
        
        if isempty(profTimes) || (~isequaln(T.Var4(i), profTimes(timesCnt)))
            profTimes = cat(1,profTimes,T.Var4(i));
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
    if T.Var4(i) == profTimes(thisTime)  %%equal to current time
       if ~isequaln(T.Var1(i), NaN) && ~isequaln(T.Var1(i), 0)
           numNELatTime = numNELatTime + 1;
       end
    elseif ~isequaln(T.Var1(i), NaN) && ~isequaln(T.Var1(i), 0) && ~isequaln(T.Var4(i), 0) && ~isequaln(T.Var4(i), NaN)  %%equal to next time
            numTimes = cat(1,numTimes,numNELatTime);
            thisTime = thisTime + 1;
            numNELatTime = 1;
    end
end
numTimes = cat(1,numTimes,numNELatTime);
numTimes = [numTimes, profTimes];
        

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
profSegs = zeros(length(numTimes),2);
profSegs(1,1) = segBegin;
z = 100:10:500;
H = 50;
% integrate GDALT vs. NE for TEC values
for i = 1:length(numTimes)
    if numTimes(i) ~= 1
        segEnd = segBegin + numTimes(i) - 1;
        profSegs(i,2) = segEnd;
        
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
        
    end
    segBegin = segBegin + numTimes(i);
    profSegs(i+1,1) = segBegin;

end

% mill_mmTEC = movmean(TEC, 250);

% convert unix time to universal time
date = strings(length(profTimes), 1);
for i = 1:length(date)
     date(i) = datestr(profTimes(i)/86400 + datenum(1970,1,1), 'dd-mmm-yyyy HH:MM:SS');
end
% convert date to numerical value for matlab plotting
mill_plotDate = datenum(date);

% millstonePlot = plot(mill_plotDate, mill_mmTEC);
millstonePlot = plot(mill_plotDate, TEC);

set(millstonePlot,'HitTest','off')
set(gca,'ButtonDownFcn',{@showProfileFcn, profTimes, profSegs, GDALT,...
    NE})
datetick('x', 'yyyy','keeplimits');
% xlim([mill_plotDate(1) mill_plotDate(end)])
xlabel('Time (UTC)'), ylabel('TEC (m^-^2)');
title('Total Electron Count vs Time, Millstone 1964-2021');

%Shows x-coordinate of point being hovered over
t = annotation('textbox');
t.Position = [0.72 0.78 0.15 0.09];
hold on
pnt = scatter(mill_plotDate(1),TEC(1),'HitTest','off');
vert = xline(mill_plotDate(1),'LineStyle',"--",'HitTest','off');
set(gcf, 'WindowButtonMotionFcn', {@hoverShowCoord, t, pnt, vert, date, mill_plotDate, TEC});


