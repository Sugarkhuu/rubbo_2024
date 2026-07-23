function [residual, g1] = static_resid_g1(T, y, x, params, T_flag)
% function [residual, g1] = static_resid_g1(T, y, x, params, T_flag)
%
% Wrapper function automatically created by Dynare
%

    if T_flag
        T = oen_rppers_chile_1p0000_0p4000_peg.static_g1_tt(T, y, x, params);
    end
    residual = oen_rppers_chile_1p0000_0p4000_peg.static_resid(T, y, x, params, false);
    g1       = oen_rppers_chile_1p0000_0p4000_peg.static_g1(T, y, x, params, false);

end
