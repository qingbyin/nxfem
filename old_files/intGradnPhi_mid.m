function gradnPhi = intGradnPhi_mid(pointA,pointB,gradPhiI,uNT,jj,v,dim,deg)
% Find the value of int_pointA^pointB of (grad_nPhi_i)Phi_j
% Input: - gradPhi at node i (gradPhiI)
%        - unit normal vector in triangle T (uNT)
%        - intersection points: pointA and pointB (1x2)
%        - jj of Phi_j, in 1:3
%        - vertices v of this triangle: 2 coordinates x 3 vertices
% Output: the value of integral for these i and j.

norDer = dot(gradPhiI,uNT); % normal derivative
lenAB = sqrt((pointB(1)-pointA(1))^2+(pointB(2)-pointA(2))^2); % lenght of AB

% coordinate of point A in the "reference" triangle
[xHa,yHa] = getCoorRef(pointA,v(:,1),v(:,2),v(:,3));
% coordinate of point B in the "reference" triangle
[xHb,yHb] = getCoorRef(pointB,v(:,1),v(:,2),v(:,3));

% get mid point of AB in reference triangle
xHm = .5*(xHa+xHb); yHm = .5*(yHa+yHb);

[shapeFunction,~,~] = getP1shapes(xHm,yHm);

gradnPhi = norDer*lenAB*shapeFunction(jj);
end