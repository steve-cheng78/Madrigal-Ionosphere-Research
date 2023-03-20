
Millstone2 = readtable('MillstoneISRredo_1976_1985.txt');
unsortedT = Millstone2;
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

% count number of valid rows of TEC and create array of
% each time value
TECrows = 0;
times = [];
timesCnt = 0;
TEC = [];

for i = 1:Trows
    if ~isequaln(T.Var7(i), NaN) && ~isequaln(T.Var4(i), NaN) && ~isequaln(T.Var7(i), 0) && ~isequaln(T.Var4(i), 0) %if valid TEC and time value
        TECrows = TECrows + 1;
        
        if isempty(times) || (~isequaln(T.Var4(i), times(timesCnt)))
            times = cat(1,times,T.Var4(i));
            timesCnt = timesCnt + 1;
            TEC = cat(1,TEC,T.Var7(i));
            
        end
    end
end



% givenmill_mmTEC = movmean(TEC, 50);

% convert unix time to universal time
date = strings(length(times), 1);
for i = 1:length(date)
     date(i) = datestr(times(i)/86400 + datenum(1970,1,1), 'dd-mmm-yyyy HH:MM:SS');
end
% convert date to numerical value for matlab plotting
givenmill_plotDate = datenum(date);

% givenMillstonePlot = plot(givenmill_plotDate, givenmill_mmTEC);
givenMillstonePlot = plot(givenmill_plotDate, TEC);
datetick('x', 'yyyy-mm-dd');
xlim([givenmill_plotDate(1) givenmill_plotDate(end)])
xlabel('Time (UTC)'), ylabel('TEC (m^-^2)');
title('Total Electron Count vs Time, Millstone 1976-2022');
xticks([datenum("1-Jan-1980") datenum("1-Jan-1990") datenum("1-Jan-2000") datenum("1-Jan-2010") datenum("1-Jan-2020")])
%title('Total Electron Count vs Time, Millstone 1970-1984');

