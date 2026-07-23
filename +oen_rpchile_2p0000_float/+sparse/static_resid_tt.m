function [T_order, T] = static_resid_tt(y, x, params, T_order, T)
if T_order >= 0
    return
end
T_order = 0;
if size(T, 1) < 44
    T = [T; NaN(44 - size(T, 1), 1)];
end
T(1) = 1/y(48);
T(2) = y(35)^params(8);
T(3) = T(1)*T(2);
T(4) = y(7)^params(11);
T(5) = T(3)*T(4);
T(6) = y(8)^params(12);
T(7) = y(9)^params(13);
T(8) = y(38)^params(20);
T(9) = 1/y(49);
T(10) = y(35)^params(9);
T(11) = T(9)*T(10);
T(12) = y(7)^params(14);
T(13) = T(11)*T(12);
T(14) = y(8)^params(15);
T(15) = y(9)^params(16);
T(16) = y(38)^params(21);
T(17) = 1/y(50);
T(18) = y(35)^params(10);
T(19) = T(17)*T(18);
T(20) = y(7)^params(17);
T(21) = T(19)*T(20);
T(22) = y(8)^params(18);
T(23) = y(9)^params(19);
T(24) = y(38)^params(22);
T(25) = params(4)/(params(4)-1);
T(26) = log(T(25));
T(27) = (1-params(5))*params(1)*y(10)^params(4);
T(28) = y(10)^(params(4)-1);
T(29) = params(1)*(1-params(6))*y(11)^params(4);
T(30) = y(11)^(params(4)-1);
T(31) = params(1)*(1-params(7))*y(12)^params(4);
T(32) = y(12)^(params(4)-1);
T(33) = y(7)^params(23);
T(34) = y(8)^params(24);
T(35) = y(9)^params(25);
T(36) = params(27)*y(31)^(1-params(28))+(1-params(27))*y(38)^(1-params(28));
T(37) = params(27)*(y(31)/y(32))^(-params(28));
T(38) = (1-params(27))*(y(38)/y(32))^(-params(28));
T(39) = y(28)^(-params(2));
T(40) = y(28)^params(2);
T(41) = y(34)^params(3);
T(42) = (y(7)/y(38))^(-params(30));
T(43) = (y(8)/y(38))^(-params(30));
T(44) = (y(9)/y(38))^(-params(30));
end
