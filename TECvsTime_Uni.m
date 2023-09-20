% Universial TECvsTime function
function TECvsTime_Uni(data_folder, figname, compound_ds)
    arguments
      data_folder (1,1) string
      
      figname (1,1) string
      
      % default value is raw Madrigal file layout
      compound_ds (1,1) string = "/Data/Table Layout"
      
      
    end

%% load entire data folder, can take large amount of RAM

files = dir(data_folder + "/*.hdf5");
T.time = [];
T.gdalt = [];
T.nel = [];

for k=1:length(files)
    
    data_file = data_folder + '/' + files(k).name;
    
    tic
    try
        raw = h5read(data_file, compound_ds);
    catch
        disp(data_file)
    end

    T.time = [T.time; datetime(1970, 1, 1, 0, 0, 0) + seconds(raw.ut1_unix)];
    T.gdalt = [T.gdalt; raw.gdalt];
    T.nel = [T.nel; raw.nel];

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
goodRows = ~isnan(T.gdalt) & ~isnan(T.nel) & T.nel > 0 & ~isnat(T.time);
T = T(goodRows,:);

profTimes = unique(T.time);

% Reverse the log_10 for NE
T.nel = 10 .^ T.nel;

Nt = length(profTimes);

TEC = zeros(Nt, 1);
chapParams = zeros(Nt, 3);
z = 100:20:500;
H = 50;

%% For EACH PROFILE, integrate GDALT vs. NE for TEC values
tic
for i = 1:Nt
    NE = sortrows(T(T.time == profTimes(i),:), "gdalt");

    [x, ia] = unique(NE.gdalt);
    NE = NE(ia,:);
    % NOTE: only takes first element of unique altitude data.
    % previous code averaged same altitude data.

    [Nmax, I] = max(NE.nel);
    z0 = x(I);

    [chapParams(i,:), N] = ChapmanFit(NE.nel, x, z, z0, Nmax, H);

    TEC(i) = trapz(z, N);

    if ~mod(i,100)
        disp("Integrating " + num2str(i/Nt*100, "%.1f") + " %")
    end
end

disp("Integration took " + num2str(toc, "%.1f") + " seconds.")

%find Chapman fit outliers in the profiles
% [outliers,whereOutliers] = chapOutliers(chapParams);
mmTEC = movmean(TEC, 250);

figure
h(1) = gcf;
ax = gca;
plt = plot(profTimes, mmTEC);

%showProfileFcn generates profile of point clicked on TEC graph
set(plt,'HitTest','off')
set(gca,'ButtonDownFcn',{@showProfileFcn, profTimes, T})
datetick('x', 'yyyy-mm-dd');
xlabel('Time (UTC)'), ylabel('TEC (m^-^2)');
title(figname);

%Shows x-coordinate of point being hovered over
txt = annotation('textbox');
txt.Position = [0.72 0.78 0.15 0.09];
txt.String = ["Time: " + datestr(profTimes(1)), "TEC: " + sprintf('%.4e',mmTEC(1))];
hold on
pnt = scatter(profTimes(1), mmTEC(1), 'HitTest', 'off');
vert = xline(profTimes(1), 'LineStyle', "--", 'HitTest', 'off');

%Side-by-side display of profile
figure
h(2) = gcf;
sideProfile = plot(0,0);
hold on
sideProfPts = scatter(0,0);

%set(fig, 'WindowButtonMotionFcn', {@hoverShowProf, sideProfile, sond_plotDate, date, profSegs,...
%    GDALT, NE})
set(h(1), 'WindowButtonMotionFcn', {@hover, ax, sideProfile, sideProfPts, T,...
    txt, pnt, vert, profTimes, mmTEC})

saveas(h, figname, 'fig')
saveas(h(1), figname, 'jpg')

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
