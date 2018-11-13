function [ii,jj,vv] = getGhostPenalty(CTs,phi,hTmax,msh,pa)
% Get 2 ghost penalty terms j_1, j_2
% Input: cut triangles + phi
% Output: triplet to contribute to build global matrix

%% Get information about edges
[eGP,neighborCTs] = getGPEdges(CTs,phi,msh,pa);

% classify into 2 sub domains
% idx in eGP
j1 = find((eGP(5,:)==1)|(eGP(5,:)==3)); % edges for term j_1
j2 = find((eGP(5,:)==2)|(eGP(5,:)==3)); % edges for term j_2

nej1 = size(j1,2); % number of ghost-penalty edges for j_1
nej2 = size(j2,2); % number of ghost-penalty edges for j_2
nbCTs = msh.t(:,neighborCTs); % neighbor cut triangles
gradPhinbCTs = getGradPhi(nbCTs,msh); % grad of phi wrt vertices of nbCTs
% gradPhinbCTs = 2 coordinates x 3 vertices x number of nbCTs


%% setting up
ii = zeros(4*(nej1+nej2),1); % column-array
jj = zeros(4*(nej1+nej2),1); % column-array
vv = zeros(4*(nej1+nej2),1); % column-array

kk1 = pa.kk1; kk2 = pa.kk2;
gam1 = pa.gam1; gam2 = pa.gam2;
points = msh.p;
newNodes = msh.newNodes;

%% compute j_1
idx=1;
for e=1:nej1
    edge = j1(e); % considered edge in eGPs, edge = idx in eGP
    eP1 = points(:,eGP(1,edge)); % endpoint 1
    eP2 = points(:,eGP(2,edge)); % endpoint 2
    normalVT = getUnitNV(eP1,eP2); % unit normal vector to e
    lenEdge = sqrt((eP1(1)-eP2(1))^2 +(eP1(2)-eP2(2))^2); % length of edge
    for i=1:2
        for j=1:2
           ii(idx) = eGP(i,edge);
           jj(idx) = eGP(j,edge);
           % [grad_n phi_i]_e
           jumpGradnPhii = ...
               dot(gradPhinbCTs(:,eGP(i+5,edge),eGP(3,edge)),normalVT)...
             - dot(gradPhinbCTs(:,eGP(i+7,edge),eGP(4,edge)),normalVT); 
           % [grad_n phi_j]_e
           jumpGradnPhij = ...
               dot(gradPhinbCTs(:,eGP(j+5,edge),eGP(3,edge)),normalVT)...
             - dot(gradPhinbCTs(:,eGP(j+7,edge),eGP(4,edge)),normalVT);  
           vv(idx) = kk1*gam1*hTmax*lenEdge*jumpGradnPhij*jumpGradnPhii;
           idx = idx+1;
        end
    end
end

%% compute j_2
for e=1:nej2
    edge = j2(e); % considered edge in eGPs
    eP1 = points(:,eGP(1,edge)); % endpoint 1
    eP2 = points(:,eGP(2,edge)); % endpoint 2
    normalVT = getUnitNV(eP1,eP2); % unit normal vector to e
    lenEdge = sqrt((eP1(1)-eP2(1))^2 +(eP1(2)-eP2(2))^2); % length of edge
    for i=1:2
        for j=1:2
           ii(idx) = newNodes(eGP(i,edge));
           jj(idx) = newNodes(eGP(j,edge));
           % [grad_n phi_i]_e
           jumpGradnPhii = ...
               dot(gradPhinbCTs(:,eGP(i+5,edge),eGP(3,edge)),normalVT)...
             - dot(gradPhinbCTs(:,eGP(i+7,edge),eGP(4,edge)),normalVT); 
           % [grad_n phi_j]_e
           jumpGradnPhij = ...
               dot(gradPhinbCTs(:,eGP(j+5,edge),eGP(3,edge)),normalVT)...
             - dot(gradPhinbCTs(:,eGP(j+7,edge),eGP(4,edge)),normalVT);  
           vv(idx) = kk2*gam2*hTmax*lenEdge*jumpGradnPhij*jumpGradnPhii;
           idx = idx+1;
        end
    end
end

end