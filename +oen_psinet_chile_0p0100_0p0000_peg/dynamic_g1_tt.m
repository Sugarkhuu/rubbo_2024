function T = dynamic_g1_tt(T, y, x, params, steady_state, it_)
% function T = dynamic_g1_tt(T, y, x, params, steady_state, it_)
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

assert(length(T) >= 56);

T = oen_psinet_chile_0p0100_0p0000_peg.dynamic_resid_tt(T, y, x, params, steady_state, it_);

T(51) = getPowerDeriv(y(74)/y(38),(-params(2)),1);
T(52) = (-y(74))/(y(38)*y(38))*T(51);
T(53) = getPowerDeriv(T(43),1/(1-params(28)),1);
T(54) = getPowerDeriv(y(41)/y(42),(-params(28)),1);
T(55) = getPowerDeriv(y(41)/y(48),(-params(30)),1);
T(56) = getPowerDeriv(y(48)/y(42),(-params(28)),1);

end
