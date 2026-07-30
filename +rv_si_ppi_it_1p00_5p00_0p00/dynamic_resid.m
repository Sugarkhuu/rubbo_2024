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
    T = rv_si_ppi_it_1p00_5p00_0p00.dynamic_resid_tt(T, y, x, params, steady_state, it_);
end
residual = zeros(51, 1);
    residual(1) = (y(27)) - (T(5)*T(6)*T(7)*T(8));
    residual(2) = (y(28)) - (T(13)*T(14)*T(15)*T(16));
    residual(3) = (y(29)) - (T(21)*T(22)*T(23)*T(24));
    residual(4) = (y(33)) - (y(27)/y(21)*y(15)+T(28)*y(69));
    residual(5) = (y(34)) - (y(15)+T(30)*y(70));
    residual(6) = (y(30)) - (y(33)*T(31)/y(34));
    residual(7) = (1) - ((1-params(5))*y(24)^(params(4)-1)+params(5)*y(30)^(1-params(4)));
    residual(8) = (y(21)) - (y(24)*y(1));
    residual(9) = (y(35)) - (y(28)/y(22)*y(16)+T(33)*y(71));
    residual(10) = (y(36)) - (y(16)+T(35)*y(72));
    residual(11) = (y(31)) - (T(31)*y(35)/y(36));
    residual(12) = (1) - ((1-params(6))*y(25)^(params(4)-1)+params(6)*y(31)^(1-params(4)));
    residual(13) = (y(22)) - (y(25)*y(2));
    residual(14) = (y(37)) - (y(29)/y(23)*y(17)+T(37)*y(73));
    residual(15) = (y(38)) - (y(17)+T(39)*y(74));
    residual(16) = (y(32)) - (T(31)*y(37)/y(38));
    residual(17) = (1) - ((1-params(7))*y(26)^(params(4)-1)+params(7)*y(32)^(1-params(4)));
    residual(18) = (y(23)) - (y(26)*y(3));
    residual(19) = (y(18)) - (y(15)*y(27)*params(8)/y(46));
    residual(20) = (y(19)) - (y(16)*y(28)*params(9)/y(46));
    residual(21) = (y(20)) - (y(17)*y(29)*params(10)/y(46));
    residual(22) = (y(45)) - (y(20)+y(18)+y(19));
    residual(23) = (y(15)) - (params(23)*y(42)*y(40)/y(21)+(y(15)*y(27)*params(11)+y(16)*y(28)*params(14)+y(17)*y(29)*params(17))/y(21)+params(23)*y(42)*y(52)/y(21));
    residual(24) = (y(16)) - (y(40)*y(42)*params(24)/y(22)+(y(15)*y(27)*params(12)+y(16)*y(28)*params(15)+y(17)*y(29)*params(18))/y(22)+y(52)*y(42)*params(24)/y(22));
    residual(25) = (y(17)) - (y(40)*y(42)*params(25)/y(23)+(y(15)*y(27)*params(13)+y(16)*y(28)*params(16)+y(17)*y(29)*params(19))/y(23)+y(52)*y(42)*params(25)/y(23));
    residual(26) = (y(42)) - (T(40)*T(41)*T(42));
    residual(27) = (y(43)) - (T(43)^(1/(1-params(28))));
    residual(28) = (y(40)) - (y(39)*T(44));
    residual(29) = (y(41)) - (y(39)*T(45));
    residual(30) = (y(44)) - (y(43)/y(5));
    residual(31) = (y(39)^(-params(2))) - (T(47)/y(76));
    residual(32) = (y(46)/y(43)) - (T(48)*T(49));
    residual(33) = (y(49)) - (y(47)*y(48));
    residual(34) = (y(51)) - (params(33)*(1-params(29)*(y(50)-params(32)))*y(56)*y(77)/y(47));
    residual(35) = (y(50)) - (y(8)/y(44)*y(7)+(y(42)*y(52)-y(49)*y(53))/y(43));
    residual(36) = (y(52)) - (params(31)*y(54)*y(55)*T(50));
    residual(37) = (y(53)) - (y(41)+y(15)*y(27)*params(20)/y(49)+y(16)*y(28)*params(21)/y(49)+y(17)*y(29)*params(22)/y(49));
    residual(38) = (log(y(51)/params(33))) - (params(34)*log(y(42)/y(4))+params(35)*y(61));
    residual(39) = (y(60)) - (params(48)*log(y(24))+params(49)*log(y(25))+params(50)*log(y(26)));
    residual(40) = (y(62)) - (params(42)*(log(y(15)/(steady_state(1)))-log(y(57))));
    residual(41) = (y(63)) - (params(43)*(log(y(16)/(steady_state(2)))-log(y(58))));
    residual(42) = (y(64)) - (params(44)*(log(y(17)/(steady_state(3)))-log(y(59))));
    residual(43) = (y(61)) - (y(64)+y(62)+y(63));
    residual(44) = (log(y(57))) - (params(37)*log(y(12))+x(it_, 1));
    residual(45) = (log(y(58))) - (params(37)*log(y(13))+x(it_, 2));
    residual(46) = (log(y(59))) - (params(37)*log(y(14))+x(it_, 3));
    residual(47) = (log(y(48))) - (params(38)*log(y(6))+x(it_, 4));
    residual(48) = (log(y(54))) - (params(39)*log(y(9))+x(it_, 5));
    residual(49) = (log(y(55))) - (params(40)*log(y(10))+x(it_, 6));
    residual(50) = (log(y(56))) - (params(41)*log(y(11))+x(it_, 7));
    residual(51) = (y(65)) - (y(42)*y(52)+y(39)*y(43)-y(49)*y(53));

end
