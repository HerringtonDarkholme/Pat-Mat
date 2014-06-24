var Parameter, assignmentFactory, incrementalCounter, indexedCounter, nominalCounter, parameter, _ref;

_ref = require('./placeholder'), parameter = _ref.parameter, Parameter = _ref.Parameter;

assignmentFactory = function(accumulation, counterFunc) {
  accumulation.__unnamed__ = [];
  return function(expression, value) {
    var count;
    count = counterFunc(expression);
    if (count != null) {
      return accumulation[count] = value;
    } else {
      return accumulation.__unnamed__.push(value);
    }
  };
};

incrementalCounter = function() {
  var inc;
  inc = 0;
  return function(expression) {
    switch (false) {
      case !isFunc(expression):
        return inc++;
      case parameter !== expression:
        return inc++;
      case !(expression instanceof Parameter):
        return inc++;
      default:
        return null;
    }
  };
};

indexedCounter = nominalCounter = function() {
  return function(expression) {
    switch (false) {
      case !(expression instanceof Parameter):
        return expression.getKey();
      default:
        return null;
    }
  };
};
