function [T_order, T] = static_g1_tt(y, x, params, T_order, T)
if T_order >= 1
    return
end
[T_order, T] = oen_impint_2p0000_managed.sparse.static_resid_tt(y, x, params, T_order, T);
T_order = 1;
if size(T, 1) < 39
    T = [T; NaN(39 - size(T, 1), 1)];
end
T(32) = getPowerDeriv(y(10),params(4)-1,1);
T(33) = getPowerDeriv(y(11),params(4)-1,1);
T(34) = getPowerDeriv(y(12),params(4)-1,1);
T(35) = getPowerDeriv(y(25),(-params(2)),1);
T(36) = getPowerDeriv(T(25),1/(1-params(21)),1);
T(37) = getPowerDeriv(y(28)/y(29),(-params(21)),1);
T(38) = getPowerDeriv(y(28)/y(35),(-params(23)),1);
T(39) = getPowerDeriv(y(35)/y(29),(-params(21)),1);
end
