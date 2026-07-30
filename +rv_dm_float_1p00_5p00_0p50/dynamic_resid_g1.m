function [residual, g1] = dynamic_resid_g1(T, y, x, params, steady_state, it_, T_flag)
% function [residual, g1] = dynamic_resid_g1(T, y, x, params, steady_state, it_, T_flag)
%
% Wrapper function automatically created by Dynare
%

    if T_flag
        T = rv_dm_float_1p00_5p00_0p50.dynamic_g1_tt(T, y, x, params, steady_state, it_);
    end
    residual = rv_dm_float_1p00_5p00_0p50.dynamic_resid(T, y, x, params, steady_state, it_, false);
    g1       = rv_dm_float_1p00_5p00_0p50.dynamic_g1(T, y, x, params, steady_state, it_, false);

end
