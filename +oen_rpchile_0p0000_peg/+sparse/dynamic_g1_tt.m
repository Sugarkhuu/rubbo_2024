function [T_order, T] = dynamic_g1_tt(y, x, params, steady_state, T_order, T)
if T_order >= 1
    return
end
[T_order, T] = oen_rpchile_0p0000_peg.sparse.dynamic_resid_tt(y, x, params, steady_state, T_order, T);
T_order = 1;
if size(T, 1) < 61
    T = [T; NaN(61 - size(T, 1), 1)];
end
T(54) = getPowerDeriv(y(63)/y(94),(-params(30)),1);
T(55) = getPowerDeriv(y(64)/y(94),(-params(30)),1);
T(56) = getPowerDeriv(y(65)/y(94),(-params(30)),1);
T(57) = getPowerDeriv(y(140)/y(84),(-params(2)),1);
T(58) = (-y(140))/(y(84)*y(84))*T(57);
T(59) = getPowerDeriv(T(44),1/(1-params(28)),1);
T(60) = getPowerDeriv(y(87)/y(88),(-params(28)),1);
T(61) = getPowerDeriv(y(94)/y(88),(-params(28)),1);
end
