function [T_order, T] = static_g1_tt(y, x, params, T_order, T)
if T_order >= 1
    return
end
[T_order, T] = oen_rpchile_1p5000_peg.sparse.static_resid_tt(y, x, params, T_order, T);
T_order = 1;
if size(T, 1) < 54
    T = [T; NaN(54 - size(T, 1), 1)];
end
T(45) = getPowerDeriv(y(7)/y(38),(-params(30)),1);
T(46) = getPowerDeriv(y(8)/y(38),(-params(30)),1);
T(47) = getPowerDeriv(y(9)/y(38),(-params(30)),1);
T(48) = getPowerDeriv(y(10),params(4)-1,1);
T(49) = getPowerDeriv(y(11),params(4)-1,1);
T(50) = getPowerDeriv(y(12),params(4)-1,1);
T(51) = getPowerDeriv(y(28),(-params(2)),1);
T(52) = getPowerDeriv(T(36),1/(1-params(28)),1);
T(53) = getPowerDeriv(y(31)/y(32),(-params(28)),1);
T(54) = getPowerDeriv(y(38)/y(32),(-params(28)),1);
end
