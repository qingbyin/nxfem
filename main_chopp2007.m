%% =======================================================================
% This file is used to find a very simple BIOFILM proposed by Chopp 2007
% This is a SYSTEM of LINEAR equations u,v (u=substrate, v=potential)
% ------------------------------------------------------------------------
% PURPOSE: Coding level set
% Related files: 
%   - ChoppSimpleKap.edp: for the code in FreeFem++
%   - model_chopp2007.m: contains all info for the model
% ------------------------------------------------------------------------
% RESULT: not enough information in the Chopp's article to compare the
% results!!!!! Change to work with models introduced in Chopp06combine (cf.
% main_chopp06combine.m)
% ------------------------------------------------------------------------
% Last modified: 08-11-2018
% ------------------------------------------------------------------------

%% =======================================================================
% DOMAIN: [0,0.5]X[0,0.5], inital interface: half of circle ((1/2,0);r0)
%-------------------------------------------------------------------------
% MODELS:
% r=sqrt(x^2+y^2)-r0 the interface
%-------------------------------------------------------------------------
% Equation of u (substrate):
% -nabla(alpha*nabla(u)) = -mu*u  in Omega
% [u]=[alpha*nabla_n(u)]=0     on Gamma
% u = 1e-5   on \partial\Omega_3
% nabla_n u = 0 elsewhere
%-------------------------------------------------------------------------
% Equation of v (potential):
% -nabla(nabla(v)) = -beta*u in Omega
% v=nabla_n(v)=0 on Gamma 
% v=0 on \partial\Omega_3
% nabla_n v = 0 elsewhere
%-------------------------------------------------------------------------
% PARAMETERS:
% alpha = 120 (Omg1), 150 (Omg2)
% beta = 1e6 (Omg1), 0 (Omg2)
% mu = 3.6e6 (Omg1), 0 (Omg2)
%=========================================================================

%% =======================================================================
% PARAMETERS
% Note that parameters are different for equations of u and v
%=========================================================================

addpath(genpath('func'));   % add all necessary functions
clear ; close all; % Initialization


% fixed parameters
%-------------------------------------------------------------------------
pa.degP1D = 3; % Gaussian quadrature points in 1D (polinomial functions)
pa.degP2D = 4; % Gaussian quadrature points in 2D (polinomial functions)
pa.degN = 8;    % Gaussian quadrature points in 2D (non-polynomial functions)
                % degree-#OfPoints : 1-1, 2-3, 3-4, 4-6, 5-7, 6-12,
                %                    7-13, 8-16, 9-19, 10-25, 11-27, 12-33
pa.tol = eps(1e3); % tolerance, 1e-14


% MODEL
%-------------------------------------------------------------------------
model = model_chopp2007;    % choose model. cf. file model_chopp2007.m

showPlot = 1;

% for both showPlot & savePlot
withMesh = false;
plotGradv = 0; % plot gradient of v on cut triangles
plotContourChange = 0; % only plot the interface with time (hold on to see the track)
plotSolution = 0; % plot solution or not? (uh, vh)

savePlot = 1; % wanna save plot or not?
    testCase = '23'; % count the test and used to name the folder
    pathOption = '_newphi';
    moreInfo = 'Test 23: find best newphi.'; % write inside file txt

pa.smallCut = 0;            % ignore small-support basis (1=ignore,0=no)
pa.tH = 10; % to find the small support using (20) or (21) in arnold 2008

% mesh's type
useFFmesh = 1; % use mesh generated by freefem++?
    reguMesh = 0; % use regular mesh or not? (only available for matlab)
    nSeg = 175;  % mesh settings (only if useFFmesh=0)


% Ghost penalty
pa.useGP = 0; % wanna use ghost penalty term?
    pa.gam1 = 1e-6; % parameter for 1st term
    pa.gam2 = 1e-6 ; % parameter for 2nd term

% Fast marching method
useFMM = 1; % use fast marching method or not (mshdist)?
    numUseFMM = 0; % count the number of use of FMM
    alp_FMM = 0.1;
    stepUseFMM = 15; % use every 15 step (disable al_FMM method)

% SUPG
useSUPG = 1; % if 1, need to make more settings
    delEps = 1e-3;
    delSD = 0.5;
%     delSD = 0;

% Penalty parameters
cpU.lamH = 1e6; % penalty coefficient for u (substrate)
cpV.lamH = 1e8; % penalty coefficient for v (potential)

% choose the machine to run
%-------------------------------------------------------------------------
% options: thi, gia, lehoan, blouza, gaia, google, ghost
machine = 'google'; 
% machine = 'blouza';
% machine = 'thi';
% machine = 'ghost';
% machine = 'lehoan';

% only enable showPlot option on thi's machine
if ~strcmp(machine,'thi')
    showPlot = 0;
end


%% Model parameters
%-------------------------------------------------------------------------
pa.phiNew = 1;
if ~pa.phiNew
    pa.distancing = 0;
    pa.r0 = 0.1;  % interface
    %     pa.a = 1; % aspect ratio (p.49 Chopp 07 xfem)
else
    pa.phiNoise = 0.01; % diff phi
    pa.phiHeight = 0.1;
    pa.distancing = 1; % make phi to be a signed distance function
end
pa.bet1 = 1e6; pa.bet2 = 0; % this is not diff coef!
% pa.bet1 = 1e8; pa.bet2 = 0; % testing
pa.mu1 = 3.6e6; pa.mu2 = 0;
% pa.bcu3 = 1e-5; % boundary condition for u on \pt\Omg_3
pa.bcu3 = 1e-3; % testing

cpU.kk1 = 120; cpU.kk2 = 150;% diff coef for u
cpV.kk1 = 1; cpV.kk2 = 1;    % diff coef for u

maxDay = 45;
CFL = 0.5;


%% DOMAIN
%-------------------------------------------------------------------------
GeoDom = model.domain(); % domain



%% Mesh settings
%-------------------------------------------------------------------------
if ~useFFmesh
    disp('Mesh generated by matlab...');
    if ~reguMesh % not regular mesh?
        hEdgeMax = 2/nSeg;
        [points,edges,triangles] = initmesh(GeoDom,'hmax',hEdgeMax);    % irregular
    else
        [points,edges,triangles] = poimesh(GeoDom,nSeg,nSeg);           % regular
    end
else % using freefem nesh
    disp('Mesh generated by FreeFem++...');
    if ~pa.phiNew
        [points,edges,triangles] = ffreadmesh('./mesh/mesh_chopp07.msh');
    else
        [points,edges,triangles] = ffreadmesh('./mesh/mesh_chopp07phinew.msh');
    end
end
% plotMesh;

msh.p = points; msh.t = triangles; msh.e = edges;   % save to msh
x = points(1,:);    % x-coordinate of points
y = points(2,:);    % y-coordinate of points

% diameter (longest side) of each triangle: 1 x nTs
msh.hT = getDiam(msh);              % 1 x number of triangles
msh.hTmax = max(msh.hT);            % maximum of all diameters
msh.nStd = size(points,2);    


% Level set function (INITIAL)
%-------------------------------------------------------------------------
phi = model.defPhi(x,y,pa); % 1 x number of points (row array)
phi(abs(phi)<pa.tol)=0; % find phi which are very small (~0) and set to 0



%% create command to run mshdist outside matlab
fprintf('Running on machine [%s]\n', machine);
switch machine
    case 'thi'
        path_nxfem = '/home/thi/Documents/nxfem/'; % thi's local machine
        path_phi = strcat(path_nxfem,'mshdist/');
        call_mshdist = strcat({'mshdist'},{' '},{path_phi},'phi'); % run in terminal
    case 'google'
        path_nxfem = '/home/thi/nxfem/';
        path_phi = strcat(path_nxfem,'mshdist/');
        call_mshdist = strcat({'mshdist'},{' '},{path_phi},'phi'); % run in terminal
    case 'ghost'
        path_nxfem = '/home/ghost/nxfem/';
        path_phi = strcat(path_nxfem,'mshdist/');
        call_mshdist = strcat({'mshdist'},{' '},{path_phi},'phi'); % run in terminal
    case 'gia'
        path_nxfem = '/home/gia/nxfem/'; % gia's local machine
        path_phi = strcat(path_nxfem,'mshdist/');
        call_mshdist = strcat({'mshdist'},{' '},{path_phi},'phi'); % run in terminal
    case 'lehoan'
        path_nxfem = '/home/lehoan/git/nxfem/'; % lehoan's local machine
        path_phi = strcat(path_nxfem,'mshdist/');
        call_mshdist = strcat({'mshdist'},{' '},{path_phi},'phi'); % run in terminal
    case 'blouza'
        path_nxfem = '/users/home/blouza/thi/nxfem/'; % blouza's local machine
        path_phi = strcat(path_nxfem,'mshdist/');
        call_mshdist = strcat({'/users/home/blouza/MshDist/build/mshdist'},{' '},{path_phi},'phi'); % run in terminal
    case 'gaia' % CHECK LATER!!!!
        path_nxfem = '/users/dinh/nxfem/'; % only on gaia machine
        path_phi = strcat(path_nxfem,'mshdist/');
%         call_mshdist = strcat({'mshdist'},{' '},{path_phi},'phi'); % run in terminal
end
call_mshdist = cell2mat(call_mshdist);



%% Distancing level set function (if it's not)
disp("Exporting to phi.mesh");
mshdist_w_mesh(msh,path_phi,'phi'); % export to .mesh
if pa.distancing
    disp("Distancing phi...");
    mshdist_w_sol(msh,phi,path_phi,'phi'); % export to phi.sol
    system(call_mshdist); % run 'mshdist file/to/phi' (distancing)
    phi = mshdist_r_sol(phi,path_phi,'phi'); % update phi
end



%% if SAVE PLOT
% Create a folder to save the plots
if savePlot
    disp("Creating folder to save plots...");
    path_machine = machine;
    if reguMesh && (~useFFmesh)
       path_regu = 'regu_';
    elseif ~useFFmesh
        path_regu = 'irregu_';
    else
        path_regu = '';
    end
    if ~useFFmesh
        path_useFF = 'matlabMesh';
    else
       path_useFF = 'FFmesh';
    end
    if useFMM 
        path_useFMM = '_wFMM'; 
    else
        path_useFMM = '_wtFMM';
    end
    if useSUPG
        path_useSUPG = '_wSUPG'; 
    else
        path_useSUPG = '_wtSUPG';
    end
    if pa.useGP
        path_useGP = '_wGP';
    else
        path_useGP = '_wtGP';
    end
    path_tris = num2str(size(triangles,2)); % number of triangles
    path_test_result = strcat(path_nxfem,'results/chopp07/',...
            testCase,'_',path_regu,path_useFF,path_useGP,path_useSUPG,...
            path_useFMM,'_',path_tris,'_',pathOption,'_',path_machine);
    path_test_remove = strcat({'rm -r'},{' '},{path_test_result}); % in case of duplicated folder
    path_test_remove = cell2mat(path_test_remove);
    system(path_test_remove);
    path_test_create = strcat({'mkdir'},{' '},{path_test_result}); % crfeate a new folder
    path_test_create = cell2mat(path_test_create);
    system(path_test_create);
end


if savePlot
   % Save parameters' info to file
    fileName = strcat(path_test_result,...
        '/parameters_',num2str(size(triangles,2)),'.txt');
    fileID = fopen(fileName,'w');
        fprintf(fileID,'%s,\n',moreInfo);
        fprintf(fileID,'\n');
        fprintf(fileID,'Machine: %s,\n',machine);
        fprintf(fileID,'Model: %s,\n',model.name);
        fprintf(fileID,'hTmax: %0.10f,\n',msh.hTmax);
        fprintf(fileID,'no. triangles: %d,\n',size(triangles,2));
        fprintf(fileID,'\n');
        fprintf(fileID,'number of days: %f,\n',maxDay);
        fprintf(fileID,'\n');
        fprintf(fileID,'Use FreeFem++ mesh: %d,\n',useFFmesh);
        fprintf(fileID,'Regular mesh: %d,\n',reguMesh);
        fprintf(fileID,'Use small-cut: %d,\n',pa.smallCut);
        fprintf(fileID,'\n');
        fprintf(fileID,'Use FMM: %d,\n',useFMM);
        fprintf(fileID,'__al_FMM: %f,\n',alp_FMM);
        fprintf(fileID,'__numUseFMM: %d,\n',numUseFMM);
        fprintf(fileID,'__numUseFMM: %d,\n',stepUseFMM);
        fprintf(fileID,'\n');
        fprintf(fileID,'useSUPG: %d,\n',useSUPG);
        fprintf(fileID,'__delEps: %f,\n',delEps);
        fprintf(fileID,'__delSD: %f,\n',delSD);
        fprintf(fileID,'\n');
        fprintf(fileID,'use Ghost penalty: %d,\n',pa.useGP);
        fprintf(fileID,'__gam1: %f,\n',pa.gam1);
        fprintf(fileID,'__gam2: %f,\n',pa.gam2);
        fprintf(fileID,'\n');
        fprintf(fileID,'Panalty terms:\n');
        fprintf(fileID,'__lamHu: %f,\n',cpU.lamH);
        fprintf(fileID,'__lamHv: %f,\n',cpV.lamH);
        fprintf(fileID,'\n');
        fprintf(fileID,'Model parameters:\n');
        if ~pa.phiNew
            fprintf(fileID,'__r0: %f,\n',pa.r0);
        else
            fprintf(fileID,'__phiHeight: %f,\n',pa.phiHeight);
            fprintf(fileID,'__phiNoise: %f,\n',pa.phiNoise);
        end
        fprintf(fileID,'__bet1: %f,\n',pa.bet1);
        fprintf(fileID,'__bet2: %f,\n',pa.bet2);
        fprintf(fileID,'__mu1: %f,\n',pa.mu1);
        fprintf(fileID,'__mu2: %f,\n',pa.mu2);
        fprintf(fileID,'__bcu3: %f,\n',pa.bcu3);
        fprintf(fileID,'\n');
%     fclose(fileID); 
end



%% EACH TIME STEP
%=========================================================================
day = 0; % count the time (days)
ns=0; % number of steps
voldSTD = zeros(msh.nStd,1); % initial vh for velocity grad v


disp("Starting the loop...");
%% loop
while day < maxDay
    disp("-----------------------------");
    nf = 0; % reset every loop to be sure uh, vh plotted on the same figure
    ns = ns+1;
    fprintf('Step= %d\n',ns);
    
    %% =======================================================================
    % GET INFORMATION OF TRIANGLES
    % The same for both equations of u and v
    %=========================================================================

     % Triangles
    %-------------------------------------------------------------------------
    tris = getTriangles(phi,msh,pa); % tris has 3 factors (structure var)
    CTs=tris.CTs; NCTs1=tris.NCTs1; NCTs2=tris.NCTs2;

    
    % On cut triangles
    %-------------------------------------------------------------------------
    CT = getInfoCTs(CTs,phi,msh,pa); % CT has many factors (structure var)
    nodeCTs=CT.nodes; areaChildCTs=CT.areaChild; iPs=CT.iPs;

    
    % Find small-cut triangles (idx in the OLD CTs)
    %-------------------------------------------------------------------------
    if pa.smallCut
        tic;time=0;
        fprintf('Removing small cut triangles... ')
        [tris,CT] = findSmallPhi_after(msh,pa,phi,tris,CT);
%         clear CTs NCTs NCTs2 nodeCTs areaChildCTs iPs; % just in case (bad practice)
        CTs=tris.CTs;
        nodeCTs=CT.nodes; areaChildCTs=CT.areaChild; iPs=CT.iPs;
        fprintf('%fs\n',toc-time);
    end
    
    nCTs = size(iPs,3); % number of cut triangles



    %% =======================================================================
    % NODES
    %=========================================================================
    msh.nNew = nodeCTs.n; % number of new nodes (nodes around the interface)
    msh.ndof = msh.nNew + msh.nStd; % number of dofs
    msh.newNodes = getNewNodes(nodeCTs.all,msh.nStd); % vector contaning new numbering of nodes around interface, column
    msh.node = getNodes(tris,nodeCTs,msh,phi,pa); % get all nodes

    
    % boundary nodes and inner nodes
    %-------------------------------------------------------------------------
    [iN,bN] = getibNodes(msh);
    bNodes = bN.all; iNodes=iN.all;
    b3Nodes = bN.e3;        % node on \pt\Omg_3 (top)
    
    
    %% plot phi
    if showPlot
        tic;time=0;
        fprintf('Plotting phi... ');
        titlePlot = strcat('phi, day = ',num2str(round(day,2)));
        
        if plotContourChange % don't show phi's value, just show its contours with time
            nf = plotNXFEM(msh,pa,phi,iPs,nf,'title',titlePlot,...
                    'withMesh',withMesh); % only mesh
        else % plot phi's value also
            nf = plotNXFEM(msh,pa,phi,iPs,nf,phi,'withMesh',withMesh,...
                'title',titlePlot,'iC','b'); % phi
        end
        fprintf('%fs\n',toc-time);
    end
    
    
    
    %% =======================================================================
    % CONTROL PARAMETERS
    % depend on mesh and different for w and u
    % in child-functions, it's the variable "cp"
    %=========================================================================
    hTCTs = msh.hT(CTs(5,:));
    
    kapU = model.kapU(cpU,CT,pa);
    cpU.kap1 = kapU.kap1; cpU.kap2 = kapU.kap2; % kappa_i
    cpU.lambda = model.lamU(cpU,hTCTs,CT,pa); % penalty coef (not ghost penalty)

    kapV = model.kapV(cpV,CT,pa);
    cpV.kap1 = kapV.kap1; cpV.kap2 = kapV.kap2; % kappa_i
    cpV.lambda = model.lamV(cpV,hTCTs,CT,pa); % penalty coef (not ghost penalty)




    %% =======================================================================
    % SOLVING U
    %=========================================================================

    
    % Stiffness matrix (all nodes including nodes on boundary)
    %-------------------------------------------------------------------------
    disp("Solving u...");
    Au = getGM_Chopp07u(tris,phi,CT,msh,pa,cpU);

    
    % Load vector (all nodes including nodes on boundary)
    %-------------------------------------------------------------------------
    defFu = model.defFu;
    Fu = getLf(msh,pa,tris,CT,defFu);
    

    
    % BCs
    %-------------------------------------------------------------------------
    unew = zeros(msh.ndof,1); % column-array
    unew(b3Nodes) = pa.bcu3; % BC

    
    % Solving u
    %----------------------------------------------------------------------
    Fu = Fu - Au*unew; % modification of F
    
    % LU factorization
    unew(iNodes) = Au(iNodes,iNodes)\Fu(iNodes); % don't care nodes on boundary
    
    % unew(iNodes) = gmres(Au(iNodes,iNodes),Fu(iNodes)); % GMRES factorization
        
    
    
    %% ====================================================================
    % SOLVING V
    %======================================================================
    fprintf('Solving v... ');tic;time=0;
    
    % Stiffness matrix (all nodes including nodes on boundary)
    %----------------------------------------------------------------------
    Av = getGM_Chopp07v(tris,phi,CT,msh,pa,cpV);

    
    % Load vector (all nodes including nodes on boundary)
    %----------------------------------------------------------------------
    uSep = getWsep(unew,msh,-pa.bet1,-pa.bet2);
    Fv = getL_Chopp07v(msh,pa,tris,CT,uSep);


    
    % BCs
    %----------------------------------------------------------------------
    vnew = zeros(msh.ndof,1); % column-array
    vnew(b3Nodes) = 0; % Dirichlet on \pt\Omg3

    
    % Solving v
    %----------------------------------------------------------------------
    Fv = Fv - Av*vnew; % modification of F
    
    % LU factorization
    vnew(iNodes) = Av(iNodes,iNodes)\Fv(iNodes); % don't care nodes on boundary
    
    % vnew(iNodes) = gmres(Av(iNodes,iNodes),Fv(iNodes));   % GMRES factorization
    fprintf('%fs\n',toc-time);
    
    
    
    % u and v in std Vh
    disp("Converting u, v to STD...");
    unewSTD = interNX2STD(unew,msh);
    vnewSTD = interNX2STD(vnew,msh);
    
    
     %% grad v
    [gvnew.x,gvnew.y] = pdegrad(points,triangles,vnewSTD);
    [gvold.x,gvold.y] = pdegrad(points,triangles,voldSTD);
    
    
    %% ====================================================================
    % PLOT u and v
    %======================================================================
    if showPlot && plotSolution
%         nf = plotNXFEM(msh,pa,phi,iPs,nf,'eleLabel','off','nodeLabel','off'); % only mesh

        disp('Plotting u...');
        titlePlot = strcat('uh, day = ',num2str(round(day,2)));
        nf = plotNXFEM(msh,pa,phi,iPs,nf,unewSTD,'withMesh',withMesh,...
                    'title',titlePlot,'iC','b'); % uh

        disp('Plotting v...');
        titlePlot = strcat('vh, day = ',num2str(round(day,2)));
        nf = plotNXFEM(msh,pa,phi,iPs,nf,vnewSTD,'withMesh',withMesh,...
                    'title',titlePlot,'iC','b'); % vh
    end % end if showPlot
    
    
    
    %% SAVE PLOT
    if savePlot
        tic;time=0;
        fprintf("Saving plots... ");
        
        % phi
        nf=nf+1; 
        f = figure(nf);
        if plotContourChange % don't show phi's value, just show its contours with time
            set(f, 'Visible', 'off');
            titlePlot = strcat('phi, day = ',num2str(round(day,2)));
            plotNXFEM(msh,pa,phi,iPs,nf,'title',titlePlot,...
                    'withMesh',withMesh,'show',false,'iC','b'); % only mesh
            hold on
        else % plot phi's value also
            set(f, 'Visible', 'off');
            titlePlot = strcat('phi, day = ',num2str(round(day,2)));
            plotNXFEM(msh,pa,phi,iPs,nf,phi,'withMesh',withMesh,...
                'title',titlePlot,'iC','b'); % phi
        end
        fileName = strcat(path_test_result,'/phi_',num2str(ns),'_',...
                        'day_',num2str(round(day,2)),'.png');

        % change size of images
        f.PaperUnits = 'inches';
        f.PaperPosition = [0 0 8 6];
        print(fileName,'-dpng','-r0');
        if ~plotContourChange
            close(f);
        end

        
        if plotSolution
            % uh
            nf=nf+1;
            g=figure(nf);
            set(g, 'Visible', 'off');
            titlePlot = strcat('uh, day = ',num2str(round(day,2)));
            plotNXFEM(msh,pa,phi,iPs,nf,unewSTD,'withMesh',withMesh,...
                            'title',titlePlot,'show',false,'iC','b'); % uh
            fileName = strcat(path_test_result,'/uh_',num2str(ns),...
                            '_','day_',num2str(round(day,2)),'.png');
            % change size of images
            g.PaperUnits = 'inches';
            g.PaperPosition = [0 0 8 6];
            print(fileName,'-dpng','-r0');
            close(g);

            % vh
            nf=nf+1;
            g=figure(nf);
            set(g, 'Visible', 'off');
            titlePlot = strcat('vh, day = ',num2str(round(day,2)));
            plotNXFEM(msh,pa,phi,iPs,nf,vnewSTD,'withMesh',withMesh,...
                            'title',titlePlot,'show',false,'iC','b'); % vh
            fileName = strcat(path_test_result,'/vh_',num2str(ns),...
                            '_','day_',num2str(round(day,2)),'.png');
            % change size of images
            g.PaperUnits = 'inches';
            g.PaperPosition = [0 0 8 6];
            print(fileName,'-dpng','-r0');
            close(g);
        end
        
        fprintf('%fs\n',toc-time);
    end
    
    
    
    %% ====================================================================
    % SOLVING phi (level set function)
    % standard finite element
    %======================================================================
    disp("Solving level set phi...");
    
     % dt
    maxGradV = max(abs(gvnew.x) + abs(gvnew.y));
    dt = CFL*msh.hTmax/maxGradV;
    fprintf('dt: %f\n', dt);
    day = day+dt;
    fprintf('day: %f\n', day);
    
    % get del_T
    if useSUPG
        delOld = getDellsT(msh,gvold,delEps,delSD); % Arnold's book p.223
        delNew = getDellsT(msh,gvnew,delEps,delSD);
    else
        delOld = zeros(1,size(msh.t,2)); % without SUPG
        delNew = delOld;
    end
    
    
    % stiffness matrix for level set
    %----------------------------------------------------------------------
    tic;time=0;
    fprintf('Get stiffness matrix Enew, Hnew... ');
    Enew = getMElsGP(msh,pa,gvnew,delNew,1);
    Hnew = getMHlsGP(msh,pa,gvnew,delNew,dt*0.5);
    mI = speye(msh.nStd); % identity matrix
    Aphi = mI + Enew^(-1)*Hnew;
    fprintf('%fs\n',toc-time);
    
    
    % load vector for level set
    %----------------------------------------------------------------------
   % load vector for level set
    %----------------------------------------------------------------------
    tic;time=0;
    fprintf('Get load vector (Eold, Hold, Afphi)... ');
    Eold = getMElsGP(msh,pa,gvold,delOld,1);
    Hold = getMHlsGP(msh,pa,gvold,delOld,dt*0.5);
    AFphi = mI - Eold^(-1)*Hold;
    phi = phi'; % row to column
    Fphi = AFphi*phi;
    fprintf('%fs\n',toc-time);
    
    
    % seek phi
    %----------------------------------------------------------------------
    disp('Updating phi...');
    phi = Aphi\Fphi; % update phi
    phi = phi'; % column to row
    
    
    %% update v
    disp("Updating v...");
    voldSTD = vnewSTD;
    
    
    %% Reinitialization
    %----------------------------------------------------------------------
    norm_gradphi = getNormL2GfhSTD(msh,phi); % ||gradPhi||_L2
    fprintf('|1-norm_gradphi| = %f\n',abs(1-norm_gradphi));
    
%     if useFMM && abs(1-norm_gradphi) > alp_FMM && numUse <=1
%     if useFMM && abs(1-norm_gradphi) > alp_FMM
    if useFMM && (mod(ns,stepUseFMM)==0) % every stepUseFMM step
        disp('Starting to use FMM...');
        mshdist_w_sol(msh,phi,path_phi,'phi'); % export to phi.sol
        system(call_mshdist); % run 'mshdist file/to/phi' (redistancing)
        phi = mshdist_r_sol(phi,path_phi,'phi'); % update phi
        numUseFMM = numUseFMM + 1;
    end
    
    
end % for ns


%% save info file
if savePlot
   % Save parameters' info to file
%     fileName = strcat(path_test_result,...
%         '/parameters_',num2str(size(triangles,2)),'.txt');
%     fileID = fopen(fileName,'w');
        fprintf(fileID,'\n');
        fprintf(fileID,'the last dt: %f,\n',dt);
        fprintf(fileID,'\n');
    fclose(fileID); 
end


%% CLEAN UP
% Fix conflict in git
system('rm -r mshdist/phi.mesh');
close all; % close all figures in this test


function delT = getDellsT(msh,gP,eps,SD)
    % This function 'guest' formula presented in Arnold's book, page 223 (and also cf. (7.14))
    % If in future, we need it more than once, I will put it in a separated file
    % Input: - msh.hT : h on each triangle : 1 x nTs
    %        - gP: gP.x (1 x nTs), gP.y (1 x nTs)
    %        - a control number SD \in O(1) (cf. (7.14))
    %        - given small eps > 0 (cf. 7.14), at page 223, he took eps=1e-3
    % Output: a vector 1 x nTs
    
    maxGradV = max(abs(gP.x) + abs(gP.y));
    delT = SD*msh.hT/max(eps,maxGradV);
end