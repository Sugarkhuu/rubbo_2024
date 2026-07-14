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

assert(length(T) >= 39);

T = oen_impint_0p5000_peg.static_resid_tt(T, y, x, params);

T(32) = getPowerDeriv(y(10),params(4)-1,1);
T(33) = getPowerDeriv(y(11),params(4)-1,1);
T(34) = getPowerDeriv(y(12),params(4)-1,1);
T(35) = getPowerDeriv(y(25),(-params(2)),1);
T(36) = getPowerDeriv(T(25),1/(1-params(21)),1);
T(37) = getPowerDeriv(y(28)/y(29),(-params(21)),1);
T(38) = getPowerDeriv(y(28)/y(35),(-params(23)),1);
T(39) = getPowerDeriv(y(35)/y(29),(-params(21)),1);

end
