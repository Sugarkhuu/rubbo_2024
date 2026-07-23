function T = dynamic_resid_tt(T, y, x, params, steady_state, it_)
% function T = dynamic_resid_tt(T, y, x, params, steady_state, it_)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T             [#temp variables by 1]     double  vector of temporary terms to be filled by function
%   y             [#dynamic variables by 1]  double  vector of endogenous variables in the order stored
%                                                    in M_.lead_lag_incidence; see the Manual
%   x             [nperiods by M_.exo_nbr]   double  matrix of exogenous variables (in declaration order)
%                                                    for all simulation periods
%   steady_state  [M_.endo_nbr by 1]         double  vector of steady state values
%   params        [M_.param_nbr by 1]        double  vector of parameter values in declaration order
%   it_           scalar                     double  time period for exogenous variables for which
%                                                    to evaluate the model
%
% Output:
%   T           [#temp variables by 1]       double  vector of temporary terms
%

assert(length(T) >= 53);

T(1) = 1/y(61);
T(2) = y(48)^params(8);
T(3) = T(1)*T(2);
T(4) = y(20)^params(11);
T(5) = T(3)*T(4);
T(6) = y(21)^params(12);
T(7) = y(22)^params(13);
T(8) = y(51)^params(20);
T(9) = 1/y(62);
T(10) = y(48)^params(9);
T(11) = T(9)*T(10);
T(12) = y(20)^params(14);
T(13) = T(11)*T(12);
T(14) = y(21)^params(15);
T(15) = y(22)^params(16);
T(16) = y(51)^params(21);
T(17) = 1/y(63);
T(18) = y(48)^params(10);
T(19) = T(17)*T(18);
T(20) = y(20)^params(17);
T(21) = T(19)*T(20);
T(22) = y(21)^params(18);
T(23) = y(22)^params(19);
T(24) = y(51)^params(22);
T(25) = params(4)/(params(4)-1);
T(26) = log(T(25));
T(27) = (y(79)/y(41))^(-params(2));
T(28) = (1-params(5))*params(1)*T(27);
T(29) = y(70)^params(4);
T(30) = T(28)*T(29);
T(31) = y(70)^(params(4)-1);
T(32) = T(28)*T(31);
T(33) = y(71)^params(4);
T(34) = T(27)*params(1)*(1-params(6))*T(33);
T(35) = y(71)^(params(4)-1);
T(36) = T(27)*params(1)*(1-params(6))*T(35);
T(37) = y(72)^params(4);
T(38) = T(27)*params(1)*(1-params(7))*T(37);
T(39) = y(72)^(params(4)-1);
T(40) = T(27)*params(1)*(1-params(7))*T(39);
T(41) = y(20)^params(23);
T(42) = y(21)^params(24);
T(43) = y(22)^params(25);
T(44) = params(27)*y(44)^(1-params(28))+(1-params(27))*y(51)^(1-params(28));
T(45) = params(27)*(y(44)/y(45))^(-params(28));
T(46) = (1-params(27))*(y(51)/y(45))^(-params(28));
T(47) = y(79)^(-params(2));
T(48) = params(1)*y(53)*T(47);
T(49) = y(41)^params(2);
T(50) = y(47)^params(3);
T(51) = (y(20)/y(51))^(-params(30));
T(52) = (y(21)/y(51))^(-params(30));
T(53) = (y(22)/y(51))^(-params(30));

end
