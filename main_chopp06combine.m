%% =======================================================================
% This file is used to find a very simple BIOFILM proposed by
% Chopp06combine
% Article: chopp06combine = 'A combined extended finite element and level set method for biofilm growth'
% This is a SYSTEM of LINEAR equations u,v (u=substrate=S, v=potential=Phi)
% ------------------------------------------------------------------------
% PURPOSE: verifying the results given in chopp06combine
% Related files: 
%   - model_chopp06combine.m: contains all info for the model
% ------------------------------------------------------------------------
% RESULT: 
% ------------------------------------------------------------------------
% Last modified:
% ------------------------------------------------------------------------

%% =======================================================================
% DOMAIN: [0,0.5]X[0,0.1], inital interface: half of circle ((0.25,0);r0)
% all meters are in mm
%-------------------------------------------------------------------------
% MODELS:
% r=sqrt((x-0.25)^2+y^2)-r0 the interface
% Omg1 = Omg_b, Omg2 = Omg_f
%-------------------------------------------------------------------------
% Equation of u (substrate S):
% -nabla(Ds*nabla(u)) + f*muS*u/(K0+u) = 0  in Omega
% [u]=[Ds*nabla_n(u)]=0     on Gamma
% u = 8.3e-6   on \partial\Omega_3
% nabla_n u = 0 elsewhere
%-------------------------------------------------------------------------
% Equation of v (potential Phi):
% -nabla(nabla(v)) = -f*muP*u/(K0+u) in Omega
% v=nabla_n(v)=0 on Gamma 
% v=0 on \partial\Omega_3 (checked again!)
% nabla_n v = 0 elsewhere
%-------------------------------------------------------------------------
% PARAMETERS:
% Ds = 146.88 (Omg1), 183.6 (Omg2) (DSb=0.8DSf)
% muS = 8.54932 (Omg1), 0 (Omg2)
% muP = 8.28785 (Omg1), 0 (Omg2)
%=========================================================================



%% =======================================================================
% PARAMETERS
% Note that parameters are different for equations of u and v
%=========================================================================

addpath(genpath('func'));   % add all necessary functions

% fixed parameters
%-------------------------------------------------------------------------
pa.degP1D = 3;              % Gaussian quadrature points in 1D (polinomial functions)
pa.degP2D = 4;              % Gaussian quadrature points in 2D (polinomial functions)
pa.degN = 8;    % Gaussian quadrature points in 2D (non-polynomial functions)
                % degree-#OfPoints : 1-1, 2-3, 3-4, 4-6, 5-7, 6-12,
                %                    7-13, 8-16, 9-19, 10-25, 11-27, 12-33
pa.tol = eps(1e3);          % tolerance, 1e-14



%% OPTIONS
%-------------------------------------------------------------------------
model = model_chopp06combine;    % choose model. cf. file model_chopp2007.m

showPlot = 0; % wanna show plots?
    withMesh = true;
    plotGradv = 0; % plot gradient of v on cut triangles

savePlot = 1; % wanna save plot or not?
    pathOption = '';
    
pa.smallCut = 1;  % ignore small-support basis (1=ignore,0=no)
    pa.tH = 10; % to find the small support using (20) or (21) in arnold 2008

useFFmesh = 1; % use mesh generated by freefem++?
    reguMesh = 1; % use regular mesh or not? (only available for matlab)
    nSeg = 20;  % mesh settings (only if useFFmesh=0)
useNewton = 1; % use Newton to solve nonlinear problems?
    itol = 1e-3;
    
% ghost penalty
pa.useGP = 1; % wanna use ghost penalty term?
    pa.gam1 = 1e-6; % parameter for 1st term
    pa.gam2 = 1e-6 ; % parameter for 2nd term

% Fast marching method
useFMM = 0; % use fast marching method or not (mshdist)?
    numUseFMM = 0; % count the number of use of FMM
    alp_FMM = 0.1;

% SUPG
useSUPG = 1; % if 1, need to make more settings
    delEps = 1e-3;
    delSD = 0.5;

% Penalty parameters
%-------------------------------------------------------------------------
cpU.lamH = 1e5; % penalty coefficient for u (substrate)
cpV.lamH = 1e5; % penalty coefficient for v (potential)

% choose the machine to run
%-------------------------------------------------------------------------
    % machine = 'google'; 
    % options: thi, gia, lehoan, blouza, gaia, google, ghost
% machine = 'blouza';
% machine = 'thi';
machine = 'ghost';


% only enable showPlot option on thi's machine
if ~strcmp(machine,'thi')
    showPlot = 0;
end



%% Model parameters
%-------------------------------------------------------------------------
% pa.r0 = 0.01;  % interface
pa.r0 = 0.05; % testing
    pa.distancing = 0; % make phi to be a signed distance function
pa.muS1 = 8.	; pa.muS2 = 0;
pa.muP1 = 8.28785; pa.muP2 = 0;
pa.bcu3 = 8.3e-6; % boundary condition for u on \pt\Omg_3
% pa.bcu3 = 1e-2; % just for test before apply dynamic boundary
cpU.kk1 = 146.88; cpU.kk2 = 183.6; % diff coef for u
cpV.kk1 = 1; cpV.kk2 = 1;    % diff coef for v
pa.f = 0.5; % volume fraction of active biomass
pa.K0 = 5e-7;
pa.L = 0.1; % fixed-distance of top-most Dirichlet condition



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
   [points,edges,triangles] = getMeshFromFF('./mesh/mesh_chopp06combine.msh');
end

msh.p = points; msh.t = triangles; msh.e = edges;   % save to msh
x = points(1,:);    % x-coordinate of points
y = points(2,:);    % y-coordinate of points

% diameter (longest side) of each triangle: 1 x nTs
msh.hT = getDiam(msh);              % 1 x number of triangles
msh.hTmax = max(msh.hT);            % maximum of all diameters
msh.nStd = size(points,2);          % number of standard nodes


% Level set function (INITIAL)
%-------------------------------------------------------------------------
phi = model.defPhi(x,y,pa); % 1 x number of points (row array)
phi(abs(phi)<pa.tol)=0; % find phi which are very small (~0) and set to 0



%% create command to run mshdist outside matlab
fprintf('Running on machine [%s]\n', machine);
switch machine
    case 'thi'
        path_nxfem = '/home/thi/Dropbox/git/nxfem/'; % thi's local machine
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
disp('Exporting to phi.mesh');
mshdist_w_mesh(msh,path_phi,'phi'); % export to .mesh
if pa.distancing
    tic;time=0;
    fprintf('Distancing phi... ');
    mshdist_w_sol(msh,phi,path_phi,'phi'); % export to phi.sol
    system(call_mshdist); % run 'mshdist file/to/phi' (distancing)
    phi = mshdist_r_sol(phi,path_phi,'phi'); % update phi
    fprintf("%fs\n",toc-time);
end



%% if SAVE PLOT
% Create a folder to save the plots
if savePlot
    disp("Creating folder to save plots...");
    if reguMesh
       path_regu = 'regu_';
    else
        path_regu = 'irregu_';
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
    path_test_result = strcat(path_nxfem,'results/chopp06combine/',...
                                path_regu,path_useFF,path_useGP,...
                                    path_useSUPG,path_useFMM,pathOption);
    path_test_remove = strcat({'rm -r'},{' '},{path_test_result}); % in case of duplicated folder
    path_test_remove = cell2mat(path_test_remove);
    system(path_test_remove);
    path_test_create = strcat({'mkdir'},{' '},{path_test_result}); % crfeate a new folder
    path_test_create = cell2mat(path_test_create);
    system(path_test_create);
end



%% =======================================================================
% EACH TIME STEP
%=========================================================================
% pA = model.pa;
% pA = pA();
maxStep = 50; % using dt = dx/|u|
voldSTD = zeros(msh.nStd,1); % initial vh for velocity grad v

disp('Starting the loop...');
%% loop
for ns = 1:maxStep
    disp('-----------------------------');
    fprintf('Step= %d\n',ns);
    nf = 0; % reset every loop to be sure uh, vh plotted on the same figure
    
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
        fprintf("%fs\n",toc-time);
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
    
    
    
    %% top-most Dirichlet nodes
    % Only apply Dirichlet bc on the distance above top most biofilm height
    disp('Find top-most points...');
    yTop = max(points(2,nodeCTs.all)) + pa.L;    
    if ~isempty(CTs)
        DNodes = find(points(2,:) >= yTop); % all nodes will be applied Dirichlet condition
    else
        DNodes = [];
    end
    
    
    %% plot phi
    if showPlot
        tic;time=0;
        fprintf('Plotting phi... ');
        titlePlot = strcat('phi, step = ',num2str(ns));
        nf = plotNXFEM(msh,pa,phi,iPs,nf,phi,'withMesh',withMesh,...
                'title',titlePlot,'dim',2,'export',false); % phi
        fprintf("%fs\n",toc-time);
    end
    
    
    %% =======================================================================
    % CONTROL PARAMETERS
    % depend on mesh and different for w and u
    % in child-functions, it's the variable 'cp'
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
    fprintf('Solving u (');
    
    % initial of iterative steps
    uold = zeros(msh.ndof,1);
    if ~isempty(DNodes)
        uold(DNodes,1) = pa.bcu3;
    else
        uold(b3Nodes,1) = pa.bcu3;
    end
    if ns ~= 1 % take the previous step as an initial (only on std nodes)
        uold(msh.node.std) = unew(msh.node.std); % initial of the iterative method
    end
    
    difu = 100; % initial, harmless
    imax = 50;
    step = 0;
    defFu = model.defFu;
    defG = defGu;
    
    tic;time=0;
    if ~useNewton
        fprintf('Normal fixed point method)\n');
    else
        fprintf('Using Newton method)\n');
    end
    while (difu > itol) && (step<imax)
        step = step+1;
        uoldEach = getWsep(uold,msh,1,1); % analyze numSolu into each subdomain
        if ~useNewton % don't wanna use Newton method
            
            
            Au = getGMGG(tris,phi,CT,msh,pa,cpU);

            % Load vector (all nodes including nodes on boundary)
            %-------------------------------------------------------------------------
            Fu = getLfgu(msh,pa,tris,CT,uoldEach,defFu,defG.change,-pa.f*pa.muS1,-pa.f*pa.muS2);
            
            
            % BCs u
            %-------------------------------------------------------------------------
            unew = zeros(msh.ndof,1); % column-array

            if ~isempty(DNodes)
                unew(DNodes,1) = pa.bcu3;
            else
                unew(b3Nodes,1) = pa.bcu3;
            end


            % Solving u
            %----------------------------------------------------------------------
            Fu = Fu - Au*unew; % modification of F

            % LU factorization
            unew(iNodes) = Au(iNodes,iNodes)\Fu(iNodes); % don't care nodes on boundary
            % unew(iNodes) = gmres(Au(iNodes,iNodes),Fu(iNodes));   % GMRES factorization

            del = unew - uold;
            
             % update for the next step of iterative loop
            uold = unew;
        else % if use Newton
            % DF(u)del 
            coef.omg1 = pa.f*pa.muS1; coef.omg2 = pa.f*pa.muS2;
            Adel = getGMgPP(msh,pa,cpU,tris,CT,phi,uoldEach,defG.dchange,coef);
            
            % F(u)
            coef.omg1 = pa.f*pa.muS1; coef.omg2 = pa.f*pa.muS2;
            Au = getGMgPP(msh,pa,cpU,tris,CT,phi,uoldEach,defG.change,coef);
            Fdel = Au*uold;
            
            % bc for del
            del = zeros(msh.ndof,1);
            del(bNodes) = 0; % always
            
            % solve for del
            Fdel = Fdel - Adel*del;
            % LU
            del(iNodes) = Adel(iNodes,iNodes)\Fdel(iNodes);
%             del(iNodes) = gmres(Adel(iNodes,iNodes),Fdek(iNodes)); % GMRES
        
            % get unew
            unew = zeros(msh.ndof,1); % reset its size every
            unew(bNodes,1) = uold(bNodes,1) - del(bNodes,1);
            if ~isempty(DNodes)
                unew(DNodes,1) = pa.bcu3;
            else
                unew(b3Nodes,1) = pa.bcu3;
            end
            unew(iNodes,1) = uold(iNodes,1) - del(iNodes,1); % u_i+1 = u_i - del, update
            
            % update uold for the next step of Newton loop
            uold = unew;
        end
       
        delL2 = getNormL2fhNX(del,tris,CT,msh,pa);
        Uip1L2 = getNormL2fhNX(uold,tris,CT,msh,pa);
        difu = delL2/Uip1L2; % |del|_L2/|u_i+1|_L2
        fprintf('___difu: %0.18f\n',difu);
    end
    fprintf('End of loop finding u...%fs\n',toc-time);
    
    
    %% ====================================================================
    % SOLVING V
    %======================================================================
    fprintf('Solving v... ');tic;time=0;
    
    % Stiffness matrix (all nodes including nodes on boundary)
    %----------------------------------------------------------------------
    Av = getGM_Chopp07v(tris,phi,CT,msh,pa,cpV);

    
    % Load vector (all nodes including nodes on boundary)
    %----------------------------------------------------------------------
    uSep = getWsep(unew,msh,1,1);
    Fv = getLfgu(msh,pa,tris,CT,uSep,defFu,defG.change,-pa.f*pa.muP1,-pa.f*pa.muP2);


    
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
    fprintf("%fs\n",toc-time);
    
    
    
    %% ====================================================================
    % u and v in std Vh
    %======================================================================
    disp('Converting u, v to STD...');
    unewSTD = interNX2STD(unew,msh);
    vnewSTD = interNX2STD(vnew,msh);
    
    
    %% grad v
    [gvnew.x,gvnew.y] = pdegrad(points,triangles,vnewSTD);
    [gvold.x,gvold.y] = pdegrad(points,triangles,voldSTD);
    
    % plot gvnew
    if plotGradv && showPlot
        disp('Show plots of grad(v)...');
    %     pdeplot(points,edges,triangles(1:3,:),'FlowData',[gvnew.x; gvnew.y]); % plot on the whole mesh

        % plot on the cut triangles only
        figure(nf); nf=nf+1;
        pdemesh(points,edges,triangles); % plot mesh
        hold on;
        plotInterface(msh,pa,phi,iPs); % plot the interface
        gvx = gvnew.x; gvy = gvnew.y;
        gvx(1,NCTs1(5,:))=0; gvy(1,NCTs1(5,:))=0;
        gvx(1,NCTs2(5,:))=0; gvy(1,NCTs2(5,:))=0;
        pdeplot(points,edges,triangles(1:3,:),'FlowData',[gvx; gvy]); 
        hold off;
    end
    
    
    %% ====================================================================
    % PLOT u and v
    %======================================================================
    if showPlot
%         nf = plotNXFEM(msh,pa,phi,iPs,nf,'eleLabel','off','nodeLabel','off'); % only mesh

        disp('Plotting u...');
        titlePlot = strcat('uh, step = ',num2str(ns));
        nf = plotNXFEM(msh,pa,phi,iPs,nf,unewSTD,'withMesh',withMesh,'title',titlePlot); % uh

        disp('Plotting v...');
        titlePlot = strcat('vh, step = ',num2str(ns));
        nf = plotNXFEM(msh,pa,phi,iPs,nf,vnewSTD,'withMesh',withMesh,'title',titlePlot); % vh
    end % end if showPlot
    
    
    
    %% SAVE PLOT
    if savePlot
        tic;time=0;
        fprintf("Saving plots... ");
        f=figure('visible','off');
        % save phi
        titlePlot = strcat('phi, step = ',num2str(ns));
        plotNXFEM(msh,pa,phi,iPs,nf,phi,'withMesh',withMesh,...
                'title',titlePlot,'dim',2,'export',false); % phi
        fileName = strcat(path_test_result,'/phi_','_','step_',num2str(ns),'.png');
        % change size of images
        oldpaperunits = get(gcf,'PaperUnits');
        oldpaperpos = get(gcf,'PaperPosition');
        fig = gcf;
        fig.PaperUnits = 'inches';
        fig.PaperPosition = [0 0 8 6];
        print(fileName,'-dpng','-r0');
        close(f);
        
        % uh
        f=figure('visible','off');
        titlePlot = strcat('uh, step = ',num2str(ns));
        plotNXFEM(msh,pa,phi,iPs,nf,unewSTD,'withMesh',withMesh,...
                        'title',titlePlot); % uh
        fileName = strcat(path_test_result,'/uh_',num2str(0),...
                        '_','step_',num2str(ns),'.png');
        print(fileName,'-dpng','-r0');
        close(f);
        
        % vh
        f=figure('visible','off');
        titlePlot = strcat('vh, step = ',num2str(ns));
        plotNXFEM(msh,pa,phi,iPs,nf,vnewSTD,'withMesh',withMesh,...
                        'title',titlePlot); % vh
        fileName = strcat(path_test_result,'/vh_',num2str(0),...
                        '_','step_',num2str(ns),'.png');
        print(fileName,'-dpng','-r0');
        close(f);
        
        fprintf("%fs\n",toc-time);
    end
    
    
    
    %% ====================================================================
    % SOLVING phi (level set function)
    % standard finite element
    %======================================================================
    disp('Solving level set phi...');
    
    % get del_T
    if useSUPG
        delOld = getDellsT(msh,gvold,delEps,delSD); % Arnold's book p.223
        delNew = getDellsT(msh,gvnew,delEps,delSD);
    else
        delOld = zeros(1,size(msh.t,2)); % without SUPG
        delNew = delOld;
    end
    
    
    % dt
    maxGradV = max(abs(gvnew.x) + abs(gvnew.y));
    dt = msh.hTmax/maxGradV;
    
    
    % stiffness matrix for level set
    %----------------------------------------------------------------------
    tic;time=0;
    fprintf('Get stiffness matrix Enew, Hnew... ');
    Enew = getMElsGP(msh,pa,gvnew,delNew,1);
    Hnew = getMHlsGP(msh,pa,gvnew,delNew,dt*0.5);
    mI = speye(msh.nStd); % identity matrix
    Aphi = mI + Enew^(-1)*Hnew;
    fprintf("%fs\n",toc-time);
    
    
    % load vector for level set
    %----------------------------------------------------------------------
    tic;time=0;
    fprintf('Get load vector (Eold, Hold, Afphi)... ');
    Eold = getMElsGP(msh,pa,gvold,delOld,1);
    Hold = getMHlsGP(msh,pa,gvold,delOld,dt*0.5);
    AFphi = mI - Eold^(-1)*Hold;
    phi = phi';             % row to column
    Fphi = AFphi*phi;
    fprintf("%fs\n",toc-time);
    
    
    % seek phi
    %----------------------------------------------------------------------
    disp('Updating phi...');
    phi = Aphi\Fphi;        % update phi
    phi = phi';             % column to row
    
    
    %% update v
    disp('Updating v...');
    voldSTD = vnewSTD;
    
    
    %% Reinitialization
    %----------------------------------------------------------------------
    norm_gradphi = getNormL2GfhSTD(msh,phi); % ||gradPhi||_L2
    todisplayed = ['|1-norm_gradphi| = ',num2str(abs(1-norm_gradphi))];
    disp(todisplayed);
    
%     if useFMM && abs(1-norm_gradphi) > alp_FMM && numUse <=1
    if useFMM && abs(1-norm_gradphi) > alp_FMM
        disp('Starting to use FMM...');
        mshdist_w_sol(msh,phi,path_phi,'phi'); % export to phi.sol
        system(call_mshdist); % run 'mshdist file/to/phi' (redistancing)
        phi = mshdist_r_sol(phi,path_phi,'phi'); % update phi
        numUseFMM = numUseFMM + 1;
    end
    
end % for ns


if savePlot
   % Save parameters' info to file
    fileName = strcat(path_test_result,'/parameters_',num2str(nSeg),'.txt');
    fileID = fopen(fileName,'w');
        fprintf(fileID,'Machine: %s,\n',machine);
        fprintf(fileID,'Model: %s,\n',model.name);
        fprintf(fileID,'ndof: %d,\n',msh.dof);
        fprintf(fileID,'hTmax: %0.10f,\n',hTmax);
        fprintf(fileID,'Regular mesh: %d,\n',reguMesh);
        fprintf(fileID,'Use small-cut: %d,\n',pa.smallCut);
        fprintf(fileID,'\n');
        fprintf(fileID,'Use FMM: %d,\n',useFMM);
        fprintf(fileID,'__al_FMM: %f,\n',alp_FMM);
        fprintf(fileID,'__numUseFMM: %d,\n',numUseFMM);
        fprintf(fileID,'\n');
        fprintf(fileID,'useSUPG: %d,\n',useSUPG);
        fprintf(fileID,'__delEps: %f,\n',delEps);
        fprintf(fileID,'__delSD: %f,\n',delSD);
        fprintf(fileID,'\n');
        fprintf(fileID,'use Ghost penalty: %d,\n',pa.useGP);
        fprintf(fileID,'__gam1: %f,\n',pa.gam1);
        fprintf(fileID,'__gam2: %f,\n',pa.gam2);
%         fprintf(fileID,'CFL: ');
%         for iclf = 1:size(CFL,2)
%             fprintf(fileID,'%0.2f, ',CFL(1,iclf));
%         end
        fprintf(fileID,'\n');
    fclose(fileID); 
end


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