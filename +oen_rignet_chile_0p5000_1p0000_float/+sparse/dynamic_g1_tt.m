function [T_order, T] = dynamic_g1_tt(y, x, params, steady_state, T_order, T)
if T_order >= 1
    return
end
[T_order, T] = oen_rignet_chile_0p5000_1p0000_float.sparse.dynamic_resid_tt(y, x, params, steady_state, T_order, T);
T_order = 1;
if size(T, 1) < 56
    T = [T; NaN(56 - size(T, 1), 1)];
end
T(51) = getPowerDeriv(y(127)/y(76),(-params(2)),1);
T(52) = (-y(127))/(y(76)*y(76))*T(51);
T(53) = getPowerDeriv(T(43),1/(1-params(28)),1);
T(54) = getPowerDeriv(y(79)/y(80),(-params(28)),1);
T(55) = getPowerDeriv(y(79)/y(86),(-params(30)),1);
T(56) = getPowerDeriv(y(86)/y(80),(-params(28)),1);
end
