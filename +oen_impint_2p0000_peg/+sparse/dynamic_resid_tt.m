function [T_order, T] = dynamic_resid_tt(y, x, params, steady_state, T_order, T)
if T_order >= 0
    return
end
T_order = 0;
if size(T, 1) < 40
    T = [T; NaN(40 - size(T, 1), 1)];
end
T(1) = 1/y(90);
T(2) = y(81)^params(8);
T(3) = T(1)*T(2);
T(4) = y(84)^params(13);
T(5) = 1/y(91);
T(6) = y(81)^params(9);
T(7) = T(5)*T(6);
T(8) = y(56)^params(11);
T(9) = y(84)^params(14);
T(10) = 1/y(92);
T(11) = y(81)^params(10);
T(12) = T(10)*T(11);
T(13) = y(57)^params(12);
T(14) = y(84)^params(15);
T(15) = (y(123)/y(74))^(-params(2));
T(16) = (1-params(5))*params(1)*T(15);
T(17) = y(108)^params(4);
T(18) = T(16)*T(17);
T(19) = y(108)^(params(4)-1);
T(20) = T(16)*T(19);
T(21) = params(4)/(params(4)-1);
T(22) = y(109)^params(4);
T(23) = T(15)*params(1)*(1-params(6))*T(22);
T(24) = y(109)^(params(4)-1);
T(25) = T(15)*params(1)*(1-params(6))*T(24);
T(26) = y(110)^params(4);
T(27) = T(15)*params(1)*(1-params(7))*T(26);
T(28) = y(110)^(params(4)-1);
T(29) = T(15)*params(1)*(1-params(7))*T(28);
T(30) = y(56)^params(16);
T(31) = y(57)^params(17);
T(32) = y(58)^params(18);
T(33) = params(20)*y(77)^(1-params(21))+(1-params(20))*y(84)^(1-params(21));
T(34) = params(20)*(y(77)/y(78))^(-params(21));
T(35) = (1-params(20))*(y(84)/y(78))^(-params(21));
T(36) = y(123)^(-params(2));
T(37) = params(1)*y(86)*T(36);
T(38) = y(74)^params(2);
T(39) = y(80)^params(3);
T(40) = (y(77)/y(84))^(-params(23));
end
