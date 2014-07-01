var NamedParameter, Parameter, assignmentFactory, incrementalCounter, indexedCounter, isFunc, nominalCounter, parameter, _ref;

_ref = require('./placeholder'), parameter = _ref.parameter, Parameter = _ref.Parameter, NamedParameter = _ref.NamedParameter;

isFunc = require('./util').isFunc;

assignmentFactory = function(accumulation, unnamed, counterFunc) {
  var counter;
  counter = counterFunc();
  return function(expression, value) {
    var count;
    count = counter(expression);
    if (count != null) {
      return accumulation[count] = value;
    } else {
      return unnamed.push(value);
    }
  };
};

incrementalCounter = function() {
  var inc;
  inc = 0;
  return function(expression) {
    switch (false) {
      case !(expression instanceof NamedParameter && expression.name === null):
        return null;
      case !isFunc(expression):
        return inc++;
      case expression !== parameter:
        return inc++;
      case !(expression instanceof Parameter):
        return inc++;
      default:
        return null;
    }
  };
};

indexedCounter = function() {
  return function(expression) {
    switch (false) {
      case !(expression instanceof NamedParameter && expression.name === null):
        return null;
      case !(expression instanceof Parameter):
        return expression.index;
      default:
        return null;
    }
  };
};

nominalCounter = function() {
  return function(expression) {
    switch (false) {
      case !(expression instanceof Parameter):
        return expression.getKey();
      default:
        return null;
    }
  };
};

module.exports = {
  assignmentFactory: assignmentFactory,
  incrementalCounter: incrementalCounter,
  indexedCounter: indexedCounter,
  nominalCounter: nominalCounter
};
