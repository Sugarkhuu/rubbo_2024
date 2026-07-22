function [T_order, T] = dynamic_g1_tt(y, x, params, steady_state, T_order, T)
if T_order >= 1
    return
end
[T_order, T] = oen_phisnet_chile_0p0000_1p5000.sparse.dynamic_resid_tt(y, x, params, steady_state, T_order, T);
T_order = 1;
if size(T, 1) < 60
    T = [T; NaN(60 - size(T, 1), 1)];
end
T(53) = getPowerDeriv(y(60)/y(88),(-params(30)),1);
T(54) = getPowerDeriv(y(61)/y(88),(-params(30)),1);
T(55) = getPowerDeriv(y(62)/y(88),(-params(30)),1);
T(56) = getPowerDeriv(y(131)/y(78),(-params(2)),1);
T(57) = (-y(131))/(y(78)*y(78))*T(56);
T(58) = getPowerDeriv(T(43),1/(1-params(28)),1);
T(59) = getPowerDeriv(y(81)/y(82),(-params(28)),1);
T(60) = getPowerDeriv(y(88)/y(82),(-params(28)),1);
end
