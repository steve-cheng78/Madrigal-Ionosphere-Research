function err = ChapmanErr(guess,x,y)
% guess(1) corresponds to z0
% guess(2) corresponds to Nmax
% guess(3) corresponds to H

N = chapman(x,guess(1),guess(2),guess(3));

%z = guess(1)*x+guess(2)*x.^2 + guess(3)*exp(-guess(4)*x) + ones(length(x),1)*guess(5);

err = norm(N-y);

% set(gcf,'DoubleBuffer','on');
% set(handle,'XData',N);
% drawnow
% pause(.01)
