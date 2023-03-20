z = 50:10:500;
z0 = 300;
Nmax = 1e12;
H = 65;

N = chapman(z,z0,Nmax,H);

plot(N, z);
xlabel('Electron density (Ne in m-3)'), ylabel('Altitude (km)');
title('Chapman Function Example (z0=300, Nmax=1e12, H=65)');