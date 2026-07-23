function [y, T] = dynamic_11(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
  T(56)=log(params(4)/(params(4)-1));
  y(74)=log(y(65)/y(71))-T(56);
  y(111)=params(46)*(log(y(59)/(steady_state(3)))-T(3));
  y(110)=params(45)*(log(y(58)/(steady_state(2)))-T(2));
  y(109)=params(44)*(log(y(57)/(steady_state(1)))-T(1));
  y(112)=y(87)*(y(99)+y(97)+y(98))+y(84)*y(88)-y(94)*y(100);
  y(73)=log(y(64)/y(70))-T(56);
  y(72)=log(y(63)/y(69))-T(56);
  y(108)=y(111)+y(109)+y(110);
  y(107)=params(50)*log(y(66))+params(51)*log(y(67))+params(52)*log(y(68));
end
