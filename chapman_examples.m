z = 50:10:500;
Zmax = 300;
Nmax = 1e12;
H=[20,50,80,110];

figure(1); 
hold off;
for i=1:numel(H)
    N = chapman(z,Zmax,Nmax,H(i));
    plot(N,z);
    xlabel('Density (m^{-3})');
    ylabel('Altitude (km)');
    grid on;
    hold on;
end
legend(string(H));
title('Chapman profiles, variable layer width H')

figure(2); 
hold off;
for i=1:numel(H)
    N = Nmax*exp(-((z-Zmax)/H(i)).^2);
    plot(N,z);
    xlabel('Density (m^{-3})');
    ylabel('Altitude (km)');
    grid on;
    hold on;
end
legend(string(H));
title('Gassian profiles, variable layer width H')

