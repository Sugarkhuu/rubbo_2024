function residual = static_resid(T, y, x, params, T_flag)
% function residual = static_resid(T, y, x, params, T_flag)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T         [#temp variables by 1]  double   vector of temporary terms to be filled by function
%   y         [M_.endo_nbr by 1]      double   vector of endogenous variables in declaration order
%   x         [M_.exo_nbr by 1]       double   vector of exogenous variables in declaration order
%   params    [M_.param_nbr by 1]     double   vector of parameter values in declaration order
%                                              to evaluate the model
%   T_flag    boolean                 boolean  flag saying whether or not to calculate temporary terms
%
% Output:
%   residual
%

if T_flag
    T = oen_chile_exp_nonet_float.static_resid_tt(T, y, x, params);
end
residual = zeros(53, 1);
    residual(1) = (y(13)) - (T(5)*T(6)*T(7)*T(8));
    residual(2) = (y(14)) - (T(13)*T(14)*T(15)*T(16));
    residual(3) = (y(15)) - (T(21)*T(22)*T(23)*T(24));
    residual(4) = (y(19)) - (y(13)/y(7)*y(1)+y(19)*T(25));
    residual(5) = (y(20)) - (y(1)+y(20)*(1-params(5))*params(1)*T(26));
    residual(6) = (y(16)) - (y(19)*T(27)/y(20));
    residual(7) = (1) - ((1-params(5))*T(26)+params(5)*y(16)^(1-params(4)));
    residual(8) = (y(7)) - (y(7)*y(10));
    residual(9) = (y(21)) - (y(14)/y(8)*y(2)+y(21)*T(28));
    residual(10) = (y(22)) - (y(2)+y(22)*params(1)*(1-params(6))*T(29));
    residual(11) = (y(17)) - (T(27)*y(21)/y(22));
    residual(12) = (1) - ((1-params(6))*T(29)+params(6)*y(17)^(1-params(4)));
    residual(13) = (y(8)) - (y(8)*y(11));
    residual(14) = (y(23)) - (y(15)/y(9)*y(3)+y(23)*T(30));
    residual(15) = (y(24)) - (y(3)+y(24)*params(1)*(1-params(7))*T(31));
    residual(16) = (y(18)) - (T(27)*y(23)/y(24));
    residual(17) = (1) - ((1-params(7))*T(31)+params(7)*y(18)^(1-params(4)));
    residual(18) = (y(9)) - (y(9)*y(12));
    residual(19) = (y(4)) - (y(1)*y(13)*params(8)/y(32));
    residual(20) = (y(5)) - (y(2)*y(14)*params(9)/y(32));
    residual(21) = (y(6)) - (y(3)*y(15)*params(10)/y(32));
    residual(22) = (y(31)) - (y(6)+y(4)+y(5));
    residual(23) = (y(1)) - (params(23)*y(28)*y(26)/y(7)+(y(1)*y(13)*params(11)+y(2)*y(14)*params(14)+y(3)*y(15)*params(17))/y(7)+y(28)*y(38)/y(7));
    residual(24) = (y(2)) - (y(26)*y(28)*params(24)/y(8)+(y(1)*y(13)*params(12)+y(2)*y(14)*params(15)+y(3)*y(15)*params(18))/y(8)+y(28)*y(39)/y(8));
    residual(25) = (y(3)) - (y(26)*y(28)*params(25)/y(9)+(y(1)*y(13)*params(13)+y(2)*y(14)*params(16)+y(3)*y(15)*params(19))/y(9)+y(28)*y(40)/y(9));
    residual(26) = (y(28)) - (T(32)*T(33)*T(34));
    residual(27) = (y(29)) - (T(35)^(1/(1-params(28))));
    residual(28) = (y(26)) - (y(25)*T(36));
    residual(29) = (y(27)) - (y(25)*T(37));
    residual(30) = (y(30)) - (1);
    residual(31) = (T(38)) - (T(38)*params(1)*y(37)/y(30));
    residual(32) = (y(32)/y(29)) - (T(39)*T(40));
    residual(33) = (y(35)) - (y(33)*y(34));
    residual(34) = (y(37)) - (params(35)*(1-params(29)*(y(36)-params(31)))*y(44));
    residual(35) = (y(36)) - (y(36)*y(37)/y(30)+(y(28)*(y(40)+y(38)+y(39))-y(35)*y(41))/y(29));
    residual(36) = (y(38)) - (params(32)*y(42)*y(43)*T(41));
    residual(37) = (y(39)) - (y(43)*y(42)*params(33)*T(42));
    residual(38) = (y(40)) - (y(43)*y(42)*params(34)*T(43));
    residual(39) = (y(41)) - (y(27)+y(1)*y(13)*params(20)/y(35)+y(2)*y(14)*params(21)/y(35)+y(3)*y(15)*params(22)/y(35));
    residual(40) = (log(y(37)/params(35))) - (params(36)*y(48)+params(37)*y(49));
    residual(41) = (y(48)) - (params(50)*log(y(10))+params(51)*log(y(11))+params(52)*log(y(12)));
    residual(42) = (y(50)) - (params(44)*(log(y(1)/(y(1)))-log(y(45))));
    residual(43) = (y(51)) - (params(45)*(log(y(2)/(y(2)))-log(y(46))));
    residual(44) = (y(52)) - (params(46)*(log(y(3)/(y(3)))-log(y(47))));
    residual(45) = (y(49)) - (y(52)+y(50)+y(51));
    residual(46) = (log(y(45))) - (log(y(45))*params(39)+x(1));
    residual(47) = (log(y(46))) - (log(y(46))*params(39)+x(2));
    residual(48) = (log(y(47))) - (log(y(47))*params(39)+x(3));
    residual(49) = (log(y(34))) - (log(y(34))*params(40)+x(4));
    residual(50) = (log(y(42))) - (log(y(42))*params(41)+x(5));
    residual(51) = (log(y(43))) - (log(y(43))*params(42)+x(6));
    residual(52) = (log(y(44))) - (log(y(44))*params(43)+x(7));
    residual(53) = (y(53)) - (y(28)*(y(40)+y(38)+y(39))+y(25)*y(29)-y(35)*y(41));

end
