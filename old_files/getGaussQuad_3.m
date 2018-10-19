function [wt,pt] = getGaussQuad_3(dim,deg)
% Get information of Gaussian quadrature (points and weights)
% IMPORTANCE: 
%       - In 1D : the result is exact for polynomial with degree up to 2deg-1
%       - In 2D : the result is exact for polynomial with degree up to deg
% Input: dimension and degree
% Output: weights and points. In dim 2: 
%              - wt = 1 x number of points
%              - pt = 2 coordinates x number of points

if dim==1 % dimension 1 for int_0^1
    switch deg
        case 1 % 1 point
            wt = [2.000000000000000];
            pt = [0.000000000000000];
        case 2 % 2 points
            wt = [1.000000000000000 1.000000000000000];
            pt = [-0.577350269189626 0.577350269189626];
        case 3 % 3 points
            wt = [0.555555555555556 0.888888888888889 0.555555555555556];
            pt = [-0.774596669241483 0.000000000000000 0.774596669241483];
        case 4 % 4 points
            wt = [0.347854845137454 0.652145154862546 0.652145154862546 0.347854845137454];
            pt = [-0.861136311594053 -0.339981043584856 0.339981043584856 0.861136311594053];
        case 5 % 5 points
            wt = [0.568888888888889 0.478628670499366 0.478628670499366 0.236926885056189 0.236926885056189];
            pt = [0 -0.538469310105683 0.538469310105683 0.906179845938664 0.906179845938664];
    end % end of switch dim 1
else % dimension 2 for triangle 011
    switch deg
        case 1 % degree 1, 1 point
            wt = [1.00000000000000];
            pt = [0.33333333333333; 0.33333333333333];
        case 2 % degree 2, 3 points
            wt = [0.33333333333333 0.33333333333333 0.33333333333333];
            pt = [0.50000000000000 0.50000000000000 0.00000000000000;
                  0.50000000000000 0.00000000000000 0.50000000000000];
        case 3 % degree 3, 4 points
            wt = [-0.56250000000000 0.52083333333333 0.52083333333333 0.52083333333333];
            pt = [0.33333333333333 0.20000000000000 0.20000000000000 0.60000000000000;
                  0.33333333333333 0.20000000000000 0.60000000000000 0.20000000000000];
        case 4 % degree 4, 6 points
            wt = [0.22338158967801 0.22338158967801 0.22338158967801 0.10995174365532 0.10995174365532 0.10995174365532];
            pt = [0.44594849091597 0.44594849091597 0.10810301816807 0.09157621350977 0.09157621350977 0.81684757298046;
                  0.44594849091597 0.10810301816807 0.44594849091597 0.09157621350977 0.81684757298046 0.09157621350977];
        case 5 % degree 5, 7 points
            wt = [0.22500000000000 0.13239415278851 0.13239415278851 0.13239415278851 0.12593918054483 0.12593918054483 0.12593918054483];
            pt = [0.33333333333333 0.47014206410511 0.47014206410511 0.05971587178977 0.10128650732346 0.10128650732346 0.79742698535309;
                  0.33333333333333 0.47014206410511 0.05971587178977 0.47014206410511 0.10128650732346 0.79742698535309 0.10128650732346];
        case 6 % degree 6, 12 points
            wt = [0.11678627572638 0.11678627572638 0.11678627572638 0.05084490637021 0.05084490637021 0.05084490637021 0.05084490637021 0.05084490637021 0.05084490637021 0.05084490637021 0.05084490637021 0.05084490637021];
            pt = [0.24928674517091 0.24928674517091 0.50142650965818 0.06308901449150 0.06308901449150 0.87382197101700 0.31035245103378 0.63650249912140 0.05314504984482 0.63650249912140 0.31035245103378 0.05314504984482;
                  0.24928674517091 0.50142650965818 0.24928674517091 0.06308901449150 0.87382197101700 0.06308901449150 0.63650249912140 0.05314504984482 0.31035245103378 0.31035245103378 0.05314504984482 0.63650249912140];
    end % end of switch dim 2
end % end of if dim

end