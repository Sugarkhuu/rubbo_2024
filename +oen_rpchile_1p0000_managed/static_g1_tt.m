function T = static_g1_tt(T, y, x, params)
% function T = static_g1_tt(T, y, x, params)
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

assert(length(T) >= 54);

T = oen_rpchile_1p0000_managed.static_resid_tt(T, y, x, params);

T(45) = getPowerDeriv(y(7)/y(38),(-params(30)),1);
T(46) = getPowerDeriv(y(8)/y(38),(-params(30)),1);
T(47) = getPowerDeriv(y(9)/y(38),(-params(30)),1);
T(48) = getPowerDeriv(y(10),params(4)-1,1);
T(49) = getPowerDeriv(y(11),params(4)-1,1);
T(50) = getPowerDeriv(y(12),params(4)-1,1);
T(51) = getPowerDeriv(y(28),(-params(2)),1);
T(52) = getPowerDeriv(T(36),1/(1-params(28)),1);
T(53) = getPowerDeriv(y(31)/y(32),(-params(28)),1);
T(54) = getPowerDeriv(y(38)/y(32),(-params(28)),1);

end
