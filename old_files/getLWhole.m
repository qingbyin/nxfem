function Fti = getLWhole(triangle,i,msh,pa,P)
% int_Omg P*phi on NCTs/CTs (whole triangle)
% This file is used for general P (the size of P depends on number of
%       Gaussian points (pa.degN)
% Input: - which node i?
%        - which triangle? (with points to get vertices)
%        - component P: nwt x 1
% Output: load vector's value wrt this triangle at node i

points=msh.p;

% pa.degN: Gaussian quadrature points (for complicated function)
dim=2; deg=pa.degN; % Gaussian quadrature points in 2D
[wt,pt] = getGaussQuad(dim,deg); % 2D and degree 2 (3 points)
nwt = size(wt,2); % number of Gaussian points
v1 = points(:,triangle(1)); % vertex 1
v2 = points(:,triangle(2)); % vertex 2
v3 = points(:,triangle(3)); % vertex 3
areaT = getAreaTri(v1,v2,v3); % area of triangle

if isempty(P)
    P = ones(nwt,1); % force P=1
end


Fti=0;
for k=1:nwt
    [shFu,~,~] = getP1shapes(pt(1,k),pt(2,k)); % N_i at quadrature points
    Fti = Fti + P(k)*areaT*wt(k)*shFu(i);
end

end