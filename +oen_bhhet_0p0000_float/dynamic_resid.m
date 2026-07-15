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
    T = oen_bhhet_0p0000_float.dynamic_resid_tt(T, y, x, params, steady_state, it_);
end
residual = zeros(51, 1);
    residual(1) = (y(26)) - (T(3)*T(4));
    residual(2) = (y(27)) - (T(7)*T(8)*T(9));
    residual(3) = (y(28)) - (T(12)*T(13)*T(14));
    residual(4) = (y(32)) - (y(26)/y(20)*y(14)+T(18)*y(68));
    residual(5) = (y(33)) - (y(14)+T(20)*y(69));
    residual(6) = (y(29)) - (y(32)*T(21)/y(33));
    residual(7) = (1) - ((1-params(5))*y(23)^(params(4)-1)+params(5)*y(29)^(1-params(4)));
    residual(8) = (y(20)) - (y(23)*y(1));
    residual(9) = (y(34)) - (y(27)/y(21)*y(15)+T(23)*y(70));
    residual(10) = (y(35)) - (y(15)+T(25)*y(71));
    residual(11) = (y(30)) - (T(21)*y(34)/y(35));
    residual(12) = (1) - ((1-params(6))*y(24)^(params(4)-1)+params(6)*y(30)^(1-params(4)));
    residual(13) = (y(21)) - (y(24)*y(2));
    residual(14) = (y(36)) - (y(28)/y(22)*y(16)+T(27)*y(72));
    residual(15) = (y(37)) - (y(16)+T(29)*y(73));
    residual(16) = (y(31)) - (T(21)*y(36)/y(37));
    residual(17) = (1) - ((1-params(7))*y(25)^(params(4)-1)+params(7)*y(31)^(1-params(4)));
    residual(18) = (y(22)) - (y(25)*y(3));
    residual(19) = (y(17)) - (y(14)*y(26)*params(8)/y(45));
    residual(20) = (y(18)) - (y(15)*y(27)*params(9)/y(45));
    residual(21) = (y(19)) - (y(16)*y(28)*params(10)/y(45));
    residual(22) = (y(44)) - (y(19)+y(17)+y(18));
    residual(23) = (y(14)) - (params(16)*y(41)*y(39)/y(20)+y(15)*y(27)*params(11)/y(20)+params(16)*y(41)*y(51)/y(20));
    residual(24) = (y(15)) - (y(39)*y(41)*params(17)/y(21)+y(16)*y(28)*params(12)/y(21)+y(51)*y(41)*params(17)/y(21));
    residual(25) = (y(16)) - (y(39)*y(41)*params(18)/y(22)+y(51)*y(41)*params(18)/y(22));
    residual(26) = (y(41)) - (T(30)*T(31)*T(32));
    residual(27) = (y(42)) - (T(33)^(1/(1-params(21))));
    residual(28) = (y(39)) - (y(38)*T(34));
    residual(29) = (y(40)) - (y(38)*T(35));
    residual(30) = (y(43)) - (y(42)/y(4));
    residual(31) = (y(38)^(-params(2))) - (T(37)/y(75));
    residual(32) = (y(45)/y(42)) - (T(38)*T(39));
    residual(33) = (y(48)) - (y(46)*y(47));
    residual(34) = (y(50)) - (params(26)*(1-params(22)*(y(49)-params(25)))*y(55)*y(76)/y(46));
    residual(35) = (y(49)) - (y(7)/y(43)*y(6)+(y(41)*y(51)-y(48)*y(52))/y(42));
    residual(36) = (y(51)) - (params(24)*y(53)*y(54)*T(40));
    residual(37) = (y(52)) - (y(40)+y(14)*y(26)*params(13)/y(48)+y(15)*y(27)*params(14)/y(48)+y(16)*y(28)*params(15)/y(48));
    residual(38) = (log(y(50)/params(26))) - (params(27)*y(59)+params(28)*y(60));
    residual(39) = (y(59)) - (params(41)*log(y(23))+params(42)*log(y(24))+params(43)*log(y(25)));
    residual(40) = (y(61)) - (params(35)*(log(y(14)/(steady_state(1)))-log(y(56))));
    residual(41) = (y(62)) - (params(36)*(log(y(15)/(steady_state(2)))-log(y(57))));
    residual(42) = (y(63)) - (params(37)*(log(y(16)/(steady_state(3)))-log(y(58))));
    residual(43) = (y(60)) - (y(63)+y(61)+y(62));
    residual(44) = (log(y(56))) - (params(30)*log(y(11))+x(it_, 1));
    residual(45) = (log(y(57))) - (params(30)*log(y(12))+x(it_, 2));
    residual(46) = (log(y(58))) - (params(30)*log(y(13))+x(it_, 3));
    residual(47) = (log(y(47))) - (params(31)*log(y(5))+x(it_, 4));
    residual(48) = (log(y(53))) - (params(32)*log(y(8))+x(it_, 5));
    residual(49) = (log(y(54))) - (params(33)*log(y(9))+x(it_, 6));
    residual(50) = (log(y(55))) - (params(34)*log(y(10))+x(it_, 7));
    residual(51) = (y(64)) - (y(41)*y(51)+y(38)*y(42)-y(48)*y(52));

end
