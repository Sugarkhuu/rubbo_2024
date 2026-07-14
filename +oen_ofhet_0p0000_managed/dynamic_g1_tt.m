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

assert(length(T) >= 46);

T = oen_ofhet_0p0000_managed.dynamic_resid_tt(T, y, x, params, steady_state, it_);

T(41) = getPowerDeriv(y(70)/y(36),(-params(2)),1);
T(42) = (-y(70))/(y(36)*y(36))*T(41);
T(43) = getPowerDeriv(T(33),1/(1-params(21)),1);
T(44) = getPowerDeriv(y(39)/y(40),(-params(21)),1);
T(45) = getPowerDeriv(y(39)/y(46),(-params(23)),1);
T(46) = getPowerDeriv(y(46)/y(40),(-params(21)),1);

end
