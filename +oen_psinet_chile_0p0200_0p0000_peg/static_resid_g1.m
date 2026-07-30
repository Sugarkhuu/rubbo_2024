function [residual, g1] = static_resid_g1(T, y, x, params, T_flag)
% function [residual, g1] = static_resid_g1(T, y, x, params, T_flag)
%
% Wrapper function automatically created by Dynare
%

    if T_flag
        T = oen_psinet_chile_0p0200_0p0000_peg.static_g1_tt(T, y, x, params);
    end
    residual = oen_psinet_chile_0p0200_0p0000_peg.static_resid(T, y, x, params, false);
    g1       = oen_psinet_chile_0p0200_0p0000_peg.static_g1(T, y, x, params, false);

end
