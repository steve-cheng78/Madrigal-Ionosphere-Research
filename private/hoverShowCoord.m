function hoverShowCoord (~, ~, ax, txt, pnt, vert, xData, yData)

C = get(ax, 'CurrentPoint');
Cdate = num2ruler(C(1),ax.XAxis);

ind = find(abs(Cdate-xData) == min(abs(Cdate-xData)));

pnt.XData = xData(ind);
pnt.YData = yData(ind);
vert.Value = xData(ind);

txt.String = ["Time: " + datestr(xData(ind)), "TEC: " + sprintf('%.4e',yData(ind))];

% annotation('textbox', [0.75, 0.1, 0.1, 0.1], 'String', "pi value is " + pi)

end
