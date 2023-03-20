% % Finding smallest and largest altitude ranges
% % for NEL at individual times
% 
% unsortedT = readtable('sondrestromFullSet.txt');
% T = sortrows(unsortedT, 4); %sort based on time
% Trows = height(T);
% 
% % count number of valid rows of NEL and create array of
% % each time value
% NELrows = 0;
% times = [];
% timesCnt = 0;
% 
% for i = 1:Trows
%     if ~isequaln(T.Var1(i), NaN) && ~isequaln(T.Var1(i), 0) && ~isequaln(T.Var4(i), 0) && ~isequaln(T.Var4(i), NaN)  %if valid NEL and time value
%         NELrows = NELrows + 1;
%         
%         if isempty(times) || (~isequaln(T.Var4(i), times(timesCnt)))
%             times = cat(1,times,T.Var4(i));
%             timesCnt = timesCnt + 1;
%             
%         end
%     end
% end
% 
% % create array of number of NEL values at each
% % specific time
% numTimes = [];
% numNELatTime = 0;
% thisTime = 1;
% for i = 1:length(T.Var4)
%     if T.Var4(i) == times(thisTime)  %%equal to current time
%        if ~isequaln(T.Var1(i), NaN) && ~isequaln(T.Var1(i), 0)
%            numNELatTime = numNELatTime + 1;
%        end
%     elseif ~isequaln(T.Var4(i), 0) && ~isequaln(T.Var4(i), NaN)  %%equal to next time
%         numTimes = cat(1,numTimes,numNELatTime);
%         thisTime = thisTime + 1;
%         if ~isequaln(T.Var1(i), NaN) && ~isequaln(T.Var1(i), 0)
%             numNELatTime = 1;
%         else
%             numNELatTime = 0;
%         end
%     end
% end
% numTimes = cat(1,numTimes,numNELatTime);
%         
% 
% NEL = zeros(NELrows, 1);
% GDALT = zeros(NELrows, 1);
% % fill arrays of zeros with valid NEL values
% % and corresponding GDALT values
% NELcnt = 1;
% 
% for i = 1:Trows
%     if ~isequaln(T.Var1(i), NaN) && ~isequaln(T.Var1(i), 0) && ~isequaln(T.Var3(i), NaN) && ~isequaln(T.Var3(i), 0)
%         NEL(NELcnt) = T.Var1(i);
%         GDALT(NELcnt) = T.Var3(i);
%         NELcnt = NELcnt + 1;      
%     end
% end

altRanges = zeros(length(numTimes),3);
segBegin = 1;
% find GDALT range at each time
for i = 1:length(numTimes)
    if numTimes(i) ~= 1
        segEnd = segBegin + numTimes(i) - 1;
        unsortedNE = [GDALT(segBegin:segEnd) NE(segBegin:segEnd)];
        sortedNE = sortrows(unsortedNE, 1);         %sort based on GDALT in order
        altRanges(i,1) = sortedNE(1,1);             % min altitude at each time
        altRanges(i,2) = sortedNE(length(sortedNE),1); %max altitude at each time
        altRanges(i,3) = sortedNE(length(sortedNE),1) - sortedNE(1,1);  %range of altitudes at each time
        segBegin = segBegin + numTimes(i);
    end
end

maxAltRange = max(altRanges);       %largest min altitude, largest max altitude, largest range
minAltRange = min(altRanges);       %smallest min altitude, smallest max altitude, smallest range
