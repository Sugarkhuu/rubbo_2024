function [y, T] = dynamic_9(y, x, params, steady_state, sparse_rowval, sparse_colval, sparse_colptr, T)
  y(97)=params(35)*(log(y(52)/(steady_state(3)))-T(3));
  y(96)=params(34)*(log(y(51)/(steady_state(2)))-T(2));
  y(95)=params(33)*(log(y(50)/(steady_state(1)))-T(1));
  y(98)=y(77)*y(87)+y(74)*y(78)-y(84)*y(88);
  y(94)=y(97)+y(95)+y(96);
  y(93)=params(39)*log(y(59))+params(40)*log(y(60))+params(41)*log(y(61));
end
