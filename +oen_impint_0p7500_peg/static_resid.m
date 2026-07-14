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
    T = oen_impint_0p7500_peg.static_resid_tt(T, y, x, params);
end
residual = zeros(49, 1);
    residual(1) = (y(13)) - (T(3)*T(4));
    residual(2) = (y(14)) - (T(7)*T(8)*T(9));
    residual(3) = (y(15)) - (T(12)*T(13)*T(14));
    residual(4) = (y(19)) - (y(13)/y(7)*y(1)+y(19)*T(15));
    residual(5) = (y(20)) - (y(1)+y(20)*(1-params(5))*params(1)*T(16));
    residual(6) = (y(16)) - (y(19)*T(17)/y(20));
    residual(7) = (1) - ((1-params(5))*T(16)+params(5)*y(16)^(1-params(4)));
    residual(8) = (y(7)) - (y(7)*y(10));
    residual(9) = (y(21)) - (y(14)/y(8)*y(2)+y(21)*T(18));
    residual(10) = (y(22)) - (y(2)+y(22)*params(1)*(1-params(6))*T(19));
    residual(11) = (y(17)) - (T(17)*y(21)/y(22));
    residual(12) = (1) - ((1-params(6))*T(19)+params(6)*y(17)^(1-params(4)));
    residual(13) = (y(8)) - (y(8)*y(11));
    residual(14) = (y(23)) - (y(15)/y(9)*y(3)+y(23)*T(20));
    residual(15) = (y(24)) - (y(3)+y(24)*params(1)*(1-params(7))*T(21));
    residual(16) = (y(18)) - (T(17)*y(23)/y(24));
    residual(17) = (1) - ((1-params(7))*T(21)+params(7)*y(18)^(1-params(4)));
    residual(18) = (y(9)) - (y(9)*y(12));
    residual(19) = (y(4)) - (y(1)*y(13)*params(8)/y(32));
    residual(20) = (y(5)) - (y(2)*y(14)*params(9)/y(32));
    residual(21) = (y(6)) - (y(3)*y(15)*params(10)/y(32));
    residual(22) = (y(31)) - (y(6)+y(4)+y(5));
    residual(23) = (y(1)) - (params(16)*y(28)*y(26)/y(7)+y(2)*y(14)*params(11)/y(7)+params(16)*y(28)*y(38)/y(7));
    residual(24) = (y(2)) - (y(26)*y(28)*params(17)/y(8)+y(3)*y(15)*params(12)/y(8)+y(38)*y(28)*params(17)/y(8));
    residual(25) = (y(3)) - (y(26)*y(28)*params(18)/y(9)+y(38)*y(28)*params(18)/y(9));
    residual(26) = (y(28)) - (T(22)*T(23)*T(24));
    residual(27) = (y(29)) - (T(25)^(1/(1-params(21))));
    residual(28) = (y(26)) - (y(25)*T(26));
    residual(29) = (y(27)) - (y(25)*T(27));
    residual(30) = (y(30)) - (1);
    residual(31) = (T(28)) - (T(28)*params(1)*y(37)/y(30));
    residual(32) = (y(32)/y(29)) - (T(29)*T(30));
    residual(33) = (y(35)) - (y(34));
    residual(34) = (y(37)) - (params(26)*(1-params(22)*(y(36)-params(25))));
    residual(35) = (y(36)) - (y(36)*y(37)/y(30)+(y(28)*y(38)-y(35)*y(39))/y(29));
    residual(36) = (y(38)) - (params(24)*y(40)*T(31));
    residual(37) = (y(39)) - (y(27)+y(1)*y(13)*params(13)/y(35)+y(2)*y(14)*params(14)/y(35)+y(3)*y(15)*params(15)/y(35));
    residual(38) = (y(33)) - (1);
    residual(39) = (y(44)) - (params(39)*log(y(10))+params(40)*log(y(11))+params(41)*log(y(12)));
    residual(40) = (y(46)) - (params(33)*(log(y(1)/(y(1)))-log(y(41))));
    residual(41) = (y(47)) - (params(34)*(log(y(2)/(y(2)))-log(y(42))));
    residual(42) = (y(48)) - (params(35)*(log(y(3)/(y(3)))-log(y(43))));
    residual(43) = (y(45)) - (y(48)+y(46)+y(47));
    residual(44) = (log(y(41))) - (log(y(41))*params(30)+x(1));
    residual(45) = (log(y(42))) - (log(y(42))*params(30)+x(2));
    residual(46) = (log(y(43))) - (log(y(43))*params(30)+x(3));
    residual(47) = (log(y(34))) - (log(y(34))*params(31)+x(4));
    residual(48) = (log(y(40))) - (log(y(40))*params(32)+x(5));
    residual(49) = (y(49)) - (y(28)*y(38)+y(25)*y(29)-y(35)*y(39));

end
