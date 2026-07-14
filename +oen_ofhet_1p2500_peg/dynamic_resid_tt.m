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

assert(length(T) >= 40);

T(1) = 1/y(52);
T(2) = y(43)^params(8);
T(3) = T(1)*T(2);
T(4) = y(46)^params(13);
T(5) = 1/y(53);
T(6) = y(43)^params(9);
T(7) = T(5)*T(6);
T(8) = y(18)^params(11);
T(9) = y(46)^params(14);
T(10) = 1/y(54);
T(11) = y(43)^params(10);
T(12) = T(10)*T(11);
T(13) = y(19)^params(12);
T(14) = y(46)^params(15);
T(15) = (y(70)/y(36))^(-params(2));
T(16) = (1-params(5))*params(1)*T(15);
T(17) = y(61)^params(4);
T(18) = T(16)*T(17);
T(19) = y(61)^(params(4)-1);
T(20) = T(16)*T(19);
T(21) = params(4)/(params(4)-1);
T(22) = y(62)^params(4);
T(23) = T(15)*params(1)*(1-params(6))*T(22);
T(24) = y(62)^(params(4)-1);
T(25) = T(15)*params(1)*(1-params(6))*T(24);
T(26) = y(63)^params(4);
T(27) = T(15)*params(1)*(1-params(7))*T(26);
T(28) = y(63)^(params(4)-1);
T(29) = T(15)*params(1)*(1-params(7))*T(28);
T(30) = y(18)^params(16);
T(31) = y(19)^params(17);
T(32) = y(20)^params(18);
T(33) = params(20)*y(39)^(1-params(21))+(1-params(20))*y(46)^(1-params(21));
T(34) = params(20)*(y(39)/y(40))^(-params(21));
T(35) = (1-params(20))*(y(46)/y(40))^(-params(21));
T(36) = y(70)^(-params(2));
T(37) = params(1)*y(48)*T(36);
T(38) = y(36)^params(2);
T(39) = y(42)^params(3);
T(40) = (y(39)/y(46))^(-params(23));

end
