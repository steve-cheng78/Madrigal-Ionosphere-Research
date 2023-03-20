clc,close all

% x = (0:.1:2)';
% y = [5.8955 3.5639 2.5173 1.9790 1.8990 1.3938 1.1359 1.0096 1.0343 ...
%     0.8435 0.6856 0.6100 0.5392 0.3946 0.3903 0.5474 0.3459 0.1370 ...
%     0.2211 0.1704 0.2636]';

figure('Units','centimeters',...
    'Position',[0 0 20 15],...
    'PaperPositionMode','auto');
plot(v,x,'ko');
hold on;

start = [z0; Nmax; 100];
%init = chapman(z,start(1),start(2),start(3));
h = plot(v,x,'b-');
hold off;


%ylim([0 6])
% set(gca, 'XMinorTick','on', 'XMinorGrid','on')
% set(gca, 'YMinorTick','on', 'YMinorGrid','on')
xlabel('Electron Density')
ylabel('Altitude (km)')
legend('Data','Chapman',...
    'Location','NorthEast','box','off')
title('Chapman Least Squares Fitting')


%start = [-2; 1; 4; 1; 2];
%options = optimset('TolX',0.1);
estimated_guess = fminsearch(@(guess) ChapmanErr(guess,x,v,h),start)

z = 100:10:500;
N = chapman(z,estimated_guess(1),estimated_guess(2),estimated_guess(3));
set(h,'XData',N,'YData',z);

    