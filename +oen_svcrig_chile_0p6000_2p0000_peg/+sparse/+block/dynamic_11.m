function [y, T] = dynamic_11(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
  y(101)=params(44)*(log(y(54)/(steady_state(3)))-T(3));
  y(100)=params(43)*(log(y(53)/(steady_state(2)))-T(2));
  y(99)=params(42)*(log(y(52)/(steady_state(1)))-T(1));
  y(102)=y(79)*y(89)+y(76)*y(80)-y(86)*y(90);
  y(98)=y(101)+y(99)+y(100);
  y(97)=params(48)*log(y(61))+params(49)*log(y(62))+params(50)*log(y(63));
end
