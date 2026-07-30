function [residual, g1, g2] = static_resid_g1_g2(T, y, x, params, T_flag)
% function [residual, g1, g2] = static_resid_g1_g2(T, y, x, params, T_flag)
%
% Wrapper function automatically created by Dynare
%

    if T_flag
        T = rv_dm_float_1p00_3p00_0p00.static_g2_tt(T, y, x, params);
    end
    [residual, g1] = rv_dm_float_1p00_3p00_0p00.static_resid_g1(T, y, x, params, false);
    g2       = rv_dm_float_1p00_3p00_0p00.static_g2(T, y, x, params, false);

end
