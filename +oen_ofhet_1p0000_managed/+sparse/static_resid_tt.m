function [T_order, T] = static_resid_tt(y, x, params, T_order, T)
if T_order >= 0
    return
end
T_order = 0;
if size(T, 1) < 31
    T = [T; NaN(31 - size(T, 1), 1)];
end
T(1) = 1/y(41);
T(2) = y(32)^params(8);
T(3) = T(1)*T(2);
T(4) = y(35)^params(13);
T(5) = 1/y(42);
T(6) = y(32)^params(9);
T(7) = T(5)*T(6);
T(8) = y(7)^params(11);
T(9) = y(35)^params(14);
T(10) = 1/y(43);
T(11) = y(32)^params(10);
T(12) = T(10)*T(11);
T(13) = y(8)^params(12);
T(14) = y(35)^params(15);
T(15) = (1-params(5))*params(1)*y(10)^params(4);
T(16) = y(10)^(params(4)-1);
T(17) = params(4)/(params(4)-1);
T(18) = params(1)*(1-params(6))*y(11)^params(4);
T(19) = y(11)^(params(4)-1);
T(20) = params(1)*(1-params(7))*y(12)^params(4);
T(21) = y(12)^(params(4)-1);
T(22) = y(7)^params(16);
T(23) = y(8)^params(17);
T(24) = y(9)^params(18);
T(25) = params(20)*y(28)^(1-params(21))+(1-params(20))*y(35)^(1-params(21));
T(26) = params(20)*(y(28)/y(29))^(-params(21));
T(27) = (1-params(20))*(y(35)/y(29))^(-params(21));
T(28) = y(25)^(-params(2));
T(29) = y(25)^params(2);
T(30) = y(31)^params(3);
T(31) = (y(28)/y(35))^(-params(23));
end
