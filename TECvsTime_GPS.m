% Universial TECvsTime function
function TECvsTime_GPS(data_folder, figname, compound_ds)
    arguments
      data_folder (1,1) string
      
      figname (1,1) string
      
      % default value is raw Madrigal file layout
      compound_ds (1,1) string = "/Data/Table Layout"
      
      
    end

%% load entire data folder, can take large amount of RAM

files = dir(data_folder + "/*.hdf5");
T.time = [];
T.tec = [];

for k=1:length(files)
    
    data_file = data_folder + '/' + files(k).name;
    
    tic
    try
        raw = h5read(data_file, compound_ds);
    catch
        disp(data_file)
    end

    T.time = [T.time; datetime(1970, 1, 1, 0, 0, 0) + seconds(raw.ut1_unix)];
    T.tec = [T.tec; raw.tec];

    clear('raw')
%     TECvsTime_file(data_file, compound_ds);
end

T = struct2table(T);
% Matlab h5read only reads entire compound dataset.
% Python h5py trivially reads invididual fields of compound dataset.

%% sorting
T = sortrows(T, "time");
disp("Loaded and sorted data in " + num2str(toc, "%.1f") + " seconds.")

%% count number of valid rows of NEL and create array of each time value
goodRows = ~isnan(T.tec) & ~isnat(T.time);
T = T(goodRows,:);

%% Graphing

%find Chapman fit outliers in the profiles
% [outliers,whereOutliers] = chapOutliers(chapParams);
mmTEC = movmean(T.tec, 250);

figure
fig = gcf;
ax = gca;
plt = plot(T.time, mmTEC);
datetick('x', 'yyyy-mm-dd');
xlabel('Time (UTC)'), ylabel('TEC (m^-^2)');
title(figname);
fig.OuterPosition = [200 38 900 500];

%Shows x-coordinate of point being hovered over
txt = annotation('textbox');
txt.Position = [0.72 0.78 0.15 0.09];
txt.String = ["Time: " + datestr(T.time(1)), "TEC: " + sprintf('%.4e',mmTEC(1))];
hold on
pnt = scatter(T.time(1), mmTEC(1), 'HitTest', 'off');
vert = xline(T.time(1), 'LineStyle', "--", 'HitTest', 'off');

set(fig, 'WindowButtonMotionFcn', {@hoverShowCoord, ax, txt, pnt, vert, T.time, mmTEC})

saveas(fig, figname, 'fig')
saveas(fig, figname, 'jpg')

% hold on

% %profile outlier arrays, for plotting
% outlierTEC = [];
% outlierTime = [];
% for i = 1:length(whereOutliers)
%       outlierTEC = cat(1,outlierTEC,TEC(whereOutliers(i)));
%       outlierTime = cat(1,outlierTime,plotDate(whereOutliers(i)));
%
% end
%
% scatter(outlierTime,outlierTEC,8,'filled')

end
