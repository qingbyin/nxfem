function [wt,pt] = getGaussQuad(dim,deg)
% Get information of Gaussian quadrature (points and weights)
% IMPORTANCE: 
%       - In 1D : the result is exact for polynomial with degree up to 2deg-1
%       - In 2D : the result is exact for polynomial with degree up to deg
% Input: dimension and degree
% Output: weights and points. In dim 2: 
%              - wt = 1 x number of points
%              - pt = 2 coordinates x number of points

if dim==1 % dimension 1 for int_-1^1
    % comparing to file quadrature1D.pdf
    switch deg
        case 1 % 1 point
            wt = [2];
            pt = [0];
        case 2 % 2 points
            wt = [1 1];
            pt = [-1/sqrt(3) 1/sqrt(3)];
        case 3 % 3 points
            wt = [5/9 8/9 5/9];
            pt = [-sqrt(3)/sqrt(5) 0 sqrt(3)/sqrt(5)];
        case 4 % 4 points
            wt = [1/2-(1/6)*sqrt(5)/sqrt(6) 1/2+(1/6)*sqrt(5)/sqrt(6) 1/2+(1/6)*sqrt(5)/sqrt(6) 1/2-(1/6)*sqrt(5)/sqrt(6)];
            pt = [-sqrt((1/35)*(15+2*sqrt(30))) -sqrt((1/35)*(15-2*sqrt(30))) sqrt((1/35)*(15-2*sqrt(30))) sqrt((1/35)*(15+2*sqrt(30)))];
        case 5 % 5 points
            wt = [128/225 161/450+13*sqrt(70)/900 161/450+13*sqrt(70)/900 161/450-13*sqrt(70)/900 161/450-13*sqrt(70)/900];
            pt = [0 -(1/3)*sqrt(5-2*sqrt(10/7)) (1/3)*sqrt(5-2*sqrt(10/7)) -(1/3)*sqrt(5+2*sqrt(10/7)) (1/3)*sqrt(5+2*sqrt(10/7))];
    end % end of switch dim 1
else % dimension 2 for triangle 011
    switch deg
        case 1 % degree 1, 1 point
            wt = [1];
            pt = [1/3;1/3];
        case 2 % degree 2, 3 points
            wt = [1/3 1/3 1/3];
            pt = [1/2 1/2 0;
                  1/2 0 1/2];
        case 3 % degree 3, 4 points
            wt = [-27/48 25/48 25/48 25/48];
            pt = [1/3 1/5 1/5 3/5;
                  1/3 1/5 3/5 1/5];
        case 4 % degree 4, 6 points
            wt = [0.22338158967801 0.22338158967801 0.22338158967801 0.10995174365532 0.10995174365532 0.10995174365532];
            pt = [0.44594849091597 0.44594849091597 0.10810301816807 0.09157621350977 0.09157621350977 0.81684757298046;
                  0.44594849091597 0.10810301816807 0.44594849091597 0.09157621350977 0.81684757298046 0.09157621350977];
        case 5 % degree 5, 7 points
            wt = [9/40 31/240+sqrt(15)/1200 31/240+sqrt(15)/1200 31/240+sqrt(15)/1200 31/240-sqrt(15)/1200 31/240-sqrt(15)/1200 31/240-sqrt(15)/1200];
            pt = [1/3 2/7+sqrt(15)/21 2/7+sqrt(15)/21 3/7-2*sqrt(15)/21 2/7-sqrt(15)/21 2/7-sqrt(15)/21 3/7+2*sqrt(15)/21;
                  1/3 2/7+sqrt(15)/21 3/7-2*sqrt(15)/21 2/7+sqrt(15)/21 2/7-sqrt(15)/21 3/7+2*sqrt(15)/21 2/7-sqrt(15)/21];
        case 6 % degree 6, 12 points
            wt = [0.11678627572638 0.11678627572638 0.11678627572638 0.05084490637021 0.05084490637021 0.05084490637021 0.08285107561837 0.08285107561837 0.08285107561837 0.08285107561837 0.08285107561837 0.08285107561837];
            pt = [0.24928674517091 0.24928674517091 0.50142650965818 0.06308901449150 0.06308901449150 0.87382197101700 0.31035245103378 0.63650249912140 0.05314504984482 0.63650249912140 0.31035245103378 0.05314504984482;
                  0.24928674517091 0.50142650965818 0.24928674517091 0.06308901449150 0.87382197101700 0.06308901449150 0.63650249912140 0.05314504984482 0.31035245103378 0.31035245103378 0.05314504984482 0.63650249912140];
        case 7 % degree 7, 13 points
            wt = [-0.149570044467680 0.175615257433210 0.175615257433210 0.175615257433210 0.0533472356088400 0.0533472356088400 0.0533472356088400 0.0771137608902600 0.0771137608902600 0.0771137608902600 0.0771137608902600 0.0771137608902600 0.0771137608902600];
            pt = [0.333333333333330 0.260345966079040 0.260345966079040 0.479308067841920 0.0651301029022200  0.0651301029022200  0.869739794195570 0.312865496004870 0.638444188569810 0.0486903154253200  0.638444188569810 0.312865496004870 0.0486903154253200;
                  0.333333333333330 0.260345966079040 0.479308067841920 0.260345966079040 0.0651301029022200  0.869739794195570 0.0651301029022200  0.638444188569810 0.0486903154253200  0.312865496004870 0.312865496004870 0.0486903154253200 0.638444188569810];
        case 8 % degree 8, 16 points
            wt = [0.144315607677790 0.0950916342672800 0.0950916342672800 0.0950916342672800 0.103217370534720 0.103217370534720 0.103217370534720 0.0324584976232000 0.0324584976232000 0.0324584976232000 0.0272303141744300 0.0272303141744300 0.0272303141744300 0.0272303141744300 0.0272303141744300 0.0272303141744300];
            pt = [0.333333333333330 0.459292588292720 0.459292588292720 0.0814148234145500 0.170569307751760 0.170569307751760 0.658861384496480 0.0505472283170300 0.0505472283170300 0.898905543365940 0.263112829634640 0.728492392955400 0.00839477740996000 0.728492392955400 0.263112829634640 0.00839477740996000;
                  0.333333333333330 0.459292588292720 0.0814148234145500 0.459292588292720 0.170569307751760 0.658861384496480 0.170569307751760 0.0505472283170300 0.898905543365940 0.0505472283170300 0.728492392955400 0.00839477740996000 0.263112829634640 0.263112829634640 0.00839477740996000 0.728492392955400];
        case 9 % degree 8, 19 points
            wt = [0.0971357962828000 0.0313347002271400 0.0313347002271400 0.0313347002271400 0.0778275410047700 0.0778275410047700 0.0778275410047700 0.0796477389272100 0.0796477389272100 0.0796477389272100 0.0255776756587000 0.0255776756587000 0.0255776756587000 0.0432835393772900 0.0432835393772900 0.0432835393772900 0.0432835393772900 0.0432835393772900 0.0432835393772900];
            pt = [0.333333333333330 0.489682519198740 0.489682519198740 0.0206349616025200 0.437089591492940 0.437089591492940 0.125820817014130 0.188203535619030 0.188203535619030 0.623592928761930 0.0447295133944500 0.0447295133944500 0.910540973211090 0.221962989160770 0.741198598784500 0.0368384120547400 0.741198598784500 0.221962989160770 0.0368384120547400;
                  0.333333333333330 0.489682519198740 0.0206349616025200 0.489682519198740 0.437089591492940 0.125820817014130 0.437089591492940 0.188203535619030 0.623592928761930 0.188203535619030 0.0447295133944500 0.910540973211090 0.0447295133944500 0.741198598784500 0.0368384120547400 0.221962989160770 0.221962989160770 0.0368384120547400 0.741198598784500];
        case 10 % degree 10, 25 points
            wt = [0.0908179903827500 0.0367259577564700 0.0367259577564700 0.0367259577564700 0.0453210594355300 0.0453210594355300 0.0453210594355300 0.0727579168454200 0.0727579168454200 0.0727579168454200 0.0727579168454200 0.0727579168454200 0.0727579168454200 0.0283272425310600 0.0283272425310600 0.0283272425310600 0.0283272425310600 0.0283272425310600 0.0283272425310600 0.00942166696373000 0.00942166696373000 0.00942166696373000 0.00942166696373000 0.00942166696373000 0.00942166696373000];
            pt = [0.333333333333330 0.485577633383660 0.485577633383660 0.0288447332326900 0.109481575485040 0.109481575485040 0.781036849029930 0.307939838764120 0.550352941821000 0.141707219414880 0.550352941821000 0.307939838764120 0.141707219414880 0.246672560639900 0.728323904597410 0.0250035347626900 0.728323904597410 0.246672560639900 0.0250035347626900 0.0668032510122000 0.923655933587500 0.00954081540030000 0.923655933587500 0.0668032510122000 0.00954081540030000;
                  0.333333333333330 0.485577633383660 0.0288447332326900 0.485577633383660 0.109481575485040 0.781036849029930 0.109481575485040 0.550352941821000 0.141707219414880 0.307939838764120 0.307939838764120 0.141707219414880 0.550352941821000 0.728323904597410 0.0250035347626900 0.246672560639900 0.246672560639900 0.0250035347626900 0.728323904597410 0.923655933587500 0.00954081540030000 0.0668032510122000 0.0668032510122000 0.00954081540030000 0.923655933587500];
        case 11 % degree 11, 27 points
            wt = [0.000927006328960000 0.000927006328960000 0.000927006328960000 0.0771495349148100 0.0771495349148100 0.0771495349148100 0.0593229773807700 0.0593229773807700 0.0593229773807700 0.0361845405034200 0.0361845405034200 0.0361845405034200 0.0136597310026800 0.0136597310026800 0.0136597310026800 0.0523371119622000 0.0523371119622000 0.0523371119622000 0.0523371119622000 0.0523371119622000 0.0523371119622000 0.0207076596391400 0.0207076596391400 0.0207076596391400 0.0207076596391400 0.0207076596391400 0.0207076596391400];
            pt = [0.534611048270760 0.534611048270760 -0.0692220965415200 0.398969302965850 0.398969302965850 0.202061394068290 0.203309900431280 0.203309900431280 0.593380199137440 0.119350912282580 0.119350912282580 0.761298175434840 0.0323649481112800 0.0323649481112800 0.935270103777450 0.356620648261290 0.593201213428210 0.0501781383105000 0.593201213428210 0.356620648261290 0.0501781383105000 0.171488980304040 0.807489003159790 0.0210220165361700 0.807489003159790 0.171488980304040 0.0210220165361700;
                  0.534611048270760 -0.0692220965415200 0.534611048270760 0.398969302965850 0.202061394068290 0.398969302965850 0.203309900431280 0.593380199137440 0.203309900431280 0.119350912282580 0.761298175434840 0.119350912282580 0.0323649481112800 0.935270103777450 0.0323649481112800 0.593201213428210 0.0501781383105000 0.356620648261290 0.356620648261290 0.0501781383105000 0.593201213428210 0.807489003159790 0.0210220165361700 0.171488980304040 0.171488980304040 0.0210220165361700 0.807489003159790];
        case 12 % degree 12, 33 points
            wt = [0.0257310664404500 0.0257310664404500 0.0257310664404500 0.0436925445380400 0.0436925445380400 0.0436925445380400 0.0628582242178900 0.0628582242178900 0.0628582242178900 0.0347961129307100 0.0347961129307100 0.0347961129307100 0.00616626105156000 0.00616626105156000 0.00616626105156000 0.0403715577663800 0.0403715577663800 0.0403715577663800 0.0403715577663800 0.0403715577663800 0.0403715577663800 0.0223567732023000 0.0223567732023000 0.0223567732023000 0.0223567732023000 0.0223567732023000 0.0223567732023000 0.0173162311086600 0.0173162311086600 0.0173162311086600 0.0173162311086600 0.0173162311086600 0.0173162311086600];
            pt = [0.488217389773810 0.488217389773810 0.0235652204523900 0.439724392294460 0.439724392294460 0.120551215411080 0.271210385012120 0.271210385012120 0.457579229975770 0.127576145541590 0.127576145541590 0.744847708916830 0.0213173504532100 0.0213173504532100 0.957365299093580 0.275713269685510 0.608943235779790 0.115343494534700 0.608943235779790 0.275713269685510 0.115343494534700 0.281325580989940 0.695836086787800 0.0228383322222600 0.695836086787800 0.281325580989940 0.0228383322222600 0.116251915907600 0.858014033544070 0.0257340505483300 0.858014033544070 0.116251915907600 0.0257340505483300;
                  0.488217389773810 0.0235652204523900 0.488217389773810 0.439724392294460 0.120551215411080 0.439724392294460 0.271210385012120 0.457579229975770 0.271210385012120 0.127576145541590 0.744847708916830 0.127576145541590 0.0213173504532100 0.957365299093580 0.0213173504532100 0.608943235779790 0.115343494534700 0.275713269685510 0.275713269685510 0.115343494534700 0.608943235779790 0.695836086787800 0.0228383322222600 0.281325580989940 0.281325580989940 0.0228383322222600 0.695836086787800 0.858014033544070 0.0257340505483300 0.116251915907600 0.116251915907600 0.0257340505483300 0.858014033544070];
    end % end of switch dim 2
end % end of if dim


end