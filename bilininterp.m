%bilinear interpolation by repeated linear interpolation

function result = bilininterp(x1,y1,x2,y2,q11,q12,q21,q22,x,y)

result = (1/((x2-x1)*(y2-y)))*[x2-x x-x1]*[q11 q12; q21 q22]*[y2-y; y-y1];