function [ii,jj,vv] = getTriplePGGTs(gP,msh,pa,delT)
% Get triples for \int_{all tris} phi*delta*(grad v*grad phi)
% Velocity is grad of Phi
% For the level set equation (note 6)
% cf. main_chopp*, getMElsgP, getMHlsgP
% REMARK: don't use NXFEM, it's standard FEM
% Input: - gP: gP.x (1 x nTs), gP.y (1 x nTs): grad of v
%        - del_T: 1 x nTs (SUPG coefficients)
% Output: ii,jj,vv
% ----------------------------------------------------------
% Update 26/10/18: The OLD file used to compute grad v on vertices of each
%   triangle. We now use pdegrad to find grad v on the center of each
%   triangle (this file), i.e. grad v is constant on whole triangle and discont at edge.
% ----------------------------------------------------------

tris = msh.t;
nTs = size(tris,2);
ii = zeros(9*nTs,1); jj = zeros(9*nTs,1); vv = zeros(9*nTs,1);

gradPhi = getGradPhi(tris,msh); % 2 coor x 3 vertices x nTris

idx=1;
for t=1:nTs
    triangle = tris(:,t);
    del = delT(t); % delta
    gv = [gP.x(t), gP.y(t)];
    for i=1:3
        for j=1:3
            ii(idx) = tris(i,t);
            jj(idx) = tris(j,t);
            gvgPi = dot(gv,gradPhi(:,i,t)); % gvPi is constant
            P = []; % force P=1 inside getfPhiWhole
            vv(idx) = del*gvgPi*getfPhiWhole(msh,pa,triangle,j,P);
            idx = idx+1;
        end
    end
end

end