function [residual, g1] = static_resid_g1(T, y, x, params, T_flag)
% function [residual, g1] = static_resid_g1(T, y, x, params, T_flag)
%
% Wrapper function automatically created by Dynare
%

    if T_flag
        T = rv_si_cpi_it_2p00_5p00_0p00.static_g1_tt(T, y, x, params);
    end
    residual = rv_si_cpi_it_2p00_5p00_0p00.static_resid(T, y, x, params, false);
    g1       = rv_si_cpi_it_2p00_5p00_0p00.static_g1(T, y, x, params, false);

end
