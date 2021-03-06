function [ii,jj,vv] = getTripleGGGGTs_const(vold,msh,del)
% velo is a constant
% we use notation vold for velo
% get triples for \int_{all tris} del*(grad v*grad phi)*(grad v*grad phi)
% for the level set equation (note 6)
% cf. 
% NOTE: don't use NXFEM, it's standard FEM
% Input: - v (already known) = vold
%        - coeff del
% Output: ii,jj,vv

tris = msh.t; points = msh.p;
nTs = size(tris,2);
ii = zeros(9*nTs,1); jj = zeros(9*nTs,1); vv = zeros(9*nTs,1);

idx=1;
for t=1:nTs
    triangle = tris(1:3,t);
    v1 = points(:,triangle(1)); % vertex 1
    v2 = points(:,triangle(2)); % vertex 2
    v3 = points(:,triangle(3)); % vertex 3
    areaT = getAreaTri(v1,v2,v3); % area of triangle
    for i=1:3
        for j=1:3
%             gP1 = getGrad(1,t,msh);
%             gP2 = getGrad(2,t,msh);
%             gP3 = getGrad(3,t,msh);
            ii(idx) = tris(i,t);
            jj(idx) = tris(j,t);
            gPj = getGrad(j,t,msh);
%             gvgPj = vold(tris(1,t))*dot(gP1,gPj)...
%                     + vold(tris(2,t))*dot(gP2,gPj)...
%                     + vold(tris(3,t))*dot(gP3,gPj); % gvPj is constant
            gvgPj = dot(vold,gPj);
            gPi = getGrad(i,t,msh);
%             gvgPi = vold(tris(1,t))*dot(gP1,gPi)...
%                     + vold(tris(2,t))*dot(gP2,gPi)...
%                     + vold(tris(3,t))*dot(gP3,gPi); % gvPi is constant
            gvgPi = dot(vold,gPi);
            vv(idx) = del*gvgPj*gvgPi*areaT;
            idx = idx+1;
        end
    end
end

end
