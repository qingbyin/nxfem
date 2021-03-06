%% This is a function handles containing all information about model for Chopp06combine
% It's corresponding to 
%       - file main_chopp06combine.m
%       - file hw_chopp06combine.pdf


%% =======================================================================
% DOMAIN: [0,0.5]X[0,0.5], inital interface: half of circle ((0.25,0);r0)
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



%% Setting up
function fh = model_chopp06combine
    fh.name = 'model_chopp06combine';
    fh.defFu = @findDefFu;      % RHS of equation of u
    fh.defFv = @findDefFv;      % RHS of equation of v
    fh.defPhi = @findDefPhi;    % interface
    fh.domain = @findDomain;    % domain setting
    fh.kapU = @findKapV;        % kappa for u's equation
    fh.kapV = @findKapV;        % kappa for u's equation
    fh.lamU = @findLamV;        % lambda for u's equation
    fh.lamV = @findLamV;        % lambda for u's equation
end



%% Domain
function GeoDom = findDomain()
    xDomVal = [0 0.5 0.5 0]; % x values of points constructing Omega
    yDomVal = [0 0 0.5 0.5]; % corresponding y value
    RectDom = [3,4,xDomVal,yDomVal]'; % rectangular domain "3" with "4" sides
    GeoDom = decsg(RectDom);
end




%% F
% (only constant or given function f(x,y)
% Don't contains something like g(u) where we're computing v
function valF = findDefFu(xx,yy,pa,sub)
    % Define right hand side function f
    % Input: coordinate of points + indication subdomain
    % Output: value of phi at points
    valF = 0;
end

function valF = findDefFv(xx,yy,pa,sub)
    % Define right hand side function fu
    % Input: coordinate of points + indication subdomain
    % Output: value of F at points
    valF = 0;
end


%% Interface
function valPhi=findDefPhi(xx,yy,pa)
    % Define level set function phi
    % Input: coordinate of points
    % Output: value of phi at points
    
    if ~pa.phiNew
        valPhi = sqrt((xx-0.25).^2 + yy.^2) - pa.r0; % semi circle (no need to initialize)
    %     valPhi = pa.a^2*(xx-0.5).^2 + yy.^2/(pa.a^2) - pa.r0^2; % need to use mshdist to initilize to be a signed distance function
    else
        valPhi = (yy-pa.phiHeight) + pa.phiNoise*cos(4*pi*xx/0.5); % need to initialize
    end

end


%% Kappa
%-------------------------------------------------------------------------
function kap = findKapV(cp,CT,pa)
    % for seeking u and v
    % kapi : 1 x nCTs
    
    if pa.useGP
        nCTs = size(CT.areaChild,2);
        kap.kap1 = zeros(1,nCTs) + cp.kk2/(cp.kk1+cp.kk2);
        kap.kap2 = zeros(1,nCTs) + cp.kk1/(cp.kk1+cp.kk2);
    else
        kap.kap1 = cp.kk2*CT.areaChild(1,:) ./ (cp.kk1*CT.areaChild(2,:) + cp.kk2*CT.areaChild(1,:));
        kap.kap2 = cp.kk1*CT.areaChild(2,:) ./ (cp.kk1*CT.areaChild(2,:) + cp.kk2*CT.areaChild(1,:));
    end
end


%% Lambda
%-------------------------------------------------------------------------
function lam = findLamV(cp,hTCTs,CT,pa)
    % lam: 1 x nCTs
    nCTs = size(hTCTs, 2);
    
    if pa.useGP
        coef = 4*cp.lamH*cp.kk1*cp.kk2/(cp.kk1+cp.kk2);
%         lam = coef./hTCTs;              % belongs to hT
        lam = zeros(1,nCTs) + coef;   % not belong to hT
    else
        lenAB = zeros(1,nCTs); % nCTs x 1
        lenAB(1,:) = ( (CT.iPs(1,2,:) - CT.iPs(1,1,:)).^2 + (CT.iPs(2,2,:) - CT.iPs(2,1,:)).^2 ) .^(0.5);
        coef = cp.lamH*cp.kk1*cp.kk2 .* lenAB...
            ./(cp.kk2*CT.areaChild(1,:) + cp.kk1*CT.areaChild(2,:));
        lam = coef./hTCTs;              % belongs to hT
%         lam = zeros(1,nCTs) + coef;   % not belong to hT
    end
end