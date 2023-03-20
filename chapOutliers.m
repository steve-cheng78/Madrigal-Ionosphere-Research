%Find outliers in the Chapman parameters by calculating z-scores. Z-scores
%of more than 3 are classified as outliers.

function [outliers,whereOutliers] = chapOutliers(chapParams)
zz0 = zscore(chapParams(:,1));
zNmax = zscore(chapParams(:,2));
zH = zscore(chapParams(:,3));

zChapman = [zz0 zNmax zH];
outliers = zeros(length(chapParams),1);
whereOutliers = [];

for i = 1:numel(zChapman)
    if zChapman(i) > 3
        j = mod(i,length(chapParams));
        outliers(j) = 1;
        whereOutliers = cat(1,whereOutliers,j); %indices of outliers in outlier array
    end
end

%numOutliers = length(whereOutliers);

