function [T_order, T] = dynamic_g1_tt(y, x, params, steady_state, T_order, T)
if T_order >= 1
    return
end
[T_order, T] = oen_bhhet_0p0000_float.sparse.dynamic_resid_tt(y, x, params, steady_state, T_order, T);
T_order = 1;
if size(T, 1) < 46
    T = [T; NaN(46 - size(T, 1), 1)];
end
T(41) = getPowerDeriv(y(127)/y(76),(-params(2)),1);
T(42) = (-y(127))/(y(76)*y(76))*T(41);
T(43) = getPowerDeriv(T(33),1/(1-params(21)),1);
T(44) = getPowerDeriv(y(79)/y(80),(-params(21)),1);
T(45) = getPowerDeriv(y(79)/y(86),(-params(23)),1);
T(46) = getPowerDeriv(y(86)/y(80),(-params(21)),1);
end
