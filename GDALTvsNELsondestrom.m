% Altitude vs. ELectron Density

T = readtable('son970106g.001.txt', 'PreserveVariableNames', true);
GDALT1 = T.GDALT(1:9);
NEL1 = T.NEL(1:9);
GDALT2 = T.GDALT(18869:18877);
NEL2 = T.NEL(18869:18877);
GDALT3 = T.GDALT(51443:51451);
NEL3 = T.NEL(51443:51451);

TEC1 = trapz(GDALT1, NEL1);
TEC2 = trapz(GDALT2, NEL2);
TEC3 = trapz(GDALT3, NEL3);

figure(1)
scatter(NEL1, GDALT1, 'filled');
xlabel('Electron Density (log_1_0[Ne in m-3])'), ylabel('Altitude (km)');
title('Altitude vs. Electron Density at  January 6, 1997 3:36:02 PM GMT');

figure(2)
scatter(NEL2, GDALT2, 'filled');
xlabel('Electron Density (log_1_0[Ne in m-3])'), ylabel('Altitude (km)');
title('Altitude vs. Electron Density at  January 7, 1997 8:07:39 PM GMT');

figure(3)
scatter(NEL3, GDALT3, 'filled');
xlabel('Electron Density (log_1_0[Ne in m-3])'), ylabel('Altitude (km)');
title('Altitude vs. Electron Density at  January 9, 1997 7:35:45 PM GMT');