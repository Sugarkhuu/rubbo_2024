function T = static_resid_tt(T, y, x, params)
% function T = static_resid_tt(T, y, x, params)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T         [#temp variables by 1]  double   vector of temporary terms to be filled by function
%   y         [M_.endo_nbr by 1]      double   vector of endogenous variables in declaration order
%   x         [M_.exo_nbr by 1]       double   vector of exogenous variables in declaration order
%   params    [M_.param_nbr by 1]     double   vector of parameter values in declaration order
%
% Output:
%   T         [#temp variables by 1]  double   vector of temporary terms
%

assert(length(T) >= 43);

T(1) = 1/y(45);
T(2) = y(32)^params(8);
T(3) = T(1)*T(2);
T(4) = y(7)^params(11);
T(5) = T(3)*T(4);
T(6) = y(8)^params(12);
T(7) = y(9)^params(13);
T(8) = y(35)^params(20);
T(9) = 1/y(46);
T(10) = y(32)^params(9);
T(11) = T(9)*T(10);
T(12) = y(7)^params(14);
T(13) = T(11)*T(12);
T(14) = y(8)^params(15);
T(15) = y(9)^params(16);
T(16) = y(35)^params(21);
T(17) = 1/y(47);
T(18) = y(32)^params(10);
T(19) = T(17)*T(18);
T(20) = y(7)^params(17);
T(21) = T(19)*T(20);
T(22) = y(8)^params(18);
T(23) = y(9)^params(19);
T(24) = y(35)^params(22);
T(25) = (1-params(5))*params(1)*y(10)^params(4);
T(26) = y(10)^(params(4)-1);
T(27) = params(4)/(params(4)-1);
T(28) = params(1)*(1-params(6))*y(11)^params(4);
T(29) = y(11)^(params(4)-1);
T(30) = params(1)*(1-params(7))*y(12)^params(4);
T(31) = y(12)^(params(4)-1);
T(32) = y(7)^params(23);
T(33) = y(8)^params(24);
T(34) = y(9)^params(25);
T(35) = params(27)*y(28)^(1-params(28))+(1-params(27))*y(35)^(1-params(28));
T(36) = params(27)*(y(28)/y(29))^(-params(28));
T(37) = (1-params(27))*(y(35)/y(29))^(-params(28));
T(38) = y(25)^(-params(2));
T(39) = y(25)^params(2);
T(40) = y(31)^params(3);
T(41) = (y(7)/y(35))^(-params(30));
T(42) = (y(8)/y(35))^(-params(30));
T(43) = (y(9)/y(35))^(-params(30));

end
