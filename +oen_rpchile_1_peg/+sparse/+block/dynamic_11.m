function [y, T] = dynamic_11(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
  y(105)=params(46)*(log(y(56)/(steady_state(3)))-T(3));
  y(104)=params(45)*(log(y(55)/(steady_state(2)))-T(2));
  y(103)=params(44)*(log(y(54)/(steady_state(1)))-T(1));
  y(106)=y(81)*(y(93)+y(91)+y(92))+y(78)*y(82)-y(88)*y(94);
  y(102)=y(105)+y(103)+y(104);
  y(101)=params(50)*log(y(63))+params(51)*log(y(64))+params(52)*log(y(65));
end
