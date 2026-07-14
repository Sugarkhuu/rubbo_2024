function residual = dynamic_resid(T, y, x, params, steady_state, it_, T_flag)
% function residual = dynamic_resid(T, y, x, params, steady_state, it_, T_flag)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T             [#temp variables by 1]     double   vector of temporary terms to be filled by function
%   y             [#dynamic variables by 1]  double   vector of endogenous variables in the order stored
%                                                     in M_.lead_lag_incidence; see the Manual
%   x             [nperiods by M_.exo_nbr]   double   matrix of exogenous variables (in declaration order)
%                                                     for all simulation periods
%   steady_state  [M_.endo_nbr by 1]         double   vector of steady state values
%   params        [M_.param_nbr by 1]        double   vector of parameter values in declaration order
%   it_           scalar                     double   time period for exogenous variables for which
%                                                     to evaluate the model
%   T_flag        boolean                    boolean  flag saying whether or not to calculate temporary terms
%
% Output:
%   residual
%

if T_flag
    T = oen_impint_2p5000_float.dynamic_resid_tt(T, y, x, params, steady_state, it_);
end
residual = zeros(49, 1);
    residual(1) = (y(24)) - (T(3)*T(4));
    residual(2) = (y(25)) - (T(7)*T(8)*T(9));
    residual(3) = (y(26)) - (T(12)*T(13)*T(14));
    residual(4) = (y(30)) - (y(24)/y(18)*y(12)+T(18)*y(64));
    residual(5) = (y(31)) - (y(12)+T(20)*y(65));
    residual(6) = (y(27)) - (y(30)*T(21)/y(31));
    residual(7) = (1) - ((1-params(5))*y(21)^(params(4)-1)+params(5)*y(27)^(1-params(4)));
    residual(8) = (y(18)) - (y(21)*y(1));
    residual(9) = (y(32)) - (y(25)/y(19)*y(13)+T(23)*y(66));
    residual(10) = (y(33)) - (y(13)+T(25)*y(67));
    residual(11) = (y(28)) - (T(21)*y(32)/y(33));
    residual(12) = (1) - ((1-params(6))*y(22)^(params(4)-1)+params(6)*y(28)^(1-params(4)));
    residual(13) = (y(19)) - (y(22)*y(2));
    residual(14) = (y(34)) - (y(26)/y(20)*y(14)+T(27)*y(68));
    residual(15) = (y(35)) - (y(14)+T(29)*y(69));
    residual(16) = (y(29)) - (T(21)*y(34)/y(35));
    residual(17) = (1) - ((1-params(7))*y(23)^(params(4)-1)+params(7)*y(29)^(1-params(4)));
    residual(18) = (y(20)) - (y(23)*y(3));
    residual(19) = (y(15)) - (y(12)*y(24)*params(8)/y(43));
    residual(20) = (y(16)) - (y(13)*y(25)*params(9)/y(43));
    residual(21) = (y(17)) - (y(14)*y(26)*params(10)/y(43));
    residual(22) = (y(42)) - (y(17)+y(15)+y(16));
    residual(23) = (y(12)) - (params(16)*y(39)*y(37)/y(18)+y(13)*y(25)*params(11)/y(18)+params(16)*y(39)*y(49)/y(18));
    residual(24) = (y(13)) - (y(37)*y(39)*params(17)/y(19)+y(14)*y(26)*params(12)/y(19)+y(49)*y(39)*params(17)/y(19));
    residual(25) = (y(14)) - (y(37)*y(39)*params(18)/y(20)+y(49)*y(39)*params(18)/y(20));
    residual(26) = (y(39)) - (T(30)*T(31)*T(32));
    residual(27) = (y(40)) - (T(33)^(1/(1-params(21))));
    residual(28) = (y(37)) - (y(36)*T(34));
    residual(29) = (y(38)) - (y(36)*T(35));
    residual(30) = (y(41)) - (y(40)/y(4));
    residual(31) = (y(36)^(-params(2))) - (T(37)/y(71));
    residual(32) = (y(43)/y(40)) - (T(38)*T(39));
    residual(33) = (y(46)) - (y(44)*y(45));
    residual(34) = (y(48)) - (params(26)*(1-params(22)*(y(47)-params(25)))*y(72)/y(44));
    residual(35) = (y(47)) - (y(7)/y(41)*y(6)+(y(39)*y(49)-y(46)*y(50))/y(40));
    residual(36) = (y(49)) - (params(24)*y(51)*T(40));
    residual(37) = (y(50)) - (y(38)+y(12)*y(24)*params(13)/y(46)+y(13)*y(25)*params(14)/y(46)+y(14)*y(26)*params(15)/y(46));
    residual(38) = (log(y(48)/params(26))) - (params(27)*y(55)+params(28)*y(56));
    residual(39) = (y(55)) - (params(39)*log(y(21))+params(40)*log(y(22))+params(41)*log(y(23)));
    residual(40) = (y(57)) - (params(33)*(log(y(12)/(steady_state(1)))-log(y(52))));
    residual(41) = (y(58)) - (params(34)*(log(y(13)/(steady_state(2)))-log(y(53))));
    residual(42) = (y(59)) - (params(35)*(log(y(14)/(steady_state(3)))-log(y(54))));
    residual(43) = (y(56)) - (y(59)+y(57)+y(58));
    residual(44) = (log(y(52))) - (params(30)*log(y(9))+x(it_, 1));
    residual(45) = (log(y(53))) - (params(30)*log(y(10))+x(it_, 2));
    residual(46) = (log(y(54))) - (params(30)*log(y(11))+x(it_, 3));
    residual(47) = (log(y(45))) - (params(31)*log(y(5))+x(it_, 4));
    residual(48) = (log(y(51))) - (params(32)*log(y(8))+x(it_, 5));
    residual(49) = (y(60)) - (y(39)*y(49)+y(36)*y(40)-y(46)*y(50));

end
