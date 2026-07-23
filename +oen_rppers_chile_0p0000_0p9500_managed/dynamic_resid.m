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
    T = oen_rppers_chile_0p0000_0p9500_managed.dynamic_resid_tt(T, y, x, params, steady_state, it_);
end
residual = zeros(56, 1);
    residual(1) = (y(26)) - (T(5)*T(6)*T(7)*T(8));
    residual(2) = (y(27)) - (T(13)*T(14)*T(15)*T(16));
    residual(3) = (y(28)) - (T(21)*T(22)*T(23)*T(24));
    residual(4) = (y(29)) - (log(y(20)/y(26))-T(26));
    residual(5) = (y(30)) - (log(y(21)/y(27))-T(26));
    residual(6) = (y(31)) - (log(y(22)/y(28))-T(26));
    residual(7) = (y(35)) - (y(26)/y(20)*y(14)+T(30)*y(73));
    residual(8) = (y(36)) - (y(14)+T(32)*y(74));
    residual(9) = (y(32)) - (T(25)*y(35)/y(36));
    residual(10) = (1) - ((1-params(5))*y(23)^(params(4)-1)+params(5)*y(32)^(1-params(4)));
    residual(11) = (y(20)) - (y(23)*y(1));
    residual(12) = (y(37)) - (y(27)/y(21)*y(15)+T(34)*y(75));
    residual(13) = (y(38)) - (y(15)+T(36)*y(76));
    residual(14) = (y(33)) - (T(25)*y(37)/y(38));
    residual(15) = (1) - ((1-params(6))*y(24)^(params(4)-1)+params(6)*y(33)^(1-params(4)));
    residual(16) = (y(21)) - (y(24)*y(2));
    residual(17) = (y(39)) - (y(28)/y(22)*y(16)+T(38)*y(77));
    residual(18) = (y(40)) - (y(16)+T(40)*y(78));
    residual(19) = (y(34)) - (T(25)*y(39)/y(40));
    residual(20) = (1) - ((1-params(7))*y(25)^(params(4)-1)+params(7)*y(34)^(1-params(4)));
    residual(21) = (y(22)) - (y(25)*y(3));
    residual(22) = (y(17)) - (y(14)*y(26)*params(8)/y(48));
    residual(23) = (y(18)) - (y(15)*y(27)*params(9)/y(48));
    residual(24) = (y(19)) - (y(16)*y(28)*params(10)/y(48));
    residual(25) = (y(47)) - (y(19)+y(17)+y(18));
    residual(26) = (y(14)) - (params(23)*y(44)*y(42)/y(20)+(y(14)*y(26)*params(11)+y(15)*y(27)*params(14)+y(16)*y(28)*params(17))/y(20)+y(44)*y(54)/y(20));
    residual(27) = (y(15)) - (y(42)*y(44)*params(24)/y(21)+(y(14)*y(26)*params(12)+y(15)*y(27)*params(15)+y(16)*y(28)*params(18))/y(21)+y(44)*y(55)/y(21));
    residual(28) = (y(16)) - (y(42)*y(44)*params(25)/y(22)+(y(14)*y(26)*params(13)+y(15)*y(27)*params(16)+y(16)*y(28)*params(19))/y(22)+y(44)*y(56)/y(22));
    residual(29) = (y(44)) - (T(41)*T(42)*T(43));
    residual(30) = (y(45)) - (T(44)^(1/(1-params(28))));
    residual(31) = (y(42)) - (y(41)*T(45));
    residual(32) = (y(43)) - (y(41)*T(46));
    residual(33) = (y(46)) - (y(45)/y(4));
    residual(34) = (y(41)^(-params(2))) - (T(48)/y(80));
    residual(35) = (y(48)/y(45)) - (T(49)*T(50));
    residual(36) = (y(51)) - (y(49)*y(50));
    residual(37) = (y(53)) - (params(35)*(1-params(29)*(y(52)-params(31)))*y(60)*y(81)/y(49));
    residual(38) = (y(52)) - (y(7)/y(46)*y(6)+(y(44)*(y(56)+y(54)+y(55))-y(51)*y(57))/y(45));
    residual(39) = (y(54)) - (params(32)*y(58)*y(59)*T(51));
    residual(40) = (y(55)) - (y(59)*y(58)*params(33)*T(52));
    residual(41) = (y(56)) - (y(59)*y(58)*params(34)*T(53));
    residual(42) = (y(57)) - (y(43)+y(14)*y(26)*params(20)/y(51)+y(15)*y(27)*params(21)/y(51)+y(16)*y(28)*params(22)/y(51));
    residual(43) = (log(y(53)/params(35))) - (params(36)*y(64)+params(37)*y(65)+params(38)*log(y(49)));
    residual(44) = (y(64)) - (params(50)*log(y(23))+params(51)*log(y(24))+params(52)*log(y(25)));
    residual(45) = (y(66)) - (params(44)*(log(y(14)/(steady_state(1)))-log(y(61))));
    residual(46) = (y(67)) - (params(45)*(log(y(15)/(steady_state(2)))-log(y(62))));
    residual(47) = (y(68)) - (params(46)*(log(y(16)/(steady_state(3)))-log(y(63))));
    residual(48) = (y(65)) - (y(68)+y(66)+y(67));
    residual(49) = (log(y(61))) - (params(39)*log(y(11))+x(it_, 1));
    residual(50) = (log(y(62))) - (params(39)*log(y(12))+x(it_, 2));
    residual(51) = (log(y(63))) - (params(39)*log(y(13))+x(it_, 3));
    residual(52) = (log(y(50))) - (params(40)*log(y(5))+x(it_, 4));
    residual(53) = (log(y(58))) - (params(41)*log(y(8))+x(it_, 5));
    residual(54) = (log(y(59))) - (params(42)*log(y(9))+x(it_, 6));
    residual(55) = (log(y(60))) - (params(43)*log(y(10))+x(it_, 7));
    residual(56) = (y(69)) - (y(44)*(y(56)+y(54)+y(55))+y(41)*y(45)-y(51)*y(57));

end
