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

T = rv_si_ppi_it_1p00_5p00_0p00.dynamic_resid_tt(T, y, x, params, steady_state, it_);

T(51) = getPowerDeriv(y(75)/y(39),(-params(2)),1);
T(52) = (-y(75))/(y(39)*y(39))*T(51);
T(53) = getPowerDeriv(T(43),1/(1-params(28)),1);
T(54) = getPowerDeriv(y(42)/y(43),(-params(28)),1);
T(55) = getPowerDeriv(y(42)/y(49),(-params(30)),1);
T(56) = getPowerDeriv(y(49)/y(43),(-params(28)),1);

end
