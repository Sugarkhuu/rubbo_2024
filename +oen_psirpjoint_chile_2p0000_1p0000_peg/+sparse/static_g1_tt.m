function [T_order, T] = static_g1_tt(y, x, params, T_order, T)
if T_order >= 1
    return
end
[T_order, T] = oen_psirpjoint_chile_2p0000_1p0000_peg.sparse.static_resid_tt(y, x, params, T_order, T);
T_order = 1;
if size(T, 1) < 49
    T = [T; NaN(49 - size(T, 1), 1)];
end
T(42) = getPowerDeriv(y(10),params(4)-1,1);
T(43) = getPowerDeriv(y(11),params(4)-1,1);
T(44) = getPowerDeriv(y(12),params(4)-1,1);
T(45) = getPowerDeriv(y(25),(-params(2)),1);
T(46) = getPowerDeriv(T(35),1/(1-params(28)),1);
T(47) = getPowerDeriv(y(28)/y(29),(-params(28)),1);
T(48) = getPowerDeriv(y(28)/y(35),(-params(30)),1);
T(49) = getPowerDeriv(y(35)/y(29),(-params(28)),1);
end
