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
    T = oen_phisnet_chile_2p0000_0p1000.dynamic_resid_tt(T, y, x, params, steady_state, it_);
end
residual = zeros(53, 1);
    residual(1) = (y(26)) - (T(5)*T(6)*T(7)*T(8));
    residual(2) = (y(27)) - (T(13)*T(14)*T(15)*T(16));
    residual(3) = (y(28)) - (T(21)*T(22)*T(23)*T(24));
    residual(4) = (y(32)) - (y(26)/y(20)*y(14)+T(28)*y(70));
    residual(5) = (y(33)) - (y(14)+T(30)*y(71));
    residual(6) = (y(29)) - (y(32)*T(31)/y(33));
    residual(7) = (1) - ((1-params(5))*y(23)^(params(4)-1)+params(5)*y(29)^(1-params(4)));
    residual(8) = (y(20)) - (y(23)*y(1));
    residual(9) = (y(34)) - (y(27)/y(21)*y(15)+T(33)*y(72));
    residual(10) = (y(35)) - (y(15)+T(35)*y(73));
    residual(11) = (y(30)) - (T(31)*y(34)/y(35));
    residual(12) = (1) - ((1-params(6))*y(24)^(params(4)-1)+params(6)*y(30)^(1-params(4)));
    residual(13) = (y(21)) - (y(24)*y(2));
    residual(14) = (y(36)) - (y(28)/y(22)*y(16)+T(37)*y(74));
    residual(15) = (y(37)) - (y(16)+T(39)*y(75));
    residual(16) = (y(31)) - (T(31)*y(36)/y(37));
    residual(17) = (1) - ((1-params(7))*y(25)^(params(4)-1)+params(7)*y(31)^(1-params(4)));
    residual(18) = (y(22)) - (y(25)*y(3));
    residual(19) = (y(17)) - (y(14)*y(26)*params(8)/y(45));
    residual(20) = (y(18)) - (y(15)*y(27)*params(9)/y(45));
    residual(21) = (y(19)) - (y(16)*y(28)*params(10)/y(45));
    residual(22) = (y(44)) - (y(19)+y(17)+y(18));
    residual(23) = (y(14)) - (params(23)*y(41)*y(39)/y(20)+(y(14)*y(26)*params(11)+y(15)*y(27)*params(14)+y(16)*y(28)*params(17))/y(20)+y(41)*y(51)/y(20));
    residual(24) = (y(15)) - (y(39)*y(41)*params(24)/y(21)+(y(14)*y(26)*params(12)+y(15)*y(27)*params(15)+y(16)*y(28)*params(18))/y(21)+y(41)*y(52)/y(21));
    residual(25) = (y(16)) - (y(39)*y(41)*params(25)/y(22)+(y(14)*y(26)*params(13)+y(15)*y(27)*params(16)+y(16)*y(28)*params(19))/y(22)+y(41)*y(53)/y(22));
    residual(26) = (y(41)) - (T(40)*T(41)*T(42));
    residual(27) = (y(42)) - (T(43)^(1/(1-params(28))));
    residual(28) = (y(39)) - (y(38)*T(44));
    residual(29) = (y(40)) - (y(38)*T(45));
    residual(30) = (y(43)) - (y(42)/y(4));
    residual(31) = (y(38)^(-params(2))) - (T(47)/y(77));
    residual(32) = (y(45)/y(42)) - (T(48)*T(49));
    residual(33) = (y(48)) - (y(46)*y(47));
    residual(34) = (y(50)) - (params(35)*(1-params(29)*(y(49)-params(31)))*y(57)*y(78)/y(46));
    residual(35) = (y(49)) - (y(7)/y(43)*y(6)+(y(41)*(y(53)+y(51)+y(52))-y(48)*y(54))/y(42));
    residual(36) = (y(51)) - (params(32)*y(55)*y(56)*T(50));
    residual(37) = (y(52)) - (y(56)*y(55)*params(33)*T(51));
    residual(38) = (y(53)) - (y(56)*y(55)*params(34)*T(52));
    residual(39) = (y(54)) - (y(40)+y(14)*y(26)*params(20)/y(48)+y(15)*y(27)*params(21)/y(48)+y(16)*y(28)*params(22)/y(48));
    residual(40) = (log(y(50)/params(35))) - (params(36)*y(61)+params(37)*y(62)+params(38)*log(y(46)));
    residual(41) = (y(61)) - (params(50)*log(y(23))+params(51)*log(y(24))+params(52)*log(y(25)));
    residual(42) = (y(63)) - (params(44)*(log(y(14)/(steady_state(1)))-log(y(58))));
    residual(43) = (y(64)) - (params(45)*(log(y(15)/(steady_state(2)))-log(y(59))));
    residual(44) = (y(65)) - (params(46)*(log(y(16)/(steady_state(3)))-log(y(60))));
    residual(45) = (y(62)) - (y(65)+y(63)+y(64));
    residual(46) = (log(y(58))) - (params(39)*log(y(11))+x(it_, 1));
    residual(47) = (log(y(59))) - (params(39)*log(y(12))+x(it_, 2));
    residual(48) = (log(y(60))) - (params(39)*log(y(13))+x(it_, 3));
    residual(49) = (log(y(47))) - (params(40)*log(y(5))+x(it_, 4));
    residual(50) = (log(y(55))) - (params(41)*log(y(8))+x(it_, 5));
    residual(51) = (log(y(56))) - (params(42)*log(y(9))+x(it_, 6));
    residual(52) = (log(y(57))) - (params(43)*log(y(10))+x(it_, 7));
    residual(53) = (y(66)) - (y(41)*(y(53)+y(51)+y(52))+y(38)*y(42)-y(48)*y(54));

end
