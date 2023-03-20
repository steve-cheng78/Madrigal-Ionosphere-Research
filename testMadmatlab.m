% demo program of madmatlab running on a pc or linux

madurl = 'http://millstonehill.haystack.mit.edu';

cgiurl = getMadrigalCgiUrl(madurl);

disp('List all instruments, and their latitudes and longitudes:');
instArray = getInstrumentsWeb(cgiurl);
for i = 1:length(instArray)
    disp(instArray(i));
    if i > 3
         break;
    end
end
disp('now list all experiments from local Madrigal site with mlh (code 30) in');
disp('1998 - should be data if default files installed...');
startdate = datenum('01/01/1998');
enddate = datenum('12/31/1998');
expArray = getExperimentsWeb(cgiurl, 30, startdate, enddate, 1);
for i = 1:length(expArray)
    disp(expArray(i));
end

disp('now list all files in the first experiment');
expFileArray = getExperimentFilesWeb(cgiurl, expArray(1).id);
for i = 1:length(expFileArray)
     disp(expFileArray(i));
end
disp('now first 2 parameters in the last file');
parmArray = getParametersWeb(cgiurl, expFileArray(end).name);
for i = 1:10
    disp(parmArray(i));
end
disp('run isprintWeb for that file for first two parameters');
parmStr = sprintf('%s,%s', parmArray(1).mnemonic, parmArray(2).mnemonic);
data = isprintWeb(cgiurl, expFileArray(1).name, parmStr, 'Bill Rideout', 'wrideout@haystack.mit.edu', 'MIT');
% print first 10 records
disp(data(:,:,1:10));

% download that data file in simple format

Tempdir = tempdir;
Tempdir = addSlash(Tempdir);
disp(Tempdir);

result = madDownloadFile(cgiurl, expFileArray(1).name, append(Tempdir, 'junk.hdf5'), 'Bill Rideout', 'brideout@haystack.mit.edu', 'MIT', 'hdf5');
disp('downloaded file to (tempdir)/junk.hdf5');

% run globalIsprint, which can gather data from multiple files at once
globalIsprint(madurl, ...
              'year,month,day,hour,min,sec,gdalt,dte,te', ...
              fullfile(tempdir,'isprint.txt'), ...
              'Bill Rideout', 'brideout@haystack.mit.edu', 'MIT', ...
              datenum('20-Jan-1998 00:00:00'), datenum('21-Jan-1998 23:59:59'), 30);
disp('globalIsprint output saved to (tempdir)/isprint.txt');

% run globalDownload, which can download multiple files at once
globalDownload(madurl, ...
                         Tempdir, ...
                         'Bill Rideout', ...
                         'brideout@haystack.mit.edu', ...
                         'MIT', ...
                         'ascii', ...
                         datenum('20-Jan-1998 00:00:00'), ...
                         datenum('21-Jan-1998 23:59:59'), ...
                         30);
disp('globalDownload saved files to tempdir');

% madCalculatorWeb runs the Madrigal derivation engine for any point
data = madCalculatorWeb(cgiurl, datenum(1999,2,15,12,30,0), 45,55,5,-170,-150,10,200,2.0E+3,10.0,'sdwht,kp');
disp('madCalculator output');
% print data
disp(data);

disp('The following is an example of searching for non-local experiments');
% 61 is the instrument id of Poker Flat ISR - so this will return an
% experiment not from the Millstone Madrigal site
startdate = datenum('04/01/2008');
enddate = datenum('04/30/2008');
expArray = getExperimentsWeb(cgiurl, 61, startdate, enddate, 0);
disp(cgiurl);

% calling this now would fail: expFileArray = getExperimentFilesWeb(cgiurl, expArray(1).id);
% Instead, get the cgiurl of the non-local experiment
 if (expArray(1).isLocal == 0)
      cgiurl = getMadrigalCgiUrl(expArray(1).madrigalUrl);
%     cgiurl = getCgiurlForExperiment(expArray(1));     **Turns out to be the same as line above
      disp(cgiurl);
      expArray = getExperimentsWeb(cgiurl, 61, startdate, enddate, 0);
 end

% now you can get the files
expFileArray = getExperimentFilesWeb(cgiurl, expArray(1).id);
for i = 1:length(expFileArray)
    [s,errmsg] = sprintf('File name: %s, with kindat %i', ...
            expFileArray(i).name, ...
            expFileArray(i).kindat);
     disp(s);
end

          