% Linear interpolation of a single profile in the
% Sondrestrom data

close all
xq = 150:10:500;

segBegin = 1;
for i = 1:length(numTimes)
    if numTimes(i) ~= 1
        segEnd = segBegin + numTimes(i) - 1;
        
        if i==22101 || i==12547 || i==439 || i==2148
            unsortedNE = [GDALT(segBegin:segEnd) NE(segBegin:segEnd)];
            sortedNE = sortrows(unsortedNE, 1);         %sort based on GDALT in order
            
            perAlt = 1;
            jBeg = 1;       %need these for indexing for Mvec
            jEnd = 1;
            x = [];
            v = [];
            for j = 2:length(sortedNE)
                if sortedNE(j,1) - sortedNE(j-1,1) <= 1
                    perAlt = perAlt + 1;
                    jEnd = jEnd + 1;
                else  %%Problem: last one
                    Mvec = sortedNE(jBeg:jEnd, 2);
                    NeAvg = mean(Mvec);
                    perAlt = 1;
                    jEnd = jEnd + 1;
                    jBeg = jEnd;
                    x = cat(1,x,sortedNE(j-1,1));
                    v = cat(1,v,NeAvg);
                end
            end
            Mvec = sortedNE(jBeg:jEnd, 2);
            NeAvg = mean(Mvec);
            x = cat(1,x,sortedNE(length(sortedNE),1));
            v = cat(1,v,NeAvg);
                
            
            vq = interp1(x,v,xq,'linear','extrap');
            
            GMTdate = datestr(times(i)/86400 + datenum(1970,1,1), 'dd-mmm-yyyy HH:MM:SS');
         
            figure;
            plot(v,x,'o',vq,xq,':.');
            xlabel('Electron Density (Ne in m-3)'), ylabel('Altitude (km)');
            title(strcat('Ne vs. Alt w/ Linear Interpolation (', GMTdate, ')'));
            
        end
        
        segBegin = segBegin + numTimes(i);
    end
end

